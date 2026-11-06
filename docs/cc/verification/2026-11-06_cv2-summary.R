# Protocol 2 reports after capacity, recovery and in-range jobs; no new fits.
# Shared inputs and outputs are in .rundirs/cv2-holdouts at the same frozen commit.
list(
  name    = 'cv2-summary',
  commit  = 'TO_FILL',
  config  = 'config.R',
  scripts = character(),
  checks  = list(c('tools/cross_validate_albedo.R', 'score', '.rundirs/cv2-holdouts'),
                  c('tools/check_cv_separation.R', 'summarize', '.rundirs/cv2-holdouts')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1'))
