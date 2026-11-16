# Verification cv2-summary: PASS

- verdict: **PASS**
- commit: 1d31cfcb2c63831d3eea81336739b9b7178807d7
- spec: `docs/cc/verification/2026-11-06_cv2-summary.R`
- started 2026-11-06 23:20:53 UTC, finished 2026-11-06 23:56:38 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc` at 1d31cfcb2c63831d3eea81336739b9b7178807d7; 0 frozen inputs linked from the main checkout
- run folder `.rundirs/cv2-summary`; configuration `.rundirs/cv2-summary/config_used.R` (from `config.R`); 0 files copied in
- runner `tools/rscript.sh` with THREADS=1 OPENBLAS_NUM_THREADS=1

## Scripts


## Anchors


## Checks

- `tools/cross_validate_albedo.R score .rundirs/cv2-holdouts`: exit status 0 (log `check_01.log`)
- `tools/check_cv_separation.R summarize .rundirs/cv2-holdouts`: exit status 0 (log `check_02.log`)

## Failures

- none
