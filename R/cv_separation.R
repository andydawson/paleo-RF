# The northeast exchanges and stipulated truths of CV protocol 2, section 6.
# Keep their cells, weights and scaling fixed so changes describe the model, not its inputs.
source('R/training_support.R')
source('R/regions.R')
source('R/random.R')
source('R/calibration_fit.R')

CV_RECOVERY_TRUTHS = c('darkens', 'null', 'shorter')
CV_RECOVERY_REPLICATES = 20L

separation_cell_key = function(data) paste(data$x, data$y)
separation_northeast = function(data) region_of(data$x, data$y) == 'Northeast (hemlock box)'

# Fractions must be physical at both endpoints; never clip or renormalize an exchange.
valid_exchange_rows = function(data) {
  fractions = as.matrix(data[, c('OL', 'ET', 'ST')])
  apply(is.finite(as.matrix(data[, c('x', 'y', 'elev', 'OL', 'ET', 'ST')])), 1, all) &
    rowSums(fractions < 0 | fractions > 1, na.rm = TRUE) == 0 &
    abs(rowSums(fractions) - 1) <= 1e-6
}

freeze_exchange = function(first, second, area) {
  if (nrow(first) != nrow(second) || length(area) != nrow(first) ||
      !isTRUE(all.equal(first[, c('x', 'y', 'elev', 'OL')], second[, c('x', 'y', 'elev', 'OL')],
                        check.attributes = FALSE))) stop('an exchange changed open land, location or elevation')
  valid = valid_exchange_rows(first) & valid_exchange_rows(second) & is.finite(area) & area > 0
  valid[is.na(valid)] = FALSE
  list(first = first[valid, ], second = second[valid, ], area = area[valid],
       weight = area[valid] / sum(area[valid]),
       exclusions = data.frame(candidates = nrow(first), retained = sum(valid), excluded = sum(!valid),
         candidate_area = sum(area[is.finite(area) & area > 0]), retained_area = sum(area[valid])))
}

historical_exchange = function(cells, paleo, area) {
  key = separation_cell_key(cells)
  at6 = paleo[paleo$ages == 6000, ]
  at45 = paleo[paleo$ages == 4500, ]
  if (anyDuplicated(separation_cell_key(at6)) || anyDuplicated(separation_cell_key(at45)))
    stop('duplicate historical cell')
  first = cells[, c('x', 'y', 'elev')]
  first[, c('OL', 'ET', 'ST')] = at6[match(key, separation_cell_key(at6)), c('OL', 'ET', 'ST')]
  second = first
  second$ET = at45$ET[match(key, separation_cell_key(at45))]
  second$ST = 1 - second$OL - second$ET
  freeze_exchange(first, second, area)
}

# Validating both endpoints enforces starting ET/ST >= 0.05; no separate filter is needed.
fixed_exchange = function(cells, area) {
  first = second = cells[, c('x', 'y', 'elev', 'OL', 'ET', 'ST')]
  first$ET = cells$ET - 0.05; first$ST = cells$ST + 0.05
  second$ET = cells$ET + 0.05; second$ST = cells$ST - 0.05
  freeze_exchange(first, second, area)
}

exchange_support = function(exchange, hull) {
  if (!nrow(exchange$first)) return(data.frame(x = numeric(), y = numeric(), area = numeric(),
    weight = numeric(), outside_first = logical(), outside_second = logical(),
    distance_first = numeric(), distance_second = numeric(), outside = logical()))
  a = training_support(exchange$first, hull)
  b = training_support(exchange$second, hull)
  data.frame(exchange$first[, c('x', 'y')], area = exchange$area, weight = exchange$weight,
    outside_first = a$outside, outside_second = b$outside,
    distance_first = a$distance_outside, distance_second = b$distance_outside,
    outside = a$outside | b$outside)
}

exchange_subset = function(exchange, subset) {
  keep = switch(subset, all = rep(TRUE, nrow(exchange$first)),
                inside = !exchange$support$outside, outside = exchange$support$outside)
  result = exchange
  for (name in c('first', 'second', 'support')) result[[name]] = exchange[[name]][keep, , drop = FALSE]
  result$area = exchange$area[keep]
  result$weight = result$area / sum(result$area)
  result
}

# Full Vp retains both between-endpoint and between-cell covariance in the regional SE.
contrast_from_matrix = function(X0, X1, beta, Vp, weight) {
  if (!length(weight)) return(c(contrast = NA_real_, se = NA_real_))
  mu0 = plogis(drop(X0 %*% beta)); mu1 = plogis(drop(X1 %*% beta))
  gradient = colSums(weight * (mu1 * (1 - mu1) * X1 - mu0 * (1 - mu0) * X0))
  c(contrast = sum(weight * (mu1 - mu0)), se = sqrt(drop(gradient %*% Vp %*% gradient)))
}

