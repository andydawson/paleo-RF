# Refit run 3 (MODIS cells, all days, any_75), 2 November 2026: model fitting for jan, feb, mar, apr, one of 3 month-split parts
# run at once on code-identical commits of refit-runs (code of 837f2d3). Fixed seed 1549466984 as every refit run.
# The rest of the pipeline runs once from these fits (run3-any75).
list(
  name     = 'run3-any75-fit-jan-apr',
  commit   = '014e8a3',
  config   = 'config.R',
  settings = list(analysis = list(months = c('jan', 'feb', 'mar', 'apr'), albedo = list(version = 'any_75'), draws = list(seed = 1549466984))),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R', 'scripts/4_calibration_model.R'),
  checks   = list('tests/test_config.R', 'tests/test_paths.R'),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1', CORES = '8-15'))
