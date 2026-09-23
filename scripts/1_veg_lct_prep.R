############################################################################################
# 1_veg_lct_prep.R  --  turn the land-cover posterior into two plain tables
#
# WHERE THIS SITS IN THE PIPELINE
#   This is step 1 of 9. Everything downstream (the albedo calibration, the hindcasts,
#   the forcing) needs, for every grid cell and every time slice, one number per land-cover
#   class: the fraction of the cell that is evergreen trees (ET), summergreen trees (ST)
#   and open land (OL). This script produces exactly that, once for "today" and once for
#   the whole Holocene, and adds the elevation of each cell because the calibration model
#   uses elevation as a predictor.
#
# WHAT COMES IN
#   data/veg_posts_interp_ice.RDS   (334 MB, Git LFS)
#     A data.frame of 41,961,600 rows and 9 columns. It is the OUTPUT of a Bayesian model
#     run outside this repository (Dawson et al., Climate of the Past): pollen -> REVEALS
#     (a pollen-to-vegetation model) -> spatial interpolation onto a 1-degree grid, with an ice mask. Being Bayesian, it
#     does not give one answer per cell; it gives 200 "posterior draws" (column `iter`),
#     each a plausible map. One row = one cell, one time slice, one draw, one class:
#       cell_area  area of the cell (km^2)                 <- dropped by this script
#       cell_id    integer id of the 1-degree cell
#       x, y       LONGITUDE and LATITUDE in degrees. Despite the names these are not
#                  projected metres; every spatial smooth later in the pipeline therefore
#                  works in degrees.
#       ages       time slice in years before present: 50, 200, 500, 1000, ..., 11500 (25)
#       iter       posterior draw, 1..200
#       LCT        land-cover type: "ET", "ST" or "OL"
#       value      fraction of the cell in that class, 0..1; ET+ST+OL = 1 within a draw
#       ice        flag marking cell-slices under the ice sheet   <- dropped by this script
#     (2,870 cells appear somewhere in the 25 slices; 2,870 x 25 x 200 x 3 would be 43.05
#     million rows. 1,814 cell-slices, about 2.5 %, are absent, hence 41.96 million.
#     Which ones, and why, has not been checked; ice-covered cells are NOT systematically
#     absent, see the walkthrough's cell 8165.)
#
# WHAT GOES OUT
#   data/lct_modern_reveals_interp.RDS   2,860 rows x 6:  x, y, elev, ET, OL, ST
#     The slice at 50 years BP, i.e. roughly the satellite era. This is the table the
#     albedo calibration (scripts 2, 4, 5) is fitted on.
#   data/lct_paleo_reveals_interp.RDS    69,936 rows x 7:  ages, x, y, elev, ET, OL, ST
#     All 25 slices, including 50 BP. This is what the fitted model hindcasts from
#     (script 6). 69,936 rows: 2,870 cells over 25 slices minus 1,814 absent cell-slices.
#     Only 2,860 of the cells are present at 50 BP, which is why the modern table is
#     shorter.
#
# WHAT IT DOES, IN ONE SENTENCE
#   Average the 200 draws to a single map per slice, spread the three classes into
#   columns, look up elevation for every cell, split off the modern slice, save both.
#
# NOTE ON WHAT IS THROWN AWAY
#   Averaging the draws discards the posterior spread (the uncertainty in the land cover
#   maps), and the grouping step below drops `cell_area` and `ice`. Later scripts have to
#   recover the ice information from other files. Both are deliberate simplifications of
#   the code as received, not accidents of this annotated copy.
#
# RUN TIME  About 4 minutes, nearly all of it the elevation lookup, which needs the network.
#
# HOW TO LAUNCH  Run it through the activated environment (`micromamba run -n paleo-rf
#   Rscript scripts/1_veg_lct_prep.R`). Calling the Rscript binary by its full path skips
#   the environment's activation hooks, which set PROJ_DATA and GDAL_DATA; without them the
#   elevation lookup fails with "PROJ: proj_create_from_database: Open of .../share/proj
#   failed". If you must call the binary directly, set PROJ_DATA=<env>/share/proj first.
#   This is the only script in the pipeline that trips over it, because it is the only one
#   that goes through sf's coordinate-system database.
############################################################################################

# Only three packages are used on this path. dplyr and tidyr do the reshaping; elevatr
# fetches elevation. (The original file also loaded sp, raster, terra, reshape2 and
# ggplot2 for the point-based version of the pipeline, which has been removed here.)
library(dplyr)
library(tidyr)
library(elevatr)

############################################################################################
# Coordinate reference system
############################################################################################

# A "proj string" describing plain longitude/latitude on the WGS84 ellipsoid. It is passed
# to the elevation service so it knows the coordinates we send are degrees, not metres.
ll_proj = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"

