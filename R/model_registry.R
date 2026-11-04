# The calibration models of script 4: one month's blue-sky albedo as a beta GAM (logit link)
# of location (x, y), elevation and the land-cover fractions ET, OL and ST.
#
# Why: script 4 wrote out the same bam() call fifteen times, once per model, and script 5
# took "model 8" as the selected model in three separate places. Each model is now defined
# once here, by its id; script 4 fits them in a loop, and the model used for prediction is
# chosen by id in config.R (analysis$calibration$model_id, question B4). A formula changes
# only by a reviewed change to this file.
#
# The formulas, smoothing bases and basis sizes (k) are exactly script 4's. The fitted
# response is the month's column itself (jan ~ ...) rather than the original get(month) ~
# ..., so a fit no longer depends on a variable `month` existing where it is used; the
# predictions are the same (tools/check_calibration_month.R).

CALIBRATION_MODELS = list(
  # The ladder: from location alone to location, elevation and all three cover fractions.
  # Models 2 to 5 each add one term; models 6 to 8 replace the separate cover terms with one
  # joint smooth of the three, in three forms. Scripts 4 and 5 compare them.
  mod1 = list(label = 'model 1: (x,y)',
              rhs = ~ s(x, y, bs = "gp", k = 500)),
  mod2 = list(label = 'model 2: (x,y) + elevation',
              rhs = ~ s(x, y, bs = "gp", k = 500) + s(elev, k = 50)),
  mod3 = list(label = 'model 3: (x,y) + elevation + OL',
              rhs = ~ s(x, y, bs = "gp", k = 500) + s(elev, k = 50) + s(OL, k = 50)),
  mod4 = list(label = 'model 4: (x,y) + elevation + OL + ET',
              rhs = ~ s(x, y, bs = "gp", k = 500) + s(elev, k = 50) + s(OL, k = 50) + s(ET, k = 50)),
  mod5 = list(label = 'model 5: (x,y) + elevation + OL + ET + ST',
              rhs = ~ s(x, y, bs = "gp", k = 500) + s(elev, k = 50) + s(OL, k = 50) + s(ET, k = 50) + s(ST, k = 50)),
  mod6 = list(label = 'model 6: (x,y) + elevation + s(OL, ET, ST)',
              rhs = ~ s(x, y, bs = "gp", k = 500) + s(elev, k = 50) + s(OL, ET, ST, k = 75)),
  mod7 = list(label = 'model 7: (x,y) + elevation + gp(OL, ET, ST)',
              rhs = ~ s(x, y, bs = "gp", k = 500) + s(elev, k = 50) + s(OL, ET, ST, bs = "gp", k = 200)),
  mod8 = list(label = 'model 8: (x,y) + elevation + tp(OL, ET, ST)',
              rhs = ~ s(x, y, bs = "gp", k = 500) + s(elev, k = 50) + s(OL, ET, ST, bs = "tp", k = 200)),
  # The spatial experiments: model 8's terms in other combinations, compared by script 5.
  # spatial_elev_cover is the same formula as mod8, fitted again (general question 7).
  spatial_elev_cover = list(label = 'model: (x,y) + elev + tp(OL, ET, ST)',
                            rhs = ~ s(x, y, bs = "gp", k = 500) + s(elev, k = 50) + s(OL, ET, ST, bs = "tp", k = 200)),
  spatial       = list(label = 'model: (x,y)',
                       rhs = ~ s(x, y, bs = "gp", k = 500)),
  elev          = list(label = 'model: elevation',
                       rhs = ~ s(elev, k = 50)),
  spatial_elev  = list(label = 'model: (x,y) + elevation',
                       rhs = ~ s(x, y, bs = "gp", k = 500) + s(elev, k = 50)),
  spatial_cover = list(label = 'model: (x,y) + tp(OL, ET, ST)',
                       rhs = ~ s(x, y, bs = "gp", k = 500) + s(OL, ET, ST, bs = "tp", k = 200)),
  cover         = list(label = 'model: tp(OL, ET, ST)',
                       rhs = ~ s(OL, ET, ST, bs = "tp", k = 200)),
  cover_elev    = list(label = 'model: tp(OL, ET, ST) + elev',
                       rhs = ~ s(elev, k = 50) + s(OL, ET, ST, bs = "tp", k = 200)),
  # Four more candidates for the cross-validation that chooses the model (protocol of
  # 2 November 2026, docs/cc/2026-11-02_cv_protocol.md): cover as straight lines on the logit
  # scale (OL is the reference fraction), with and without location; and model 8 with a
  # coarser location term or a smaller cover term. The smaller cover term is a smooth of the
  # position on the cover triangle (R/training_support.R), which treats the three cover
  # exchanges alike; OL is left out because it is 1 - ET - ST.
  lin_cover        = list(label = 'model: (x,y) + elevation + ET + ST',
                          rhs = ~ s(x, y, bs = "gp", k = 500) + s(elev, k = 50) + ET + ST),
  lin_cover_noloc  = list(label = 'model: elevation + ET + ST',
                          rhs = ~ s(elev, k = 50) + ET + ST),
  mod8_coarse_loc  = list(label = 'model 8 with a coarse location term (k = 30)',
                          rhs = ~ s(x, y, bs = "gp", k = 30) + s(elev, k = 50) + s(OL, ET, ST, bs = "tp", k = 200)),
  mod8_small_cover = list(label = 'model 8 with a smaller cover term (triangle position, k = 50)',
                          rhs = ~ s(x, y, bs = "gp", k = 500) + s(elev, k = 50) +
                                  s(I(ST + ET / 2), I(ET * sqrt(3) / 2), k = 50)))

