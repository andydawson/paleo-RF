# compare_cv_hindcasts.R: finished pipeline runs side by side, to see what the choice of
# calibration model does to the hindcast.
#
# WHY (cross-validation protocol 2, section 7: docs/cc/2026-11-06_cv_protocol_v2.md; Chris, 5, 6 and
# 10 November 2026). The cross-validation chooses a calibration model on prediction error. This tool
# sets the finished runs side by side so that Chris and Andria can see what that choice does to the
# albedo, to the forcing by period and to the northeast over the hemlock decline, with the tested
# limits beside the numbers. A diagnostic, not a pipeline step, and beside the northeast figure tool
# (tools/plotting/plot_northeast_cover_and_location.R), which keeps its own figure. Run it by hand
# from the repository root, after the runs and the cross-validation have finished:
#   Rscript tools/compare_cv_hindcasts.R <output-dir> <cv-output-dir> <baseline-run-dir> <run-dir> [<run-dir> ...]
# The first run is the baseline; every table gives each run and its difference from the baseline.
# The runs must differ in the calibration model only (config_used.R, analysis$calibration$model_id);
# each is named by its model id.
#
# WHAT COMES IN, from each run directory, by the fixed names of R/paths.R (nothing is written there)
#   config_used.R                                                  the run's settings
#   data/calibration_modern_lct_interp_bluesky.RDS                 script 2: today's cover and albedo
#   output/calibration/calibration_prediction_fit_<month>_bluesky.RDS   script 4: the fit the hindcast uses
#   output/prediction/paleo_interp_predict_gam_bluesky.RDS         script 6: past cover and the fitted albedo
#   output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS script 6: the mean of the simulated
#       albedo, which scripts 7a to 10 carry forward ("the pipeline's albedo" below)
#   output/forcing/RF_holocene_all_cases.RDS                       script 8: forcing, area and ice per cell,
#       month and pair of slices
#   output/forcing/forcing_by_period.csv, forcing_by_period_variant_sensitivity.csv and
#       forcing_by_month_latitude.csv                             scripts 9 and 10, as a check
# and from the cross-validation's output directory: by_distance.csv and nearby_coverage.csv.
#
# WHAT GOES OUT, into <output-dir> (each table starts with comment lines, marked #, that say what it
# holds and state the signs; read it with read.csv(file, comment.char = '#'))
#   albedo_by_month_slice.csv        the pipeline's albedo: study area and northeast, each month and slice
#   forcing_by_period.csv            forcing: both regions, the periods of config.R and the hemlock
#                                    interval, each month and the year, three kernels; the vegetation
#                                    part, the ice part and the total side by side, never the total alone
#   northeast_by_month.csv           the northeast over the hemlock decline, all twelve months: the
#                                    6 to 4.5 ka change, the evergreen-summergreen swaps, the support
#   validation_and_tested_limits.csv the cross-validation's errors and tested limits, by cover distance
#   geographic_support_by_month.csv  how many past cells have no fitting cell at their place, by month
#   albedo_series.png, albedo_difference_maps.png, forcing_difference_maps.png,
#   northeast_cover_response_apr_may.png
#   record.txt                       the code version, the runs and the MD5 sum of every file read
#
# SIGNS, everywhere: a positive albedo change or difference is brighter; a positive forcing is warming.
# The same event therefore has opposite signs in the albedo and the forcing tables.
#
# THE ARITHMETIC
#   1. Regional means are area-weighted over the same cells for every run. The study area is the
#      cells of script 8's forcing table. Albedo by slice is weighted by area times the ice-free
#      fraction (the weight vegetation albedo has in the pipeline's partial-ice albedo). Forcing is
#      taken as saved: its ice treatment is already inside, and it is not weighted by ice again.
#   2. Forcing by period is script 9's: summed over a period's slice pairs, averaged over the months
#      with a value, area-weighted, from the three saved variants of script 8's table (script 9, notes
#      A1 and A2): the vegetation part and the ice part of the partial-ice split, and their total.
#      Scripts 9 and 10 save the study-area means only; the months, the northeast and the hemlock
#      interval need the same sums again, so the tool stops unless it reproduces every number those
#      scripts did save. The hemlock interval is the three steps ending at 5500, 5000 and 4500 BP.
#      The totals of the periods with ice can agree between runs while the vegetation parts differ,
#      which is why the three are always given together.
#   3. Support. A cover mix is outside the training range when it lies outside that month's own range
#      of today's mixes (R/training_support.R); a period is outside in a cell and month if any end of
#      any of its steps is. Each mean comes with the share of its weight that is outside, the part of
#      the mean itself that comes from outside (same denominator, so the inside part is the rest), and
#      the largest distance outside with its band. Beside that, per month: how many past cells have
#      no fitting cell at their own place or lie north of every fitting cell (in winter the
#      calibration has no albedo in the far north).
#   4. The northeast table uses the fitted albedo ("deterministic": predict(), no simulation), so that
#      a swap is the model's own response. The pipeline's simulated means are given beside the
#      6 to 4.5 ka change. The swaps are R/hindcast_comparison.R's modern_swaps(); the historical-size
#      exchange is the separation test's (protocol 2, section 6; R/cv_separation.R).

source('R/config.R')
source('R/paths.R')
source('R/run_manifest.R')          # code_version(), for the record
source('R/forcing_periods.R')
source('R/map_helpers.R')
source('R/hindcast_comparison.R')

