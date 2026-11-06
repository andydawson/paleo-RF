# Protocol 2: d1, apr; fifteen configurations if the frozen fold is feasible.
# Shared inputs and outputs are in .rundirs/cv2-holdouts at the same frozen commit.
list(
  name    = 'cv2-fit-d1-apr',
  commit  = 'TO_FILL',
  config  = 'config.R',
  scripts = character(),
  checks  = list(c('tools/cross_validate_albedo.R', 'fit', '.rundirs/cv2-holdouts', 'd1', 'apr')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1'))
