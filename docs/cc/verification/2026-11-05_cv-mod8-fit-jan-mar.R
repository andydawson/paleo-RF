# Cross-validation, protocol section 7 (5 November 2026): model fitting for jan-mar with model_id mod8, one of four
# month-split parts on code-identical commits of refit-runs; run 1's settings and seed otherwise. The rest of the
# pipeline runs once from these fits (cv-mod8).
list(
  name     = 'cv-mod8-fit-jan-mar',
  commit   = '073079d',
  config   = 'config.R',
  settings = list(analysis = list(months = c('jan','feb','mar'), draws = list(seed = 1549466984),
                                  calibration = list(model_id = 'mod8'))),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R', 'scripts/4_calibration_model.R'),
  checks   = list('tests/test_config.R'),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1'))