library(dplyr)
library(ggplot2)
library(mgcv)                       # predict() for the saved fits

HEMLOCK_INTERVAL = c(4500, 6000)    # the steps ending at 5500, 5000 and 4500 BP (protocol 2, section 7)
COMPONENTS = c(vegetation = 'veg_part', ice = 'ice_part', total = 'veg_ice_parts')   # script 8's saved variants: the two parts add up to the total
MAP_SLICES = c(50, 4500, 6000)      # with the oldest slice of the runs, added below
FIGURE_MONTHS = c(apr = 'April', may = 'May')   # the months of the northeast cover-response figure
CURVE_STEPS = 25                    # points along each of its lines

args = commandArgs(trailingOnly = TRUE)
if (length(args) < 4) {
  cat('usage: Rscript tools/compare_cv_hindcasts.R <output-dir> <cv-output-dir> <baseline-run-dir> <run-dir> [<run-dir> ...]\n')
  quit(status = 2)
}
out_dir = args[1]
cv_dir = args[2]
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# --- the runs and what they share -----------------------------------------------------------------

# Every file read is noted, for the record of inputs.
FILES_READ = character()
read_noted = function(file, reader = readRDS) {
  if (!file.exists(file)) stop('missing input: ', file, call. = FALSE)
  FILES_READ <<- union(FILES_READ, file)
  reader(file)
}
read_product = function(run, id, month = NULL, reader = readRDS) read_noted(path_file(run$paths, id, month = month), reader)
open_run = function(dir) {
  cfg = read_noted(file.path(dir, 'config_used.R'), load_config)
  list(dir = dir, cfg = cfg, paths = c(redirected_paths(dir), list(tag = ALBEDO_TAG)))
}
runs = lapply(args[-(1:2)], open_run)
names(runs) = sapply(runs, function(run) run$cfg$analysis$calibration$model_id)
baseline = names(runs)[1]
others = names(runs)[-1]
if (anyDuplicated(names(runs))) stop('two runs use the same calibration model: ', paste(names(runs), collapse = ', '), call. = FALSE)

# The runs may differ in the calibration model only: the comparison is then of the models.
shared_settings = function(run) { analysis = run$cfg$analysis; analysis$calibration$model_id = NULL; analysis }
for (name in others) if (!identical(shared_settings(runs[[name]]), shared_settings(runs[[baseline]])))
  stop('run ', name, ' differs from the baseline in more than the calibration model (config_used.R, analysis)', call. = FALSE)
cfg = runs[[baseline]]$cfg
if (!identical(cfg$analysis$months, MONTHS)) stop('the comparison needs all twelve months, as protocol 2 does', call. = FALSE)
if (cfg$analysis$forcing$variant != COMPONENTS[['total']])
  stop('the comparison reports the partial-ice total and its two parts; config.R analysis$forcing$variant is ',
       cfg$analysis$forcing$variant, call. = FALSE)
slices = cfg$analysis$ages
kernels = cfg$analysis$forcing$report_kernels
same = function(a, b) isTRUE(all.equal(a, b, tolerance = 0, check.attributes = FALSE))

# Today's cover and albedo: one calibration table for every run, so each month has one training range.
cal = read_product(runs[[baseline]], 'calibration_table')
for (name in others) if (!same(read_product(runs[[name]], 'calibration_table'), cal))
  stop('run ', name, ' was calibrated on other data than the baseline', call. = FALSE)
hulls = lapply(setNames(MONTHS, MONTHS), function(month) training_hull(cal[complete_rows(cal, month), ]))

# Past cover and albedo, one row per cell, slice and month, in the baseline's order. Every run must
# predict for the same cells, slices and cover; rows are matched by cell, slice and month, never by
# position. `deterministic` is the fitted albedo, `simulated` the pipeline's albedo: one column per run.
row_key = function(rows) paste(rows$x, rows$y, rows$year, rows$month)
albedo = read_product(runs[[baseline]], 'prediction_point')[, c('year', 'x', 'y', 'elev', 'OL', 'ET', 'ST', 'month')]
deterministic = simulated = matrix(NA_real_, nrow(albedo), length(runs), dimnames = list(NULL, names(runs)))
for (name in names(runs)) {
  point = read_product(runs[[name]], 'prediction_point')
  summary = read_product(runs[[name]], 'prediction_summary')
  at_point = match(row_key(albedo), row_key(point))
  at_summary = match(row_key(albedo), row_key(summary))
  if (anyNA(at_point) || anyNA(at_summary) || nrow(point) != nrow(albedo) || nrow(summary) != nrow(albedo) ||
      !same(point[at_point, c('elev', 'OL', 'ET', 'ST')], albedo[, c('elev', 'OL', 'ET', 'ST')]))
    stop('run ', name, ' does not predict for the same cells, slices and cover as the baseline', call. = FALSE)
  deterministic[, name] = point$alb_mean[at_point]
  simulated[, name] = summary$alb_mean[at_summary]
}
rm(point, summary)

# The support of every cell, slice and month: is its cover mix outside that month's training range,
# and how far (R/training_support.R).
albedo$outside = NA
albedo$distance = NA_real_
for (month in MONTHS) {
  rows = albedo$month == month
  support = training_support(albedo[rows, ], hulls[[month]])
  albedo$outside[rows] = support$outside
  albedo$distance[rows] = support$distance_outside
}

