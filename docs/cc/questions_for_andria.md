# Open questions for Andria

Maintained by Chris with Claude Code. Updated 2026-09-18. Only questions
that are still open are listed; answered or superseded items are removed
(e.g. the REVEALS and interpolation code, now agreed to be out of scope;
the point / non-interp path, now dropped; the interpolated posteriors and
ice shapefiles, received 2026-09-17).

## 1. Time slices in the interpolated land-cover file

The interpolated land-cover file you sent has 25 time slices: 50, 200,
500, then every 500 years to 11,500, and beyond. The scripts in the repo
use a shorter list, 50, 200, 500 to 11,500 in 500-year steps, and the
draft methods describe a different set again, with irregular bins in the
last two millennia (0-100, 100-350, 350-700, 700-1,500) and 1,000-year
bins before that. Which set of slices should the paper use, and are the
slice boundaries in the file the ones the REVEALS reconstruction was
actually run on? Also, does each slice value in the file represent a bin
centre or a bin edge?

## 2. Content of `veg_posts_interp_ice.RDS`

- The `ice` column is NA for the rows we looked at. What values does it
  take, and does it mean the cell was masked for that slice, or partly
  ice-covered?
- Are the 200 `iter` values posterior draws from the interpolation model
  (so that each draw is a coherent map), or independent per cell?
- `cell_area`: units (km²?) and on which projection?
- Cells: 2,870. Is that the full land mask of the study region, and is
  the 1-degree grid the same as `data/grid.RDS`?

## 3. Data files still needed for scripts 7a and 8

- `data/Dalton_QSR_2020_Ice/dalton_interpolated_LC6k.tif`: the Dalton et
  al. 2020 ice-fraction raster interpolated to the time slices (script 7a).
- `data/albedo_glacier_monthly.csv`: the monthly glacier albedo assigned
  to ice-covered cells (scripts 7 and 7a). Where do the values come from?
- `data/radiative-kernels/`: `HadGEM3-GA7.1_TOA_kernel_L19.nc`,
  `CAM5/alb.kernel.nc`, `CACKv1.0/CACKv1.0.nc` (script 8). Were these
  used as downloaded, or preprocessed?

## 4. Provenance to record in the data documentation

- The blue-sky albedo GeoTIFF (`blue_sky_monthly_2000-2009.tif`): the
  MODIS MCD43A3 v061 plus ERA5 construction described in the methods. Is
  the code for that step available anywhere, and who ran it?
- `grid.RDS`, the political-boundary polygons and `taxon2LCT_translation_v2.0.csv`:
  origin and version.
- The R version and package versions used for the results in the talk
  (there is no renv lock or sessionInfo in the repo).

## 5. Method choices to confirm for the write-up

- The scripts hard-code model 8 as the selected calibration model, while
  the manuscript says analysis of deviance chose it. Which criterion was
  used, and did the same model win in all twelve months?
- The manuscript says 1,000 posterior samples per cell and month; the
  scripts draw 100. Which is intended?
- Snow is never modelled: the 2000-2009 snow climatology enters through
  the location and elevation terms and is held fixed for every slice. You
  said the snow / water-budget branch was dropped deliberately. Should the
  paper state the fixed-modern-snow assumption explicitly in methods and
  limitations?
- Which combination does the paper report for the ice contribution in
  7a: threshold (ice fraction > 0.5) or area-weighted, and fixed or scaled
  glacier albedo?

## 6. Repository logistics

- The 334 MB posteriors file is now in the repo via Git LFS. LFS storage
  and download quota count against the repo owner's GitHub account (free
  tier: 1 GB each). Is that acceptable, or should large files live
  elsewhere (e.g. Zenodo / OSF with a download script)?
- Are the archived scripts (`scripts/archive/`, the Thornthwaite,
  ClimateNA and GCM snow work) safe to remove from the working tree and
  keep only in git history?

## 7. Fundamental questions, to raise when the time is right

The full list is in `METHODOLOGY_QUESTIONS.md`; the five to ask first:

1. Does land-cover uncertainty (the 200 draws) propagate into the albedo
   and forcing at all? Script 1 averages the draws before anything else.
2. Is the calibration fitted on the interpolated modern field (mostly
   model output) rather than on pollen-bearing cells only, and is that the
   intended design?
3. What is held fixed by the space-for-time substitution, and which of
   those things changed enough over the Holocene to matter?
4. The location term cancels in every slice-to-slice difference, so the
   whole signal comes from the cover smooth. How much of the real cover
   effect has the very flexible spatial term absorbed?
5. The headline comparison sets a local, land-only, clear-sky, per-interval
   forcing against global-mean cumulative greenhouse-gas forcing. What is
   the fair comparison?
