# Exploring the fitted cover response beside published forest contrasts
# (docs/cc/2026-11-10_cover_contrast_test_design_fable.md). For six versions of the albedo model it
# reports the albedo change each predicts when 10 points of cover are exchanged between two classes
# at the modern cells, by month, region and albedo table. It describes how the fitted models
# behave: no pass or fail, and no effect on the choice of model (Chris, 10 November 2026).
#
#   Rscript tools/explore_cover_contrasts.R fit <run-dir> <output-dir> <month> [<month> ...] [--fill-missing]
#       <run-dir> is a finished run; its configuration (config_used.R) says which albedo its
#       calibration table holds: all days, snow-free or snowy (--fill-missing for a run saved before
#       a setting existed: load_config() in R/config.R). For each month the six versions are
#       fitted afresh to that table (REML, the ordinary fitter and its one retry) and the three
#       exchanges are evaluated in the study area and the six named regions. Jobs for different
#       runs and months can run side by side. Nothing is written into <run-dir>. Each fit made is
#       saved, with its attempts, as fit_<table>_<month>_<version>.rds, and the month's exchanges
#       as cases_<table>_<month>.rds, so that a result can be examined without fitting again.
#       Keep <output-dir> outside git: the fits are large.
#   Rscript tools/explore_cover_contrasts.R report <output-dir>
#       stacks every table and month found in <output-dir> into cover_contrasts.csv and fits.csv,
#       and draws cover_contrasts.pdf: a page per albedo table, then the published values.
#   Rscript tools/explore_cover_contrasts.R duveiller <saved-contrast-dir> <netcdf-file> <output-dir>
#       sets the all-days results that the fit command saved in <saved-contrast-dir> (all twelve
#       months: their cases and fits, which are not refitted) beside the monthly change in albedo
#       published by Duveiller et al. (2018; <netcdf-file> is their albedo_IGBPdet.nc), on the cells
#       both cover, and writes cover_contrasts_duveiller.csv, cover_contrasts_duveiller.pdf and
#       record_duveiller.txt into <output-dir>. A comparison, with no pass or fail.
#
# The quantity. "A to B" is the predicted albedo with 5 points more of B and 5 fewer of A than a
# cell's own mix, minus the predicted albedo with 5 points more of A and 5 fewer of B; the third
# class, location and elevation are held. Positive is brighter. It is named and signed as the
# published transitions are (albedo after minus albedo before: Duveiller et al. 2018, eq. 11;
# Lejeune et al. 2020, sect. 2.3.1), but it is the change for 10 points of the cell, not for a
# complete transition: the models are curved on the albedo scale. The published class differences
# therefore have a page of their own, and stand beside the model only multiplied by 0.10 (the
# fraction converted times the complete-transition value: Lejeune et al. 2020, eqs 8 and 11),
# as a guide for the eye, not a measurement.

source('R/config.R')
source('R/paths.R')
source('R/run_manifest.R')    # code_version(), for the records
source('R/preparation.R')     # column_by_month(): a column of the albedo build's cell table
source('R/cv_separation.R')   # the exchanges, their contrast, the fitter, the regions, the training range

# Three sizes of the location term, each with straight-line and with thin-plate cover (Chris,
# 10 November 2026: "Six versions"). R/model_registry.R defines them.
CONTRAST_VERSIONS = c('loc30_linear', 'mod8_coarse_loc', 'loc100_linear', 'loc100_tp200', 'lin_cover', 'mod8')

# The exchanges, named from the class that gives up 10 points of the cell to the class that takes
# them. `contrast` is the matching contrast of the table of published values, whose difference is
# the albedo of the `to` class minus that of the `from` class.
EXCHANGES = data.frame(exchange = c('evergreen to summergreen', 'evergreen to open land', 'summergreen to open land'),
                       from = c('ET', 'ET', 'ST'), to = c('ST', 'OL', 'OL'), contrast = 1:3)
EXCHANGE_SIZE   = 2 * EXCHANGE_HALF_STEP   # 0.10 of the cell
STUDY_AREA      = 'Study area'
# Cells in which both exchanged classes cover at least 10 % are counted beside every result, not
# used to filter. This adapts one element of the filter of Lejeune et al. (2020, sect. 2.3.1, p.
# 1213), which joins low class fractions with a condition on the regression's error, after
# neighbourhood filters of its own; it is not their rule.
MIN_CLASS_SHARE = 0.10
PUBLISHED_FILE  = 'docs/cc/2026-11-10_published_albedo_contrasts.csv'
TABLE_LABELS    = c(all_days = 'all-days', snow_free = 'snow-free', snowy = 'snowy')

# --- The fit command ------------------------------------------------------------------------------

# What the fit command reads of a finished run, writing nothing into it: which albedo its
# calibration table holds, the table, each cell's area (script 7a's table, as the forcing weights
# cells) and, from the albedo build's cell table, the share of each cell-month's accepted
# retrievals flagged snow-free and snowy. The cell table is the repository's, so it is first shown
# to be the one the run's calibration table was made from.
read_run = function(run_dir, fill_missing = FALSE) {
  cfg = load_config(file.path(run_dir, 'config_used.R'), fill_missing)
  albedo = cfg$analysis$albedo
  if (albedo$source != 'modis_cells') stop('the exploration needs a run on the MODIS cell albedo, not ', albedo$source)
  paths = c(redirected_paths(run_dir), list(tag = ALBEDO_TAG))   # only names files; makes no folder in the run
  files = c(configuration = file.path(run_dir, 'config_used.R'),
            sapply(c('calibration_table', 'albedo_differences', 'albedo_modis_cells'), function(id) path_file(paths, id)))
  cal = readRDS(files[['calibration_table']])
  cell_table = utils::read.csv(files[['albedo_modis_cells']])
  rebuilt = column_by_month(cell_table, cal, paste0(albedo$version, ALBEDO_STATISTICS[[albedo$statistic]]))
  rebuilt[rebuilt == 0] = 1e-4                                   # script 2 lifts an exact zero for the beta model
  if (!isTRUE(all.equal(rebuilt, cal[, MONTHS], check.attributes = FALSE, tolerance = 0)))
    stop(files[['albedo_modis_cells']], ' is not the cell table this run\'s calibration table was made from')
  share = function(snow) column_by_month(cell_table, cal, paste0(albedo$version, '_share_', snow))
  list(table = albedo$statistic, cal = cal, files = files, domain = cfg$analysis$domain,
       area = area_of(cal, cell_areas(readRDS(files[['albedo_differences']]))),
       snowfree_share = share('snowfree'), snowy_share = share('snowy'))
}

