# Cross-validation that chooses the albedo model on its accuracy for cover mixes beyond the modern
# range: protocol 2 (docs/cc/2026-11-06_cv_protocol_v2.md). The
# functions are in R/cross_validation.R; this tool reads a finished run and runs the protocol's three
# stages, each a separate command so that Chris sees the holdouts before any model is fitted:
#
#   Rscript tools/cross_validate_albedo.R holdouts <run-dir>
#       the directions, the withheld cells, the feasibility of each month and holdout, and how the
#       withheld cells' distances compare with the hindcast's (minutes; no model fitted).
#   Rscript tools/cross_validate_albedo.R fit <run-dir> <holdout> <month> [<month> ...]
#       fits the fifteen candidates (CV_MODELS, R/model_registry.R) without that holdout's cells and
#       predicts them (hours). Holdout "inrange" (skill inside the range, reported only) fits the
#       model 8 and the chosen model, after the score stage; run the score
#       stage again afterwards for its reports.
#   Rscript tools/cross_validate_albedo.R score <run-dir>
#       the scores, their uncertainty and the choice, with the checks reported beside them.
#
# <run-dir> is the directory a run wrote into (its config's run$dir). It needs that run's
# configuration (config_used.R, as tools/verify_change.R writes it; else the repository's config.R),
# calibration table (script 2), past cover (script 1) and albedo differences (script 7a, for each
# cell's area and ice fraction). Results go to <run-dir>/output/cross_validation_v2/, with a record of
# the code version, the inputs' MD5 sums and the seeds.

source('R/config.R')
source('R/paths.R')                 # brings R/model_registry.R
source('R/random.R')
source('R/run_manifest.R')         # code_version(), for the record of each stage
source('R/cross_validation.R')
source('R/calibration_fit.R')

CV_SEED        = 1549466984         # the refit runs' fixed seed (Chris, 31 October 2026)
LOW_OPEN_LAND  = 0.2                # protocol 2 evergreen-share diagnostic
SEEDS = list(inrange = derive_seed(CV_SEED, 'cross_validation', 'inrange'),
             resample = derive_seed(CV_SEED, 'cross_validation', 'resample'))

cv_file = function(run_dir, name) {
  dir = file.path(run_dir, 'output', 'cross_validation_v2')
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  file.path(dir, name)
}

# The run's configuration: the one the run was made with, if the run folder keeps it.
run_config = function(run_dir) {
  used = file.path(run_dir, 'config_used.R')
  load_config(if (file.exists(used)) used else 'config.R')
}

# The holdout membership in the calibration table's row order, matched by cell (x, y), so a
# reordered table cannot move a withheld cell into training.
membership_for = function(holdouts, cal, holdout) {
  row = match(paste(cal$x, cal$y), paste(holdouts$membership$x, holdouts$membership$y))
  if (anyNA(row) || is.null(holdouts$membership[[holdout]])) stop('the calibration table does not match the holdouts (cells or holdout ', holdout, ')')
  holdouts$membership[[holdout]][row]
}

# The MD5 sums of the inputs; later stages stop if the calibration table changed since the holdouts
# were made (the target itself is frozen in holdouts.rds).
input_md5 = function(paths) tools::md5sum(c(path_file(paths, 'calibration_table'), path_file(paths, 'lct_paleo'),
                                            path_file(paths, 'albedo_differences')))
check_inputs = function(holdouts, paths) {
  now = input_md5(paths)
  if (!identical(holdouts$protocol_version, 2L)) stop('holdouts are not from protocol 2; make separate version-2 holdouts')
  if (!identical(unname(now), unname(holdouts$md5))) stop('inputs changed since the holdouts were made')
  if (!identical(holdouts$models, CV_MODELS) || !identical(holdouts$terms, vapply(CV_MODELS, calibration_terms, '')))
    stop('CV model definitions changed since the holdouts were made')
}

