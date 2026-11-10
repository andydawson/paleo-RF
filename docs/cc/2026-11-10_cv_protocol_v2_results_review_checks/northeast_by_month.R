# Review only (read-only): the protocol's two northeast exchanges, for all twelve months, from the
# full-data prediction fits the three pipeline runs already saved. No new fit. Uses the project's own
# contrast code (R/cv_separation.R) and the cells and areas frozen for the capacity test.
suppressPackageStartupMessages(library(mgcv))
source('R/cv_separation.R')
V = '/home/expert/Documents/contracting/Andria/paleo-RF-verify'
runs = c(winner_loc100_linear = file.path(V, '1d31cfc/.rundirs/cv2-winner'),
         coarse_loc30_tp200   = file.path(V, 'e82f399/.rundirs/cv-chosen'),
         model8               = file.path(V, 'f05628d/.rundirs/cv-mod8'))
frozen = readRDS(file.path(V, '1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2/separation/frozen.rds'))
hist  = frozen$months$apr$exchanges$historical   # 6 ka cover -> 4.5 ka evergreen at 6 ka open land (same cells every month)
fixed = frozen$months$apr$exchanges$fixed        # modern cells: 0.05 less evergreen -> 0.05 more evergreen
cal = frozen$cal
ne = separation_northeast(cal)
months = c('jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec')
rows = NULL
for (run in names(runs)) for (m in months) {
  fit = readRDS(file.path(runs[[run]], 'output/calibration', sprintf('calibration_prediction_fit_%s_bluesky.RDS', m)))
  h = exchange_contrast(fit, hist); f = exchange_contrast(fit, fixed)
  hull = training_hull(cal[complete_rows(cal, m), ])
  out_h = mean(training_support(hist$first, hull)$outside | training_support(hist$second, hull)$outside)
  out_f = mean(training_support(fixed$first, hull)$outside | training_support(fixed$second, hull)$outside)
  obs = cal[[m]][ne & complete_rows(cal, m)]
  r = data.frame(run = run, month = m, n_fit = nrow(fit$model), converged = fit_converged(fit),
                 ne_cells_observed = length(obs), ne_mean_albedo = mean(obs),
                 hist = h[['contrast']], hist_se = h[['se']], hist_outside = out_h,
                 fixed = f[['contrast']], fixed_se = f[['se']], fixed_outside = out_f,
                 b_ET = NA, b_ST = NA, swap_logit = NA, swap_logit_se = NA, edf_loc = NA)
  s = calibration_fit_summary(fit)
  if (any(s$term == 's(x,y)')) r$edf_loc = s$edf[s$term == 's(x,y)']
  if (all(c('ET', 'ST') %in% names(coef(fit)))) {
    b = coef(fit)[c('ET', 'ST')]; Vb = fit$Vp[match(c('ET', 'ST'), names(coef(fit))), match(c('ET', 'ST'), names(coef(fit)))]
    r$b_ET = b[['ET']]; r$b_ST = b[['ST']]; r$swap_logit = b[['ST']] - b[['ET']]
    r$swap_logit_se = sqrt(Vb[1, 1] + Vb[2, 2] - 2 * Vb[1, 2])
    r$b_ET_se = sqrt(Vb[1, 1]); r$b_ST_se = sqrt(Vb[2, 2])
  } else { r$b_ET_se = NA; r$b_ST_se = NA }
  rows = rbind(rows, r); rm(fit); gc(verbose = FALSE)
}
options(width = 250)
cat('Historical-size exchange (6 ka -> 4.5 ka evergreen, mean decline 0.18, open land at 6 ka). Positive = brighter after the decline.\n')
w = reshape(rows[, c('run', 'month', 'hist')], idvar = 'month', timevar = 'run', direction = 'wide')
s = reshape(rows[, c('run', 'month', 'hist_se')], idvar = 'month', timevar = 'run', direction = 'wide')
print(cbind(month = w$month, round(w[, -1], 4), round(s[, -1], 4), ne_mean_albedo = round(rows$ne_mean_albedo[rows$run == 'model8'], 3),
            outside_share = round(rows$hist_outside[rows$run == 'model8'], 2)), row.names = FALSE)
cat('\nFixed exchange at modern northeast cells (0.10 more evergreen replacing summergreen). Negative = darker with more evergreen.\n')
w = reshape(rows[, c('run', 'month', 'fixed')], idvar = 'month', timevar = 'run', direction = 'wide')
s = reshape(rows[, c('run', 'month', 'fixed_se')], idvar = 'month', timevar = 'run', direction = 'wide')
print(cbind(month = w$month, round(w[, -1], 4), round(s[, -1], 4), outside_share = round(rows$fixed_outside[rows$run == 'model8'], 2)), row.names = FALSE)
cat('\nWinner: cover coefficients on the logit scale (open land is the reference), and the albedo slope of a full\n')
cat('evergreen-to-summergreen swap at the northeast mean albedo, mu(1-mu) x (b_ST - b_ET):\n')
x = rows[rows$run == 'winner_loc100_linear', ]
x$slope_per_unit = x$ne_mean_albedo * (1 - x$ne_mean_albedo) * x$swap_logit
x$slope_se = x$ne_mean_albedo * (1 - x$ne_mean_albedo) * x$swap_logit_se
x$forest_to_open_ET = -x$ne_mean_albedo * (1 - x$ne_mean_albedo) * x$b_ET
x$forest_to_open_ST = -x$ne_mean_albedo * (1 - x$ne_mean_albedo) * x$b_ST
print(data.frame(month = x$month, n = x$n_fit, conv = x$converged, edf_loc = round(x$edf_loc, 1), ne_albedo = round(x$ne_mean_albedo, 3),
                 b_ET = round(x$b_ET, 3), se = round(x$b_ET_se, 3), b_ST = round(x$b_ST, 3), se = round(x$b_ST_se, 3),
                 swap_logit = round(x$swap_logit, 3), se = round(x$swap_logit_se, 3),
                 summergreen_minus_evergreen = round(x$slope_per_unit, 4), se = round(x$slope_se, 4),
                 open_minus_evergreen = round(x$forest_to_open_ET, 4), open_minus_summergreen = round(x$forest_to_open_ST, 4)), row.names = FALSE)
cat('\nall fits converged:', all(rows$converged), '\n')
saveRDS(rows, './northeast_by_month.rds')
