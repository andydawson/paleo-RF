# Verification simplify-legacy-forcing: PASS

- verdict: **PASS**
- commit: 51888b4742b949ec4a26f33f56643508a7e73b69
- spec: `docs/cc/verification/2026-11-01_simplify-legacy-forcing.R`
- started 2026-11-01 16:52:51 UTC, finished 2026-11-01 16:54:06 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/51888b4` at 51888b4742b949ec4a26f33f56643508a7e73b69; 0 frozen inputs linked from the main checkout
- run folder `.rundirs/simplify-legacy-forcing`; configuration `.rundirs/simplify-legacy-forcing/config_used.R` (from `configs/legacy_config.R`); 2 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=16-23

## Scripts

- scripts/9_forcing_barplot.R: exit status 0, 0.6 min, run record `20261101T165303.873Z_3965912.md`, 4 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.3 min, run record `20261101T165337.730Z_3966095.md`, 1 outputs

## Anchors


## Checks

- `tools/check_anchors.R tests/anchors/interp-forcing-2026-10-08 .rundirs/simplify-legacy-forcing --all`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tests/test_check_comments_only.R`: exit status 0

## Failures

- none
