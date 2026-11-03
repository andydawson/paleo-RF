# Sixth run, on 44d0605: the by-region report and its test added (the holdouts stage is unchanged: it must give cv-holdouts-5's tables).
# Third run, on 8b85be9: the fixes both code reviews agreed and Chris's decisions of 3 November (target 27-74 N, cut rule,
# own-departure grouping).
# Cross-validation, stage 1 (holdouts), 2 November 2026: the protocol approved by Chris
# (docs/cc/2026-11-02_cv_protocol.md) on the main refit's data (run 1, Chris's choice). Scripts 1-2 remake
# run 1's calibration table and past cover with run 1's settings on this branch's code; the checks show
# they match run 1's own tables, run the tests, and run the holdouts stage (no model is fitted). Script
# 7a's albedo differences (area and ice fraction of each cell) are copied from run 1.
run1 = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main'
list(
  name     = 'cv-holdouts-6',
  commit   = '44d0605',
  config   = 'config.R',
  settings = list(analysis = list(draws = list(seed = 1549466984))),
  copy     = list(c(file.path(run1, 'data/ALB_diffs_bluesky.RDS'), 'data/ALB_diffs_bluesky.RDS')),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R'),
  checks   = list(c('tools/compare_tables.R', file.path(run1, 'data/calibration_modern_lct_interp_bluesky.RDS'),
                    '.rundirs/cv-holdouts-6/data/calibration_modern_lct_interp_bluesky.RDS'),
                  c('tools/compare_tables.R', file.path(run1, 'data/lct_paleo_reveals_interp.RDS'),
                    '.rundirs/cv-holdouts-6/data/lct_paleo_reveals_interp.RDS'),
                  'tests/test_cross_validation.R', 'tests/test_model_registry.R', 'tests/test_training_support.R',
                  'tests/test_config.R', 'tests/test_paths.R',
                  c('tools/cross_validate_albedo.R', 'holdouts', '.rundirs/cv-holdouts-6')),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1'))
