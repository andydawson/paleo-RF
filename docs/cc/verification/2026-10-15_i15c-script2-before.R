# I15c script 2 (before): script 2 under the legacy configuration from the frozen modern land cover.
list(
  name    = 'i15c-script2-before',
  commit  = '2138f8f22404dd8c04d222e1fe3ff9bc6f89e00d',
  config  = 'configs/legacy_config.R',
  seed    = c('lct_modern'),
  scripts = 'scripts/2_calibration_lct_bluesky.R',
  checks  = list(c('tools/check_anchors.R', 'tests/anchors/interp-allmonths-2026-09-20', '.rundirs/i15c-script2-before')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '8', CORES = '8-15'))
