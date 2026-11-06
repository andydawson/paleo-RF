# Hand-worked exchanges, frozen truths and protocol-2 pass rules. No model is fitted.
suppressMessages(source('tools/check_cv_separation.R'))
equal = function(a, b) isTRUE(all.equal(a, b, check.attributes = FALSE))
fails = function(expression) inherits(try(force(expression), silent = TRUE), 'try-error')

cells = data.frame(x = c(-75, -74, -73, -72), y = c(42, 43, 44, 45),
  elev = c(100, 200, 300, 400), OL = c(.2, .3, .4, .5), ET = c(.3, .2, .1, .01),
  ST = c(.5, .5, .5, .49), apr = c(.2, .3, .4, NA))
area = c(1, 3, 2, 4)
fixed = fixed_exchange(cells, area)
stopifnot(nrow(fixed$first) == 3, fixed$exclusions$excluded == 1,
  equal(fixed$weight, c(1, 3, 2)/6), equal(rowSums(fixed$first[, c('OL','ET','ST')]), rep(1, 3)),
  equal(rowSums(fixed$second[, c('OL','ET','ST')]), rep(1, 3)),
  equal(fixed$first[,c('OL','x','y','elev')], fixed$second[,c('OL','x','y','elev')]),
  equal(fixed$second$ET - fixed$first$ET, rep(.1, 3)))
paleo = rbind(transform(cells, ages = 6000), transform(cells, ages = 4500, ET = ET - .05))
historical = historical_exchange(cells, paleo, area)
stopifnot(nrow(historical$first) == 3, equal(historical$second$ET - historical$first$ET, rep(-.05, 3)),
  equal(historical$second$OL, cells$OL[1:3]), equal(historical$weight, fixed$weight))
bad = fixed$second; bad$elev[1] = 999
stopifnot(fails(freeze_exchange(fixed$first, bad, fixed$area)))
empty = fixed_exchange(cells[0, ], numeric())
stopifnot(nrow(empty$first) == 0, !length(empty$weight))

# Two endpoint matrices and their shared coefficients. Identical endpoints have zero SE;
# regional averaging preserves covariance between cells, rather than dividing it by n.
X0 = cbind(1, c(0, 0)); X1 = cbind(1, c(1, 2)); weight = c(.25, .75)
Vp = matrix(c(.04, .01, .01, .09), 2)
contrast = contrast_from_matrix(X0, X1, c(0, log(3)), Vp, weight)
gradient = c(.25 * (.1875-.25) + .75 * (.09-.25), .25*.1875 + .75*.18)
expected_se = sqrt(.04*gradient[1]^2 + 2*.01*prod(gradient) + .09*gradient[2]^2)
stopifnot(equal(contrast, c(.25*(.75-.5) + .75*(.9-.5), expected_se)),
  equal(contrast_from_matrix(X0, X0, c(0, log(3)), Vp, weight), c(0, 0)))
reverse = contrast_from_matrix(X1, X0, c(0, log(3)), Vp, weight)
stopifnot(equal(reverse, c(-contrast[1], contrast[2])),
  equal(contrast_from_matrix(X0, X1, c(0, 0), diag(c(1, 4)), weight)[['se']], .875))

# A small model-shaped object supplies known frozen scales, not an estimated fit.
rows = cells[complete_rows(cells, 'apr'), ]
fit = list(model = rows[, c('apr','x','y','elev','OL','ET','ST')],
  formula = calibration_formula('mod8', 'apr'), method = 'REML',
  family = list(family = 'Beta regression(20)', link = 'logit', getTheta = function(trans) 20),
  control = list(maxit = 500), iter = 4, outer.info = list(conv = 'full convergence'),
  linear.predictors = c(-1, 0, 1))
check_reused_model8(fit, cells, 'apr')
generator = freeze_generator(cells, 'apr', fit)
stopifnot(equal(generator$a, qlogis(.3)), generator$A == 1, generator$phi == 20,
  equal(generator$centre[c('OL', 'elev','ET','y')], c(.3, 200, .2, 43)),
  equal(generator$scale[c('OL','elev','ET','y')], c(.1, 100, .1, 1)))
