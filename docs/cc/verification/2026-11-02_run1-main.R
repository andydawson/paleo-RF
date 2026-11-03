# Refit run 1 (main: MODIS cells, all days, full_75), 1 November 2026: the whole pipeline from the model fits of the
# four month-split parts (run1-main-fit-*), as in the 18 October full run. Same configuration and fixed seed
# 1549466984 (Chris: launch). On the tip of refit-runs, whose commits after 837f2d3 are documentation only.
# No anchors: the MODIS calibration has new results by design.
verify = '/home/expert/Documents/contracting/Andria/paleo-RF-verify'
parts  = c('5ddcb94/.rundirs/run1-main-fit-jan-mar', 'be277d7/.rundirs/run1-main-fit-apr-jun',
           'f9f9e46/.rundirs/run1-main-fit-jul-sep', '8db4a5e/.rundirs/run1-main-fit-oct-dec')
fits = unlist(lapply(parts, function(p) {
  f = list.files(file.path(verify, p, 'output/calibration'), pattern = '\\.RDS$', full.names = TRUE)
  if (!length(f)) stop('no fits in ', p)
  f
}))
list(
  name     = 'run1-main',
  commit   = 'd5d5df5',
  config   = 'config.R',
  settings = list(analysis = list(draws = list(seed = 1549466984))),
  copy     = lapply(fits, function(f) c(f, file.path('output/calibration', basename(f)))),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R', 'scripts/3_plot_cal_lct_albedo.R',
               'scripts/5_calibration_eval.R', 'scripts/6_prediction_model.R', 'scripts/7_plot_preds.R',
               'scripts/7a_alb_diff_full.R', 'scripts/8_radiative.R', 'scripts/9_forcing_barplot.R',
               'scripts/10_forcing_breakdown.R'),
  checks   = list('tests/test_config.R', 'tests/test_paths.R', 'tests/test_forcing_breakdown.R'),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '8', CORES = '0-7'))
