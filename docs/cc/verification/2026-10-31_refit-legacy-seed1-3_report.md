# Verification refit-legacy-seed1-3: PASS

- verdict: **PASS**
- commit: 3d6a05ae2c5dad62aaa7e335daae173c6c2260ee
- spec: `docs/cc/verification/2026-10-31_refit-legacy-seed1-3.R`
- started 2026-10-31 18:44:18 UTC, finished 2026-10-31 19:04:09 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/3d6a05a` at 3d6a05ae2c5dad62aaa7e335daae173c6c2260ee; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/refit-legacy-seed1-3`; configuration `.rundirs/refit-legacy-seed1-3/config_used.R` (from `configs/legacy_config.R`); 195 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=8-15

## Scripts

- scripts/5_calibration_eval.R: exit status 0, 6.8 min, run record `20261031T184436.658Z_3472537.md`, 13 outputs
- scripts/6_prediction_model.R: exit status 0, 11.6 min, run record `20261031T185124.765Z_3475507.md`, 38 outputs

## Anchors

- tests/anchors/interp-seed1-2026-10-14: every file MATCH
```
calibration_model_stats.csv                      MATCH
paleo_interp_predict_gam_summary_bluesky.RDS     MATCH
paleo_interp_predict_gam_samps_apr_bluesky.RDS   MATCH
paleo_interp_predict_gam_samps_aug_bluesky.RDS   MATCH
paleo_interp_predict_gam_samps_dec_bluesky.RDS   MATCH
paleo_interp_predict_gam_samps_feb_bluesky.RDS   MATCH
paleo_interp_predict_gam_samps_jan_bluesky.RDS   MATCH
paleo_interp_predict_gam_samps_jul_bluesky.RDS   MATCH
paleo_interp_predict_gam_samps_jun_bluesky.RDS   MATCH
paleo_interp_predict_gam_samps_mar_bluesky.RDS   MATCH
paleo_interp_predict_gam_samps_may_bluesky.RDS   MATCH
paleo_interp_predict_gam_samps_nov_bluesky.RDS   MATCH
paleo_interp_predict_gam_samps_oct_bluesky.RDS   MATCH
paleo_interp_predict_gam_samps_sep_bluesky.RDS   MATCH
paleo_interp_predict_gam_summary_apr_bluesky.RDS MATCH
paleo_interp_predict_gam_summary_aug_bluesky.RDS MATCH
paleo_interp_predict_gam_summary_dec_bluesky.RDS MATCH
paleo_interp_predict_gam_summary_feb_bluesky.RDS MATCH
paleo_interp_predict_gam_summary_jan_bluesky.RDS MATCH
paleo_interp_predict_gam_summary_jul_bluesky.RDS MATCH
paleo_interp_predict_gam_summary_jun_bluesky.RDS MATCH
paleo_interp_predict_gam_summary_mar_bluesky.RDS MATCH
paleo_interp_predict_gam_summary_may_bluesky.RDS MATCH
paleo_interp_predict_gam_summary_nov_bluesky.RDS MATCH
paleo_interp_predict_gam_summary_oct_bluesky.RDS MATCH
paleo_interp_predict_gam_summary_sep_bluesky.RDS MATCH
```

## Checks

- `tests/test_calendar.R`: exit status 0
- `tests/test_check_merge_evidence.R`: exit status 0
- `tests/test_check_model7_convergence.R`: exit status 0
- `tests/test_config.R`: exit status 0
- `tests/test_differences.R`: exit status 0
- `tests/test_model_registry.R`: exit status 0
- `tests/test_preparation.R`: exit status 0
- `tests/test_preparation_albedo.R`: exit status 0
- `tests/test_random.R`: exit status 0
- `tests/test_run_manifest.R`: exit status 0
- `tests/test_tools.R`: exit status 0
- `tests/test_verify_change.R`: exit status 0
- `tests/test_bluesky_albedo.R`: exit status 0

## Failures

- none
