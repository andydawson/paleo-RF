# Drift fixes: scripts 1 and 2 under the original configuration must reproduce their anchors (script 1's printed
# diagnostic claim removed; run-directory and seeded-marker plumbing changed).
list(
  name    = 'drift-legacy-prep',
  commit  = 'ac90729527f5965184c6e7abcaefab80129b86e5',
  config  = 'configs/legacy_config.R',
  scripts = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R'),
  checks  = list(c('tools/check_anchors.R', 'tests/anchors/interp-allmonths-2026-09-20', '.rundirs/drift-legacy-prep')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '8', CORES = '16-23'))
