# Verification run5-winter: PASS

- verdict: **PASS**
- commit: 4946d09ad0c816b6b35d00831d6d95369bdeb9cd
- spec: `docs/cc/verification/2026-11-02_run5-winter.R`
- started 2026-11-04 09:06:56 UTC, finished 2026-11-04 09:46:53 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/4946d09` at 4946d09ad0c816b6b35d00831d6d95369bdeb9cd; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/run5-winter`; configuration `.rundirs/run5-winter/config_used.R` (from `config.R`); 64 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=0-7

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261104T090711.537Z_3005703.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261104T090733.092Z_3005873.md`, 1 outputs
- scripts/3_plot_cal_lct_albedo.R: exit status 0, 0.8 min, run record `20261104T090837.978Z_3006071.md`, 0 outputs
- scripts/5_calibration_eval.R: exit status 0, 1.7 min, run record `20261104T090923.561Z_3006187.md`, 5 outputs
- scripts/6_prediction_model.R: exit status 0, 3.9 min, run record `20261104T091103.479Z_3006854.md`, 14 outputs
- scripts/7_plot_preds.R: exit status 0, 21.2 min, run record `20261104T091501.470Z_3008160.md`, 4 outputs
- scripts/7a_alb_diff_full.R: exit status 0, 9.9 min, run record `20261104T093615.350Z_3014730.md`, 1 outputs
- scripts/8_radiative.R: exit status 0, 0.2 min, run record `20261104T094606.447Z_3017750.md`, 1 outputs
- scripts/9_forcing_barplot.R: exit status 0, 0.3 min, run record `20261104T094617.695Z_3017791.md`, 3 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.1 min, run record `20261104T094633.089Z_3017858.md`, 1 outputs

## Anchors


## Checks

- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tests/test_forcing_breakdown.R`: exit status 0

## Failures

- none
