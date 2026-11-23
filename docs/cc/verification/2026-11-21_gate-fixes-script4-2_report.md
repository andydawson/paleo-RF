# Verification gate-fixes-script4-2: PASS

- verdict: **PASS**
- commit: 5cadb41affefe1db093bdd6e3906b60a9217f420
- spec: `docs/cc/verification/2026-11-20_gate-fixes-script4-2.R`
- started 2026-11-20 22:34:57 UTC, finished 2026-11-21 00:42:17 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/5cadb41` at 5cadb41affefe1db093bdd6e3906b60a9217f420; 0 frozen inputs linked from the main checkout
- run folder `.rundirs/gate-fixes-script4-2`; configuration `.rundirs/gate-fixes-script4-2/config_used.R` (from `configs/legacy_config.R`); 0 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=0-7

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.5 min, run record `20261120T223510.810Z_3102234.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 3.6 min, run record `20261120T223541.214Z_3102554.md`, 2 outputs
- scripts/4_calibration_model.R: exit status 0, 122.8 min, run record `20261120T223916.864Z_3104555.md`, 17 outputs

## Anchors


## Checks

- `-e 
mine = read.csv('.rundirs/gate-fixes-script4-2/output/calibration/AIC_table.csv')
ref  = read.csv('tests/anchors/interp-allmonths-2026-09-20/AIC_table.csv')[, c('model', 'jan')]
print(cbind(mine, anchor = ref$jan))
stopifnot(identical(dim(mine), dim(ref)), identical(mine$model, ref$model), identical(mine$jan, ref$jan))
cat('January AIC column identical to the anchor for all', nrow(mine), 'models
')
`: exit status 0

## Failures

- none