# Which cells are in each region: the forcing's study area (its west and latitude limits, as
# scripts 7a and 8 apply them) and the six boxes of R/regions.R. Most cells of a box are in the
# study area too; the boxes reach a little beyond it in the south and the north.
region_members = function(cells, domain) {
  box = region_of(cells$x, cells$y)
  c(setNames(list(cells$x > domain$lon_min & cells$y > domain$lat_min & cells$y < domain$lat_max), STUDY_AREA),
    sapply(DIAGNOSTIC_REGIONS$region, function(region) box == region, simplify = FALSE))
}

# Every region and exchange of one month, before any fit, so that every version is described at
# the same cells: the eligible cells with their two endpoints and weights, and one row of what
# stands behind them. Eligible: a cell with albedo that month and an area, whose two endpoints are
# valid fractions inside the month's range of modern cover mixes over the whole continent (the
# hull of the cells the versions are fitted to). The range says the mix is familiar; it does not
# say that similar cells are nearby.
exchange_cases = function(run, month) {
  cal = run$cal
  fitted = complete_rows(cal, month)
  has_area = is.finite(run$area) & run$area > 0
  hull = training_hull(cal[fitted, ])
  members = region_members(cal, run$domain)
  cases = list()
  for (region in names(members)) {
    in_region = members[[region]] & has_area
    use = in_region & fitted
    for (i in seq_len(nrow(EXCHANGES))) {
      exchange = fixed_exchange(cal[use, ], run$area[use], gains = EXCHANGES$to[i], loses = EXCHANGES$from[i])
      exchange$support = exchange_support(exchange, hull)
      eligible = exchange_subset(exchange, 'inside')
      own = match(separation_cell_key(eligible$first), separation_cell_key(cal))   # the eligible cells' rows of the table
      both = cal[own, EXCHANGES$from[i]] >= MIN_CLASS_SHARE & cal[own, EXCHANGES$to[i]] >= MIN_CLASS_SHARE
      cases[[length(cases) + 1]] = list(exchange = eligible, support = data.frame(
        region = region, exchange = EXCHANGES$exchange[i], region_cells = sum(in_region), fitted_cells = sum(use),
        eligible_cells = length(own), area_share = sum(eligible$area) / sum(run$area[in_region]), cells_10pct = sum(both),
        snowfree_share = stats::median(run$snowfree_share[[month]][own]),
        snowy_share = stats::median(run$snowy_share[[month]][own])))
    }
  }
  cases
}

# One version fitted for one month. Not fitted where the table has fewer complete cells than the
# version has coefficients (the protocol's rule); that is reported, as a failed fit is.
fit_version = function(version, month, cal, fit_model) {
  cells = complete_model_rows(cal, month)
  if (cells < CV_COEFFICIENTS[[version]])
    return(list(fit = NULL, converged = NA, retries = NA_integer_, warnings = '', minutes = NA_real_,
                status = sprintf('not fitted: %d complete cells, fewer than its %d coefficients', cells, CV_COEFFICIENTS[[version]])))
  started = Sys.time()
  fitted = fit_model(version, month, cal)
  fitted$minutes = as.numeric(difftime(Sys.time(), started, units = 'mins'))
  fitted
}

# How unlike the eligible cells' own differences are: their area-weighted standard deviation about
# the regional mean (a spread across cells, as in Boisier et al. 2013, Table 2). Not an uncertainty
# of the mean, which is the standard error of exchange_contrast().
exchange_spread = function(fit, exchange) {
  if (!nrow(exchange$first)) return(NA_real_)
  difference = as.numeric(stats::predict(fit, exchange$second, type = 'response') -
                            stats::predict(fit, exchange$first, type = 'response'))
  sqrt(sum(exchange$weight * (difference - sum(exchange$weight * difference))^2))
}

# One version's rows for every region and exchange of the month. A version that was not fitted,
# failed or did not converge keeps its rows, without numbers.
version_rows = function(version, fitted, cases) {
  do.call(rbind, lapply(cases, function(case) {
    estimate = c(contrast = NA_real_, se = NA_real_)
    spread = NA_real_
    if (isTRUE(fitted$converged)) {
      estimate = exchange_contrast(fitted$fit, case$exchange)
      spread = exchange_spread(fitted$fit, case$exchange)
    }
    data.frame(version = version, location_k = CV_LOCATION_K[[version]], cover_form = CV_COVER_FORM[[version]],
               case$support, contrast = estimate[['contrast']], se = estimate[['se']], spread = spread,
               converged = fitted$converged, fit_status = fitted$status)
  }))
}

# One record per job: when, the code version, each input with its MD5 sum, the versions' terms and
# the packages, then any `extra` lines (the comparison's settings and times). `md5` can be given
# when the inputs were hashed earlier, as a timed step. code_version() watches R/, scripts/ and
# config.R for uncommitted changes, and any further file it is given: here this tool.
write_record = function(out_dir, job, files, extra = character(), md5 = tools::md5sum(files)) {
  code = code_version('tools/explore_cover_contrasts.R')
  packages = c('mgcv', 'sf')
  writeLines(c(paste('job:', job), paste('time:', format(Sys.time(), tz = 'UTC', usetz = TRUE)),
               paste('commit:', code$commit), paste('branch:', code$branch),
               paste('uncommitted changes in R/, scripts/, config.R or this tool:', code$dirty),
               paste('input', names(files), files, unname(md5)),
               paste('version', CONTRAST_VERSIONS, vapply(CONTRAST_VERSIONS, calibration_terms, '')),
               paste('package R', getRversion()),
               paste('package', packages, vapply(packages, function(p) as.character(utils::packageVersion(p)), '')),
               extra),
             file.path(out_dir, paste0('record_', job, '.txt')))
}

