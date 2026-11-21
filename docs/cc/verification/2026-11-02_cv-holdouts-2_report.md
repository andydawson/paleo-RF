# Verification cv-holdouts-2: PASS

- verdict: **PASS**
- commit: 5bf769e5567f582679eb7ffbbd3f40258d205437
- spec: `docs/cc/verification/2026-11-02_cv-holdouts-2.R`
- started 2026-11-02 20:39:46 UTC, finished 2026-11-02 20:46:13 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/5bf769e` at 5bf769e5567f582679eb7ffbbd3f40258d205437; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/cv-holdouts-2`; configuration `.rundirs/cv-holdouts-2/config_used.R` (from `config.R`); 1 files copied in
- runner `tools/rscript.sh` with THREADS=1 CORES=40-47

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261102T204002.942Z_183987.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261102T204024.988Z_184090.md`, 1 outputs

## Anchors


## Checks

- `tools/compare_tables.R /home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main/data/calibration_modern_lct_interp_bluesky.RDS .rundirs/cv-holdouts-2/data/calibration_modern_lct_interp_bluesky.RDS`: exit status 0
- `tools/compare_tables.R /home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main/data/lct_paleo_reveals_interp.RDS .rundirs/cv-holdouts-2/data/lct_paleo_reveals_interp.RDS`: exit status 0
- `tests/test_cross_validation.R`: exit status 0
- `tests/test_model_registry.R`: exit status 0
- `tests/test_training_support.R`: exit status 0
- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tools/cross_validate_albedo.R holdouts .rundirs/cv-holdouts-2`: exit status 0

## Failures

- none
