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
#       predicts them (hours). Holdout "inrange" (skill inside the range, reported only) fits only
#       model 8 and the chosen model, after the score stage.
#   Rscript tools/cross_validate_albedo.R score <run-dir>
#       the scores, their uncertainty and the choice, with the checks reported beside them.
#
# <run-dir> is the directory a run wrote into (its config's run$dir). It needs that run's
# calibration table (script 2), past cover (script 1) and albedo differences (script 7a, for each
# cell's area and ice fraction). Results go to <run-dir>/output/cross_validation/.

source('R/config.R')
source('R/paths.R')                 # brings R/model_registry.R
source('R/random.R')
source('R/cross_validation.R')

CV_SEED        = 1549466984         # the refit runs' fixed seed (Chris, 31 October 2026)
CV_RETRY_MAXIT = 2000               # one retry for a fit that has not converged (protocol, section 5)
LOW_OPEN_LAND  = 0.2                # "low open land" for the evergreen-share check (implementer's choice)

cv_file = function(run_dir, name) {
  dir = file.path(run_dir, 'output', 'cross_validation')
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  file.path(dir, name)
}

# The rows a month's models are fitted on or scored on: albedo and every predictor present.
complete_rows = function(cal, month) stats::complete.cases(cal[, c(month, CALIBRATION_PREDICTORS)])

# The months of the calibration table that have any albedo.
calibration_months = function(cal) Filter(function(m) m %in% names(cal) && any(!is.na(cal[[m]])), MONTHS)

# Great-circle distance (km) from each cell a to the nearest of the cells b (one-degree centres).
nearest_km = function(ax, ay, bx, by) {
  r = pi / 180
  vapply(seq_along(ax), function(i) min(6371 * acos(pmin(1, sin(ay[i] * r) * sin(by * r) +
                                                          cos(ay[i] * r) * cos(by * r) * cos((bx - ax[i]) * r)))), 0)
}

# --- Stage 1: holdouts --------------------------------------------------------------------------
stage_holdouts = function(run_dir, paths) {
  cal = readRDS(path_file(paths, 'calibration_table'))
  months = calibration_months(cal)
  paleo = readRDS(path_file(paths, 'lct_paleo'))
  diffs = readRDS(path_file(paths, 'albedo_differences'))
  slices = sort(unique(paleo$ages))

  # Each past cell-slice's area and ice fraction: script 7a's pairs give the younger end, and the
  # oldest slice is the older end of the last pair. Ice does not depend on the month.
  d1 = diffs[diffs$month == diffs$month[1], ]
  ice = unique(rbind(data.frame(x = d1$x, y = d1$y, ages = d1$year, area = as.numeric(d1$area), ice = d1$ice_frac_young),
                     data.frame(x = d1$x, y = d1$y, ages = slices[match(d1$year, slices) + 1], area = as.numeric(d1$area), ice = d1$ice_frac_old)))
  hindcast = merge(paleo[paleo$ages != min(slices), ], ice, by = c('x', 'y', 'ages'))
  cat(sprintf('past cell-slices with an area and ice fraction (script 7a): %d of %d\n',
              nrow(hindcast), sum(paleo$ages != min(slices))))
  # Target weight (protocol, section 2): slices and months equally; within a slice, area x ice-free.
  ice_free_area = hindcast$area * (1 - hindcast$ice)
  hindcast$weight = ice_free_area / ave(ice_free_area, hindcast$ages, FUN = sum) / length(unique(hindcast$ages)) / length(months)

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

  # One holdout per direction, at the first cut feasible in the most months (protocol, sections 3-4).
  largest_model = sapply(months, function(m) max(sapply(CV_MODELS, model_coefficients, month = m, data = cal)))
  feasibility_of = function(withheld, holdout, cut) do.call(rbind, lapply(months, function(m) {
    rows = complete_rows(cal, m)
    train = rows & !withheld
    valid = rows & withheld
    if (any(valid) && !all(training_support(cal[valid, ], training_hull(cal[train, ]))$outside))
      stop('a withheld cell lies inside its training range: ', holdout, ', ', m)
    blocks = length(unique(cv_block(cal$x[valid], cal$y[valid])))
    data.frame(holdout = holdout, cut = cut, month = m, training_rows = sum(train), largest_model = largest_model[[m]],
               withheld_cells = sum(valid), blocks = blocks,
               feasible = sum(train) >= largest_model[[m]] && blocks >= CV_MIN_BLOCKS)
  }))
  membership = cal[, c('x', 'y')]
  feasibility = NULL
  for (i in seq_len(nrow(directions))) {
    options = lapply(CV_CUTS, function(cut) {
      withheld = cv_holdouts(cal, directions$angle[i], cut)
      list(withheld = withheld, table = feasibility_of(withheld, directions$direction[i], cut))
    })
    best = options[[which.max(sapply(options, function(o) sum(o$table$feasible)))]]
    membership[[directions$direction[i]]] = best$withheld
    feasibility = rbind(feasibility, best$table)
  }
  # Skill inside the range (reported only): a fifth of the geographic blocks, seeded.
  blocks = cv_block(cal$x, cal$y)
  picked = withr_seed(derive_seed(CV_SEED, 'cross_validation', 'inrange'),
                      sample(sort(unique(blocks)), round(length(unique(blocks)) / 5)))
  membership$inrange = blocks %in% picked

  # How the withheld cells compare with the hindcast (protocol, section 4): distance outside the
  # training range (cover) and to the nearest training cell (km); 10th / 50th / 90th percentiles.
  q = function(v) paste(if (length(v)) signif(stats::quantile(v, c(0.1, 0.5, 0.9), names = FALSE), 2) else rep(NA, 3), collapse = ' / ')
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
               months = months), cv_file(run_dir, 'holdouts.rds'))
  for (name in c('directions', 'feasibility', 'comparison', 'target'))
    utils::write.csv(get(name), cv_file(run_dir, paste0(name, '.csv')), row.names = FALSE)
  plot_directions(cal, outside, directions, membership, cv_file(run_dir, 'directions.pdf'))
  cat('\ndirections (angle on the cover triangle: 0 = more summergreen, 90 = more evergreen):\n'); print(directions)
  cat('\nfeasibility of each holdout and month:\n'); print(feasibility, row.names = FALSE)
  cat('\nwithheld cells against the past (10th / 50th / 90th percentiles):\n'); print(comparison, row.names = FALSE)
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

