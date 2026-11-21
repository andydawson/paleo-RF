# Documentation only (the writing-tool drafts under docs/cc/roles_draft/): the test suite on the commit.
list(
  name    = 'writing-tools',
  commit  = '1ea8de4f793995589c0bca784d2ce96093525880',
  config  = 'config.R',
  scripts = character(0),
  checks  = list('tests/test_config.R', 'tests/test_paths.R', 'tests/test_tools.R'),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '2', CORES = '20-21'))
