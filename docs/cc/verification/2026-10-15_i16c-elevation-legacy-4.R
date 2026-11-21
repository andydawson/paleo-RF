# I16c elevation (legacy): script 1 under the legacy configuration (centre-point elevation)
# must reproduce its anchors exactly; plus the path and config tests.
list(
  name    = 'i16c-elevation-legacy-4',
  commit  = '75945ee0258d3f60a5c896e5dd608f04897b3b51',
  config  = 'configs/legacy_config.R',
  scripts = 'scripts/1_veg_lct_prep.R',
  checks  = list(c('tools/check_anchors.R', 'tests/anchors/interp-allmonths-2026-09-20', '.rundirs/i16c-elevation-legacy-4'),
                 'tests/test_paths.R', 'tests/test_config.R'),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '4', CORES = '8-11'))
