# Checks of the cover-contrast exploration (tools/explore_cover_contrasts.R) on real data, for its
# verification spec. They check the implementation, not the science: no result is judged.
#
#   Rscript tools/check_cover_contrasts.R inputs <all-days-run> <snow-free-run> <snowy-run>
#       The three finished runs the exploration reads are the ones traced in the implementation
#       note (section 4): each file has its recorded MD5 sum, the repository's cell table
#       reproduces each calibration table, and the three tables hold the same cells, cover,
#       elevation and cell areas; only the albedo differs. Add --fill-missing for runs saved before
#       a setting existed (load_config() in R/config.R).
#   Rscript tools/check_cover_contrasts.R exchanges <protocol-2-run>
#       Protocol 2's own northeast exchanges (April and May, fixed and historical), rebuilt with
#       the generalised helpers of R/cv_separation.R, are identical to those it froze.
#   Rscript tools/check_cover_contrasts.R job <output-dir>
#       The fit and report commands' output for the snowy table's July and August: the expected
#       records, rows and support, a few numbers, and one saved fit that gives its numbers back.
#
# Paths are relative to the repository root or absolute. Nothing is written.

suppressMessages(source('tools/explore_cover_contrasts.R'))
suppressPackageStartupMessages(library(mgcv))

# --- inputs ---------------------------------------------------------------------------------------

# The MD5 sums the trial of 15 November recorded for each file read_run() reads.
INPUT_MD5 = list(
  all_days  = c(configuration = '7166904d1dc1fd19a9650253bfc1be4a', calibration_table = '67f258c3a2d97f729bb7139ae4940fc5',
                albedo_differences = '2b7136049712ec99f38272edfc436719', albedo_modis_cells = 'd73c54cca47b864284e430f87ef9ce3f'),
  snow_free = c(configuration = '5e07cee49897eac1a83a477a09fdcc3e', calibration_table = '0e67a3d38ee2af12c08ab1b2e78d5928',
                albedo_differences = '9c23799b08379eae7b5f5d080f3b5836', albedo_modis_cells = 'd73c54cca47b864284e430f87ef9ce3f'),
  snowy     = c(configuration = 'c547a726297bc6cb9f2298c7c763fbc8', calibration_table = 'c907790dc87b5b9d2a1c171550557b60',
                albedo_differences = 'e1b6124d758c00d42576d1a6c76f1ef3', albedo_modis_cells = 'd73c54cca47b864284e430f87ef9ce3f'))

check_inputs = function(run_dirs, fill_missing = FALSE) {
  runs = lapply(setNames(run_dirs, names(INPUT_MD5)), read_run, fill_missing)   # read_run stops unless the cell table reproduces the run's table
  same = function(a, b) isTRUE(all.equal(a, b, check.attributes = FALSE, tolerance = 0))
  cover = c('x', 'y', 'elev', 'OL', 'ET', 'ST')
  for (table in names(runs)) {
    run = runs[[table]]
    md5 = unname(tools::md5sum(run$files[names(INPUT_MD5[[table]])]))
    cat(sprintf('%-9s table %-9s MD5 sums as recorded: %s; same cells, cover, elevation and areas as all days: %s\n', table, run$table,
                identical(md5, unname(INPUT_MD5[[table]])), same(run$cal[, cover], runs$all_days$cal[, cover]) && same(run$area, runs$all_days$area)))
    stopifnot(run$table == table, identical(md5, unname(INPUT_MD5[[table]])),
              same(run$cal[, cover], runs$all_days$cal[, cover]), same(run$area, runs$all_days$area))
  }
  stopifnot(nrow(runs$all_days$cal) == 2812, sum(is.finite(runs$all_days$area)) == 2808)
  cat('The three inputs are those traced; 2,812 calibration cells, 2,808 with an area.\n')
}

# --- exchanges ------------------------------------------------------------------------------------

