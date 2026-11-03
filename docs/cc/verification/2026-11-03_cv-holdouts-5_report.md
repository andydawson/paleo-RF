# Verification cv-holdouts-5: PASS

- verdict: **PASS**
- commit: 6841c484ceb4810621224896820290495dae92ca
- spec: `docs/cc/verification/2026-11-03_cv-holdouts-5.R`
- started 2026-11-03 18:27:40 UTC, finished 2026-11-03 18:34:48 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/6841c48` at 6841c484ceb4810621224896820290495dae92ca; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/cv-holdouts-5`; configuration `.rundirs/cv-holdouts-5/config_used.R` (from `config.R`); 1 files copied in
- runner `tools/rscript.sh` with THREADS=1

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261103T182756.588Z_76127.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261103T182819.235Z_76187.md`, 1 outputs

## Anchors


## Checks

- `tools/compare_tables.R /home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main/data/calibration_modern_lct_interp_bluesky.RDS .rundirs/cv-holdouts-5/data/calibration_modern_lct_interp_bluesky.RDS`: exit status 0
- `tools/compare_tables.R /home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main/data/lct_paleo_reveals_interp.RDS .rundirs/cv-holdouts-5/data/lct_paleo_reveals_interp.RDS`: exit status 0
- `tests/test_cross_validation.R`: exit status 0
- `tests/test_model_registry.R`: exit status 0
- `tests/test_training_support.R`: exit status 0
- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tools/cross_validate_albedo.R holdouts .rundirs/cv-holdouts-5`: exit status 0

## Failures

- none
