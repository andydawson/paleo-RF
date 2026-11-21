# Drift fixes: scripts 5 and 6 under the original configuration with seed 1 must reproduce the whole seed-1
# anchor; the spec both seeds and copies, so the new seeded-marker rules and the copy-loop line are exercised.
months = c('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec')
list(
  name    = 'drift-legacy-seed1',
  commit  = 'ac90729527f5965184c6e7abcaefab80129b86e5',
  config  = 'configs/legacy_config.R',
  seed    = c('calibration_table', 'calibration_ladder', 'calibration_spatial',
              'calibration_spatial_elev_cover', 'aic_table', 'lct_paleo'),
  copy    = lapply(months, function(m) c(sprintf('output/calibration/calibration_mod8_interp_%s_bluesky.RDS', m),
                                         sprintf('output/calibration/calibration_prediction_fit_%s_bluesky.RDS', m))),
  scripts = c('scripts/5_calibration_eval.R', 'scripts/6_prediction_model.R'),
  anchors = 'tests/anchors/interp-seed1-2026-10-14',
  checks  = list('tests/test_calendar.R', 'tests/test_check_merge_evidence.R', 'tests/test_check_model7_convergence.R',
                 'tests/test_config.R', 'tests/test_differences.R', 'tests/test_model_registry.R',
                 'tests/test_preparation.R', 'tests/test_preparation_albedo.R', 'tests/test_random.R',
                 'tests/test_run_manifest.R', 'tests/test_tools.R', 'tests/test_verify_change.R',
                 'tests/test_bluesky_albedo.R'),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '8', CORES = '16-23'))
