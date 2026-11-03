# Verification old-scripts-archive: PASS

- verdict: **PASS**
- commit: 03f0cabf730b2a825fb3505f8fb46fb55db19667
- spec: `docs/cc/verification/2026-11-03_old-scripts-archive.R`
- started 2026-11-03 17:46:10 UTC, finished 2026-11-03 17:50:17 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/03f0cab` at 03f0cabf730b2a825fb3505f8fb46fb55db19667; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/old-scripts-archive`; configuration `.rundirs/old-scripts-archive/config_used.R` (from `configs/legacy_config.R`); 1 files copied in
- runner `tools/rscript.sh` with THREADS=1

## Scripts

- scripts/2_calibration_lct_bluesky.R: exit status 0, 2.8 min, run record `20261103T174627.082Z_30494.md`, 2 outputs
- scripts/3_plot_cal_lct_albedo.R: exit status 0, 0.8 min, run record `20261103T174912.687Z_37165.md`, 0 outputs

## Anchors


## Checks

- `tools/check_anchors.R tests/anchors/interp-allmonths-2026-09-20 .rundirs/old-scripts-archive`: exit status 0
- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0

## Failures

- none