# Forcing, area and ice: script 8's table, the columns used here. Cells, pairs, areas and ice
# fractions must be the same in every run, in the same order; the two parts must add up to the total.
forcing_columns = as.vector(outer(kernels, COMPONENTS, function(kernel, component) paste0('rf_', kernel, '_', component)))
pair_columns = c('cell_id', 'x', 'y', 'year', 'month', 'area', 'ice_frac_young', 'ice_frac_old')
forcing = lapply(runs, function(run) {
  table = read_product(run, 'forcing')[, c(pair_columns, 'alb_diff_veg_ice_parts', forcing_columns)]
  table$area = as.numeric(table$area)   # script 7a stores the area with its unit (m2)
  table
})
for (name in names(runs)) {
  if (!identical(forcing[[name]][, pair_columns], forcing[[baseline]][, pair_columns]))
    stop('run ', name, ' does not hold the same cells, pairs, areas and ice fractions as the baseline', call. = FALSE)
  for (kernel in kernels) {
    column = function(component) forcing[[name]][[paste0('rf_', kernel, '_', COMPONENTS[[component]])]]
    if (any(abs(column('vegetation') + column('ice') - column('total')) > 1e-9, na.rm = TRUE))
      stop('run ', name, ', ', kernel, ': the vegetation and ice parts do not add up to the total', call. = FALSE)
  }
}

# Each cell-slice's area and ice-free fraction, and so the study area: the cells of script 8's table.
slice_weights = slice_area_ice(forcing[[baseline]], slices)
at = match(paste(albedo$x, albedo$y, albedo$year), paste(slice_weights$x, slice_weights$y, slice_weights$ages))
albedo$area = slice_weights$area[at]
albedo$ice = slice_weights$ice[at]
albedo$weight = albedo$area * (1 - albedo$ice)
albedo$cell = paste(albedo$x, albedo$y)
albedo$northeast = separation_northeast(albedo)
in_study_area = !is.na(at) & is.finite(albedo$weight)
REGIONS = c('study area', 'northeast')
in_region = function(region, northeast) if (region == 'northeast') northeast else rep(TRUE, length(northeast))

# The hindcast's geographic support by month, beside the cover-range flag: the past cells with no
# fitting cell at their own place, and those north of every fitting cell (R/hindcast_comparison.R).
past_cells = unique(albedo[in_study_area, c('x', 'y', 'area', 'northeast')])
geography = NULL
for (region in REGIONS) for (month in MONTHS)
  geography = rbind(geography, data.frame(region = region, month = month,
    geographic_support(past_cells[in_region(region, past_cells$northeast), ], cal[complete_rows(cal, month), c('x', 'y')])))

# --- table 1: the pipeline's albedo by month and slice ----------------------------------------------

albedo_table = NULL
for (name in names(runs)) for (region in REGIONS) {
  rows = which(in_study_area & in_region(region, albedo$northeast))
  values = data.frame(albedo[rows, c('year', 'month', 'cell', 'weight', 'outside', 'distance')],
                      value = simulated[rows, name], annual_weight = albedo$weight[rows])
  albedo_table = rbind(albedo_table, data.frame(region = region, run = name, monthly_and_annual_means(values, 'year')))
}
albedo_table = albedo_table %>%
  transmute(region, run, age_bp = year, month, cells, albedo = mean, outside_share, albedo_outside_part = outside_part,
            max_outside_distance, outside_band = outside_band(max_outside_distance)) %>%
  add_differences(c('region', 'age_bp', 'month'), c('albedo', 'albedo_outside_part'), baseline) %>%
  arrange(region, age_bp, match(month, c(MONTHS, 'annual')), match(run, names(runs)))

# --- table 2: forcing by period ------------------------------------------------------------------------

# The slice pairs of each period, and of the hemlock interval, on the baseline's rows (R/forcing_periods.R);
# `row` carries every run's values along, the tables being in the same order.
pair_rows = cbind(forcing[[baseline]][, pair_columns], row = seq_len(nrow(forcing[[baseline]])))
pairs = rbind(assign_forcing_periods(pair_rows, cfg$analysis$coarse$ages, slices),
              assign_forcing_periods(pair_rows, HEMLOCK_INTERVAL, slices))
pairs$period = as.character(pairs$period)
coarse_periods = period_labels(cfg$analysis$coarse$ages)
hemlock_period = period_labels(HEMLOCK_INTERVAL)

# The support of both ends of every pair, then of every cell and month of a period.
end_support = function(age) {
  at = match(paste(pairs$x, pairs$y, age, pairs$month), row_key(albedo))
  if (anyNA(at)) stop(sum(is.na(at)), ' forcing rows have no cover row at one end of their slice pair', call. = FALSE)
  albedo[at, c('outside', 'distance')]
}
pairs[, c('outside_young', 'distance_young')] = end_support(pairs$year)
pairs[, c('outside_old', 'distance_old')] = end_support(pairs$age_old)
support = period_support(pairs)
northeast_cells = unique(pairs$cell_id[separation_northeast(pairs)])

