# What "jumps out" of the reconstruction and of the three runs: a search over tiles of the
# study area and over every pair of slices.
#
# For each tile (10 degrees of longitude by 5 of latitude, stepped by half a tile so that a
# feature on a tile edge is not missed) and each window (an older and a younger slice) it
# computes the area-weighted mean change of the three cover fractions, how clean an exchange
# it is, the three runs' albedo change (mean of the twelve months) and their vegetation
# forcing, and writes one table. Exploration: the candidates are chosen from this and from
# the literature, and are then computed again on their own boxes (08_candidates.R).
source('./case_study_helpers.R')
a = read_cache(); cells = a$cells; ages = a$ages

tiles = expand.grid(lon_min = seq(-170, -60, by = 5), lat_min = seq(27, 69, by = 2.5))
tiles$lon_max = tiles$lon_min + 10; tiles$lat_max = tiles$lat_min + 5
tiles$n_cells = sapply(seq_len(nrow(tiles)), function(i) sum(in_box(cells, tiles[i, ])))
tiles = tiles[tiles$n_cells >= 20, ]

windows = subset(expand.grid(young = ages, old = ages), old > young)

# The annual (twelve-month) fitted albedo of each run by cell and slice, and the forcing of
# each pair by cell: the months' mean, over the months with a kernel value.
annual_albedo  = lapply(a$fitted_albedo, function(x) apply(x, 1:2, mean))
annual_forcing = lapply(a$forcing, function(f) apply(f$hadgem_veg_part, 1:2, mean, na.rm = TRUE))

tile_window = function(tile) {
  inside = in_box(cells, tile)
  cover = a$cover[inside, , , drop = FALSE]; ice = a$ice[inside, , drop = FALSE]; area = cells$area[inside]
  do.call(rbind, lapply(seq_len(nrow(windows)), function(w) {
    i_young = slice_index(ages, windows$young[w]); i_old = slice_index(ages, windows$old[w])
    # A cell counts by its area times its ice-free share at the icier end of the window.
    weight = area * (1 - pmax(ice[, i_young], ice[, i_old]))
    if (sum(weight) < 0.5 * sum(area)) return(NULL)
    d = sapply(CLASSES, function(class) weighted_mean(cover[, i_young, class] - cover[, i_old, class], weight))
    albedo = sapply(names(RUNS), function(run) weighted_mean(annual_albedo[[run]][inside, i_young] - annual_albedo[[run]][inside, i_old], weight))
    pairs_in = which(a$pairs >= windows$young[w] & a$pairs < windows$old[w])
    forcing = sapply(names(RUNS), function(run) weighted_mean(rowSums(annual_forcing[[run]][inside, pairs_in, drop = FALSE]), area))
    data.frame(tile[, c('lon_min', 'lon_max', 'lat_min', 'lat_max')], old = windows$old[w], young = windows$young[w],
               ice_free_share = sum(weight) / sum(area),
               d_OL = d[['OL']], d_ET = d[['ET']], d_ST = d[['ST']],
               setNames(as.list(albedo), paste0('albedo_', names(RUNS))), setNames(as.list(forcing), paste0('forcing_', names(RUNS))))
  }))
}
found = do.call(rbind, lapply(seq_len(nrow(tiles)), function(i) tile_window(tiles[i, ])))
found$largest_change = pmax(abs(found$d_OL), abs(found$d_ET), abs(found$d_ST))
found$purity   = exchange_purity(found$d_OL, found$d_ET, found$d_ST)
found$exchange = exchange_label(found$d_OL, found$d_ET, found$d_ST)
albedo_columns = paste0('albedo_', names(RUNS))
found$albedo_mean  = rowMeans(found[, albedo_columns])
found$albedo_range = apply(found[, albedo_columns], 1, max) - apply(found[, albedo_columns], 1, min)
found$same_sign    = apply(sign(found[, albedo_columns]), 1, function(s) length(unique(s)) == 1)

# The reconstruction's step-to-step movement in each tile: the median over the 24 consecutive
# pairs of the largest class change. The slices are interpolated one at a time, so this is a
# rough measure of how much a tile mean moves between slices when nothing much happens.
tile_key = with(found, paste(lon_min, lat_min))
steps = found[match(found$old, ages) - match(found$young, ages) == 1, ]
step_noise = tapply(steps$largest_change, paste(steps$lon_min, steps$lat_min), median)
found$step_noise = step_noise[tile_key]
found$change_over_noise = found$largest_change / found$step_noise
saveRDS(found, file.path(CACHE, 'tile_window_search.RDS'))

# The best window of each tile first, then the next best that does not overlap it in time.
best_windows = function(table, score, per_tile = 2) {
  do.call(rbind, lapply(split(table, paste(table$lon_min, table$lat_min)), function(t) {
    t = t[order(-t[[score]]), ]; kept = t[0, ]
    for (i in seq_len(nrow(t))) {
      if (nrow(kept) >= per_tile) break
      if (!any(t$young[i] < kept$old & t$old[i] > kept$young)) kept = rbind(kept, t[i, ])
    }
    kept
  }))
}
show = function(t, n = 40) {
  t = head(t, n)
  out = data.frame(box = sprintf('%4.0f..%4.0f E %4.1f..%4.1f N', t$lon_min, t$lon_max, t$lat_min, t$lat_max),
                   window = sprintf('%5.0f>%5.0f', t$old, t$young), free = round(t$ice_free_share, 2),
                   dOL = round(t$d_OL, 3), dET = round(t$d_ET, 3), dST = round(t$d_ST, 3), purity = round(t$purity, 2),
                   x_noise = round(t$change_over_noise, 1), exchange = t$exchange,
                   alb8 = round(t$albedo_mod8, 4), alb_chosen = round(t$albedo_loc100_linear, 4), alb_coarse = round(t$albedo_mod8_coarse_loc, 4),
                   rf8 = round(t$forcing_mod8, 2), rf_chosen = round(t$forcing_loc100_linear, 2), rf_coarse = round(t$forcing_mod8_coarse_loc, 2))
  print(out, row.names = FALSE)
}
events = found[found$old - found$young <= 2000 & found$ice_free_share > 0.9, ]
cat('\n== A. Largest cover changes within 2000 years, ice-free tiles (two best windows per tile)\n')
b = best_windows(events, 'largest_change'); show(b[order(-b$largest_change), ], 45)
cat('\n== B. Cleanest large exchanges (purity > 0.8, largest change > 0.05) within 2000 years\n')
clean = events[events$purity > 0.8 & events$largest_change > 0.05, ]
b = best_windows(clean, 'largest_change', 1); show(b[order(-b$largest_change), ], 35)
cat('\n== C. Largest albedo disagreement between the runs (range of the annual change), windows within 2000 years\n')
b = best_windows(events, 'albedo_range', 1); show(b[order(-b$albedo_range), ], 25)
cat('\n== D. Largest agreed albedo change: same sign in all three runs, ranked by the smallest absolute change of the three\n')
agreed = events[events$same_sign, ]; agreed$smallest = apply(abs(agreed[, albedo_columns]), 1, min)
b = best_windows(agreed, 'smallest', 1); show(b[order(-b$smallest), ], 25)
cat('\n== E. Largest vegetation forcing in any run (absolute), windows within 2000 years\n')
events$largest_forcing = apply(abs(events[, paste0('forcing_', names(RUNS))]), 1, max)
b = best_windows(events, 'largest_forcing', 1); show(b[order(-b$largest_forcing), ], 25)
