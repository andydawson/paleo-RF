# Small cleanups of 3 November 2026: the archived model-structure script's four entries removed from the path
# catalogue (R/paths.R) and the test filter that skipped them. Tools and tests only: the tests that use the
# catalogue (paths, verification tool) and the config tests.
list(
  name    = 'cleanups-paths',
  commit  = '29d964c',
  config  = 'config.R',
  checks  = list('tests/test_paths.R', 'tests/test_verify_change.R', 'tests/test_config.R', 'tests/test_tools.R'),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1'))