forcing_table = NULL
cell_forcing = list()   # per cell and period, the headline total over the year: for the difference maps
for (name in names(runs)) for (kernel in kernels) for (component in names(COMPONENTS)) {
  pairs$rf = forcing[[name]][pairs$row, paste0('rf_', kernel, '_', COMPONENTS[[component]])]
  cell_months = period_cell_months(pairs, 'rf') %>% left_join(support, by = c('period', 'cell_id', 'month')) %>%
    mutate(cell = cell_id, weight = area, annual_weight = area / months_with_value)
  for (region in REGIONS) {
    rows = cell_months[in_region(region, cell_months$cell_id %in% northeast_cells), ]
    forcing_table = rbind(forcing_table, data.frame(region = region, run = name, kernel = kernel, component = component,
                                                    monthly_and_annual_means(rows, 'period')))
  }
  if (kernel == kernels[1] && component == 'total')
    cell_forcing[[name]] = cell_months %>% group_by(period, cell_id) %>% summarise(rf = mean(value, na.rm = TRUE), .groups = 'drop')
}
# The vegetation part, the ice part and the total side by side in one row: the total is never read alone.
by_component = forcing_table
forcing_table = by_component %>%
  transmute(region, run, kernel, period, month, cells, area_m2 = total_weight, outside_share, max_outside_distance,
            component, forcing = mean, outside_part) %>%
  tidyr::pivot_wider(names_from = component, values_from = c(forcing, outside_part), names_glue = '{component}_{.value}') %>%
  as.data.frame()
if (nrow(forcing_table) * length(COMPONENTS) != nrow(by_component))
  stop('the vegetation part, the ice part and the total do not rest on the same cells', call. = FALSE)
forcing_table = forcing_table %>% mutate(outside_band = outside_band(max_outside_distance)) %>%
  add_differences(c('region', 'kernel', 'period', 'month'), paste0(names(COMPONENTS), rep(c('_forcing', '_outside_part'), each = length(COMPONENTS))), baseline) %>%
  arrange(region, match(period, c(coarse_periods, hemlock_period)), kernel, match(month, c(MONTHS, 'annual')), match(run, names(runs)))

# Check: the study-area means are the numbers scripts 9 and 10 saved, for every run: script 9's
# domain mean of the total for each kernel and period, its HadGEM3 means of the vegetation part, the
# ice part and the total (the variant table, note A2), and script 10's monthly means of the total.
for (name in names(runs)) {
  mine = forcing_table[forcing_table$region == 'study area' & forcing_table$run == name & forcing_table$period %in% coarse_periods, ]
  annual = mine[mine$month == 'annual', ]
  monthly = mine[mine$month != 'annual', ]
  script9 = read_product(runs[[name]], 'forcing_by_period', reader = read.csv)
  gap_total = annual$total_forcing - script9$domain_mean[match(paste(annual$period, annual$kernel), paste(script9$period, script9$kernel))]
  variants = read_product(runs[[name]], 'forcing_variant_sensitivity', reader = read.csv)
  hadgem = annual[annual$kernel == 'hadgem', ]
  gap_parts = unlist(lapply(names(COMPONENTS), function(component)
    hadgem[[paste0(component, '_forcing')]] - variants$domain_mean[match(paste(hadgem$period, COMPONENTS[[component]]), paste(variants$period, variants$variant))]))
  script10 = read_product(runs[[name]], 'forcing_breakdown', reader = read.csv) %>% group_by(kernel, period, month) %>%
    summarise(band_mean = sum(band_mean * valid_area_m2, na.rm = TRUE) / sum(valid_area_m2), .groups = 'drop')
  gap_months = monthly$total_forcing - script10$band_mean[match(paste(monthly$period, monthly$kernel, monthly$month),
                                                                 paste(script10$period, script10$kernel, script10$month))]
  gaps = c(gap_total, gap_parts, gap_months)
  if (anyNA(gaps) || max(abs(gaps)) > 1e-9) stop('run ', name, ': the study-area forcing does not reproduce scripts 9 and 10', call. = FALSE)
  cat(sprintf('%s: study-area forcing reproduces script 9 (totals %.1e, HadGEM3 parts %.1e) and script 10 (months %.1e): largest gaps, W/m2\n',
              name, max(abs(gap_total)), max(abs(gap_parts)), max(abs(gap_months))))
}

# Check: in the northeast the three steps of the hemlock interval sum to the change between its ends,
# on the same cells, in the pipeline's albedo. The steps telescope only without ice, so cell-months
# with ice in the interval are left out and counted.
hemlock = pairs[pairs$period == hemlock_period & pairs$cell_id %in% northeast_cells, ]
iced = unique(paste(hemlock$cell_id, hemlock$month)[hemlock$ice_frac_young != 0 | hemlock$ice_frac_old != 0])
hemlock = hemlock[!paste(hemlock$cell_id, hemlock$month) %in% iced, ]
end_rows = function(age) match(paste(hemlock$x, hemlock$y, age, hemlock$month), row_key(albedo))[hemlock$year == HEMLOCK_INTERVAL[1]]
for (name in names(runs)) {
  steps = data.frame(cell = hemlock$cell_id, month = hemlock$month, change = forcing[[name]]$alb_diff_veg_ice_parts[hemlock$row])
  ends = data.frame(cell = hemlock$cell_id, month = hemlock$month)[hemlock$year == HEMLOCK_INTERVAL[1], ]
  ends$young = simulated[end_rows(HEMLOCK_INTERVAL[1]), name]
  ends$old = simulated[end_rows(HEMLOCK_INTERVAL[2]), name]
  gap = step_sum_gap(steps, ends)
  if (gap > 1e-9) stop('run ', name, ': the northeast steps of ', hemlock_period, ' do not sum to the change between its ends', call. = FALSE)
  cat(sprintf('%s: northeast %s, the three steps sum to the end-to-end change on %d cell-months (largest gap %.1e; %d with ice left out)\n',
              name, hemlock_period, nrow(ends), gap, length(iced)))
}

