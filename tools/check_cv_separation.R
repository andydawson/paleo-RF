# CV protocol 2, section 6: freeze first, then run capacity months and recovery truths
# as independent single-thread jobs. This tool never changes the predictive choice.
#   prepare <cv2-run-dir> <run1-full-pipeline-dir>  (before any version-2 fit)
#   capacity <cv2-run-dir> <apr|may>               (14 new fits, one reused)
#   recovery <cv2-run-dir> <apr|may> <darkens|null|shorter>  (after selection)
#   summarize <cv2-run-dir>                       (no fits)
source('tools/cross_validate_albedo.R')
source('R/cv_separation.R')

separation_file = function(run_dir, name) {
  dir = cv_file(run_dir, 'separation')
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  file.path(dir, name)
}

separation_record = function(run_dir, stage, frozen_md5 = NA_character_) {
  v = code_version('config.R')
  writeLines(c(paste('stage:', stage), paste('time:', format(Sys.time(), tz = 'UTC', usetz = TRUE)),
    paste('commit:', v$commit), paste('uncommitted:', v$dirty), paste('frozen inputs MD5:', frozen_md5),
    paste('base seed:', CV_SEED), capture.output(sessionInfo())),
    separation_file(run_dir, paste0('record_', stage, '.txt')))
}

separation_read = function(run_dir) {
  path = separation_file(run_dir, 'frozen.rds')
  frozen = readRDS(path)
  if (!identical(unname(tools::md5sum(frozen$input_files)), frozen$md5))
    stop('separation inputs changed after freezing')
  attr(frozen, 'md5') = unname(tools::md5sum(path))
  frozen
}

separation_prepare = function(run_dir, source_run) {
  destination = separation_file(run_dir, 'frozen.rds')
  if (file.exists(destination)) stop('separation inputs are already frozen; use a new run directory')
  config_files = file.path(c(run_dir, source_run), 'config_used.R')
  if (!all(file.exists(config_files))) stop('both runs need config_used.R to check reuse')
  cfg = load_config(config_files[1]); old_cfg = load_config(config_files[2])
  if (!identical(cfg$analysis, old_cfg$analysis) || old_cfg$analysis$calibration$model_id != 'mod8' ||
      !identical(cfg$analysis$albedo, list(source = 'modis_cells', statistic = 'all_days', version = 'full_75')))
    stop('version 2 and the reused model-8 pipeline must have identical main-refit scientific settings')
  paths = c(redirected_paths(run_dir), list(tag = ALBEDO_TAG))
  old_paths = c(redirected_paths(source_run), list(tag = ALBEDO_TAG))
  ids = c('calibration_table', 'lct_paleo', 'albedo_differences')
  files = vapply(ids, function(id) path_file(paths, id), '')
  old_files = vapply(ids, function(id) path_file(old_paths, id), '')
  # Compare the actual inputs; serialization differences alone do not invalidate reuse.
  for (i in seq_along(files)) if (!isTRUE(all.equal(readRDS(files[i]), readRDS(old_files[i]), tolerance = 0)))
    stop('reused run differs in ', ids[i])
  cal = readRDS(files[['calibration_table']]); paleo = readRDS(files[['lct_paleo']])
  diffs = readRDS(files[['albedo_differences']])
  areas = unique(data.frame(x = diffs$x, y = diffs$y, area = as.numeric(diffs$area)))
  rm(diffs)
  if (anyDuplicated(separation_cell_key(areas))) stop('one cell has inconsistent areas')
  cell_area = function(cells) areas$area[match(separation_cell_key(cells), separation_cell_key(areas))]
  past_cells = paleo[paleo$ages == 6000 & separation_northeast(paleo), c('x', 'y', 'elev')]
  capacity = historical_exchange(past_cells, paleo, cell_area(past_cells))
  frozen = list(cal = cal, capacity = capacity, months = list(), config = cfg,
    source_config = old_cfg, models = CV_MODELS, location_k = CV_LOCATION_K, cover_form = CV_COVER_FORM,
    base_seed = CV_SEED, protocol_md5 = unname(tools::md5sum('docs/cc/2026-11-06_cv_protocol_v2.md')))
  seeds = endpoints = exclusions = NULL
  fit_files = character()
  for (month in c('apr', 'may')) {
    fit_file = path_file(old_paths, 'calibration_prediction_fit', month = month)
    fit_files = c(fit_files, fit_file)
    fit = readRDS(fit_file)
    generator = freeze_generator(cal, month, fit)
    rows = cal[complete_rows(cal, month), ]
    hull = training_hull(rows)
    modern = rows[separation_northeast(rows), ]
    exchanges = list(fixed = fixed_exchange(modern, cell_area(modern)), historical = capacity)
    for (name in names(exchanges)) exchanges[[name]]$support = exchange_support(exchanges[[name]], hull)
    month_capacity = capacity
    month_capacity$support = exchange_support(month_capacity, hull)
    responses = list()
    for (truth in CV_RECOVERY_TRUTHS) {
      responses[[truth]] = lapply(seq_len(CV_RECOVERY_REPLICATES), function(replicate)
        recovery_response(cal, month, generator, truth, replicate, CV_SEED))
      seeds = rbind(seeds, data.frame(month = month, truth = truth, replicate = seq_len(CV_RECOVERY_REPLICATES),
        seed = vapply(responses[[truth]], function(x) x$seed, 0L)))
    }
    for (name in c('capacity', names(exchanges))) {
      exchange = if (name == 'capacity') month_capacity else exchanges[[name]]
      exclusions = rbind(exclusions, cbind(month = month, exchange = name, exchange$exclusions))
      endpoints = rbind(endpoints, cbind(month = rep(month, nrow(exchange$first)),
        exchange = rep(name, nrow(exchange$first)), exchange$support,
        OL = exchange$first$OL, ET_first = exchange$first$ET, ST_first = exchange$first$ST,
        ET_second = exchange$second$ET, ST_second = exchange$second$ST))
    }
    frozen$months[[month]] = list(generator = generator, exchanges = exchanges, capacity = month_capacity,
      responses = responses, model8_file = fit_file, reuse = fit_convergence(fit))
    rm(fit)
  }
  frozen$input_files = c(files, old_files, config_files, fit_files)
  frozen$md5 = unname(tools::md5sum(frozen$input_files))
  saveRDS(frozen, destination)
  write.csv(seeds, separation_file(run_dir, 'seeds.csv'), row.names = FALSE)
  write.csv(endpoints, separation_file(run_dir, 'endpoints.csv'), row.names = FALSE)
  write.csv(exclusions, separation_file(run_dir, 'exclusions.csv'), row.names = FALSE)
  write.csv(data.frame(file = frozen$input_files, md5 = frozen$md5),
            separation_file(run_dir, 'inputs.csv'), row.names = FALSE)
  dput(lapply(frozen$months, function(x) x$generator), separation_file(run_dir, 'generators.R'))
  separation_record(run_dir, 'prepare', unname(tools::md5sum(destination)))
  print(exclusions, row.names = FALSE)
}

