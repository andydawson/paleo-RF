# CV and the separation tests share the ordinary fitter and its single convergence retry.
# Pipeline fitting remains in model_registry.R with its existing controls.
source('R/model_registry.R')

fit_calibration_retry = function(model_id, month, data,
                                 control = modifyList(CALIBRATION_CONTROL, list(nthreads = 1))) {
  control$maxit = 500
  warnings = character()
  attempts = list()
  fit = NULL
  for (attempt in 1:2) {
    if (attempt == 2) control$maxit = 2000
    error = NULL
    fit = tryCatch(withCallingHandlers(
      # Missingness is common to the whole grid, including models omitting a predictor.
      fit_calibration_model(model_id, month, data[complete_rows(data, month), , drop = FALSE],
                            method = 'REML', control = control),
      warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w))
        invokeRestart('muffleWarning')
      }), error = function(e) { error <<- conditionMessage(e); NULL })
    converged = !is.null(fit) && isTRUE(fit_converged(fit))
    status = if (is.null(fit)) paste('ERROR:', error) else fit_convergence(fit)
    attempts[[attempt]] = data.frame(attempt = attempt, maxit = control$maxit,
                                     converged = converged, status = status)
    # Errors are recorded immediately; the protocol's retry is for nonconvergence.
    if (is.null(fit) || converged) break
  }
  list(fit = fit, converged = converged, retries = attempt - 1L, status = status,
       warnings = paste(unique(warnings), collapse = ' | '), attempts = do.call(rbind, attempts))
}

# Sum coefficient EDF within each term; include the parametric block for linear cover.
# Each smooth in the CV grid has one penalty and therefore one smoothing parameter.
calibration_fit_summary = function(fit) {
  out = data.frame(term = character(), edf = numeric(), smoothing_parameter = numeric())
  if (is.null(fit)) return(out)
  if (fit$nsdf > 0) out = rbind(out, data.frame(term = 'parametric',
    edf = sum(fit$edf[seq_len(fit$nsdf)]), smoothing_parameter = NA_real_))
  for (s in fit$smooth) out = rbind(out, data.frame(term = s$label,
    edf = sum(fit$edf[s$first.para:s$last.para]), smoothing_parameter = unname(fit$sp[s$first.sp])))
  out
}
