# Protocol 2 in-range diagnostic, jul, aug, sep: winner and model 8, deduplicated.
# Three months in one invocation; at most six fits, with monthly outputs unchanged.
# Shared inputs and outputs are in .rundirs/cv2-holdouts at the same frozen commit.
list(
  name    = 'cv2-fit-inrange-jul-sep',
  commit  = '1d31cfcb2c63831d3eea81336739b9b7178807d7',
  config  = 'config.R',
  scripts = character(),
  checks  = list(c('tools/cross_validate_albedo.R', 'fit', '.rundirs/cv2-holdouts', 'inrange', 'jul', 'aug', 'sep')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1'))
