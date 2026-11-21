# Effect of leaving today's ice caps out of the calibration (Chris, 19 October): the full run of
# 18 October repeated with the ice caps kept in (analysis$calibration$ice_mask = 'none', the
# original setting), everything else the same, and script 6's draws seeded with the base seed the
# 18 October run recorded (1384237515), so the prediction draws share their random numbers.
# Model fitting split by month across six code-identical commits so the parts run at once;
# this part fits mar-apr. The rest runs once, in full-icecaps-kept-2026-10-19.
list(
  name     = 'fit-icecaps-kept-mar-apr-2026-10-19',
  commit   = 'f0be70e',
  config   = 'config.R',
  settings = list(analysis = list(months = c('mar','apr'),
                                  calibration = list(ice_mask = 'none'),
                                  draws = list(seed = 1384237515))),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R', 'scripts/4_calibration_model.R'),
  checks   = list('tests/test_config.R', 'tests/test_paths.R'),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '8', CORES = '8-15'))
