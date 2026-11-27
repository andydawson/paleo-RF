# Cross-validation, protocol section 7 (5 November 2026): model fitting for oct-dec with model_id mod8_coarse_loc, one of four
# month-split parts on code-identical commits of refit-runs; run 1's settings and seed otherwise. The rest of the
# pipeline runs once from these fits (cv-chosen).
list(
  name     = 'cv-chosen-fit-oct-dec',
  commit   = '1ade8d3',
  config   = 'config.R',
  settings = list(analysis = list(months = c('oct','nov','dec'), draws = list(seed = 1549466984),
                                  calibration = list(model_id = 'mod8_coarse_loc'))),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R', 'scripts/4_calibration_model.R'),
  checks   = list('tests/test_config.R'),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1'))
