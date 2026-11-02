# Verification cv-holdouts: PASS

- verdict: **PASS**
- commit: b0cf6b1340ede7707dc35e5232ea79558f2451c6
- spec: `docs/cc/verification/2026-11-02_cv-holdouts.R`
- started 2026-11-02 20:27:05 UTC, finished 2026-11-02 20:33:34 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/b0cf6b1` at b0cf6b1340ede7707dc35e5232ea79558f2451c6; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/cv-holdouts`; configuration `.rundirs/cv-holdouts/config_used.R` (from `config.R`); 1 files copied in
- runner `tools/rscript.sh` with THREADS=1 CORES=40-47

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261102T202720.834Z_177182.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261102T202743.553Z_177884.md`, 1 outputs

## Anchors


## Checks

- `tools/compare_tables.R /home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main/data/calibration_modern_lct_interp_bluesky.RDS .rundirs/cv-holdouts/data/calibration_modern_lct_interp_bluesky.RDS`: exit status 0
- `tools/compare_tables.R /home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main/data/lct_paleo_reveals_interp.RDS .rundirs/cv-holdouts/data/lct_paleo_reveals_interp.RDS`: exit status 0
- `tests/test_cross_validation.R`: exit status 0
- `tests/test_model_registry.R`: exit status 0
- `tests/test_training_support.R`: exit status 0
- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tools/cross_validate_albedo.R holdouts .rundirs/cv-holdouts`: exit status 0

## Failures

- none