# Each predictions file carries the MD5 of the holdouts.rds it was fitted against; the score stage
# reads only files whose MD5 matches the current holdouts.rds, so predictions made for holdouts that
# have since been rebuilt can never be scored against the new ones (code review of 4 November).
holdouts_md5 = function(run_dir) unname(tools::md5sum(cv_file(run_dir, 'holdouts.rds')))
read_predictions = function(run_dir, files) {
  now = holdouts_md5(run_dir)
  read = lapply(files, readRDS)
  stale = files[!vapply(read, function(p) identical(attr(p, 'holdouts_md5'), now), TRUE)]
  if (length(stale)) stop('predictions made for other holdouts (rerun the fit stage): ', paste(basename(stale), collapse = ', '))
  do.call(rbind, read)
}

# One record per stage: when, the code version, the inputs' MD5 sums and the seeds.
write_record = function(run_dir, paths, stage) {
  v = code_version('config.R')
  if (stage == 'holdouts') saveRDS(run_config(run_dir), cv_file(run_dir, 'config_used.rds'))
  packages = c('R', 'mgcv', 'sf')
  versions = c(as.character(getRversion()), vapply(packages[-1], function(p) as.character(utils::packageVersion(p)), ''))
  writeLines(c('protocol_version: 2', paste('stage:', stage), paste('time:', format(Sys.time(), tz = 'UTC', usetz = TRUE)),
               paste('commit:', v$commit), paste('branch:', v$branch), paste('uncommitted changes:', v$dirty),
               paste('input', names(input_md5(paths)), input_md5(paths)),
               paste('package', packages, versions), paste('seed', names(SEEDS), unlist(SEEDS))), cv_file(run_dir, paste0('record_', stage, '.txt')))
}

# Great-circle distance (km) from each cell a to the nearest of the cells b (one-degree centres).
nearest_km = function(ax, ay, bx, by) {
  r = pi / 180
  vapply(seq_along(ax), function(i) min(6371 * acos(pmax(-1, pmin(1, sin(ay[i] * r) * sin(by * r) +
                                                          cos(ay[i] * r) * cos(by * r) * cos((bx - ax[i]) * r))))), 0)
}

# --- Stage 1: holdouts --------------------------------------------------------------------------
# Geometry uses each month's actual complete training rows, then remains frozen for every model.
validation_cells = function(cal, withheld, directions, month, holdout) {
  complete = complete_rows(cal, month)
  train = cal[complete & !withheld, ]
  valid = cal[complete & withheld, ]
  departure = withheld_departure(valid, training_hull(train), directions, month)
  data.frame(holdout = holdout, month = month, calibration_row = which(complete & withheld),
             x = valid$x, y = valid$y, OL = valid$OL, ET = valid$ET, ST = valid$ST,
             departure[, c('outside', 'distance', 'angle', 'own_direction', 'group')],
             km = nearest_km(valid$x, valid$y, train$x, train$y), observed = valid[[month]])
}

# Group coverage is fixed from geometry; model failures never redefine its scoring denominator.
coverage_table = function(rows, target) {
  groups = target
  selected = cv_scoring_rows(rows, target)
  groups$nearby_scored = vapply(groups$group, function(g) sum(rows$group == g & selected), 0L)
  groups$far_cells = vapply(groups$group, function(g) sum(rows$group == g & rows$km >= CV_NEARBY_KM), 0L)
  groups$represented = groups$nearby_scored > 0
  groups
}

