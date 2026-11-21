# Second run, on 5bf769e: one ice fraction per past cell-slice (the first run, on b0cf6b1, passed but printed NA for the
# outside share: slices with a missing ice fraction lost all their target weight).
# Cross-validation, stage 1 (holdouts), 2 November 2026: the protocol approved by Chris
# (docs/cc/2026-11-02_cv_protocol.md) on the main refit's data (run 1, Chris's choice). Scripts 1-2 remake
# run 1's calibration table and past cover with run 1's settings on this branch's code; the checks show
# they match run 1's own tables, run the tests, and run the holdouts stage (no model is fitted). Script
# 7a's albedo differences (area and ice fraction of each cell) are copied from run 1.
run1 = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main'
list(
  name     = 'cv-holdouts-2',
  commit   = '5bf769e',
  config   = 'config.R',
  settings = list(analysis = list(draws = list(seed = 1549466984))),
  copy     = list(c(file.path(run1, 'data/ALB_diffs_bluesky.RDS'), 'data/ALB_diffs_bluesky.RDS')),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R'),
  checks   = list(c('tools/compare_tables.R', file.path(run1, 'data/calibration_modern_lct_interp_bluesky.RDS'),
                    '.rundirs/cv-holdouts-2/data/calibration_modern_lct_interp_bluesky.RDS'),
                  c('tools/compare_tables.R', file.path(run1, 'data/lct_paleo_reveals_interp.RDS'),
                    '.rundirs/cv-holdouts-2/data/lct_paleo_reveals_interp.RDS'),
                  'tests/test_cross_validation.R', 'tests/test_model_registry.R', 'tests/test_training_support.R',
                  'tests/test_config.R', 'tests/test_paths.R',
                  c('tools/cross_validate_albedo.R', 'holdouts', '.rundirs/cv-holdouts-2')),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1', CORES = '40-47'))
