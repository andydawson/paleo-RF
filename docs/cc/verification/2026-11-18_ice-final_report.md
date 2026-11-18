# Verification ice-final: PASS

- verdict: **PASS**
- commit: 0ffa156a6398c42a6c07d3664ce8059e0e484aa0
- spec: `/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/docs/cc/verification/2026-11-18_ice-final.R`
- started 2026-11-18 15:28:03 UTC, finished 2026-11-18 15:33:06 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/0ffa156` at 0ffa156a6398c42a6c07d3664ce8059e0e484aa0; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/ice-final`; configuration `.rundirs/ice-final/config_used.R` (from `config.R`); 0 files copied in
- runner `tools/rscript.sh` with THREADS=1 OPENBLAS_NUM_THREADS=1

## Scripts


## Anchors


## Checks

- `tests/test_bluesky_albedo.R`: exit status 0 (log `check_01.log`)
- `tests/test_build_nadi1_fractions.R`: exit status 0 (log `check_02.log`)
- `tests/test_calendar.R`: exit status 0 (log `check_03.log`)
- `tests/test_calibration_fit.R`: exit status 0 (log `check_04.log`)
- `tests/test_check_comments_only.R`: exit status 0 (log `check_05.log`)
- `tests/test_check_merge_evidence.R`: exit status 0 (log `check_06.log`)
- `tests/test_check_model7_convergence.R`: exit status 0 (log `check_07.log`)
- `tests/test_config.R`: exit status 0 (log `check_08.log`)
- `tests/test_cross_validation_stages.R`: exit status 0 (log `check_09.log`)
- `tests/test_cross_validation.R`: exit status 0 (log `check_10.log`)
- `tests/test_cv_separation.R`: exit status 0 (log `check_11.log`)
- `tests/test_differences.R`: exit status 0 (log `check_12.log`)
- `tests/test_explore_cover_contrasts.R`: exit status 0 (log `check_13.log`)
- `tests/test_forcing_breakdown.R`: exit status 0 (log `check_14.log`)
- `tests/test_forcing_components.R`: exit status 0 (log `check_15.log`)
- `tests/test_forcing_periods.R`: exit status 0 (log `check_16.log`)
- `tests/test_hindcast_comparison.R`: exit status 0 (log `check_17.log`)
- `tests/test_model_registry.R`: exit status 0 (log `check_18.log`)
- `tests/test_paths.R`: exit status 0 (log `check_19.log`)
- `tests/test_preparation_albedo.R`: exit status 0 (log `check_20.log`)
- `tests/test_preparation_ice.R`: exit status 0 (log `check_21.log`)
- `tests/test_preparation.R`: exit status 0 (log `check_22.log`)
- `tests/test_random.R`: exit status 0 (log `check_23.log`)
- `tests/test_run_manifest.R`: exit status 0 (log `check_24.log`)
- `tests/test_tools.R`: exit status 0 (log `check_25.log`)
- `tests/test_training_support.R`: exit status 0 (log `check_26.log`)
- `tests/test_verify_change.R`: exit status 0 (log `check_27.log`)
- `tools/check_cover_contrasts.R inputs ../1d31cfc/.rundirs/cv2-holdouts ../8e3f3a4/.rundirs/run2-snowfree-2 ../74b5482/.rundirs/run7-snowy --fill-missing`: exit status 0 (log `check_28.log`)
- `tools/explore_cover_contrasts.R duveiller /home/expert/Documents/contracting/Andria/paleo-RF-verify/7c12534/.rundirs/cover-contrasts-full /home/expert/Documents/contracting/Andria/paleo-RF/data/duveiller2018/albedo_IGBPdet.nc .rundirs/ice-final/duveiller`: exit status 0 (log `check_29.log`)
- `tools/check_cover_contrasts.R duveiller .rundirs/ice-final/duveiller /home/expert/Documents/contracting/Andria/paleo-RF-verify/7c12534/.rundirs/cover-contrasts-full /home/expert/Documents/contracting/Andria/paleo-RF/data/duveiller2018/albedo_IGBPdet.nc`: exit status 0 (log `check_30.log`)

## Failures

- none
