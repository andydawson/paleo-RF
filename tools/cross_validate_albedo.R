# Cross-validation that chooses the albedo model on its accuracy for cover mixes beyond the modern
# range: the protocol Chris approved on 2 November 2026 (docs/cc/2026-11-02_cv_protocol.md). The
# functions are in R/cross_validation.R; this tool reads a finished run and runs the protocol's three
# stages, each a separate command so that Chris sees the holdouts before any model is fitted:
#
#   Rscript tools/cross_validate_albedo.R holdouts <run-dir>
#       the directions, the withheld cells, the feasibility of each month and holdout, and how the
#       withheld cells' distances compare with the hindcast's (minutes; no model fitted).
#   Rscript tools/cross_validate_albedo.R fit <run-dir> <holdout> <month> [<month> ...]
#       fits the thirteen candidates (CV_MODELS, R/model_registry.R) without that holdout's cells and
#       predicts them (hours). Holdout "inrange" (skill inside the range, reported only) fits the
#       location pairs (CV_INRANGE_MODELS) and the chosen model, after the score stage; run the score
#       stage again afterwards for its reports.
#   Rscript tools/cross_validate_albedo.R score <run-dir>
#       the scores, their uncertainty and the choice, with the checks reported beside them.
#
# <run-dir> is the directory a run wrote into (its config's run$dir). It needs that run's
# configuration (config_used.R, as tools/verify_change.R writes it; else the repository's config.R),
# calibration table (script 2), past cover (script 1) and albedo differences (script 7a, for each
# cell's area and ice fraction). Results go to <run-dir>/output/cross_validation/, with a record of
# the code version, the inputs' MD5 sums and the seeds.

source('R/config.R')
source('R/paths.R')                 # brings R/model_registry.R
source('R/random.R')
source('R/run_manifest.R')         # code_version(), for the record of each stage
source('R/cross_validation.R')

CV_SEED        = 1549466984         # the refit runs' fixed seed (Chris, 31 October 2026)
CV_RETRY_MAXIT = 2000               # one retry for a fit that has not converged (protocol, section 5)
LOW_OPEN_LAND  = 0.2                # "low open land" for the evergreen-share check (implementer's choice)
SEEDS = list(inrange = derive_seed(CV_SEED, 'cross_validation', 'inrange'),
             resample = derive_seed(CV_SEED, 'cross_validation', 'resample'))

cv_file = function(run_dir, name) {
  dir = file.path(run_dir, 'output', 'cross_validation')
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
  if (!identical(unname(now[1]), unname(holdouts$md5[1]))) stop('the calibration table changed since the holdouts were made')
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
  writeLines(c(paste('stage:', stage), paste('time:', format(Sys.time(), tz = 'UTC', usetz = TRUE)),
               paste('commit:', v$commit), paste('branch:', v$branch), paste('uncommitted changes:', v$dirty),
               paste('input', names(input_md5(paths)), input_md5(paths)),
               paste('seed', names(SEEDS), unlist(SEEDS))), cv_file(run_dir, paste0('record_', stage, '.txt')))
}

# Great-circle distance (km) from each cell a to the nearest of the cells b (one-degree centres).
nearest_km = function(ax, ay, bx, by) {
  r = pi / 180
  vapply(seq_along(ax), function(i) min(6371 * acos(pmin(1, sin(ay[i] * r) * sin(by * r) +
                                                          cos(ay[i] * r) * cos(by * r) * cos((bx - ax[i]) * r)))), 0)
}

