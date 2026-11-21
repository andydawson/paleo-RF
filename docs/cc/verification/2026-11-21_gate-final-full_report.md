# Verification gate-final-full: PASS

- verdict: **PASS**
- commit: d0ed3544701c8b50462322e43d954b6560dce09e
- spec: `docs/cc/verification/2026-11-20_gate-final-full.R`
- started 2026-11-20 17:11:12 UTC, finished 2026-11-21 19:10:32 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/d0ed354` at d0ed3544701c8b50462322e43d954b6560dce09e; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/gate-final-full`; configuration `.rundirs/gate-final-full/config_used.R` (from `config.R`); 0 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=24-31

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261120T171129.010Z_2941808.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261120T171150.536Z_2942132.md`, 1 outputs
- scripts/3_plot_cal_lct_albedo.R: exit status 0, 0.8 min, run record `20261120T171259.512Z_2942975.md`, 0 outputs
- scripts/4_calibration_model.R: exit status 0, 1384.7 min, run record `20261120T171346.904Z_2943422.md`, 193 outputs
- scripts/5_calibration_eval.R: exit status 0, 7.0 min, run record `20261121T161835.188Z_3673140.md`, 13 outputs
- scripts/6_prediction_model.R: exit status 0, 11.9 min, run record `20261121T162538.765Z_3677710.md`, 38 outputs
- scripts/7_plot_preds.R: exit status 0, 74.7 min, run record `20261121T163736.512Z_3684334.md`, 4 outputs
- scripts/7a_alb_diff_full.R: exit status 0, 76.5 min, run record `20261121T175219.839Z_3716857.md`, 1 outputs
- scripts/8_radiative.R: exit status 0, 0.4 min, run record `20261121T190851.174Z_3750638.md`, 1 outputs
- scripts/9_forcing_barplot.R: exit status 0, 0.8 min, run record `20261121T190915.241Z_3750812.md`, 4 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.3 min, run record `20261121T191001.492Z_3751186.md`, 1 outputs

## Anchors


## Checks

- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tests/test_forcing_breakdown.R`: exit status 0

## Failures

- none
