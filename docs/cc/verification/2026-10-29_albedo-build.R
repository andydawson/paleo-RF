# The rebuilt MODIS albedo tool (tools/prepare_bluesky_albedo.R) after taking in the latest
# migration branch (Chris, 29 October: verify properly instead of the 20 October exception).
# It is a stand-alone data-building tool that runs no pipeline script, so nothing is run as a
# script; the check is its test file, which works its arithmetic, land rule, climatology,
# request and checksum handling, and deletion safeguards by hand on made-up data.
list(
  name     = 'albedo-build',
  commit   = 'albedo-build',
  config   = 'config.R',
  settings = NULL,
  seed     = NULL,
  copy     = NULL,
  scripts  = character(0),
  anchors  = NULL,
  checks   = list(c('tests/test_bluesky_albedo.R')),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1'))
