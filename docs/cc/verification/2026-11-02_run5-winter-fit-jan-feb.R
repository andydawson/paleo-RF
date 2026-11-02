# Refit run 5 (MODIS cells, all days, full_nocut, November-February; reported month by month only), 2 November 2026: model fitting for jan, feb, one of 2 month-split parts
# run at once on code-identical commits of refit-runs (code of 837f2d3). Fixed seed 1549466984 as every refit run.
# The rest of the pipeline runs once from these fits (run5-winter).
list(
  name     = 'run5-winter-fit-jan-feb',
  commit   = '9ea33e1',
  config   = 'config.R',
  settings = list(analysis = list(months = c('jan', 'feb'), albedo = list(version = 'full_nocut'), draws = list(seed = 1549466984))),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R', 'scripts/4_calibration_model.R'),
  checks   = list('tests/test_config.R', 'tests/test_paths.R'),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1', CORES = '8-15'))
