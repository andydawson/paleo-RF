# Protocol 2 capacity comparison, apr: fourteen fits; reuse the checked model-8 REML fit.
# Shared inputs and outputs are in .rundirs/cv2-holdouts at the same frozen commit.
list(
  name    = 'cv2-capacity-apr',
  commit  = '1d31cfcb2c63831d3eea81336739b9b7178807d7',
  config  = 'config.R',
  scripts = character(),
  checks  = list(c('tools/check_cv_separation.R', 'capacity', '.rundirs/cv2-holdouts', 'apr')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1'))
