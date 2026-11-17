# The combined code after merging the cover-contrast tool onto the trunk (16 November 2026), which already
# holds the cross-validation (merged at 326ea11) and the hindcast comparison tool (merged at c254734). The
# merge check needs a PASS report on this combined code. It runs every check of the two tools' own specs,
# unchanged (each verified on its own branch: 7c12534 and 6faebe3), with the shared tests run once.
here = '/home/expert/Documents/contracting/Andria/paleo-RF-wt/merge-contrasts/docs/cc/verification'
spec = function(file) source(file.path(here, file), local = new.env())$value
checks = c(spec('2026-11-15_cover-contrasts.R')$checks, spec('2026-11-10_cv-hindcast-comparison.R')$checks)
list(
  name    = 'merge-cover-contrasts',
  commit  = '1ae8eccc419b8ee918a45c73779fda751ff170c4',
  config  = 'config.R',
  scripts = character(),
  checks  = checks[!duplicated(checks)],
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1'))
