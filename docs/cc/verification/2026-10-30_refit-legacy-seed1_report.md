# Verification refit-legacy-seed1: FAIL

- verdict: **FAIL**
- commit: 527ea1c9b4819cd82711e3a514c2a9304c8f3a56
- spec: `docs/cc/verification/2026-10-30_refit-legacy-seed1.R`
- started 2026-10-30 17:22:19 UTC, finished 2026-10-30 17:24:26 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/527ea1c` at 527ea1c9b4819cd82711e3a514c2a9304c8f3a56; 0 frozen inputs linked from the main checkout
- run folder `.rundirs/refit-legacy-seed1`; configuration `.rundirs/refit-legacy-seed1/config_used.R` (from `configs/legacy_config.R`); 195 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=8-15

## Scripts

- scripts/5_calibration_eval.R: exit status 1, 1.7 min, run record `20261030T172234.141Z_3000984.md`, 12 outputs
- scripts/6_prediction_model.R: not run (an earlier step failed)

## Anchors

- tests/anchors/interp-seed1-2026-10-14: not compared (an earlier step failed)

## Checks


## Failures

- scripts/5_calibration_eval.R exited with status 1 (log: /home/expert/Documents/contracting/Andria/paleo-RF-verify/527ea1c/.rundirs/refit-legacy-seed1/5_calibration_eval.log)
- scripts/5_calibration_eval.R: run record status "failed"
