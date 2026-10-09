# Interp anchor, 2026-09-20

The first outputs ever produced by the interp pipeline on this machine,
frozen as the regression reference for that flavour. Run provenance:
`runs/2026-09-19_1013_interp-run-1-to-6_RECONSTRUCTED.md`.

| File | What | Exactly reproducible? |
|---|---|---|
| `lct_modern_reveals_interp.RDS`, `lct_paleo_reveals_interp.RDS` | script 1 land cover, 2,860 cells, 25 slices | yes: elevation now comes from the committed cache `data/elev_interp_cells.RDS`, and a re-run on 2026-10-08 reproduced both files byte for byte |
| `calibration_modern_lct_interp_bluesky.RDS` | script 2 calibration table, 2,860 x 12 months | yes, deterministic |
| `AIC_table.csv` | script 4 model comparison | yes |
| `calibration_model_stats.csv` | script 5 fit statistics | **no**: computed from unseeded simulations; three re-runs on 2026-10-08 differ from this file by up to 0.01, so compare with the tolerances in `../tolerances.tsv` |
| `paleo_interp_predict_gam_bluesky.RDS` | script 6 point predictions | yes, given the fitted models, **at 8 BLAS threads** (at 4 the last bits differ) |
| `paleo_interp_predict_gam_summary_bluesky.RDS` | script 6 mean, sd and quantiles over 100 draws | **no**: the draws are unseeded, so compare with the tolerances in `../tolerances.tsv` |

`MD5SUMS.txt` (added 2026-10-08) covers the five deterministic files.

Fitted model objects are not anchored: 3.6 GB, and a `bam` object carries
its call and environment so `all.equal` flags differences after any
refactor even when the fit is identical. The AIC table captures what
matters about them.
