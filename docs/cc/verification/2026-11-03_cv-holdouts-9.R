# Ninth run, on b7a5772: the geographic sensitivity reports (decision 15). The holdouts stage adds inrange.csv and keeps its
# other four tables, which must be byte-identical to cv-holdouts-7's (the last check, in this report).
run1 = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main'
previous = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/11356e0/.rundirs/cv-holdouts-7/output/cross_validation'
tables = c('feasibility.csv', 'directions.csv', 'target.csv', 'comparison.csv')
same = sprintf("old = tools::md5sum(file.path('%s', c(%s))); new = tools::md5sum(file.path('.rundirs/cv-holdouts-9/output/cross_validation', c(%s))); print(cbind(old, new)); stopifnot(identical(unname(old), unname(new)))",
               previous, paste0("'", tables, "'", collapse = ', '), paste0("'", tables, "'", collapse = ', '))
list(
  name     = 'cv-holdouts-9',
  commit   = 'b7a5772',
  config   = 'config.R',
  settings = list(analysis = list(draws = list(seed = 1549466984))),
  copy     = list(c(file.path(run1, 'data/ALB_diffs_bluesky.RDS'), 'data/ALB_diffs_bluesky.RDS')),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R'),
  checks   = list(c('tools/compare_tables.R', file.path(run1, 'data/calibration_modern_lct_interp_bluesky.RDS'),
                    '.rundirs/cv-holdouts-9/data/calibration_modern_lct_interp_bluesky.RDS'),
                  'tests/test_cross_validation.R', 'tests/test_model_registry.R', 'tests/test_training_support.R',
                  'tests/test_config.R', 'tests/test_paths.R',
                  c('tools/cross_validate_albedo.R', 'holdouts', '.rundirs/cv-holdouts-9'),
                  c('-e', same)),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1'))
