# Verification review-fixes: PASS

- verdict: **PASS**
- commit: 89f7d1786fe1b36265623f7e42924d45ea726c8b
- spec: `docs/cc/verification/2026-11-04_review-fixes.R`
- started 2026-11-04 18:10:42 UTC, finished 2026-11-04 18:23:32 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/89f7d17` at 89f7d1786fe1b36265623f7e42924d45ea726c8b; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/review-fixes`; configuration `.rundirs/review-fixes/config_used.R` (from `config.R`); 1 files copied in
- runner `tools/rscript.sh` with THREADS=1

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261104T181058.636Z_4004907.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 1.1 min, run record `20261104T181120.985Z_4005053.md`, 1 outputs
- scripts/3_plot_cal_lct_albedo.R: exit status 0, 0.8 min, run record `20261104T181228.977Z_4005448.md`, 0 outputs

## Anchors


## Checks

- `tools/compare_tables.R /home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main/data/calibration_modern_lct_interp_bluesky.RDS .rundirs/review-fixes/data/calibration_modern_lct_interp_bluesky.RDS`: exit status 0
- `-e stopifnot(file.exists('.rundirs/review-fixes/Rplots.pdf'), !file.exists('Rplots.pdf')); cat('Rplots.pdf in the run folder only\n')`: exit status 0
- `tests/test_run_manifest.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tests/test_cross_validation.R`: exit status 0
- `tests/test_model_registry.R`: exit status 0
- `tests/test_config.R`: exit status 0
- `tools/cross_validate_albedo.R holdouts .rundirs/review-fixes`: exit status 0
- `-e old = tools::md5sum(file.path('/home/expert/Documents/contracting/Andria/paleo-RF-verify/11356e0/.rundirs/cv-holdouts-7/output/cross_validation', c('feasibility.csv', 'directions.csv', 'target.csv', 'comparison.csv'))); new = tools::md5sum(file.path('.rundirs/review-fixes/output/cross_validation', c('feasibility.csv', 'directions.csv', 'target.csv', 'comparison.csv'))); print(cbind(old, new)); stopifnot(identical(unname(old), unname(new)))`: exit status 0
- `tests/test_cross_validation_stages.R .rundirs/review-fixes`: exit status 0

## Failures

- none
