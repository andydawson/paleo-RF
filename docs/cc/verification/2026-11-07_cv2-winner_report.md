# Verification cv2-winner: PASS

- verdict: **PASS**
- commit: 1d31cfcb2c63831d3eea81336739b9b7178807d7
- spec: `docs/cc/verification/2026-11-06_cv2-winner.R`
- started 2026-11-06 23:57:40 UTC, finished 2026-11-07 22:50:48 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc` at 1d31cfcb2c63831d3eea81336739b9b7178807d7; 0 frozen inputs linked from the main checkout
- run folder `.rundirs/cv2-winner`; configuration `.rundirs/cv2-winner/config_used.R` (from `config.R`); 0 files copied in
- runner `tools/rscript.sh` with THREADS=8 OPENBLAS_NUM_THREADS=1

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261106T235753.010Z_2785359.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261106T235814.222Z_2785515.md`, 1 outputs
- scripts/3_plot_cal_lct_albedo.R: exit status 0, 0.7 min, run record `20261106T235919.862Z_2785872.md`, 0 outputs
- scripts/4_calibration_model.R: exit status 0, 1229.4 min, run record `20261107T000004.820Z_2786137.md`, 193 outputs
- scripts/5_calibration_eval.R: exit status 0, 6.1 min, run record `20261107T202934.309Z_4168458.md`, 13 outputs
- scripts/6_prediction_model.R: exit status 0, 10.1 min, run record `20261107T203539.940Z_4170673.md`, 38 outputs
- scripts/7_plot_preds.R: exit status 0, 71.1 min, run record `20261107T204547.135Z_4173129.md`, 4 outputs
- scripts/7a_alb_diff_full.R: exit status 0, 52.4 min, run record `20261107T215655.230Z_4189919.md`, 1 outputs
- scripts/8_radiative.R: exit status 0, 0.4 min, run record `20261107T224917.507Z_8955.md`, 1 outputs
- scripts/9_forcing_barplot.R: exit status 0, 0.6 min, run record `20261107T224940.618Z_9072.md`, 4 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.3 min, run record `20261107T225019.093Z_9376.md`, 1 outputs

## Anchors


## Checks

- `tests/test_config.R`: exit status 0 (log `check_01.log`)
- `tests/test_paths.R`: exit status 0 (log `check_02.log`)
- `tests/test_forcing_breakdown.R`: exit status 0 (log `check_03.log`)

## Failures

- none
