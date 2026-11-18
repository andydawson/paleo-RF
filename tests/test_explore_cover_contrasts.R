# The exploration of the fitted cover response: hand-worked cells, a stand-in fitter (one small
# parametric fit; none of the six versions is fitted), the tracked table of published values, and a
# miniature of Duveiller et al.'s file for the comparison command.
suppressMessages(source('tools/explore_cover_contrasts.R'))
suppressPackageStartupMessages(library(mgcv))
equal = function(a, b) isTRUE(all.equal(a, b, check.attributes = FALSE))
fails = function(expression) inherits(try(force(expression), silent = TRUE), 'try-error')

# --- Published values: only what can honestly be set on a month axis ------------------------------
published = read_published()
guide = guide_for(published, 'all_days')
hollinger = published[published$source == 'Hollinger 2010' & published$months == 'April-May' &
                        published$exchange == 'evergreen to summergreen', ]
stopifnot(identical(months_between('apr', 'may'), c('apr', 'may')), identical(months_between('dec', 'feb'), c('dec', 'jan', 'feb')),
  all(published$month %in% MONTHS), all(published$snow %in% names(TABLE_LABELS)), all(is.finite(published$difference)),
  setequal(published$exchange, EXCHANGES$exchange),
  !any(published$source %in% c('Bright 2015', 'Euskirchen 2016')),   # spectral bands; snow periods
  # the two tower groups of Hollinger's Table 2, each at both months, as published (deciduous minus evergreen)
  nrow(hollinger) == 4, setequal(hollinger$difference, c(0.061, 0.034)), setequal(hollinger$month, c('apr', 'may')),
  all(hollinger$snow == 'snow_free'),
  # beside the all-days fits: snow-free values, June to September only; beside the others: their own snow state
  nrow(guide) > 0, all(guide$snow == 'snow_free'), all(guide$month %in% c('jun', 'jul', 'aug', 'sep')),
  equal(guide$guide, 0.10 * guide$difference), all(guide_for(published, 'snowy')$snow == 'snowy'),
  nrow(guide_for(published, 'snow_free')) == sum(published$snow == 'snow_free'),
  # the classes, the kind of albedo and the qualification travel with every guide
  all(c('class_a', 'class_b', 'albedo_kind', 'qualification') %in% names(guide)), attr(published, 'values')[['drawn']] == 58)

# The values Astra's review asked to qualify (findings 1 and 5) and Jin's two values.
by_source = function(source) published[published$source == source, ]
burakowski = by_source('Burakowski 2015')
mosaic = grepl('mosaic', burakowski$class_a)
beside_snowy = guide_for(published, 'snowy')
lutz = by_source('Lutz 2015')
jin = by_source('Jin 2002')
stopifnot(
  # four single-day values, all 9 March 2013; the two mosaic comparisons drawn on the published page but never beside the model
  nrow(burakowski) == 4, all(burakowski$month == 'mar'), all(startsWith(burakowski$qualification, 'single day (9 March 2013)')),
  setequal(burakowski$difference[mosaic], c(0.12, 0.15)), setequal(burakowski$difference[!mosaic], c(0.54, 0.52)),
  !any(grepl('mosaic', unlist(lapply(names(TABLE_LABELS), function(t) guide_for(published, t)$class_a)))),
  equal(sort(beside_snowy$guide[beside_snowy$source == 'Burakowski 2015']), c(0.052, 0.054)),
  # Lutz: three annual means at separate sites, all conditions, so beside no model page
  length(unique(lutz$difference)) == 3, all(lutz$qualification == 'annual mean; separate sites'), all(lutz$months == 'annual'),
  # Burakowski 2016: the placement follows the paper's comparison window
  all(grepl('comparison window', by_source('Burakowski 2016')$qualification)),
  # Jin: two values, November to January, read by Astra only
  nrow(jin) == 6, setequal(jin$difference, c(0.017, 0.081)), setequal(jin$month, c('nov', 'dec', 'jan')),
  all(jin$beside_model == 'yes'), all(jin$qualification == ''))

# The five columns added for this tool restate the table's own text, row by row; and each
# difference is the first class's albedo minus the second's, wherever all three are numbers.
rows = read.csv(PUBLISHED_FILE)
stated = suppressWarnings(as.integer(sub('^Contrast ([123])[ .,].*$', '\\1', rows$note)))   # none for "Contrasts 2 and 3"
number = function(text) suppressWarnings(as.numeric(text))
# Every distinct period of the table, with the first and last calendar month it must have; any
# other period (Euskirchen's snow periods, values not read) has none.
periods = data.frame(
  period = c('April-May', 'June-August', 'September-October', 'December-March', 'December-February', 'November-January',
             'annual', 'January', 'February', 'March', 'April', 'May', 'November'),
  first  = c('apr', 'jun', 'sep', 'dec', 'dec', 'nov', 'jan', 'jan', 'feb', 'mar', 'apr', 'may', 'nov'),
  last   = c('may', 'aug', 'oct', 'mar', 'feb', 'jan', 'dec', 'jan', 'feb', 'mar', 'apr', 'may', 'nov'))
