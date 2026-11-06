# Protocol 2 selection; run only after all directional jobs have finished.
# Shared inputs and outputs are in .rundirs/cv2-holdouts at the same frozen commit.
list(
  name    = 'cv2-score',
  commit  = 'TO_FILL',
  config  = 'config.R',
  scripts = character(),
  checks  = list(c('tools/cross_validate_albedo.R', 'score', '.rundirs/cv2-holdouts')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1'))