# The fit command, for a run as read_run() returns it. `fit_model` is the ordinary fitter (REML, one
# retry at a higher step limit if it has not converged); the tests pass a stand-in.
fit_months = function(run, out_dir, months, fit_model = fit_calibration_retry) {
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  for (month in months) {
    job = paste(run$table, month, sep = '_')
    cases = exchange_cases(run, month)
    saveRDS(cases, file.path(out_dir, sprintf('cases_%s.rds', job)))
    contrasts = fits = NULL
    for (version in CONTRAST_VERSIONS) {
      fitted = fit_version(version, month, run$cal, fit_model)
      cat(sprintf('%s %s %s: %.1f min; %s\n', run$table, month, version, fitted$minutes, fitted$status))
      if (!is.na(fitted$converged))                 # the fitter ran: keep what it returned, failed or not
        saveRDS(fitted, file.path(out_dir, sprintf('fit_%s_%s.rds', job, version)))
      contrasts = rbind(contrasts, version_rows(version, fitted, cases))
      fits = rbind(fits, data.frame(version = version, complete_cells = complete_model_rows(run$cal, month),
                                    coefficients = CV_COEFFICIENTS[[version]], converged = fitted$converged,
                                    retries = fitted$retries, minutes = fitted$minutes, status = fitted$status,
                                    warnings = fitted$warnings))
      rm(fitted); gc(verbose = FALSE)
    }
    utils::write.csv(cbind(table = run$table, month = month, contrasts), file.path(out_dir, sprintf('contrasts_%s.csv', job)), row.names = FALSE)
    utils::write.csv(cbind(table = run$table, month = month, fits), file.path(out_dir, sprintf('fits_%s.csv', job)), row.names = FALSE)
    write_record(out_dir, job, run$files)
  }
}

# --- The report command ---------------------------------------------------------------------------

CONTRASTS_HEADER = c(
  'Albedo change for a 10-point exchange of cover at the modern cells, as each fitted version predicts it',
  '(tools/explore_cover_contrasts.R; design: docs/cc/2026-11-10_cover_contrast_test_design_fable.md).',
  'A description of the fitted models, with no pass or fail. Positive is brighter.',
  'table: the albedo the versions were fitted to: all_days, snow_free or snowy retrievals of one albedo build.',
  'version, location_k, cover_form: the model (R/model_registry.R), the basis size of its location term, its cover term.',
  'exchange "A to B": predicted albedo with 5 points more of B and 5 fewer of A than the cell\'s own mix, minus predicted',
  '  albedo with 5 points more of A and 5 fewer of B; the third class, location and elevation are held.',
  'region_cells: the region\'s cells of the calibration table that have an area in script 7a\'s table.',
  'fitted_cells: those with albedo this month, the cells the versions were fitted to.',
  'eligible_cells: those whose two endpoints are valid fractions inside this month\'s continental range of cover mixes.',
  'area_share: area of the eligible cells / area of the region\'s cells: the share of the modern calibration cells\' area that',
  '  the result represents, not a share of the whole regional box.',
  'cells_10pct: eligible cells where both exchanged classes cover at least 10 % of the cell. Counted, not applied: it adapts',
  '  one element of the filter of Lejeune et al. (2020, sect. 2.3.1), which also has a condition on the regression\'s error.',
  'contrast: area-weighted mean of the predicted differences over the eligible cells.',
  'se: its standard error from the coefficient covariance, keeping the covariance between the two endpoints and between',
  '  cells. Approximate and conditional: it leaves out the uncertainty of the smoothing, spatial dependence, the cover',
  '  data and the choice of model. The figure shows contrast plus or minus 2 se.',
  'spread: area-weighted standard deviation of the cells\' own differences about the contrast: how unlike the cells are,',
  '  not an uncertainty.',
  'snowfree_share, snowy_share: median over the eligible cells of the share of this month\'s accepted retrievals that',
  '  were flagged snow-free and snowy (the albedo build\'s cell table).',
  'converged: TRUE; FALSE = the fit failed or did not converge; NA = not fitted. fit_status says which and why.',
  'The versions are fitted to the whole continent and evaluated at each region\'s cells.',
  'The eligible cells are the same for every version within a table, month, region and exchange. They differ between',
  'tables, months and exchanges, so a change of cells can look like a change of response. A result from one or three',
  'cells describes those cells, not the region.')

# A table with lines of explanation above it, each starting with "#": read it back with
# read.csv(comment.char = '#').
write_with_header = function(table, file, header) {
  connection = file(file, 'w')
  on.exit(close(connection))
  writeLines(paste('#', header), connection)
  utils::write.csv(table, connection, row.names = FALSE)
}

# The calendar months from `first` to `last`, through the year end if need be (dec to feb).
months_between = function(first, last) {
  i = match(first, MONTHS); j = match(last, MONTHS)
  MONTHS[if (i <= j) i:j else c(i:12, 1:j)]
}

# The published class differences that can be set on a month axis: a number read in its source,
# for one of the three contrasts, of broadband albedo, in one snow state, for calendar months.
# One row per value and month it covers, keeping the original classes, the kind of albedo and the
# table's qualification (a single day, annual means, an uncertain period), so that no value is
# read as more than it is. The rest of the table (values not read, single spectral bands, snow
# periods that are not calendar months) stays in the table only.
read_published = function(file = PUBLISHED_FILE) {
  rows = utils::read.csv(file)
  rows$difference = suppressWarnings(as.numeric(rows$difference_a_minus_b))   # "not read" and the like become missing
  usable = rows[is.finite(rows$difference) & rows$contrast %in% EXCHANGES$contrast & rows$broadband == 'yes' &
                  rows$snow %in% names(TABLE_LABELS) & rows$first_month %in% MONTHS & rows$last_month %in% MONTHS, ]
  by_month = do.call(rbind, lapply(seq_len(nrow(usable)), function(i) {
    months = months_between(usable$first_month[i], usable$last_month[i])
    data.frame(usable[rep(i, length(months)), c('source', 'locator', 'months', 'snow', 'difference', 'class_a', 'class_b',
                                                 'albedo_kind', 'qualification', 'beside_model')],
               source_region = usable$region[i],     # not `region`, which names the project's regions in the model's table
               exchange = EXCHANGES$exchange[match(usable$contrast[i], EXCHANGES$contrast)], month = months, row.names = NULL)
  }))
  attr(by_month, 'values') = c(in_table = nrow(rows), drawn = nrow(usable))
  by_month
}