expected = periods[match(sub(' \\(.*$', '', rows$months), periods$period), ]          # "March (9 March 2013)" is "March"
calendar = !is.na(expected$period)
stopifnot(identical(rows$first_month[calendar], expected$first[calendar]), identical(rows$last_month[calendar], expected$last[calendar]),
  all(rows$first_month[!calendar] == '' & rows$last_month[!calendar] == ''), setequal(expected$period[calendar], periods$period),
  identical(lengths(lapply(seq_len(nrow(periods)), function(i) months_between(periods$first[i], periods$last[i]))),
            c(2L, 3L, 2L, 4L, 3L, 3L, 12L, rep(1L, 6))))
stopifnot(identical(rows$contrast, stated),
  all((rows$snow == 'snowy') == grepl('^snow-covered', rows$snow_state)),
  all((rows$snow == 'snow_free') == (grepl('^snow-free', rows$snow_state) & !grepl('and snow-covered', rows$snow_state))),
  all((rows$snow == 'all_days') == grepl('^all ', rows$snow_state)),
  all((rows$broadband == 'no') == grepl('NOT broadband', rows$albedo_kind)),
  all(abs(number(rows$difference_a_minus_b) - (number(rows$albedo_a) - number(rows$albedo_b))) < 5.1e-5, na.rm = TRUE),   # one is rounded to four decimals
  sum(is.finite(number(rows$difference_a_minus_b))) == 98,
  # the two added columns: a qualification only where the review asked for one; only the mosaic comparisons kept from beside the model
  identical(rows$source[rows$qualification != ''], rep(c('Burakowski 2016', 'Burakowski 2015', 'Lutz 2015'), c(6, 4, 3))),
  identical(which(rows$beside_model == 'no'), which(grepl('mosaic', rows$class_a))), all(rows$beside_model %in% c('yes', 'no')),
  sum(rows$beside_model == 'no') == 2, all(grepl('read by Astra', rows$read_from[rows$source == 'Jin 2002' & rows$checked != 'abstract only'])))

# --- A run in which every number can be worked by hand -------------------------------------------
# 160 background cells west of the named boxes set the month's range of cover mixes: every mix with
# at least 2 % of each class (three near-pure cells are its corners). Six northeast cells follow.
i = 1:160
background = data.frame(x = -124.5 + (i %% 20), y = 41.5 + (i %/% 20), elev = 100 + (i * 37) %% 900,
                        OL = 0.10 + 0.5 * ((i * 0.618) %% 1))
background$ET = (1 - background$OL) * (0.15 + 0.7 * ((i * 0.414) %% 1))
background$ST = 1 - background$OL - background$ET
background[1:3, c('OL', 'ET', 'ST')] = rbind(c(.96, .02, .02), c(.02, .96, .02), c(.02, .02, .96))
northeast = data.frame(x = -75.5 + 0:5, y = 42.5, elev = 300,
                       OL = c(.20, .06, .50, .30, .30, .50), ET = c(.30, .44, .08, .30, .35, .03))
northeast$ST = 1 - northeast$OL - northeast$ET
south = data.frame(x = -85.5, y = 25.5, elev = 10, OL = .3, ET = .3, ST = .4)   # in the Southeast box, south of the study area
cal = rbind(northeast, background, south)
# A known response: open land brightest, evergreen darkest, so all three exchanges brighten, with a
# little noise that differs between months (the comparison command below needs all twelve).
albedo_of = function(cal, month) plogis(-0.5 - 2 * cal$ET - cal$ST + 0.0003 * cal$elev + 0.05 * sin(seq_len(nrow(cal)) + match(month, MONTHS) - 4))
cal$apr = albedo_of(cal, 'apr')
cal$apr[4] = NA                                   # the fourth northeast cell has no albedo in April
area = c(1, 3, 2, 4, NA, 5, rep(2, 161))          # the fifth has no area
flat = function(value) setNames(data.frame(matrix(value, nrow(cal), length(MONTHS))), MONTHS)
run = list(table = 'snowy', cal = cal, area = area, files = c(calibration_table = 'config.R'),
           domain = list(lon_min = -170, lat_min = 27, lat_max = 74),
           snowfree_share = flat(0.25), snowy_share = flat(0.75))

