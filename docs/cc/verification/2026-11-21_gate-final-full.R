# Final integration gate (issue #16), 3 of 3: the final configuration (config.R as it stands) run from scratch,
# scripts 1 to 10, with test files as checks. No anchor exists for this configuration: the run shows that the whole
# pipeline runs end to end on the final code and records every setting in its run manifests. Commit d0ed354 (the
# tip of the last merged branch) has code identical to 9c8dea1 (1 of 3), so the runs can go side by side.
list(
  name    = 'gate-final-full',
  commit  = 'd0ed3544701c8b50462322e43d954b6560dce09e',
  config  = 'config.R',
  scripts = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R', 'scripts/3_plot_cal_lct_albedo.R',
              'scripts/4_calibration_model.R', 'scripts/5_calibration_eval.R', 'scripts/6_prediction_model.R',
              'scripts/7_plot_preds.R', 'scripts/7a_alb_diff_full.R', 'scripts/8_radiative.R',
              'scripts/9_forcing_barplot.R', 'scripts/10_forcing_breakdown.R'),
  checks  = list('tests/test_config.R', 'tests/test_paths.R', 'tests/test_forcing_breakdown.R'),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '8', CORES = '24-31'))