endpoints = rows[1, ]; endpoints$OL = .5; endpoints$ET = .4; endpoints$elev = 400; endpoints$y = 45
# Use the training means/SDs above at this new endpoint: z(OL)=2, z(elev)=2, z(ET)=2, z(y)=2.
stopifnot(equal(generator_mean(endpoints, generator, 'darkens'), plogis(qlogis(.3) + 2.5)),
  equal(generator_contrast(fixed, generator, 'null'), 0),
  generator_contrast(fixed, generator, 'darkens') < 0,
  generator_contrast(historical, generator, 'darkens') > 0)
short = (45 - 43) + sin(2*pi*45/4)*cos(2*pi*(-75)/8)
stopifnot(equal(generator_mean(endpoints, generator, 'shorter'),
  plogis(qlogis(.3) + .5 + (short-generator$centre[['short']])/generator$scale[['short']])) )

# The seed belongs to dataset/month/truth/replicate, never to a configuration.
draw = recovery_response(cells, 'apr', generator, 'darkens', 1L, CV_SEED)
draw_again = recovery_response(cells, 'apr', generator, 'darkens', 1L, CV_SEED)
other = recovery_response(cells, 'apr', generator, 'darkens', 2L, CV_SEED)
stopifnot(identical(draw, draw_again), !identical(draw$response, other$response),
  identical(draw$seed, derive_seed(CV_SEED, 'cross_validation', 'recovery', 'apr', 'darkens', 1)),
  identical(is.na(draw$response), is.na(cells$apr)), all(draw$response[1:3] > 0 & draw$response[1:3] < 1))
model_a = model_b = cells; model_a$apr = draw$response; model_b$apr = draw$response
stopifnot(identical(model_a, model_b), identical(recovery_models('mod8'), c('mod8','cover_elev')),
  identical(recovery_models('lin_cover_noloc'), c('lin_cover_noloc','mod8')),
  identical(recovery_models('loc12_tp50'), c('loc12_tp50','mod8','loc0_tp50')))

# 18/20 signs passes; 17/20 fails. Equality at both numerical limits passes.
status = function(values, exact = 1, reference = 1, null = FALSE, converged = rep(TRUE, 20), cells = 1)
  recovery_statistics(values, converged, exact, reference, null, cells)$status
stopifnot(status(c(rep(1,18),-1,-1)) == 'pass', status(c(rep(1,17),-1,-1,-1)) == 'fail',
  status(rep(1.5,20)) == 'pass', status(rep(1.5001,20)) == 'fail',
  status(rep(.5,20), 0, 2, TRUE) == 'pass', status(rep(.5001,20), 0, 2, TRUE) == 'fail',
  status(rep(.5,20), 0, 1, TRUE) == 'fail', # threshold uses the exact reference, not a fitted contrast
  status(c(NA,rep(1,19))) == 'incomplete', status(rep(1,19)) == 'incomplete',
  status(rep(1,20), converged = c(FALSE,rep(TRUE,19))) == 'incomplete',
  status(rep(1,20), reference = 0) == 'untestable', status(rep(1,20), cells = 0) == 'untestable')
statistics = recovery_statistics(c(rep(1,18),-1,-1), rep(TRUE,20), 1, 1)
stopifnot(equal(statistics$bias, -.2), equal(statistics$rmse, sqrt(.4)),
  equal(statistics$mcse_sign_proportion, sqrt(.9*.1/20)))

# An AIC fixture has log likelihood -10 and df=3, so AIC=26; changing month, rows,
# response or predictors is rejected before the AIC calculation.
class(fit) = 'cv_aic_fixture'
logLik.cv_aic_fixture = function(object, ...) structure(-10, class = 'logLik', df = 3, nobs = 3)
stopifnot(full_month_aic(fit, cells, 'apr')[['aic']] == 26,
  full_month_aic(fit, cells, 'apr')[['smoothing_uncertainty_correction']] == 0)