# Northeast, by hand. Eligible needs 5 points to give up in both exchanged classes and both
# endpoints inside the range (each class at least 2 %):
#   cell 1 (OL .20, ET .30): every exchange.      cell 2 (OL .06): only evergreen to summergreen,
#   cell 3 (ET .08): every exchange, but below    since 1 % open land is outside the range.
#     Lejeune's 10 % for the evergreen ones.      cell 6 (ET .03): only summergreen to open land.
#   cell 4: no albedo, so not fitted.             cell 5: no area, so not one of the region's cells.
cases = exchange_cases(run, 'apr')
support = do.call(rbind, lapply(cases, function(case) case$support))
ne = support[support$region == 'Northeast (hemlock box)', ]
stopifnot(nrow(support) == 7 * 3, identical(ne$exchange, EXCHANGES$exchange),
  all(ne$region_cells == 5), all(ne$fitted_cells == 4), identical(ne$eligible_cells, c(3L, 2L, 3L)),
  equal(ne$area_share, c(1 + 3 + 2, 1 + 2, 1 + 2 + 5) / 15), identical(ne$cells_10pct, c(2L, 1L, 3L)),
  all(ne$snowfree_share == 0.25), all(ne$snowy_share == 0.75))
# Without `members`, the regions are the study area and the six boxes of R/regions.R, in that order.
stopifnot(identical(unique(support$region), c(STUDY_AREA, DIAGNOSTIC_REGIONS$region)))
# The study area takes the latitude window, not the boxes: the southern cell is in the Southeast
# box only. A region without cells has counts of zero and nothing else.
study = support[support$region == STUDY_AREA, ]
southeast = support[support$region == 'Southeast (AR, LA to FL, GA, Carolinas)', ]
alaska = support[support$region == 'Alaska / Yukon', ]
stopifnot(all(study$region_cells == 5 + 160), all(study$fitted_cells == 4 + 160), all(southeast$region_cells == 1),
  all(alaska$region_cells == 0), all(alaska$eligible_cells == 0), all(is.na(alaska$snowy_share)))
# Positive is brighter, and "A to B" gains B: the second endpoint has 10 points more of B.
first_case = cases[[which(support$region == 'Northeast (hemlock box)' & support$exchange == 'evergreen to summergreen')]]$exchange
stopifnot(equal(first_case$second$ST - first_case$first$ST, rep(.1, 3)), equal(first_case$second$ET - first_case$first$ET, rep(-.1, 3)),
  equal(first_case$weight, c(1, 3, 2) / 6))

# --- The fit command with a stand-in fitter -------------------------------------------------------
# 166 complete cells (all but the one without albedo): the two versions with at most 151 coefficients are "fitted", the other four
# are not. The stand-in fails for one of the two; the other gets one small parametric fit.
kept = NULL
stand_in = function(version, month, data) {
  if (version == 'loc100_linear')
    return(list(fit = NULL, converged = FALSE, retries = 1L, status = 'ERROR: stipulated failure', warnings = ''))
  kept <<- mgcv::gam(stats::reformulate(c('ET', 'ST', 'elev'), month), family = mgcv::betar(link = 'logit'),
                     data = data[complete_rows(data, month), ], method = 'REML')
  list(fit = kept, converged = TRUE, retries = 0L, status = 'stand-in', warnings = '')
}
out_dir = tempfile('cover-contrasts-')
invisible(capture.output(fit_months(run, out_dir, 'apr', fit_model = stand_in)))
contrasts = read.csv(file.path(out_dir, 'contrasts_snowy_apr.csv'))
fits = read.csv(file.path(out_dir, 'fits_snowy_apr.csv'))
fitted = contrasts[contrasts$version == 'loc30_linear', ]
stopifnot(nrow(contrasts) == 6 * 7 * 3, all(contrasts$table == 'snowy'), all(contrasts$month == 'apr'),
  identical(fits$version, CONTRAST_VERSIONS), all(fits$complete_cells == 166),
  identical(fits$converged, c(TRUE, NA, FALSE, NA, NA, NA)), fits$status[3] == 'ERROR: stipulated failure',
  all(grepl('^not fitted: 166 complete cells, fewer than its', fits$status[c(2, 4, 5, 6)])),
  # a version that failed or was not fitted keeps all its rows, with its status and no numbers
  all(table(contrasts$version) == 21), all(is.na(contrasts$contrast[contrasts$version != 'loc30_linear'])),
  all(is.na(contrasts$se[contrasts$version != 'loc30_linear'])), !any(is.na(fitted$contrast[fitted$eligible_cells > 0])),
  all(is.na(fitted$contrast[fitted$eligible_cells == 0])),
  file.exists(file.path(out_dir, 'record_snowy_apr.txt')))
