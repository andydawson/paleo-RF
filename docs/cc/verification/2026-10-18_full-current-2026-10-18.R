# Full run of the current configuration, 18 October 2026, with Andria's blue-sky raster (the
# MODIS rebuild is not ready). The model fits (script 4) come from the four month-split parts
# run at once on code-identical commits (fit-*-2026-10-18); everything else runs here, in order.
# No anchors: the current configuration has new results by design.
verify = '/home/expert/Documents/contracting/Andria/paleo-RF-verify'
parts  = c('4ba4d2a/.rundirs/fit-jan-mar-2026-10-18', 'f0be70e/.rundirs/fit-apr-jun-2026-10-18',
           'ce2577e/.rundirs/fit-jul-sep-2026-10-18', '294e201/.rundirs/fit-oct-dec-2026-10-18')
fits = unlist(lapply(parts, function(p) {
  f = list.files(file.path(verify, p, 'output/calibration'), pattern = '\\.RDS$', full.names = TRUE)
  if (!length(f)) stop('no fits in ', p)
  f
}))
list(
  name    = 'full-current-2026-10-18',
  commit  = '4ba4d2a',
  config  = 'config.R',
  copy    = lapply(fits, function(f) c(f, file.path('output/calibration', basename(f)))),
  scripts = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R', 'scripts/3_plot_cal_lct_albedo.R',
              'scripts/5_calibration_eval.R', 'scripts/6_prediction_model.R', 'scripts/7_plot_preds.R',
              'scripts/7a_alb_diff_full.R', 'scripts/8_radiative.R', 'scripts/9_forcing_barplot.R',
              'scripts/10_forcing_breakdown.R'),
  checks  = list('tests/test_config.R', 'tests/test_paths.R', 'tests/test_forcing_breakdown.R'),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '8', CORES = '0-11'))
