# Final integration gate (issue #16), 1 of 3: the original analysis (configs/legacy_config.R) run from scratch,
# scripts 1 to 10 including script 4's full refit (the eight-model ladder, the seven spatial experiments and the
# selected model for each month), as the regression contract requires
# (docs/cc/2026-10-08_single_config_regression_contract.md, sections 2 and 5). Byte for byte: the land-cover and
# calibration tables, the AIC table and the point predictions (interp-allmonths-2026-09-20) and, with the legacy
# configuration's seed 1, every file of scripts 5 and 6 (interp-seed1-2026-10-14). Scripts 7 to 10 then run on this
# run's own seed-1 summary, which has no anchor (the tail anchors come from the unseeded summary: see 2 of 3).
# 8 threads, as the contract asks of comparison runs: January's refit was bit-identical at 8 threads (8 October).
list(
  name    = 'gate-legacy-full',
  commit  = '9c8dea142bf75db76cc841f0e857ada2baeb8672',
  config  = 'configs/legacy_config.R',
  scripts = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R', 'scripts/3_plot_cal_lct_albedo.R',
              'scripts/4_calibration_model.R', 'scripts/5_calibration_eval.R', 'scripts/6_prediction_model.R',
              'scripts/7_plot_preds.R', 'scripts/7a_alb_diff_full.R', 'scripts/8_radiative.R',
              'scripts/9_forcing_barplot.R', 'scripts/10_forcing_breakdown.R'),
  anchors = c('tests/anchors/interp-allmonths-2026-09-20', 'tests/anchors/interp-seed1-2026-10-14'),
  checks  = list('tests/test_config.R', 'tests/test_paths.R'),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '8', CORES = '8-15'))
