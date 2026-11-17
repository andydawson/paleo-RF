# Checks of the cover-contrast exploration (tools/explore_cover_contrasts.R) on real data, for its
# verification spec. They check the implementation, not the science: no result is judged.
#
#   Rscript tools/check_cover_contrasts.R inputs <all-days-run> <snow-free-run> <snowy-run>
#       The three finished runs the exploration reads are the ones traced in the implementation
#       note (section 4): each file has its recorded MD5 sum, the repository's cell table
#       reproduces each calibration table, and the three tables hold the same cells, cover,
#       elevation and cell areas; only the albedo differs.
#   Rscript tools/check_cover_contrasts.R exchanges <protocol-2-run>
#       Protocol 2's own northeast exchanges (April and May, fixed and historical), rebuilt with
#       the generalised helpers of R/cv_separation.R, are identical to those it froze.
#   Rscript tools/check_cover_contrasts.R job <output-dir>
#       The fit and report commands' output for the snowy table's July and August: the expected
#       records, rows and support, a few numbers, and one saved fit that gives its numbers back.
#   Rscript tools/check_cover_contrasts.R duveiller <output-dir> <saved-contrast-dir> <netcdf-file>
#       The duveiller command's output for the full saved run: the published file as recorded and
#       consistent, with the design's value at one cell; 1,512 rows, the published side and the
#       coverage the same for every version, numbers exactly where there are common cells; the
#       design's counts; five means recomputed from the raw file and the saved fits; one page; a
#       complete record.
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

