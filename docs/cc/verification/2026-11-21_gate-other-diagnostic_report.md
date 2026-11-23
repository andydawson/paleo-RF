# Verification gate-other-diagnostic: PASS

- verdict: **PASS**
- commit: 91735fb47ba3b623e1912cc74362b6777fb4cfd8
- spec: `docs/cc/verification/2026-11-21_gate-other-diagnostic.R`
- started 2026-11-21 19:28:45 UTC, finished 2026-11-21 19:30:02 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/91735fb` at 91735fb47ba3b623e1912cc74362b6777fb4cfd8; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/gate-other-diagnostic`; configuration `.rundirs/gate-other-diagnostic/config_used.R` (from `configs/legacy_config.R`); 0 files copied in
- runner `tools/rscript.sh` with THREADS=1 CORES=0-3

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.8 min, run record `20261121T192901.033Z_3764124.md`, 2 outputs

## Anchors


## Checks

- `tools/check_anchors.R tests/anchors/interp-allmonths-2026-09-20 .rundirs/gate-other-diagnostic`: exit status 0
- `-e f = list.files('.rundirs/gate-other-diagnostic/figures/diagnostics'); print(f);
                          stopifnot(c('1_absent_cell_slices.csv', '1_ice_flag_all_slices.png', '1_mean_vs_median.png',
                                      '1_mean_vs_median_difference.png') %in% f,
                                    any(grepl('^1_ice_flag_[0-9]{5}BP[.]png$', f)))`: exit status 0

## Failures

- none
