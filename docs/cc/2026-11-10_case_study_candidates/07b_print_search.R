# Print the tile-and-window search of 07_search_tiles_and_windows.R compactly (one line per
# tile and window), by the question asked.  Usage: Rscript 07b_print_search.R <A|B|C|D|E|F> [rows]
source('./case_study_helpers.R')
args = commandArgs(trailingOnly = TRUE); what = args[1]; rows = if (length(args) > 1) as.integer(args[2]) else 40
found = readRDS(file.path(CACHE, 'tile_window_search.RDS'))
albedo_columns = paste0('albedo_', names(RUNS)); forcing_columns = paste0('forcing_', names(RUNS))
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
short = c('open land' = 'OL', evergreen = 'ET', summergreen = 'ST')
show = function(t, n) {
  t = head(t, n)
  ex = sapply(strsplit(t$exchange, ' to '), function(p) paste(short[p[1]], short[p[2]], sep = '>'))
  cat(sprintf('%-22s %-11s %5s %6s %6s %6s %4s %5s %-6s | %7s %7s %7s | %6s %6s %6s\n', 'box (lon, lat)', 'old>young', 'free', 'dOL', 'dET', 'dST', 'pur', 'xnois', 'exch', 'alb_m8', 'alb_ch', 'alb_co', 'rf_m8', 'rf_ch', 'rf_co'))
  for (i in seq_len(nrow(t))) cat(sprintf('%4.0f..%4.0f %4.1f..%4.1f %5.0f>%5.0f %5.2f %6.3f %6.3f %6.3f %4.2f %5.1f %-6s | %7.4f %7.4f %7.4f | %6.2f %6.2f %6.2f\n',
    t$lon_min[i], t$lon_max[i], t$lat_min[i], t$lat_max[i], t$old[i], t$young[i], t$ice_free_share[i], t$d_OL[i], t$d_ET[i], t$d_ST[i], t$purity[i], t$change_over_noise[i], ex[i],
    t$albedo_mod8[i], t$albedo_loc100_linear[i], t$albedo_mod8_coarse_loc[i], t$forcing_mod8[i], t$forcing_loc100_linear[i], t$forcing_mod8_coarse_loc[i]))
}
events = found[found$old - found$young <= 2000 & found$ice_free_share > 0.9, ]
if (what == 'A') { cat('A. Largest cover changes within 2000 years, tiles more than 90 % ice-free (two best windows per tile)\n')
  b = best_windows(events, 'largest_change'); show(b[order(-b$largest_change), ], rows) }
if (what == 'B') { cat('B. Cleanest large exchanges (purity > 0.8, largest change > 0.05), within 2000 years\n')
  clean = events[events$purity > 0.8 & events$largest_change > 0.05, ]; b = best_windows(clean, 'largest_change', 2); show(b[order(-b$largest_change), ], rows) }
if (what == 'C') { cat('C. Largest disagreement between the runs: range of the annual albedo change\n')
  b = best_windows(events, 'albedo_range', 1); show(b[order(-b$albedo_range), ], rows) }
if (what == 'D') { cat('D. Largest agreed albedo change: same sign in all three runs, ranked by the smallest absolute change\n')
  agreed = events[events$same_sign, ]; agreed$smallest = apply(abs(agreed[, albedo_columns]), 1, min); b = best_windows(agreed, 'smallest', 1); show(b[order(-b$smallest), ], rows) }
if (what == 'E') { cat('E. Largest vegetation forcing in any run (absolute, W/m2 over the tile, HadGEM3)\n')
  events$largest_forcing = apply(abs(events[, forcing_columns]), 1, max); b = best_windows(events, 'largest_forcing', 1); show(b[order(-b$largest_forcing), ], rows) }
if (what == 'F') { cat('F. Largest changes south of 50 N and after 9 ka (away from the ice), within 2000 years\n')
  south = events[events$lat_max <= 52 & events$old <= 9000, ]; b = best_windows(south, 'largest_change', 2); show(b[order(-b$largest_change), ], rows) }
if (what == 'G') { cat('G. Sign disagreement: runs differ in sign and the range is large, cover change > 0.05\n')
  dis = events[!events$same_sign & events$largest_change > 0.05, ]; b = best_windows(dis, 'albedo_range', 1); show(b[order(-b$albedo_range), ], rows) }