stage_holdouts = function(run_dir, paths, previous_run = run_dir) {
  cfg = run_config(run_dir)
  cal = readRDS(path_file(paths, 'calibration_table'))
  months = cfg$analysis$months
  if (!identical(months, MONTHS)) stop('protocol 2 requires all twelve months')
  if (!identical(cfg$analysis$albedo, list(source = 'modis_cells', statistic = 'all_days', version = 'full_75')))
    stop('protocol 2 requires MODIS cells, all days, full_75')
  if (cfg$analysis$domain$lat_min != 27 || cfg$analysis$domain$lat_max != 74) stop('protocol 2 requires the 27–74 N forcing window')
  paleo = readRDS(path_file(paths, 'lct_paleo'))
  domain = cfg$analysis$domain
  hindcast = cv_target_weights(paleo, readRDS(path_file(paths, 'albedo_differences')), cfg$analysis$ages,
                               length(months), domain$lat_min, domain$lat_max)
  exclusions = attr(hindcast, 'exclusions')
  per_month = do.call(rbind, lapply(months, function(m) {
    hull = training_hull(cal[complete_rows(cal, m), ])
    cbind(hindcast[, c('x', 'y', 'ages', 'OL', 'ET', 'ST', 'weight')], month = m,
          distance = training_support(hindcast, hull)$distance_outside, angle = departure_angle(hindcast, hull))
  }))
  if (!any(!is.na(per_month$angle) & per_month$weight > 0)) stop('no positive historical target lies outside the modern hulls; no useful comparison')
  directions = cv_directions(per_month$angle, per_month$weight)
  outside = per_month[!is.na(per_month$angle), ]
  outside$direction = nearest_direction(outside$angle, directions)
  outside$group = paste(outside$month, outside$direction, distance_band(outside$distance))
  target = aggregate(weight ~ group + month + direction, outside, sum)
  directions$share = as.numeric(tapply(outside$weight, outside$direction, sum)[directions$direction]) / sum(outside$weight)
  directions$share_within_30 = sapply(seq_len(nrow(directions)), function(i) {
    o = outside[outside$direction == directions$direction[i], ]
    sum(o$weight[angle_gap(o$angle, directions$angle[i]) <= 30]) / sum(o$weight)
  })

  # Coefficient counts come from model setup, before fitting. Every month uses the same bases.
  coefficients = vapply(CV_MODELS, model_coefficients, 0L, month = months[1], data = cal)
  if (!identical(as.integer(coefficients), as.integer(CV_COEFFICIENTS))) stop('setup coefficient counts differ from the approved table')
  largest_model = max(coefficients)
  membership = cal[, c('x', 'y')]
  feasibility = validation = NULL
  for (i in seq_len(nrow(directions))) {
    d = directions$direction[i]
    for (cut in CV_CUTS) {
      withheld = cv_holdouts(cal, directions$angle[i], cut)
      cells = do.call(rbind, lapply(months, function(m) validation_cells(cal, withheld, directions, m, d)))
      if (!all(cells$outside)) stop('a directional withheld cell lies inside its training range')
      f = do.call(rbind, lapply(months, function(m) {
        data.frame(holdout = d, cut = cut, month = m,
                   cv_feasibility(sum(complete_rows(cal, m) & !withheld), largest_model, cells[cells$month == m, ], target))
      }))
      if (any(f$feasible)) break
    }
    membership[[d]] = withheld
    feasibility = rbind(feasibility, f)
    validation = rbind(validation, cells)
  }
  validation$feasible = feasibility$feasible[match(paste(validation$holdout, validation$month), paste(feasibility$holdout, feasibility$month))]
  validation$selected = validation$feasible & cv_scoring_rows(validation, target)
  diagnostic = validation[validation$feasible, ]
  coverage = coverage_table(diagnostic, target)
  nearby_depth = cv_nearby_depth(diagnostic, target, directions$direction, months)
  nearby_coverage = cv_nearby_coverage(diagnostic, target)
  # Both regional subsets use the same full historical denominator, never a reweighted target.
  northeast_depth = cv_nearby_depth(diagnostic[region_of(diagnostic$x, diagnostic$y) == 'Northeast (hemlock box)', ],
                                   target, directions$direction, months)
  q = function(v) paste(if (length(v)) signif(stats::quantile(v, c(0.1, 0.5, 0.9), names = FALSE), 3) else rep(NA, 3), collapse = ' / ')
  blocks = cv_block(cal$x, cal$y)
  picked = withr_seed(SEEDS$inrange, sample(sort(unique(blocks)), round(length(unique(blocks)) / 5)))
  membership$inrange = blocks %in% picked
  inrange_cells = do.call(rbind, lapply(months, function(m) validation_cells(cal, membership$inrange, directions, m, 'inrange')))
  inrange = do.call(rbind, lapply(months, function(m) {
    cells = inrange_cells[inrange_cells$month == m, ]
    inside = !cells$outside
    blocks = length(unique(cv_block(cells$x[inside], cells$y[inside])))
    training_rows = sum(complete_rows(cal, m) & !membership$inrange)
    data.frame(month = m, training_rows = training_rows, largest_model = largest_model, withheld_cells = nrow(cells),
               inside_cells = sum(inside), blocks = blocks, km_10_50_90 = q(cells$km[inside]),
               km_max = if (any(inside)) max(cells$km[inside]) else NA_real_,
               feasible = training_rows >= largest_model && blocks >= CV_MIN_BLOCKS)
  }))
  comparison = do.call(rbind, lapply(seq_len(nrow(feasibility)), function(i) {
    f = feasibility[i, ]
    cells = validation[validation$holdout == f$holdout & validation$month == f$month, ]
    h = outside[outside$month == f$month & outside$direction == f$holdout, ]
    rows = complete_rows(cal, f$month)
    maxima = cv_distance_maxima(cells, target, f$feasible)
    data.frame(holdout = f$holdout, month = f$month, feasible = f$feasible,
               cover_withheld = q(cells$distance), cover_past = q(h$distance),
               km_withheld = q(cells$km), km_past = q(nearest_km(h$x, h$y, cal$x[rows], cal$y[rows])),
               as.list(maxima))
  }))
  previous_file = file.path(previous_run, 'output', 'cross_validation', 'holdouts.rds')
  membership_changes = data.frame(status = 'run 1 holdouts unavailable; provide previous-run directory')
  if (file.exists(previous_file)) {
    previous = readRDS(previous_file)
    previous_rows = match(paste(cal$x, cal$y), paste(previous$membership$x, previous$membership$y))
    membership_changes = do.call(rbind, lapply(seq_len(nrow(directions)), function(i) {
      old = previous$directions$direction[which.min(angle_gap(directions$angle[i], previous$directions$angle))]
      before = previous$membership[[old]][previous_rows]
      after = membership[[directions$direction[i]]]
      data.frame(direction = directions$direction[i], previous_direction = old,
                 angle_change = min(angle_gap(directions$angle[i], previous$directions$angle)),
                 cut = feasibility$cut[match(directions$direction[i], feasibility$holdout)],
                 previous_cut = previous$feasibility$cut[match(old, previous$feasibility$holdout)],
                 cells_compared = sum(!is.na(before)), cells_changed = sum(before != after, na.rm = TRUE),
                 new_cells = sum(is.na(before)))
    }))
  }
  saveRDS(list(protocol_version = 2L, models = CV_MODELS, terms = vapply(CV_MODELS, calibration_terms, ''),
               coefficients = coefficients, directions = directions, membership = membership, feasibility = feasibility,
               validation = validation, target = target, inrange = inrange, inrange_cells = inrange_cells,
               months = months, analysis = cfg$analysis, md5 = unname(input_md5(paths))), cv_file(run_dir, 'holdouts.rds'))
  write_record(run_dir, paths, 'holdouts')
  for (name in c('directions', 'feasibility', 'comparison', 'target', 'inrange', 'exclusions', 'coverage',
                 'nearby_depth', 'nearby_coverage', 'northeast_depth', 'membership_changes'))
    utils::write.csv(get(name), cv_file(run_dir, paste0(name, '.csv')), row.names = FALSE)
  utils::write.csv(validation, cv_file(run_dir, 'validation_cells.csv'), row.names = FALSE)
  plot_directions(cal, outside, directions, membership, cv_file(run_dir, 'directions.pdf'))
  print(feasibility, row.names = FALSE)
  print(exclusions, row.names = FALSE)
  cat("Nearby deep-band coverage, by each cell's own direction:\n")
  print(nearby_coverage[nearby_coverage$cover_band == '[0.1,Inf)', ], row.names = FALSE)
  print(cv_represented_weight(diagnostic$group[cv_scoring_rows(diagnostic, target)], target))
  if (!any(feasibility$feasible)) cat('No useful comparison is feasible; the declared requirements are unchanged.\n')
}

