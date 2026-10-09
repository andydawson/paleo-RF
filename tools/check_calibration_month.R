# The one cheap calibration check of the regression contract: refit the selected model for
# one month and compare it with the stored fit, instead of re-running script 4 (27 h).
#
# Why: script 4's fits are on disk and every later issue verifies scripts 5 to 9 from them;
# only the fitting code itself needs a fresh check. A one-month refit of model 8 takes 1-5
# minutes. The check compares predictions on the calibration table (tolerance 1e-6, since
# bam at nthreads = 8 is not established as bit-reproducible) and the integer AIC with the
# anchored AIC table.
#
# check_calibration_month(month, fit_fun) takes the fitting function as an argument, so the
# model specification is never copied here: the default refits from the stored model's own
# formula, family link, method and control; later issues pass their registry function.
#
# Usage: Rscript tools/check_calibration_month.R <month> [stored-model.RDS]
#   Exit status 1 if predictions differ by more than 1e-6 or the integer AIC differs.

suppressPackageStartupMessages(library(mgcv))

refit_like_stored <- function(stored, data, month) {
  # formula(stored) is `get(month) ~ ...`, evaluated where the fit was made (the global
  # environment), so `month` has to exist there.
  assign("month", month, envir = globalenv())
  # betar() reads `link` unevaluated (substitute), so the stored link is passed by do.call.
  mgcv::bam(stats::formula(stored), data = data,
            family = do.call(betar, list(link = stored$family$link)),
            method = stored$method, na.action = na.omit,
            control = list(nthreads = stored$control$nthreads, maxit = stored$control$maxit))
}

check_calibration_month <- function(month, stored, data, aic_table, fit_fun = refit_like_stored,
                                    tolerance = 1e-6) {
  t0 <- Sys.time()
  fresh <- fit_fun(stored, data, month)
  minutes <- as.numeric(difftime(Sys.time(), t0, units = "mins"))
  keep <- !is.na(data[[month]])
  p_old <- stats::predict(stored, newdata = data[keep, ], type = "response")
  p_new <- stats::predict(fresh,  newdata = data[keep, ], type = "response")
  d <- max(abs(p_old - p_new))
  aic_anchor <- aic_table[aic_table$model == 8, month]
  aic_new <- round(stats::AIC(fresh))
  list(month = month, minutes = minutes, max_abs_pred_diff = d, tolerance = tolerance,
       aic_anchor = aic_anchor, aic_new = aic_new,
       ok = d <= tolerance && isTRUE(aic_new == aic_anchor))
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  month <- if (length(args) >= 1) args[1] else stop("usage: Rscript tools/check_calibration_month.R <month> [stored-model.RDS]")
  stored_path <- if (length(args) >= 2) args[2] else
    sprintf("output/calibration/calibration_mod_interp_selected_%s_bluesky.RDS", month)
  res <- check_calibration_month(
    month, stored = readRDS(stored_path),
    data = readRDS("data/calibration_modern_lct_interp_bluesky.RDS"),
    aic_table = utils::read.csv("tests/anchors/interp-allmonths-2026-09-20/AIC_table.csv"))
  cat(sprintf("month %s | refit %.1f min | max |pred diff| %.3g (tolerance %g) | AIC anchor %d, refit %d | %s\n",
              res$month, res$minutes, res$max_abs_pred_diff, res$tolerance, res$aic_anchor, res$aic_new,
              if (res$ok) "PASS" else "FAIL"))
  quit(status = if (res$ok) 0 else 1)
}
