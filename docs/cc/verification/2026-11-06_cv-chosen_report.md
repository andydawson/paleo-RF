# Verification cv-chosen: PASS

- verdict: **PASS**
- commit: e82f399cda884c5e1071ea1d8a6fd5623a7227ff
- spec: `docs/cc/verification/2026-11-05_cv-chosen.R`
- started 2026-11-06 07:11:36 UTC, finished 2026-11-06 09:38:35 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/e82f399` at e82f399cda884c5e1071ea1d8a6fd5623a7227ff; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/cv-chosen`; configuration `.rundirs/cv-chosen/config_used.R` (from `config.R`); 192 files copied in
- runner `tools/rscript.sh` with THREADS=8

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261106T071155.717Z_2206777.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261106T071217.634Z_2207055.md`, 1 outputs
- scripts/3_plot_cal_lct_albedo.R: exit status 0, 0.8 min, run record `20261106T071323.262Z_2207541.md`, 0 outputs
- scripts/5_calibration_eval.R: exit status 0, 6.5 min, run record `20261106T071408.613Z_2207823.md`, 13 outputs
- scripts/6_prediction_model.R: exit status 0, 11.7 min, run record `20261106T072036.432Z_2212755.md`, 38 outputs
- scripts/7_plot_preds.R: exit status 0, 71.7 min, run record `20261106T073224.583Z_2219977.md`, 4 outputs
- scripts/7a_alb_diff_full.R: exit status 0, 53.0 min, run record `20261106T084408.487Z_2248786.md`, 1 outputs
- scripts/8_radiative.R: exit status 0, 0.4 min, run record `20261106T093706.529Z_2271329.md`, 1 outputs
- scripts/9_forcing_barplot.R: exit status 0, 0.6 min, run record `20261106T093729.100Z_2271424.md`, 4 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.3 min, run record `20261106T093807.784Z_2271749.md`, 1 outputs

## Anchors


## Checks

- `tests/test_config.R`: exit status 0
- `tests/test_forcing_breakdown.R`: exit status 0

## Failures

- none