# What the fitter returned is saved for the two versions it ran for, the failure too, and the
# month's exchanges once; the saved fit gives back the table's numbers exactly.
saved = readRDS(file.path(out_dir, 'fit_snowy_apr_loc30_linear.rds'))
saved_cases = readRDS(file.path(out_dir, 'cases_snowy_apr.rds'))
again = t(sapply(saved_cases, function(case) exchange_contrast(saved$fit, case$exchange)))
stopifnot(setequal(list.files(out_dir, '[.]rds$'), c('cases_snowy_apr.rds', 'fit_snowy_apr_loc30_linear.rds', 'fit_snowy_apr_loc100_linear.rds')),
  identical(saved$status, 'stand-in'), identical(coef(saved$fit), coef(kept)), identical(saved_cases, cases),
  is.null(readRDS(file.path(out_dir, 'fit_snowy_apr_loc100_linear.rds'))$fit),
  equal(again[, 'contrast'], fitted$contrast), equal(again[, 'se'], fitted$se))
# Every version is described at the same cells.
same_cells = c('region', 'exchange', 'region_cells', 'fitted_cells', 'eligible_cells', 'area_share', 'cells_10pct')
for (version in CONTRAST_VERSIONS)
  stopifnot(equal(contrasts[contrasts$version == version, same_cells], fitted[, same_cells]))
# The numbers, worked independently from the kept fit: predicted albedo at the two endpoints of
# the three eligible northeast cells, weighted by area 1, 3 and 2.
endpoint = function(cells, more, fewer) { cells[[more]] = cells[[more]] + .05; cells[[fewer]] = cells[[fewer]] - .05; cells }
difference = as.numeric(predict(kept, endpoint(cal[1:3, ], 'ST', 'ET'), type = 'response') -
                          predict(kept, endpoint(cal[1:3, ], 'ET', 'ST'), type = 'response'))
weight = c(1, 3, 2) / 6
row = fitted[fitted$region == 'Northeast (hemlock box)' & fitted$exchange == 'evergreen to summergreen', ]
stopifnot(equal(row$contrast, sum(weight * difference)), row$contrast > 0, row$se > 0,
  equal(row$spread, sqrt(sum(weight * (difference - sum(weight * difference))^2))),
  all(fitted$contrast[fitted$eligible_cells > 0] > 0),       # the stipulated response brightens in all three
  identical(fitted$location_k[1], 30L), identical(fitted$cover_form[1], 'linear'))

# --- The report command ---------------------------------------------------------------------------
invisible(capture.output(suppressMessages(report(out_dir))))   # one month: ggplot remarks that a line has one point
stacked = read.csv(file.path(out_dir, 'cover_contrasts.csv'), comment.char = '#')
beside = read.csv(file.path(out_dir, 'published_guide.csv'))
stopifnot(equal(stacked, contrasts), grepl('^# ', readLines(file.path(out_dir, 'cover_contrasts.csv'), 1)),
  equal(read.csv(file.path(out_dir, 'fits.csv')), fits), all(beside$beside_table == 'snowy'), all(beside$snow == 'snowy'),
  file.size(file.path(out_dir, 'cover_contrasts.pdf')) > 0, file.exists(file.path(out_dir, 'record_report.txt')),
  fails(report(tempfile('no-fits-'))))
unlink(out_dir, recursive = TRUE)

# --- Reading a run: the repository's cell table must be the one its calibration table came from ---
cell_table = read.csv('data/albedo_modis_cells.csv')
some = unique(cell_table[cell_table$y > 44 & cell_table$y < 46 & cell_table$x > -76 & cell_table$x < -70, c('x', 'y')])
real = data.frame(some, elev = 200, OL = .2, ET = .3, ST = .5, row.names = NULL)
albedo = column_by_month(cell_table, real, 'full_75')
albedo[albedo == 0] = 1e-4
run_dir = tempfile('cover-contrasts-run-')
dir.create(file.path(run_dir, 'data'), recursive = TRUE)
invisible(file.copy('config.R', file.path(run_dir, 'config_used.R')))
saveRDS(data.frame(real, albedo), file.path(run_dir, 'data', 'calibration_modern_lct_interp_bluesky.RDS'))
saveRDS(data.frame(x = rep(real$x[-1], 2), y = rep(real$y[-1], 2), area = 7), file.path(run_dir, 'data', 'ALB_diffs_bluesky.RDS'))
read = read_run(run_dir)
stopifnot(nrow(real) >= 5, read$table == 'all_days', equal(read$cal, data.frame(real, albedo)),
  is.na(read$area[1]), all(read$area[-1] == 7), read$domain$lat_min == 27,
  equal(read$snowfree_share, column_by_month(cell_table, real, 'full_75_share_snowfree')),
  equal(read$snowy_share$jul, rep(0, nrow(real))), identical(sort(list.files(run_dir, recursive = TRUE)),
    c('config_used.R', 'data/ALB_diffs_bluesky.RDS', 'data/calibration_modern_lct_interp_bluesky.RDS')))
