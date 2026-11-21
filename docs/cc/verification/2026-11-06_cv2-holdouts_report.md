# Verification cv2-holdouts: PASS

- verdict: **PASS**
- commit: 1d31cfcb2c63831d3eea81336739b9b7178807d7
- spec: `docs/cc/verification/2026-11-06_cv2-holdouts.R`
- started 2026-11-06 13:52:38 UTC, finished 2026-11-06 13:55:20 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc` at 1d31cfcb2c63831d3eea81336739b9b7178807d7; 0 frozen inputs linked from the main checkout
- run folder `.rundirs/cv2-holdouts`; configuration `.rundirs/cv2-holdouts/config_used.R` (from `config.R`); 1 files copied in
- runner `tools/rscript.sh` with THREADS=1 OPENBLAS_NUM_THREADS=1

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261106T135250.880Z_2388642.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261106T135312.423Z_2388719.md`, 1 outputs

## Anchors


## Checks

- `-e for (p in c('data/calibration_modern_lct_interp_bluesky.RDS', 'data/lct_paleo_reveals_interp.RDS')) stopifnot(identical(readRDS(file.path('/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main', p)), readRDS(file.path('.rundirs/cv2-holdouts', p))))`: exit status 0 (log `check_01.log`)
- `tools/cross_validate_albedo.R holdouts .rundirs/cv2-holdouts /home/expert/Documents/contracting/Andria/paleo-RF-verify/f07ff68/.rundirs/cv-run1`: exit status 0 (log `check_02.log`)
- `tools/check_cv_separation.R prepare .rundirs/cv2-holdouts /home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main`: exit status 0 (log `check_03.log`)

## Failures

- none
