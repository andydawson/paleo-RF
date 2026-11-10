# Review only (read-only): an independent block bootstrap of the paired score differences, and a
# direct check of the contrast helper against plain predict().
out = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2'
h = readRDS(file.path(out, 'holdouts.rds')); target = h$target
p = do.call(rbind, lapply(Sys.glob(file.path(out, 'predictions_d[123]_*.rds')), readRDS))
p = p[is.finite(p$km) & p$km < 250 & p$group %in% target$group[target$weight > 0], ]
p$se2 = (p$predicted - p$observed)^2
models = c('loc100_linear', 'loc100_tp50', 'loc100_tp200', 'loc500_tp50', 'lin_cover', 'mod8', 'loc30_tp50')
key = paste(p$holdout, p$month, p$calibration_row)
base = p[p$model == models[1], ]; k0 = key[p$model == models[1]]
E = sapply(models, function(m) { d = p[p$model == m, ]; d$se2[match(k0, key[p$model == m])] })
block = paste(floor(base$x / 5), floor(base$y / 5)); blocks = unique(block)
gw = target$weight[match(base$group, target$group)]
score = function(mult) { s = rowsum(E * mult, base$group); n = rowsum(mult, base$group)[, 1]
  w = target$weight[match(rownames(s), target$group)] * (n > 0); colSums(s / pmax(n, 1) * w) / sum(w) }
cat('blocks:', length(blocks), ' rows:', nrow(base), '\n')
set.seed(20261110)
B = t(replicate(2000, { pick = table(factor(sample(blocks, replace = TRUE), levels = blocks)); score(as.numeric(pick[block])) }))
full = score(rep(1, nrow(base)))
for (m in models[-1]) { d = B[, m] - B[, 1]
  cat(sprintf('%-13s minus winner: difference %.6f, bootstrap SE %.6f (ratio %.2f); 95%% interval %.6f to %.6f; winner better in %.1f%% of resamples\n',
              m, full[[m]] - full[[1]], sd(d), (full[[m]] - full[[1]]) / sd(d), quantile(d, .025), quantile(d, .975), 100 * mean(d > 0))) }
# How concentrated is the winner's margin over model 8? Share of the difference by block.
contrib = tapply((E[, 'mod8'] - E[, 'loc100_linear']) * gw / ave(rep(1, nrow(base)), base$group, FUN = sum), block, sum)
contrib = sort(contrib / sum(contrib), decreasing = TRUE)
cat('share of the model-8-minus-winner difference from the top 5 blocks:', round(sum(contrib[1:5]), 2), '; top 10:', round(sum(contrib[1:10]), 2), '; blocks with negative contribution:', sum(contrib < 0), 'of', length(contrib), '\n')
print(round(head(contrib, 8), 3))

suppressPackageStartupMessages(library(mgcv))
V = '/home/expert/Documents/contracting/Andria/paleo-RF-verify'
frozen = readRDS(file.path(out, 'separation/frozen.rds')); ex = frozen$months$apr$exchanges$historical
for (run in c('1d31cfc/.rundirs/cv2-winner', 'f05628d/.rundirs/cv-mod8')) {
  fit = readRDS(file.path(V, run, 'output/calibration/calibration_prediction_fit_apr_bluesky.RDS'))
  cat(run, 'April, direct predict(): ', sum(ex$weight * (predict(fit, ex$second, type = 'response') - predict(fit, ex$first, type = 'response'))), '\n')
}