albedo$jul[2] = albedo$jul[2] + 0.001             # a table from another build: stop, do not describe other retrievals
saveRDS(data.frame(real, albedo), file.path(run_dir, 'data', 'calibration_modern_lct_interp_bluesky.RDS'))
stopifnot(fails(read_run(run_dir)))
unlink(run_dir, recursive = TRUE)
# --- The duveiller command: a miniature of the published file ------------------------------------
# More longitudes than latitudes, and latitudes descending as in the real file; the months stored
# from December back to January, and the transitions out of order with one code more. So a
# position taken for a value, or a grid read the wrong way round, gives other numbers. Each value
# tells its cell, month and transition apart and is a multiple of 2^-24, exact in the file's 32-bit
# floats. The counts are everywhere, also where there is no estimate, as in the real file.
LON = seq(-124.5, -70.5); LAT = seq(49.5, 25.5)                         # every cell of the hand-made run
STORED_MONTHS = 12:1; STORED_TRANSITIONS = c(38, 12, 28, 99, 23)
value = function(lon, lat, month, transition) (lon + 125.5 + 64 * (lat - 24.5) + 4096 * month + 65536 * transition) / 2^24
grid = expand.grid(lon = LON, lat = LAT, month = STORED_MONTHS, transition = STORED_TRANSITIONS)
shape = c(length(LON), length(LAT), length(STORED_MONTHS), length(STORED_TRANSITIONS))
change = array(value(grid$lon, grid$lat, grid$month, grid$transition), shape)
samples = array(20 + (grid$lat - 24.5) + (grid$lon + 125.5) %% 7, shape)    # 21 to 51
jan = STORED_MONTHS == 1; t23 = STORED_TRANSITIONS == 23
change[LON == -75.5, LAT == 42.5, jan, t23] = NaN                       # January: no estimate at the first northeast cell,
change[LON == -74.5, LAT == 42.5, jan, t23] = 0                         # and an estimate of zero at the second
change[LON > -100, , STORED_MONTHS == 7, STORED_TRANSITIONS == 38] = NaN  # July, transition 38: none east of 100 W
write_source = function(change, samples, lon = LON, dims = c('lon', 'lat', 'mon', 'iTr')) {
  file = tempfile('duveiller-', fileext = '.nc')
  axes = list(lon = ncdf4::ncdim_def('lon', 'degreesE', lon), lat = ncdf4::ncdim_def('lat', 'degreesN', LAT),
              mon = ncdf4::ncdim_def('mon', 'months', STORED_MONTHS), iTr = ncdf4::ncdim_def('iTr', '', STORED_TRANSITIONS))
  nc = ncdf4::nc_create(file, list(ncdf4::ncvar_def('Delta_albedo', '', axes[dims], NaN, prec = 'float'),
                                   ncdf4::ncvar_def('N_Delta_albedo', 'samples', axes[dims], NaN, prec = 'float')))
  order = match(dims, names(axes))
  ncdf4::ncvar_put(nc, 'Delta_albedo', aperm(change, order))
  ncdf4::ncvar_put(nc, 'N_Delta_albedo', aperm(samples, order))
  ncdf4::nc_close(nc)
  file
}
fails_with = function(expression, pattern) {
  result = try(force(expression), silent = TRUE)
  inherits(result, 'try-error') && grepl(pattern, result)
}
source_file = write_source(change, samples)
nc = ncdf4::nc_open(source_file)
check_duveiller_file(nc)
# Each transition turned to the exchange's direction and multiplied by 0.10, latitudes the right way up.
turned = function(month, transition, sign) EXCHANGE_SIZE * sign * outer(LON, LAT, value, month = month, transition = transition)
reversed = turned(1, 23, -1)
reversed[LON == -75.5, LAT == 42.5] = NaN; reversed[LON == -74.5, LAT == 42.5] = 0
july = turned(7, 38, 1); july[LON > -100, ] = NaN
january = read_duveiller_month(nc, 'jan')
stopifnot(identical(names(january), EXCHANGES$exchange), equal(january[['evergreen to summergreen']]$change, reversed),
  equal(january[['evergreen to open land']]$change, turned(1, 38, 1)), equal(january[['summergreen to open land']]$change, turned(1, 28, 1)),
  equal(read_duveiller_month(nc, 'jul')[['evergreen to open land']]$change, july),
  equal(january[['evergreen to summergreen']]$samples, samples[, , jan, t23]),
  # a missing estimate stays missing, a zero stays an estimate, and only the change is reversed
  !is.finite(january[['evergreen to summergreen']]$change[LON == -75.5, LAT == 42.5]),
  identical(january[['evergreen to summergreen']]$change[LON == -74.5, LAT == 42.5], 0),
  all(january[['evergreen to summergreen']]$change[LON < -100, ] < 0), all(january[['evergreen to summergreen']]$samples > 0))
