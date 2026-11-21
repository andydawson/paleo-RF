# 1_veg_lct_prep.R: turn the land-cover posterior into two plain tables
# Interp (spatially complete) path only. Settings come from config.R, and every file is
# read and written through the run manifest; comments marked '# CM:' are notes on
# changes from the original analysis.
# The draws are reduced by reduce_land_cover() and the fractions checked by
# check_fractions() (R/preparation.R); the elevation is read from a prepared table; a
# diagnostic switch (config.R run$diagnostic) adds checks and plots at the end
# (R/land_cover_diagnostics.R).

# Settings, file locations and this run's manifest: run_begin() reads config.R (or the file
# given with --config), sets up the paths of R/paths.R and starts the run's
# manifest; files are then read and written through it.
source('R/run_manifest.R')
run   = run_begin('1_veg_lct_prep')
cfg   = run$cfg
paths = run$paths

# Packages, loaded after run_begin() so that a missing one is recorded as a failed run.
library(dplyr)
library(tidyr)

lct_interp = read_input(run, path_file(paths, 'veg_posts'))

#  not sure if should use median
# CM: the draws are summarised by reduce_land_cover() (R/preparation.R): the mean, as here
# before, or the median, chosen in config.R (analysis$land_cover$reduction,
# question A1).
source('R/preparation.R')
lct_interp_wide = reduce_land_cover(lct_interp, cfg$analysis$land_cover$reduction)

# The fractions must sum to one in every cell and slice: the calibration smooth of the
# three is fitted on that sheet only (question B1). Stops otherwise; the result
# is recorded in the run manifest.
run_record(run, 'land_cover_fractions', check_fractions(lct_interp_wide))

locations_interp = lct_interp_wide[,c('x', 'y')]

# Elevation of each cell (config.R analysis$elevation$method, question B9).
# "land_mean": the GMTED2010 mean over the cell's non-ocean area, a table prepared once by
# tools/prepare_land_elevation.R (committed).
# "centre_point" (the original): the elevation at each cell centre from the AWS terrain
# tiles, data/elev_interp_cells.RDS (committed; one row per cell: x, y, elev). If it is
# missing, tools/prepare_centre_elevation.R remakes it with the original query.
if (cfg$analysis$elevation$method == 'land_mean') {
  elev_lookup = read_input(run, path_file(paths, 'elevation_land_mean'), read.csv)
  run_record(run, 'elevation', list(method = 'land_mean',
                                    source = 'GMTED2010 30-arc-second mean over non-sea area (sea = GMTED 0 m)'))
} else {
  elev_file = path_file(paths, 'elevation_cache')
  if (!file.exists(elev_file)) stop(elev_file, ' is missing: run tools/prepare_centre_elevation.R once')
  elev_lookup = read_input(run, elev_file)
}
elev_interp = elev_lookup$elev[match(paste(locations_interp$x, locations_interp$y),
                                     paste(elev_lookup$x, elev_lookup$y))]
if (anyNA(elev_interp)) stop('cells without an elevation in the elevation table: ', sum(is.na(elev_interp)))

lct_interp_all = data.frame(lct_interp_wide[,c('ages', 'x', 'y')],
                     elev = elev_interp,
                     lct_interp_wide[,c('ET', 'OL', 'ST')])



lct_interp_modern = lct_interp_all[which(lct_interp_all$ages == 50), ]

lct_interp_modern = lct_interp_modern[, which(!(colnames(lct_interp_modern) %in% c('ages')))]

# One row per modern cell (x, y): elevation and the three land-cover fractions.
write_output(run, lct_interp_modern, path_file(paths, 'lct_modern'))

lct_interp_paleo = lct_interp_all

# One row per cell and slice (x, y, ages).
write_output(run, lct_interp_paleo, path_file(paths, 'lct_paleo'))

# Diagnostics of the input, when config.R's run$diagnostic is TRUE (off by default): checks
# and plots into figures/diagnostics/, by R/land_cover_diagnostics.R. They change no output.
if (cfg$run$diagnostic) {
  source('R/land_cover_diagnostics.R')
  land_cover_diagnostics(lct_interp, lct_interp_wide, lct_interp_all, cfg$analysis$domain,
                         cfg$presentation$map_windows$diagnostics, paths)
}

run_finish(run)