exchange_contrast = function(fit, exchange) {
  if (!nrow(exchange$first)) return(c(contrast = NA_real_, se = NA_real_))
  contrast_from_matrix(predict(fit, exchange$first, type = 'lpmatrix'),
    predict(fit, exchange$second, type = 'lpmatrix'), coef(fit), fit$Vp, exchange$weight)
}

# These checks also protect AIC: identical response rows in one month, never tuning fits.
check_full_month_rows = function(fit, data, month) {
  rows = data[complete_rows(data, month), ]
  columns = names(fit$model)
  if (!identical(all.vars(formula(fit))[1], month) || !month %in% columns ||
      !all(columns %in% names(rows)) || !identical(rownames(fit$model), rownames(rows)) ||
      !isTRUE(all.equal(fit$model, rows[, columns, drop = FALSE], tolerance = 0, check.attributes = FALSE)))
    stop('fit does not use the identical full-data response and predictor rows for ', month)
  invisible(TRUE)
}

check_reused_model8 = function(fit, data, month) {
  check_full_month_rows(fit, data, month)
  if (!identical(deparse(formula(fit), width.cutoff = 500L),
                 deparse(calibration_formula('mod8', month), width.cutoff = 500L)) ||
      !identical(fit$method, 'REML') || !grepl('^Beta regression', fit$family$family) ||
      !identical(fit$family$link, 'logit') || !fit$control$maxit %in% c(500, 2000) ||
      !isTRUE(fit_converged(fit))) stop('saved prediction fit is not the converged ordinary REML model 8')
  invisible(TRUE)
}

full_month_aic = function(fit, data, month) {
  check_full_month_rows(fit, data, month)
  if (!identical(fit$method, 'REML')) stop('conditional AIC requires the full-data REML fits')
  c(aic = as.numeric(AIC(fit)), smoothing_uncertainty_correction = as.numeric(!is.null(fit$edf2)))
}

freeze_generator = function(data, month, fit) {
  check_reused_model8(fit, data, month)
  rows = data[complete_rows(data, month), ]
  variables = c('OL', 'elev', 'ET', 'y')
  centre = vapply(rows[, variables], mean, 0)
  scale = vapply(rows[, variables], sd, 0)
  short = (rows$y - centre[['y']]) / scale[['y']] +
    sin(2 * pi * rows$y / 4) * cos(2 * pi * rows$x / 8)
  centre = c(centre, short = mean(short)); scale = c(scale, short = sd(short))
  generator = list(a = qlogis(median(rows[[month]])), A = sd(fit$linear.predictors),
                   phi = fit$family$getTheta(TRUE), centre = centre, scale = scale)
  if (any(!is.finite(unlist(generator))) || any(scale <= 0) || generator$A <= 0 || generator$phi <= 0)
    stop('the frozen generator has a nonfinite or zero scale, amplitude or precision')
  generator
}

generator_mean = function(data, generator, truth) {
  if (!truth %in% CV_RECOVERY_TRUTHS) stop('unknown recovery truth: ', truth)
  z = function(variable) (data[[variable]] - generator$centre[[variable]]) / generator$scale[[variable]]
  spatial = z('y')
  if (truth == 'shorter') spatial = (spatial + sin(2 * pi * data$y / 4) * cos(2 * pi * data$x / 8) -
                                     generator$centre[['short']]) / generator$scale[['short']]
  b = if (truth == 'null') 0 else -0.5
  plogis(generator$a + generator$A * (0.5 * z('OL') + 0.25 * z('elev') + b * z('ET') + spatial))
}

generator_contrast = function(exchange, generator, truth) {
  if (!length(exchange$weight)) return(NA_real_)
  sum(exchange$weight * (generator_mean(exchange$second, generator, truth) -
                          generator_mean(exchange$first, generator, truth)))
}

# Only a response vector is saved: all configurations read this one frozen draw.
recovery_response = function(data, month, generator, truth, replicate, base_seed) {
  seed = derive_seed(base_seed, 'cross_validation', 'recovery', month, truth, replicate)
  rows = complete_rows(data, month)
  mu = generator_mean(data[rows, ], generator, truth)
  response = data[[month]]
  # withr_seed is shared with CV and restores the caller's random-number state.
  response[rows] = withr_seed(seed, rbeta(sum(rows), mu * generator$phi, (1 - mu) * generator$phi))
  list(seed = seed, response = response)
}

