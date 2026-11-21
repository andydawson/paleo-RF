# Tests for tools/check_model7_convergence.R, on a cheap model (elevation only) and made-up data
# instead of model 7, whose fits take hours. Run: Rscript tests/test_check_model7_convergence.R
source("tools/check_model7_convergence.R")

set.seed(1)
toy = data.frame(elev = runif(300, 0, 3000))
toy$feb = plogis(-1 + toy$elev / 2000 + rnorm(300, 0, 0.3))
toy$feb[1:5] = NA
# A "saved" fit stopped at a limit of 2 steps, as model 7 stops at 500; and one that converged.
stopped   = suppressWarnings(fit_calibration_model("elev", "feb", toy, method = "ML",
                                                   control = modifyList(CALIBRATION_CONTROL, list(maxit = 2))))
converged = fit_calibration_model("elev", "feb", toy, method = "ML")

at_limit = check_refit("feb", stopped, toy, model_id = "elev")
control  = check_refit("feb", converged, toy, model_id = "elev")
stopifnot(
  identical(at_limit$method, "ML"),                   # the saved fit's method, not REML by default
  at_limit$rows_saved == 295, at_limit$rows_refit == 295,
  identical(at_limit$steps_saved, "2 of 2"),
  grepl(" of 2000$", at_limit$steps_refit),
  grepl("reached its limit", at_limit$convergence_saved),
  !grepl("NOT", at_limit$convergence_refit),
  # a fit that had converged is reproduced at the higher limit
  control$aic_refit == control$aic_saved,
  control$max_abs_fitted_change < 1e-10,
  identical(control$steps_saved, sub(" of 2000$", " of 500", control$steps_refit))
)
# It stops unless the refit compares like with like, before fitting when the data differ.
stops_with = function(pattern, expr) grepl(pattern, tryCatch({ expr; "" }, error = conditionMessage))
frame_differs = "would not compare like with like: the model frame differs"
stopifnot(
  stops_with(frame_differs, check_refit("feb", converged, toy[-10, ], model_id = "elev")),                       # a dropped row
  stops_with(frame_differs, check_refit("feb", converged, toy[c(1:9, 11, 10, 12:300), ], model_id = "elev")),           # reordered rows
  stops_with(frame_differs, check_refit("feb", converged, within(toy, feb[20] <- 0.5), model_id = "elev")),     # a changed response
  stops_with(frame_differs, check_refit("feb", converged, within(toy, feb[30] <- NA), model_id = "elev")),      # changed missingness
  stops_with("the formula differs", check_refit("mar", converged, within(toy, mar <- feb), model_id = "elev")),   # same values, another month's column
  # after fitting too: a fitting function with another link is refused
  stops_with("the family or its link differs",
             check_refit("feb", converged, toy, model_id = "elev",
                         fit_fun = function(model_id, month, data, method, control)
                           mgcv::bam(calibration_formula(model_id, month), data = data, family = mgcv::betar(link = "probit"),
                                     method = method, na.action = na.omit, control = control))),
  # the saved fit's own controls are kept, only the step limit changes
  identical(check_refit("feb", converged, toy, model_id = "elev",
                        fit_fun = function(model_id, month, data, method, control) {
                          stopifnot(identical(control[names(control) != "maxit"], converged$control[names(converged$control) != "maxit"]),
                                    control$maxit == 2000)
                          fit_calibration_model(model_id, month, data, method, control)
                        })$aic_refit, control$aic_saved)
)

# The command line refuses a call without months.
rscript = file.path(R.home("bin"), "Rscript")
stopifnot(system2(rscript, c("tools/check_model7_convergence.R", "."), stdout = FALSE, stderr = FALSE) == 2)
cat("test_check_model7_convergence: all tests passed\n")