# The published values set beside one albedo table's fits: those of its own snow state. Beside the
# all-days fits, only the snow-free values of June to September, the months the design names as
# comparable (section 3). That holds for the northeast, which then has no snowy retrievals, not
# for every region (in Alaska and Yukon most eligible cells have some in June), so the figure
# shows each month's snowy share of retrievals beside the all-days fits. Multiplied by the size of
# the exchange. Not the values the table marks as not for beside the model: a comparison with a
# mixed mosaic is not a complete change from forest to open land.
guide_for = function(published, table) {
  same_state = if (table == 'all_days') published$snow == 'snow_free' & published$month %in% c('jun', 'jul', 'aug', 'sep')
               else published$snow == table
  beside = same_state & published$beside_model == 'yes'
  data.frame(published[beside, ], guide = EXCHANGE_SIZE * published$difference[beside])
}

month_axis = function() ggplot2::scale_x_continuous(breaks = 1:12, labels = substr(month.abb, 1, 1), limits = c(0.5, 12.5))

# The share of retrievals shown under each panel: of the page's own snow state, and snowy beside
# the all-days fits, where it says how much of an all-days mean rests on snowy retrievals.
SHARE_SHOWN = c(all_days = 'snowy_share', snow_free = 'snowfree_share', snowy = 'snowy_share')

# A share as a percentage for the figure: whole numbers, one significant digit below 1 %.
percent = function(share) ifelse(is.na(share), '', ifelse(share > 0 & share < 0.01, sprintf('%.1g', 100 * share), sprintf('%.0f', 100 * share)))

# The pages of model results (one per albedo table, and the comparison with Duveiller et al.)
# share the next four pieces, so that they look alike.

# A panel per region and exchange, in the order of the rows, named with the region's calibration cells.
panels_of = function(rows) {
  panels = unique(rows[, c('region', 'exchange', 'region_cells')])
  panels$panel = sprintf('%s\n%s; %d calibration cells', panels$region, panels$exchange, panels$region_cells)
  panels$panel = factor(panels$panel, levels = panels$panel)
  panels
}

# The six versions against month: colour for the size of the location term, line type for the
# cover term, each month's value with plus or minus two standard errors, the versions side by side.
version_layers = function() {
  dodge = ggplot2::position_dodge(width = 0.6)
  list(ggplot2::geom_linerange(ggplot2::aes(ymin = contrast - 2 * se, ymax = contrast + 2 * se), position = dodge, alpha = 0.6, na.rm = TRUE),
       ggplot2::geom_line(ggplot2::aes(linetype = cover_form), position = dodge, na.rm = TRUE),
       ggplot2::geom_point(position = dodge, size = 0.9, na.rm = TRUE),
       ggplot2::scale_colour_manual('Location term, basis size', values = c('30' = '#D95F02', '100' = '#1B9E77', '500' = '#7570B3')),
       ggplot2::scale_linetype_manual('Cover term', values = c(linear = 'solid', tp200 = 'dashed'),
                                      labels = c(linear = 'straight lines', tp200 = 'thin plate, 200')))
}

# What stands behind each month's result, as three lines of text under each panel: the three
# `columns` of `rows` named, a count of cells and two shares (shown as percentages). These do not
# depend on the version, and the function stops if they do.
support_layer = function(rows, columns) {
  support = unique(rows[, c('panel', 'month', columns)])
  if (anyDuplicated(support[, c('panel', 'month')])) stop('the cells behind a result differ between versions')
  lines = list(as.character(support[[columns[1]]]), percent(support[[columns[2]]]), percent(support[[columns[3]]]))
  text = do.call(rbind, lapply(1:3, function(i) data.frame(support[, c('panel', 'month')], label = lines[[i]], vjust = -0.6 - 1.3 * (3 - i))))
  ggplot2::geom_text(ggplot2::aes(match(month, MONTHS), -Inf, label = label, vjust = vjust), text,
                     inherit.aes = FALSE, size = 1.9, colour = 'grey25')
}

# Three panels to a row, each with its own vertical scale and room under the lines for the support
# text, against the calendar months.
panel_layout = function() list(
  ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0.5, 0.05))),   # room for the text under the lines
  ggplot2::facet_wrap(~ panel, ncol = nrow(EXCHANGES), scales = 'free_y'), month_axis(),
  ggplot2::theme_bw(9), ggplot2::theme(legend.position = 'top'))