separation_capacity = function(run_dir, month) {
  frozen = separation_read(run_dir)
  data = frozen$cal
  result = terms = attempts = NULL
  for (model in CV_MODELS) {
    if (model == 'mod8') {
      fit = readRDS(frozen$months[[month]]$model8_file)
      check_reused_model8(fit, data, month)
      fitted = list(fit = fit, converged = TRUE, retries = 0L, status = fit_convergence(fit), warnings = '',
        attempts = data.frame(attempt = 0L, maxit = fit$control$maxit, converged = TRUE, status = 'reused'))
    } else fitted = fit_calibration_retry(model, month, data)
    fit = fitted$fit
    contrast = c(contrast = NA_real_, se = NA_real_)
    aic = c(aic = NA_real_, smoothing_uncertainty_correction = NA_real_)
    concurvity = location_concurvity(NULL, model)
    if (!is.null(fit)) {
      check_full_month_rows(fit, data, month)
      fit_terms = calibration_fit_summary(fit)
      terms = rbind(terms, cbind(month = month, model = model, fit_terms))
      if (fitted$converged) {
        contrast = exchange_contrast(fit, frozen$months[[month]]$capacity)
        aic = full_month_aic(fit, data, month)
        concurvity = location_concurvity(fit, model)
      }
    }
    result = rbind(result, cbind(data.frame(month = month, model = model,
      location_k = CV_LOCATION_K[[model]], cover_form = CV_COVER_FORM[[model]],
      reused = model == 'mod8', converged = fitted$converged, retries = fitted$retries,
      status = fitted$status, warnings = fitted$warnings,
      contrast = contrast[['contrast']], se = contrast[['se']], aic = aic[['aic']],
      smoothing_uncertainty_correction = as.logical(aic[['smoothing_uncertainty_correction']])), concurvity))
    attempts = rbind(attempts, cbind(month = month, model = model, fitted$attempts))
    rm(fit, fitted); gc(verbose = FALSE)
  }
  result$lower95 = result$contrast - 1.96 * result$se
  result$upper95 = result$contrast + 1.96 * result$se
  result$sign_resolved = is.finite(result$lower95) & (result$lower95 > 0 | result$upper95 < 0)
  result$delta_aic = if (any(is.finite(result$aic))) result$aic - min(result$aic, na.rm = TRUE) else NA_real_
  saveRDS(list(frozen_md5 = attr(frozen, 'md5'), comparison = result, terms = terms, attempts = attempts),
           separation_file(run_dir, paste0('capacity_', month, '.rds')))
  write.csv(result, separation_file(run_dir, paste0('capacity_', month, '.csv')), row.names = FALSE)
  separation_record(run_dir, paste0('capacity_', month), attr(frozen, 'md5'))
}

