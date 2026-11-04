# Cross-validation fits (#24): holdout d2, month nov, the 13 candidates, into the cross-validation run folder
# .rundirs/cv-run1 (holdouts made at the same commit, f07ff68; spec 2026-11-04_cv-run1.R). Script 1 runs only because
# this version of the verification tool needs a script; its products in this spec's own folder are not used.
list(
  name    = 'cv-run1-fit-d2-nov',
  commit  = 'f07ff68',
  config  = 'config.R',
  scripts = 'scripts/1_veg_lct_prep.R',
  checks  = list(c('tools/cross_validate_albedo.R', 'fit', '.rundirs/cv-run1', 'd2', 'nov')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1'))
