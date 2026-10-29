# Tests for fit_convergence() in R/model_registry.R, on made-up fits holding only the fields it
# reads, and for the control argument of fit_calibration_model() on a small real fit.
# Run from the repository root: Rscript tests/test_model_registry.R
source("R/model_registry.R")

converged = list(iter = 37L, control = list(maxit = 500),
                 outer.info = list(conv = "full convergence", iter = 5L, grad = c(1e-4, -7.7e-4),
                                   hess = diag(c(1.1, 3))))
at_limit = converged; at_limit$iter = 500L
no_optimiser = converged; no_optimiser$outer.info = NULL
no_conv = converged; no_conv$outer.info$conv = NULL
step_failed = converged; step_failed$outer.info$conv = "step failed"
not_pos_def = converged; not_pos_def$outer.info$hess = matrix(-1)   # also the 1x1 case

stopifnot(
  identical(fit_convergence(converged),
            "fitting loop: 37 of 500 steps; smoothing parameters: full convergence after 5 iterations; largest gradient 7.7e-04; Hessian positive definite (smallest eigenvalue 1.1)"),
  startsWith(fit_convergence(at_limit),
             'fitting loop: reached its limit of 500 steps, probably NOT converged (see R\'s "algorithm did not converge" warning); '),
  identical(fit_convergence(no_optimiser), "fitting loop: 37 of 500 steps; smoothing parameters: not available"),
  identical(fit_convergence(no_conv), "fitting loop: 37 of 500 steps; smoothing parameters: not available"),
  grepl("smoothing parameters: NOT converged: step failed after 5 iterations", fit_convergence(step_failed), fixed = TRUE),
  grepl("Hessian NOT positive definite (smallest eigenvalue -1)", fit_convergence(not_pos_def), fixed = TRUE),
  # a fit that converged says NOT nowhere
  !grepl("NOT", fit_convergence(converged)),
  # a fit with its model frame also gives the rows it was fitted on
  endsWith(fit_convergence(c(converged, list(model = data.frame(jan = 1:3)))), "Hessian positive definite (smallest eigenvalue 1.1); fitted on 3 rows")
)

# fit_calibration_model(): the default control is CALIBRATION_CONTROL, and a diagnostic can pass
# another. A cheap model (elevation only) on made-up data, two cells missing their albedo.
set.seed(1)
toy = data.frame(elev = runif(200, 0, 3000))
toy$jan = plogis(-1 + toy$elev / 2000 + rnorm(200, 0, 0.3))
toy$jan[1:2] = NA
default_fit = suppressWarnings(fit_calibration_model("elev", "jan", toy))
small_fit = suppressWarnings(fit_calibration_model("elev", "jan", toy, control = modifyList(CALIBRATION_CONTROL, list(maxit = 3, nthreads = 1))))
stopifnot(
  identical(names(formals(fit_calibration_model)), c("model_id", "month", "data", "method", "control")),
  identical(default_fit$control$maxit, CALIBRATION_CONTROL$maxit),
  identical(small_fit$control$maxit, 3),
  identical(small_fit$control$nthreads, 1),
  nrow(default_fit$model) == 198,
  grepl("fitted on 198 rows$", fit_convergence(default_fit))
)
cat("test_model_registry: all tests passed\n")