separation_winner = function(run_dir) {
  choice = read.csv(cv_file(run_dir, 'scores.csv'))
  winner = choice$model[choice$chosen]
  if (length(winner) != 1) stop('recovery needs one completed predictive choice')
  winner
}

separation_recovery = function(run_dir, month, truth) {
  frozen = separation_read(run_dir)
  winner = separation_winner(run_dir)
  models = recovery_models(winner)
  settings = frozen$months[[month]]
  result = terms = attempts = NULL
  for (replicate in seq_len(CV_RECOVERY_REPLICATES)) {
    data = frozen$cal
    draw = settings$responses[[truth]][[replicate]]
    data[[month]] = draw$response
    for (model in models) {
      fitted = fit_calibration_retry(model, month, data)
      if (!is.null(fitted$fit)) terms = rbind(terms, cbind(month = month, truth = truth,
        replicate = replicate, model = model, calibration_fit_summary(fitted$fit)))
      attempts = rbind(attempts, cbind(month = month, truth = truth, replicate = replicate,
        model = model, fitted$attempts))
      for (name in names(settings$exchanges)) for (subset in c('all', 'inside', 'outside')) {
        exchange = exchange_subset(settings$exchanges[[name]], subset)
        contrast = c(contrast = NA_real_, se = NA_real_)
        prediction_error = ''
        if (fitted$converged) contrast = tryCatch(exchange_contrast(fitted$fit, exchange),
          error = function(e) { prediction_error <<- conditionMessage(e); c(contrast = NA_real_, se = NA_real_) })
        result = rbind(result, data.frame(month = month, truth = truth, replicate = replicate,
          model = model, seed = draw$seed, exchange = name, subset = subset,
          cells = nrow(exchange$first), area = sum(exchange$area),
          area_share = sum(exchange$area) / sum(settings$exchanges[[name]]$area),
          exact = generator_contrast(exchange, settings$generator, truth),
          reference = generator_contrast(exchange, settings$generator, 'darkens'),
          contrast = contrast[['contrast']], se = contrast[['se']],
          converged = fitted$converged, retries = fitted$retries, status = fitted$status,
          warnings = fitted$warnings, prediction_error = prediction_error))
      }
      rm(fitted); gc(verbose = FALSE)
    }
  }
  file = paste0('recovery_', month, '_', truth)
  saveRDS(list(frozen_md5 = attr(frozen, 'md5'), winner = winner, models = models,
    replicates = result, terms = terms, attempts = attempts), separation_file(run_dir, paste0(file, '.rds')))
  write.csv(result, separation_file(run_dir, paste0(file, '.csv')), row.names = FALSE)
  separation_record(run_dir, file, attr(frozen, 'md5'))
}

