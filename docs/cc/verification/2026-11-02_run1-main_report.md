# Verification run1-main: PASS

- verdict: **PASS**
- commit: d5d5df5232a735167a1d06edf184de0ac259d8af
- spec: `docs/cc/verification/2026-11-01_run1-main.R`
- started 2026-11-01 22:51:54 UTC, finished 2026-11-02 01:40:16 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5` at d5d5df5232a735167a1d06edf184de0ac259d8af; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/run1-main`; configuration `.rundirs/run1-main/config_used.R` (from `config.R`); 192 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=0-7

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261101T225212.363Z_4059028.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261101T225233.973Z_4059166.md`, 1 outputs
- scripts/3_plot_cal_lct_albedo.R: exit status 0, 0.7 min, run record `20261101T225338.559Z_4059408.md`, 0 outputs
- scripts/5_calibration_eval.R: exit status 0, 6.7 min, run record `20261101T225423.055Z_4059637.md`, 13 outputs
- scripts/6_prediction_model.R: exit status 0, 11.4 min, run record `20261101T230104.541Z_4061389.md`, 38 outputs
- scripts/7_plot_preds.R: exit status 0, 70.2 min, run record `20261101T231235.134Z_4064232.md`, 4 outputs
- scripts/7a_alb_diff_full.R: exit status 0, 76.0 min, run record `20261102T002245.205Z_4081146.md`, 1 outputs
- scripts/8_radiative.R: exit status 0, 0.4 min, run record `20261102T013846.161Z_4099161.md`, 1 outputs
- scripts/9_forcing_barplot.R: exit status 0, 0.6 min, run record `20261102T013908.471Z_4099303.md`, 4 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.3 min, run record `20261102T013947.043Z_4099463.md`, 1 outputs

## Anchors


## Checks

- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tests/test_forcing_breakdown.R`: exit status 0

## Failures

- none
