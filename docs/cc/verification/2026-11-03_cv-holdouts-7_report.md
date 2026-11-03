# Verification cv-holdouts-7: PASS

- verdict: **PASS**
- commit: 11356e0bc474f9db8d92dbb8e555db40e9880eb8
- spec: `docs/cc/verification/2026-11-03_cv-holdouts-7.R`
- started 2026-11-03 20:53:06 UTC, finished 2026-11-03 21:00:26 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/11356e0` at 11356e0bc474f9db8d92dbb8e555db40e9880eb8; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/cv-holdouts-7`; configuration `.rundirs/cv-holdouts-7/config_used.R` (from `config.R`); 1 files copied in
- runner `tools/rscript.sh` with THREADS=1

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261103T205322.710Z_158302.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261103T205344.863Z_158635.md`, 1 outputs

## Anchors


## Checks

- `tools/compare_tables.R /home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main/data/calibration_modern_lct_interp_bluesky.RDS .rundirs/cv-holdouts-7/data/calibration_modern_lct_interp_bluesky.RDS`: exit status 0
- `tools/compare_tables.R /home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main/data/lct_paleo_reveals_interp.RDS .rundirs/cv-holdouts-7/data/lct_paleo_reveals_interp.RDS`: exit status 0
- `tests/test_cross_validation.R`: exit status 0
- `tests/test_model_registry.R`: exit status 0
- `tests/test_training_support.R`: exit status 0
- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tools/cross_validate_albedo.R holdouts .rundirs/cv-holdouts-7`: exit status 0

## Failures

- none
