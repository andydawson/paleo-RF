############################################################################################
# 7a_alb_diff_full.R  --  albedo change between consecutive slices, split into
#                          vegetation and ice contributions
#
# WHERE THIS SITS IN THE PIPELINE
#   Step 7a of 9 (it does not depend on script 7; both read script 6's output). Script 6
#   gave every cell an albedo for every slice and month, assuming the cell is vegetated.
#   But for much of the early Holocene many northern cells were under the ice sheet, whose
#   albedo is high and has nothing to do with vegetation. This script brings the ice in:
#   it looks up the ice fraction of every cell at every slice, combines vegetation and ice
#   albedo into a cell albedo, and then takes the difference between each slice and the
#   next older one. Those differences are what script 8 turns into forcing.
#
# WHAT COMES IN
#   output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS   839,232 x 13
#     From script 6: per cell, slice and month, the mean and quantiles of modelled albedo.
#   data/Dalton_QSR_2020_Ice/dalton_interpolated_LC6k.tif   26 layers, 116 x 62 cells
#     Ice FRACTION (0..1) per grid cell for slices 12,000 to 50 BP, layers named yr<n>bp.
#   data/albedo_glacier_monthly.csv                          12 rows
#     Monthly albedo to assign to ice: `ice_albedo_fixed` (0.68 all year) and
#     `ice_albedo_sc` (seasonal, 0.56 to 0.80). The "sc" variants below use the latter.
#   data/grid.RDS   the 1-degree grid, for cell ids and cell areas.
#
# WHAT GOES OUT
#   data/ALB_diffs_bluesky.RDS       806,172 x 21   (anchored; reproduces byte for byte)
#     2,866 cells; 211 of them (all south of 27 N or north of 74 N) have fewer than 24
#     pairs, and script 8 trims them, leaving 764,640 rows.
#     One row per cell x month x consecutive slice-pair (24 pairs from 25 slices). `year`
#     is the YOUNGER slice of the pair. Ten alb_diff_* columns, all young minus old.
#
# TWO WAYS OF COMBINING VEGETATION AND ICE, HENCE TWO FAMILIES OF COLUMNS
#   "_part" (area-weighted):  cell albedo = ice_albedo x ice_frac + veg_albedo x (1 - ice_frac)
#     Treats the cell as a mix; a cell 30% under ice gets 30% of the ice albedo.
#   "_thresh" (all or nothing): the cell is ice if ice_frac > 0.5, otherwise vegetation.
#     Simpler, and closer to how the binary ice mask was used elsewhere.
#   Within each family the change is further split into a vegetation contribution (albedo
#   of the vegetated area changing) and an ice contribution (ice giving way to vegetation),
#   and there are "ice" and "icesc" versions depending on which ice albedo is used. The
#   naming: alb_diff_<veg|ice|icesc|veg_ice|veg_icesc>_<thresh|part|parts>.
#   Which of these the paper should use is an open question (questions file, C section).
#
# SIGN AND PAIRING
#   Rows for one cell and month are sorted young to old (50, 200, 500, ...). Each
#   difference is computed as -diff(), i.e. young minus old, so a fall in albedo over time
#   is negative here and becomes a positive (warming) forcing in script 8.
#
# RUN TIME  About 50 minutes (51.7 in the manifest), almost all in the per-cell loop at
#   the end, which grows its result with rbind() inside a double loop (quadratic). Stage 4
#   of the staged plan replaces it. Memory is not recorded in the manifest; observed
#   around 12 GB.
############################################################################################

# sp and raster for the point/raster operations that still use those older packages,
# terra for the Dalton raster and reprojection, sf for cell areas, dplyr for counts,
# ggplot2 for two exploratory plots at the end.
library(sp)
library(raster)
library(dplyr)
library(terra)
library(sf)
library(ggplot2)

alb_prod = "bluesky"