# --- table 3: the northeast over the hemlock decline, every month ------------------------------------

# One swap's columns: its contrast and standard error, and how far its ends reach outside the range.
swap_columns = function(prefix, contrast, reach) setNames(
  data.frame(contrast[['contrast']], contrast[['se']], reach[['outside_share']], reach[['max_outside_distance']],
             outside_band(reach[['max_outside_distance']])),
  paste0(prefix, c('_open_land', '_open_land_se', '_outside_share', '_max_outside_distance', '_outside_band')))

northeast_table = curves = curve_points = curve_ends = NULL
for (month in MONTHS) {
  training = cal[complete_rows(cal, month), ]
  training = training[separation_northeast(training), ]
  low = min(training$ET)                  # today's evergreen range in the region,
  high = max(training$ET)
  observed = range(training[[month]])     # and today's albedo range there
  hull = hulls[[month]]

  # The region's cells at each slice, in one order, with their area weights.
  region_rows = which(albedo$month == month & albedo$northeast)
  rows_at = function(age) { rows = region_rows[albedo$year[region_rows] == age]; rows[order(albedo$cell[rows])] }
  r50 = rows_at(50); r6 = rows_at(6000); r5.5 = rows_at(5500); r5 = rows_at(5000); r4.5 = rows_at(4500)
  if (!all(sapply(list(r6, r5.5, r5, r4.5), function(rows) identical(albedo$cell[rows], albedo$cell[r50]))))
    stop('the northeast does not hold the same cells at 50, 4500, 5000, 5500 and 6000 BP', call. = FALSE)
  cells_at = function(rows) albedo[rows, c('x', 'y', 'elev', 'OL', 'ET', 'ST')]
  area = albedo$area[r6]
  weight = area / sum(area)
  swaps = modern_swaps(cells_at(r50), cells_at(r6), low, high, area)
  historical = historical_exchange(cells_at(r6)[, c('x', 'y', 'elev')], transform(albedo[region_rows, ], ages = year), area)
  swap_reach = lapply(swaps, exchange_outside, hull = hull)
  outside_any = albedo$outside[r6] | albedo$outside[r5.5] | albedo$outside[r5] | albedo$outside[r4.5]
  distance_any = max(albedo$distance[c(r6, r5.5, r5, r4.5)])

  for (name in names(runs)) {
    fit = read_product(runs[[name]], 'calibration_prediction_fit', month = month)
    check_full_month_rows(fit, cal, month)   # fitted on exactly this month's calibration rows (R/cv_separation.R)
    fitted = deterministic[, name]
    # The saved fitted albedo is this fit's: script 6 predicted from the model script 5 passed on.
    if (max(abs(as.numeric(predict(fit, cells_at(r6), type = 'response')) - fitted[r6])) > 1e-8)
      stop('run ', name, ', ', month, ': the saved predictions are not those of the saved prediction fit', call. = FALSE)
    swap = lapply(swaps, function(exchange) exchange_contrast(fit, exchange))
    exchange = exchange_contrast(fit, historical)
    northeast_table = rbind(northeast_table, data.frame(
      month = month, run = name, cells = length(r6),
      evergreen_low = low, evergreen_high = high, observed_albedo_min = observed[1], observed_albedo_max = observed[2],
      albedo_6ka = sum(weight * fitted[r6]), albedo_4.5ka = sum(weight * fitted[r4.5]),
      position_4.5ka = range_position(sum(weight * fitted[r4.5]), observed[1], observed[2]),
      change_6_to_4.5ka = sum(weight * (fitted[r4.5] - fitted[r6])),
      change_6_to_4.5ka_simulated = sum(weight * (simulated[r4.5, name] - simulated[r6, name])),
      outside_share_6ka = sum(weight[albedo$outside[r6]]), outside_share_4.5ka = sum(weight[albedo$outside[r4.5]]),
      outside_share_any_slice = sum(weight[outside_any]), max_outside_distance = distance_any, outside_band = outside_band(distance_any),
      swap_columns('swap_50bp', swap[['50 BP']], swap_reach[['50 BP']]), swap_columns('swap_6ka', swap[['6 ka']], swap_reach[['6 ka']]),
      historical_exchange = exchange[['contrast']], historical_exchange_se = exchange[['se']],
      swap_cells = attr(swaps, 'exclusions')$retained, swap_cells_excluded = attr(swaps, 'exclusions')$excluded))

    # For the April and May figure: the line across today's evergreen range at each cell's 50 BP open
    # land (its two ends are the table's swap), and the points at the actual past mixes.
    if (month %in% names(FIGURE_MONTHS)) {
      modern = swaps[['50 BP']]
      for (evergreen in seq(low, high, length.out = CURVE_STEPS))
        curves = rbind(curves, data.frame(month = month, run = name, evergreen = evergreen,
          albedo = sum(modern$weight * predict(fit, cells_with_evergreen(modern$first, evergreen), type = 'response'))))
      curve_points = rbind(curve_points, data.frame(month = month, run = name, age = c('6 ka', '4.5 ka'),
        evergreen = c(sum(weight * albedo$ET[r6]), sum(weight * albedo$ET[r4.5])),
        albedo = c(sum(weight * fitted[r6]), sum(weight * fitted[r4.5]))))
    }
    rm(fit)
  }
  # The same for every run: today's albedo range, and how much of each end of the line is outside the range.
  if (month %in% names(FIGURE_MONTHS)) {
    ends = exchange_support(swaps[['50 BP']], hull)
    curve_ends = rbind(curve_ends, data.frame(month = month, observed_min = observed[1], observed_max = observed[2],
      outside_low = sum(ends$weight[ends$outside_second]), outside_high = sum(ends$weight[ends$outside_first])))
  }
}
northeast_table = add_differences(northeast_table, 'month', c('change_6_to_4.5ka', 'swap_50bp_open_land', 'swap_6ka_open_land', 'historical_exchange'), baseline)