LADDER_MODELS  = paste0('mod', 1:8)
# Written out, so that a model added for the cross-validation is not fitted by script 4.
SPATIAL_MODELS = c('spatial_elev_cover', 'spatial', 'elev', 'spatial_elev', 'spatial_cover', 'cover', 'cover_elev')
# The cross-validation's thirteen candidates; the baselines (no cover term) are scored but
# never chosen, because they predict no change from vegetation by construction.
CV_MODELS    = c(LADDER_MODELS, 'cover_elev', 'lin_cover', 'lin_cover_noloc', 'mod8_coarse_loc', 'mod8_small_cover')
CV_BASELINES = c('mod1', 'mod2')

# The predictors any calibration model uses (x, y, elev, OL, ET, ST).
CALIBRATION_PREDICTORS = unique(unlist(lapply(CALIBRATION_MODELS, function(model) all.vars(model$rhs))))

# The rows a month's models are fitted on, and their number: the cells with that month's
# albedo and every predictor (fit_calibration_model drops the others, na.omit).
complete_rows = function(data, month) stats::complete.cases(data[, c(month, CALIBRATION_PREDICTORS)])
complete_model_rows = function(data, month) sum(complete_rows(data, month))

# The number of coefficients of a model, from mgcv's model setup without fitting (seconds).
# The family is left at mgcv's default: it does not change the model matrix.
model_coefficients = function(model_id, month, data) {
  ncol(mgcv::gam(calibration_formula(model_id, month), data = data, fit = FALSE)$X)
}

# Fitting controls for every model. Eight threads is not an analysis setting: it changes no
# result beyond the last bit, and it is the thread count the stored fits were made with.
CALIBRATION_CONTROL = list(nthreads = 8, maxit = 500)

# The formula of a model for one month: that month's albedo column on the model's terms.
calibration_formula = function(model_id, month) {
  if (!model_id %in% names(CALIBRATION_MODELS)) stop('calibration_formula: unknown model id ', model_id)
  eval(call('~', as.name(month), CALIBRATION_MODELS[[model_id]]$rhs[[2]]), globalenv())
}

# The model's terms as text, for the run manifest: "s(x, y, bs = \"gp\", k = 500) + ...".
calibration_terms = function(model_id) paste(deparse(CALIBRATION_MODELS[[model_id]]$rhs[[2]], width.cutoff = 500L), collapse = ' ')

# Fit one model for one month to the calibration table. method is "REML" (the default, for
# the fit used to predict and for the spatial experiments) or "ML" (the ladder in the current
# configuration, config.R analysis$calibration$comparison_method; question B4). ML is the
# usual convention when models with different terms are compared; mgcv's AIC is valid on
# either. control is CALIBRATION_CONTROL for every pipeline fit; only a diagnostic passes
# another, e.g. a higher step limit in tools/check_model7_convergence.R (Chris, 2026-10-29).
fit_calibration_model = function(model_id, month, data, method = "REML", control = CALIBRATION_CONTROL) {
  mgcv::bam(calibration_formula(model_id, month),
            data      = data,
            family    = mgcv::betar(link = "logit"),
            method    = method,
            na.action = na.omit,
            control   = control)
}

# One line saying whether a fit really converged, for script 4's log. bam() always stores
# converged = TRUE without checking (mgcv 1.9.4), so its own field is no evidence. The first
# check is the one bam's fitting loop makes itself (it only warns "algorithm did not
# converge"): did the loop stop before its step limit? The rest is what mgcv's gam.check()
# prints for the smoothing-parameter optimiser (in the last loop step, for bam): full
# convergence, the largest gradient, and whether the Hessian is positive definite. Every
# sign of failure is marked NOT, so a log can be searched for it. A fit that keeps its model
# frame (every bam fit) also says how many rows it was fitted on: the cells with an albedo that
# month (na.omit), which differ by month and by albedo choice. (The brief of 2026-10-29 asked for
# the rows on script 4's convergence line; putting them here, so that the line and the model-7
# tool both carry them, was the implementer's choice.)
fit_convergence = function(fit) {
  rows = if (is.null(fit$model)) '' else sprintf('; fitted on %d rows', nrow(fit$model))
  paste0(loop_and_optimiser(fit), rows)
}

# Whether a fit converged, by the two tests of fit_convergence()'s line: the fitting loop stopped
# before its step limit, and the smoothing-parameter optimiser reports full convergence (the
# cross-validation's rule, protocol of 2 November 2026, section 5).
fit_converged = function(fit) fit$iter < fit$control$maxit && identical(fit$outer.info$conv, 'full convergence')

# The convergence part of fit_convergence()'s line.
loop_and_optimiser = function(fit) {
  # A loop that converged on exactly its last step looks the same in the saved fit as one
  # that ran out, so at the limit the line points to R's warning instead of guessing.
  loop = if (fit$iter >= fit$control$maxit) {
    sprintf('fitting loop: reached its limit of %d steps, probably NOT converged (see R\'s "algorithm did not converge" warning)',
            fit$control$maxit)
  } else {
    sprintf('fitting loop: %d of %d steps', fit$iter, fit$control$maxit)
  }
  outer = fit$outer.info
  if (is.null(outer) || is.null(outer$conv)) return(paste0(loop, '; smoothing parameters: not available'))
  optimiser = if (outer$conv == 'full convergence') outer$conv else paste('NOT converged:', outer$conv)
  smallest_eigenvalue = min(eigen(outer$hess, symmetric = TRUE, only.values = TRUE)$values)
  sprintf('%s; smoothing parameters: %s after %d iterations; largest gradient %.1e; Hessian %s (smallest eigenvalue %.2g)',
          loop, optimiser, outer$iter, max(abs(outer$grad)),
          if (smallest_eigenvalue > 0) 'positive definite' else 'NOT positive definite', smallest_eigenvalue)
}
