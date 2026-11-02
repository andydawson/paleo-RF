# Full run of the current configuration, 18 October 2026 (Chris: launch, use the whole workstation).
# Model fitting split by month across four code-identical commits so the four parts run at once
# (same-commit verifications share a worktree); this part fits 'apr', 'may', 'jun'. The rest of the pipeline then
# runs once, in full-current-2026-10-18, from these fits.
list(
  name     = 'fit-apr-jun-2026-10-18',
  commit   = 'f0be70e',
  config   = 'config.R',
  settings = list(analysis = list(months = c('apr', 'may', 'jun'))),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R', 'scripts/4_calibration_model.R'),
  checks   = list('tests/test_config.R', 'tests/test_paths.R'),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '8', CORES = '12-23'))
