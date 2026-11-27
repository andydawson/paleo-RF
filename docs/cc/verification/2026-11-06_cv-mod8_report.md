# Verification cv-mod8: PASS

- verdict: **PASS**
- commit: f05628d58a62f9501f7e8a7c39f494813b24ead3
- spec: `docs/cc/verification/2026-11-05_cv-mod8.R`
- started 2026-11-06 07:11:36 UTC, finished 2026-11-06 09:39:13 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/f05628d` at f05628d58a62f9501f7e8a7c39f494813b24ead3; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/cv-mod8`; configuration `.rundirs/cv-mod8/config_used.R` (from `config.R`); 192 files copied in
- runner `tools/rscript.sh` with THREADS=8

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261106T071154.513Z_2206724.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261106T071216.511Z_2207020.md`, 1 outputs
- scripts/3_plot_cal_lct_albedo.R: exit status 0, 0.8 min, run record `20261106T071322.355Z_2207504.md`, 0 outputs
- scripts/5_calibration_eval.R: exit status 0, 6.7 min, run record `20261106T071408.288Z_2207788.md`, 13 outputs
- scripts/6_prediction_model.R: exit status 0, 12.0 min, run record `20261106T072048.871Z_2212953.md`, 38 outputs
- scripts/7_plot_preds.R: exit status 0, 71.7 min, run record `20261106T073250.771Z_2220179.md`, 4 outputs
- scripts/7a_alb_diff_full.R: exit status 0, 53.2 min, run record `20261106T084432.749Z_2248899.md`, 1 outputs
- scripts/8_radiative.R: exit status 0, 0.4 min, run record `20261106T093743.504Z_2271539.md`, 1 outputs
- scripts/9_forcing_barplot.R: exit status 0, 0.6 min, run record `20261106T093806.214Z_2271711.md`, 4 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.3 min, run record `20261106T093845.175Z_2271958.md`, 1 outputs

## Anchors


## Checks

- `tests/test_config.R`: exit status 0
- `tests/test_forcing_breakdown.R`: exit status 0

## Failures

- none
