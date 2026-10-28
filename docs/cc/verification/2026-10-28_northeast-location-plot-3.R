# After the change-reviewer's fixes (Chris, 28 October): the northeast figure with the training-range test in its caption,
# and the pollen-coverage figure now using the shared regions of R/regions.R (its region table must match the 27 October
# run). Both on the 18 October full run's products.
run18 = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/4ba4d2a/.rundirs/full-current-2026-10-18'
list(
  name     = 'northeast-location-plot-3',
  commit   = 'northeast-location-plot',
  config   = 'config.R',
  settings = NULL,
  seed     = NULL,
  copy     = list(c(file.path(run18, 'output/calibration/calibration_prediction_fit_may_bluesky.RDS'),
                    'output/calibration/calibration_prediction_fit_may_bluesky.RDS'),
                  c(file.path(run18, 'output/calibration/calibration_mod_cover_elev_may.RDS'),
                    'output/calibration/calibration_mod_cover_elev_may.RDS'),
                  c(file.path(run18, 'output/prediction/paleo_interp_predict_gam_bluesky.RDS'),
                    'output/prediction/paleo_interp_predict_gam_bluesky.RDS')),
  scripts  = c('tools/plotting/plot_pollen_site_coverage.R',
               'tools/plotting/plot_northeast_cover_and_location.R'),
  anchors  = NULL,
  checks   = NULL,
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1'))
