# Verification run4-any75-snowfree: PASS

- verdict: **PASS**
- commit: c2ccdb1232ad654836ba062f566a3a80808f8b95
- spec: `docs/cc/verification/2026-11-02_run4-any75-snowfree.R`
- started 2026-11-04 06:12:05 UTC, finished 2026-11-04 09:05:40 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/c2ccdb1` at c2ccdb1232ad654836ba062f566a3a80808f8b95; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/run4-any75-snowfree`; configuration `.rundirs/run4-any75-snowfree/config_used.R` (from `config.R`); 192 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=0-7

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261104T061223.744Z_2251109.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261104T061244.859Z_2251222.md`, 1 outputs
- scripts/3_plot_cal_lct_albedo.R: exit status 0, 0.8 min, run record `20261104T061350.620Z_2251393.md`, 0 outputs
- scripts/5_calibration_eval.R: exit status 0, 6.5 min, run record `20261104T061435.675Z_2251480.md`, 13 outputs
- scripts/6_prediction_model.R: exit status 0, 11.6 min, run record `20261104T062108.257Z_2253821.md`, 38 outputs
- scripts/7_plot_preds.R: exit status 0, 73.1 min, run record `20261104T063246.217Z_2257313.md`, 4 outputs
- scripts/7a_alb_diff_full.R: exit status 0, 78.3 min, run record `20261104T074550.694Z_2566238.md`, 1 outputs
- scripts/8_radiative.R: exit status 0, 0.4 min, run record `20261104T090410.129Z_3004317.md`, 1 outputs
- scripts/9_forcing_barplot.R: exit status 0, 0.6 min, run record `20261104T090432.527Z_3004422.md`, 4 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.3 min, run record `20261104T090510.870Z_3004889.md`, 1 outputs

## Anchors


## Checks

- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tests/test_forcing_breakdown.R`: exit status 0

## Failures

- none