check_exchanges = function(run) {
  frozen = readRDS(file.path(run, 'output/cross_validation_v2/separation/frozen.rds'))
  paths = c(redirected_paths(run), list(tag = ALBEDO_TAG))
  areas = cell_areas(readRDS(path_file(paths, 'albedo_differences')))
  paleo = readRDS(path_file(paths, 'lct_paleo'))
  cal = frozen$cal
  past_cells = paleo[paleo$ages == 6000 & separation_northeast(paleo), c('x', 'y', 'elev')]
  historical = historical_exchange(past_cells, paleo, area_of(past_cells, areas))
  for (month in c('apr', 'may')) {
    rows = cal[complete_rows(cal, month), ]
    hull = training_hull(rows)
    modern = rows[separation_northeast(rows), ]
    now = list(fixed = fixed_exchange(modern, area_of(modern, areas)), historical = historical)
    for (name in names(now)) {
      now[[name]]$support = exchange_support(now[[name]], hull)
      cat(sprintf('%s %-10s identical to the frozen exchange: %s\n', month, name, identical(now[[name]], frozen$months[[month]]$exchanges[[name]])))
      stopifnot(identical(now[[name]], frozen$months[[month]]$exchanges[[name]]))
    }
  }
  cat('All four exchanges of protocol 2 are reproduced bit for bit.\n')
}

# --- job ------------------------------------------------------------------------------------------

# What stands behind the snowy table's July and August results in three regions, as the trial of
# 15 November and Astra's independent count (review of 15 November, finding 3) found it.
SNOWY_SUPPORT = data.frame(
  month          = rep(c('jul', 'aug'), each = 9),
  region         = rep(rep(c(STUDY_AREA, 'Northeast (hemlock box)', 'Alaska / Yukon'), each = 3), 2),
  exchange       = rep(EXCHANGES$exchange, 6),
  region_cells   = rep(rep(c(2623, 83, 445), each = 3), 2),
  fitted_cells   = rep(c(388, 0, 80, 279, 0, 121), each = 3),
  eligible_cells = c(123, 140, 225, 0, 0, 0, 45, 41, 41, 109, 101, 153, 0, 0, 0, 74, 75, 72),
  cells_10pct    = c(119, 122, 225, 0, 0, 0, 45, 41, 41, 108, 95, 153, 0, 0, 0, 74, 75, 72),
  area_share     = c(0.03763893, 0.04020164, 0.05658993, 0, 0, 0, 0.10732837, 0.09422826, 0.09227676,
                     0.03276667, 0.02750197, 0.03759456, 0, 0, 0, 0.16898647, 0.16401939, 0.15549832),
  snowy_share    = c(0.0008990, 0.0015105, 0.0037880, NA, NA, NA, 0.0065940, 0.0057950, 0.0037880,
                     0.0007410, 0.0013560, 0.0028440, NA, NA, NA, 0.0012150, 0.0010960, 0.0012535))

# Three results of the trial of 15 November (snowy, July, study area, location 30 with straight-line
# cover). A refit at the same code reproduces them to rounding; the tolerances allow for another
# linear algebra library, and are far below the standard errors.
SNOWY_RESULTS = data.frame(exchange = EXCHANGES$exchange,
                           contrast = c(-0.037102282184, -0.006146395338, 0.031727830304),
                           se       = c(0.01061128941, 0.00741295250, 0.01058519956))
CONTRAST_TOLERANCE = 1e-6    # absolute
SE_TOLERANCE       = 1e-3    # relative

