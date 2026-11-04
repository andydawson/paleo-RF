# Second attempt: the first lacked the predictions, which the figure reads since the drift fixes.
# Northeast figure, neutral overall title (Chris, 1 November): the figure redrawn from the 18 October run's products
# (read only); its printed numbers must equal those of drift-diagnostics, only the title changes.
run18 = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/4ba4d2a/.rundirs/full-current-2026-10-18'
list(
  name     = 'northeast-title-2',
  commit   = '1ce2ca1693cba87522d247d223d81b0a50e2aace',
  config   = 'config.R',
  copy     = list(c(file.path(run18, 'output/calibration/calibration_prediction_fit_may_bluesky.RDS'),
                    'output/calibration/calibration_prediction_fit_may_bluesky.RDS'),
                  c(file.path(run18, 'output/calibration/calibration_mod_cover_elev_may.RDS'),
                    'output/calibration/calibration_mod_cover_elev_may.RDS'),
                  c(file.path(run18, 'output/prediction/paleo_interp_predict_gam_bluesky.RDS'),
                    'output/prediction/paleo_interp_predict_gam_bluesky.RDS')),
  scripts  = c('tools/plotting/plot_northeast_cover_and_location.R'),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1', CORES = '40-43'))
