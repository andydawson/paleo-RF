# Protocol 2 in-range diagnostic, oct, nov, dec: winner and model 8, deduplicated.
# Three months in one invocation; at most six fits, with monthly outputs unchanged.
# Shared inputs and outputs are in .rundirs/cv2-holdouts at the same frozen commit.
list(
  name    = 'cv2-fit-inrange-oct-dec',
  commit  = 'TO_FILL',
  config  = 'config.R',
  scripts = character(),
  checks  = list(c('tools/cross_validate_albedo.R', 'fit', '.rundirs/cv2-holdouts', 'inrange', 'oct', 'nov', 'dec')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1'))
