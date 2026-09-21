# Run: non-interp pipeline, March, scripts 2 to 7 (RECONSTRUCTED)

**Note.** First successful end-to-end run of any flavour of this pipeline.
Purpose: get the code running at all and check it reproduces Andria's
committed results. It does. This is the **second** March attempt of the
day: the first, launched 13:52, fitted the whole ladder to a stale
land-cover table and produced albedo of ~0 for every paleo cell (see
below), and was discarded.

**Written by hand after the fact**, before `R/run_manifest.R` existed.

## Provenance

- when: 2026-09-16 16:45 to 19:40
- status: completed, scripts 2, 3, 4, 5, 6, 7. Script 1 not run: its
  REVEALS input is absent, but its outputs are committed, so the rest
  could start from them. Scripts 7a and 8 blocked on missing data.
- commit: branch `run-nointerp`, off `chris-dev`
- working tree: clean at launch
- host: beastly | cores used: 0-7 of 48, `nice -n 10`
- BLAS/OMP/MKL threads: 8 / 8 / 8
- R version 4.5.3 (2026-03-11)
- packages: mgcv 1.9.4, terra 1.9.50, raster 3.6.32, sp 2.2.3,
  dplyr 1.2.1, gratia 0.11.2, ggplot2 4.0.3

## Config

- flavour: non-interp (505 pollen-bearing cells)
- month: March only
- alb_prod: bluesky

## Code changes required (all marked `# [run-nointerp]`)

- `run_interp` guards round the interp blocks in scripts 2 to 7
- script 4's commented-out March ladder restored; its `mod7_free` save
  bug fixed; the unused `mod9` refit disabled
- `scripts/make_grid.R` reconstructed (the original is not in the repo)
- `rgeos`, `rgdal` (retired from CRAN) and `SemiPar` (archived) no longer
  loaded; `dplyr` loaded where it was used but not attached
- point-scale extraction commented out (input missing)
- empty ice overlay in script 7 (shapefiles not yet supplied)
- **script 2 falls back to the age-50 slice of `lct_paleo_reveals.RDS`**
  for the modern calibration sites. This was the fix that made the run
  meaningful: the committed `lct_modern_reveals.RDS` is stale, holding
  1,029 site-level rows with cover in percent, where everything else in
  the non-interp flavour uses 505 grid cells with proportions. Fitting on
  it gave a model that predicted ~0 albedo for all paleo cells.

## Inputs

  - data/lct_paleo_reveals.RDS (age-50 slice used as the modern sites)
  - data/blue_sky_monthly_2000-2009.tif
  - data/grid.RDS, data/map-data/geographic/pbs.RDS, pbs_ll.RDS

## Outputs (anchored in tests/anchors/nointerp-mar-2026-09-16)

  - data/calibration_modern_lct_bluesky.RDS | 505 cells x 12 months
  - data/calibration_mod{1..8,7_free}_bluesky.RDS (not anchored)
  - data/calibration_model_selected_bluesky.RDS
  - data/paleo_predict_gam[_samps|_summary]_bluesky.RDS | 4,453 cell-slices
  - data/alb_preds_diffs_bluesky.RDS
  - figures/ | ~79 files

## Timings measured

- script 2 ~3 min, script 3 ~1 min
- script 4 2 h 49 min for the nine-model March ladder on 8 cores. The
  discarded first attempt took 81 min unthrottled, using about 25 cores.
- scripts 5 and 6 seconds each; script 7 ~6 min

## Verification

Reproduces Andria's committed results: the regenerated calibration table
is byte-identical to `calibration_modern_lct_bluesky.RDS` as committed,
and the paleo predictions match hers to a correlation of 0.9989 (mean
absolute difference 0.007 in albedo), the residual being the unseeded
draws. Selected model adjusted R-squared 0.886, model-versus-data
correlation 0.95.
