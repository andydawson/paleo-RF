# Second run, after the twelve in-range fits passed (5 November), for the in-range report.
# Cross-validation (#24): the score stage on .rundirs/cv-run1, after all 36 fits passed (3 holdouts x 12 months, at
# f07ff68). Scores, their uncertainty and the choice of model, with the checks reported beside them (protocol,
# section 6). Script 1 runs only because this version of the verification tool needs a script.
list(
  name    = 'cv-run1-score-2',
  commit  = 'f07ff68',
  config  = 'config.R',
  scripts = 'scripts/1_veg_lct_prep.R',
  checks  = list(c('tools/cross_validate_albedo.R', 'score', '.rundirs/cv-run1')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1'))