# Did a fit converge: the fitting loop stopped before its limit and the smoothing-parameter
# optimiser reports full convergence (the checks of fit_convergence(), R/model_registry.R).
fit_converged = function(fit) fit$iter < fit$control$maxit && identical(fit$outer.info$conv, 'full convergence')

stage_fit = function(run_dir, paths, holdout, months) {
  cal = readRDS(path_file(paths, 'calibration_table'))
  holdouts = readRDS(cv_file(run_dir, 'holdouts.rds'))
  withheld = holdouts$membership[[holdout]]
  if (is.null(withheld)) stop('no holdout called ', holdout, '; holdouts: ', paste(setdiff(names(holdouts$membership), c('x', 'y')), collapse = ', '))
  models = if (holdout == 'inrange') {
    scores = utils::read.csv(cv_file(run_dir, 'scores.csv'))
    unique(c('mod8', scores$model[scores$chosen]))
  } else CV_MODELS
  for (m in months) {
    if (holdout != 'inrange' && !holdouts$feasibility$feasible[holdouts$feasibility$holdout == holdout & holdouts$feasibility$month == m]) {
      cat(holdout, m, ': not feasible (holdouts stage); not fitted\n')
      next
    }
    rows = complete_rows(cal, m)
    train = cal[rows & !withheld, ]
    valid = cal[rows & withheld, ]
    distance = training_support(valid, training_hull(train))$distance_outside
    predictions = do.call(rbind, lapply(models, function(id) {
      started = Sys.time()
      fit = suppressWarnings(fit_calibration_model(id, m, train))
      if (!fit_converged(fit))
        fit = suppressWarnings(fit_calibration_model(id, m, train, control = modifyList(CALIBRATION_CONTROL, list(maxit = CV_RETRY_MAXIT))))
      cat(sprintf('%s %s %s: %.1f min; %s\n', holdout, m, id, as.numeric(difftime(Sys.time(), started, units = 'mins')), fit_convergence(fit)))
      data.frame(holdout = holdout, month = m, model = id, x = valid$x, y = valid$y, OL = valid$OL, ET = valid$ET, ST = valid$ST,
                 distance = distance, observed = valid[[m]], predicted = as.numeric(stats::predict(fit, valid, type = 'response')),
                 converged = fit_converged(fit))
    }))
    saveRDS(predictions, cv_file(run_dir, sprintf('predictions_%s_%s.rds', holdout, m)))
  }
}

