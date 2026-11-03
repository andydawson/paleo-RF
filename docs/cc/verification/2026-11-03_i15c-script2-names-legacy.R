# I15c script 2, the last renames (bs_interp_df -> albedo_by_cell, bs_interp_df_coarse -> albedo_coarse_by_cell),
# 3 November 2026, issue #18: script 2 under the legacy configuration (Andria's raster) from the frozen modern
# land cover; the calibration table must match the anchor byte for byte, as before the rename.
list(
  name    = 'i15c-script2-names-legacy',
  commit  = 'c3ef429',
  config  = 'configs/legacy_config.R',
  seed    = c('lct_modern'),
  scripts = 'scripts/2_calibration_lct_bluesky.R',
  checks  = list(c('tools/check_anchors.R', 'tests/anchors/interp-allmonths-2026-09-20', '.rundirs/i15c-script2-names-legacy')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1'))
