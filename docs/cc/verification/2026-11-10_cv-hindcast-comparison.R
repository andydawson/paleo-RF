# Protocol 2, section 7: the three finished hindcasts side by side (tools/compare_cv_hindcasts.R).
# No pipeline script runs and no model is fitted: the tool reads the three run folders and the
# cross-validation's outputs, and writes into this run's folder only. Run it after the reviews, with
# the commit filled in. It makes the comparison twice, the second time with two runs' roles reversed,
# and then checks the tables (the last check, below).
verify   = '/home/expert/Documents/contracting/Andria/paleo-RF-verify'
mod8     = file.path(verify, 'f05628d/.rundirs/cv-mod8')        # the baseline: model 8
chosen   = file.path(verify, '1d31cfc/.rundirs/cv2-winner')     # the chosen model, loc100_linear
coarse   = file.path(verify, 'e82f399/.rundirs/cv-chosen')      # the coarse-location model, mod8_coarse_loc
cv       = file.path(verify, '1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2')
out      = '.rundirs/cv-hindcast-comparison/comparison'
reversed = '.rundirs/cv-hindcast-comparison/comparison_reversed'

# What the tables must satisfy beyond the tool's own stops. The tool already stops unless the
# study-area forcing reproduces script 9's domain means (the total for each kernel and period, the
# HadGEM3 parts) and script 10's monthly means with its latitude bands combined; the northeast steps
# sum to the end-to-end change; every fit used its month's calibration rows; and the saved fitted
# northeast albedo at 6 and at 4.5 ka is that of the saved fit.
table_checks = sprintf("
read = function(dir, name) read.csv(file.path(dir, name), comment.char = '#')
header = function(dir, name) { lines = readLines(file.path(dir, name)); lines[startsWith(lines, '#')] }
out = '%s'; reversed = '%s'; capacity = read.csv('%s')
files = c('albedo_by_month_slice.csv', 'forcing_by_period.csv', 'northeast_by_month.csv', 'validation_and_tested_limits.csv',
          'geographic_support_by_month.csv', 'albedo_series.png', 'albedo_difference_maps.png', 'forcing_difference_maps.png',
          'northeast_cover_response_apr_may.png', 'record.txt')
stopifnot(all(file.exists(file.path(out, files))))
albedo = read(out, files[1]); forcing = read(out, files[2]); northeast = read(out, files[3]); validation = read(out, files[4])
geography = read(out, files[5])

# Every run on the same rows: 2 regions, 25 slices or 8 periods, 12 months and the year, 3 kernels, 3 runs.
stopifnot(nrow(albedo) == 2 * 25 * 13 * 3, nrow(forcing) == 2 * 8 * 13 * 3 * 3, nrow(northeast) == 12 * 3, nrow(geography) == 2 * 12,
          all(albedo$albedo_difference[albedo$run == 'mod8'] == 0), all(forcing$total_forcing_difference[forcing$run == 'mod8'] == 0))

# The vegetation part and the ice part add up to the total in every row, and so do their outside parts.
stopifnot(max(abs(forcing$vegetation_forcing + forcing$ice_forcing - forcing$total_forcing)) < 1e-9,
          max(abs(forcing$vegetation_outside_part + forcing$ice_outside_part - forcing$total_outside_part)) < 1e-9)

# Common denominators: on every row every run rests on the same cells (forcing: and the same area),
# and every run's swaps on the same northeast cells.
same_in_runs = function(table, by, column) all(tapply(table[[column]], do.call(paste, table[by]), function(v) length(unique(v)) == 1))
stopifnot(same_in_runs(albedo, c('region', 'age_bp', 'month'), 'cells'), same_in_runs(forcing, c('region', 'kernel', 'period', 'month'), 'cells'),
          same_in_runs(forcing, c('region', 'kernel', 'period', 'month'), 'area_m2'), length(unique(northeast$swap_cells)) == 1)

# The kernels' coverage, and the forcing header that states it: in the study area CACK has values in
# 2,646 cells in January and 2,439 in December, every other kernel and month in 2,655; the northeast 83 throughout.
monthly = forcing[forcing$month != 'annual', ]
cack = monthly$region == 'study area' & monthly$kernel == 'cack'
stopifnot(all(monthly$cells[cack & monthly$month == 'jan'] == 2646), all(monthly$cells[cack & monthly$month == 'dec'] == 2439),
          all(monthly$cells[monthly$region == 'study area' & !(cack & monthly$month %%in%% c('jan', 'dec'))] == 2655),
          all(monthly$cells[monthly$region == 'northeast'] == 83),
          '# study area: the cack kernel has values in 2646 cells in jan and 2439 cells in dec; every other kernel and month has 2655 cells.' %%in%% header(out, files[2]))

# The swaps' endpoint distances: each swap's largest distance outside is the larger of its two ends'.
for (swap in c('swap_50bp', 'swap_6ka'))
  stopifnot(all(northeast[[paste0(swap, '_max_outside_distance')]] ==
                pmax(northeast[[paste0(swap, '_high_evergreen_max_distance')]], northeast[[paste0(swap, '_low_evergreen_max_distance')]])))

# The tested directions in words, and the northeast's reach beside the limit in its direction: its past
# mixes outside the range leave it towards less open land (d2), as far as 0.107, tested near training to 0.099.
reach = grep('past mixes leave the range in direction', header(out, files[3]), value = TRUE)
stopifnot(!anyNA(validation$direction_in_words), unique(validation$direction_in_words[validation$own_direction == 'd2']) == 'less open land and more summergreen',
          length(reach) == 1, grepl('direction d2 (less open land and more summergreen), as far as 0.107 outside; near training the cross-validation tested that direction up to 0.099: the northeast reaches FURTHER OUTSIDE THAN WAS TESTED', reach, fixed = TRUE),
          reach %%in%% header(out, files[4]))

# April and May: the historical-size exchange and its standard error are the capacity table's, for all three models.
both = merge(northeast, capacity, by.x = c('month', 'run'), by.y = c('month', 'model'))
stopifnot(nrow(both) == 6, max(abs(both$historical_exchange - both$contrast)) < 1e-8, max(abs(both$historical_exchange_se - both$se)) < 1e-8)

# The fitted and the pipeline's simulated 6 to 4.5 ka changes are different quantities, each checked by
# the tool against its own saved product (the fitted ends against the saved fits, the simulated ends
# against script 8's three steps). No tolerance between them has a basis, so their gap is reported, not judged.
gap = northeast$change_6_to_4.5ka - northeast$change_6_to_4.5ka_simulated
cat('northeast 6 to 4.5 ka, fitted minus simulated change: largest gap', signif(max(abs(gap)), 3), 'albedo;',
    sum(sign(northeast$change_6_to_4.5ka) != sign(northeast$change_6_to_4.5ka_simulated)), 'of', nrow(northeast), 'month-runs differ in sign\\n')

# Geographic support: every northeast cell has a fitting cell at its place in every month; in the study
# area no past cell lies north of the fitting cells from March to September, and 1,340 and 1,013 of the
# 2,655 do in December and January (northernmost fitting cell at 53.5 and 58.5 N).
study = geography[geography$region == 'study area', ]; rownames(study) = study$month
stopifnot(all(geography$cells_without_fitting_cell[geography$region == 'northeast'] == 0), all(study$past_cells == 2655),
          all(study[c('mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep'), 'cells_north_of_fitting'] == 0),
          identical(study[c('dec', 'jan'), 'cells_north_of_fitting'], c(1340L, 1013L)),
          identical(study[c('dec', 'jan'), 'northernmost_fitting_latitude'], c(53.5, 58.5)))

# With the roles of model 8 and the chosen model reversed, every difference changes sign.
flip = function(name, by, columns) {
  a = read(out, name); b = read(reversed, name)
  a = a[a$run == 'loc100_linear', ]; b = b[b$run == 'mod8', ]
  b = b[match(do.call(paste, a[by]), do.call(paste, b[by])), ]
  stopifnot(nrow(a) > 0, !anyNA(b$run))
  for (column in columns) stopifnot(max(abs(a[[column]] + b[[column]])) < 1e-12)
}
flip(files[1], c('region', 'age_bp', 'month'), c('albedo_difference', 'albedo_outside_part_difference'))
flip(files[2], c('region', 'kernel', 'period', 'month'), paste0(c('vegetation', 'ice', 'total'), rep(c('_forcing_difference', '_outside_part_difference'), each = 3)))
flip(files[3], 'month', paste0(c('change_6_to_4.5ka', 'swap_50bp_open_land', 'swap_6ka_open_land', 'historical_exchange'), '_difference'))
cat('cv-hindcast-comparison: every table check passed\\n')
", out, reversed, file.path(cv, 'separation/capacity.csv'))

list(
  name    = 'cv-hindcast-comparison',
  commit  = 'TO_FILL',
  config  = 'config.R',
  scripts = character(),
  checks  = list('tests/test_hindcast_comparison.R',
                 'tests/test_training_support.R',
                 'tests/test_cross_validation.R',
                 'tests/test_cross_validation_stages.R',
                 'tests/test_cv_separation.R',
                 c('tools/compare_cv_hindcasts.R', out, cv, mod8, chosen, coarse),
                 c('tools/compare_cv_hindcasts.R', reversed, cv, chosen, mod8),
                 c('-e', table_checks)),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1'))
