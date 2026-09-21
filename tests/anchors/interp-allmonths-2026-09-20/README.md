# Interp anchor, 2026-09-20

The first outputs ever produced by the interp pipeline on this machine,
frozen as the regression reference for that flavour. Run provenance:
`runs/2026-09-19_1013_interp-run-1-to-6_RECONSTRUCTED.md`.

| File | What | Exactly reproducible? |
|---|---|---|
| `lct_modern_reveals_interp.RDS`, `lct_paleo_reveals_interp.RDS` | script 1 land cover, 2,860 cells, 25 slices | **no**: elevation is fetched from AWS at run time |
| `calibration_modern_lct_interp_bluesky.RDS` | script 2 calibration table, 2,860 x 12 months | yes, deterministic |
| `AIC_table.csv`, `calibration_model_stats.csv` | script 4 and 5 model comparison | yes |
| `paleo_interp_predict_gam_bluesky.RDS` | script 6 point predictions | yes, given the fitted models |
| `paleo_interp_predict_gam_summary_bluesky.RDS` | script 6 mean, sd and quantiles over 100 draws | **no**: the draws are unseeded, so compare with a tolerance |

Fitted model objects are not anchored: 3.6 GB, and a `bam` object carries
its call and environment so `all.equal` flags differences after any
refactor even when the fit is identical. The AIC table captures what
matters about them.
