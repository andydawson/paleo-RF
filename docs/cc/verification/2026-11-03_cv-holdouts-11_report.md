# Verification cv-holdouts-11: PASS

- verdict: **PASS**
- commit: f0c253633d047b474c6ce03221a366d4d86b78d0
- spec: `docs/cc/verification/2026-11-03_cv-holdouts-11.R`
- started 2026-11-03 23:22:21 UTC, finished 2026-11-03 23:32:25 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/f0c2536` at f0c253633d047b474c6ce03221a366d4d86b78d0; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/cv-holdouts-11`; configuration `.rundirs/cv-holdouts-11/config_used.R` (from `config.R`); 1 files copied in
- runner `tools/rscript.sh` with THREADS=1

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261103T232236.892Z_1647440.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261103T232259.903Z_1652838.md`, 1 outputs

## Anchors


## Checks

- `tools/compare_tables.R /home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main/data/calibration_modern_lct_interp_bluesky.RDS .rundirs/cv-holdouts-11/data/calibration_modern_lct_interp_bluesky.RDS`: exit status 0
- `tests/test_cross_validation.R`: exit status 0
- `tests/test_model_registry.R`: exit status 0
- `tests/test_training_support.R`: exit status 0
- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tools/cross_validate_albedo.R holdouts .rundirs/cv-holdouts-11`: exit status 0
- `-e old = tools::md5sum(file.path('/home/expert/Documents/contracting/Andria/paleo-RF-verify/11356e0/.rundirs/cv-holdouts-7/output/cross_validation', c('feasibility.csv', 'directions.csv', 'target.csv', 'comparison.csv'))); new = tools::md5sum(file.path('.rundirs/cv-holdouts-11/output/cross_validation', c('feasibility.csv', 'directions.csv', 'target.csv', 'comparison.csv'))); print(cbind(old, new)); stopifnot(identical(unname(old), unname(new)))`: exit status 0
- `tests/test_cross_validation_stages.R .rundirs/cv-holdouts-11`: exit status 0

## Failures

- none
