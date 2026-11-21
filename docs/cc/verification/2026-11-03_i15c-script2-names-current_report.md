# Verification i15c-script2-names-current: PASS

- verdict: **PASS**
- commit: c3ef429796de00fc01476ea03c5f3f866c5f1806
- spec: `docs/cc/verification/2026-11-03_i15c-script2-names-current.R`
- started 2026-11-03 15:58:59 UTC, finished 2026-11-03 16:00:54 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/c3ef429` at c3ef429796de00fc01476ea03c5f3f866c5f1806; 0 frozen inputs linked from the main checkout
- run folder `.rundirs/i15c-script2-names-current`; configuration `.rundirs/i15c-script2-names-current/config_used.R` (from `config.R`); 0 files copied in
- runner `tools/rscript.sh` with THREADS=1

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261103T155912.144Z_409111.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261103T155934.545Z_410255.md`, 1 outputs

## Anchors


## Checks

- `tools/compare_tables.R /home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main/data/calibration_modern_lct_interp_bluesky.RDS .rundirs/i15c-script2-names-current/data/calibration_modern_lct_interp_bluesky.RDS`: exit status 0

## Failures

- none
