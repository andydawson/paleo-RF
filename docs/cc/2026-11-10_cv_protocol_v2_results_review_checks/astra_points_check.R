# Review follow-up (read-only): two points raised by Astra's check of the review.
V = '/home/expert/Documents/contracting/Andria/paleo-RF-verify'
out = file.path(V, '1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2')
h = readRDS(file.path(out, 'holdouts.rds')); target = h$target
p = do.call(rbind, lapply(Sys.glob(file.path(out, 'predictions_d[123]_*.rds')), readRDS))
p = p[is.finite(p$km) & p$km < 250 & p$group %in% target$group[target$weight > 0], ]
four = paste(floor(p$x / 5), floor(p$y / 5)) %in% c('-32 12', '-32 11', '-32 13', '-31 12')
m = function(model) round(tapply(p$predicted[four & p$model == model], factor(p$month[four & p$model == model], h$months), mean), 3)
cat('1. Mean albedo in the four Alaskan blocks, by month:\n')
print(rbind(observed = round(tapply(p$observed[four & p$model == 'mod8'], factor(p$month[four & p$model == 'mod8'], h$months), mean), 3),
            chosen = m('loc100_linear'), rival_loc500_linear = m('lin_cover'), model8 = m('mod8'), no_location = m('lin_cover_noloc')))
cat('rows per month:\n'); print(table(factor(p$month[four & p$model == 'mod8'], h$months)))
cat('\n2. Past cells north of the northernmost fitting cell, by month (27-74 N window; any slice):\n')
cal = readRDS(file.path(out, 'separation/frozen.rds'))$cal
paleo = readRDS(file.path(V, '1d31cfc/.rundirs/cv2-winner/data/lct_paleo_reveals_interp.RDS'))
paleo = paleo[paleo$y > 27 & paleo$y < 74, ]; cells = unique(paleo[, c('x', 'y')])
res = t(sapply(h$months, function(mo) { ok = !is.na(cal[[mo]]); north = max(cal$y[ok])
  key = paste(cells$x, cells$y) %in% paste(cal$x[ok], cal$y[ok])
  c(fitting_cells = sum(ok), northernmost_fitting_latitude = north, past_cells = nrow(cells), past_cells_north_of_it = sum(cells$y > north),
    past_cells_without_a_fitting_cell = sum(!key)) }))
print(res)
