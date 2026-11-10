# Review only, exploratory (not part of protocol 2; writes only to the scratchpad): the closest rival of the
# chosen model (location k = 500, elevation, linear cover; registry id lin_cover) fitted to the all-days and
# snow-free calibration tables, one month per process, to read its evergreen/summergreen coefficient.
suppressPackageStartupMessages(library(mgcv))
source('R/calibration_fit.R')
m = commandArgs(trailingOnly = TRUE)[1]
V = '/home/expert/Documents/contracting/Andria/paleo-RF-verify'
tables = c(all_days = file.path(V, '1d31cfc/.rundirs/cv2-winner'), snow_free = file.path(V, '8e3f3a4/.rundirs/run2-snowfree-2'))
rows = NULL
for (t in names(tables)) {
  cal = readRDS(file.path(tables[[t]], 'data/calibration_modern_lct_interp_bluesky.RDS'))
  started = Sys.time(); r = fit_calibration_retry('lin_cover', m, cal)
  if (!r$converged) { cat(t, m, 'NOT converged:', r$status, '\n'); next }
  fit = r$fit; ne = fit$model$x >= -80 & fit$model$x < -66 & fit$model$y >= 40 & fit$model$y < 48
  mu = mean(fit$model[[m]][ne]); i = match(c('ET', 'ST'), names(coef(fit))); b = coef(fit)[i]; Vb = fit$Vp[i, i]
  rows = rbind(rows, data.frame(table = t, month = m, n = nrow(fit$model), retries = r$retries, ne_cells = sum(ne), ne_albedo = mu,
    summergreen_minus_evergreen = mu * (1 - mu) * (b[[2]] - b[[1]]), se = mu * (1 - mu) * sqrt(Vb[1, 1] + Vb[2, 2] - 2 * Vb[1, 2]),
    open_minus_evergreen = -mu * (1 - mu) * b[[1]], open_minus_summergreen = -mu * (1 - mu) * b[[2]],
    edf_location = sum(fit$edf[fit$smooth[[1]]$first.para:fit$smooth[[1]]$last.para]),
    minutes = as.numeric(difftime(Sys.time(), started, units = 'mins'))))
}
write.csv(rows, sprintf('./rival_%s.csv', m), row.names = FALSE)
