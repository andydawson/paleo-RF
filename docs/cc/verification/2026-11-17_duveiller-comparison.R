# The comparison of the cover-contrast exploration's all-days results with Duveiller et al. (2018):
# the duveiller command of tools/explore_cover_contrasts.R, its tests (in
# tests/test_explore_cover_contrasts.R) and its real-data check (tools/check_cover_contrasts.R
# duveiller). Design: docs/cc/2026-11-16_duveiller_comparison_design_codex_gpt6astra.md; Chris's
# decisions: docs/cc/2026-11-17_duveiller_comparison_decisions.md.
#
# The tests of the contrast spec of 15 November first. Then the full command, twelve months, on the
# saved all-days cases and fits of the exploration's full run of 16 November (72 saved fits, not
# refitted; about two minutes and 0.5 GB in the trial of 17 November), into a new folder inside
# this verification's own run folder, which the tool requires not to exist yet; then its check.
# The saved run and the published file are read only.
saved   = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/7c12534/.rundirs/cover-contrasts-full'
netcdf  = '/home/expert/Documents/contracting/Andria/paleo-RF/data/duveiller2018/albedo_IGBPdet.nc'   # MD5 96125db41154fa176c53b51596893ad6
out_dir = '.rundirs/duveiller-comparison/comparison'
list(
  name    = 'duveiller-comparison',
  commit  = 'TO_FILL',
  config  = 'config.R',
  scripts = character(),
  checks  = list('tests/test_cv_separation.R',
                 'tests/test_explore_cover_contrasts.R',
                 'tests/test_training_support.R',
                 'tests/test_calibration_fit.R',
                 'tests/test_model_registry.R',
                 'tests/test_cross_validation.R',
                 'tests/test_cross_validation_stages.R',
                 'tests/test_preparation_albedo.R',
                 'tests/test_config.R',
                 'tests/test_paths.R',
                 c('tools/explore_cover_contrasts.R', 'duveiller', saved, netcdf, out_dir),
                 c('tools/check_cover_contrasts.R', 'duveiller', out_dir, saved, netcdf)),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1'))
