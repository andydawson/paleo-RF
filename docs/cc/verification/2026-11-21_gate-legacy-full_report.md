# Verification gate-legacy-full: PASS

- verdict: **PASS**
- commit: 9c8dea142bf75db76cc841f0e857ada2baeb8672
- spec: `docs/cc/verification/2026-11-20_gate-legacy-full.R`
- started 2026-11-20 17:11:11 UTC, finished 2026-11-21 11:25:20 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/9c8dea1` at 9c8dea142bf75db76cc841f0e857ada2baeb8672; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/gate-legacy-full`; configuration `.rundirs/gate-legacy-full/config_used.R` (from `configs/legacy_config.R`); 0 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=8-15

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261120T171128.620Z_2941758.md`, 2 outputs
- scripts/2_calibration_lct_bluesky.R: exit status 0, 2.8 min, run record `20261120T171150.251Z_2942096.md`, 2 outputs
- scripts/3_plot_cal_lct_albedo.R: exit status 0, 0.8 min, run record `20261120T171436.258Z_2944235.md`, 0 outputs
- scripts/4_calibration_model.R: exit status 0, 943.0 min, run record `20261120T171524.782Z_2944741.md`, 193 outputs
- scripts/5_calibration_eval.R: exit status 0, 6.8 min, run record `20261121T085831.741Z_3396711.md`, 13 outputs
- scripts/6_prediction_model.R: exit status 0, 11.8 min, run record `20261121T090519.626Z_3401022.md`, 38 outputs
- scripts/7_plot_preds.R: exit status 0, 73.6 min, run record `20261121T091710.401Z_3416786.md`, 4 outputs
- scripts/7a_alb_diff_full.R: exit status 0, 53.0 min, run record `20261121T103048.785Z_3480730.md`, 1 outputs
- scripts/8_radiative.R: exit status 0, 0.4 min, run record `20261121T112348.661Z_3507693.md`, 1 outputs
- scripts/9_forcing_barplot.R: exit status 0, 0.6 min, run record `20261121T112411.868Z_3507966.md`, 4 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.3 min, run record `20261121T112446.252Z_3508354.md`, 1 outputs

## Anchors

- tests/anchors/interp-allmonths-2026-09-20: every file MATCH
```
lct_modern_reveals_interp.RDS                    MATCH
lct_paleo_reveals_interp.RDS                     MATCH
calibration_modern_lct_interp_bluesky.RDS        MATCH
AIC_table.csv                                    MATCH
paleo_interp_predict_gam_bluesky.RDS             MATCH
```
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

- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0

## Failures

- none
