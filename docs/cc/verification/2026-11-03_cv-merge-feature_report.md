# Verification cv-merge-feature: PASS

- verdict: **PASS**
- commit: e00a8d06f116b18ce074ca66aebfd903534edab6
- spec: `docs/cc/verification/2026-11-03_cv-merge-feature.R`
- started 2026-11-03 23:34:33 UTC, finished 2026-11-03 23:44:32 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/e00a8d0` at e00a8d06f116b18ce074ca66aebfd903534edab6; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/cv-merge-feature`; configuration `.rundirs/cv-merge-feature/config_used.R` (from `config.R`); 1 files copied in
- runner `tools/rscript.sh` with THREADS=1

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261103T233450.383Z_1740725.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261103T233512.902Z_1744394.md`, 1 outputs

## Anchors


## Checks

- `tests/test_tools.R`: exit status 0
- `tests/test_verify_change.R`: exit status 0
- `tools/compare_tables.R /home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main/data/calibration_modern_lct_interp_bluesky.RDS .rundirs/cv-merge-feature/data/calibration_modern_lct_interp_bluesky.RDS`: exit status 0
- `tests/test_cross_validation.R`: exit status 0
- `tests/test_model_registry.R`: exit status 0
- `tests/test_training_support.R`: exit status 0
- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tools/cross_validate_albedo.R holdouts .rundirs/cv-merge-feature`: exit status 0
- `-e old = tools::md5sum(file.path('/home/expert/Documents/contracting/Andria/paleo-RF-verify/11356e0/.rundirs/cv-holdouts-7/output/cross_validation', c('feasibility.csv', 'directions.csv', 'target.csv', 'comparison.csv'))); new = tools::md5sum(file.path('.rundirs/cv-merge-feature/output/cross_validation', c('feasibility.csv', 'directions.csv', 'target.csv', 'comparison.csv'))); print(cbind(old, new)); stopifnot(identical(unname(old), unname(new)))`: exit status 0
- `tests/test_cross_validation_stages.R .rundirs/cv-merge-feature`: exit status 0

## Failures

- none
