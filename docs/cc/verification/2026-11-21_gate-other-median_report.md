# Verification gate-other-median: PASS

- verdict: **PASS**
- commit: a06eddf15d2179f2bda70a368f9879e5f7964f4a
- spec: `docs/cc/verification/2026-11-21_gate-other-median.R`
- started 2026-11-21 19:28:46 UTC, finished 2026-11-21 19:32:26 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/a06eddf` at a06eddf15d2179f2bda70a368f9879e5f7964f4a; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/gate-other-median`; configuration `.rundirs/gate-other-median/config_used.R` (from `configs/legacy_config.R`); 0 files copied in
- runner `tools/rscript.sh` with THREADS=1 CORES=4-7

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.5 min, run record `20261121T192902.368Z_3764185.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 2.7 min, run record `20261121T192929.489Z_3764516.md`, 2 outputs

## Anchors


## Checks

- `-e covers = c('ET', 'OL', 'ST')
    for (t in c('lct_modern_reveals_interp.RDS', 'lct_paleo_reveals_interp.RDS')) {
      med = readRDS(file.path('.rundirs/gate-other-median/data', t)); avg = readRDS(file.path('data', t))
      keys = setdiff(names(avg), covers)
      med = med[do.call(order, unname(as.list(med[keys]))), ]; avg = avg[do.call(order, unname(as.list(avg[keys]))), ]
      err = max(abs(rowSums(med[covers]) - 1)); d = abs(as.matrix(med[covers]) - as.matrix(avg[covers]))
      cat(t, ':', nrow(med), 'rows; columns', names(med), '; largest row-sum error', err,
          '; median minus mean, mean', mean(d), 'largest', max(d), '
')
      stopifnot(identical(names(med), names(avg)), nrow(med) == nrow(avg),
                all(mapply(identical, as.list(med[keys]), as.list(avg[keys]))), err < 1e-12, max(d) > 0)
    }`: exit status 0

## Failures

- none
