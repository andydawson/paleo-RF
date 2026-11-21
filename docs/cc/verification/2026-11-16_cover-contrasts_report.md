# Verification cover-contrasts: PASS

- verdict: **PASS**
- commit: 7c125340fc69e6f0320238c6392b34d7729b53b6
- spec: `/home/expert/Documents/contracting/Andria/paleo-RF-wt/contrasts/docs/cc/verification/2026-11-15_cover-contrasts.R`
- started 2026-11-16 17:22:50 UTC, finished 2026-11-16 17:29:23 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/7c12534` at 7c125340fc69e6f0320238c6392b34d7729b53b6; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/cover-contrasts`; configuration `.rundirs/cover-contrasts/config_used.R` (from `config.R`); 0 files copied in
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
- `tools/check_cover_contrasts.R inputs ../1d31cfc/.rundirs/cv2-holdouts ../8e3f3a4/.rundirs/run2-snowfree-2 ../74b5482/.rundirs/run7-snowy`: exit status 0 (log `check_11.log`)
- `tools/check_cover_contrasts.R exchanges ../1d31cfc/.rundirs/cv2-holdouts`: exit status 0 (log `check_12.log`)
- `tools/explore_cover_contrasts.R fit ../74b5482/.rundirs/run7-snowy .rundirs/cover-contrasts/cover_contrasts jul aug`: exit status 0 (log `check_13.log`)
- `tools/explore_cover_contrasts.R report .rundirs/cover-contrasts/cover_contrasts`: exit status 0 (log `check_14.log`)
- `tools/check_cover_contrasts.R job .rundirs/cover-contrasts/cover_contrasts`: exit status 0 (log `check_15.log`)

## Failures

- none
