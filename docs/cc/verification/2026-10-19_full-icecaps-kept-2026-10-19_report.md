# Verification full-icecaps-kept-2026-10-19: PASS

- verdict: **PASS**
- commit: 4ba4d2a62cc8aeb547a9c77f73bf11b744568a99
- spec: `/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/icecaps/full-icecaps-kept-2026-10-19.R`
- started 2026-10-19 16:10:41 UTC, finished 2026-10-19 19:05:35 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/4ba4d2a` at 4ba4d2a62cc8aeb547a9c77f73bf11b744568a99; 0 frozen inputs linked from the main checkout
- run folder `.rundirs/full-icecaps-kept-2026-10-19`; configuration `.rundirs/full-icecaps-kept-2026-10-19/config_used.R` (from `config.R`); 192 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=0-11

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261019T161056.178Z_2420065.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 2.7 min, run record `20261019T161118.049Z_2420214.md`, 2 outputs
- scripts/3_plot_cal_lct_albedo.R: exit status 0, 0.8 min, run record `20261019T161359.275Z_2421285.md`, 0 outputs
- scripts/5_calibration_eval.R: exit status 0, 6.8 min, run record `20261019T161446.107Z_2421475.md`, 13 outputs
- scripts/6_prediction_model.R: exit status 0, 11.9 min, run record `20261019T162134.439Z_2422754.md`, 38 outputs
- scripts/7_plot_preds.R: exit status 0, 72.6 min, run record `20261019T163335.043Z_2426847.md`, 4 outputs
- scripts/7a_alb_diff_full.R: exit status 0, 78.0 min, run record `20261019T174612.517Z_2440599.md`, 1 outputs
- scripts/8_radiative.R: exit status 0, 0.4 min, run record `20261019T190410.218Z_2453489.md`, 1 outputs
- scripts/9_forcing_barplot.R: exit status 0, 0.6 min, run record `20261019T190432.571Z_2453588.md`, 4 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.3 min, run record `20261019T190506.301Z_2453732.md`, 1 outputs

## Anchors


## Checks

- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tests/test_forcing_breakdown.R`: exit status 0

## Failures

- none
