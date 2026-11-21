# Review only, exploratory (not part of protocol 2; writes nothing to any run folder): the chosen model's
# formula (location k = 100, elevation, linear cover) fitted to the existing snow-free and snowy
# calibration tables of runs 2 and 7, to see whether its evergreen/summergreen coefficient changes sign with snow.
suppressPackageStartupMessages(library(mgcv))
source('R/calibration_fit.R')
V = '/home/expert/Documents/contracting/Andria/paleo-RF-verify'
tables = c(all_days = file.path(V, '1d31cfc/.rundirs/cv2-winner'), snow_free = file.path(V, '8e3f3a4/.rundirs/run2-snowfree-2'),
           snowy = file.path(V, '74b5482/.rundirs/run7-snowy'))
months = c('jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec')
rows = NULL
for (t in names(tables)) {
  cal = readRDS(file.path(tables[[t]], 'data/calibration_modern_lct_interp_bluesky.RDS'))
  for (m in months) {
    if (!m %in% names(cal) || sum(complete_rows(cal, m)) < 500) next
    started = Sys.time()
    r = fit_calibration_retry('loc100_linear', m, cal)
    if (!r$converged) { rows = rbind(rows, data.frame(table = t, month = m, n = sum(complete_rows(cal, m)), converged = FALSE, ne_cells = NA, ne_albedo = NA,
      summergreen_minus_evergreen = NA, se = NA, open_minus_evergreen = NA, open_minus_summergreen = NA, minutes = NA)); next }
    fit = r$fit; ne = fit$model$x >= -80 & fit$model$x < -66 & fit$model$y >= 40 & fit$model$y < 48
    mu = if (any(ne)) mean(fit$model[[m]][ne]) else NA
    i = match(c('ET', 'ST'), names(coef(fit))); b = coef(fit)[i]; Vb = fit$Vp[i, i]
    rows = rbind(rows, data.frame(table = t, month = m, n = nrow(fit$model), converged = TRUE, ne_cells = sum(ne), ne_albedo = mu,
      summergreen_minus_evergreen = mu * (1 - mu) * (b[[2]] - b[[1]]), se = mu * (1 - mu) * sqrt(Vb[1, 1] + Vb[2, 2] - 2 * Vb[1, 2]),
      open_minus_evergreen = -mu * (1 - mu) * b[[1]], open_minus_summergreen = -mu * (1 - mu) * b[[2]],
      minutes = as.numeric(difftime(Sys.time(), started, units = 'mins'))))
  }
}
options(width = 200); num = sapply(rows, is.numeric); rows[num] = round(rows[num], 4)
print(rows, row.names = FALSE)