# The cover triangle: modern cells grey, past mixes outside the range coloured by direction, each
# holdout's withheld modern cells circled.
plot_directions = function(cal, outside, directions, membership, file) {
  suppressPackageStartupMessages(library(ggplot2))
  modern = cover_triangle_xy(cal)
  past = cbind(outside['direction'], cover_triangle_xy(outside))
  withheld = do.call(rbind, lapply(directions$direction, function(d) cbind(modern[membership[[d]], ], direction = d)))
  p = ggplot() +
    geom_polygon(aes(px, py), data.frame(px = c(0, 1, 0.5), py = c(0, 0, sqrt(3) / 2)), fill = NA, colour = 'grey40') +
    geom_point(aes(px, py), modern, colour = 'grey70', size = 0.4) +
    geom_point(aes(px, py, colour = direction), past, size = 0.3, alpha = 0.3) +
    geom_point(aes(px, py, colour = direction), withheld, shape = 1, size = 1.2) +
    facet_wrap(~ direction, nrow = 1) + coord_equal() + theme_void() + theme(legend.position = 'none') +
    labs(title = 'Where the past leaves the modern range (one panel per direction), and the cells each holdout withholds',
         subtitle = paste('grey: modern cells; dots: past mixes outside the range (any month); circles: the modern cells withheld',
                          'open land bottom left, summergreen bottom right, evergreen top', sep = '\n'))
  ggsave(file, p, width = 13, height = 5)
}

