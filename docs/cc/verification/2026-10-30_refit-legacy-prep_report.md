# Verification refit-legacy-prep: PASS

- verdict: **PASS**
- commit: 527ea1c9b4819cd82711e3a514c2a9304c8f3a56
- spec: `docs/cc/verification/2026-10-30_refit-legacy-prep.R`
- started 2026-10-30 17:17:36 UTC, finished 2026-10-30 17:21:59 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/527ea1c` at 527ea1c9b4819cd82711e3a514c2a9304c8f3a56; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/refit-legacy-prep`; configuration `.rundirs/refit-legacy-prep/config_used.R` (from `configs/legacy_config.R`); 0 files copied in
- runner `tools/rscript.sh` with THREADS=4 CORES=8-11

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261030T171756.252Z_2992778.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 2.7 min, run record `20261030T171817.767Z_2993520.md`, 2 outputs

## Anchors


## Checks

- `tools/check_anchors.R tests/anchors/interp-allmonths-2026-09-20 .rundirs/refit-legacy-prep`: exit status 0
- `tests/test_calendar.R`: exit status 0
- `tests/test_check_merge_evidence.R`: exit status 0
- `tests/test_check_model7_convergence.R`: exit status 0
- `tests/test_config.R`: exit status 0
- `tests/test_differences.R`: exit status 0
- `tests/test_model_registry.R`: exit status 0
- `tests/test_preparation.R`: exit status 0
- `tests/test_preparation_albedo.R`: exit status 0
- `tests/test_random.R`: exit status 0
- `tests/test_run_manifest.R`: exit status 0
- `tests/test_tools.R`: exit status 0
- `tests/test_verify_change.R`: exit status 0
- `tests/test_bluesky_albedo.R`: exit status 0

## Failures

- none