# Provenance manifest; see script 8's header.
source('R/run_manifest.R')
run_start('7a_alb_diff_full',
          note   = Sys.getenv('RUN_NOTE'),
          inputs = Filter(file.exists, c(
            paste0('output/prediction/paleo_interp_predict_gam_summary_', alb_prod, '.RDS'),
            'data/Dalton_QSR_2020_Ice/dalton_interpolated_LC6k.tif',
            'data/albedo_glacier_monthly.csv',
            'data/grid.RDS',
            'data/map-data/geographic/pbs_ll.RDS',
            'data/map-data/geographic/pbs.RDS')),
          config = list(alb_prod = alb_prod))

# The 25 slice ages (years BP), how many there are, and the coarse subset used for maps.
ages = c(50, 200, seq(500, 11500, by=500))
N_times = length(ages)
ages_sub = c(50, 500, 2000, 4000, 6000, 8000, 10000, 12000)

months = c('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec')

# Albedo bin edges (as fractions) for a binned column computed below and never used.
breaks_alb = c(0, 4, 8, 12, 16, 20, 40, 60, 80, 100)/100

# Map limits; unused here.
ylim = c(12, 82) 
xlim = c(-166, -50) 

# WGS84 lon/lat, as a proj string, for the point objects.
proj_WGS84 <- '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0'

# Script 6's summary: one row per cell x slice x month.
alb_interp_preds = readRDS(paste0('output/prediction/paleo_interp_predict_gam_summary_', alb_prod, '.RDS'))

# Binned mean albedo; computed, unused.
alb_interp_preds$alb_bin = cut(alb_interp_preds$alb_mean, breaks_alb, labels=FALSE)

############################################################################################
# Ice fraction per cell and slice, from the Dalton raster
############################################################################################

# 26-layer raster of ice fraction; parse each layer name ("yr8000bp") into its year.
ice_dalton_interp = rast('data/Dalton_QSR_2020_Ice/dalton_interpolated_LC6k.tif')
ice_dalton_years = as.numeric(sapply(names(ice_dalton_interp), function(x) strsplit(x, 'yr|bp')[[1]][2]))

# New column to hold the ice fraction of each row's cell at its slice.
alb_interp_preds$ice_frac = NA

# The slices present in the predictions (25 of them).
alb_preds_ages = unique(alb_interp_preds$year)

for (i in 1:length(alb_preds_ages)){
  
  print(paste0('Albedo year ', alb_preds_ages[i], ' YBP'))
  # Rows (all months, all cells) for this slice.
  idx_age = which(alb_interp_preds$year == alb_preds_ages[i])
  
  # Their coordinates as sp points in lon/lat.
  coords_veg  = SpatialPoints(alb_interp_preds[idx_age,c('x', 'y')], 
                              proj4string=CRS(proj_WGS84))
  
  # ---- Match the slice to a Dalton layer and sample it ----------------------------------
  # match() gives the index of the layer whose year equals this slice's year (every one
  # of the 25 slice ages has a layer, so this never returns NA). project() makes sure the
  # layer is in lon/lat; the points are converted to terra and projected to the same CRS.
  idx_ice = match(alb_preds_ages[i], ice_dalton_years)
  ice_layer = project(ice_dalton_interp[[idx_ice]], proj_WGS84)
  
  coords_veg_spat = vect(coords_veg)
  coords_veg_spat_proj = project(coords_veg_spat, crs(ice_layer))
  
  # extract() returns a two-column frame (point id, value); column 2 is the ice fraction.
  ice_status_veg = terra::extract(ice_layer, coords_veg_spat_proj)
  
  # Histogram of this slice's ice fractions, to the default graphics device (Rplots.pdf).
  hist(ice_status_veg[,2])
  
  # Store.
  alb_interp_preds[idx_age, 'ice_frac'] = ice_status_veg[,2]
  
}

# Drop cells west of 170 W (the far Aleutians) and any row where the ice raster had no
# value (its extent is slightly smaller than the prediction grid).
alb_interp_preds = alb_interp_preds[which(alb_interp_preds$x > -170),]

alb_interp_preds = alb_interp_preds[which(!is.na(alb_interp_preds$ice_frac)),]

############################################################################################
# Grid cell ids and areas
############################################################################################

# Boundaries (loaded for maps that are commented out).
pbs_ll = readRDS('data/map-data/geographic/pbs_ll.RDS')
pbs = readRDS('data/map-data/geographic/pbs.RDS')