# --- the cross-validation's errors and tested limits, to read beside the outside distances ----------

validation = validation_limits(read_noted(file.path(cv_dir, 'by_distance.csv'), read.csv),
                               read_noted(file.path(cv_dir, 'nearby_coverage.csv'), read.csv), names(runs))

# --- the tables, each with its header ---------------------------------------------------------------

ka = function(age) paste(age / 1000, 'ka')
write_table = function(table, name, header) {
  file = file.path(out_dir, name)
  writeLines(paste('#', header), file)
  suppressWarnings(write.table(table, file, append = TRUE, sep = ',', row.names = FALSE, qmethod = 'double'))
}
run_line = sprintf('Runs: %s. Baseline: %s; a column ending in _difference is the run minus the baseline.', paste(names(runs), collapse = ', '), baseline)
support_lines = c(
  'outside_share: the share of the weight on cover mixes outside that month\'s training range; a period is outside in a cell and month if any end of any of its steps is.',
  'The _outside_part of a mean is the part that comes from those cells, on the whole mean\'s denominator: the inside part is the rest.',
  'max_outside_distance and outside_band: the largest distance outside (cover-triangle units; 0.05 is about 5 percentage points of cover) and its band.',
  'Compare the bands with validation_and_tested_limits.csv: the cross-validation tested each direction only up to the distance given there.')
write_table(albedo_table, 'albedo_by_month_slice.csv', c(
  'The pipeline\'s albedo (the mean of the simulated albedo, which the forcing is made from), by region, slice (age_bp, years BP) and month.',
  'SIGNS: albedo is a fraction, 0 to 1; a positive albedo_difference means the run is BRIGHTER than the baseline.',
  run_line,
  'Regional means weigh each cell by its area times its ice-free fraction, over the same cells for every run; "annual" is the mean over the twelve months.',
  sprintf('The study area is the cells of the forcing table; the oldest slice is %s BP.', max(slices)), support_lines))
write_table(forcing_table, 'forcing_by_period.csv', c(
  'Forcing by region, period, month and kernel, in W/m2 averaged over the region (script 9\'s domain mean, not a global equivalent); the vegetation part, the ice part and the total side by side.',
  'SIGNS: a positive forcing is WARMING (the surface darkened from the older to the younger end); a positive ..._forcing_difference means more warming than the baseline.',
  run_line,
  'vegetation_forcing + ice_forcing = total_forcing: the vegetation part, the ice part and the total of the partial-ice split (script 8\'s saved variants veg_part, ice_part and veg_ice_parts; script 9, notes A1 and A2).',
  'READ THE THREE TOGETHER: where ice changed, the total can agree between runs while the vegetation part differs, even in sign. The forcing is as saved: its ice treatment is already inside.',
  sprintf('Periods are those of config.R, plus %s: the hemlock interval, the steps ending at 5500, 5000 and 4500 BP.', hemlock_period),
  sprintf('The period labelled "%s" runs to the oldest slice, %s, not to its label\'s older end (script 9, note A4).', tail(coarse_periods, 1), ka(max(slices))),
  'A period is the sum of its slice pairs; "annual" averages each cell over its months with a value, as script 9 does. The study-area means reproduce the numbers scripts 9 and 10 saved.',
  'area_m2: the area of the cells with a value.', '<part>_outside_part: the part of <part>_forcing that comes from cells outside the training range.', support_lines))
write_table(geography, 'geographic_support_by_month.csv', c(
  'The hindcast\'s geographic support by month, to read beside the cover-range flag of the other tables.',
  'The calibration has no albedo for a cell in a month with too little sun there, so each month is fitted on its own cells (fitting_cells; the northernmost at northernmost_fitting_latitude, degrees N).',
  'cells_without_fitting_cell: past cells of the region with no fitting cell at their own place that month; cells_north_of_fitting: those north of every fitting cell. There the location term is applied beyond its data.',
  'Area shares are of the region\'s past cells (past_cells: the study area is the cells of the forcing table).'))
