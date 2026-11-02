# Refit run 7 (MODIS cells, snowy days, full_75, every month but July and August: Chris, 1 November), 2 November 2026: model fitting for jan, feb, mar, apr, one of 3 month-split parts
# run at once on code-identical commits of refit-runs (code of 837f2d3). Fixed seed 1549466984 as every refit run.
# The rest of the pipeline runs once from these fits (run7-snowy).
list(
  name     = 'run7-snowy-fit-jan-apr',
  commit   = '7e6f30c',
  config   = 'config.R',
  settings = list(analysis = list(months = c('jan', 'feb', 'mar', 'apr'), albedo = list(statistic = 'snowy'), draws = list(seed = 1549466984))),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R', 'scripts/4_calibration_model.R'),
  checks   = list('tests/test_config.R', 'tests/test_paths.R'),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1', CORES = '8-15'))
