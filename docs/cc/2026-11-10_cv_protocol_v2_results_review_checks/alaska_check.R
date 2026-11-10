# Review only (read-only): does the choice depend on a few Alaskan blocks?
out = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2'
h = readRDS(file.path(out, 'holdouts.rds')); target = h$target
p = do.call(rbind, lapply(Sys.glob(file.path(out, 'predictions_d[123]_*.rds')), readRDS))
p = p[is.finite(p$km) & p$km < 250 & p$group %in% target$group[target$weight > 0] & p$model != 'cover_elev', ]
p$se2 = (p$predicted - p$observed)^2; p$err = p$predicted - p$observed
models = setdiff(h$models, 'cover_elev')
key = paste(p$holdout, p$month, p$calibration_row)
base = p[p$model == models[1], ]; k0 = key[p$model == models[1]]
E = sapply(models, function(m) { d = p[p$model == m, ]; d$se2[match(k0, key[p$model == m])] })
block = paste(floor(base$x / 5), floor(base$y / 5)); blocks = unique(block)
score = function(mult) { s = rowsum(E * mult, base$group); n = rowsum(mult, base$group)[, 1]
  w = target$weight[match(rownames(s), target$group)] * (n > 0); c(colSums(s / pmax(n, 1) * w) / sum(w), represented = sum(w) / sum(target$weight)) }
show = function(label, keep) { s = score(as.numeric(keep)); r = sqrt(s[models]); o = order(r)
  cat(sprintf('%-46s rows %5d, target weight kept %.2f | %s | mod8 %.4f, lin_cover(k500) %.4f\n', label, sum(keep), s[['represented']],
              paste(sprintf('%s %.4f', models[o][1:4], r[o][1:4]), collapse = ', '), r[['mod8']], r[['lin_cover']])) }
show('all selected rows', rep(TRUE, nrow(base)))
show('without the four top blocks (W/interior Alaska)', !block %in% c('-32 12', '-32 11', '-32 13', '-31 12'))
show('without Alaska and Yukon west of 140 W', base$x > -140)
show('only east of 100 W', base$x > -100)
show('without the ten top blocks', !block %in% c('-32 12','-32 11','-32 13','-31 12','-25 10','-17 8','-12 10','-24 10', names(sort(tapply((E[, 'mod8'] - E[, 'loc100_linear']) * target$weight[match(base$group, target$group)] / ave(rep(1, nrow(base)), base$group, FUN = sum), block, sum), decreasing = TRUE))[9:10]))
# Paired bootstrap of mod8 minus winner and lin_cover minus winner without the four Alaskan blocks.
keep = !block %in% c('-32 12', '-32 11', '-32 13', '-31 12'); bl = unique(block[keep]); set.seed(20261110)
B = t(replicate(2000, { pick = table(factor(sample(bl, replace = TRUE), levels = bl)); m = as.numeric(pick[block]); m[is.na(m)] = 0; score(m)[models] }))
full = score(as.numeric(keep))[models]
for (m in c('loc100_tp50', 'loc500_tp50', 'lin_cover', 'mod8', 'loc30_tp50')) { d = B[, m] - B[, 'loc100_linear']
  cat(sprintf('without the four blocks: %-12s minus winner %.6f, SE %.6f (ratio %.2f), winner better in %.1f%% of resamples\n', m, full[[m]] - full[['loc100_linear']], sd(d), (full[[m]] - full[['loc100_linear']]) / sd(d), 100 * mean(d > 0))) }
a = base[!keep, ]
cat('the four blocks: cells', nrow(unique(a[, c('x', 'y')])), '; rows', nrow(a), '; holdouts', paste(names(table(a$holdout)), table(a$holdout), collapse = ', '), '\n')
b8 = p[p$model == 'mod8', ][match(k0, key[p$model == 'mod8']), ][!keep, ]; bw = base[!keep, ]
print(round(rbind(observed = tapply(bw$observed, factor(bw$month, h$months), mean), winner = tapply(bw$predicted, factor(bw$month, h$months), mean),
                  mod8 = tapply(b8$predicted, factor(b8$month, h$months), mean)), 3))
