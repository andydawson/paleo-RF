# Ice maps (branch ice-maps): the comment-only follow-ups after the PASS at 4e8532c (Fable's review, approved by
# Chris on 20 November 2026). A repeated comment line deleted in scripts/7_plot_preds.R, and two outdated comments
# reworded in R/paths.R and tools/build_nadi1_fractions.R. No script runs: every R file under R/, scripts/,
# config.R and configs/ must parse to the same code as at 4e8532c, and the NADI-1 build tool, which
# check_comments_only.R does not cover, is checked by its test, which sources it.
list(
  name    = 'ice-maps-comments',
  commit  = 'bd2ca6c01dd368f89334c2b52e0ecd3255da7801',
  config  = 'config.R',
  scripts = character(0),
  checks  = list(c('tools/check_comments_only.R', '4e8532c91893c496ea5d0633c169b899ceeac7b4'),
                 'tests/test_build_nadi1_fractions.R', 'tests/test_paths.R', 'tests/test_check_comments_only.R'),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1'))