check_inputs = function(run_dirs) {
  runs = lapply(setNames(run_dirs, names(INPUT_MD5)), read_run)   # read_run stops unless the cell table reproduces the run's table
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

# --- duveiller ------------------------------------------------------------------------------------

# The published file the design inspected: Figshare article 5217709, version 1
# (data/duveiller2018/PROVENANCE.txt in the main checkout).
DUVEILLER_MD5 = '96125db41154fa176c53b51596893ad6'

# The northeast's common and eligible cells as the design's inspection of the same files counted
# them (16 November).
NORTHEAST_COMMON = data.frame(month = rep(c('jan', 'jul'), each = 3), exchange = rep(EXCHANGES$exchange, 2),
                              common_cells = c(20, 1, 11, 40, 5, 12), eligible_cells = rep(c(58, 41, 22), 2))

# Means recomputed here from the raw file and the saved fits' own predictions, without the tool's
# functions: winter and summer, the three transitions with their signs written out again, three
# versions.
RECOMPUTED = data.frame(month = c('jan', 'jul', 'jan', 'jul', 'jul'),
  region = c('Northeast (hemlock box)', 'Northeast (hemlock box)', STUDY_AREA, STUDY_AREA, 'Upper Midwest / Great Lakes'),
  exchange = c('evergreen to summergreen', 'evergreen to summergreen', 'summergreen to open land', 'summergreen to open land', 'evergreen to open land'),
  transition = c(23, 23, 28, 28, 38), sign = c(-1, -1, 1, 1, 1),
  version = c('loc100_linear', 'loc100_linear', 'mod8', 'mod8', 'loc30_linear'))

check_duveiller = function(out_dir, saved_dir, source_file) {
  # The file: the one inspected, with an uncertainty and at least 20 samples wherever it has an
  # estimate of the three transitions, and the design's value at 75.5 W, 45.5 N in January, as
  # published and as the tool reads it (reversed and multiplied by 0.10).
  nc = ncdf4::nc_open(source_file)
  on.exit(ncdf4::nc_close(nc))
  at = function(dim, value) match(value, nc$dim[[dim]]$vals)
  for (code in DUVEILLER_TRANSITIONS$transition) {
    every_month = function(variable) ncdf4::ncvar_get(nc, variable, start = c(1, 1, 1, at('iTr', code)), count = c(-1, -1, -1, 1))
    estimate = is.finite(every_month('Delta_albedo'))
    sd = every_month('SD_Delta_albedo')
    stopifnot(all(is.finite(sd[estimate]) & sd[estimate] >= 0), all(every_month('N_Delta_albedo')[estimate] >= 20))
  }
  cell = c(at('lon', -75.5), at('lat', 45.5))
  value = function(variable) ncdf4::ncvar_get(nc, variable, start = c(cell, at('mon', 1), at('iTr', 23)), count = c(1, 1, 1, 1))
  read = read_duveiller_month(nc, 'jan')[['evergreen to summergreen']]
  stopifnot(unname(tools::md5sum(source_file)) == DUVEILLER_MD5, abs(value('Delta_albedo') + 0.0444744043) < 1e-10,
            abs(value('SD_Delta_albedo') - 0.0143031348) < 1e-10, value('N_Delta_albedo') == 39,
            abs(read$change[cell[1], cell[2]] - 0.00444744043) < 1e-11, read$samples[cell[1], cell[2]] == 39)
  cat('The published file has its recorded MD5 sum; every estimate of transitions 23, 38 and 28 has an uncertainty and at least\n',
      '20 samples; at 75.5 W, 45.5 N in January transition 23 is -0.0444744043 (39 samples), read as +0.00444744043.\n', sep = '')

  # The table: every month, version, region and exchange once; the published side and the coverage
  # the same for every version; the saved results' cells, fits and area shares; numbers exactly
  # where there are common cells (every all-days fit converged).
  rows = utils::read.csv(file.path(out_dir, 'cover_contrasts_duveiller.csv'), comment.char = '#')
  key = c('month', 'version', 'region', 'exchange')
  saved = do.call(rbind, lapply(MONTHS, function(month) utils::read.csv(file.path(saved_dir, sprintf('contrasts_all_days_%s.csv', month)))))
  same = merge(rows, saved, by = key, suffixes = c('', '_saved'))
  per_case = unique(rows[, c('month', 'region', 'exchange', 'region_cells', 'eligible_cells', 'common_cells', 'common_area_m2',
                             'share_of_eligible_area', 'share_of_region_area', 'min_samples', 'max_samples', 'duveiller_contrast')])
  common = rows$common_cells > 0
  eligible = same$eligible_cells > 0
  stopifnot(nrow(rows) == 1512, !anyDuplicated(rows[, key]), setequal(rows$month, MONTHS), setequal(rows$version, CONTRAST_VERSIONS),
            setequal(rows$exchange, EXCHANGES$exchange), length(unique(rows$region)) == 7, nrow(per_case) == 12 * 7 * 3,
            nrow(same) == 1512, all(same$eligible_cells == same$eligible_cells_saved), all(same$region_cells == same$region_cells_saved),
            identical(same$fit_status, same$fit_status_saved), all(rows$converged),
            identical(is.finite(rows$duveiller_contrast), common), identical(is.finite(rows$contrast), common),
            identical(is.finite(rows$se), common), identical(is.finite(rows$spread), common),
            identical(is.finite(rows$min_samples), common), all(rows$min_samples[common] >= 20 & rows$min_samples[common] <= rows$max_samples[common]),
            all(rows$common_cells <= rows$eligible_cells), identical(is.finite(same$share_of_eligible_area), eligible),
            all(same$share_of_eligible_area[eligible] <= 1), all(same$share_of_region_area[!eligible] == 0),
            all(abs(same$share_of_region_area - same$area_share * same$share_of_eligible_area)[eligible] < 1e-12))
  cat(sprintf('1,512 uniquely identified rows; the published side and the coverage the same for every version; the saved results\' cells\n%s',
              'and fits; numbers exactly where there are common cells; the shares of area consistent with the saved ones.\n'))

  # What the design's inspection found: the northeast's counts in January and July; no common cells
  # in Alaska and Yukon in January and December, and at most two for summergreen to open land.
  ne = per_case[per_case$region == 'Northeast (hemlock box)', ]
  ne = ne[match(paste(NORTHEAST_COMMON$month, NORTHEAST_COMMON$exchange), paste(ne$month, ne$exchange)), ]
  alaska = per_case[per_case$region == 'Alaska / Yukon', ]
  stopifnot(identical(as.numeric(ne$common_cells), NORTHEAST_COMMON$common_cells), identical(as.numeric(ne$eligible_cells), NORTHEAST_COMMON$eligible_cells),
            all(alaska$common_cells[alaska$month %in% c('jan', 'dec')] == 0), all(alaska$common_cells[alaska$exchange == 'summergreen to open land'] <= 2))
  cat('The common cells of the northeast and of Alaska and Yukon are those the design\'s inspection counted.\n')

  # Five means recomputed, and the saved mean over all the eligible cells from the same predictions.
  for (i in seq_len(nrow(RECOMPUTED))) {
    pick = RECOMPUTED[i, ]
    cases = readRDS(file.path(saved_dir, sprintf('cases_all_days_%s.rds', pick$month)))
    case = cases[[which(vapply(cases, function(c) c$support$region == pick$region && c$support$exchange == pick$exchange, FALSE))]]$exchange
    layer = ncdf4::ncvar_get(nc, 'Delta_albedo', start = c(1, 1, at('mon', match(pick$month, MONTHS)), at('iTr', pick$transition)), count = c(-1, -1, 1, 1))
    published = layer[cbind(at('lon', case$first$x), at('lat', case$first$y))]
    kept = is.finite(published)
    weight = case$area[kept] / sum(case$area[kept])
    fit = readRDS(file.path(saved_dir, sprintf('fit_all_days_%s_%s.rds', pick$month, pick$version)))$fit
    difference = as.numeric(stats::predict(fit, case$second, type = 'response') - stats::predict(fit, case$first, type = 'response'))
    row = rows[rows$month == pick$month & rows$version == pick$version & rows$region == pick$region & rows$exchange == pick$exchange, ]
    before = saved[saved$month == pick$month & saved$version == pick$version & saved$region == pick$region & saved$exchange == pick$exchange, ]
    again = c(published = sum(weight * 0.10 * pick$sign * published[kept]), model = sum(weight * difference[kept]), all_eligible = sum(case$weight * difference))
    cat(sprintf('%s, %s, %s, %s: %d of %d cells; published %.6f (again %.6f), model %.6f (again %.6f); all eligible cells %.6f (saved %.6f)\n',
                pick$month, pick$region, pick$exchange, pick$version, sum(kept), length(kept), row$duveiller_contrast, again[['published']],
                row$contrast, again[['model']], again[['all_eligible']], before$contrast))
    stopifnot(nrow(row) == 1, row$common_cells == sum(kept), abs(row$duveiller_contrast - again[['published']]) < 1e-12,
              abs(row$contrast - again[['model']]) < 1e-12, abs(before$contrast - again[['all_eligible']]) < 1e-12)
    rm(fit); gc(verbose = FALSE)
  }
  cat('Five means recomputed from the raw file and the saved fits agree within 1e-12, and so do the saved means over all eligible cells.\n')

  # One page, and a complete record whose inputs still have their recorded MD5 sums.
  pdf = file.path(out_dir, 'cover_contrasts_duveiller.pdf')
  pages = length(grepRaw('/Type /Page ', readBin(pdf, 'raw', file.size(pdf)), fixed = TRUE, all = TRUE))
  record = readLines(file.path(out_dir, 'record_duveiller.txt'))
  inputs = do.call(rbind, strsplit(grep('^input ', record, value = TRUE), ' '))
  stopifnot(pages == 1, 'job: duveiller' %in% record, nrow(inputs) == 1 + 12 + 12 + 72, inputs[1, 2] == 'published_change',
            inputs[1, 4] == DUVEILLER_MD5, identical(unname(tools::md5sum(inputs[, 3])), inputs[, 4]),
            length(grep('^transition: ', record)) == 3, any(grepl('^not reported: SD_Delta_albedo', record)),
            any(grepl('^package ncdf4 ', record)), length(grep('^time .*: [0-9.]+ s$', record)) == 4)
  cat('One page; the record lists the 97 inputs with their current MD5 sums, the mapping, the settings and four timings.\n')
}

if (sys.nframe() == 0L) {
  args = commandArgs(trailingOnly = TRUE)
  if (length(args) == 4 && args[1] == 'inputs') check_inputs(args[2:4])
  else if (length(args) == 2 && args[1] == 'exchanges') check_exchanges(args[2])
  else if (length(args) == 2 && args[1] == 'job') check_job(args[2])
  else if (length(args) == 4 && args[1] == 'duveiller') check_duveiller(args[2], args[3], args[4])
  else {
    cat('usage: Rscript tools/check_cover_contrasts.R inputs <all-days-run> <snow-free-run> <snowy-run> | exchanges <protocol-2-run> | job <output-dir>',
        '| duveiller <output-dir> <saved-contrast-dir> <netcdf-file>\n')
    quit(status = 2)
  }
}
