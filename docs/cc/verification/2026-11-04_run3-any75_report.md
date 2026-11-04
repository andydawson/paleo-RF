# Verification run3-any75: PASS

- verdict: **PASS**
- commit: 7850d4673b64983dbfaad225c9182e86297a1354
- spec: `docs/cc/verification/2026-11-02_run3-any75.R`
- started 2026-11-04 01:40:32 UTC, finished 2026-11-04 04:37:24 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/7850d46` at 7850d4673b64983dbfaad225c9182e86297a1354; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/run3-any75`; configuration `.rundirs/run3-any75/config_used.R` (from `config.R`); 192 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=0-7

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261104T014050.890Z_2167440.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261104T014112.399Z_2167556.md`, 1 outputs
- scripts/3_plot_cal_lct_albedo.R: exit status 0, 0.8 min, run record `20261104T014218.906Z_2167731.md`, 0 outputs
- scripts/5_calibration_eval.R: exit status 0, 6.6 min, run record `20261104T014306.234Z_2168218.md`, 13 outputs
- scripts/6_prediction_model.R: exit status 0, 11.9 min, run record `20261104T014941.685Z_2170226.md`, 38 outputs
- scripts/7_plot_preds.R: exit status 0, 74.3 min, run record `20261104T020139.510Z_2173917.md`, 4 outputs
- scripts/7a_alb_diff_full.R: exit status 0, 79.9 min, run record `20261104T031559.194Z_2196794.md`, 1 outputs
- scripts/8_radiative.R: exit status 0, 0.4 min, run record `20261104T043550.703Z_2220334.md`, 1 outputs
- scripts/9_forcing_barplot.R: exit status 0, 0.7 min, run record `20261104T043614.043Z_2220772.md`, 4 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.3 min, run record `20261104T043653.600Z_2220876.md`, 1 outputs

## Anchors


## Checks

- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tests/test_forcing_breakdown.R`: exit status 0

## Failures

- none