# Bin labels 1..9; unused.
labels = seq(1, length(breaks_alb)-1)

# Slice ages in thousands of years, as strings, for facet labels.
labels_ages_full = signif(data.frame(age = ages)/1000, 3)
labels_ages_full$facets = paste(labels_ages_full$age)

# The 24 consecutive slice-pairs as (young, old) in ka, with a label like "0.05-0.2" and a
# running id. Defined for plots that are commented out.
labels_period_full = data.frame(end_young = ages[1:(length(ages)-1)]/1000, 
                                end_old = ages[2:length(ages)]/1000)
labels_period_full$facets = paste(labels_period_full$end_young, labels_period_full$end_old, sep='-')

labels_period_full$period_id = seq(1, nrow(labels_period_full))

# Another lon/lat proj string; unused here.
ll_proj = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"

# The coarse ages again; unused here.
years = c(50, 500, 2000, 4000, 6000, 8000, 10000, 12000)

# Bin edges and labels for albedo, redefined; used for a binned column below.
breaks_alb = c(0, 5, 10, 20, 30, 40, 60, 80, 100)/100
labels_alb = c("0 - 5", "5 - 10", "10 - 20", "20 - 30", "30 - 40", "40 - 60", "60 - 80", "80 - 100")

# The 1-degree grid as a raster, and as a table of (x, y, cell id).
grid_NA <- readRDS("data/grid.RDS")
grid_df = as.data.frame(grid_NA, xy=TRUE)

# Look up which grid cell each prediction row's coordinates fall in.
cell_id <- raster::extract(grid_NA, alb_interp_preds[,c('x', 'y')])

# Prefix the cell id, then get each cell's CENTRE coordinates from the grid (so all rows in
# a cell share exactly the same long/lat, whatever their original x/y).
alb_grid <- data.frame(cell_id, alb_interp_preds)
coords   = xyFromCell(grid_NA, alb_grid$cell_id)
colnames(coords) = c('long', 'lat')

# Keep the columns needed from here on.
alb_grid = cbind(coords, 
                 alb_grid[,c('x', 'y', 'cell_id', 'year', 'ice_frac', 'alb_mean', 'alb_sd', 'month')])

# ---- Cell areas ---------------------------------------------------------------------------
# Convert the grid to polygons, then to sf, and ask sf for each polygon's area on the
# ellipsoid (m^2). A 1-degree cell shrinks towards the pole: about 11,800 km^2 at 17.5 N
# (the grid's southern edge), 7,700 at 51.5 N, 2,500 at 78.5 N. These areas are what
# script 9 uses to weight cells.
spdf_2 <- as(grid_NA,'SpatialPolygonsDataFrame')

sf_data = st_as_sf(spdf_2)
grid_df$area <- st_area(sf_data) #area of each "square"
grid_df$area_km2 <- units::set_units(grid_df$area, "km^2") # in km2
colnames(grid_df) = c('long', 'lat', 'cell_id', 'area', 'area_km2')

# Join the areas onto the prediction rows by cell.
alb_grid = merge(alb_grid, grid_df, by = c('cell_id', 'lat', 'long'))

alb_grid_full = alb_grid

############################################################################################
# Combine vegetation and ice albedo, both ways
############################################################################################

# Monthly ice albedo table; look up the two ice-albedo conventions by month.
alb_glacier = read.csv('data/albedo_glacier_monthly.csv', header=TRUE)

alb_grid_full$ice_albedo_fixed = alb_glacier[match(alb_grid_full$month, alb_glacier$month), 'ice_albedo_fixed']
alb_grid_full$ice_albedo_sc = alb_glacier[match(alb_grid_full$month, alb_glacier$month), 'ice_albedo_sc']

# The modelled albedo is, by construction, the albedo of the vegetated surface.
alb_grid_full$alb_veg = alb_grid_full$alb_mean

# ---- Area-weighted ("part") combination ---------------------------------------------------
# Ice part: ice albedo times the ice fraction. Vegetation part: vegetation albedo times
# the rest. Their sum is the cell's albedo under the mixing assumption.
alb_grid_full$alb_ice_part = alb_grid_full$ice_albedo_fixed * alb_grid_full$ice_frac
alb_grid_full$alb_icesc_part = alb_grid_full$ice_albedo_sc * alb_grid_full$ice_frac 

