# Redundant reads removed: script 8 under the legacy configuration from the frozen differences.
list(
  name    = 'simplify-io-script8',
  commit  = 'dbff5bd917a823113e6856cdb44371eb4ea38534',
  config  = 'configs/legacy_config.R',
  seed    = c('albedo_differences'),
  scripts = 'scripts/8_radiative.R',
  checks  = list(c('tools/check_anchors.R', 'tests/anchors/interp-tail-2026-09-21', '.rundirs/simplify-io-script8')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '4', CORES = '16-19'))
