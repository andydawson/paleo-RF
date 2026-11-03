# Verification run2-snowfree-2: PASS

- verdict: **PASS**
- commit: 8e3f3a49a4d0814003b4540e20de689f99c6c415
- spec: `docs/cc/verification/2026-11-03_run2-snowfree-2.R`
- started 2026-11-03 16:43:55 UTC, finished 2026-11-03 19:42:21 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/8e3f3a4` at 8e3f3a49a4d0814003b4540e20de689f99c6c415; 0 frozen inputs linked from the main checkout
- run folder `.rundirs/run2-snowfree-2`; configuration `.rundirs/run2-snowfree-2/config_used.R` (from `config.R`); 192 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=0-7

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.3 min, run record `20261103T164410.009Z_6989.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261103T164430.839Z_7056.md`, 1 outputs
- scripts/3_plot_cal_lct_albedo.R: exit status 0, 0.7 min, run record `20261103T164536.120Z_7432.md`, 0 outputs
- scripts/5_calibration_eval.R: exit status 0, 6.6 min, run record `20261103T164620.708Z_8017.md`, 13 outputs
- scripts/6_prediction_model.R: exit status 0, 11.5 min, run record `20261103T165254.580Z_11091.md`, 38 outputs
- scripts/7_plot_preds.R: exit status 0, 74.7 min, run record `20261103T170430.191Z_14082.md`, 4 outputs
- scripts/7a_alb_diff_full.R: exit status 0, 81.6 min, run record `20261103T181912.597Z_72552.md`, 1 outputs
- scripts/8_radiative.R: exit status 0, 0.4 min, run record `20261103T194047.120Z_96846.md`, 1 outputs
- scripts/9_forcing_barplot.R: exit status 0, 0.7 min, run record `20261103T194110.547Z_96915.md`, 4 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.3 min, run record `20261103T194150.176Z_97332.md`, 1 outputs

## Anchors


## Checks

- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tests/test_forcing_breakdown.R`: exit status 0

## Failures

- none
