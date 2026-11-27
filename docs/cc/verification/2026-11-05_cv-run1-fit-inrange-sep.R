# Cross-validation (#24): the in-range holdout (skill inside the training range, reported only; protocol section 6),
# month sep, into .rundirs/cv-run1 after the score stage chose mod8_coarse_loc. Script 1 runs only because this
# version of the verification tool needs a script.
list(
  name    = 'cv-run1-fit-inrange-sep',
  commit  = 'f07ff68',
  config  = 'config.R',
  scripts = 'scripts/1_veg_lct_prep.R',
  checks  = list(c('tools/cross_validate_albedo.R', 'fit', '.rundirs/cv-run1', 'inrange', 'sep')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1'))
