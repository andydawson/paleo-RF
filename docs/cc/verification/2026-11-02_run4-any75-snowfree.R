# Refit run 4 (MODIS cells, snow-free days, any_75), 2 November 2026: the whole pipeline from the model fits of its month-split parts, as in run 1
# (run1-main). Same configuration and fixed seed 1549466984. No anchors: new results by design.
verify = '/home/expert/Documents/contracting/Andria/paleo-RF-verify'
parts  = c('0df176d/.rundirs/run4-any75-snowfree-fit-jan-apr-2',
           'f6ca119/.rundirs/run4-any75-snowfree-fit-may-aug',
           '54decc7/.rundirs/run4-any75-snowfree-fit-sep-dec-2')
fits = unlist(lapply(parts, function(p) {
  f = list.files(file.path(verify, p, 'output/calibration'), pattern = '\\.RDS$', full.names = TRUE)
  if (!length(f)) stop('no fits in ', p)
  f
}))
list(
  name     = 'run4-any75-snowfree',
  commit   = 'c2ccdb1',
  config   = 'config.R',
  settings = list(analysis = list(albedo = list(statistic = 'snow_free', version = 'any_75'), draws = list(seed = 1549466984))),
  copy     = lapply(fits, function(f) c(f, file.path('output/calibration', basename(f)))),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R', 'scripts/3_plot_cal_lct_albedo.R',
               'scripts/5_calibration_eval.R', 'scripts/6_prediction_model.R', 'scripts/7_plot_preds.R',
               'scripts/7a_alb_diff_full.R', 'scripts/8_radiative.R', 'scripts/9_forcing_barplot.R',
               'scripts/10_forcing_breakdown.R'),
  checks   = list('tests/test_config.R', 'tests/test_paths.R', 'tests/test_forcing_breakdown.R'),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '8', CORES = '0-7'))