fit$edf2 = 3
stopifnot(full_month_aic(fit, cells, 'apr')[['smoothing_uncertainty_correction']] == 1)
bad_fit = fit; bad_fit$method = 'ML'
stopifnot(fails(check_reused_model8(bad_fit, cells, 'apr')), fails(full_month_aic(bad_fit, cells, 'apr')))
bad_fit = fit; bad_fit$model$apr[1] = .7
stopifnot(fails(full_month_aic(bad_fit, cells, 'apr')))
bad_fit = fit; bad_fit$model$apr[1] = bad_fit$model$apr[1] + 1e-10
stopifnot(fails(full_month_aic(bad_fit, cells, 'apr')))
bad_fit = fit; bad_fit$model$x[1] = -100
stopifnot(fails(check_reused_model8(bad_fit, cells, 'apr')))
bad_fit = fit; bad_fit$model = bad_fit$model[1:2, ]
stopifnot(fails(full_month_aic(bad_fit, cells, 'apr')))
bad_fit = fit; bad_fit$formula = calibration_formula('mod8', 'may')
stopifnot(fails(full_month_aic(bad_fit, cells, 'apr')))
bad_fit = fit; bad_fit$formula = calibration_formula('mod8_coarse_loc', 'apr')
stopifnot(fails(check_reused_model8(bad_fit, cells, 'apr')))

# Subsets have a common denominator, renormalizing only within the requested report.
fixed$support = data.frame(outside = c(FALSE, TRUE, TRUE))
inside = exchange_subset(fixed, 'inside'); outside = exchange_subset(fixed, 'outside')
stopifnot(equal(sum(inside$area) + sum(outside$area), sum(fixed$area)),
  equal(inside$weight, 1), equal(outside$weight, c(3,2)/5),
  equal(sum(inside$area)/sum(fixed$area) + sum(outside$area)/sum(fixed$area), 1))

# In mgcv's pairwise matrices rows explain columns; direction matters for observed concurvity.
pair = matrix(c(1, .2, .8, 1), 2, dimnames = list(c('s(x,y)', 'para'), c('s(x,y)', 'para')))
pair_values = location_cover_concurvity(list(worst = pair, observed = pair, estimate = pair), 'para')
stopifnot(pair_values$location_from_cover_observed == .2, pair_values$cover_from_location_observed == .8,
  location_concurvity(NULL, 'loc12_linear')$cover_block == 'parametric (intercept and ET/ST)',
  location_concurvity(NULL, 'lin_cover_noloc')$cover_block == 'not applicable',
  is.na(location_concurvity(NULL, 'loc12_linear')$location_edf))

# Exercise the stage boundaries with a fitter that never estimates anything. The first
# no-location recovery fit fails; its twenty-slot summary must remain incomplete.
staged = new.env(parent = globalenv())
for (name in c('separation_capacity', 'separation_recovery', 'separation_summarize')) {
  staged[[name]] = get(name)
  environment(staged[[name]]) = staged
}
staged$month = 'apr'; staged$truth = 'darkens'; staged$calls = 0L; staged$responses = list()
staged$fail_all = FALSE
staged$gc = function(...) invisible(NULL)
staged$separation_record = function(...) invisible(NULL)
staged$calibration_fit_summary = function(fit)
  data.frame(term = 'parametric', edf = 3, smoothing_parameter = NA_real_)
staged$location_concurvity = function(fit, model) location_concurvity(NULL, model)
make_fixture = function(data, month, model = 'mod8') {
  result = fit
  result$model = data[complete_rows(data, month), c(month, CALIBRATION_PREDICTORS)]
  result$formula = calibration_formula(model, month)
  result$outer.info = list(conv = 'full convergence', iter = 2, grad = 0, hess = matrix(1))
  result
}
staged$fit_calibration_retry = function(model, month, data) {
  staged$calls = staged$calls + 1L
  staged$responses[[staged$calls]] = data[[month]]
  failed = staged$fail_all || (staged$fail && model == 'cover_elev' && staged$calls == 2L)
  result = if (failed) NULL else make_fixture(data, month, model)
  list(fit = result, converged = !failed, retries = 0L,
    status = if (failed) 'ERROR: stipulated fixture failure' else 'fixture converged', warnings = '',
    attempts = data.frame(attempt = 1L, maxit = 500, converged = !failed, status = 'fixture'))
}
staged$exchange_contrast = function(fit, exchange)
  c(contrast = generator_contrast(exchange, generator, staged$truth), se = 0)