# --- Stage 1: holdouts --------------------------------------------------------------------------
stage_holdouts = function(run_dir, paths) {
  cfg = run_config(run_dir)
  cal = readRDS(path_file(paths, 'calibration_table'))
  months = cfg$analysis$months
  paleo = readRDS(path_file(paths, 'lct_paleo'))
  domain = cfg$analysis$domain
  hindcast = cv_target_weights(paleo, readRDS(path_file(paths, 'albedo_differences')), cfg$analysis$ages,
                               length(months), domain$lat_min, domain$lat_max)
  in_window = paleo$ages %in% cfg$analysis$ages[-1] & paleo$y > domain$lat_min & paleo$y < domain$lat_max
  cat(sprintf('past cell-slices in the target (%g-%g N): %d, of which %d have an area and ice fraction\n',
              domain$lat_min, domain$lat_max, sum(in_window), nrow(hindcast)))

  # Every past mix's distance outside each month's training range, and its direction.
  per_month = do.call(rbind, lapply(months, function(m) {
    hull = training_hull(cal[complete_rows(cal, m), ])
    cbind(hindcast[, c('x', 'y', 'ages', 'OL', 'ET', 'ST', 'weight')], month = m,
          distance = training_support(hindcast, hull)$distance_outside, angle = departure_angle(hindcast, hull))
  }))
  directions = cv_directions(per_month$angle, per_month$weight)
  outside = per_month[!is.na(per_month$angle), ]
  outside$direction = nearest_direction(outside$angle, directions)
  outside$group = paste(outside$month, outside$direction, distance_band(outside$distance))
  target = aggregate(weight ~ group + month + direction, outside, sum)
  cat(sprintf('target weight outside the month\'s training range: %.1f%%\n', 100 * sum(outside$weight)))
  # The shares the score uses (each mix in its nearest direction), and how much of each lies within
  # 30 degrees of its direction's mean, so a small family of departures is not lost silently.
  directions$share = as.numeric(tapply(outside$weight, outside$direction, sum)[directions$direction]) / sum(outside$weight)
  directions$share_within_30 = sapply(seq_len(nrow(directions)), function(i) {
    o = outside[outside$direction == directions$direction[i], ]
    sum(o$weight[angle_gap(o$angle, directions$angle[i]) <= 30]) / sum(o$weight)
  })

  # One holdout per direction at the 80th percentile; the 70th, then the 90th, only for a direction
  # that fails in every month (protocol, sections 3-4, amended 3 November).
  largest_model = sapply(months, function(m) max(sapply(CV_MODELS, model_coefficients, month = m, data = cal)))
  feasibility_of = function(withheld, holdout, cut) do.call(rbind, lapply(months, function(m) {
    rows = complete_rows(cal, m)
    train = rows & !withheld
    valid = rows & withheld
    withheld_cells = cal[valid, ]
    departure = withheld_departure(withheld_cells, training_hull(cal[train, ]), directions, m)
    if (!all(departure$outside)) stop('a withheld cell lies inside its training range: ', holdout, ', ', m)
    # The blocks are counted on the withheld cells the score uses: those in a group with positive
    # target weight (Chris, 3 November).
    scored = departure$group %in% target$group[target$weight > 0]
    blocks = length(unique(cv_block(withheld_cells$x[scored], withheld_cells$y[scored])))
    data.frame(holdout = holdout, cut = cut, month = m, training_rows = sum(train), largest_model = largest_model[[m]],
               withheld_cells = sum(valid), scored_cells = sum(scored), blocks = blocks,
               feasible = sum(train) >= largest_model[[m]] && blocks >= CV_MIN_BLOCKS)
  }))
  membership = cal[, c('x', 'y')]
  feasibility = NULL
  for (i in seq_len(nrow(directions))) {
    for (cut in CV_CUTS) {
      withheld = cv_holdouts(cal, directions$angle[i], cut)
      cut_feasibility = feasibility_of(withheld, directions$direction[i], cut)
      if (any(cut_feasibility$feasible)) break
    }
    membership[[directions$direction[i]]] = withheld
    feasibility = rbind(feasibility, cut_feasibility)
  }
  q = function(v) paste(if (length(v)) signif(stats::quantile(v, c(0.1, 0.5, 0.9), names = FALSE), 2) else rep(NA, 3), collapse = ' / ')
  # Skill inside the range (reported only): a fifth of the geographic blocks, seeded.
  blocks = cv_block(cal$x, cal$y)
  picked = withr_seed(SEEDS$inrange, sample(sort(unique(blocks)), round(length(unique(blocks)) / 5)))
  membership$inrange = blocks %in% picked
  # The in-range holdout's support, fixed before any fit (protocol, geographic amendment): its scored
  # cells are the withheld cells inside their month's remaining training range; a month needs enough
  # training rows for the largest model and scored cells in CV_MIN_BLOCKS blocks, else it is untested.
  inrange = do.call(rbind, lapply(months, function(m) {
    rows = complete_rows(cal, m)
    train = rows & !membership$inrange
    valid = rows & membership$inrange
    inside = !training_support(cal[valid, ], training_hull(cal[train, ]))$outside
    km = nearest_km(cal$x[valid][inside], cal$y[valid][inside], cal$x[train], cal$y[train])
    blocks = length(unique(cv_block(cal$x[valid][inside], cal$y[valid][inside])))
    data.frame(month = m, training_rows = sum(train), largest_model = largest_model[[m]], withheld_cells = sum(valid),
               inside_cells = sum(inside), blocks = blocks, km_10_50_90 = q(round(km)), km_max = if (length(km)) round(max(km)) else NA,
               feasible = sum(train) >= largest_model[[m]] && blocks >= CV_MIN_BLOCKS)
  }))

  # How the withheld cells compare with the hindcast (protocol, section 4): distance outside the
  # training range (cover) and to the nearest training cell (km); 10th / 50th / 90th percentiles.
  comparison = do.call(rbind, lapply(directions$direction, function(d) do.call(rbind, lapply(months, function(m) {
    rows = complete_rows(cal, m)
    train = rows & !membership[[d]]
    valid = rows & membership[[d]]
    h = outside[outside$month == m & outside$direction == d, ]
    data.frame(direction = d, month = m,
               cover_withheld = q(training_support(cal[valid, ], training_hull(cal[train, ]))$distance_outside),
               cover_past = q(h$distance),
               km_withheld = q(round(nearest_km(cal$x[valid], cal$y[valid], cal$x[train], cal$y[train]))),
               km_past = q(round(nearest_km(h$x, h$y, cal$x[rows], cal$y[rows]))))
  }))))

  saveRDS(list(directions = directions, membership = membership, feasibility = feasibility, target = target,
               inrange = inrange, months = months, md5 = unname(input_md5(paths))), cv_file(run_dir, 'holdouts.rds'))   # unnamed: a moved run folder keeps the same holdouts
  write_record(run_dir, paths, 'holdouts')
  for (name in c('directions', 'feasibility', 'comparison', 'target', 'inrange'))
    utils::write.csv(get(name), cv_file(run_dir, paste0(name, '.csv')), row.names = FALSE)
  plot_directions(cal, outside, directions, membership, cv_file(run_dir, 'directions.pdf'))
  cat('\ndirections (angle on the cover triangle: 0 = more summergreen, 90 = more evergreen):\n'); print(directions)
  cat('\nfeasibility of each holdout and month:\n'); print(feasibility, row.names = FALSE)
  cat('\nwithheld cells against the past (10th / 50th / 90th percentiles):\n'); print(comparison, row.names = FALSE)
  cat('\nthe in-range holdout (reported only):\n'); print(inrange, row.names = FALSE)
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
  warnings = character()
  started = Sys.time()
  attempt = function(control) withCallingHandlers(fit_calibration_model(id, month, train, control = control),
    warning = function(w) { warnings <<- c(warnings, conditionMessage(w)); invokeRestart('muffleWarning') })
  result = tryCatch({
    fit = attempt(CALIBRATION_CONTROL)
    if (!fit_converged(fit)) fit = attempt(modifyList(CALIBRATION_CONTROL, list(maxit = CV_RETRY_MAXIT)))
    list(predicted = as.numeric(stats::predict(fit, valid, type = 'response')), converged = fit_converged(fit),
         status = fit_convergence(fit))
  }, error = function(e) list(predicted = rep(NA_real_, nrow(valid)), converged = FALSE, status = paste('ERROR:', conditionMessage(e))))
  cat(sprintf('%s %s: %.1f min; %s\n', month, id, as.numeric(difftime(Sys.time(), started, units = 'mins')), result$status))
  data.frame(model = id, predicted = result$predicted, converged = result$converged, status = result$status,
             warnings = paste(unique(warnings), collapse = ' | '))
}

