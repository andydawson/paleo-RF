# Run: 9_forcing_barplot

**Note.** first attempt at slide 18: Holocene forcing by period vs IPCC AR6 modern agents, assumptions stated in the script header

## Provenance

- when: 2026-09-21 16:30:11 to 16:30:44 (0.6 min)
- status: completed
- commit: 1c2dc4a (run-interp)
- working tree: **DIRTY** - scripts/ or R/ had uncommitted changes
- host: beastly | cores used: 0-7
- BLAS/OMP/MKL threads: 8 / 8 / 8
- R version 4.5.3 (2026-03-11)
- packages: mgcv 1.9.4, terra 1.9.50, raster 3.6.32, sp 2.2.3, dplyr 1.2.1, gratia 0.11.2, ggplot2 4.0.3

## Config

- variant: veg_ice_thresh
- kernels: hadgem, cam5, cack
- periods: 0.05 - 0.5 ka, 0.5 - 2 ka, 2 - 4 ka, 4 - 6 ka, 6 - 8 ka, 8 - 10 ka, 10 - 12 ka
- earth_area_m2: 5.101e+14

## Inputs

  - output/forcing/RF_holocene_all_cases.RDS | 132.7 MB | md5 a6705be34f2aaca0dc3aa52a1fe2ba76
  - data/ipcc-ar6/AR6_ERF_1750-2019.csv | 0.1 MB | md5 f64915777d2971c5eb5d96a432f45c48
  - data/ipcc-ar6/AR6_ERF_1750-2019_pc05.csv | 0.1 MB | md5 59901f800bbdb5cd612682bc1193ad17
  - data/ipcc-ar6/AR6_ERF_1750-2019_pc95.csv | 0.1 MB | md5 012bcceb696255d62d3c8e798cb2f56d

## Outputs

  - figures/forcing_barplot_holocene_vs_modern.pdf | 0.0 MB | md5 (not hashed)
  - figures/forcing_barplot_holocene_vs_modern.png | 0.1 MB | md5 (not hashed)
  - figures/forcing_barplot_domain_mean.pdf | 0.0 MB | md5 (not hashed)
  - figures/forcing_barplot_variant_sensitivity.pdf | 0.0 MB | md5 (not hashed)
  - output/forcing/forcing_by_period.csv | 0.0 MB | md5 (not hashed)
  - output/forcing/forcing_by_period_variant_sensitivity.csv | 0.0 MB | md5 (not hashed)
  - output/forcing/modern_ipcc_ar6_erf.csv | 0.0 MB | md5 (not hashed)