# One page: an albedo table's contrasts against month, a line per version with its interval, a
# panel per region and exchange, the published guide as grey ticks, and under each panel the
# support of each month's result: the eligible cells, their share of the area of the region's
# calibration cells, and the share of retrievals of SHARE_SHOWN.
plot_table = function(contrasts, guide, table) {
  panels = panels_of(contrasts)
  contrasts = merge(contrasts, panels)
  guide = merge(guide, panels[, c('exchange', 'panel')])   # by exchange: the same guide in every region's panel
  shown = c(snowy_share = 'snowy', snowfree_share = 'snow-free')[[SHARE_SHOWN[[table]]]]
  all_days = if (table == 'all_days') paste('\nBeside these all-days fits only snow-free published values of June to September are drawn: the northeast has no snowy',
    'retrievals then, but other regions can (Alaska and Yukon among them): see the third line under each panel.') else ''
  ggplot2::ggplot(contrasts, ggplot2::aes(match(month, MONTHS), contrast, colour = factor(location_k), group = version)) +
    ggplot2::geom_hline(yintercept = 0, colour = 'grey60') +
    ggplot2::geom_segment(ggplot2::aes(x = match(month, MONTHS) - 0.4, xend = match(month, MONTHS) + 0.4, y = guide, yend = guide),
                          guide, inherit.aes = FALSE, colour = 'grey45', linewidth = 0.5) +
    ggplot2::geom_point(ggplot2::aes(match(month, MONTHS), guide), guide[guide$qualification != '', ],   # see the published page
                        inherit.aes = FALSE, colour = 'grey30', shape = 1, size = 1.2) +
    version_layers() +
    support_layer(contrasts, c('eligible_cells', 'area_share', SHARE_SHOWN[[table]])) +
    panel_layout() +
    ggplot2::labs(x = 'Month', y = 'Albedo change for a 10-point exchange of cover (positive: brighter)',
      title = sprintf('Fitted response to a 10-point exchange of cover: versions fitted to %s albedo', TABLE_LABELS[[table]]),
      caption = paste0('Lines: each version\'s predicted change, the area-weighted mean over the eligible cells. Bars: plus or minus two standard errors, ',
        'approximate and conditional on the fitted model.\nThe versions are fitted to the whole continent and evaluated at each region\'s cells. ',
        'Vertical scales differ between panels.\nGrey ticks: published differences between whole classes multiplied by 0.10 ',
        '("ideal linear mixing"): a guide for the eye, not a measurement, at the months each was published for. The same published values are ',
        'repeated\nin every region\'s panel, wherever they were measured. A circle marks one with a qualification (a single day; a period the source ',
        'does not state exactly): see the last page.', all_days,
        '\nUnder each panel, by month, the same for every version: the eligible cells; their share (%) of the area of the region\'s modern ',
        'calibration cells (not of the whole box);\nthe median share (%) of the month\'s accepted retrievals at those cells that were flagged ', shown,
        '. A result from a few cells describes those cells, not the region. No pass or fail is implied.'))
}

# The last page: the published differences themselves, in their own units and months. The shape
# of each mark gives the table's qualification. An annual value is one line across the year, so
# that it cannot be read as twelve monthly observations.
plot_published = function(published) {
  values = attr(published, 'values')
  snow = c(snow_free = 'snow-free', snowy = 'snow-covered', all_days = 'all conditions')
  published$panel = paste(published$exchange, snow[published$snow], sep = '\n')
  published$panel = factor(published$panel, levels = paste(rep(EXCHANGES$exchange, times = 3), rep(snow, each = 3), sep = '\n'))
  published$qualification[published$qualification == ''] = 'none recorded: a mean over the months shown'
  annual = published$months == 'annual'
  ticks = published[!annual, ]
  annual = unique(published[annual, setdiff(names(published), 'month')])
  ggplot2::ggplot(ticks, ggplot2::aes(colour = source)) +
    ggplot2::geom_hline(yintercept = 0, colour = 'grey60') +
    ggplot2::geom_segment(ggplot2::aes(x = match(month, MONTHS) - 0.4, xend = match(month, MONTHS) + 0.4, y = difference, yend = difference), linewidth = 0.7) +
    ggplot2::geom_point(ggplot2::aes(match(month, MONTHS), difference, shape = qualification), size = 1.8) +
    ggplot2::geom_segment(ggplot2::aes(x = 0.6, xend = 12.4, y = difference, yend = difference), annual, linewidth = 0.7) +
    ggplot2::geom_point(ggplot2::aes(6.5, difference, shape = qualification), annual, size = 1.8) +
    ggplot2::facet_wrap(~ panel, ncol = nrow(EXCHANGES), scales = 'free_y', drop = FALSE) + month_axis() +
    ggplot2::theme_bw(9) + ggplot2::theme(legend.position = 'top', legend.box = 'vertical') +
    ggplot2::guides(shape = ggplot2::guide_legend(ncol = 1)) +   # the qualifications are long
    ggplot2::labs(x = 'Month', y = 'Published albedo difference between two whole classes', colour = NULL, shape = 'Qualification',
      title = 'Published albedo differences between cover classes, in each source\'s own kind of albedo and months',
      subtitle = paste('"A to B" is the published albedo of class B minus that of class A. A value is drawn at every month of the period it was published for;',
                       'an annual value is one line across the year.'),
      caption = paste(sprintf('%d of the %d rows of %s are drawn; the others were not read, are single spectral bands, or are for periods that are not calendar months.',
          values[['drawn']], values[['in_table']], PUBLISHED_FILE),
        'The two comparisons with a mosaic of crops, forest, grass and shrub (Burakowski 2015) are on this page only, not beside the model: they are not a complete',
        'change from forest to open land.',
        'These are classes, sites or neighbouring pairs; the model pages show a response around mixed one-degree cells. Summergreen there includes larch and shrubs,',
        'and open land mixes crops, grass, tundra and bare ground. Some sources use the same MODIS observations as the project: independently published,',
        'not wholly independent. Their spreads and the model\'s standard errors measure different things. The project\'s albedo is the monthly mean of',
        'local-noon blue-sky albedo; the sources use tower radiation totals, blue-sky, white-sky or black-sky albedo (the table\'s albedo_kind column).', sep = '\n'))
}

# The report command: no fits.
report = function(out_dir) {
  read_all = function(pattern) {
    files = Sys.glob(file.path(out_dir, pattern))
    if (!length(files)) stop('no ', pattern, ' in ', out_dir, ': run the fit command first')
    do.call(rbind, lapply(files, utils::read.csv))
  }
  in_order = function(rows) rows[order(match(rows$table, names(TABLE_LABELS)), match(rows$month, MONTHS)), ]   # tables, then calendar months
  contrasts = in_order(read_all('contrasts_*.csv'))
  fits = in_order(read_all('fits_*.csv'))
  published = read_published()
  tables = unique(contrasts$table)
  write_with_header(contrasts, file.path(out_dir, 'cover_contrasts.csv'), CONTRASTS_HEADER)
  utils::write.csv(fits, file.path(out_dir, 'fits.csv'), row.names = FALSE)
  guides = lapply(tables, function(table) { guide = guide_for(published, table); data.frame(beside_table = rep(table, nrow(guide)), guide) })
  utils::write.csv(do.call(rbind, guides), file.path(out_dir, 'published_guide.csv'), row.names = FALSE)
  grDevices::pdf(file.path(out_dir, 'cover_contrasts.pdf'), width = 12, height = 17)
  for (table in tables) print(plot_table(contrasts[contrasts$table == table, ], guide_for(published, table), table))
  print(plot_published(published))
  grDevices::dev.off()
  stacked = Sys.glob(file.path(out_dir, 'contrasts_*.csv'))
  write_record(out_dir, 'report', c(published_values = PUBLISHED_FILE, setNames(stacked, basename(stacked))))
  fits$fit = ifelse(is.na(fits$converged), 'not fitted', ifelse(fits$converged, 'converged', 'failed or not converged'))
  print(stats::xtabs(~ table + fit, fits))
}

