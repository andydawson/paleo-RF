# Verification gate-fixes-script4: FAIL

- verdict: **FAIL**
- commit: 5cadb41affefe1db093bdd6e3906b60a9217f420
- spec: `docs/cc/verification/2026-11-20_gate-fixes-script4.R`
- started 2026-11-20 20:24:20 UTC, finished 2026-11-20 22:32:42 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/5cadb41` at 5cadb41affefe1db093bdd6e3906b60a9217f420; 0 frozen inputs linked from the main checkout
- run folder `.rundirs/gate-fixes-script4`; configuration `.rundirs/gate-fixes-script4/config_used.R` (from `configs/legacy_config.R`); 0 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=0-7

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.5 min, run record `20261120T202433.884Z_3039048.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 3.5 min, run record `20261120T202502.897Z_3039321.md`, 2 outputs
- scripts/4_calibration_model.R: exit status 0, 124.0 min, run record `20261120T202831.796Z_3040678.md`, 17 outputs

## Anchors


## Checks

- `-e 
gate  = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/9c8dea1/.rundirs/gate-legacy-full/output/calibration'
mine  = '.rundirs/gate-fixes-script4/output/calibration'
files = list.files(mine)
stopifnot(length(files) > 0, all(grepl('_jan_', files)))
same  = unname(tools::md5sum(file.path(mine, files))) == unname(tools::md5sum(file.path(gate, files)))
cat(sprintf('%d January fit files; %d byte-identical to the gate run at 9c8dea1
', length(files), sum(same, na.rm = TRUE)))
stopifnot(!anyNA(same), all(same))
cat('all January fits identical
')
`: exit status 1

## Failures

- check failed: -e 
gate  = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/9c8dea1/.rundirs/gate-legacy-full/output/calibration'
mine  = '.rundirs/gate-fixes-script4/output/calibration'
files = list.files(mine)
stopifnot(length(files) > 0, all(grepl('_jan_', files)))
same  = unname(tools::md5sum(file.path(mine, files))) == unname(tools::md5sum(file.path(gate, files)))
cat(sprintf('%d January fit files; %d byte-identical to the gate run at 9c8dea1
', length(files), sum(same, na.rm = TRUE)))
stopifnot(!anyNA(same), all(same))
cat('all January fits identical
')
 (log: /home/expert/Documents/contracting/Andria/paleo-RF-verify/5cadb41/.rundirs/gate-fixes-script4/checks.log)
