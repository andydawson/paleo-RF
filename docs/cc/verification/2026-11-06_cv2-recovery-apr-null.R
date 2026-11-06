# Protocol 2 recovery, apr, null: twenty frozen datasets, up to three distinct configurations.
# Shared inputs and outputs are in .rundirs/cv2-holdouts at the same frozen commit.
list(
  name    = 'cv2-recovery-apr-null',
  commit  = 'TO_FILL',
  config  = 'config.R',
  scripts = character(),
  checks  = list(c('tools/check_cv_separation.R', 'recovery', '.rundirs/cv2-holdouts', 'apr', 'null')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1'))
