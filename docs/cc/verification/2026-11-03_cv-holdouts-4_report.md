# Verification cv-holdouts-4: PASS

- verdict: **PASS**
- commit: 25cde3a49d6ffe3434a4bf34e2026b138209b712
- spec: `docs/cc/verification/2026-11-03_cv-holdouts-4.R`
- started 2026-11-03 18:08:51 UTC, finished 2026-11-03 18:15:41 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/25cde3a` at 25cde3a49d6ffe3434a4bf34e2026b138209b712; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/cv-holdouts-4`; configuration `.rundirs/cv-holdouts-4/config_used.R` (from `config.R`); 1 files copied in
- runner `tools/rscript.sh` with THREADS=1

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261103T180908.149Z_66550.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261103T180930.402Z_66828.md`, 1 outputs

## Anchors


## Checks

- `tools/compare_tables.R /home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main/data/calibration_modern_lct_interp_bluesky.RDS .rundirs/cv-holdouts-4/data/calibration_modern_lct_interp_bluesky.RDS`: exit status 0
- `tools/compare_tables.R /home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main/data/lct_paleo_reveals_interp.RDS .rundirs/cv-holdouts-4/data/lct_paleo_reveals_interp.RDS`: exit status 0
- `tests/test_cross_validation.R`: exit status 0
- `tests/test_model_registry.R`: exit status 0
- `tests/test_training_support.R`: exit status 0
- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tools/cross_validate_albedo.R holdouts .rundirs/cv-holdouts-4`: exit status 0

## Failures

- none
