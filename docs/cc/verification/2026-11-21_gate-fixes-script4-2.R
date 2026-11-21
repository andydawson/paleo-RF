# Fixes after the integration review (branch gate-fixes), 2 of 2, second attempt. The first attempt
# (2026-11-20_gate-fixes-script4, FAIL) compared the fit files byte for byte with the gate run's and assumed every
# January file name holds "_jan_": both wrong. The spatial experiments' names end in "jan.RDS", and a saved fit is not
# a stable byte copy: model 3's January fit has exactly the same coefficients, fitted values, smoothing parameters and
# AIC in the original, the gate run and this code, yet three different files, because the beta family it uses keeps
# internal state that is saved with the model (the regression contract never compares whole fitted objects). This
# attempt uses the contract's own reference for the fits: the AIC table's January column must equal the anchored
# table's (tests/anchors/interp-allmonths-2026-09-20/AIC_table.csv), for all eight ladder models.
list(
  name     = 'gate-fixes-script4-2',
  commit   = '5cadb41affefe1db093bdd6e3906b60a9217f420',
  config   = 'configs/legacy_config.R',
  settings = list(analysis = list(months = 'jan')),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R', 'scripts/4_calibration_model.R'),
  checks   = list(c('-e', "
mine = read.csv('.rundirs/gate-fixes-script4-2/output/calibration/AIC_table.csv')
ref  = read.csv('tests/anchors/interp-allmonths-2026-09-20/AIC_table.csv')[, c('model', 'jan')]
print(cbind(mine, anchor = ref$jan))
stopifnot(identical(dim(mine), dim(ref)), identical(mine$model, ref$model), identical(mine$jan, ref$jan))
cat('January AIC column identical to the anchor for all', nrow(mine), 'models\n')
")),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '8', CORES = '0-7'))