write_table(northeast_table, 'northeast_by_month.csv', c(
  'The northeast (80 to 66 W, 40 to 48 N) over the hemlock decline, by month and run. Fitted albedo (no simulation) unless a column says simulated; area-weighted over the region\'s cells.',
  'SIGNS: every change, swap and exchange is positive when the surface gets BRIGHTER.',
  run_line,
  'change_6_to_4.5ka: the albedo at 4.5 ka minus that at 6 ka at the actual past cover; _simulated: the same from the pipeline\'s albedo.',
  'swap_50bp_open_land and swap_6ka_open_land: evergreen set to the lowest minus to the highest share found in the region today (evergreen_low, evergreen_high), summergreen taking its place, with each cell\'s open land held at its 50 BP or its 6 ka level. Positive: summergreen is the brighter cover.',
  'historical_exchange: the same kind of swap at its historical size: each cell\'s evergreen moved from its 6 ka to its 4.5 ka share with open land held at 6 ka (the separation test of protocol 2).',
  '_se: the standard error of a swap, from the fit\'s coefficient covariance (conditional on its smoothing).',
  'position_4.5ka: the predicted 4.5 ka albedo against the range observed in the region today (observed_albedo_min, observed_albedo_max): a warning, not a bound.',
  'outside_share_*: the share of the region\'s area whose actual past mix is outside the month\'s training range at 6 ka, at 4.5 ka, and at any of 6, 5.5, 5 and 4.5 ka; swap_*_outside_share: with either end of the swap outside.',
  'The matching northeast forcing is in forcing_by_period.csv (region northeast).', support_lines[3:4]))
write_table(validation, 'validation_and_tested_limits.csv', c(
  'The cross-validation\'s errors and tested limits, to read beside the outside distances of the other tables (protocol 2, section 7).',
  'For each direction in which past cover leaves today\'s range (own_direction) and band of distance outside (cover_band): each model\'s error on the withheld cells less than 250 km from training.',
  'rmse and signed_error (predicted minus observed albedo) are pooled over those predictions (cell_month_holdouts): diagnostic errors, not the selection score.',
  'cells, blocks and max_cover_distance_nearby: what the selection rested on there, and the largest distance tested (empty where the group has no weight in the selection). A direction and band not listed was not tested near training.'))

# --- figures --------------------------------------------------------------------------------------------

run_colours = setNames(c('grey25', '#d95f02', '#1b9e77', '#7570b3', '#e7298a')[seq_along(runs)], names(runs))

# The albedo of each slice, the mean over the months.
series = albedo_table[albedo_table$month == 'annual', ]
ggsave(file.path(out_dir, 'albedo_series.png'), width = 10, height = 4.5, dpi = 160,
  ggplot(series, aes(age_bp / 1000, albedo, colour = run)) + geom_line() + geom_point(size = 0.7) +
    facet_wrap(~ region, scales = 'free_y') + scale_colour_manual(values = run_colours, breaks = names(runs), name = 'calibration model') +
    labs(x = 'age (ka)', y = 'albedo, mean over the months',
         title = 'The pipeline\'s albedo through the Holocene, by calibration model',
         subtitle = sprintf('Area-weighted over ice-free land; the same cells for every model. Oldest slice %s. A higher albedo is a brighter surface.', ka(max(slices)))) +
    theme_bw(base_size = 9))

window = cfg$presentation$map_windows$diagnostics
land = prepare_boundaries(read_noted(path_file(runs[[baseline]]$paths, 'boundaries_ll')), window)
difference_map = function(cells, title, subtitle, unit) {
  limit = unname(quantile(abs(cells$difference), 0.98, na.rm = TRUE))   # a few extreme cells must not wash out the rest
  ggplot() + geom_tile(data = cells, aes(x, y, fill = pmax(pmin(difference, limit), -limit))) +
    boundary_layers(land, window, colour = 'grey60', linewidth = 0.1) + facet_grid(panel_row ~ panel_column) +
    scale_fill_gradient2(low = '#2166ac', mid = 'grey95', high = '#b2182b', name = unit) +
    labs(title = title, subtitle = sprintf('%s Colour clipped at the 98th percentile (%.2g).', subtitle, limit), x = NULL, y = NULL) +
    theme_bw(base_size = 9) + theme(strip.text = element_text(face = 'bold'))
}

# Albedo: each run minus the baseline, mean over the months, on the ice-free share of each cell.
map_rows = which(in_study_area & albedo$year %in% c(MAP_SLICES, max(slices)))
albedo_maps = do.call(rbind, lapply(others, function(name) data.frame(albedo[map_rows, c('x', 'y', 'year')], panel_row = name,
  difference = (simulated[map_rows, name] - simulated[map_rows, baseline]) * (1 - albedo$ice[map_rows])))) %>%
  group_by(panel_row, panel_column = factor(ka(year), levels = ka(sort(unique(year)))), x, y) %>%
  summarise(difference = mean(difference), .groups = 'drop')
ggsave(file.path(out_dir, 'albedo_difference_maps.png'), width = 13, height = 1.5 + 2.4 * length(others), dpi = 150,
  difference_map(albedo_maps, sprintf('Albedo: each calibration model minus %s', baseline),
                 'The pipeline\'s albedo on the ice-free share of each cell, mean over the months. Red: brighter than the baseline; blue: darker.', 'albedo'))

# Forcing: the headline total of the first kernel over each period of config.R, each run minus the baseline.
cell_xy = unique(pairs[, c('cell_id', 'x', 'y')])
forcing_maps = do.call(rbind, lapply(others, function(name) {
  run_cells = cell_forcing[[name]]
  base_cells = cell_forcing[[baseline]]
  at = match(paste(run_cells$period, run_cells$cell_id), paste(base_cells$period, base_cells$cell_id))
  data.frame(run_cells[, c('period', 'cell_id')], panel_column = name, difference = run_cells$rf - base_cells$rf[at])
}))
forcing_maps = forcing_maps[forcing_maps$period %in% coarse_periods, ]
forcing_maps$panel_row = factor(forcing_maps$period, levels = coarse_periods)
forcing_maps[, c('x', 'y')] = cell_xy[match(forcing_maps$cell_id, cell_xy$cell_id), c('x', 'y')]
ggsave(file.path(out_dir, 'forcing_difference_maps.png'), width = 3 + 3.7 * length(others), height = 16, dpi = 150,
  difference_map(forcing_maps, sprintf('Forcing (%s kernel, total): each calibration model minus %s', kernels[1], baseline),
                 sprintf('Sum over each period\'s steps, mean over the months; the last period ends at %s. Red: more warming than the baseline; blue: more cooling.', ka(max(slices))), 'W/m2'))