recovery_models = function(winner) {
  if (length(winner) != 1 || !winner %in% CV_MODELS) stop('recovery needs one selected CV configuration')
  no_location = CV_MODELS[CV_LOCATION_K == 0 & CV_COVER_FORM == CV_COVER_FORM[[winner]]]
  unique(c(winner, 'mod8', no_location))
}

# Missing/failed replicates remain in the report and cannot pass by a reduced denominator.
recovery_statistics = function(contrast, converged, exact, reference, null = FALSE, cells = 1L) {
  complete = length(contrast) == CV_RECOVERY_REPLICATES && length(converged) == length(contrast) &&
    all(converged %in% TRUE) && all(is.finite(contrast))
  testable = cells > 0 && is.finite(exact) && is.finite(reference) && reference != 0 && (null || exact != 0)
  out = data.frame(status = if (!testable) 'untestable' else if (!complete) 'incomplete' else 'fail',
    mean_contrast = NA_real_, bias = NA_real_, rmse = NA_real_, sign_count = NA_integer_,
    mean_absolute_contrast = NA_real_, mcse_mean = NA_real_, mcse_rmse = NA_real_,
    mcse_sign_proportion = NA_real_, mcse_mean_absolute = NA_real_,
    bias_limit = abs(exact) / 2, null_limit = abs(reference) / 4)
  if (!complete || !testable) return(out)
  error = contrast - exact
  out$mean_contrast = mean(contrast); out$bias = mean(error); out$rmse = sqrt(mean(error^2))
  out$mean_absolute_contrast = mean(abs(contrast))
  out$mcse_mean = sd(contrast) / sqrt(length(contrast))
  out$mcse_mean_absolute = sd(abs(contrast)) / sqrt(length(contrast))
  out$mcse_rmse = if (out$rmse == 0) 0 else sd(error^2) / (2 * sqrt(length(error)) * out$rmse)
  if (null) {
    pass = out$mean_absolute_contrast <= out$null_limit
  } else {
    out$sign_count = sum(sign(contrast) == sign(exact))
    p = out$sign_count / length(contrast)
    out$mcse_sign_proportion = sqrt(p * (1 - p) / length(contrast))
    pass = out$sign_count >= 18 && abs(out$bias) <= out$bias_limit
  }
  if (pass) out$status = 'pass'
  out
}

location_concurvity = function(fit, model, compute_concurvity = TRUE) {
  linear = CV_COVER_FORM[[model]] == 'linear'
  out = data.frame(fit_rank = NA_integer_, coefficient_count = NA_integer_,
    cover_rank = NA_integer_, cover_coefficient_count = NA_integer_,
    location_edf = NA_real_, cover_block = if (linear)
    'parametric (intercept and ET/ST)' else 'cover smooth',
    concurvity_reason = if (linear) 'fit unavailable' else
      'not computable: cover fractions sum to one, so the thin-plate cover basis is rank-deficient',
    location_from_cover_worst = NA_real_, location_from_cover_observed = NA_real_,
    location_from_cover_estimate = NA_real_, cover_from_location_worst = NA_real_,
    cover_from_location_observed = NA_real_, cover_from_location_estimate = NA_real_)
  if (CV_LOCATION_K[[model]] == 0) {
    out$cover_block = 'not applicable'
    if (linear) out$concurvity_reason = 'not applicable: no location term'
  }
  if (is.null(fit)) return(out)
  out$fit_rank = fit$rank
  out$coefficient_count = length(coef(fit))
  if (linear) {
    cover_matrix = model.matrix(~ ET + ST, data = fit$model)
  } else {
    cover = which(vapply(fit$smooth, function(s) s$label == 's(OL,ET,ST)', FALSE))
    cover_matrix = mgcv::PredictMat(fit$smooth[[cover]], fit$model)
  }
  out$cover_rank = qr(cover_matrix)$rank
  out$cover_coefficient_count = ncol(cover_matrix)
  if (CV_LOCATION_K[[model]] == 0) return(out)
  terms = calibration_fit_summary(fit)
  out$location_edf = terms$edf[terms$term == 's(x,y)']
  if (!linear) return(out)
  if (!compute_concurvity) { out$concurvity_reason = 'fit did not converge'; return(out) }
  pair = mgcv::concurvity(fit, full = FALSE)
  values = location_cover_concurvity(pair, 'para')
  out[names(values)] = values
  out$concurvity_reason = ''
  out
}

# mgcv's pairwise matrices put the explaining term in rows and the explained term in columns.
location_cover_concurvity = function(pair, cover) {
  out = list()
  for (measure in c('worst', 'observed', 'estimate')) {
    out[[paste0('location_from_cover_', measure)]] = pair[[measure]][cover, 's(x,y)']
    out[[paste0('cover_from_location_', measure)]] = pair[[measure]]['s(x,y)', cover]
  }
  out
}
