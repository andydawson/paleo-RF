# Tests for R/hindcast_comparison.R, worked by hand. No model is fitted and no run is read.
# Run from the repository root: Rscript tests/test_hindcast_comparison.R
suppressMessages({ library(dplyr); source('R/hindcast_comparison.R') })
equal = function(a, b) isTRUE(all.equal(a, b, check.attributes = FALSE))
fails = function(expression) inherits(try(force(expression), silent = TRUE), 'try-error')

# The band of a distance outside the training range: the cross-validation's bands, lower edge included.
stopifnot(identical(outside_band(c(0, 0.01, 0.02, 0.05, 0.2)), c('inside', '[0,0.02)', '[0.02,0.05)', '[0.05,0.1)', '[0.1,Inf)')))

# A weighted mean and its support. Weights 1 (inside, value 0.2) and 3 (outside by 0.03, value 0.4):
# mean (0.2 + 1.2) / 4 = 0.35, of which 1.2 / 4 = 0.30 comes from outside and 0.2 / 4 = 0.05 from
# inside; three quarters of the weight is outside. A row without a value or without weight takes no part.
rows = data.frame(g = 'a', cell = 1:4, value = c(0.2, 0.4, NA, 0.9), weight = c(1, 3, 5, 0),
                  outside = c(FALSE, TRUE, TRUE, TRUE), distance = c(0, 0.03, 0.5, 0.6))
m = mean_with_support(rows, g)
inside_part = sum((rows$weight * rows$value)[c(1)]) / 4
stopifnot(m$cells == 2, m$total_weight == 4, equal(m$mean, 0.35), equal(m$outside_part, 0.30),
          equal(m$outside_part + inside_part, m$mean), equal(m$outside_share, 0.75), m$max_outside_distance == 0.03)

# Forcing by period, script 9's way. Cell A (area 2): January 0.4 + 0.6 = 1, February 1 + 2 = 3.
# Cell B (area 1): January 1.5 + 2.5 = 4; February has a missing pair, so no value (script 9's A5).
# January mean (2 x 1 + 1 x 4) / 3 = 2; February 3, over A alone. The mean over months averages each
# cell over its months with a value first (A6): A 2, B 4, so (2 x 2 + 1 x 4) / 3 = 8/3.
forcing = data.frame(period = 'p', cell_id = rep(c('A', 'B'), each = 4), month = rep(rep(c('jan', 'feb'), each = 2), 2),
                     area = rep(c(2, 1), each = 4), rf = c(0.4, 0.6, 1, 2, 1.5, 2.5, NA, 1))
cell_months = as.data.frame(period_cell_months(forcing, 'rf'))
value_of = function(cell, month) cell_months$value[cell_months$cell_id == cell & cell_months$month == month]
stopifnot(nrow(cell_months) == 4, equal(value_of('A', 'jan'), 1), equal(value_of('A', 'feb'), 3), equal(value_of('B', 'jan'), 4),
          is.na(value_of('B', 'feb')), identical(cell_months$months_with_value[order(cell_months$cell_id)], c(2L, 2L, 1L, 1L)))

# The support of each cell-month: B's January has one pair whose older end lies outside by 0.03, so
# it is outside at that distance; a period is outside if any end of any of its steps is.
pairs = data.frame(period = 'p', cell_id = rep(c('A', 'B'), each = 4), month = rep(rep(c('jan', 'feb'), each = 2), 2),
                   outside_young = FALSE, outside_old = c(rep(FALSE, 4), TRUE, FALSE, FALSE, FALSE),
                   distance_young = 0, distance_old = c(rep(0, 4), 0.03, 0, 0, 0))
support = as.data.frame(period_support(pairs))
stopifnot(nrow(support) == 4, identical(support$outside[support$cell_id == 'B' & support$month == 'jan'], TRUE),
          sum(support$outside) == 1, equal(max(support$distance), 0.03))

cell_months = merge(cell_months, support)
cell_months$cell = cell_months$cell_id
cell_months$weight = cell_months$area
cell_months$annual_weight = cell_months$area / cell_months$months_with_value
means = as.data.frame(monthly_and_annual_means(cell_months, 'period'))
row_of = function(month) means[means$month == month, ]
stopifnot(equal(row_of('jan')$mean, 2), equal(row_of('feb')$mean, 3), row_of('feb')$cells == 1, row_of('feb')$total_weight == 2,
          equal(row_of('annual')$mean, 8 / 3), row_of('annual')$cells == 2, equal(row_of('annual')$total_weight, 3),
          # B's January is the only cell-month outside: 1 x 4 of the January sum of 6, and of the year's 8.
          equal(row_of('jan')$outside_part, 4 / 3), equal(row_of('jan')$outside_share, 1 / 3),
          equal(row_of('annual')$outside_part, 4 / 3), equal(row_of('annual')$outside_share, 1 / 3),
          # The inside part, summed separately, adds back to each mean.
          equal(row_of('jan')$outside_part + 2 * 1 / 3, row_of('jan')$mean),
          equal(row_of('annual')$outside_part + (1 * 1 + 1 * 3) / 3, row_of('annual')$mean))