############################################################################################
# Load the posterior and collapse the 200 draws to their mean
############################################################################################

# Read the whole 334 MB table into memory (about 3 GB as an R object).
lct_interp = readRDS('data/veg_posts_interp_ice.RDS')

# ---- Collapse the posterior draws ----------------------------------------------------
# For each combination of cell, location, slice and class, take the mean of `value` over
# the 200 draws. group_by() says which columns define a group; summarize() then computes
# one row per group. Two things happen here that are easy to miss:
#   1. Any column NOT named in group_by() and NOT computed in summarize() disappears. That
#      is how `iter` (intended), `cell_area` and `ice` (side effects) are dropped.
#   2. dplyr's summarize() removes only the LAST grouping variable (LCT) from the result,
#      so `lct_interp` comes back still grouped by cell_id, x, y and ages. That grouping is
#      harmless for the next step and is cleared when we convert to a data.frame below.
# Result: 41,961,600 rows -> 209,808 rows (one per cell-slice-class), 6 columns.
lct_interp = lct_interp %>% 
  group_by(cell_id, x, y, ages, LCT) %>%
  summarize(value = mean(value))

# ---- Long to wide -----------------------------------------------------------------------
# The table is "long": three rows per cell-slice, one per class. The models downstream want
# it "wide": one row per cell-slice with columns ET, ST, OL. pivot_wider() does that:
#   id_cols     the columns that identify a row in the wide table
#   names_from  the column whose values become new column NAMES  (LCT -> "ET","OL","ST")
#   values_from the column whose values fill those new columns  (value)
# Result: 69,936 rows x 7 (cell_id, x, y, ages, ET, OL, ST).
lct_interp_wide = pivot_wider(lct_interp, id_cols = c('cell_id', 'x', 'y', 'ages'), names_from = c('LCT'), values_from = c('value'))
# pivot_wider() returns a tibble (dplyr's flavour of data.frame). Convert to a plain
# data.frame so that base-R indexing later behaves the way the rest of the code expects.
lct_interp_wide = data.frame(lct_interp_wide)

############################################################################################
# Elevation for every cell
############################################################################################

# Take just the coordinates. There is one row per cell-slice here (69,936), so every cell's
# coordinates appear up to 25 times; the elevation service is simply asked 25 times for
# the same point. Wasteful but harmless.
locations_interp = lct_interp_wide[,c('x', 'y')]

# ---- Elevation lookup (network) -----------------------------------------------------------
# get_elev_point() sends the coordinates to Amazon's terrain-tile service and returns the
# elevation in metres at each point. `prj` tells it the coordinates are lon/lat degrees.
# Two consequences worth knowing:
#   * it needs an internet connection and takes a few minutes;
#   * it depends on a remote service, so `elev` is treated as not bit-for-bit reproducible
#     (the anchors README compares it with a tolerance); whether repeated lookups actually
#     differ has not been tested. The re-run of 2026-09-23 returned identical values.
# Elevation is used downstream as a predictor of albedo (higher ground is snowier).
ele_get_interp = get_elev_point(locations_interp, prj=ll_proj, src = "aws")

# Assemble the final table in the column order the rest of the pipeline expects:
# ages, x, y, then elev pulled out of the elevatr result, then the three class fractions.
# Note that `cell_id` is deliberately not carried forward; later scripts re-derive a cell
# id by looking coordinates up in data/grid.RDS.
lct_interp_all = data.frame(lct_interp_wide[,c('ages', 'x', 'y')], 
                     elev = ele_get_interp$elevation, 
                     lct_interp_wide[,c('ET', 'OL', 'ST')])

############################################################################################
# Split off the modern slice and save
############################################################################################

# "Modern" means the 50 years BP slice, the one closest to the 2000-2009 satellite albedo
# the calibration is fitted against. which() returns the row numbers where the condition
# is TRUE; indexing with them keeps those rows. 2,860 rows.
lct_interp_modern = lct_interp_all[which(lct_interp_all$ages == 50), ]

# The modern table does not need an `ages` column (they are all 50), so drop it. The
# expression keeps every column whose name is NOT in the set c('ages').
lct_interp_modern = lct_interp_modern[, which(!(colnames(lct_interp_modern) %in% c('ages')))]

# Save the modern table: input to script 2 (albedo sampling) and hence to the calibration.
saveRDS(lct_interp_modern, 'data/lct_modern_reveals_interp.RDS')

# The paleo table is simply everything, modern slice included, under a new name.
lct_interp_paleo = lct_interp_all

# Save the paleo table: input to script 6 (hindcasting albedo for every slice).
saveRDS(lct_interp_paleo, 'data/lct_paleo_reveals_interp.RDS')
