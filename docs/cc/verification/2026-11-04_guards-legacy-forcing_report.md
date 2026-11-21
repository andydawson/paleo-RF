# Verification guards-legacy-forcing: PASS

- verdict: **PASS**
- commit: 0b8c031b00639e2cb5640f88e103082280327430
- spec: `docs/cc/verification/2026-11-04_guards-legacy-forcing.R`
- started 2026-11-04 12:42:58 UTC, finished 2026-11-04 12:45:08 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/0b8c031` at 0b8c031b00639e2cb5640f88e103082280327430; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/guards-legacy-forcing`; configuration `.rundirs/guards-legacy-forcing/config_used.R` (from `configs/legacy_config.R`); 2 files copied in
- runner `tools/rscript.sh` with THREADS=1

## Scripts

- scripts/9_forcing_barplot.R: exit status 0, 0.6 min, run record `20261104T124312.844Z_3519073.md`, 4 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.3 min, run record `20261104T124347.600Z_3522035.md`, 1 outputs

## Anchors


## Checks

- `tools/check_anchors.R tests/anchors/interp-forcing-2026-10-08 .rundirs/guards-legacy-forcing --all`: exit status 0
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
