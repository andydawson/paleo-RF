# Protocol 2 in-range diagnostic, sep: only the winner and model 8, deduplicated.
# Shared inputs and outputs are in .rundirs/cv2-holdouts at the same frozen commit.
list(
  name    = 'cv2-fit-inrange-sep',
  commit  = 'TO_FILL',
  config  = 'config.R',
  scripts = character(),
  checks  = list(c('tools/cross_validate_albedo.R', 'fit', '.rundirs/cv2-holdouts', 'inrange', 'sep')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1'))
