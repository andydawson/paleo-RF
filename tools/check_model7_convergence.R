# Refit model 7 with a higher step limit, for named months of a finished run, and set the result
# beside the run's saved 500-step fit.
#
# Why (Chris, 2026-10-29, decision 3 of docs/cc/2026-10-29_refit_plan_decisions.md): in some
# months script 4's model 7 stops at its limit of 500 fitting steps, so its AIC in the ladder may
# be that of an unfinished fit. Refitting those months at 2,000 steps, plus one month where it
# converged as a control that the result does not move, says whether the ranking can be trusted.
# The pipeline's limit is not changed: this is a diagnostic only.
#
# The refit uses the pipeline's own fitting function (fit_calibration_model in
# R/model_registry.R) with the saved fit's own method (ML or REML) and fitting controls, only
# the step limit raised. It stops unless the refit compares like with like: the same formula,
# the same family and link, and the same model frame (the same rows, in the same order, with
# the same values), checked before fitting and again after. No result file is written (the
# report is printed), though setting up the run's paths creates its product directories if
# they are missing.
#
# Usage, from the repository root:
#   Rscript tools/check_model7_convergence.R <run-dir> <month> [<month> ...]
# <run-dir> is the directory the run wrote into (its config's run$dir), or "." for the
# repository's own locations. Reads the run's calibration table and its saved model-7 fits.
# Each refit takes hours (eight threads, as script 4).

source('R/config.R')
source('R/paths.R')

MODEL7_CHECK_MAXIT = 2000

# Why a refit would not be comparable with the saved fit: one sentence per difference in the
# formula, the model frame (rows and values, in order) or the family and its link.
setup_differences = function(saved, formula, model_frame, family) {
  family_name = function(f) sub('\\(.*$', '', f$family)   # "Beta regression(46.1)": theta is estimated
  c(if (!identical(deparse(stats::formula(saved)), deparse(formula))) 'the formula differs',
    if (!isTRUE(all.equal(saved$model, model_frame, check.attributes = FALSE)))
      'the model frame differs (rows dropped, added or reordered, or values changed)',
    if (!identical(family_name(saved$family), family_name(family)) || !identical(saved$family$link, family$link))
      'the family or its link differs')
}

stop_unless_comparable = function(month, differences) {
  if (length(differences)) stop(sprintf('check_refit, %s: the refit would not compare like with like: %s',
                                        month, paste(differences, collapse = '; ')), call. = FALSE)
}

# Refit one month's saved fit with a higher step limit and compare. `fit_fun` is the fitting
# function, replaceable for the tests. Returns one row: per fit its method, rows fitted, steps
# taken out of the limit and AIC, the largest change in the fitted values, and both convergence
# lines of fit_convergence().
check_refit = function(month, saved, data, model_id = 'mod7', maxit = MODEL7_CHECK_MAXIT,
                       fit_fun = fit_calibration_model) {
  # Checked before fitting, which takes hours for model 7: the data must give the saved fit's
  # model frame under the registry's formula (the variables of the smooths, rows with a
  # missing value dropped, as fit_calibration_model does).
  formula = calibration_formula(model_id, month)
  frame = stats::model.frame(mgcv::interpret.gam(formula)$fake.formula, data, na.action = na.omit)
  stop_unless_comparable(month, setup_differences(saved, formula, frame, saved$family))
  started = Sys.time()
  refit = fit_fun(model_id, month, data, method = saved$method,
                  control = modifyList(saved$control, list(maxit = maxit)))
  stop_unless_comparable(month, setup_differences(saved, stats::formula(refit), refit$model, refit$family))
  data.frame(month = month, model = model_id, method = saved$method,
             rows_saved = nrow(saved$model), rows_refit = nrow(refit$model),
             steps_saved = sprintf('%d of %d', saved$iter, saved$control$maxit),
             steps_refit = sprintf('%d of %d', refit$iter, refit$control$maxit),
             aic_saved = stats::AIC(saved), aic_refit = stats::AIC(refit),
             max_abs_fitted_change = max(abs(stats::fitted(refit) - stats::fitted(saved))),
             minutes = round(as.numeric(difftime(Sys.time(), started, units = 'mins')), 1),
             convergence_saved = fit_convergence(saved), convergence_refit = fit_convergence(refit))
}

if (sys.nframe() == 0L) {
  args = commandArgs(trailingOnly = TRUE)
  if (length(args) < 2) { cat('usage: Rscript tools/check_model7_convergence.R <run-dir> <month> [<month> ...]\n'); quit(status = 2) }
  run_dir = args[1]
  months = check_months(args[-1])
  paths = pipeline_paths(NULL, if (run_dir == '.') baseline_paths() else redirected_paths(run_dir))
  suppressPackageStartupMessages(library(mgcv))
  data = readRDS(path_file(paths, 'calibration_table'))
  for (month in months) {
    saved = readRDS(path_calibration_model(paths, 'mod7', month))
    result = check_refit(month, saved, data)
    cat(sprintf('\n%s, model 7 by %s: %d rows (saved) / %d (refit)\n', month, result$method, result$rows_saved, result$rows_refit))
    cat(sprintf('  saved: %s steps, AIC %.1f\n  refit: %s steps, AIC %.1f (%.1f min)\n',
                result$steps_saved, result$aic_saved, result$steps_refit, result$aic_refit, result$minutes))
    cat(sprintf('  AIC change %.1f; largest change in a fitted value %.2g\n',
                result$aic_refit - result$aic_saved, result$max_abs_fitted_change))
    cat('  saved: ', result$convergence_saved, '\n  refit: ', result$convergence_refit, '\n', sep = '')
  }
}
