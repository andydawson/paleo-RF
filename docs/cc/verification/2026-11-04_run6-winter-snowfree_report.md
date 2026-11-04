# Verification run6-winter-snowfree: PASS

- verdict: **PASS**
- commit: ba5e69aff2998c07d829822bf2a1638bc03a3a93
- spec: `docs/cc/verification/2026-11-02_run6-winter-snowfree.R`
- started 2026-11-04 09:47:31 UTC, finished 2026-11-04 10:27:02 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/ba5e69a` at ba5e69aff2998c07d829822bf2a1638bc03a3a93; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/run6-winter-snowfree`; configuration `.rundirs/run6-winter-snowfree/config_used.R` (from `config.R`); 64 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=0-7

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261104T094748.024Z_3018593.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261104T094809.131Z_3018692.md`, 1 outputs
- scripts/3_plot_cal_lct_albedo.R: exit status 0, 0.7 min, run record `20261104T094914.294Z_3018853.md`, 0 outputs
- scripts/5_calibration_eval.R: exit status 0, 1.5 min, run record `20261104T094958.426Z_3018976.md`, 5 outputs
- scripts/6_prediction_model.R: exit status 0, 3.7 min, run record `20261104T095131.158Z_3019555.md`, 14 outputs
- scripts/7_plot_preds.R: exit status 0, 21.2 min, run record `20261104T095511.887Z_3020741.md`, 4 outputs
- scripts/7a_alb_diff_full.R: exit status 0, 9.8 min, run record `20261104T101624.870Z_3027157.md`, 1 outputs
- scripts/8_radiative.R: exit status 0, 0.2 min, run record `20261104T102615.605Z_3030307.md`, 1 outputs
- scripts/9_forcing_barplot.R: exit status 0, 0.3 min, run record `20261104T102626.825Z_3030352.md`, 3 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.1 min, run record `20261104T102642.216Z_3030446.md`, 1 outputs

## Anchors


## Checks

- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tests/test_forcing_breakdown.R`: exit status 0

## Failures

- none
