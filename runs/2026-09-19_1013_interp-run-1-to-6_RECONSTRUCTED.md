# Run: interp pipeline, scripts 1 to 6 (RECONSTRUCTED)

**Note.** First ever run of the interp (spatially complete, all-months)
pipeline, the path the EGU talk and draft manuscript are built on. Purpose:
produce the interp outputs so they can serve as the regression anchor for
that flavour. Reached the end of script 6; scripts 7, 7a and 8 remain
blocked on missing data.

**This manifest was written by hand after the fact**, before
`R/run_manifest.R` existed. Later runs get one generated automatically.

## Provenance

- when: 2026-09-19 07:42 to 2026-09-20 13:00
- status: completed for scripts 1, 2, 4, 6; script 5 completed its interp
  work then failed on the known `spatial_experiment/` path mismatch
  (known issue 13); scripts 3, 7, 7a, 8 not run
- commit: branch `run-interp`, off `chris-dev`, at `8a15f42` when the run
  started; later documentation commits do not affect the code that ran
- working tree: clean for `scripts/` at launch
- host: beastly | cores used: 0-7 of 48, `nice -n 10`
- BLAS/OMP/MKL threads: 8 / 8 / 8 (capped deliberately; leaving them
  uncapped caused 48 threads to thrash inside 8 cores on 2026-09-17)
- R version 4.5.3 (2026-03-11)
- packages: mgcv 1.9.4, terra 1.9.50, raster 3.6.32, sp 2.2.3,
  dplyr 1.2.1, gratia 0.11.2, ggplot2 4.0.3

## Config

- flavour: interp
- months: all twelve
- alb_prod: bluesky
- code change required: `1_veg_lct_prep.R` non-interp half guarded behind
  `run_nointerp` (commit 8a15f42), so the interp half could be reached

## Inputs

  - data/veg_posts_interp_ice.RDS | 334 MB | Andria, 2026-09-17, via Git LFS
  - data/blue_sky_monthly_2000-2009.tif | 3.3 MB
  - data/grid.RDS | 0.0 MB
  - data/map-data/geographic/pbs.RDS, pbs_ll.RDS
  - elevation fetched from AWS terrain tiles at run time (`elevatr`), so
    not reproducible byte-for-byte

## Outputs

  - data/lct_modern_reveals_interp.RDS | 0.1 MB | 2,860 cells
  - data/lct_paleo_reveals_interp.RDS | 1.5 MB | 69,936 rows, 25 slices
  - data/calibration_modern_lct_interp_bluesky.RDS | 0.2 MB (+ _coarse)
  - output/calibration/ | 3.6 GB | 96 ladder models + 84 spatial-experiment
    models + AIC_table.csv + calibration_model_stats.csv (git-ignored)
  - output/calibration/calibration_mod_interp_selected_<month>_bluesky.RDS | 12 files
  - output/prediction/ | 38 files | per-month and merged predictions;
    summary has 839,232 rows (2,870 cells x 25 slices x 12 months)
  - figures/ | ~98 albedo maps and calibration diagnostics (git-ignored)

## Timings measured

- script 1: ~4 min (mostly the network elevation lookup)
- script 2: ~20 min
- script 4: ~27 h. Model 7, the only Gaussian-process basis on the 3-D
  cover smooth, took ~2 h per month, about four fifths of the ladder's
  cost; every other model took 1 to 5 min. The last 3 h were a redundant
  refit of the non-interp May ladder, which is also live on this branch.
- script 5: ~4 min to the point of failure
- script 6: ~15 min

## Findings from this run

Recorded in `docs/cc/questions_for_andria_scientific.md`: B2a (the interp
flavour fits the spatial smooth on degrees, not projected metres), B2b
(polar night removes every cell above 60N from the December calibration),
B4 (model 8 wins the AIC in 11 of 12 months, so the hard-coded choice is
supported), B4a (land cover explains ten times more in autumn than in
midwinter).
