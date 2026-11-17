# Verification duveiller-comparison: PASS

- verdict: **PASS**
- commit: fa9e465be9781036e4468930538c1f5151406482
- spec: `/home/expert/Documents/contracting/Andria/paleo-RF-wt/duveiller/docs/cc/verification/2026-11-17_duveiller-comparison.R`
- started 2026-11-17 18:47:58 UTC, finished 2026-11-17 18:51:38 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/fa9e465` at fa9e465be9781036e4468930538c1f5151406482; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/duveiller-comparison`; configuration `.rundirs/duveiller-comparison/config_used.R` (from `config.R`); 0 files copied in
- runner `tools/rscript.sh` with THREADS=1 OPENBLAS_NUM_THREADS=1

## Scripts


## Anchors


## Checks

- `tests/test_cv_separation.R`: exit status 0 (log `check_01.log`)
- `tests/test_explore_cover_contrasts.R`: exit status 0 (log `check_02.log`)
- `tests/test_training_support.R`: exit status 0 (log `check_03.log`)
- `tests/test_calibration_fit.R`: exit status 0 (log `check_04.log`)
- `tests/test_model_registry.R`: exit status 0 (log `check_05.log`)
- `tests/test_cross_validation.R`: exit status 0 (log `check_06.log`)
- `tests/test_cross_validation_stages.R`: exit status 0 (log `check_07.log`)
- `tests/test_preparation_albedo.R`: exit status 0 (log `check_08.log`)
- `tests/test_config.R`: exit status 0 (log `check_09.log`)
- `tests/test_paths.R`: exit status 0 (log `check_10.log`)
- `tools/explore_cover_contrasts.R duveiller /home/expert/Documents/contracting/Andria/paleo-RF-verify/7c12534/.rundirs/cover-contrasts-full /home/expert/Documents/contracting/Andria/paleo-RF/data/duveiller2018/albedo_IGBPdet.nc .rundirs/duveiller-comparison/comparison`: exit status 0 (log `check_11.log`)
- `tools/check_cover_contrasts.R duveiller .rundirs/duveiller-comparison/comparison /home/expert/Documents/contracting/Andria/paleo-RF-verify/7c12534/.rundirs/cover-contrasts-full /home/expert/Documents/contracting/Andria/paleo-RF/data/duveiller2018/albedo_IGBPdet.nc`: exit status 0 (log `check_12.log`)

## Failures

- none
