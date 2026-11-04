# I15c script 2 (after): script 2 under the legacy configuration from the frozen modern land cover.
list(
  name    = 'i15c-script2-after',
  commit  = 'a83d9d5e9cb9f4af4ac30b215f31c12a938fb0d1',
  config  = 'configs/legacy_config.R',
  seed    = c('lct_modern'),
  scripts = 'scripts/2_calibration_lct_bluesky.R',
  checks  = list(c('tools/check_anchors.R', 'tests/anchors/interp-allmonths-2026-09-20', '.rundirs/i15c-script2-after')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '8', CORES = '8-15'))
