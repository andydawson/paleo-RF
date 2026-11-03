# Refit run 4 (MODIS cells, snow-free days, any_75), 2 November 2026: model fitting for may, jun, jul, aug, one of 3 month-split parts
# run at once on code-identical commits of refit-runs (code of 837f2d3). Fixed seed 1549466984 as every refit run.
# The rest of the pipeline runs once from these fits (run4-any75-snowfree).
list(
  name     = 'run4-any75-snowfree-fit-may-aug',
  commit   = 'f6ca119',
  config   = 'config.R',
  settings = list(analysis = list(months = c('may', 'jun', 'jul', 'aug'), albedo = list(statistic = 'snow_free', version = 'any_75'), draws = list(seed = 1549466984))),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R', 'scripts/4_calibration_model.R'),
  checks   = list('tests/test_config.R', 'tests/test_paths.R'),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1'))   # no core pinning: up to six jobs at once (Chris, 3 November)
