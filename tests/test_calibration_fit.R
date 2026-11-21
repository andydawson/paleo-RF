# Retry and fit summaries on hand-made fits: no CV model is fitted by this test.
source('R/calibration_fit.R')
data = data.frame(apr = c(0.4, 0.5), x = c(-70, NA), y = 45, elev = 10,
                   OL = 0.2, ET = 0.3, ST = 0.5)
ok = list(iter = 10L, control = list(maxit = 500),
           outer.info = list(conv = 'full convergence', iter = 2, grad = 0, hess = matrix(1)),
           nsdf = 3L, edf = c(1, 1, 1, 0.25, 0.75), sp = c('s(elev)' = 2),
           smooth = list(list(label = 's(elev)', first.para = 4L, last.para = 5L, first.sp = 1L)))
calls = integer()
fit_calibration_model = function(model_id, month, data, method, control) {
  calls <<- c(calls, control$maxit)
  stopifnot(method == 'REML', control$nthreads == 1, nrow(data) == 1L, data$apr == 0.4)
  modifyList(ok, list(control = control))
}
result = fit_calibration_retry('mod8', 'apr', data)
stopifnot(result$converged, result$retries == 0, identical(calls, 500),
          nrow(result$attempts) == 1, result$warnings == '')
terms = calibration_fit_summary(result$fit)
stopifnot(identical(terms$term, c('parametric', 's(elev)')), identical(terms$edf, c(3, 1)),
          is.na(terms$smoothing_parameter[1]), terms$smoothing_parameter[2] == 2)

calls = integer()
fit_calibration_model = function(model_id, month, data, method, control) {
  calls <<- c(calls, control$maxit)
  warning(paste('attempt', length(calls)))
  modifyList(ok, list(control = control, iter = if (length(calls) == 1) 500L else 12L))
}
result = fit_calibration_retry('mod8', 'apr', data)
stopifnot(result$converged, result$retries == 1, identical(calls, c(500, 2000)),
          identical(result$attempts$converged, c(FALSE, TRUE)),
          result$warnings == 'attempt 1 | attempt 2')

fit_calibration_model = function(model_id, month, data, method, control)
  modifyList(ok, list(control = control, iter = control$maxit))
result = fit_calibration_retry('mod8', 'apr', data)
stopifnot(!result$converged, result$retries == 1, nrow(result$attempts) == 2,
          !any(result$attempts$converged))

fit_calibration_model = function(...) stop('bad data')
result = fit_calibration_retry('mod8', 'apr', data)
stopifnot(!result$converged, result$retries == 0, is.null(result$fit),
          result$status == 'ERROR: bad data', nrow(calibration_fit_summary(result$fit)) == 0)

# An error on the retry also retains the first nonconvergence record.
fit_calibration_model = function(model_id, month, data, method, control) {
  if (control$maxit == 2000) stop('retry failed')
  modifyList(ok, list(iter = 500L))
}
result = fit_calibration_retry('mod8', 'apr', data)
stopifnot(!result$converged, result$retries == 1, result$status == 'ERROR: retry failed',
          nrow(result$attempts) == 2, !any(result$attempts$converged))
cat('test_calibration_fit: all tests passed\n')
