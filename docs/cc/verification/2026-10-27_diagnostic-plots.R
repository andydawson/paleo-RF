# Diagnostic plots (tools/plotting/): the three figures for Andria must run to completion on
# the 18 October full run's products (the run they were first drawn from, 20 October).
run18 = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/4ba4d2a/.rundirs/full-current-2026-10-18'
list(
  name     = 'diagnostic-plots',
  commit   = 'diagnostic-plots',
  config   = 'config.R',
  settings = NULL,
  seed     = NULL,
  copy     = list(c(file.path(run18, 'output/calibration/calibration_prediction_fit_may_bluesky.RDS'),
                    'output/calibration/calibration_prediction_fit_may_bluesky.RDS'),
                  c(file.path(run18, 'output/prediction/paleo_interp_predict_gam_bluesky.RDS'),
                    'output/prediction/paleo_interp_predict_gam_bluesky.RDS'),
                  c(file.path(run18, 'output/forcing/RF_holocene_all_cases.RDS'),
                    'output/forcing/RF_holocene_all_cases.RDS')),
  scripts  = c('tools/plotting/plot_pollen_site_coverage.R',
               'tools/plotting/plot_training_support.R',
               'tools/plotting/plot_forcing_vs_training_support.R'),
  anchors  = NULL,
  checks   = NULL,
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1'))
