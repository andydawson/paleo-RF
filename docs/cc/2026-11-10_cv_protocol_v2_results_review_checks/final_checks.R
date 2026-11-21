# Review only (read-only): two remaining numbers.
source('R/cross_validation.R'); source('R/model_registry.R')
V = '/home/expert/Documents/contracting/Andria/paleo-RF-verify'
out = file.path(V, '1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2')
h = readRDS(file.path(out, 'holdouts.rds')); target = h$target
# 1. Share of each past slice outside the modern range (April's range; area as cos(latitude), no ice weighting: approximate).
cal = readRDS(file.path(out, 'separation/frozen.rds'))$cal
paleo = readRDS(file.path(V, '1d31cfc/.rundirs/cv2-winner/data/lct_paleo_reveals_interp.RDS'))
paleo = paleo[paleo$y > 27 & paleo$y < 74 & stats::complete.cases(paleo[, c('OL', 'ET', 'ST')]), ]
hull = training_hull(cal[complete_rows(cal, 'apr'), ])
s = training_support(paleo, hull); w = cospi(paleo$y / 180)
share = tapply(w * s$outside, paleo$ages, sum) / tapply(w, paleo$ages, sum)
cat('share of each slice outside the modern (April) range, by age in years BP:\n'); print(round(share, 3))
ne = paleo$x >= -80 & paleo$x < -66 & paleo$y >= 40 & paleo$y < 48
cat('same, northeast box only:\n'); print(round(tapply((w * s$outside)[ne], paleo$ages[ne], sum) / tapply(w[ne], paleo$ages[ne], sum), 2))
# 2. Paired differences among the location-500 versions, with and without the four Alaskan blocks.
p = do.call(rbind, lapply(Sys.glob(file.path(out, 'predictions_d[123]_*.rds')), readRDS))
p = p[is.finite(p$km) & p$km < 250 & p$group %in% target$group[target$weight > 0], ]
p$se2 = (p$predicted - p$observed)^2
models = c('loc100_linear', 'lin_cover', 'loc500_tp50', 'mod8'); key = paste(p$holdout, p$month, p$calibration_row)
base = p[p$model == models[1], ]; k0 = key[p$model == models[1]]
E = sapply(models, function(m) { d = p[p$model == m, ]; d$se2[match(k0, key[p$model == m])] })
block = paste(floor(base$x / 5), floor(base$y / 5))
score = function(mult) { s = rowsum(E * mult, base$group); n = rowsum(mult, base$group)[, 1]
  w = target$weight[match(rownames(s), target$group)] * (n > 0); colSums(s / pmax(n, 1) * w) / sum(w) }
for (label in c('all rows', 'without the four Alaskan blocks')) {
  keep = if (label == 'all rows') rep(TRUE, nrow(base)) else !block %in% c('-32 12', '-32 11', '-32 13', '-31 12')
  bl = unique(block[keep]); set.seed(20261110)
  B = t(replicate(2000, { pick = table(factor(sample(bl, replace = TRUE), levels = bl)); m = as.numeric(pick[block]); m[is.na(m)] = 0; score(m) }))
  full = score(as.numeric(keep))
  for (pair in list(c('mod8', 'lin_cover'), c('mod8', 'loc500_tp50'), c('lin_cover', 'loc100_linear'))) { d = B[, pair[1]] - B[, pair[2]]
    cat(sprintf('%-32s %-11s minus %-13s: %.6f, SE %.6f, ratio %.2f\n', label, pair[1], pair[2], full[[pair[1]]] - full[[pair[2]]], sd(d), (full[[pair[1]]] - full[[pair[2]]]) / sd(d))) }
}
