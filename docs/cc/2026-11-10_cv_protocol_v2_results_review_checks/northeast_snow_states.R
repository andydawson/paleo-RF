# Review only (read-only): the same two northeast exchanges from model 8's existing snow-free and
# snowy calibrations (runs 2 and 7), beside its all-days calibration. No new fit. Cells are those of
# the frozen exchanges that the month's fit actually had an albedo for (no location extrapolation).
suppressPackageStartupMessages(library(mgcv))
source('R/cv_separation.R')
V = '/home/expert/Documents/contracting/Andria/paleo-RF-verify'
runs = c(all_days = file.path(V, 'f05628d/.rundirs/cv-mod8'), snow_free = file.path(V, '8e3f3a4/.rundirs/run2-snowfree-2'),
         snowy = file.path(V, '74b5482/.rundirs/run7-snowy'))
frozen = readRDS(file.path(V, '1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2/separation/frozen.rds'))
exch = list(hist = frozen$months$apr$exchanges$historical, fixed = frozen$months$apr$exchanges$fixed)
months = c('jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec')
rows = NULL
for (run in names(runs)) for (m in months) {
  f = file.path(runs[[run]], 'output/calibration', sprintf('calibration_prediction_fit_%s_bluesky.RDS', m))
  if (!file.exists(f)) next
  fit = readRDS(f); have = paste(fit$model$x, fit$model$y)
  ne = fit$model$x >= -80 & fit$model$x < -66 & fit$model$y >= 40 & fit$model$y < 48
  r = data.frame(run = run, month = m, n_fit = nrow(fit$model), ne_cells = sum(ne), ne_albedo = mean(fit$model[[m]][ne]))
  for (e in names(exch)) { x = exch[[e]]; keep = paste(x$first$x, x$first$y) %in% have
    s = list(first = x$first[keep, ], second = x$second[keep, ], weight = x$area[keep] / sum(x$area[keep]))
    v = if (any(keep)) exchange_contrast(fit, s) else c(contrast = NA, se = NA)
    r[[paste0(e, '_cells')]] = sum(keep); r[[e]] = v[['contrast']]; r[[paste0(e, '_se')]] = v[['se']] }
  rows = rbind(rows, r); rm(fit); gc(verbose = FALSE)
}
options(width = 220)
rows[, c('ne_albedo', 'hist', 'hist_se', 'fixed', 'fixed_se')] = round(rows[, c('ne_albedo', 'hist', 'hist_se', 'fixed', 'fixed_se')], 4)
print(rows, row.names = FALSE)
