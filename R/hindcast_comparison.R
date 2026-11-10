# Setting finished pipeline runs side by side: the arithmetic of tools/compare_cv_hindcasts.R
# (cross-validation protocol 2, section 7: docs/cc/2026-11-06_cv_protocol_v2.md).
#
# Why functions: the tool's tables are read as evidence of what the choice of calibration model does
# to the hindcast. The regional means, the part of each that rests on cover mixes outside the
# training range and the differences between runs are therefore each defined once, here, and worked
# by hand in tests/test_hindcast_comparison.R.
#
# Signs, everywhere: a positive albedo change or difference is brighter; a positive forcing is warming.
# Needs dplyr.

source('R/cross_validation.R')   # distance and km bands, slice_area_ice(); brings the training range and the regions
source('R/cv_separation.R')      # the northeast exchanges and their contrasts

# The band of a distance outside the training range, in the cross-validation's bands
# (CV_DISTANCE_BANDS); 'inside' for a mix inside the range.
outside_band = function(distance) ifelse(distance > 0, as.character(distance_band(distance)), 'inside')

# The weighted mean of `value` within each group, with the support it rests on: the share of the
# weight, and the part of the mean itself, that come from cover mixes outside the training range, and
# the largest distance outside. The outside part uses the whole group's denominator, so the mean is
# its outside part plus its inside part (protocol 2, section 7). `rows` has the columns value, weight,
# outside, distance and cell besides the grouping columns given in `...`; a row with no value or no
# weight takes no part.
mean_with_support = function(rows, ...) {
  rows %>% filter(!is.na(value), weight > 0) %>% group_by(...) %>%
    summarise(cells = n_distinct(cell), total_weight = sum(weight),
              mean = sum(weight * value) / total_weight,
              outside_part = sum(weight * value * outside) / total_weight,
              outside_share = sum(weight * outside) / total_weight,
              max_outside_distance = max(distance), .groups = 'drop')
}

# The regional mean of each month, and of the year as the mean over the months, each with its support
# (mean_with_support()). `rows`: one row per cell and month within each group of `by`, with the
# cell's weight in a month's mean (`weight`) and in the mean over months (`annual_weight`).
monthly_and_annual_means = function(rows, by) {
  rows$month = as.character(rows$month)
  monthly = mean_with_support(rows, across(all_of(c(by, 'month'))))
  annual = mean_with_support(transform(rows, weight = annual_weight), across(all_of(by)))
  annual$month = 'annual'
  rbind(monthly, annual[, names(monthly)])
}

# One forcing column summed over each period's slice pairs, per cell and month (script 9's note A5: a
# missing pair leaves the sum missing), with the number of months in which the cell has a value. A
# cell-month then weighs its area in that month's regional mean, and its area divided by that number
# of months in the mean over months (script 9's A6 and A7), so the study-area means are script 9's.
# `forcing`: script 8's table after assign_forcing_periods() (R/forcing_periods.R).
period_cell_months = function(forcing, column) {
  forcing %>% group_by(period, cell_id, month, area) %>%
    summarise(value = sum(.data[[column]], na.rm = FALSE), .groups = 'drop') %>%
    group_by(period, cell_id) %>% mutate(months_with_value = sum(!is.na(value))) %>% ungroup()
}

# Whether each cell-month of a period rests on a cover mix outside the training range: outside if the
# mix at either end of any of the period's slice pairs is outside that month's range, with the
# largest distance outside among those ends (protocol 2, section 7). `pairs`: one row per period,
# cell, month and slice pair, with the support of its younger and older ends.
period_support = function(pairs) {
  pairs %>% group_by(period, cell_id, month) %>%
    summarise(outside = any(outside_young | outside_old), distance = max(distance_young, distance_old), .groups = 'drop')
}

# Each run's difference from the baseline run in the given columns, as new columns named
# <column>_difference: the run minus the baseline on the rows that share the `by` columns (zero for
# the baseline itself). Every run must hold the same rows as the baseline, once each.
add_differences = function(table, by, columns, baseline) {
  key = function(rows) do.call(paste, c(rows[by], sep = '|'))
  base = table[table$run == baseline, ]
  at = match(key(table), key(base))
  if (anyNA(at) || anyDuplicated(key(base)) || nrow(table) != nrow(base) * length(unique(table$run)))
    stop('the runs do not hold the same rows as the baseline run, once each', call. = FALSE)
  for (column in columns) table[[paste0(column, '_difference')]] = table[[column]] - base[[column]][at]
  table
}

