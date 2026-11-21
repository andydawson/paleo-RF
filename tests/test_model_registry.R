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
default_fit = suppressWarnings(fit_calibration_model("elev", "jan", toy,
  control = modifyList(CALIBRATION_CONTROL, list(nthreads = 1))))
small_fit = suppressWarnings(fit_calibration_model("elev", "jan", toy, control = modifyList(CALIBRATION_CONTROL, list(maxit = 3, nthreads = 1))))
stopifnot(
  identical(names(formals(fit_calibration_model)), c("model_id", "month", "data", "method", "control")),
  identical(default_fit$control$maxit, CALIBRATION_CONTROL$maxit),
  identical(small_fit$control$maxit, 3),
  identical(small_fit$control$nthreads, 1),
  nrow(default_fit$model) == 198,
  grepl("fitted on 198 rows$", fit_convergence(default_fit))
)
# The rows a month can be fitted on, and a model's coefficients from its setup.
cells = data.frame(x = runif(600, -120, -70), y = runif(600, 30, 60), elev = runif(600, 0, 3000),
                   OL = 0.2, ET = 0.3, ST = 0.5, jan = runif(600, 0.1, 0.8))
cells$jan[1:3] = NA; cells$elev[3:4] = NA; cells$feb = cells$jan; cells$feb[10] = NA
stopifnot(
  setequal(CALIBRATION_PREDICTORS, c("x", "y", "elev", "OL", "ET", "ST")),
  complete_model_rows(cells, "jan") == 600 - 4,      # rows 1-3 lack the albedo, 3-4 the elevation
  complete_model_rows(cells, "feb") == 600 - 5,
  model_coefficients("elev", "jan", cells) == 50,     # s(elev, k = 50): intercept + 49
  model_coefficients("spatial_elev", "jan", cells) == 549
)
# The approved grid's setup counts and order, independent of fitted EDF. All models use
# the same complete rows even when their own formula omits location or a cover column.
set.seed(12)
fractions = matrix(rexp(3 * 800), ncol = 3)
fractions = fractions / rowSums(fractions)
grid = data.frame(x = runif(800, -125, -65), y = runif(800, 28, 73),
                   elev = runif(800, 0, 3000), OL = fractions[, 1], ET = fractions[, 2],
                   ST = fractions[, 3], jan = runif(800, 0.1, 0.8))
expected_ids = c('lin_cover_noloc', 'loc0_tp50', 'cover_elev',
                  'loc12_linear', 'loc12_tp50', 'loc12_tp200',
                  'loc30_linear', 'loc30_tp50', 'mod8_coarse_loc',
                  'loc100_linear', 'loc100_tp50', 'loc100_tp200',
                  'lin_cover', 'loc500_tp50', 'mod8')
expected_counts = c(52L, 99L, 249L, 63L, 110L, 260L, 81L, 128L, 278L,
                     151L, 198L, 348L, 551L, 598L, 748L)
stopifnot(identical(CV_MODELS, expected_ids), identical(unname(CV_COEFFICIENTS), expected_counts),
          identical(vapply(CV_MODELS, model_coefficients, 0L, month = 'jan', data = grid), CV_COEFFICIENTS),
          identical(LADDER_MODELS, paste0('mod', 1:8)), length(SPATIAL_MODELS) == 7L)

# The five retained CV formulas are written out so adding the grid cannot change them.
unchanged = list(
  lin_cover_noloc = ~ s(elev, k = 50) + ET + ST,
  cover_elev = ~ s(elev, k = 50) + s(OL, ET, ST, bs = "tp", k = 200),
  mod8_coarse_loc = ~ s(x, y, bs = "gp", k = 30) + s(elev, k = 50) + s(OL, ET, ST, bs = "tp", k = 200),
  lin_cover = ~ s(x, y, bs = "gp", k = 500) + s(elev, k = 50) + ET + ST,
  mod8 = ~ s(x, y, bs = "gp", k = 500) + s(elev, k = 50) + s(OL, ET, ST, bs = "tp", k = 200))
for (id in names(unchanged)) stopifnot(identical(CALIBRATION_MODELS[[id]]$rhs, unchanged[[id]]))
# Prediction setup is identical for the old model-8 formula and registry formula, without
# fitting a CV model. Both matrix rows and penalties must agree, not just coefficient counts.
old_formula = eval(call('~', as.name('jan'), unchanged$mod8[[2]]))
old_setup = mgcv::gam(old_formula, data = grid, fit = FALSE)
new_setup = mgcv::gam(calibration_formula('mod8', 'jan'), data = grid, fit = FALSE)
stopifnot(identical(old_setup$X, new_setup$X), identical(old_setup$S, new_setup$S))

# A fixed ET-for-ST exchange changes every linear model's logit by the same amount.
# Both endpoints enter one setup, so unchanged elevation/location use identical bases.
source('R/cv_separation.R')
exchange_cells = grid[which(grid$ET >= 0.05 & grid$ST >= 0.05)[1:5], ]
exchange = fixed_exchange(exchange_cells, rep(1, nrow(exchange_cells)))
endpoints = rbind(grid, transform(exchange$first, jan = 0.4), transform(exchange$second, jan = 0.4))
first_rows = nrow(grid) + seq_len(nrow(exchange$first))
second_rows = first_rows + nrow(exchange$first)
linear_models = CV_MODELS[CV_COVER_FORM == 'linear']
stopifnot(length(linear_models) == 5L, nrow(exchange$first) == nrow(exchange_cells))
for (id in linear_models) {
  setup = mgcv::gam(calibration_formula(id, 'jan'), data = endpoints, fit = FALSE)
  X0 = setup$X[first_rows, , drop = FALSE]
  X1 = setup$X[second_rows, , drop = FALSE]
  cover_columns = match(c('ET', 'ST'), colnames(setup$X))
  stopifnot(!anyNA(cover_columns))
  beta = seq_len(ncol(setup$X)) / ncol(setup$X)
  beta[cover_columns] = c(0.7, -0.3)
  difference = X1 - X0
  stopifnot(all(abs(difference[, -cover_columns]) < 1e-12),
            all(abs(difference[, cover_columns[1]] - 0.1) < 1e-12),
            all(abs(difference[, cover_columns[2]] + 0.1) < 1e-12),
            all(abs(drop(difference %*% beta) - 0.1 * (beta[cover_columns[1]] - beta[cover_columns[2]])) < 1e-12))
}
cat("test_model_registry: all tests passed\n")
