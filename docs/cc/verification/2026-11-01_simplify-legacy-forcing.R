# Simplifications (branch simplify-2026-11-01): the test files the other simplify specs did not run, notably
# test_paths.R, which checks the single catalogue expansion (catalogue_paths) that verify_change now uses; carried by
# scripts 9 and 10 under the original configuration, seeded, against the whole interp-forcing anchor.
list(
  name    = 'simplify-legacy-forcing',
  commit  = '51888b4742b949ec4a26f33f56643508a7e73b69',
  config  = 'configs/legacy_config.R',
  seed    = c('forcing', 'coarse_differences'),
  scripts = c('scripts/9_forcing_barplot.R', 'scripts/10_forcing_breakdown.R'),
  checks  = list(c('tools/check_anchors.R', 'tests/anchors/interp-forcing-2026-10-08', '.rundirs/simplify-legacy-forcing', '--all'),
                 'tests/test_paths.R', 'tests/test_check_comments_only.R'),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '8', CORES = '16-23'))
