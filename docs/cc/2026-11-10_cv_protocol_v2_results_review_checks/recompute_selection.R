# Review only (read-only): recompute protocol 2's selection score from the saved predictions,
# independently of R/cross_validation.R, then break it down. Writes nothing.
out = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2'
h = readRDS(file.path(out, 'holdouts.rds'))
target = h$target
p = do.call(rbind, lapply(Sys.glob(file.path(out, 'predictions_d[123]_*.rds')), readRDS))
cat(nrow(p), 'prediction rows;', length(unique(p$model)), 'models;', length(unique(paste(p$holdout, p$month))), 'holdout-months\n')
p$ok  = p$converged & is.finite(p$predicted)
p$se2 = ifelse(p$ok, (p$predicted - p$observed)^2, NA)
p$err = ifelse(p$ok, p$predicted - p$observed, NA)
p$sel = is.finite(p$km) & p$km < 250 & p$group %in% target$group[target$weight > 0]
w_of  = function(g) target$weight[match(g, target$group)]
score = function(d) { if (!nrow(d)) return(NA_real_); g = tapply(d$se2, d$group, mean); w = w_of(names(g)); sum(g * w) / sum(w) }
models = h$models; months = h$months
S = function(keep) sapply(models, function(m) score(p[keep & p$model == m, ]))

cat('\n== 1. Overall selection MSE: recomputed against scores.csv\n')
saved = read.csv(file.path(out, 'scores.csv'))
overall = S(p$sel)
print(data.frame(recomputed = overall, saved = saved$score[match(models, saved$model)],
                 max_abs_diff = abs(overall - saved$score[match(models, saved$model)])), digits = 6)
cat('unconverged or failed fits by model:\n'); print(table(p$model[!p$ok], paste(p$holdout, p$month)[!p$ok]))

cat('\n== 2. Selection RMSE by month (same rows and weights, one month at a time)\n')
bym = sapply(months, function(mo) sqrt(S(p$sel & p$month == mo)))
print(round(bym, 3))
cat('winner of each month: '); print(apply(bym, 2, function(v) names(which.min(v))))
cat('rank of loc100_linear, loc100_tp50, mod8 in each month:\n')
print(apply(bym, 2, function(v) rank(v, na.last = 'keep')[c('loc100_linear', 'loc100_tp50', 'mod8', 'lin_cover', 'lin_cover_noloc')]))

cat('\n== 3. Each month\'s share of the overall MSE (weight x group MSE), winner and model 8\n')
contrib = function(m) { d = p[p$sel & p$model == m, ]; g = tapply(d$se2, d$group, mean); w = w_of(names(g))
  mo = sub(' .*', '', names(g)); tapply(g * w, factor(mo, months), sum) / sum(w) }
cw = contrib('loc100_linear'); c8 = contrib('mod8')
print(round(rbind(winner = cw, mod8 = c8, difference = c8 - cw, share_of_difference = (c8 - cw) / sum(c8 - cw)), 5))

cat('\n== 4. Selection RMSE by distance to the nearest training cell, and by departure direction\n')
print(round(sqrt(cbind(under_100km = S(p$sel & p$km < 100), km_100_to_250 = S(p$sel & p$km >= 100),
                       d1 = S(p$sel & p$own_direction == 'd1'), d2 = S(p$sel & p$own_direction == 'd2'),
                       d3 = S(p$sel & p$own_direction == 'd3'))), 4))
cat('rows under 100 km:', sum(p$sel & p$km < 100 & p$model == 'mod8'), ' rows 100-250 km:', sum(p$sel & p$km >= 100 & p$model == 'mod8'), '\n')
cat('quantiles of km among selected rows:\n'); print(round(quantile(p$km[p$sel & p$model == 'mod8'], c(0, .1, .25, .5, .75, .9, 1)), 1))

cat('\n== 5. Post-hoc sensitivity of the choice (not the protocol\'s rule): which model has the lowest score if...\n')
alt = list(all = p$sel, under_100km = p$sel & p$km < 100, km_100_250 = p$sel & p$km >= 100,
           snow_free_jun_sep = p$sel & p$month %in% c('jun', 'jul', 'aug', 'sep'),
           oct_to_may = p$sel & !p$month %in% c('jun', 'jul', 'aug', 'sep'),
           shallow_cover_under_0.02 = p$sel & p$distance < 0.02, deeper_cover_0.02_plus = p$sel & p$distance >= 0.02)
for (n in names(alt)) { s = sqrt(S(alt[[n]])); o = order(s)[1:4]
  cat(sprintf('%-26s %s | mod8 %.4f\n', n, paste(sprintf('%s %.4f', names(s)[o], s[o]), collapse = ', '), s[['mod8']])) }
cat('leave one month out, lowest score: ')
print(sapply(months, function(mo) names(which.min(S(p$sel & p$month != mo)))))
# Months standardised by the spread of observed albedo among that month's selected rows.
v = tapply(p$observed[p$sel & p$model == 'mod8'], p$month[p$sel & p$model == 'mod8'], var)
p$se2_raw = p$se2; p$se2 = p$se2_raw / v[p$month]
s = sort(sqrt(S(p$sel))); cat('months standardised by observed variance (relative RMSE):\n'); print(round(s, 3))
p$se2 = p$se2_raw

cat('\n== 6. Model 8 minus winner, mean squared error and bias, by km bin and cover-distance band (selected rows)\n')
a = p[p$sel & p$model == 'loc100_linear', ]; b = p[p$sel & p$model == 'mod8', ]; l = p[p$sel & p$model == 'lin_cover', ]
key = function(d) paste(d$holdout, d$month, d$calibration_row)
stopifnot(identical(key(a), key(b)), identical(key(a), key(l)))
kmb = cut(a$km, c(0, 100, 150, 200, 250), right = FALSE); cb = cut(a$distance, c(0, .02, .05, .10, Inf), right = FALSE)
tab = function(x) round(tapply(x, list(kmb, cb), mean), 4)
cat('rows:\n'); print(table(kmb, cb))
cat('winner RMSE:\n'); print(round(sqrt(tapply(a$se2, list(kmb, cb), mean)), 3))
cat('model 8 RMSE:\n'); print(round(sqrt(tapply(b$se2, list(kmb, cb), mean)), 3))
cat('linear cover with location k=500, RMSE:\n'); print(round(sqrt(tapply(l$se2, list(kmb, cb), mean)), 3))
cat('winner bias:\n'); print(tab(a$err)); cat('model 8 bias:\n'); print(tab(b$err))
cat('\nsame by month group (jun-sep, then oct-may), all directions: model 8 RMSE then winner RMSE:\n')
for (grp in list(c('jun', 'jul', 'aug', 'sep'), setdiff(months, c('jun', 'jul', 'aug', 'sep')))) { k = a$month %in% grp
  cat(paste(grp, collapse = ' '), '\n'); print(round(sqrt(tapply(b$se2[k], list(kmb[k], cb[k]), mean)), 3)); print(round(sqrt(tapply(a$se2[k], list(kmb[k], cb[k]), mean)), 3)) }

cat('\n== 7. Where the selected (nearby) withheld cells are\n')
u = unique(a[, c('holdout', 'x', 'y')])
print(do.call(rbind, lapply(split(u, u$holdout), function(d) data.frame(holdout = d$holdout[1], cells = nrow(d),
  lon_q = paste(round(quantile(d$x, c(.05, .5, .95)), 1), collapse = ' / '), lat_q = paste(round(quantile(d$y, c(.05, .5, .95)), 1), collapse = ' / ')))))
