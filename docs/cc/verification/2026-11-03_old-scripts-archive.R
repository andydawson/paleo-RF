# The 18 scripts outside the pipeline moved to archive/ (issue #26, 3 November 2026): scripts 2 and 3 (3 sources
# scripts/make_grid.R, which stays) under the legacy configuration from the frozen modern land cover; the
# calibration table must match the anchor byte for byte; the config and path tests must pass.
list(
  name    = 'old-scripts-archive',
  commit  = '03f0cab',
  config  = 'configs/legacy_config.R',
  seed    = c('lct_modern'),
  scripts = c('scripts/2_calibration_lct_bluesky.R', 'scripts/3_plot_cal_lct_albedo.R'),
  checks  = list(c('tools/check_anchors.R', 'tests/anchors/interp-allmonths-2026-09-20', '.rundirs/old-scripts-archive'),
                 'tests/test_config.R', 'tests/test_paths.R'),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1'))