# --- The duveiller command ------------------------------------------------------------------------
# Design: docs/cc/2026-11-16_duveiller_comparison_design_codex_gpt6astra.md. Chris's decisions
# (docs/cc/2026-11-17_duveiller_comparison_decisions.md): all three exchanges, and no summary of
# the published uncertainties for now.

# The transitions of Duveiller et al. (2018) set beside the three exchanges, and the sign that turns
# each into the exchange's direction: needleleaf evergreen to broadleaf deciduous forest, which the
# file holds the other way round (transition 23, broadleaf deciduous to needleleaf evergreen), so
# its sign is reversed; needleleaf evergreen forest to grassland (38); broadleaf deciduous forest to
# grassland (28). Codes and reversal: Duveiller, Hooker & Cescatti (2018), Scientific Data 5,
# 180014, p. 11. The analogues are approximate: summergreen includes larch and shrubs, and
# grassland stands for open land.
DUVEILLER_TRANSITIONS = data.frame(exchange = EXCHANGES$exchange, transition = c(23, 38, 28), sign = c(-1, 1, 1))
# A published one-degree estimate rests on at least 20 samples (the method's own rule). The file is
# checked for it; nothing is filtered by it.
DUVEILLER_MIN_SAMPLES = 20

DUVEILLER_HEADER = c(
  'Albedo change for a 10-point exchange of cover on the same cells: as each fitted version predicts it, and as Duveiller et al. (2018)',
  'published it (tools/explore_cover_contrasts.R duveiller; design: docs/cc/2026-11-16_duveiller_comparison_design_codex_gpt6astra.md).',
  'A comparison of seasonal responses on the cells both cover: no pass or fail, and no effect on the choice of model. Positive is brighter.',
  'The versions are the saved all-days fits behind cover_contrasts.csv, not refitted. A row per month, version, region and exchange.',
  'month, version, location_k, cover_form, region, exchange, region_cells: as in cover_contrasts.csv.',
  'eligible_cells: the cells of the saved all-days result for this month, region and exchange.',
  'common_cells, common_area_m2: those with a published estimate (a finite Delta_albedo) for this month and the matched transition, and their area.',
  'share_of_eligible_area: common area / eligible area: how much of the saved result is compared.',
  'share_of_region_area: common area / area of the region\'s calibration cells: how much of the region\'s calibration support is represented.',
  '  The first is missing where there are no eligible cells, the second only for a region without calibration cells.',
  'min_samples, max_samples: the fewest and most published samples (N_Delta_albedo) behind the estimates of the common cells.',
  'duveiller_contrast: the published change for the matched transition, times 0.10 (the size of the exchange), area-weighted over the common',
  '  cells. Evergreen to summergreen is set beside needleleaf evergreen to broadleaf deciduous forest (the file holds transition 23, the other',
  '  way round, so its sign is reversed); evergreen to open land beside needleleaf evergreen forest to grassland (38); summergreen to open land',
  '  beside broadleaf deciduous forest to grassland (28). The 0.10 is a linear-mixing reference, not a claim that the model responds linearly.',
  'contrast, se, spread: the version\'s area-weighted mean predicted change over the same common cells with the same weights, its standard',
  '  error and the spread of the cells\' own changes, as in cover_contrasts.csv. Missing where there are no common cells.',
  'converged, fit_status: of the saved fit.',
  'Not the same quantity: the project\'s albedo is the 2000-2009 monthly blue-sky climatology; Duveiller et al.\'s is the mean of black- and',
  '  white-sky albedo, calendar-month medians over 2008-2012 of retrievals near mid-month. The classes match only approximately (summergreen',
  '  includes larch and shrubs; grassland stands for open land). Their one-degree values summarise local transitions, not the conversion of',
  '  a whole cell. Both rest on MODIS observations. The common cells can change from month to month.',
  'Agreement in sign, seasonal timing and broad magnitude would show consistency on these cells; disagreement marks a response to examine,',
  '  without saying which estimate is wrong. Neither shows how the model behaves under Holocene climates or ice sheets.',
  'The published uncertainties (SD_Delta_albedo) are not summarised here (Chris, 16 November 2026); they stay in the source file.')

# The published file's layout, checked before anything is read from it: R shows its variables'
# dimensions as lon, lat, mon, iTr (the reverse of their order on disk), and its grid must be a
# one-degree grid (each coordinate unique and one degree from the next, within the globe).
check_duveiller_file = function(nc) {
  for (variable in c('Delta_albedo', 'N_Delta_albedo')) {
    dims = vapply(nc$var[[variable]]$dim, function(d) d$name, '')
    if (!identical(dims, c('lon', 'lat', 'mon', 'iTr')))
      stop(nc$filename, ': expected ', variable, ' with the dimensions lon, lat, mon, iTr; found ', paste(dims, collapse = ', '))
  }
  one_degree = function(values, limit) !anyDuplicated(values) && all(abs(diff(values)) == 1) && all(abs(values) < limit)
  if (!one_degree(nc$dim$lon$vals, 180) || !one_degree(nc$dim$lat$vals, 90))
    stop(nc$filename, ': its longitudes and latitudes are not a one-degree grid')
}