# Differences from the baseline run: the run minus the baseline on shared rows, zero for the baseline;
# with the runs' roles reversed every difference changes sign; a run that lacks a row stops.
table = data.frame(run = rep(c('a', 'b'), each = 2), k = rep(c('x', 'y'), 2), v = c(1, 2, 1.5, 1))
from_a = add_differences(table, 'k', 'v', 'a')
from_b = add_differences(table, 'k', 'v', 'b')
stopifnot(equal(from_a$v_difference, c(0, 0, 0.5, -1)), equal(from_b$v_difference, c(-0.5, 1, 0, 0)),
          equal(from_a$v_difference[from_a$run == 'b'], -from_b$v_difference[from_b$run == 'a']),
          fails(add_differences(table[-4, ], 'k', 'v', 'a')), fails(add_differences(rbind(table, table[1, ]), 'k', 'v', 'a')))

# Consecutive changes against the change between the ends (design of 5 November): albedos 0.20, 0.18,
# 0.17 and 0.15 at 6, 5.5, 5 and 4.5 ka give changes of -0.02, -0.01 and -0.02, which sum to -0.05, the
# 4.5 ka albedo minus the 6 ka one. A cell missing from the ends stops the check.
steps = data.frame(cell = 'c1', month = 'may', change = c(-0.02, -0.01, -0.02))
ends = data.frame(cell = 'c1', month = 'may', young = 0.15, old = 0.20)
stopifnot(step_sum_gap(steps, ends) < 1e-12, equal(step_sum_gap(steps, transform(ends, young = 0.16)), 0.01),
          fails(step_sum_gap(steps, transform(ends, cell = 'c2'))))

# The modern-range swap. Three cells; evergreen range today 0.20 to 0.40. With 0.70 open land at 50 BP
# the third cell cannot hold 0.40 evergreen, so it leaves both columns: the same two cells are swapped
# under 50 BP and under 6 ka open land. The first cell at 50 BP is the design's example: 0.15, 0.40,
# 0.45 becomes 0.15, 0.20, 0.65. Open land, location and elevation do not move.
cells_50bp = data.frame(x = c(-75, -74, -73), y = c(42, 43, 44), elev = c(100, 200, 300), OL = c(0.15, 0.30, 0.70), ET = 0.3, ST = c(0.55, 0.40, 0))
cells_6ka = transform(cells_50bp, OL = c(0.10, 0.20, 0.50), ST = c(0.60, 0.50, 0.20))
swaps = modern_swaps(cells_50bp, cells_6ka, low = 0.20, high = 0.40, area = c(1, 3, 2))
modern = swaps[['50 BP']]; past = swaps[['6 ka']]
stopifnot(identical(names(swaps), c('50 BP', '6 ka')), identical(attr(swaps, 'exclusions'), data.frame(candidates = 3L, retained = 2L, excluded = 1L)),
          equal(unlist(modern$first[1, c('OL', 'ET', 'ST')]), c(0.15, 0.40, 0.45)), equal(unlist(modern$second[1, c('OL', 'ET', 'ST')]), c(0.15, 0.20, 0.65)),
          equal(modern$weight, c(0.25, 0.75)), identical(modern$first[, c('x', 'y')], past$first[, c('x', 'y')]),
          equal(past$first$OL, c(0.10, 0.20)), equal(past$second$ET - past$first$ET, c(-0.2, -0.2)),
          equal(rowSums(past$second[, c('OL', 'ET', 'ST')]), c(1, 1)), equal(modern$first[, c('x', 'y', 'elev', 'OL')], modern$second[, c('x', 'y', 'elev', 'OL')]),
          fails(modern_swaps(cells_50bp, cells_6ka[3:1, ], 0.20, 0.40, c(1, 3, 2))))
