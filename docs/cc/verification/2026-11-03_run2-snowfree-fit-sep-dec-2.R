# Rerun: the first attempt was killed one minute after starting, 3 November 07:59 UTC, when its queue runner was stopped; identical otherwise.
# Refit run 2 (MODIS cells, snow-free days, full_75), 2 November 2026: model fitting for sep, oct, nov, dec, one of 3 month-split parts
# run at once on code-identical commits of refit-runs (code of 837f2d3). Fixed seed 1549466984 as every refit run.
# The rest of the pipeline runs once from these fits (run2-snowfree).
list(
  name     = 'run2-snowfree-fit-sep-dec-2',
  commit   = 'e04de82',
  config   = 'config.R',
  settings = list(analysis = list(months = c('sep', 'oct', 'nov', 'dec'), albedo = list(statistic = 'snow_free'), draws = list(seed = 1549466984))),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R', 'scripts/4_calibration_model.R'),
  checks   = list('tests/test_config.R', 'tests/test_paths.R'),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1', CORES = '24-31'))
