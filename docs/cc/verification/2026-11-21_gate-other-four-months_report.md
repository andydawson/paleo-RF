# Verification gate-other-four-months: PASS

- verdict: **PASS**
- commit: 68ca9ad9662f13fb3f515d128ea4d20cfd41808a
- spec: `docs/cc/verification/2026-11-21_gate-other-four-months.R`
- started 2026-11-21 19:28:46 UTC, finished 2026-11-21 20:10:46 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/68ca9ad` at 68ca9ad9662f13fb3f515d128ea4d20cfd41808a; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/gate-other-four-months`; configuration `.rundirs/gate-other-four-months/config_used.R` (from `configs/legacy_config.R`); 187 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=8-15

## Scripts

- scripts/5_calibration_eval.R: exit status 0, 1.8 min, run record `20261121T192904.525Z_3764229.md`, 5 outputs
- scripts/6_prediction_model.R: exit status 0, 4.2 min, run record `20261121T193052.513Z_3765339.md`, 14 outputs
- scripts/7_plot_preds.R: exit status 0, 23.2 min, run record `20261121T193503.025Z_3768362.md`, 4 outputs
- scripts/7a_alb_diff_full.R: exit status 0, 11.8 min, run record `20261121T195814.105Z_3784071.md`, 1 outputs
- scripts/8_radiative.R: exit status 0, 0.2 min, run record `20261121T201000.335Z_3802894.md`, 1 outputs
- scripts/9_forcing_barplot.R: exit status 0, 0.2 min, run record `20261121T201011.674Z_3803316.md`, 4 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.1 min, run record `20261121T201025.788Z_3803818.md`, 1 outputs

## Anchors


## Checks

- `-e source('tools/check_anchors.R')
                          r = check_anchors('tests/anchors/interp-seed1-2026-10-14', '.rundirs/gate-other-four-months')
                          r = r[grepl('_(feb|may|aug|nov)_bluesky[.]RDS$', r$file), ]; print(r, row.names = FALSE)
                          stopifnot(nrow(r) == 8, all(r$result == 'MATCH'))`: exit status 0
- `-e f = readRDS('.rundirs/gate-other-four-months/output/forcing/RF_holocene_all_cases.RDS')
                          print(table(as.character(f$month)))
                          stopifnot(setequal(as.character(f$month), c('feb', 'may', 'aug', 'nov')))`: exit status 0

## Failures

- none
