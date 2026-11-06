# Run only after selection has a winner other than model 8. If model 8 wins, reuse
# run1-main instead. Read the frozen score; the pipeline has no new switch or fit injection.
commit = 'TO_FILL'
checkout = normalizePath('.')
worktree = file.path(dirname(checkout), paste0(basename(checkout), '-verify'), substr(commit, 1, 7))
scores = utils::read.csv(file.path(worktree, '.rundirs/cv2-holdouts/output/cross_validation_v2/scores.csv'))
winner = scores$model[scores$chosen]
stopifnot(length(winner) == 1L)
if (winner == 'mod8') stop('model 8 won: reuse the completed run1-main pipeline; do not run this spec')
list(
  name     = 'cv2-winner',
  commit   = commit,
  config   = 'config.R',
  settings = list(analysis = list(calibration = list(model_id = winner),
                                  draws = list(seed = 1549466984))),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R',
               'scripts/3_plot_cal_lct_albedo.R', 'scripts/4_calibration_model.R',
               'scripts/5_calibration_eval.R', 'scripts/6_prediction_model.R',
               'scripts/7_plot_preds.R', 'scripts/7a_alb_diff_full.R',
               'scripts/8_radiative.R', 'scripts/9_forcing_barplot.R',
               'scripts/10_forcing_breakdown.R'),
  checks   = list('tests/test_config.R', 'tests/test_paths.R', 'tests/test_forcing_breakdown.R'),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1'))
