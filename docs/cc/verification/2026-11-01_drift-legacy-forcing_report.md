# Verification drift-legacy-forcing: PASS

- verdict: **PASS**
- commit: ac90729527f5965184c6e7abcaefab80129b86e5
- spec: `docs/cc/verification/2026-11-01_drift-legacy-forcing.R`
- started 2026-11-01 13:43:27 UTC, finished 2026-11-01 13:45:42 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/ac90729` at ac90729527f5965184c6e7abcaefab80129b86e5; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/drift-legacy-forcing`; configuration `.rundirs/drift-legacy-forcing/config_used.R` (from `configs/legacy_config.R`); 2 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=16-23

## Scripts

- scripts/9_forcing_barplot.R: exit status 0, 0.6 min, run record `20261101T134343.924Z_3891429.md`, 4 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.3 min, run record `20261101T134419.130Z_3892191.md`, 1 outputs

## Anchors


## Checks

- `tools/check_anchors.R tests/anchors/interp-forcing-2026-10-08 .rundirs/drift-legacy-forcing --all`: exit status 0
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
- `tests/test_forcing_periods.R`: exit status 0
- `tests/test_training_support.R`: exit status 0
- `tests/test_forcing_breakdown.R`: exit status 0
- `tests/test_forcing_components.R`: exit status 0

## Failures

- none
