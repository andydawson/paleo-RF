# Refit on the MODIS albedo (branch refit-modis): under the original configuration, scripts 1
# and 2 must reproduce their anchors byte for byte (script 2's raster path was restructured into
# if blocks); plus every test file that runs in a fresh worktree. The coarse table is compared
# with the frozen data/calibration_modern_lct_interp_bluesky_coarse.RDS by MD5 after the run.
list(
  name    = 'refit-legacy-prep',
  commit  = 'refit-modis',
  config  = 'configs/legacy_config.R',
  scripts = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R'),
  checks  = list(c('tools/check_anchors.R', 'tests/anchors/interp-allmonths-2026-09-20', '.rundirs/refit-legacy-prep'),
                 'tests/test_calendar.R', 'tests/test_check_merge_evidence.R', 'tests/test_check_model7_convergence.R',
                 'tests/test_config.R', 'tests/test_differences.R', 'tests/test_model_registry.R',
                 'tests/test_preparation.R', 'tests/test_preparation_albedo.R', 'tests/test_random.R',
                 'tests/test_run_manifest.R', 'tests/test_tools.R', 'tests/test_verify_change.R',
                 'tests/test_bluesky_albedo.R'),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '4', CORES = '8-11'))