# --- Stage 2: fits ------------------------------------------------------------------------------

# One candidate in one holdout-month: fitted on the training rows (one retry at a higher step limit
# if it has not converged), then its predictions for the withheld rows. A fit that fails outright is
# recorded, not dropped: its predictions are missing and its status says why (protocol, section 5).
fit_and_predict = function(id, month, train, valid) {
  started = Sys.time()
  result = fit_calibration_retry(id, month, train)
  predicted = rep(NA_real_, nrow(valid))
  if (result$converged) {
    predicted = tryCatch(as.numeric(stats::predict(result$fit, valid, type = 'response')), error = function(e) {
      result$converged <<- FALSE
      result$status <<- paste('ERROR predicting:', conditionMessage(e))
      rep(NA_real_, nrow(valid))
    })
  }
  cat(sprintf('%s %s: %.1f min; %s\n', month, id, as.numeric(difftime(Sys.time(), started, units = 'mins')), result$status))
  attempts = paste(sprintf('%d (maxit %d): %s', result$attempts$attempt, result$attempts$maxit, result$attempts$status), collapse = ' | ')
  out = data.frame(model = id, predicted = predicted, converged = result$converged, status = result$status,
                   warnings = result$warnings, retries = result$retries, attempts = attempts)
  if (!is.null(result$fit)) attr(out, 'fit_summary') = calibration_fit_summary(result$fit)
  out
}

stage_fit = function(run_dir, paths, holdout, months) {
  cal = readRDS(path_file(paths, 'calibration_table'))
  fitted_against = holdouts_md5(run_dir)
  holdouts = readRDS(cv_file(run_dir, 'holdouts.rds'))
  check_inputs(holdouts, paths)
  if (!identical(run_config(run_dir)$analysis, holdouts$analysis)) stop('analysis configuration changed since holdouts')
  withheld = membership_for(holdouts, cal, holdout)
  models = CV_MODELS
  if (holdout == 'inrange') {
    scores = utils::read.csv(cv_file(run_dir, 'scores.csv'))
    if (!any(scores$chosen)) stop('no winner: the winner/model-8 in-range comparison is not defined')
    models = unique(c(CV_INRANGE_MODELS, scores$model[scores$chosen]))
  }
  for (m in months) {
    feasible = if (holdout == 'inrange') holdouts$inrange$feasible[holdouts$inrange$month == m] else
      holdouts$feasibility$feasible[holdouts$feasibility$holdout == holdout & holdouts$feasibility$month == m]
    if (length(feasible) != 1) stop('month or holdout was not frozen in the holdouts stage')
    if (!feasible) { cat(holdout, m, ': not feasible; not fitted\n'); next }
    rows = complete_rows(cal, m)
    train = cal[rows & !withheld, ]
    cells = if (holdout == 'inrange') holdouts$inrange_cells else holdouts$validation
    cells = cells[cells$holdout == holdout & cells$month == m, ]
    valid = cal[cells$calibration_row, ]
    predictions = summaries = NULL
    for (id in models) {
      prediction = fit_and_predict(id, m, train, valid)
      summary = attr(prediction, 'fit_summary')
      if (!is.null(summary)) summaries = rbind(summaries, data.frame(holdout = holdout, month = m, model = id, summary))
      predictions = rbind(predictions, cbind(cells, prediction))
      saveRDS(structure(predictions, holdouts_md5 = fitted_against), cv_file(run_dir, sprintf('predictions_%s_%s.rds', holdout, m)))
      if (!is.null(summaries)) utils::write.csv(summaries, cv_file(run_dir, sprintf('fit_summary_%s_%s.csv', holdout, m)), row.names = FALSE)
    }
    write_record(run_dir, paths, sprintf('fit_%s_%s', holdout, m))
  }
}