# The northeast in April and May: the model's albedo as summergreen and evergreen change places at
# each cell's 50 BP open land, with the actual past mixes as points.
curve_ends$panel = sprintf('%s: outside the training range, %.0f%% of the area at the low-evergreen end and %.0f%% at the high end',
                           FIGURE_MONTHS[curve_ends$month], 100 * curve_ends$outside_low, 100 * curve_ends$outside_high)
curves$panel = curve_ends$panel[match(curves$month, curve_ends$month)]
curve_points$panel = curve_ends$panel[match(curve_points$month, curve_ends$month)]
ggsave(file.path(out_dir, 'northeast_cover_response_apr_may.png'), width = 12, height = 5.5, dpi = 160,
  ggplot() +
    geom_rect(data = curve_ends, aes(xmin = -Inf, xmax = Inf, ymin = observed_min, ymax = observed_max), fill = 'grey90') +
    geom_line(data = curves, aes(evergreen, albedo, colour = run), linewidth = 0.8) +
    geom_point(data = curve_points, aes(evergreen, albedo, colour = run, shape = age), size = 2.4) +
    facet_wrap(~ panel) + scale_colour_manual(values = run_colours, breaks = names(runs), name = 'calibration model') +
    scale_shape_manual(values = c('6 ka' = 16, '4.5 ka' = 17), breaks = c('6 ka', '4.5 ka'), name = 'actual past cover\n(region mean)') +
    labs(x = 'evergreen share (each cell\'s open land as at 50 BP; summergreen the rest)', y = 'fitted albedo (region mean)',
         title = 'Northeast (80-66°W, 40-48°N): albedo as evergreen and summergreen change places',
         caption = paste('Points use the actual past cover mixes. Lines exchange evergreen and summergreen across today\'s evergreen range in the region,',
                         'holding each cell\'s modern open land, location and elevation fixed.\nGrey: the albedo range observed in the region today.',
                         'Where a line\'s cells are outside the training range it is an extrapolation (shares in the panel titles).')) +
    theme_bw(base_size = 9) + theme(plot.caption = element_text(hjust = 0)))

# --- the record ----------------------------------------------------------------------------------------

version = code_version('config.R')
packages = c('mgcv', 'sf', 'dplyr', 'ggplot2')
writeLines(c(paste('time:', format(Sys.time(), tz = 'UTC', usetz = TRUE)),
             paste('commit:', version$commit), paste('branch:', version$branch), paste('uncommitted changes:', version$dirty),
             paste('R', getRversion()), paste('package', packages, sapply(packages, function(p) as.character(utils::packageVersion(p)))),
             sprintf('run %s%s: %s', names(runs), ifelse(names(runs) == baseline, ' (baseline)', ''), sapply(runs, function(run) run$dir)),
             paste('cross-validation output:', cv_dir),
             sprintf('cell-slice-months: %d predicted, %d in the study area, %d of those under ice entirely (no weight)',
                     nrow(albedo), sum(in_study_area), sum(albedo$weight[in_study_area] == 0)),
             paste('input', FILES_READ, tools::md5sum(FILES_READ))),
           file.path(out_dir, 'record.txt'))

options(width = 200)
cat('\nNortheast, 6 to 4.5 ka (positive = brighter):\n')
print(northeast_table[, c('month', 'run', 'change_6_to_4.5ka', 'swap_50bp_open_land', 'swap_6ka_open_land', 'historical_exchange', 'outside_share_any_slice')],
      row.names = FALSE, digits = 3)
cat(sprintf('\nStudy-area forcing, %s kernel, mean over the months (W/m2; positive = warming): vegetation part, ice part, total\n', kernels[1]))
print(forcing_table[forcing_table$region == 'study area' & forcing_table$kernel == kernels[1] & forcing_table$month == 'annual',
                    c('period', 'run', 'vegetation_forcing', 'ice_forcing', 'total_forcing')], row.names = FALSE, digits = 3)
cat(sprintf('\nNortheast forcing over the hemlock interval (%s), %s kernel (W/m2; positive = warming): vegetation part, ice part, total\n', hemlock_period, kernels[1]))
print(forcing_table[forcing_table$region == 'northeast' & forcing_table$kernel == kernels[1] & forcing_table$period == hemlock_period,
                    c('month', 'run', 'vegetation_forcing', 'ice_forcing', 'total_forcing', 'outside_share')], row.names = FALSE, digits = 3)
cat('\nPast cells north of every fitting cell, by month (study area):\n')
print(geography[geography$region == 'study area', c('month', 'fitting_cells', 'northernmost_fitting_latitude', 'past_cells', 'cells_without_fitting_cell', 'cells_north_of_fitting')], row.names = FALSE)
cat('\nwritten to', out_dir, '\n')
