# Verification run7-snowy: PASS

- verdict: **PASS**
- commit: 74b5482e6d27d475141db91c7cbba2f825d990a7
- spec: `docs/cc/verification/2026-11-02_run7-snowy.R`
- started 2026-11-04 14:32:36 UTC, finished 2026-11-04 16:32:49 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/74b5482` at 74b5482e6d27d475141db91c7cbba2f825d990a7; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/run7-snowy`; configuration `.rundirs/run7-snowy/config_used.R` (from `config.R`); 160 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=0-7

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261104T143254.015Z_3741005.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261104T143315.447Z_3741077.md`, 1 outputs
- scripts/3_plot_cal_lct_albedo.R: exit status 0, 0.7 min, run record `20261104T143421.979Z_3746906.md`, 0 outputs
- scripts/5_calibration_eval.R: exit status 0, 4.7 min, run record `20261104T143503.563Z_3749199.md`, 11 outputs
- scripts/6_prediction_model.R: exit status 0, 9.0 min, run record `20261104T143948.914Z_3770280.md`, 32 outputs
- scripts/7_plot_preds.R: exit status 0, 59.7 min, run record `20261104T144853.099Z_3802011.md`, 4 outputs
- scripts/7a_alb_diff_full.R: exit status 0, 42.9 min, run record `20261104T154835.698Z_3896939.md`, 1 outputs
- scripts/8_radiative.R: exit status 0, 0.3 min, run record `20261104T163127.234Z_3952033.md`, 1 outputs
- scripts/9_forcing_barplot.R: exit status 0, 0.6 min, run record `20261104T163147.558Z_3952130.md`, 3 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.2 min, run record `20261104T163221.026Z_3952256.md`, 1 outputs

## Anchors


## Checks

- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tests/test_forcing_breakdown.R`: exit status 0

## Failures

- none
