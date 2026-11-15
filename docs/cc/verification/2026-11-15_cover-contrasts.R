# The exploration of the fitted cover response: the exchange helpers for any two cover classes
# (R/cv_separation.R) and the new tool (tools/explore_cover_contrasts.R).
#
# Hand-worked tests first, then one small real job and its report: the snowy calibration table of
# the finished run of 4 November (read only, in its own verify worktree), July and August. Those
# months have 470 and 360 complete cells, so four of the six versions are fitted (the longest took
# 1.7 minutes in the trial of 15 November) and the two with a location term of 500 are reported as
# not fitted, which is the rule the job is meant to show working.
#
# This does not run the exploration itself (three tables, twelve months, six versions: up to 216
# fits, some of them long). That run needs Chris's go-ahead and its own specs.
list(
  name    = 'cover-contrasts',
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
                 c('tools/explore_cover_contrasts.R', 'fit', '../74b5482/.rundirs/run7-snowy',
                   '.rundirs/cover-contrasts/cover_contrasts', 'jul', 'aug'),
                 c('tools/explore_cover_contrasts.R', 'report', '.rundirs/cover-contrasts/cover_contrasts')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1'))
