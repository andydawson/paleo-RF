# Refit run 1 (main: MODIS cells, all days, full_75), 1 November 2026: model fitting for jul-sep,
# one of four month-split parts run at once on code-identical commits of refit-runs (Chris: launch,
# fixed seed 1549466984). The rest of the pipeline runs once from these fits (run1-main).
list(
  name     = 'run1-main-fit-jul-sep',
  commit   = 'f9f9e46',
  config   = 'config.R',
  settings = list(analysis = list(months = c('jul','aug','sep'), draws = list(seed = 1549466984))),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R', 'scripts/4_calibration_model.R'),
  checks   = list('tests/test_config.R', 'tests/test_paths.R'),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1', CORES = '16-23'))
