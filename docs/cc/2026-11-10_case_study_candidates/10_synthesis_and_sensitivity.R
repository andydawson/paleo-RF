# Two checks across the candidates.
#
# 1. The same question asked of every candidate: how much does each run change the albedo
#    per unit of cover exchanged, by season? For an evergreen-summergreen exchange the unit
#    is cover moved from summergreen to evergreen; for an open-land exchange it is cover moved
#    from trees and shrubs to open land. Put side by side, the candidates then show whether a
#    run behaves the same way everywhere, and the published class contrasts can be read
#    against them. A ratio is only meaningful where the exchange is fairly clean, so the
#    purity is given.
# 2. Whether a candidate's result depends on exactly where its box and slices were put: the
#    box is moved two degrees each way and each end of the window one slice each way, and the
#    spread of each run's vegetation forcing is given, with how often its sign holds.
# Writes candidate_response_per_unit_cover.csv and candidate_sensitivity.csv.
source('./case_study_helpers.R')
a = read_cache(); cells = a$cells; ages = a$ages
candidates = read.csv(file.path(OUT_DIR, 'candidates.csv'), stringsAsFactors = FALSE)
SEASONS = list(`Dec-Feb` = c('dec', 'jan', 'feb'), `Mar-May` = c('mar', 'apr', 'may'), `Jun-Aug` = c('jun', 'jul', 'aug'), `Sep-Nov` = c('sep', 'oct', 'nov'))

# Cover change, albedo change by month and annual vegetation forcing of one box and window.
box_window = function(box, old, young) {
  inside = in_box(cells, box)
  i_old = slice_index(ages, old); i_young = slice_index(ages, young)
  area = cells$area[inside]
  weight = area * (1 - pmax(a$ice[inside, i_old], a$ice[inside, i_young]))
  pairs_in = which(a$pairs >= young & a$pairs < old)
  list(cells = sum(inside),
       change = sapply(CLASSES, function(class) weighted_mean(a$cover[inside, i_young, class] - a$cover[inside, i_old, class], weight)),
       albedo = sapply(names(RUNS), function(run) sapply(MONTHS, function(month)
         weighted_mean(a$fitted_albedo[[run]][inside, i_young, month] - a$fitted_albedo[[run]][inside, i_old, month], weight))),
       forcing = sapply(names(RUNS), function(run)
         weighted_mean(rowMeans(apply(a$forcing[[run]]$hadgem_veg_part[inside, pairs_in, , drop = FALSE], c(1, 3), sum), na.rm = TRUE), area)))
}

# ---- 1. Response per unit of cover exchanged ---------------------------------------------
per_unit = do.call(rbind, lapply(seq_len(nrow(candidates)), function(i) {
  candidate = candidates[i, ]; r = box_window(candidate, candidate$old, candidate$young); d = r$change
  evergreen_summergreen = abs(d[['OL']]) < pmin(abs(d[['ET']]), abs(d[['ST']]))
  unit = if (evergreen_summergreen) (d[['ET']] - d[['ST']]) / 2 else d[['OL']]
  do.call(rbind, lapply(names(SEASONS), function(season) data.frame(
    candidate = candidate$key, kind = if (evergreen_summergreen) 'summergreen to evergreen' else 'trees and shrubs to open land',
    cover_exchanged = unit, purity = exchange_purity(d[['OL']], d[['ET']], d[['ST']]), season = season,
    t(setNames(colMeans(r$albedo[SEASONS[[season]], , drop = FALSE]) / unit, paste0('albedo_per_unit_', names(RUNS)))), row.names = NULL)))
}))
write.csv(per_unit, file.path(OUT_DIR, 'candidate_response_per_unit_cover.csv'), row.names = FALSE)
for (kind in unique(per_unit$kind)) {
  cat('\n== Albedo change per unit of cover moved from', kind, '(model 8 / chosen / coarse-location)\n')
  t = per_unit[per_unit$kind == kind, ]
  cat(sprintf('%-28s %9s %6s  %-22s %-22s %-22s %-22s\n', 'candidate', 'exchanged', 'purity', names(SEASONS)[1], names(SEASONS)[2], names(SEASONS)[3], names(SEASONS)[4]))
  for (key in unique(t$candidate)) { k = t[t$candidate == key, ]
    cat(sprintf('%-28s %+9.3f %6.2f  ', key, k$cover_exchanged[1], k$purity[1]),
        paste(sprintf('%+5.2f/%+5.2f/%+5.2f  ', k$albedo_per_unit_mod8, k$albedo_per_unit_loc100_linear, k$albedo_per_unit_mod8_coarse_loc), collapse = '  '), '\n') }
}

# ---- 2. Sensitivity to the box and to the slices -----------------------------------------
shift_slice = function(age, by) ages[pmin(pmax(match(age, ages) + by, 1), length(ages))]
sensitivity = do.call(rbind, lapply(seq_len(nrow(candidates)), function(i) {
  candidate = candidates[i, ]
  base = box_window(candidate, candidate$old, candidate$young)
  variants = list()
  for (dx in c(-2, 0, 2)) for (dy in c(-2, 0, 2)) {
    box = candidate; box$lon_min = box$lon_min + dx; box$lon_max = box$lon_max + dx; box$lat_min = box$lat_min + dy; box$lat_max = box$lat_max + dy
    variants[[length(variants) + 1]] = box_window(box, candidate$old, candidate$young)$forcing
  }
  for (d_old in c(-1, 0, 1)) for (d_young in c(-1, 0, 1)) {
    old = shift_slice(candidate$old, d_old); young = shift_slice(candidate$young, d_young)
    if (old > young) variants[[length(variants) + 1]] = box_window(candidate, old, young)$forcing
  }
  v = do.call(rbind, variants)
  data.frame(candidate = candidate$key, variants = nrow(v), run = names(RUNS), forcing_base = base$forcing,
             forcing_lowest = apply(v, 2, min), forcing_highest = apply(v, 2, max),
             same_sign_share = sapply(names(RUNS), function(run) mean(sign(v[, run]) == sign(base$forcing[[run]]))), row.names = NULL)
}))
write.csv(sensitivity, file.path(OUT_DIR, 'candidate_sensitivity.csv'), row.names = FALSE)
cat('\n== Vegetation forcing (W/m2 over the box, HadGEM3): base, and lowest to highest over the moved boxes and windows; share with the base sign\n')
for (key in unique(sensitivity$candidate)) { k = sensitivity[sensitivity$candidate == key, ]
  cat(sprintf('%-28s', key), paste(sprintf('%+5.2f (%+5.2f to %+5.2f; %3.0f%%)', k$forcing_base, k$forcing_lowest, k$forcing_highest, 100 * k$same_sign_share), collapse = '   '), '\n') }