# The layout is checked by name, the grid by its spacing, the counts against the estimates.
swapped = ncdf4::nc_open(write_source(change, samples, dims = c('lat', 'lon', 'mon', 'iTr')))
half = ncdf4::nc_open(write_source(change, samples, lon = seq(-124.5, by = 0.5, length.out = length(LON))))
few = samples; few[LON == -73.5, LAT == 42.5, jan, t23] = 19
too_few = ncdf4::nc_open(write_source(change, few))
stopifnot(fails_with(check_duveiller_file(swapped), 'dimensions lon, lat, mon, iTr'), fails_with(check_duveiller_file(half), 'not a one-degree grid'),
  fails_with(read_duveiller_month(too_few, 'jan'), 'without 20 samples'), !fails(read_duveiller_month(too_few, 'feb')))
for (opened in list(swapped, half, too_few)) ncdf4::nc_close(opened)

# --- The duveiller command: the saved job of the hand-made run, all twelve months ----------------
# The run above with all-days albedo in every month (the fourth northeast cell has none), fitted by
# the stand-in: loc30_linear fitted, loc100_linear failed, the other four not fitted.
all_days = run
all_days$table = 'all_days'
for (month in MONTHS) all_days$cal[[month]] = albedo_of(cal, month)
all_days$cal[4, MONTHS] = NA
saved_dir = tempfile('saved-')
invisible(capture.output(fit_months(all_days, saved_dir, MONTHS, fit_model = stand_in)))
comparison_dir = tempfile('duveiller-')
invisible(capture.output(suppressMessages(compare_duveiller(saved_dir, source_file, comparison_dir))))
compared = read.csv(file.path(comparison_dir, 'cover_contrasts_duveiller.csv'), comment.char = '#')
source_columns = c('month', 'region', 'exchange', 'region_cells', 'eligible_cells', 'common_cells', 'common_area_m2',
                   'share_of_eligible_area', 'share_of_region_area', 'min_samples', 'max_samples', 'duveiller_contrast')
stopifnot(nrow(compared) == 12 * 6 * 7 * 3, !anyDuplicated(compared[, c('month', 'version', 'region', 'exchange')]),
  identical(unique(compared$month), MONTHS), identical(unique(compared$version), CONTRAST_VERSIONS),
  nrow(unique(compared[, source_columns])) == 12 * 7 * 3,       # the published side and the coverage are the same for every version
  grepl('^# ', readLines(file.path(comparison_dir, 'cover_contrasts_duveiller.csv'), 1)),
  file.size(file.path(comparison_dir, 'cover_contrasts_duveiller.pdf')) > 0)
# Northeast, January, evergreen to summergreen, by hand. The eligible cells are the first three
# (areas 1, 3 and 2): the first has no published estimate and the second an estimate of zero, so
# two common cells weighted 3/5 and 2/5, and the published mean is 2/5 of the third cell's value
# reversed and multiplied by 0.10. The region's calibration cells have an area of 1 + 3 + 2 + 4 + 5.
ne_jan = compared[compared$month == 'jan' & compared$region == 'Northeast (hemlock box)' & compared$exchange == 'evergreen to summergreen', ]
stopifnot(nrow(ne_jan) == 6, all(ne_jan$eligible_cells == 3), all(ne_jan$common_cells == 2), all(ne_jan$common_area_m2 == 5),
  equal(ne_jan$share_of_eligible_area, rep(5 / 6, 6)), equal(ne_jan$share_of_region_area, rep(5 / 15, 6)),
  equal(ne_jan$duveiller_contrast, rep(2 / 5 * -0.1 * value(-73.5, 42.5, 1, 23), 6)), all(ne_jan$min_samples == 40), all(ne_jan$max_samples == 41))