# Signs: where evergreen is the darker cover (a negative coefficient on the logit scale), low evergreen
# minus high evergreen is positive, brighter. Reversing the swap negates it; no swap gives zero.
contrast_of = function(exchange) contrast_from_matrix(cbind(1, exchange$first$ET), cbind(1, exchange$second$ET),
                                                       c(qlogis(0.2), -1), diag(2) * 0.01, exchange$weight)[['contrast']]
reversed = modern_swaps(cells_50bp, cells_6ka, low = 0.40, high = 0.20, area = c(1, 3, 2))[['50 BP']]
no_swap = modern_swaps(cells_50bp, cells_6ka, low = 0.30, high = 0.30, area = c(1, 3, 2))[['50 BP']]
stopifnot(contrast_of(modern) > 0, equal(contrast_of(reversed), -contrast_of(modern)), contrast_of(no_swap) == 0)

# How far an exchange reaches outside the training range. The range is the triangle of mixes with at
# least 0.2 of each cover. Cell one stays inside at both ends; cell two (three quarters of the area)
# has 0.1 evergreen at its second end, outside by 0.1 x sqrt(3) / 2 on the cover triangle.
hull = training_hull(data.frame(OL = c(0.2, 0.2, 0.6), ET = c(0.2, 0.6, 0.2), ST = c(0.6, 0.2, 0.2)))
first = second = data.frame(x = c(-75, -74), y = c(42, 43), elev = c(100, 200), OL = 0.3, ET = 0.3, ST = 0.4)
second$ET = c(0.4, 0.1); second$ST = 1 - second$OL - second$ET
reach = exchange_outside(freeze_exchange(first, second, c(1, 3)), hull)
stopifnot(equal(reach[['outside_share']], 0.75), equal(reach[['max_outside_distance']], 0.1 * sqrt(3) / 2))

# Geographic support in one month. Four past cells of areas 1, 1, 2 and 4; the month's fitting cells
# are the first two, the northernmost at 45 N. The third past cell (44 N) has no fitting cell at its
# place but lies south of 45 N; the fourth (60 N) has none and lies north of every fitting cell.
past_cells = data.frame(x = c(-70, -71, -72, -73), y = c(40, 45, 44, 60), area = c(1, 1, 2, 4))
geography = geographic_support(past_cells, past_cells[1:2, c('x', 'y')])
stopifnot(geography$fitting_cells == 2, geography$northernmost_fitting_latitude == 45, geography$past_cells == 4,
          geography$cells_without_fitting_cell == 2, equal(geography$area_share_without_fitting_cell, 6 / 8),
          geography$cells_north_of_fitting == 1, equal(geography$area_share_north_of_fitting, 4 / 8))

# A predicted albedo against the range observed today (design of 5 November): 0.08, 0.15 and 0.22
# against 0.10 to 0.20 are below, within and above; a value on an end is within.
stopifnot(identical(range_position(c(0.08, 0.15, 0.22, 0.10, 0.20), 0.10, 0.20), c('below', 'within', 'above', 'within', 'within')))

# The cross-validation's errors beside the tables: nearby predictions (under 250 km) are pooled over the
# two nearby distance bands, 2 at a mean squared error of 0.01 and 6 at 0.03 giving (0.02 + 0.18) / 8 =
# 0.025; farther rows, the northeast's own rows and other models are left out; the tested limit comes
# from the coverage table.
by_distance = data.frame(region = c('all', 'all', 'all', 'northeast', 'all'), model = c('m1', 'm1', 'm1', 'm1', 'm2'),
                         own_direction = 'd1', cover_band = '[0.02,0.05)', km_band = c('[0,100)', '[100,250)', '[250,500)', '[0,100)', '[0,100)'),
                         cell_month_holdouts = c(2, 6, 50, 9, 4), mse = c(0.01, 0.03, 0.5, 0.9, 0.2), signed_error = c(0.04, -0.02, 0.3, 0.1, 0.1))
coverage = data.frame(own_direction = 'd1', cover_band = '[0.02,0.05)', cell_month_holdouts = 8, cells = 5, blocks = 3,
                      max_cover_distance_nearby = 0.049, score_weight_share = 0.1)
limits = validation_limits(by_distance, coverage, 'm1')
stopifnot(nrow(limits) == 1, limits$model == 'm1', limits$cell_month_holdouts == 8, equal(limits$rmse, sqrt(0.025)),
          equal(limits$signed_error, (2 * 0.04 - 6 * 0.02) / 8), limits$cells == 5, limits$blocks == 3, limits$max_cover_distance_nearby == 0.049)

cat('test_hindcast_comparison: all tests passed\n')