alb_grid_full$alb_veg_part = alb_grid_full$alb_veg * (1 - alb_grid_full$ice_frac)

alb_grid_full$alb_veg_ice_parts = alb_grid_full$alb_ice_part + alb_grid_full$alb_veg_part 
alb_grid_full$alb_veg_icesc_parts = alb_grid_full$alb_icesc_part + alb_grid_full$alb_veg_part 

# ---- Threshold combination ------------------------------------------------------------
# Rows more than half ice are "ice cells"; the rest are "vegetation cells". The vegetation
# albedo is blanked in ice cells and the ice albedo in vegetation cells, so each cell has
# exactly one of the two; rowSums with na.rm = TRUE then picks whichever is present.
idx_ice = which(alb_grid_full$ice_frac > 0.5)
idx_veg = which(alb_grid_full$ice_frac <= 0.5)

alb_grid_full$alb_veg_thresh = alb_grid_full$alb_veg
alb_grid_full$alb_veg_thresh[idx_ice] = NA

alb_grid_full$alb_ice_thresh = alb_grid_full$ice_albedo_fixed
alb_grid_full$alb_ice_thresh[idx_veg] = NA

alb_grid_full$alb_icesc_thresh = alb_grid_full$ice_albedo_sc
alb_grid_full$alb_icesc_thresh[idx_veg] = NA

alb_grid_full$alb_veg_ice_thresh = rowSums(cbind(alb_grid_full$alb_veg_thresh, alb_grid_full$alb_ice_thresh), na.rm=TRUE)
alb_grid_full$alb_veg_icesc_thresh = rowSums(cbind(alb_grid_full$alb_veg_thresh, alb_grid_full$alb_icesc_thresh), na.rm=TRUE)

############################################################################################
# Coverage checks (printed; nothing changes the data)
############################################################################################

# Number of distinct cells present at each slice.
alb_grid_full_cells = alb_grid_full %>%
  group_by(year) %>%
  dplyr::summarize(N_all = n_distinct(cell_id))

# Per cell and month, how many slices have a row. A complete cell has 25.
cell_count_summary = alb_grid_full[,c('cell_id', 'month', 'year')] %>%
  group_by(cell_id, month) %>%
  dplyr::summarize(cell_count = n()) #%>%

# Cells with fewer than 25 slices, and where they are: all 211 of them lie south of 27 N
# (114) or north of 74 N (97), which is why script 8 trims to that band.
cell_id_missing = unique(cell_count_summary[which(cell_count_summary$cell_count < 25), 'cell_id'])
cell_id_missing$lat = alb_grid_full[match(cell_id_missing$cell_id, alb_grid_full$cell_id),'lat']

N_missing = nrow(cell_id_missing)
N_missing_south = length(which(cell_id_missing$lat<27))
N_missing_north = length(which(cell_id_missing$lat>74))
N_missing_south + N_missing_north

# The same count with the incomplete cells removed; `alb_grid_full_new` is not used after.
alb_grid_full_new = alb_grid_full[which(!(alb_grid_full$cell_id %in% cell_id_missing$cell_id)),] 
cell_count_summary_new = alb_grid_full_new[,c('cell_id', 'month', 'year')] %>%
  group_by(cell_id, month) %>%
  dplyr::summarize(cell_count = n()) #%>%

cell_id_missing_new = unique(cell_count_summary_new[which(cell_count_summary_new$cell_count < 25), 'cell_id'])

# Binned albedo, sd and coefficient of variation, with labels; for maps that are
# commented out.
alb_grid_full$alb_bin = cut(alb_grid_full$alb_mean, breaks_alb, labels=FALSE)

breaks_sd = c(0, 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07)
labels_sd = c("0 - 0.01", "0.01 - 0.02", "0.02 - 0.03", "0.03 - 0.04", "0.04 - 0.05", "0.05 - 0.06", "0.06 - 0.07")
alb_grid_full$alb_sd_bin = cut(alb_grid_full$alb_sd, breaks_sd, labels=FALSE, include.lowest=TRUE)
alb_grid_full$alb_sd_bin = factor(alb_grid_full$alb_sd_bin, 
                                  levels=seq(1, length(labels_sd)),
                                  labels = labels_sd)

