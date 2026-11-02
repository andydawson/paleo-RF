# Verification full-current-2026-10-18: PASS

- verdict: **PASS**
- commit: 4ba4d2a62cc8aeb547a9c77f73bf11b744568a99
- spec: `/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/fullrun/full-current-2026-10-18.R`
- started 2026-10-18 13:47:08 UTC, finished 2026-10-18 16:39:52 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/4ba4d2a` at 4ba4d2a62cc8aeb547a9c77f73bf11b744568a99; 0 frozen inputs linked from the main checkout
- run folder `.rundirs/full-current-2026-10-18`; configuration `.rundirs/full-current-2026-10-18/config_used.R` (from `config.R`); 192 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=0-11

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261018T134723.254Z_1988748.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 2.6 min, run record `20261018T134744.801Z_1988871.md`, 2 outputs
- scripts/3_plot_cal_lct_albedo.R: exit status 0, 0.8 min, run record `20261018T135022.539Z_1989516.md`, 0 outputs
- scripts/5_calibration_eval.R: exit status 0, 6.5 min, run record `20261018T135108.523Z_1989656.md`, 13 outputs
- scripts/6_prediction_model.R: exit status 0, 11.7 min, run record `20261018T135738.061Z_1991121.md`, 38 outputs
- scripts/7_plot_preds.R: exit status 0, 71.6 min, run record `20261018T140920.990Z_1993702.md`, 4 outputs
- scripts/7a_alb_diff_full.R: exit status 0, 77.5 min, run record `20261018T152056.457Z_2007647.md`, 1 outputs
- scripts/8_radiative.R: exit status 0, 0.4 min, run record `20261018T163827.423Z_2024491.md`, 1 outputs
- scripts/9_forcing_barplot.R: exit status 0, 0.6 min, run record `20261018T163849.765Z_2024575.md`, 4 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.3 min, run record `20261018T163922.801Z_2024690.md`, 1 outputs

## Anchors


## Checks

- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tests/test_forcing_breakdown.R`: exit status 0

## Failures

- none