# --- Stage 3: scores and the choice -------------------------------------------------------------
stage_score = function(run_dir, paths) {
  cal = readRDS(path_file(paths, 'calibration_table'))
  holdouts = readRDS(cv_file(run_dir, 'holdouts.rds'))
  needed = holdouts$feasibility[holdouts$feasibility$feasible, c('holdout', 'month')]
  files = cv_file(run_dir, sprintf('predictions_%s_%s.rds', needed$holdout, needed$month))
  if (!all(file.exists(files))) stop('missing fits (run the fit stage first): ', paste(basename(files[!file.exists(files)]), collapse = ', '))
  predictions = do.call(rbind, lapply(files, readRDS))
  predictions$group = paste(predictions$month, predictions$holdout, distance_band(predictions$distance))
  predictions$squared_error = (predictions$predicted - predictions$observed)^2
  errors = stats::reshape(predictions[, c('holdout', 'month', 'x', 'y', 'group', 'model', 'squared_error')],
                          idvar = c('holdout', 'month', 'x', 'y', 'group'), timevar = 'model', direction = 'wide')
  names(errors) = sub('^squared_error\\.', '', names(errors))
  if (!all(CV_MODELS %in% names(errors)) || anyNA(errors[CV_MODELS])) stop('a candidate lacks predictions for some withheld cells')
  errors$block = cv_block(errors$x, errors$y)

  # Every group the withheld cells fall in has a target weight (0 where no past mix lies there).
  target = merge(data.frame(group = unique(errors$group)), holdouts$target[, c('group', 'weight')], all = TRUE)
  target$weight[is.na(target$weight)] = 0
  scored = cv_score(errors, target, CV_MODELS, seed = derive_seed(CV_SEED, 'cross_validation', 'resample'))
  coefficients = sapply(CV_MODELS, model_coefficients, month = needed$month[1], data = cal)
  converged = tapply(predictions$converged, predictions$model, all)[CV_MODELS]
  choice = cv_choose(scored, coefficients, eligible = !(CV_MODELS %in% CV_BASELINES) & converged)
  utils::write.csv(choice, cv_file(run_dir, 'scores.csv'), row.names = FALSE)

  # Reported beside the choice, never used for it (protocol, section 6).
  by_month = aggregate(cbind(rmse = (predicted - observed)^2, signed_error = predicted - observed) ~ model + month, predictions, mean)
  by_month$rmse = sqrt(by_month$rmse)
  low = predictions[predictions$OL <= LOW_OPEN_LAND, ]
  low$evergreen = cut(low$ET, c(0, 0.2, 0.4, 0.6, 1), include.lowest = TRUE)
  low_open_land = if (nrow(low)) aggregate(cbind(signed_error = predicted - observed) ~ model + evergreen, low, mean) else NULL
  utils::write.csv(by_month, cv_file(run_dir, 'scores_by_month.csv'), row.names = FALSE)
  if (!is.null(low_open_land)) utils::write.csv(low_open_land, cv_file(run_dir, 'low_open_land.csv'), row.names = FALSE)

  cat(sprintf('holdout-months scored: %d; withheld cell-months: %d; geographic blocks: %d\n',
              nrow(needed), nrow(errors), length(unique(errors$block))))
  cat(sprintf('share of the outside target represented: %.1f%%\n\n', 100 * scored$represented))
  print(choice, row.names = FALSE, digits = 4)
  cat('\nchosen:', choice$model[choice$chosen], '\n')
  inrange = Sys.glob(cv_file(run_dir, 'predictions_inrange_*.rds'))
  if (length(inrange)) {
    r = do.call(rbind, lapply(inrange, readRDS))
    cat('\nskill inside the range (reported only), RMSE:\n')
    print(aggregate(cbind(rmse = (predicted - observed)^2) ~ model, r, function(e) sqrt(mean(e))), row.names = FALSE)
  }
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