# --- Stage 3: scores and the choice -------------------------------------------------------------

# The in-range holdout's reports (protocol, geographic amendment; never used to choose): on withheld
# cells inside their month's remaining training range, each model's score with the expected months
# weighted equally and its paired difference from model 8 (block-resampled standard error); the same
# by distance to the nearest training cell; and by region. A fit that failed or did not converge is a
# missing value; a model missing any expected month has no score ("incomplete"), never a partial one.
inrange_report = function(run_dir, r, models, months) {
  failed = unique(r[!r$converged, c('month', 'model', 'status')])
  r = r[r$distance == 0, ]
  errors = wide_by_model(r, c('month', 'x', 'y', 'km'), ifelse(r$converged, (r$predicted - r$observed)^2, NA), models)
  errors$block = cv_block(errors$x, errors$y)
  errors$group = errors$month
  complete = sapply(models, function(m) sum(sapply(months, function(mo) any(errors$month == mo) && !anyNA(errors[[m]][errors$month == mo]))))
  s = cv_score(errors, data.frame(group = months, weight = 1 / length(months)), models, SEEDS$resample)
  ok = complete == length(months)
  score = ifelse(ok, s$score, NA)
  scores = data.frame(model = models, status = ifelse(ok, 'complete', 'incomplete'), months_complete = complete, months_expected = length(months),
                      score = score, rmse = sqrt(score), difference = score - score[match('mod8', models)],
                      se_difference = ifelse(ok & ok[match('mod8', models)], apply(s$resampled, 2, function(v) stats::sd(v - s$resampled[, 'mod8'])), NA),
                      row.names = NULL)
  utils::write.csv(scores, cv_file(run_dir, 'inrange_scores.csv'), row.names = FALSE)
  utils::write.csv(cv_paired_by_band(errors, data.frame(km_band = as.character(km_band(errors$km))), models, 'mod8', SEEDS$resample),
                   cv_file(run_dir, 'inrange_by_distance.csv'), row.names = FALSE)
  utils::write.csv(cv_by_region(r[r$converged & !is.na(r$predicted), ], LOW_OPEN_LAND), cv_file(run_dir, 'inrange_by_region.csv'), row.names = FALSE)
  cat('\nskill inside the range (reported only; cells inside their training range, expected months equal):\n')
  print(scores, row.names = FALSE, digits = 4)
  if (nrow(failed)) { cat('in-range fits that failed or did not converge:\n'); print(failed, row.names = FALSE) }
}
# Distance errors use common predicted rows for each model/model-8 pair. Weight shares use the
# frozen selection rows, including when a model fails, and far rows always carry zero share.
distance_report = function(errors, signed, target, models, monthly = FALSE) {
  bands = data.frame(holdout = errors$holdout, own_direction = errors$own_direction,
                     cover_band = as.character(distance_band(errors$distance)), km_band = as.character(km_band(errors$km)))
  if (monthly) bands$month = errors$month
  selected = cv_scoring_rows(errors, target)
  all = merge(cv_paired_by_band(errors, bands, models, 'mod8', SEEDS$resample, signed_errors = signed, target = target),
              cv_weight_share(errors$group, target, bands, selected), sort = FALSE)
  all$region = 'all'
  northeast = region_of(errors$x, errors$y) == 'Northeast (hemlock box)'
  if (!any(northeast)) return(all)
  region_bands = data.frame(bands, region = ifelse(northeast, 'northeast', 'elsewhere'))
  shares = cv_weight_share(errors$group, target, region_bands, selected)
  ne = cv_paired_by_band(errors[northeast, ], bands[northeast, ], models, 'mod8', SEEDS$resample,
                          signed_errors = signed[northeast, ], target = target)
  ne$region = 'northeast'
  rbind(all, merge(ne, shares[shares$region == 'northeast', ], sort = FALSE))
}