alb_grid_full$alb_cv = alb_grid_full$alb_sd / alb_grid_full$alb_mean
breaks_cv = c(0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 10)
labels_cv = c("0 - 0.05", "0.05 - 0.1", "0.1 - 0.15", "0.15 - 0.2", "0.2 - 0.25", "0.25 - 0.3", "0.3 - 10")
alb_grid_full$alb_cv_bin = cut(alb_grid_full$alb_cv, breaks_cv, labels=FALSE, include.lowest=TRUE)
alb_grid_full$alb_cv_bin = factor(alb_grid_full$alb_cv_bin, 
                                  levels=seq(1, length(labels_cv)),
                                  labels = labels_cv)

# Coarse age labels; unused here.
labels_year = c('0.05 ka', '0.5 ka', '2 ka', '4 ka', '6 ka', '8 ka', '10 ka', '12 ka')

# Facet label per row (its slice age in ka), as an ordered factor; month likewise.
alb_grid_full$facets = labels_ages_full[match(alb_grid_full$year/1000, labels_ages_full$age), 'facets']
alb_grid_full$facets = factor(alb_grid_full$facets, levels = labels_ages_full$facets)
alb_grid_full$month = factor(alb_grid_full$month, levels = months)

############################################################################################
# The differences: one cell and month at a time
############################################################################################

# A one-column table of all 25 ages, used to pad each cell's series to full length.
years_df = data.frame(year = ages)

# The identifying columns carried into the output, and the empty output table with the
# ten difference columns and the two ice fractions added.
alb_diff_colnames = c('cell_id', 'lat', 'long', 'x', 'y', 'year', 'month', 'area', 'area_km2')

alb_diff_df = data.frame(matrix(NA, nrow=0, ncol=length(alb_diff_colnames)+12))

colnames(alb_diff_df) = c(alb_diff_colnames, 
                          'ice_frac_young', 
                          'ice_frac_old', 
                          'alb_diff_veg_thresh',
                          'alb_diff_ice_thresh',
                          'alb_diff_veg_ice_thresh',
                          'alb_diff_icesc_thresh',
                          'alb_diff_veg_icesc_thresh',
                          'alb_diff_veg_part',
                          'alb_diff_ice_part',
                          'alb_diff_veg_ice_parts',
                          'alb_diff_icesc_part',
                          'alb_diff_veg_icesc_parts')

# The cells to loop over (about 2,866) and three counters for the situations noted below.
cell_ids = unique(alb_grid_full$cell_id)
N_cells  = length(cell_ids)

tally_both = 0
tally_increase = 0
tally_increase_mult = 0