stage_fit = function(run_dir, paths, holdout, months) {
  cal = readRDS(path_file(paths, 'calibration_table'))
  fitted_against = holdouts_md5(run_dir)   # taken with the load, so a rebuild during the fits cannot relabel them
  holdouts = readRDS(cv_file(run_dir, 'holdouts.rds'))
  check_inputs(holdouts, paths)
  if (holdout == 'inrange' && is.null(holdouts$inrange)) stop('holdouts.rds has no in-range support table: rerun the holdouts stage')
  withheld = membership_for(holdouts, cal, holdout)
  models = if (holdout == 'inrange') {
    scores = utils::read.csv(cv_file(run_dir, 'scores.csv'))
    unique(c(CV_INRANGE_MODELS, scores$model[scores$chosen]))
  } else CV_MODELS
  for (m in months) {
    feasible = if (holdout == 'inrange') holdouts$inrange$feasible[holdouts$inrange$month == m] else
      holdouts$feasibility$feasible[holdouts$feasibility$holdout == holdout & holdouts$feasibility$month == m]
    if (!feasible) {
      cat(holdout, m, ': not feasible (holdouts stage); not fitted\n')
      next
    }
    rows = complete_rows(cal, m)
    train = cal[rows & !withheld, ]
    valid = cal[rows & withheld, ]
    # Each withheld cell's own departure from its training range and its group, kept beside its holdout.
    departure = withheld_departure(valid, training_hull(train), holdouts$directions, m)
    cells = data.frame(holdout = holdout, month = m, x = valid$x, y = valid$y, OL = valid$OL, ET = valid$ET, ST = valid$ST,
                       departure[, c('distance', 'angle', 'own_direction', 'group')],
                       km = nearest_km(valid$x, valid$y, train$x, train$y), observed = valid[[m]])
    file = cv_file(run_dir, sprintf('predictions_%s_%s.rds', holdout, m))
    predictions = NULL
    for (id in models) {   # saved after every candidate, so a later failure loses nothing
      predictions = rbind(predictions, cbind(cells, fit_and_predict(id, m, train, valid)))
      saveRDS(structure(predictions, holdouts_md5 = fitted_against), file)
    }
    write_record(run_dir, paths, sprintf('fit_%s_%s', holdout, m))   # one record per fitted month
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
stage_score = function(run_dir, paths) {
  cal = readRDS(path_file(paths, 'calibration_table'))
  holdouts = readRDS(cv_file(run_dir, 'holdouts.rds'))
  check_inputs(holdouts, paths)
  needed = holdouts$feasibility[holdouts$feasibility$feasible, c('holdout', 'month')]
  files = cv_file(run_dir, sprintf('predictions_%s_%s.rds', needed$holdout, needed$month))
  if (!all(file.exists(files))) stop('missing fits (run the fit stage first): ', paste(basename(files[!file.exists(files)]), collapse = ', '))
  predictions = read_predictions(run_dir, files)
  if (!all(CV_MODELS %in% predictions$model) || !all(table(predictions$model)[CV_MODELS] == nrow(predictions) / length(CV_MODELS)))
    stop('the candidates were not all fitted on every holdout and month (rerun the fit stage)')
  # A withheld cell counts under the direction in which it lies outside its own fold's training range,
  # as the past mixes do, not under its holdout's (Chris, 3 November, frozen before any score).
  cat(sprintf('withheld cell-months whose own direction differs from their holdout\'s: %d of %d\n',
              sum(predictions$own_direction != predictions$holdout, na.rm = TRUE) / length(CV_MODELS), nrow(predictions) / length(CV_MODELS)))
  ids = c('holdout', 'month', 'x', 'y', 'group', 'km', 'distance')
  errors = wide_by_model(predictions, ids, (predictions$predicted - predictions$observed)^2, CV_MODELS)
  errors$block = cv_block(errors$x, errors$y)

  # Every group the withheld cells fall in has a target weight (0 where no past mix lies there).
  target = merge(data.frame(group = unique(errors$group)), holdouts$target[, c('group', 'weight')], all = TRUE)
  target$weight[is.na(target$weight)] = 0
  groups = merge(target, as.data.frame(table(group = errors$group), responseName = 'withheld_cell_months'), all.x = TRUE)
  utils::write.csv(groups, cv_file(run_dir, 'groups.csv'), row.names = FALSE)
  scored = cv_score(errors, target, CV_MODELS, seed = SEEDS$resample)
  coefficients = sapply(CV_MODELS, model_coefficients, month = needed$month[1], data = cal)
  # A candidate with any fit that failed or did not converge cannot be chosen (its score may be missing).
  converged = tapply(predictions$converged, predictions$model, all)[CV_MODELS]
  choice = cv_choose(scored, coefficients, eligible = !(CV_MODELS %in% CV_BASELINES) & converged)
  choice$represented = scored$represented
  utils::write.csv(choice, cv_file(run_dir, 'scores.csv'), row.names = FALSE)

  # Reported beside the choice, never used for it (protocol, section 6); from converged fits only, as
  # the choice trusts no other.
  ok = !is.na(predictions$predicted) & predictions$converged
  by_month = aggregate(cbind(rmse = (predicted - observed)^2, signed_error = predicted - observed) ~ model + month, predictions[ok, ], mean)
  by_month$rmse = sqrt(by_month$rmse)
  low = predictions[ok & predictions$OL <= LOW_OPEN_LAND, ]
  low$evergreen = cut(low$ET, c(0, 0.2, 0.4, 0.6, 1), include.lowest = TRUE)
  low_open_land = if (nrow(low)) aggregate(cbind(signed_error = predicted - observed) ~ model + evergreen, low, mean) else NULL
  utils::write.csv(by_month, cv_file(run_dir, 'scores_by_month.csv'), row.names = FALSE)
  if (!is.null(low_open_land)) utils::write.csv(low_open_land, cv_file(run_dir, 'low_open_land.csv'), row.names = FALSE)
  utils::write.csv(cv_by_region(predictions[ok, ], LOW_OPEN_LAND), cv_file(run_dir, 'by_region.csv'), row.names = FALSE)
  # Whether a candidate's advantage over model 8 sits in the cells far from training: paired
  # differences by distance to the nearest training cell, within cover-distance band, failed fits
  # dropped one by one (protocol, geographic amendment; no extra fits); with each band's share of the
  # selection score's weight (a row's weight is its group's target weight shared among its rows).
  converged_errors = wide_by_model(predictions, ids, ifelse(predictions$converged, (predictions$predicted - predictions$observed)^2, NA), CV_MODELS)
  converged_errors$block = errors$block
  bands = data.frame(km_band = as.character(km_band(errors$km)), cover_band = as.character(distance_band(errors$distance)))
  by_distance = merge(cv_paired_by_band(converged_errors, bands, CV_MODELS, 'mod8', SEEDS$resample),
                      cv_weight_share(errors$group, target, bands), sort = FALSE)
  utils::write.csv(by_distance, cv_file(run_dir, 'by_distance.csv'), row.names = FALSE)
  write_record(run_dir, paths, 'score')

  cat(sprintf('holdout-months scored: %d; withheld cell-months: %d; geographic blocks: %d\n',
              nrow(needed), nrow(errors), length(unique(errors$block))))
  cat(sprintf('share of the outside target represented: %.1f%%; resamples missing a weighted group: %d of %d\n\n',
              100 * scored$represented, scored$resamples_missing_a_group, nrow(scored$resampled)))
  print(choice, row.names = FALSE, digits = 4)
  failed = unique(predictions[!predictions$converged, c('holdout', 'month', 'model', 'status')])
  if (nrow(failed)) { cat('\nfits that failed or did not converge:\n'); print(failed, row.names = FALSE) }
  if (!choice$eligible[choice$model == 'mod8']) cat('\nmodel 8 cannot be chosen: the comparison is incomplete\n')
  cat('\nchosen:', if (any(choice$chosen)) choice$model[choice$chosen] else 'none (the resampled uncertainty is not finite)', '\n')
  inrange = Sys.glob(cv_file(run_dir, 'predictions_inrange_*.rds'))
  if (length(inrange))
    inrange_report(run_dir, read_predictions(run_dir, inrange), models = unique(c(CV_INRANGE_MODELS, choice$model[choice$chosen])),
                   months = holdouts$inrange$month[holdouts$inrange$feasible])
}

if (sys.nframe() == 0L) {
  args = commandArgs(trailingOnly = TRUE)
  usage = 'usage: Rscript tools/cross_validate_albedo.R holdouts <run-dir> | fit <run-dir> <holdout> <month> [...] | score <run-dir>\n'
  if (length(args) < 2 || !args[1] %in% c('holdouts', 'fit', 'score') || (args[1] == 'fit' && length(args) < 4)) { cat(usage); quit(status = 2) }
  run_dir = args[2]
  paths = pipeline_paths(NULL, redirected_paths(run_dir))
  suppressPackageStartupMessages(library(mgcv))
  switch(args[1],
         holdouts = stage_holdouts(run_dir, paths),
         fit      = stage_fit(run_dir, paths, args[3], check_months(args[-(1:3)])),
         score    = stage_score(run_dir, paths))
}
