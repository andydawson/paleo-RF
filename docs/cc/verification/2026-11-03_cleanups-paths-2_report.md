# Verification cleanups-paths-2: FAIL

- verdict: **FAIL**
- commit: 29d964c3ebf868d8d678939bb784b8c028ba2e0e
- spec: `docs/cc/verification/2026-11-03_cleanups-paths-2.R`
- started 2026-11-03 18:10:32 UTC, finished 2026-11-03 18:11:24 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/29d964c` at 29d964c3ebf868d8d678939bb784b8c028ba2e0e; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/cleanups-paths-2`; configuration `.rundirs/cleanups-paths-2/config_used.R` (from `config.R`); 0 files copied in
- runner `tools/rscript.sh` with THREADS=1

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261103T181049.279Z_68057.md`, 2 outputs

## Anchors


## Checks

- `tests/test_paths.R`: exit status 1
- `tests/test_verify_change.R`: not run (an earlier step failed)
- `tests/test_config.R`: not run (an earlier step failed)
- `tests/test_tools.R`: not run (an earlier step failed)

## Failures

- check failed: tests/test_paths.R (log: /home/expert/Documents/contracting/Andria/paleo-RF-verify/29d964c/.rundirs/cleanups-paths-2/checks.log)