for (i in 1:N_cells){
  
  print(paste0('Cell ', i, ' of ', N_cells))
  
  for (month in months){
    
    # This cell's rows for this month, sorted young to old.
    alb_cell = alb_grid_full[which((alb_grid_full$cell_id == cell_ids[i])&(alb_grid_full$month == month)),] 
    alb_cell = alb_cell[order(alb_cell$year),]
    
    # A cell with a single slice has no pairs; skip it.
    if (nrow(alb_cell) == 1){
      next
    } 
    
    # Pad to all 25 ages so that a missing slice becomes a row of NAs rather than the
    # series silently skipping it (which would pair non-consecutive slices).
    alb_cell_filled = merge(years_df, alb_cell, all.x=TRUE)
    
    # ---- Ice that grows through time -------------------------------------------------------
    # diff() runs young to old, so a negative step means the ice fraction is LARGER in the
    # younger slice: ice advancing forward in time. That is not expected in this period
    # and is treated as noise in the ice product: the YOUNGER slice's value is replaced by
    # the mean of the values either side of it (in a copy, ice_frac_adj). The fix is
    # applied once, not iterated: 2,844 pairs in the anchored run still show ice growing
    # afterwards and are merely counted below. If the first pair were the offender the
    # code would error (index 0); it did not occur here. Cases with more than one such
    # step are counted. Question C2.
    idx_ice_increase = which(diff(alb_cell_filled$ice_frac)<0)
    if(length(idx_ice_increase)>1){
      tally_increase_mult = tally_increase_mult + 1
      print('Ice increase over multiple time periods')
    }
    
    alb_cell_filled$ice_frac_adj = alb_cell_filled$ice_frac
    alb_cell_filled$ice_frac_adj[idx_ice_increase] = (alb_cell_filled$ice_frac_adj[idx_ice_increase + 1] +  alb_cell_filled$ice_frac_adj[idx_ice_increase - 1])/2
    
    # Ice fraction at the young and old end of each of the 24 pairs.
    ice_frac_young = alb_cell_filled$ice_frac_adj[1:(nrow(alb_cell_filled)-1)]
    ice_frac_old = alb_cell_filled$ice_frac_adj[2:nrow(alb_cell_filled)]
    
    # Threshold flags per pair: ice at the young end, at the old end, at both.
    is_ice_young =  ice_frac_young > 0.5
    is_ice_old =  ice_frac_old > 0.5
    is_ice_both = is_ice_young & is_ice_old
    
    # Pairs where (after adjustment) ice still grows forward in time.
    is_ice_increase = ice_frac_old < ice_frac_young
    
    # Pairs with a missing ice fraction at either end.
    is_ice_missing = is.na(ice_frac_young) | is.na(ice_frac_old)
    
    # Count and report pairs that are ice at both ends (no change, forcing zero) and pairs
    # with growing ice.
    if (sum(is_ice_both[!is_ice_missing], na.rm=TRUE)>0){
      
      tally_both = tally_both + sum(is_ice_both[!is_ice_missing], na.rm=TRUE)
      print(paste0('Still ice, forcing 0: ', sum(is_ice_both[!is_ice_missing], na.rm=TRUE)))
    }
    
    if (any(is_ice_increase[!is_ice_missing])) {
      tally_increase = tally_increase + sum(is_ice_increase[!is_ice_missing], na.rm=TRUE)
      print(paste0('Increasing ice fraction: ', sum(is_ice_increase[!is_ice_missing], na.rm=TRUE)))
      
    }
    
    # ---- Area-weighted differences ("part") ------------------------------------------------
    # Vegetation part: the change in vegetation albedo (young minus old) applied to the
    # fraction that was NOT ice at the old end.
    alb_diff_veg_part = -diff(alb_cell_filled$alb_veg) * (1-ice_frac_old)
    
    # Ice part: where ice retreated (old fraction minus young fraction > 0), that strip of
    # the cell went from ice albedo (old) to vegetation albedo (young); the change is the
    # difference between those two albedos times the fraction that changed.
    alb_diff_ice_part = (alb_cell_filled$alb_veg[1:(nrow(alb_cell_filled)-1)] - alb_cell_filled$ice_albedo_fixed[2:nrow(alb_cell_filled)]) * (ice_frac_old-ice_frac_young)
    alb_diff_icesc_part = (alb_cell_filled$alb_veg[1:(nrow(alb_cell_filled)-1)] - alb_cell_filled$ice_albedo_sc[2:nrow(alb_cell_filled)]) * (ice_frac_old-ice_frac_young)
    
    # Totals: vegetation plus ice part (computed twice, identically, in the original).
    alb_diff_veg_ice_parts = rowSums(cbind(alb_diff_veg_part, alb_diff_ice_part))
    alb_diff_veg_icesc_parts =  rowSums(cbind(alb_diff_veg_part, alb_diff_icesc_part))
    
    alb_diff_veg_ice_parts = rowSums(cbind(alb_diff_veg_part, alb_diff_ice_part))
    alb_diff_veg_icesc_parts =  rowSums(cbind(alb_diff_veg_part, alb_diff_icesc_part))
    
    # ---- Threshold differences ("thresh") -------------------------------------------------
    # Vegetation: the change in vegetation albedo, blanked for any pair that is ice at
    # either end (no vegetation to compare).
    alb_diff_veg_thresh = -diff(alb_cell_filled$alb_veg) 
    alb_diff_veg_thresh[is_ice_old | is_ice_young] = NA
    
    # Ice: young vegetation albedo minus the old ICE albedo. alb_ice_thresh is NA in
    # vegetation cells, so this is NA unless the old end was ice: it captures ice -> veg.
    alb_diff_ice_thresh = alb_cell_filled$alb_veg[1:(nrow(alb_cell_filled)-1)] - 
      alb_cell_filled$alb_ice_thresh[2:nrow(alb_cell_filled)]
    
    alb_diff_icesc_thresh =  alb_cell_filled$alb_veg[1:(nrow(alb_cell_filled)-1)] - 
      alb_cell_filled$alb_icesc_thresh[2:nrow(alb_cell_filled)]
    
    # Ice at both ends: no change, so zero. Missing ice fraction: unknown, so NA.
    alb_diff_ice_thresh[is_ice_both] = 0
    alb_diff_icesc_thresh[is_ice_both] = 0
    alb_diff_ice_thresh[is_ice_missing] = NA
    alb_diff_icesc_thresh[is_ice_missing] = NA
    
    # Totals: whichever of the vegetation or ice difference is present for each pair,
    # then NA where ice was missing. The two are exclusive in the three expected cases
    # (veg->veg, ice->veg, ice->ice) but NOT when ice ADVANCES across the threshold
    # (young end ice, old end vegetation): there both are NA and rowSums(na.rm = TRUE)
    # yields 0, a silent "no change". 36 pairs in the anchored run (question C2).
    alb_diff_veg_ice_thresh = rowSums(cbind(alb_diff_veg_thresh, alb_diff_ice_thresh), na.rm=TRUE)
    alb_diff_veg_icesc_thresh =  rowSums(cbind(alb_diff_veg_thresh, alb_diff_icesc_thresh), na.rm=TRUE)
    
    alb_diff_veg_ice_thresh[is_ice_missing] = NA
    alb_diff_veg_icesc_thresh[is_ice_missing] = NA
    
    # ---- Append this cell-month's 24 pairs to the output ------------------------------
    # The identifying columns come from the YOUNG row of each pair (rows 1..24 of the
    # padded series). rbind() onto a growing table is what makes this loop slow.
    alb_diff_df = rbind(alb_diff_df, 
                        data.frame(subset(alb_cell_filled[1:(nrow(alb_cell_filled)-1), ], 
                                          select=alb_diff_colnames), 
                                   ice_frac_young = ice_frac_young,
                                   ice_frac_old = ice_frac_old,
                                   alb_diff_veg_thresh = alb_diff_veg_thresh,
                                   alb_diff_ice_thresh = alb_diff_ice_thresh,
                                   alb_diff_veg_ice_thresh = alb_diff_veg_ice_thresh,
                                   alb_diff_icesc_thresh = alb_diff_icesc_thresh,
                                   alb_diff_veg_icesc_thresh = alb_diff_veg_icesc_thresh,
                                   alb_diff_veg_part = alb_diff_veg_part,
                                   alb_diff_ice_part = alb_diff_ice_part,
                                   alb_diff_veg_ice_parts = alb_diff_veg_ice_parts,
                                   alb_diff_icesc_part = alb_diff_icesc_part,
                                   alb_diff_veg_icesc_parts = alb_diff_veg_icesc_parts))
    
  }
}

# Padded rows whose slice was missing have NA identifiers; drop them.
alb_diff_df =  alb_diff_df[which(!is.na(alb_diff_df$lat)),]

# Save. This is the input to script 8, and the anchored output of this script.
saveRDS(alb_diff_df, paste0('data/ALB_diffs_', alb_prod, '.RDS'))

############################################################################################
# Two exploratory plots of pairs where ice grew (to Rplots.pdf; not saved)
############################################################################################

foo2 = alb_diff_df[which(alb_diff_df$ice_frac_young > alb_diff_df$ice_frac_old),]

ggplot(data=foo2) +
  geom_point(aes(x=ice_frac_old, y=ice_frac_young, size=year, colour=y))

ggplot(data=foo2) +
  geom_point(aes(x=ice_frac_old-ice_frac_young, y=year))

# Close the provenance manifest.
run_end(outputs = Filter(file.exists, paste0('data/ALB_diffs_', alb_prod, '.RDS')))
