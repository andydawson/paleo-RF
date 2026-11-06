# Protocol 2 recovery, apr, darkens: twenty frozen datasets, up to three distinct configurations.
# Shared inputs and outputs are in .rundirs/cv2-holdouts at the same frozen commit.
list(
  name    = 'cv2-recovery-apr-darkens',
  commit  = 'TO_FILL',
  config  = 'config.R',
  scripts = character(),
  checks  = list(c('tools/check_cv_separation.R', 'recovery', '.rundirs/cv2-holdouts', 'apr', 'darkens')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1'))