# The common cells' two endpoints are the saved ones, subset alike, and the weights are renormalised.
jan_cases = readRDS(file.path(saved_dir, 'cases_all_days_jan.rds'))
k = which(sapply(jan_cases, function(case) case$support$region == 'Northeast (hemlock box)' && case$support$exchange == 'evergreen to summergreen'))
matched = duveiller_cases(jan_cases, january, nc)[[k]]$exchange
stopifnot(identical(matched$first, jan_cases[[k]]$exchange$first[2:3, ]), identical(matched$second, jan_cases[[k]]$exchange$second[2:3, ]),
  equal(matched$weight, c(3, 2) / 5), equal(jan_cases[[k]]$exchange$weight, c(1, 3, 2) / 6))
# A region with calibration cells but none eligible (as Alaska and Yukon in December): none of its
# area is represented, and there is no share of an eligible area to give.
none = jan_cases[k]
none[[1]]$exchange = freeze_exchange(none[[1]]$exchange$first[0, ], none[[1]]$exchange$second[0, ], numeric(0))
none[[1]]$support[, c('eligible_cells', 'area_share')] = 0
none = duveiller_cases(none, january, nc)[[1]]$support
stopifnot(none$common_cells == 0, is.na(none$share_of_eligible_area), none$share_of_region_area == 0, is.na(none$duveiller_contrast))
# The fitted version's mean on those two cells with those weights, from its own predictions, and not
# its saved mean over all three; the failed and the unfitted versions have no numbers.
fit = readRDS(file.path(saved_dir, 'fit_all_days_jan_loc30_linear.rds'))$fit
cells = all_days$cal[2:3, ]
ne_difference = as.numeric(predict(fit, endpoint(cells, 'ST', 'ET'), type = 'response') - predict(fit, endpoint(cells, 'ET', 'ST'), type = 'response'))
saved_row = read.csv(file.path(saved_dir, 'contrasts_all_days_jan.csv'))
saved_row = saved_row[saved_row$version == 'loc30_linear' & saved_row$region == 'Northeast (hemlock box)' & saved_row$exchange == 'evergreen to summergreen', ]
restricted = ne_jan[ne_jan$version == 'loc30_linear', ]
stopifnot(equal(restricted$contrast, sum(c(3, 2) / 5 * ne_difference)), !equal(restricted$contrast, saved_row$contrast), restricted$se > 0,
  all(is.na(ne_jan$contrast[ne_jan$version != 'loc30_linear'])), ne_jan$fit_status[ne_jan$version == 'loc100_linear'] == 'ERROR: stipulated failure',
  all(grepl('^not fitted', ne_jan$fit_status[!ne_jan$version %in% c('loc30_linear', 'loc100_linear')])))
# July, evergreen to open land: no published estimate at the northeast's two eligible cells, so the
# rows stay, without means. Alaska and Yukon have no cells at all, so no shares either.
empty = compared[compared$month == 'jul' & compared$region == 'Northeast (hemlock box)' & compared$exchange == 'evergreen to open land', ]
alaska_rows = compared[compared$region == 'Alaska / Yukon', ]
stopifnot(nrow(empty) == 6, all(empty$eligible_cells == 2), all(empty$common_cells == 0), all(empty$common_area_m2 == 0),
  all(empty$share_of_eligible_area == 0), all(empty$share_of_region_area == 0), all(is.na(empty$duveiller_contrast)),
  all(is.na(empty$min_samples) & is.na(empty$max_samples)), all(is.na(empty$contrast) & is.na(empty$se) & is.na(empty$spread)),
  all(alaska_rows$eligible_cells == 0), all(is.na(alaska_rows$share_of_eligible_area) & is.na(alaska_rows$share_of_region_area)),
  # numbers exactly where there are common cells (and, for a version, a converged fit)
  identical(is.finite(compared$duveiller_contrast), compared$common_cells > 0),
  identical(is.finite(compared$contrast), compared$common_cells > 0 & compared$version == 'loc30_linear'))
record = readLines(file.path(comparison_dir, 'record_duveiller.txt'))
stopifnot('job: duveiller' %in% record, length(grep('^input ', record)) == 1 + 12 + 12 + 24,   # the file, cases, status tables and the 24 fits made
  paste('input published_change', source_file, tools::md5sum(source_file)) %in% record,
  'transition: evergreen to summergreen beside transition 23, sign -1' %in% record, length(grep('^transition: ', record)) == 3,
  any(grepl('^package ncdf4 ', record)), length(grep('^time .*: [0-9.]+ s$', record)) == 4)

