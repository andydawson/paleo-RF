# Verification guards-cv: PASS

- verdict: **PASS**
- commit: 0b8c031b00639e2cb5640f88e103082280327430
- spec: `docs/cc/verification/2026-11-04_guards-cv.R`
- started 2026-11-04 12:45:08 UTC, finished 2026-11-04 12:54:40 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/0b8c031` at 0b8c031b00639e2cb5640f88e103082280327430; 0 frozen inputs linked from the main checkout
- run folder `.rundirs/guards-cv`; configuration `.rundirs/guards-cv/config_used.R` (from `config.R`); 1 files copied in
- runner `tools/rscript.sh` with THREADS=1

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261104T124521.194Z_3529495.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261104T124542.534Z_3530888.md`, 1 outputs

## Anchors


## Checks

- `tools/compare_tables.R /home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main/data/calibration_modern_lct_interp_bluesky.RDS .rundirs/guards-cv/data/calibration_modern_lct_interp_bluesky.RDS`: exit status 0
- `tests/test_cross_validation.R`: exit status 0
- `tests/test_model_registry.R`: exit status 0
- `tests/test_training_support.R`: exit status 0
- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tools/cross_validate_albedo.R holdouts .rundirs/guards-cv`: exit status 0
- `-e old = tools::md5sum(file.path('/home/expert/Documents/contracting/Andria/paleo-RF-verify/11356e0/.rundirs/cv-holdouts-7/output/cross_validation', c('feasibility.csv', 'directions.csv', 'target.csv', 'comparison.csv'))); new = tools::md5sum(file.path('.rundirs/guards-cv/output/cross_validation', c('feasibility.csv', 'directions.csv', 'target.csv', 'comparison.csv'))); print(cbind(old, new)); stopifnot(identical(unname(old), unname(new)))`: exit status 0
- `tests/test_cross_validation_stages.R .rundirs/guards-cv`: exit status 0

## Failures

- none
