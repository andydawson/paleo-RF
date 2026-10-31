# Verification refit-legacy-seed1-2: FAIL

- verdict: **FAIL**
- commit: 83415dba2ba618fe056f6cb1c8752117ade9a834
- spec: `docs/cc/verification/2026-10-31_refit-legacy-seed1-2.R`
- started 2026-10-31 18:24:30 UTC, finished 2026-10-31 18:43:25 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/83415db` at 83415dba2ba618fe056f6cb1c8752117ade9a834; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/refit-legacy-seed1-2`; configuration `.rundirs/refit-legacy-seed1-2/config_used.R` (from `configs/legacy_config.R`); 195 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=8-15

## Scripts

- scripts/5_calibration_eval.R: exit status 0, 6.6 min, run record `20261031T182448.407Z_3466742.md`, 13 outputs
- scripts/6_prediction_model.R: exit status 0, 11.7 min, run record `20261031T183126.542Z_3468486.md`, 38 outputs

## Anchors

- tests/anchors/interp-seed1-2026-10-14: NOT all MATCH
```
calibration_model_stats.csv                      DIFFER (anchor 5e5d1575, got 5e99a3ad)
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


## Failures

- anchor not matched: tests/anchors/interp-seed1-2026-10-14