check_job = function(out_dir) {
  contrasts = utils::read.csv(file.path(out_dir, 'cover_contrasts.csv'), comment.char = '#')
  fits = utils::read.csv(file.path(out_dir, 'fits.csv'))
  key = c('table', 'month', 'version', 'region', 'exchange')
  fitted = paste(fits$month, fits$version)[fits$converged %in% TRUE]
  not_fitted = c('lin_cover', 'mod8')
  stopifnot(nrow(fits) == 12, all(fits$table == 'snowy'), sum(fits$converged %in% TRUE) == 8,
            all(is.na(fits$converged[fits$version %in% not_fitted])), all(grepl('^not fitted', fits$status[fits$version %in% not_fitted])),
            nrow(contrasts) == 252, !anyDuplicated(contrasts[, key]), all(contrasts$table == 'snowy'))
  cat('12 fit records (8 converged, 4 not fitted); 252 uniquely identified contrast rows.\n')

  # The support of a result does not depend on the version.
  support = c('region_cells', 'fitted_cells', 'eligible_cells', 'area_share', 'cells_10pct', 'snowfree_share', 'snowy_share')
  per_case = unique(contrasts[, c('month', 'region', 'exchange', support)])
  stopifnot(nrow(per_case) == 2 * 7 * 3)
  # Numbers where a converged fit has eligible cells, none elsewhere.
  expect = paste(contrasts$month, contrasts$version) %in% fitted & contrasts$eligible_cells > 0
  stopifnot(all(is.finite(contrasts$contrast[expect]) & is.finite(contrasts$se[expect]) & contrasts$se[expect] > 0),
            all(is.na(contrasts$contrast[!expect]) & is.na(contrasts$se[!expect])))
  cat(sprintf('Support the same for every version; %d rows with numbers, %d without, as expected.\n', sum(expect), sum(!expect)))

  found = merge(SNOWY_SUPPORT[, c('month', 'region', 'exchange')], per_case, sort = FALSE)
  found = found[match(paste(SNOWY_SUPPORT$month, SNOWY_SUPPORT$region, SNOWY_SUPPORT$exchange),
                      paste(found$month, found$region, found$exchange)), ]
  for (column in c('region_cells', 'fitted_cells', 'eligible_cells', 'cells_10pct')) stopifnot(identical(as.numeric(found[[column]]), SNOWY_SUPPORT[[column]]))
  stopifnot(all(abs(found$area_share - SNOWY_SUPPORT$area_share) < 1e-8),
            identical(is.na(found$snowy_share), is.na(SNOWY_SUPPORT$snowy_share)),
            all(abs(found$snowy_share - SNOWY_SUPPORT$snowy_share) < 1e-7, na.rm = TRUE))
  cat('The known support counts and shares of the study area, the northeast and Alaska / Yukon are reproduced.\n')

  rows = contrasts[contrasts$month == 'jul' & contrasts$region == STUDY_AREA & contrasts$version == 'loc30_linear', ]
  rows = rows[match(SNOWY_RESULTS$exchange, rows$exchange), ]
  print(data.frame(rows[, c('exchange', 'contrast', 'se')], trial_contrast = SNOWY_RESULTS$contrast, trial_se = SNOWY_RESULTS$se), row.names = FALSE, digits = 10)
  stopifnot(all(abs(rows$contrast - SNOWY_RESULTS$contrast) < CONTRAST_TOLERANCE), all(abs(rows$se / SNOWY_RESULTS$se - 1) < SE_TOLERANCE))
  cat(sprintf('Three results agree with the trial within %g in contrast and %g %% in standard error.\n', CONTRAST_TOLERANCE, 100 * SE_TOLERANCE))

  # The saved fits: one for each fit made, and one of them gives back its rows exactly.
  saved = sort(list.files(out_dir, '^fit_.*[.]rds$'))
  stopifnot(identical(saved, sort(sprintf('fit_snowy_%s.rds', sub(' ', '_', fitted)))),
            file.exists(file.path(out_dir, c('cases_snowy_jul.rds', 'cases_snowy_aug.rds'))))
  fit = readRDS(file.path(out_dir, 'fit_snowy_jul_loc100_linear.rds'))
  cases = readRDS(file.path(out_dir, 'cases_snowy_jul.rds'))
  again = t(sapply(cases, function(case) exchange_contrast(fit$fit, case$exchange)))
  table_rows = contrasts[contrasts$month == 'jul' & contrasts$version == 'loc100_linear', ]
  table_rows = table_rows[match(sapply(cases, function(case) paste(case$support$region, case$support$exchange)),
                                paste(table_rows$region, table_rows$exchange)), ]
  stopifnot(isTRUE(fit$converged), isTRUE(all.equal(unname(again[, 'contrast']), table_rows$contrast, tolerance = 1e-12)),
            isTRUE(all.equal(unname(again[, 'se']), table_rows$se, tolerance = 1e-12)))
  cat('8 fits saved; the saved July fit of loc100_linear, with the saved cases, gives back its 21 contrasts and standard errors.\n')
}

if (sys.nframe() == 0L) {
  command = tool_command_line()
  args = command$args
  if (length(args) == 4 && args[1] == 'inputs') check_inputs(args[2:4], command$fill_missing)
  else if (length(args) == 2 && args[1] == 'exchanges') check_exchanges(args[2])
  else if (length(args) == 2 && args[1] == 'job') check_job(args[2])
  else {
    cat('usage: Rscript tools/check_cover_contrasts.R inputs <all-days-run> <snow-free-run> <snowy-run> [--fill-missing] | exchanges <protocol-2-run> | job <output-dir>\n')
    quit(status = 2)
  }
}
