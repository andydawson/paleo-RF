# Verification cv-run1: PASS

- verdict: **PASS**
- commit: f07ff68045a1f32f511b1244ce5808197e241a5b
- spec: `docs/cc/verification/2026-11-04_cv-run1.R`
- started 2026-11-04 15:06:37 UTC, finished 2026-11-04 15:13:01 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/f07ff68` at f07ff68045a1f32f511b1244ce5808197e241a5b; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/cv-run1`; configuration `.rundirs/cv-run1/config_used.R` (from `config.R`); 1 files copied in
- runner `tools/rscript.sh` with THREADS=1

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261104T150651.771Z_3822698.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261104T150713.463Z_3823233.md`, 1 outputs

## Anchors


## Checks

- `tools/compare_tables.R /home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main/data/calibration_modern_lct_interp_bluesky.RDS .rundirs/cv-run1/data/calibration_modern_lct_interp_bluesky.RDS`: exit status 0
- `tests/test_cross_validation.R`: exit status 0
- `tests/test_model_registry.R`: exit status 0
- `tests/test_training_support.R`: exit status 0
- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tools/cross_validate_albedo.R holdouts .rundirs/cv-run1`: exit status 0
- `-e old = tools::md5sum(file.path('/home/expert/Documents/contracting/Andria/paleo-RF-verify/11356e0/.rundirs/cv-holdouts-7/output/cross_validation', c('feasibility.csv', 'directions.csv', 'target.csv', 'comparison.csv'))); new = tools::md5sum(file.path('.rundirs/cv-run1/output/cross_validation', c('feasibility.csv', 'directions.csv', 'target.csv', 'comparison.csv'))); print(cbind(old, new)); stopifnot(identical(unname(old), unname(new)))`: exit status 0

## Failures

- none
