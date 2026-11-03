# Verification run8-raster: PASS

- verdict: **PASS**
- commit: 795792f9ec195895e3077ef9399ca4e93f75cc83
- spec: `docs/cc/verification/2026-11-02_run8-raster.R`
- started 2026-11-02 21:12:40 UTC, finished 2026-11-03 00:09:47 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/795792f` at 795792f9ec195895e3077ef9399ca4e93f75cc83; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/run8-raster`; configuration `.rundirs/run8-raster/config_used.R` (from `config.R`); 192 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=0-7

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261102T211259.741Z_213060.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 2.7 min, run record `20261102T211321.477Z_213147.md`, 2 outputs
- scripts/3_plot_cal_lct_albedo.R: exit status 0, 0.8 min, run record `20261102T211604.746Z_213684.md`, 0 outputs
- scripts/5_calibration_eval.R: exit status 0, 6.5 min, run record `20261102T211652.462Z_213911.md`, 13 outputs
- scripts/6_prediction_model.R: exit status 0, 12.1 min, run record `20261102T212325.935Z_214698.md`, 38 outputs
- scripts/7_plot_preds.R: exit status 0, 73.7 min, run record `20261102T213534.915Z_216172.md`, 4 outputs
- scripts/7a_alb_diff_full.R: exit status 0, 79.0 min, run record `20261102T224915.424Z_224808.md`, 1 outputs
- scripts/8_radiative.R: exit status 0, 0.4 min, run record `20261103T000814.041Z_234168.md`, 1 outputs
- scripts/9_forcing_barplot.R: exit status 0, 0.7 min, run record `20261103T000837.160Z_234375.md`, 4 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.3 min, run record `20261103T000916.923Z_234430.md`, 1 outputs

## Anchors


## Checks

- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tests/test_forcing_breakdown.R`: exit status 0

## Failures

- none
