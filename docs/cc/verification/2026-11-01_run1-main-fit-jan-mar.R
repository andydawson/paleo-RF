# Refit run 1 (main: MODIS cells, all days, full_75), 1 November 2026: model fitting for jan-mar,
# one of four month-split parts run at once on code-identical commits of refit-runs (Chris: launch,
# fixed seed 1549466984). The rest of the pipeline runs once from these fits (run1-main).
list(
  name     = 'run1-main-fit-jan-mar',
  commit   = '5ddcb94',
  config   = 'config.R',
  settings = list(analysis = list(months = c('jan','feb','mar'), draws = list(seed = 1549466984))),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R', 'scripts/4_calibration_model.R'),
  checks   = list('tests/test_config.R', 'tests/test_paths.R'),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1', CORES = '0-7'))
