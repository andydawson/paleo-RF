# Drift fixes: the four diagnostic tools on the 18 October run's products (read only); their numbers must equal the
# 27-28 October logs, only titles and wording change.
run18 = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/4ba4d2a/.rundirs/full-current-2026-10-18'
list(
  name     = 'drift-diagnostics',
  commit   = 'drift-fixes',
  config   = 'config.R',
  copy     = list(c(file.path(run18, 'output/calibration/calibration_prediction_fit_may_bluesky.RDS'),
                    'output/calibration/calibration_prediction_fit_may_bluesky.RDS'),
                  c(file.path(run18, 'output/calibration/calibration_mod_cover_elev_may.RDS'),
                    'output/calibration/calibration_mod_cover_elev_may.RDS'),
                  c(file.path(run18, 'output/prediction/paleo_interp_predict_gam_bluesky.RDS'),
                    'output/prediction/paleo_interp_predict_gam_bluesky.RDS'),
                  c(file.path(run18, 'output/forcing/RF_holocene_all_cases.RDS'),
                    'output/forcing/RF_holocene_all_cases.RDS')),
  scripts  = c('tools/plotting/plot_pollen_site_coverage.R', 'tools/plotting/plot_training_support.R',
               'tools/plotting/plot_forcing_vs_training_support.R', 'tools/plotting/plot_northeast_cover_and_location.R'),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1'))