# The largest gap between the sum of each cell-month's consecutive changes over an interval and the
# change between the interval's two ends: zero when the steps telescope on the same cells.
# `steps`: cell, month and change, one row per slice pair; `ends`: cell, month, and the level at the
# younger and older end.
step_sum_gap = function(steps, ends) {
  sums = rowsum(steps$change, paste(steps$cell, steps$month))
  at = match(paste(ends$cell, ends$month), rownames(sums))
  if (anyNA(at) || nrow(sums) != nrow(ends)) stop('the steps and the ends do not hold the same cells and months', call. = FALSE)
  max(abs(sums[at, 1] - (ends$young - ends$old)))
}

# The modern-range swap of protocol 2, section 7, as two exchanges on the same cells: evergreen set to
# the high and then to the low end of today's range in the region, with each cell's open land held at
# its 50 BP level or at its 6 ka level, summergreen the rest, location and elevation fixed. Second
# endpoint minus first is low evergreen minus high: summergreen replacing evergreen. Only cells valid
# at both ends under both open-land levels are kept, so the two columns and every model use the same
# cells. `cells_50bp` and `cells_6ka`: the region's cells (x, y, elev, OL, ET, ST) at the two slices,
# in the same order; `area`: their areas.
modern_swaps = function(cells_50bp, cells_6ka, low, high, area) {
  if (!identical(separation_cell_key(cells_50bp), separation_cell_key(cells_6ka)))
    stop('the two slices do not hold the same cells in the same order', call. = FALSE)
  ends = function(cells) list(first = cells_with_evergreen(cells, high), second = cells_with_evergreen(cells, low))
  open_land = list('50 BP' = ends(cells_50bp), '6 ka' = ends(cells_6ka))
  valid = is.finite(area) & area > 0
  for (e in open_land) valid = valid & valid_exchange_rows(e$first) & valid_exchange_rows(e$second)
  valid[is.na(valid)] = FALSE
  swaps = lapply(open_land, function(e) freeze_exchange(e$first[valid, ], e$second[valid, ], area[valid]))
  attr(swaps, 'exclusions') = data.frame(candidates = length(valid), retained = sum(valid), excluded = sum(!valid))
  swaps
}

# How far an exchange reaches outside a month's training range: the share of its area with either
# end outside, and the largest distance outside at either end.
exchange_outside = function(exchange, hull) {
  support = exchange_support(exchange, hull)
  c(outside_share = sum(support$weight[support$outside]),
    max_outside_distance = max(support$distance_first, support$distance_second))
}

# The hindcast's geographic support in one month, to read beside the cover-range flag: of the past
# cells, how many (and what share of their area) have no fitting cell at their own place, and how many
# lie north of the northernmost fitting cell. The calibration has no albedo for a cell in a month with
# too little sun there, so in winter the hindcast applies the location term beyond the fitting cells.
# `past`: one row per cell, with x, y and area; `fitting`: the month's fitting cells, x and y.
geographic_support = function(past, fitting) {
  no_cell = !paste(past$x, past$y) %in% paste(fitting$x, fitting$y)
  north = past$y > max(fitting$y)
  data.frame(fitting_cells = nrow(fitting), northernmost_fitting_latitude = max(fitting$y), past_cells = nrow(past),
             cells_without_fitting_cell = sum(no_cell), area_share_without_fitting_cell = sum(past$area[no_cell]) / sum(past$area),
             cells_north_of_fitting = sum(north), area_share_north_of_fitting = sum(past$area[north]) / sum(past$area))
}

# Where a predicted albedo sits against the range observed in the region today: a descriptive warning,
# not a physical bound. A value on an end of the range counts as within.
range_position = function(value, low, high) ifelse(value < low, 'below', ifelse(value > high, 'above', 'within'))

# The cross-validation's errors and tested limits, to read beside the outside distances of the tables:
# for each departure direction and band of cover distance, each model's pooled error on the withheld
# predictions less than CV_NEARBY_KM from training, how many there were, and the cells, blocks and
# largest cover distance behind the selection there. Pooled diagnostic errors from the
# cross-validation's by_distance.csv and nearby_coverage.csv, not its selection score.
validation_limits = function(by_distance, nearby_coverage, models) {
  nearby_bands = levels(km_band(0))[CV_KM_BANDS[-1] <= CV_NEARBY_KM]
  nearby = by_distance[by_distance$region == 'all' & by_distance$model %in% models & by_distance$km_band %in% nearby_bands &
                         !is.na(by_distance$mse), ]
  pooled = nearby %>% group_by(own_direction, cover_band, model) %>%
    summarise(rmse = sqrt(sum(cell_month_holdouts * mse) / sum(cell_month_holdouts)),
              signed_error = sum(cell_month_holdouts * signed_error) / sum(cell_month_holdouts),
              cell_month_holdouts = sum(cell_month_holdouts), .groups = 'drop')
  limits = nearby_coverage[, c('own_direction', 'cover_band', 'cells', 'blocks', 'max_cover_distance_nearby')]
  as.data.frame(left_join(pooled, limits, by = c('own_direction', 'cover_band')))
}
