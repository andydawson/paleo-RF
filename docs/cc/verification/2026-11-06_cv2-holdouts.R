# Protocol 2, before any fit: reproduce run 1's calibration and cover, freeze the new
# holdouts and target, check model-8 reuse, then freeze exchanges and synthetic data.
run1 = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main'
previous_cv = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/f07ff68/.rundirs/cv-run1'
products = c('data/calibration_modern_lct_interp_bluesky.RDS', 'data/lct_paleo_reveals_interp.RDS')
same_inputs = sprintf(
  "for (p in c(%s)) stopifnot(identical(readRDS(file.path('%s', p)), readRDS(file.path('.rundirs/cv2-holdouts', p))))",
  paste0("'", products, "'", collapse = ', '), run1)
list(
  name     = 'cv2-holdouts',
  commit   = 'TO_FILL',
  config   = 'config.R',
  settings = list(analysis = list(draws = list(seed = 1549466984))),
  copy     = list(c(file.path(run1, 'data/ALB_diffs_bluesky.RDS'), 'data/ALB_diffs_bluesky.RDS')),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R'),
  checks   = list(c('-e', same_inputs),
                  c('tools/cross_validate_albedo.R', 'holdouts', '.rundirs/cv2-holdouts', previous_cv),
                  c('tools/check_cv_separation.R', 'prepare', '.rundirs/cv2-holdouts', run1)),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1'))
