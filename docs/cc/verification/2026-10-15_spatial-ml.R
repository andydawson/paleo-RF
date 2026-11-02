# Spatial experiments by the comparison method: the legacy path is the same calculation
# (method = "REML", the function's default); this spec runs the test suite on the commit.
# The ML fits are exercised by the full current-configuration run.
list(
  name    = 'spatial-ml',
  commit  = 'spatial-ml',
  config  = 'config.R',
  scripts = character(0),
  checks  = list('tests/test_config.R', 'tests/test_paths.R', 'tests/test_preparation.R', 'tests/test_run_manifest.R'),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '2', CORES = '20-21'))
