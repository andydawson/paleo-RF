# Final integration gate (issue #16), other settings 2 of 3, which Chris chose on 21 November 2026 to rerun on the
# final code: the median land cover (analysis$land_cover$reduction = "median") through scripts 1 and 2, from the
# original analysis's configuration. No anchor exists for the median. The check: both tables keep the mean tables'
# columns and keys (cell, age, elevation), each row's three shares add up to 1, and the shares differ from the mean's
# (so the median was used); script 2 must run on them. The mean tables are the baseline files in data/, equal to the
# all-months anchor. Last run in October (changelog, I04a). Commit a06eddf has the trunk's current code (identical to
# 68ca9ad, the tip).
list(
  name     = 'gate-other-median',
  commit   = 'a06eddf15d2179f2bda70a368f9879e5f7964f4a',
  config   = 'configs/legacy_config.R',
  settings = list(analysis = list(land_cover = list(reduction = 'median'))),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R'),
  checks   = list(c('-e', "covers = c('ET', 'OL', 'ST')
    for (t in c('lct_modern_reveals_interp.RDS', 'lct_paleo_reveals_interp.RDS')) {
      med = readRDS(file.path('.rundirs/gate-other-median/data', t)); avg = readRDS(file.path('data', t))
      keys = setdiff(names(avg), covers)
      med = med[do.call(order, unname(as.list(med[keys]))), ]; avg = avg[do.call(order, unname(as.list(avg[keys]))), ]
      err = max(abs(rowSums(med[covers]) - 1)); d = abs(as.matrix(med[covers]) - as.matrix(avg[covers]))
      cat(t, ':', nrow(med), 'rows; columns', names(med), '; largest row-sum error', err,
          '; median minus mean, mean', mean(d), 'largest', max(d), '\n')
      stopifnot(identical(names(med), names(avg)), nrow(med) == nrow(avg),
                all(mapply(identical, as.list(med[keys]), as.list(avg[keys]))), err < 1e-12, max(d) > 0)
    }")),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1', CORES = '4-7'))
