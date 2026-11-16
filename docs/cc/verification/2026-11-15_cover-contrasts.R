# The exploration of the fitted cover response: the exchange helpers for any two cover classes
# (R/cv_separation.R), the tool (tools/explore_cover_contrasts.R) and its real-data checks
# (tools/check_cover_contrasts.R).
#
# Launch from the main paleo-RF checkout, so that the worktree is paleo-RF-verify/<commit> and the
# finished runs below, in their own verify worktrees beside it, are found by relative paths. They
# are read only.
#
# Hand-worked tests first. Then, on real data: the three inputs are those traced in the
# implementation note; protocol 2's frozen exchanges are reproduced at this commit; one small job
# and its report, the snowy table's July and August (470 and 360 complete cells, so four of the
# six versions are fitted, the longest in about 2.4 minutes in the trials, and the two with a
# location term of 500 are reported as not fitted); and the job's output is checked: 12 fit
# records, 252 contrast rows, the support and a few numbers as known, and one saved fit that
# gives its numbers back.
#
# This does not run the exploration itself (three tables, twelve months, six versions: 216 fit
# records, 212 fits). That run needs Chris's go-ahead and its own specs.
all_days  = '../1d31cfc/.rundirs/cv2-holdouts'     # the protocol 2 run, 6 November
snow_free = '../8e3f3a4/.rundirs/run2-snowfree-2'  # 3 November
snowy     = '../74b5482/.rundirs/run7-snowy'       # 4 November
out_dir   = '.rundirs/cover-contrasts/cover_contrasts'
list(
  name    = 'cover-contrasts',
  commit  = '7c12534',
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
                 c('tools/check_cover_contrasts.R', 'inputs', all_days, snow_free, snowy),
                 c('tools/check_cover_contrasts.R', 'exchanges', all_days),
                 c('tools/explore_cover_contrasts.R', 'fit', snowy, out_dir, 'jul', 'aug'),
                 c('tools/explore_cover_contrasts.R', 'report', out_dir),
                 c('tools/check_cover_contrasts.R', 'job', out_dir)),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1'))
