# Northeast figure redrawn on the rebuilt MODIS albedo (Chris, 5 November 2026, for Andria): the figure script at the
# tip of feature/single-config, reading run 1's May fits (main run: MODIS cells, all days, full_75) and its predictions
# (read only). The October version was drawn from the 18 October run on Andria's raster.
verify = '/home/expert/Documents/contracting/Andria/paleo-RF-verify'
fits   = file.path(verify, 'be277d7/.rundirs/run1-main-fit-apr-jun/output/calibration')
run1   = file.path(verify, 'd5d5df5/.rundirs/run1-main')
list(
  name     = 'northeast-figure-run1',
  commit   = 'c86e4b5',
  config   = 'config.R',
  copy     = list(c(file.path(fits, 'calibration_prediction_fit_may_bluesky.RDS'),
                    'output/calibration/calibration_prediction_fit_may_bluesky.RDS'),
                  c(file.path(fits, 'calibration_mod_cover_elev_may.RDS'),
                    'output/calibration/calibration_mod_cover_elev_may.RDS'),
                  c(file.path(run1, 'output/prediction/paleo_interp_predict_gam_bluesky.RDS'),
                    'output/prediction/paleo_interp_predict_gam_bluesky.RDS')),
  scripts  = c('tools/plotting/plot_northeast_cover_and_location.R'),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1', CORES = '44-45'))