fixture_dir = tempfile('cv-separation-stages-')
dir.create(fixture_dir)
fixture_cal = cells; fixture_cal$may = fixture_cal$apr + .02
fixture = list(cal = fixture_cal, months = list())
for (month in c('apr', 'may')) {
  fit_file = file.path(fixture_dir, paste0(month, '.rds'))
  saveRDS(make_fixture(fixture_cal, month), fit_file)
  exchanges = list(fixed = fixed, historical = historical)
  exchanges$historical$support = fixed$support
  responses = setNames(lapply(CV_RECOVERY_TRUTHS, function(truth)
    lapply(1:20, function(replicate) recovery_response(fixture_cal, month, generator, truth, replicate, CV_SEED))),
    CV_RECOVERY_TRUTHS)
  fixture$months[[month]] = list(model8_file = fit_file, capacity = fixed, exchanges = exchanges,
    generator = generator, responses = responses)
}
fixture$input_files = file.path(fixture_dir, paste0(c('apr','may'), '.rds'))
fixture$md5 = unname(tools::md5sum(fixture$input_files))
saveRDS(fixture, separation_file(fixture_dir, 'frozen.rds'))
write.csv(data.frame(model = 'mod8', chosen = TRUE), cv_file(fixture_dir, 'scores.csv'), row.names = FALSE)
staged$fail = FALSE
for (month in c('apr','may')) staged$separation_capacity(fixture_dir, month)
stopifnot(staged$calls == 28L)
for (month in c('apr','may')) for (truth in CV_RECOVERY_TRUTHS) {
  staged$calls = 0L; staged$responses = list(); staged$truth = truth
  staged$fail = month == 'apr' && truth == 'darkens'
  staged$separation_recovery(fixture_dir, month, truth)
  stopifnot(staged$calls == 40L)
  for (replicate in 1:20)
    stopifnot(identical(staged$responses[[2*replicate-1]], staged$responses[[2*replicate]]))
}
invisible(capture.output(staged$separation_summarize(fixture_dir)))
capacity_table = read.csv(separation_file(fixture_dir, 'capacity.csv'))
recovery_table = read.csv(separation_file(fixture_dir, 'summaries.csv'))
passed = read.csv(separation_file(fixture_dir, 'passed.csv'))
stopifnot(nrow(capacity_table) == 30L, sum(capacity_table$reused) == 2L,
  all(capacity_table$delta_aic == 0), nrow(recovery_table) == 72L,
  passed$passes_recovery[passed$model == 'mod8'], !passed$passes_recovery[passed$model == 'cover_elev'],
  all(recovery_table$status[recovery_table$model == 'cover_elev' & recovery_table$month == 'apr' &
    recovery_table$truth == 'darkens'] == 'incomplete'))
# A whole failed job has no term summaries. It still writes every failed replicate and
# the final report must say incomplete rather than failing while appending an empty table.
staged$fail_all = TRUE; staged$truth = 'null'
staged$separation_recovery(fixture_dir, 'may', 'null')
invisible(capture.output(staged$separation_summarize(fixture_dir)))
recovery_table = read.csv(separation_file(fixture_dir, 'summaries.csv'))
passed = read.csv(separation_file(fixture_dir, 'passed.csv'))
stopifnot(!any(passed$passes_recovery),
  all(recovery_table$status[recovery_table$month == 'may' & recovery_table$truth == 'null'] == 'incomplete'))
unlink(fixture_dir, recursive = TRUE)
cat('CV separation: hand-worked checks passed (no fits).\n')
