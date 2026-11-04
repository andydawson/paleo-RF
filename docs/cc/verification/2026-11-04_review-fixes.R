# Whole-code review of 4 November, findings 6, 7, 11 and 12 (Chris chose all four): plots go to the run folder's
# Rplots.pdf in batch runs only; plain loops in the CV band comparison and one complete-row check; docs. Scripts 1-3
# (script 3 prints plots with no device open, so its Rplots.pdf must land in the run folder); the cross-validation's
# holdouts stage, its tables byte-identical to cv-holdouts-7's, and the stages test (which scores with a stand-in fit).
run1 = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main'
previous = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/11356e0/.rundirs/cv-holdouts-7/output/cross_validation'
tables = c('feasibility.csv', 'directions.csv', 'target.csv', 'comparison.csv')
same = sprintf("old = tools::md5sum(file.path('%s', c(%s))); new = tools::md5sum(file.path('.rundirs/review-fixes/output/cross_validation', c(%s))); print(cbind(old, new)); stopifnot(identical(unname(old), unname(new)))",
               previous, paste0("'", tables, "'", collapse = ', '), paste0("'", tables, "'", collapse = ', '))
list(
  name     = 'review-fixes',
  commit   = '89f7d1786fe1b36265623f7e42924d45ea726c8b',
  config   = 'config.R',
  settings = list(analysis = list(draws = list(seed = 1549466984))),
  copy     = list(c(file.path(run1, 'data/ALB_diffs_bluesky.RDS'), 'data/ALB_diffs_bluesky.RDS')),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R', 'scripts/3_plot_cal_lct_albedo.R'),
  checks   = list(c('tools/compare_tables.R', file.path(run1, 'data/calibration_modern_lct_interp_bluesky.RDS'),
                    '.rundirs/review-fixes/data/calibration_modern_lct_interp_bluesky.RDS'),
                  c('-e', "stopifnot(file.exists('.rundirs/review-fixes/Rplots.pdf'), !file.exists('Rplots.pdf')); cat('Rplots.pdf in the run folder only\\n')"),
                  'tests/test_run_manifest.R', 'tests/test_paths.R', 'tests/test_cross_validation.R',
                  'tests/test_model_registry.R', 'tests/test_config.R',
                  c('tools/cross_validate_albedo.R', 'holdouts', '.rundirs/review-fixes'),
                  c('-e', same),
                  c('tests/test_cross_validation_stages.R', '.rundirs/review-fixes')),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1'))
