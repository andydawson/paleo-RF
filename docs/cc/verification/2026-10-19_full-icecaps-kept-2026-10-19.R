# Effect of leaving today's ice caps out of the calibration (Chris, 19 October): the full run of
# 18 October (full-current-2026-10-18) repeated with the ice caps kept in (ice_mask = 'none', the
# original setting), same commit, same scripts, same raster; draws seeded with the 18 October
# script 6 base seed (1384237515). Fits come from the six fit-icecaps-kept-*-2026-10-19 parts.
# Correction (29 October, found by Fable's review of the refit plan): 1384237515 was the 18 October
# script 5 (evaluation) base seed; the 18 October script 6 (prediction) base seed was 1549466984. So
# the two runs' evaluation draws used the same seed but their prediction draws did not.
verify = '/home/expert/Documents/contracting/Andria/paleo-RF-verify'
parts  = c('4ba4d2a/.rundirs/fit-icecaps-kept-jan-feb-2026-10-19', 'f0be70e/.rundirs/fit-icecaps-kept-mar-apr-2026-10-19',
           'ce2577e/.rundirs/fit-icecaps-kept-may-jun-2026-10-19', '294e201/.rundirs/fit-icecaps-kept-jul-aug-2026-10-19',
           'a9dcdc2/.rundirs/fit-icecaps-kept-sep-oct-2026-10-19', '8e715d2/.rundirs/fit-icecaps-kept-nov-dec-2026-10-19')
fits = unlist(lapply(parts, function(p) {
  f = list.files(file.path(verify, p, 'output/calibration'), pattern = '\\.RDS$', full.names = TRUE)
  if (!length(f)) stop('no fits in ', p)
  f
}))
list(
  name     = 'full-icecaps-kept-2026-10-19',
  commit   = '4ba4d2a',
  config   = 'config.R',
  settings = list(analysis = list(calibration = list(ice_mask = 'none'),
                                  draws = list(seed = 1384237515))),
  copy     = lapply(fits, function(f) c(f, file.path('output/calibration', basename(f)))),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R', 'scripts/3_plot_cal_lct_albedo.R',
               'scripts/5_calibration_eval.R', 'scripts/6_prediction_model.R', 'scripts/7_plot_preds.R',
               'scripts/7a_alb_diff_full.R', 'scripts/8_radiative.R', 'scripts/9_forcing_barplot.R',
               'scripts/10_forcing_breakdown.R'),
  checks   = list('tests/test_config.R', 'tests/test_paths.R', 'tests/test_forcing_breakdown.R'),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '8', CORES = '0-11'))
