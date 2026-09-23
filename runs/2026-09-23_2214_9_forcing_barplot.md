# Run: 9_forcing_barplot

**Note.** annotated script 9 verification run

## Provenance

- when: 2026-09-23 22:14:34 to 22:15:20 (0.8 min)
- status: completed
- commit: f46051c (annotated-interp)
- working tree: **DIRTY** - scripts/ or R/ had uncommitted changes
- host: beastly | cores used: 20-21
- BLAS/OMP/MKL threads: 2 /  / 
- R version 4.5.3 (2026-03-11)
- packages: mgcv 1.9.4, terra 1.9.50, raster 3.6.32, sp 2.2.3, dplyr 1.2.1, gratia 0.11.2, ggplot2 4.0.3

## Config

- variant: veg_ice_thresh
- kernels: hadgem, cam5, cack
- periods: 0.05 - 0.5 ka, 0.5 - 2 ka, 2 - 4 ka, 4 - 6 ka, 6 - 8 ka, 8 - 10 ka, 10 - 12 ka
- earth_area_m2: 5.101e+14

## Inputs

  - output/forcing/RF_holocene_all_cases.RDS | 132.7 MB | md5 a6705be34f2aaca0dc3aa52a1fe2ba76
  - data/alb_interp_preds_diffs_bluesky.RDS | 13.4 MB | md5 8ae11ad606a6da545b0355ea67ad0a14
  - data/ipcc-ar6/AR6_ERF_1750-2019.csv | 0.1 MB | md5 f64915777d2971c5eb5d96a432f45c48
  - data/ipcc-ar6/AR6_ERF_1750-2019_pc05.csv | 0.1 MB | md5 59901f800bbdb5cd612682bc1193ad17
  - data/ipcc-ar6/AR6_ERF_1750-2019_pc95.csv | 0.1 MB | md5 012bcceb696255d62d3c8e798cb2f56d

## Outputs

  - figures/forcing_barplot_slide18.pdf | 0.0 MB | md5 (not hashed)
  - figures/forcing_barplot_slide18.png | 0.0 MB | md5 (not hashed)
  - figures/forcing_barplot_kernel_spread.pdf | 0.0 MB | md5 (not hashed)
  - figures/forcing_barplot_domain_mean.pdf | 0.0 MB | md5 (not hashed)
  - figures/forcing_barplot_variant_sensitivity.pdf | 0.0 MB | md5 (not hashed)
  - output/forcing/forcing_by_period.csv | 0.0 MB | md5 (not hashed)
  - output/forcing/forcing_by_period_variant_sensitivity.csv | 0.0 MB | md5 (not hashed)
  - output/forcing/modern_ipcc_ar6_erf.csv | 0.0 MB | md5 (not hashed)
  - figures/forcing_barplot_slide18_egu2024recipe.pdf | 0.0 MB | md5 (not hashed)
  - output/forcing/forcing_by_period_egu2024recipe_vs_slide.csv | 0.0 MB | md5 (not hashed)

