# Protocol 2 hand-worked checks; no cross-validation or recovery fitting.
# Shared inputs and outputs are in .rundirs/cv2-holdouts at the same frozen commit.
list(
  name    = 'cv2-tests',
  commit  = 'TO_FILL',
  config  = 'config.R',
  scripts = character(),
  checks  = list('tests/test_model_registry.R',
                  'tests/test_calibration_fit.R',
                  'tests/test_cross_validation.R',
                  'tests/test_cross_validation_stages.R',
                  'tests/test_cv_separation.R',
                  'tests/test_training_support.R',
                  'tests/test_random.R',
                  'tests/test_differences.R',
                  'tests/test_forcing_periods.R',
                  'tests/test_forcing_breakdown.R',
                  'tests/test_config.R',
                  'tests/test_paths.R'),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1'))