stage_score = function(run_dir, paths) {
  holdouts = readRDS(cv_file(run_dir, 'holdouts.rds'))
  check_inputs(holdouts, paths)
  if (!identical(run_config(run_dir)$analysis, holdouts$analysis)) stop('analysis configuration changed since holdouts')
  needed = holdouts$feasibility[holdouts$feasibility$feasible, c('holdout', 'month')]
  target = holdouts$target
  coefficients = holdouts$coefficients[CV_MODELS]
  if (!nrow(needed)) {
    scored = cv_score(data.frame(), target, CV_MODELS, SEEDS$resample)
    choice = cv_choose(scored, coefficients, rep(FALSE, length(CV_MODELS)))
    choice$represented = 0
    choice$missing = 1
    utils::write.csv(choice, cv_file(run_dir, 'scores.csv'), row.names = FALSE)
    write_record(run_dir, paths, 'score')
    cat('No useful comparison is feasible; no configuration chosen.\n')
    return(invisible(choice))
  }
  files = cv_file(run_dir, sprintf('predictions_%s_%s.rds', needed$holdout, needed$month))
  if (!all(file.exists(files))) stop('missing fits (run the fit stage first): ', paste(basename(files[!file.exists(files)]), collapse = ', '))
  predictions = read_predictions(run_dir, files)
  frozen = holdouts$validation[holdouts$validation$feasible, ]
  key = function(r) paste(r$holdout, r$month, r$calibration_row)
  for (m in CV_MODELS) {
    r = predictions[predictions$model == m, ]
    if (nrow(r) != nrow(frozen) || anyDuplicated(key(r)) || !setequal(key(r), key(frozen)))
      stop('a candidate does not contain every frozen validation row: ', m)
    common = frozen[match(key(r), key(frozen)), ]
    if (!isTRUE(all.equal(r[, names(common)], common, check.attributes = FALSE, tolerance = 0)))
      stop('prediction geometry differs from the frozen validation rows: ', m)
  }
  ids = c('holdout', 'month', 'x', 'y', 'own_direction', 'group', 'km', 'distance')
  valid_prediction = predictions$converged & is.finite(predictions$predicted)
  errors = wide_by_model(predictions, ids, ifelse(valid_prediction, (predictions$predicted - predictions$observed)^2, NA), CV_MODELS)
  signed = wide_by_model(predictions, ids, ifelse(valid_prediction, predictions$predicted - predictions$observed, NA), CV_MODELS)
  errors$block = cv_block(errors$x, errors$y)
  selected = cv_scoring_rows(errors, target)
  scored = cv_score(errors[selected, ], target, CV_MODELS, seed = SEEDS$resample)
  converged = vapply(CV_MODELS, function(m) all(valid_prediction[predictions$model == m]), TRUE)
  choice = cv_choose(scored, coefficients, eligible = converged)
  choice$represented = scored$represented
  choice$missing = 1 - scored$represented
  choice$selection_rmse_se = apply(sqrt(scored$resampled), 2, stats::sd)
  choice$resamples_missing_a_group = scored$resamples_missing_a_group
  choice$comparison_complete = converged[['mod8']]
  utils::write.csv(choice, cv_file(run_dir, 'scores.csv'), row.names = FALSE)
  utils::write.csv(coverage_table(errors, target), cv_file(run_dir, 'groups.csv'), row.names = FALSE)
  fitted = unique(predictions[, intersect(c('holdout', 'month', 'model', 'converged', 'status', 'warnings', 'retries', 'attempts'), names(predictions))])
  utils::write.csv(fitted, cv_file(run_dir, 'fit_status.csv'), row.names = FALSE)
  tested_months = data.frame(month = holdouts$months, tuned = holdouts$months %in% needed$month)
  utils::write.csv(tested_months, cv_file(run_dir, 'tuned_months.csv'), row.names = FALSE)

  # These pooled errors describe observed predictions; none is a selection score.
  by_month = data.frame(model = character(), month = character(), rmse = numeric(), signed_error = numeric())
  if (any(valid_prediction)) {
    by_month = aggregate(cbind(rmse = (predicted - observed)^2, signed_error = predicted - observed) ~ model + month,
                         predictions[valid_prediction, ], mean)
    by_month$rmse = sqrt(by_month$rmse)
  }
  low = predictions[valid_prediction & predictions$OL <= LOW_OPEN_LAND, ]
  low$evergreen = cut(low$ET, c(0, 0.2, 0.4, 0.6, 1), include.lowest = TRUE)
  low_open_land = data.frame(model = character(), evergreen = character(), rmse = numeric(), signed_error = numeric())
  if (nrow(low)) {
    low_open_land = aggregate(cbind(rmse = (predicted - observed)^2, signed_error = predicted - observed) ~ model + evergreen, low, mean)
    low_open_land$rmse = sqrt(low_open_land$rmse)
  }
  utils::write.csv(by_month, cv_file(run_dir, 'scores_by_month.csv'), row.names = FALSE)
  utils::write.csv(low_open_land, cv_file(run_dir, 'low_open_land.csv'), row.names = FALSE)
  utils::write.csv(cv_by_region(predictions[valid_prediction, ], LOW_OPEN_LAND), cv_file(run_dir, 'by_region.csv'), row.names = FALSE)
  utils::write.csv(distance_report(errors, signed, target, CV_MODELS), cv_file(run_dir, 'by_distance.csv'), row.names = FALSE)
  utils::write.csv(distance_report(errors, signed, target, CV_MODELS, monthly = TRUE), cv_file(run_dir, 'by_distance_month.csv'), row.names = FALSE)
  depth = do.call(rbind, lapply(CV_MODELS, function(m) {
    common = is.finite(errors[[m]]) & is.finite(errors$mod8)
    data.frame(model = m, cv_nearby_depth(errors[common, ], target, holdouts$directions$direction, holdouts$months))
  }))
  utils::write.csv(depth, cv_file(run_dir, 'predicted_nearby_depth.csv'), row.names = FALSE)
  nearby_coverage = cv_nearby_coverage(frozen, target)
  deep = frozen[cv_scoring_rows(frozen, target) & frozen$distance >= .10, ]
  deep_share = sum(nearby_coverage$score_weight_share[nearby_coverage$cover_band == '[0.1,Inf)'])
  writeLines(c(sprintf('Nearby deep cover: %.6f of selection weight; %d cell-month-holdouts, %d unique cells, %d blocks.',
                        deep_share, nrow(deep), nrow(unique(deep[, c('x', 'y')])), length(unique(cv_block(deep$x, deep$y)))),
                'The bootstrap standard error in albedo units is selection_rmse_se in scores.csv.',
                if (converged[['mod8']]) 'Model 8 completed every required fit.' else 'Model 8 failed a required fit: comparison incomplete.',
                if (any(choice$chosen)) paste('Chosen:', choice$model[choice$chosen]) else 'No automatic choice: no eligible model or unsupported uncertainty.'),
              cv_file(run_dir, 'selection_notes.txt'))
  write_record(run_dir, paths, 'score')
  print(choice, row.names = FALSE, digits = 4)
  inrange = Sys.glob(cv_file(run_dir, 'predictions_inrange_*.rds'))
  if (length(inrange) && any(choice$chosen))
    inrange_report(run_dir, read_predictions(run_dir, inrange), models = unique(c(CV_INRANGE_MODELS, choice$model[choice$chosen])),
                   months = holdouts$inrange$month[holdouts$inrange$feasible])
  invisible(choice)
}

if (sys.nframe() == 0L) {
  args = commandArgs(trailingOnly = TRUE)
  usage = 'usage: Rscript tools/cross_validate_albedo.R holdouts <run-dir> [<run-1-dir>] | fit <run-dir> <holdout> <month> [...] | score <run-dir>\n'
  if (length(args) < 2 || !args[1] %in% c('holdouts', 'fit', 'score') || (args[1] == 'fit' && length(args) < 4)) { cat(usage); quit(status = 2) }
  run_dir = args[2]
  paths = pipeline_paths(NULL, redirected_paths(run_dir))
  suppressPackageStartupMessages(library(mgcv))
  switch(args[1],
         holdouts = stage_holdouts(run_dir, paths, if (length(args) >= 3) args[3] else run_dir),
         fit      = stage_fit(run_dir, paths, args[3], check_months(args[-(1:3)])),
         score    = stage_score(run_dir, paths))
}
