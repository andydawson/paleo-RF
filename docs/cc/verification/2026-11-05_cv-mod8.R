# Cross-validation, protocol section 7 (5 November 2026): scripts 1-3 and 5-10 with model_id mod8, from the four
# month-split parts' fits (cv-mod8-fit-*), as run 1. Compared with the other model's run for the hindcast and the northeast.
verify = '/home/expert/Documents/contracting/Andria/paleo-RF-verify'
parts  = c('073079d/.rundirs/cv-mod8-fit-jan-mar', 'ab454c4/.rundirs/cv-mod8-fit-apr-jun',
           'e89ffbe/.rundirs/cv-mod8-fit-jul-sep', '33aec25/.rundirs/cv-mod8-fit-oct-dec')
fits = unlist(lapply(parts, function(p) {
  f = list.files(file.path(verify, p, 'output/calibration'), pattern = '[.]RDS$', full.names = TRUE)
  if (!length(f)) stop('no fits in ', p)
  f
}))
list(
  name     = 'cv-mod8',
  commit   = 'f05628d',
  config   = 'config.R',
  settings = list(analysis = list(draws = list(seed = 1549466984), calibration = list(model_id = 'mod8'))),
  copy     = lapply(fits, function(f) c(f, file.path('output/calibration', basename(f)))),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R', 'scripts/3_plot_cal_lct_albedo.R',
               'scripts/5_calibration_eval.R', 'scripts/6_prediction_model.R', 'scripts/7_plot_preds.R',
               'scripts/7a_alb_diff_full.R', 'scripts/8_radiative.R', 'scripts/9_forcing_barplot.R',
               'scripts/10_forcing_breakdown.R'),
  checks   = list('tests/test_config.R', 'tests/test_forcing_breakdown.R'),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '8'))