# --- The case-studies command: the four boxes, and the saved job above evaluated there -----------
# The boxes as the case-study search's table gives them, written out again: each takes a cell on its
# west and south edges (its south-west corner), not one on its east or north edge (its south-east
# and north-west corners). No corner of one box is in another.
west = c(-80, -80, -100, -84); east = c(-66, -55, -88, -74); south = c(40, 50, 40, 32); north = c(48, 60, 50, 40)
inside = do.call(cbind, case_study_members(data.frame(x = c(west, east, west), y = c(south, south, north))))
stopifnot(identical(names(CASE_STUDY_BOXES), c('hemlock_decline', 'quebec_spruce', 'prairie_advance', 'clearance_seaboard')),
  identical(colnames(inside), unname(CASE_STUDY_BOXES)), identical(unname(inside), rbind(diag(4) == 1, matrix(FALSE, 8, 4))))
# The saved all-days job of the hand-made run, evaluated at the boxes. Nothing may be fitted: the
# tool's fitting step, the ordinary fitter and the registry's fitter stop the test if called. The
# six northeast cells are the hemlock box's; the other boxes have no cells here.
fitters = mget(c('fit_version', 'fit_calibration_retry', 'fit_calibration_model'))
fit_version = fit_calibration_retry = fit_calibration_model = function(...) stop('the case-studies command fitted a model')
case_dir = tempfile('case-studies-')
invisible(capture.output(evaluate_case_studies(all_days, saved_dir, case_dir)))
invisible(list2env(fitters, globalenv()))
stacked = function(dir) do.call(rbind, lapply(MONTHS, function(month) read.csv(file.path(dir, sprintf('contrasts_all_days_%s.csv', month)))))
boxes = stacked(case_dir)
before = stacked(saved_dir)
hemlock = 'Northeast (hemlock box)'
status_tables = sprintf('fits_all_days_%s.csv', MONTHS)
stopifnot(nrow(boxes) == 12 * 6 * 4 * 3, identical(unique(boxes$region), unname(CASE_STUDY_BOXES)),
  # the hemlock box gives back the saved northeast rows, numbers and all; the other boxes have no cells
  equal(boxes[boxes$region == hemlock, ], before[before$region == hemlock, ]),
  all(boxes$region_cells[boxes$region != hemlock] == 0), all(is.na(boxes$contrast[boxes$region != hemlock])),
  # the status tables copied unchanged; the cases saved, and no fit saved or copied
  identical(unname(tools::md5sum(file.path(case_dir, status_tables))), unname(tools::md5sum(file.path(saved_dir, status_tables)))),
  setequal(list.files(case_dir, '[.]rds$'), sprintf('cases_all_days_%s.rds', MONTHS)))
# Each month's record: the run's file, the boxes' table, the saved status table and the two fits the
# stand-in made (loc30_linear, and loc100_linear's failure), and where the fits came from.
case_record = readLines(file.path(case_dir, 'record_all_days_jan.txt'))
jan_fit = file.path(saved_dir, 'fit_all_days_jan_loc30_linear.rds')
stopifnot(length(grep('^input ', case_record)) == 1 + 1 + 1 + 2,
  paste('input case_study_boxes', CASE_STUDY_FILE, tools::md5sum(CASE_STUDY_FILE)) %in% case_record,
  paste('input', basename(jan_fit), jan_fit, tools::md5sum(jan_fit)) %in% case_record,
  paste('fits: read from', saved_dir, '(saved by the fit command), not refitted') %in% case_record)

# --- The duveiller command: what stops it --------------------------------------------------------
# A shifted grid, and saved fits that do not match their status tables, stop the comparison with a reason.
tampered = file.path(saved_dir, 'fit_all_days_jun_loc30_linear.rds')
jun_fit = readRDS(tampered); jun_fit$status = 'another fit'; saveRDS(jun_fit, tampered)
stopifnot(fails_with(compare_duveiller(saved_dir, write_source(change, samples, lon = LON + 0.5), tempfile()), 'do not line up'),
  fails_with(compare_duveiller(saved_dir, source_file, tempfile()), 'is not the fit its status table describes'))
invisible(file.remove(file.path(saved_dir, 'fit_all_days_mar_loc30_linear.rds')))
stopifnot(fails_with(compare_duveiller(saved_dir, source_file, tempfile()), 'do not match their status tables'))
ncdf4::nc_close(nc)
unlink(c(saved_dir, comparison_dir, case_dir), recursive = TRUE)
cat('Cover contrasts, the case-study boxes and the comparison with Duveiller et al.: hand-worked checks passed (none of the six versions fitted).\n')