# One month of the three transitions, as matrices of longitude by latitude: the published change
# for a complete transition, turned to the exchange's direction and multiplied by the size of the
# exchange (0.10: the fraction converted times the complete-transition value, Lejeune et al. 2020,
# eq. 11), and the number of samples behind it. Months and transitions are looked up by their
# coordinate values, not their positions. Only a finite Delta_albedo is an estimate (the file keeps
# some counts where the estimate is missing); an estimate of exactly zero is kept.
read_duveiller_month = function(nc, month) {
  position = function(dim, value) {
    found = match(value, nc$dim[[dim]]$vals)
    if (is.na(found)) stop(nc$filename, ' has no ', dim, ' ', value)
    found
  }
  layers = list()
  for (i in seq_len(nrow(DUVEILLER_TRANSITIONS))) {
    transition = DUVEILLER_TRANSITIONS$transition[i]
    start = c(1, 1, position('mon', match(month, MONTHS)), position('iTr', transition))
    read = function(variable) ncdf4::ncvar_get(nc, variable, start = start, count = c(-1, -1, 1, 1))
    change = read('Delta_albedo')
    samples = read('N_Delta_albedo')
    if (any(is.finite(change) & !(is.finite(samples) & samples >= DUVEILLER_MIN_SAMPLES)))
      stop(sprintf('%s, transition %g, %s: an estimate without %d samples behind it', nc$filename, transition, month, DUVEILLER_MIN_SAMPLES))
    layers[[DUVEILLER_TRANSITIONS$exchange[i]]] = list(change = EXCHANGE_SIZE * DUVEILLER_TRANSITIONS$sign[i] * change, samples = samples)
  }
  layers
}

# The place of each cell in the published grid, by exact centre: no interpolation and no nearest
# neighbour. Stops, naming a cell, if any centre is not one of the grid's.
grid_index = function(nc, cells) {
  index = cbind(match(cells$x, nc$dim$lon$vals), match(cells$y, nc$dim$lat$vals))
  off = which(is.na(index[, 1]) | is.na(index[, 2]))
  if (length(off)) stop(sprintf('%d cell centres, among them %g E %g N, are not centres of the grid of %s: the grids do not line up',
                                length(off), cells$x[off[1]], cells$y[off[1]], nc$filename))
  index
}

# The saved cases of one month restricted to their cells with a published estimate, and the
# published mean there. Both endpoints and the areas are subset alike and the weights renormalised
# over the common cells (freeze_exchange), so that the published mean and every version's mean
# have the same cells and weights. A case without common cells keeps its row, without means. The
# saved snow shares describe the saved cells, not the common ones, and are left behind.
duveiller_cases = function(cases, layers, nc) {
  lapply(cases, function(case) {
    saved = case$exchange
    k = match(case$support$exchange, EXCHANGES$exchange)
    cell = grid_index(nc, saved$first)
    change = layers[[case$support$exchange]]$change[cell]
    samples = layers[[case$support$exchange]]$samples[cell]
    common = is.finite(change)
    matched = freeze_exchange(saved$first[common, ], saved$second[common, ], saved$area[common],
                              held = held_class(EXCHANGES$to[k], EXCHANGES$from[k]))
    if (matched$exclusions$excluded > 0) stop('a saved exchange lost cells when restricted to the common cells')
    eligible_area = sum(saved$area)
    share = if (eligible_area > 0) sum(matched$area) / eligible_area else NA_real_
    # Of the region's calibration area: the saved share times the part kept; none of it where no cell
    # was eligible (Alaska and Yukon in December), and missing only for a region without calibration cells.
    region_share = if (eligible_area > 0) case$support$area_share * share else if (case$support$region_cells > 0) 0 else NA_real_
    some = any(common)
    list(exchange = matched, support = data.frame(
      region = case$support$region, exchange = case$support$exchange, region_cells = case$support$region_cells,
      eligible_cells = case$support$eligible_cells, common_cells = sum(common), common_area_m2 = sum(matched$area),
      share_of_eligible_area = share, share_of_region_area = region_share,
      min_samples = if (some) min(samples[common]) else NA_real_, max_samples = if (some) max(samples[common]) else NA_real_,
      duveiller_contrast = if (some) sum(matched$weight * change[common]) else NA_real_))
  })
}

# The fit status of the saved all-days job, a row per month and version, with the file of each
# saved fit: there must be one exactly where the fitter ran (converged TRUE or FALSE, not NA).
read_fit_status = function(saved_dir) {
  status = do.call(rbind, lapply(MONTHS, function(month) utils::read.csv(file.path(saved_dir, sprintf('fits_all_days_%s.csv', month)))))
  if (!identical(paste(status$month, status$version), paste(rep(MONTHS, each = length(CONTRAST_VERSIONS)), CONTRAST_VERSIONS)))
    stop(saved_dir, ': its fit status tables do not hold the six versions for every month')
  status$file = file.path(saved_dir, sprintf('fit_all_days_%s_%s.rds', status$month, status$version))
  wrong = file.exists(status$file) != !is.na(status$converged)
  if (any(wrong)) stop('the saved fits do not match their status tables: ', paste(basename(status$file[wrong]), collapse = ', '))
  status
}

# One version's saved fit for one month, as its row of the status table describes it.
saved_fit = function(row) {
  if (is.na(row$converged)) return(list(fit = NULL, converged = NA, status = row$status))
  fitted = readRDS(row$file)
  if (!identical(fitted$converged, row$converged) || !identical(fitted$status, row$status))
    stop(row$file, ' is not the fit its status table describes')
  fitted
}

