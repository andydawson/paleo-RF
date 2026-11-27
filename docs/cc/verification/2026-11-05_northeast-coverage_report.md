# Verification northeast-coverage: PASS

- verdict: **PASS**
- commit: b215344e8b394a419e073e37801746880d6860b2
- spec: `docs/cc/verification/2026-11-05_northeast-coverage.R`
- started 2026-11-05 21:40:15 UTC, finished 2026-11-05 21:50:26 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/b215344` at b215344e8b394a419e073e37801746880d6860b2; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/northeast-coverage`; configuration `.rundirs/northeast-coverage/config_used.R` (from `config.R`); 0 files copied in
- runner `tools/rscript.sh` with THREADS=1 OPENBLAS_NUM_THREADS=1

## Scripts


## Anchors


## Checks

- `-e source('docs/cc/verification/2026-11-05_northeast-coverage.R'); coverage_parse()`: exit status 0
- `tests/test_modis_albedo_helpers.R`: exit status 0
- `tests/test_bluesky_albedo.R`: exit status 0
- `tests/test_northeast_forest_albedo.R`: exit status 0
- `tests/test_northeast_forest_coverage.R`: exit status 0
- `-e source('docs/cc/verification/2026-11-05_northeast-coverage.R'); coverage_inputs()`: exit status 0
- `tools/check_northeast_forest_albedo.R --config .rundirs/northeast-coverage/config_used.R`: exit status 0
- `-e source('docs/cc/verification/2026-11-05_northeast-coverage.R'); coverage_pairs()`: exit status 0
- `-e source('docs/cc/verification/2026-11-05_northeast-coverage.R'); coverage_losses()`: exit status 0
- `-e source('docs/cc/verification/2026-11-05_northeast-coverage.R'); coverage_structural()`: exit status 0
- `-e source('docs/cc/verification/2026-11-05_northeast-coverage.R'); coverage_counts()`: exit status 0
- `-e source('docs/cc/verification/2026-11-05_northeast-coverage.R'); coverage_manifest()`: exit status 0

## Failures

- none