separation_summarize = function(run_dir) {
  frozen = separation_read(run_dir)
  winner = separation_winner(run_dir)
  models = recovery_models(winner)
  read_result = function(file) {
    result = readRDS(separation_file(run_dir, file))
    if (!identical(result$frozen_md5, attr(frozen, 'md5'))) stop('results use other frozen inputs: ', file)
    result
  }
  capacity = terms = attempts = NULL
  replicates = summaries = NULL
  for (month in c('apr', 'may')) {
    capacity_result = read_result(paste0('capacity_', month, '.rds'))
    capacity = rbind(capacity, capacity_result$comparison)
    terms = rbind(terms, cbind(experiment = 'capacity', truth = NA, replicate = NA, capacity_result$terms))
    attempts = rbind(attempts, cbind(experiment = 'capacity', truth = NA, replicate = NA, capacity_result$attempts))
    for (truth in CV_RECOVERY_TRUTHS) {
      result = read_result(paste0('recovery_', month, '_', truth, '.rds'))
      if (!identical(result$winner, winner) || !identical(result$models, models)) stop('recovery used another winner')
      replicates = rbind(replicates, result$replicates)
      if (!is.null(result$terms)) terms = rbind(terms, cbind(experiment = 'recovery', result$terms))
      attempts = rbind(attempts, cbind(experiment = 'recovery', result$attempts))
      for (model in models) for (exchange in c('fixed', 'historical')) for (subset in c('all', 'inside', 'outside')) {
        rows = result$replicates[result$replicates$model == model & result$replicates$exchange == exchange &
                                  result$replicates$subset == subset, ]
        statistics = recovery_statistics(rows$contrast, rows$converged, rows$exact[1], rows$reference[1],
                                          truth == 'null', rows$cells[1])
        summaries = rbind(summaries, cbind(data.frame(month = month, truth = truth, model = model,
          exchange = exchange, subset = subset, cells = rows$cells[1], area = rows$area[1],
          area_share = rows$area_share[1], exact = rows$exact[1], reference = rows$reference[1]), statistics))
      }
    }
  }
  capacity$sign_reversal = FALSE
  capacity$magnitude_range = NA_real_
  for (month in c('apr', 'may')) for (cover in unique(CV_COVER_FORM)) {
    rows = which(capacity$month == month & capacity$cover_form == cover)
    contrast = capacity$contrast[rows]
    finite = contrast[is.finite(contrast)]
    capacity$sign_reversal[rows] = any(finite < 0) && any(finite > 0)
    if (length(finite)) capacity$magnitude_range[rows] = diff(range(abs(finite)))
  }
  passed = do.call(rbind, lapply(models, function(model) {
    rows = summaries[summaries$model == model & summaries$subset == 'all', ]
    data.frame(model = model, required_checks = 12L, passed_checks = sum(rows$status == 'pass'),
      passes_recovery = nrow(rows) == 12 && all(rows$status == 'pass'),
      northeast_sign_claim_prevented = nrow(rows) != 12 || any(rows$status != 'pass'))
  }))
  for (name in c('capacity', 'replicates', 'summaries', 'passed', 'terms', 'attempts'))
    write.csv(get(name), separation_file(run_dir, paste0(name, '.csv')), row.names = FALSE)
  suppressPackageStartupMessages(library(ggplot2))
  plot = ggplot(capacity, aes(location_k, contrast, colour = cover_form, group = cover_form)) +
    geom_hline(yintercept = 0, colour = 'grey60') + geom_line() + geom_point() +
    geom_errorbar(aes(ymin = lower95, ymax = upper95), width = 4) + facet_wrap(~ month) +
    scale_x_continuous(breaks = c(0, 12, 30, 100, 500)) + theme_bw() +
    labs(x = 'Location basis size (0: no location term)', y = 'Albedo contrast: second endpoint minus first',
      colour = 'Cover form', caption = '6 ka open land; 4.5 ka evergreen minus 6 ka evergreen. Conditional approximate 95% intervals.')
  ggsave(separation_file(run_dir, 'capacity.pdf'), plot, width = 10, height = 5)
  writeLines(c('Selection is unchanged by these reports. AIC differences compare only full-data fits within one month.',
    'Recovery pass rules use the complete frozen cell set. Inside/outside subsets are diagnostics; outside means either endpoint is outside.',
    'Intervals use Vp and are conditional on smoothing parameters; errors across configurations are not independent.',
    'Twenty replicates give worst-case Monte Carlo SE 0.112 for a sign proportion. MCSEs here use independent replicate variation.',
    'Recovery failure, incompleteness or untestability prevents a northeast vegetation-sign claim.',
    'Agreement within this grid does not establish correct separation or historical signs.'), separation_file(run_dir, 'interpretation.txt'))
  separation_record(run_dir, 'summarize', attr(frozen, 'md5'))
  print(passed, row.names = FALSE)
}

if (sys.nframe() == 0L) {
  args = commandArgs(trailingOnly = TRUE)
  usage = 'usage: check_cv_separation.R prepare <run> <source-run> | capacity <run> <month> | recovery <run> <month> <truth> | summarize <run>'
  if (length(args) < 2 || !args[1] %in% c('prepare', 'capacity', 'recovery', 'summarize')) stop(usage)
  if (args[1] %in% c('capacity', 'recovery') && (length(args) < 3 || !args[3] %in% c('apr', 'may'))) stop(usage)
  if (args[1] == 'prepare' && length(args) != 3) stop(usage)
  if (args[1] == 'recovery' && (length(args) != 4 || !args[4] %in% CV_RECOVERY_TRUTHS)) stop(usage)
  suppressPackageStartupMessages(library(mgcv))
  switch(args[1], prepare = separation_prepare(args[2], args[3]),
    capacity = separation_capacity(args[2], args[3]),
    recovery = separation_recovery(args[2], args[3], args[4]), summarize = separation_summarize(args[2]))
}
