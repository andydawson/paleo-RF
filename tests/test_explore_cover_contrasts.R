# The exploration of the fitted cover response: hand-worked cells, a stand-in fitter (one small
# parametric fit; none of the six versions is fitted) and the tracked table of published values.
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
# A known response: open land brightest, evergreen darkest, so all three exchanges brighten.
cal$apr = plogis(-0.5 - 2 * cal$ET - cal$ST + 0.0003 * cal$elev + 0.05 * sin(seq_len(nrow(cal))))
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
cat('Cover contrasts: hand-worked checks passed (none of the six versions fitted).\n')