# The comparison's page: each version's change on the common cells, drawn as on the pages of the
# report command, and the published mean on the same cells as a black diamond. Both come from the
# same rows, so they are joined by region, month and exchange. Under each panel, by month: the
# common cells, their share of the eligible cells' area and of the area of the region's
# calibration cells.
plot_duveiller = function(rows) {
  rows = merge(rows, panels_of(rows))
  published = unique(rows[, c('panel', 'month', 'duveiller_contrast')])
  if (anyDuplicated(published[, c('panel', 'month')])) stop('the published means differ between versions')
  ggplot2::ggplot(rows, ggplot2::aes(match(month, MONTHS), contrast, colour = factor(location_k), group = version)) +
    ggplot2::geom_hline(yintercept = 0, colour = 'grey60') +
    version_layers() +
    ggplot2::geom_point(ggplot2::aes(match(month, MONTHS), duveiller_contrast, shape = 'Duveiller et al. (2018), times 0.10'),
                        published, inherit.aes = FALSE, colour = 'black', size = 2.2, na.rm = TRUE) +
    ggplot2::scale_shape_manual('Published, on the same cells', values = 18) +
    support_layer(rows, c('common_cells', 'share_of_eligible_area', 'share_of_region_area')) +
    panel_layout() +
    ggplot2::labs(x = 'Month', y = 'Albedo change for a 10-point exchange of cover (positive: brighter)',
      title = 'Fitted response beside Duveiller et al. (2018), on the cells both cover: versions fitted to all-days albedo',
      caption = paste(sep = '\n',
        'Lines and bars: each version\'s predicted change, the area-weighted mean over the common cells, plus or minus two standard errors (approximate and conditional on',
        'the fitted model). The saved all-days fits of the exploration, not refitted: fitted to the whole continent and evaluated at each region\'s cells. Vertical scales differ.',
        'Black diamonds: the published change of Duveiller et al. (2018) for the nearest of their transitions, times 0.10, averaged over the same cells with the same area',
        'weights: needleleaf evergreen to broadleaf deciduous forest (their transition 23, reversed), needleleaf evergreen forest to grassland (38), broadleaf deciduous',
        'forest to grassland (28). Common cells: the cells of the model\'s result with a published estimate that month; they can change from month to month.',
        'Under each panel, by month: the common cells; their share (%) of the area of the model\'s eligible cells; their share (%) of the area of the region\'s calibration cells.',
        'Not the same quantity: the project\'s albedo is the 2000-2009 monthly blue-sky climatology; Duveiller et al.\'s is the mean of black- and white-sky albedo,',
        'calendar-month medians over 2008-2012 of retrievals near mid-month. The classes match only approximately (summergreen includes larch and shrubs; grassland stands',
        'for open land). Their one-degree values summarise local transitions, not the conversion of a whole cell. Both rest on MODIS observations. The 0.10 is a linear-mixing',
        'reference, not a claim that the model responds linearly. Agreement in sign, seasonal timing and broad magnitude would show consistency on these cells; disagreement',
        'marks a response to examine, without saying which estimate is wrong. Neither shows how the model behaves under Holocene climates or ice sheets. No pass or fail.',
        'The published uncertainties are not summarised here.'))
}

# The duveiller command: the all-days cases and fits that the fit command saved in `saved_dir`
# (all twelve months; nothing is refitted) beside the published file, on the cells both cover.
# Writes the table, its page and a record, with the time each step took, into `out_dir`. One saved
# fit is in memory at a time.
compare_duveiller = function(saved_dir, source_file, out_dir) {
  started = Sys.time()
  seconds = function(since) as.numeric(difftime(Sys.time(), since, units = 'secs'))
  nc = ncdf4::nc_open(source_file)
  on.exit(ncdf4::nc_close(nc))
  check_duveiller_file(nc)
  status = read_fit_status(saved_dir)
  case_files = file.path(saved_dir, sprintf('cases_all_days_%s.rds', MONTHS))
  files = c(source_file, case_files, file.path(saved_dir, sprintf('fits_all_days_%s.csv', MONTHS)), status$file[!is.na(status$converged)])
  names(files) = c('published_change', basename(files[-1]))
  md5 = tools::md5sum(files)
  cases = lapply(setNames(seq_along(MONTHS), MONTHS), function(i) duveiller_cases(readRDS(case_files[i]), read_duveiller_month(nc, MONTHS[i]), nc))
  times = c('hashing and reading the inputs' = seconds(started))

  step = Sys.time()
  rows = NULL
  for (i in seq_len(nrow(status))) {
    fitted = saved_fit(status[i, ])
    rows = rbind(rows, data.frame(month = status$month[i], version_rows(status$version[i], fitted, cases[[status$month[i]]])))
    rm(fitted); gc(verbose = FALSE)
  }
  times['recomputing the six versions on the common cells'] = seconds(step)

  step = Sys.time()
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  write_with_header(rows, file.path(out_dir, 'cover_contrasts_duveiller.csv'), DUVEILLER_HEADER)
  grDevices::pdf(file.path(out_dir, 'cover_contrasts_duveiller.pdf'), width = 12, height = 17)
  print(plot_duveiller(rows))
  grDevices::dev.off()
  times['writing the table and the figure'] = seconds(step)
  times['whole command'] = seconds(started)
  write_record(out_dir, 'duveiller', files, md5 = md5, extra = c(
    'comparison: the saved all-days cases and fits, not refitted, beside the published change in albedo of Duveiller et al. (2018)',
    sprintf('transition: %s beside transition %g, sign %+d', DUVEILLER_TRANSITIONS$exchange, DUVEILLER_TRANSITIONS$transition, DUVEILLER_TRANSITIONS$sign),
    'scale: the published change times 0.10, the size of the exchange; the versions\' changes are not scaled',
    'matching: exact one-degree cell centres; common cells: the saved eligible cells with a finite Delta_albedo for the month and transition',
    'weights: the saved cell areas renormalised over the common cells, the same for the published mean and every version',
    'not reported: SD_Delta_albedo (Chris, 16 November 2026: no summary of the published uncertainties for now)',
    paste('package ncdf4', utils::packageVersion('ncdf4')),
    sprintf('time %s: %.1f s', names(times), times)))
  cat(sprintf('%d rows; %s\n', nrow(rows), paste(sprintf('%s %.1f s', names(times), times), collapse = '; ')))
}

if (sys.nframe() == 0L) {
  command = tool_command_line()
  args = command$args
  if (length(args) >= 4 && args[1] == 'fit') {
    suppressPackageStartupMessages(library(mgcv))
    fit_months(read_run(args[2], command$fill_missing), args[3], check_months(args[-(1:3)]))
  } else if (length(args) == 2 && args[1] == 'report') {
    report(args[2])
  } else if (length(args) == 4 && args[1] == 'duveiller') {
    suppressPackageStartupMessages(library(mgcv))   # the saved fits are mgcv models
    compare_duveiller(args[2], args[3], args[4])
  } else {
    cat('usage: Rscript tools/explore_cover_contrasts.R fit <run-dir> <output-dir> <month> [<month> ...] [--fill-missing] | report <output-dir>',
        '| duveiller <saved-contrast-dir> <netcdf-file> <output-dir>\n')
    quit(status = 2)
  }
}
