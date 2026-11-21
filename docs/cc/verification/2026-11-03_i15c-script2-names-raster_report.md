# Verification i15c-script2-names-raster: PASS

- verdict: **PASS**
- commit: c3ef429796de00fc01476ea03c5f3f866c5f1806
- spec: `docs/cc/verification/2026-11-03_i15c-script2-names-raster.R`
- started 2026-11-03 16:00:54 UTC, finished 2026-11-03 16:04:31 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/c3ef429` at c3ef429796de00fc01476ea03c5f3f866c5f1806; 0 frozen inputs linked from the main checkout
- run folder `.rundirs/i15c-script2-names-raster`; configuration `.rundirs/i15c-script2-names-raster/config_used.R` (from `config.R`); 0 files copied in
- runner `tools/rscript.sh` with THREADS=1

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261103T160107.355Z_411288.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 2.8 min, run record `20261103T160129.174Z_411470.md`, 2 outputs

## Anchors


## Checks

- `tools/compare_tables.R /home/expert/Documents/contracting/Andria/paleo-RF-verify/b689642/.rundirs/run8-raster-fit-jan-apr-2/data/calibration_modern_lct_interp_bluesky.RDS .rundirs/i15c-script2-names-raster/data/calibration_modern_lct_interp_bluesky.RDS`: exit status 0
- `tools/compare_tables.R /home/expert/Documents/contracting/Andria/paleo-RF-verify/b689642/.rundirs/run8-raster-fit-jan-apr-2/data/calibration_modern_lct_interp_bluesky_coarse.RDS .rundirs/i15c-script2-names-raster/data/calibration_modern_lct_interp_bluesky_coarse.RDS`: exit status 0

## Failures

- none
