# Protocol 2 capacity comparison, may: fourteen fits; reuse the checked model-8 REML fit.
# Shared inputs and outputs are in .rundirs/cv2-holdouts at the same frozen commit.
list(
  name    = 'cv2-capacity-may',
  commit  = 'TO_FILL',
  config  = 'config.R',
  scripts = character(),
  checks  = list(c('tools/check_cv_separation.R', 'capacity', '.rundirs/cv2-holdouts', 'may')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1'))
