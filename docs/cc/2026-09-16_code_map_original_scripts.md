# Code map: paleo-RF

High-level guide to the scripts in this repository, written 2026-09-16 from a
read-through of the code (no code was changed). Use it as a map before
exploring the scripts yourself. Line counts are approximate.

**What the project does.** Estimates radiative forcing from Holocene land-cover
change in North America. Fossil-pollen-derived vegetation (REVEALS
reconstructions) is converted to three land-cover-type fractions (LCT: ET =
evergreen trees, ST = summergreen trees, OL = open land). A satellite albedo
climatology is extracted at modern sites to fit a calibration model
(albedo ~ space + elevation + LCT, one beta-regression GAM per month). The
calibration model is applied to paleo LCT to predict albedo through time, and
albedo differences are converted to radiative forcing.

## Main pipeline (`scripts/`)

```
1_veg_lct_prep.R ─► 2_calibration_lct_bluesky.R ─► 4_calibration_model.R ─► 5_calibration_eval.R
        │                      │                                                   │
        │                      └─► 3_plot_cal_lct_albedo.R (diagnostic plots)      ▼
        │                                                              6_prediction_model.R
        └─► GCM_snow_prob.R (paleo climate side-branch)                            │
                                                                                   ▼
                                                     7_plot_preds.R / 7a_alb_diff_full.R ─► 8_radiative.R
```

Two "flavours" of the data run through the scripts: the original REVEALS
output (files without `_interp`) and a spatially interpolated, ice-masked
version (`_interp`). The most recent commits moved the active path to the
`_interp` flavour; the non-interp code is often still present, commented out
or duplicated below. `alb_prod` (`'bluesky'` vs `'albclim'`) selects the
albedo product; `bluesky` is the live choice.

### `1_veg_lct_prep.R` (~250 lines)
Converts REVEALS taxon-level vegetation posteriors to ET/ST/OL fractions per
grid cell and time slice, projects to Albers, attaches elevation (via
`elevatr`, which needs network access), clips to the study region, and splits
modern (age 50) from paleo. Then repeats the same for the interpolated
posteriors.
- Reads: `veg_pred_LGM_8.0.RDS`, `veg_posts_interp_ice.RDS`,
  `taxon2LCT_translation_v2.csv`, `grid.RDS`.
- Writes: `lct_modern_reveals.RDS`, `lct_paleo_reveals.RDS`, and the
  `_interp` versions of both.

### `2_calibration_lct_bluesky.R` (~420 lines)
Extracts the 12-month blue-sky albedo climatology (2000-2009 GeoTIFF) at the
modern LCT sites, at native 0.25 degree resolution and resampled to the
project grid ("coarse"). Produces monthly albedo maps and a native-vs-coarse
scatter. The whole block is duplicated for the `_interp` data.
- Reads: `blue_sky_monthly_2000-2009.tif`, `grid.RDS`, `lct_modern_reveals*.RDS`, map polygons.
- Writes: `calibration_modern_lct_bluesky.RDS` (+ `_coarse`, `_point`,
  `_interp`, `_interp_coarse`), `figures/albedo_maps_*`.

### `3_plot_cal_lct_albedo.R` (~620 lines)
Diagnostic plots of the calibration dataset only: LCT pie maps, tricolore
ternary maps, gridded LCT maps, albedo vs latitude/elevation/LCT scatter
panels, per-month correlations. Nothing downstream depends on it.
- Reads: `calibration_modern_lct_*` files; sources `scripts/make_grid.R`
  (not in repo).
- Writes: `figures/LCT_*`.

### `4_calibration_model.R` (~830 lines)
Fits the calibration models. For each month, a ladder of eight
`mgcv::bam(..., family = betar(link='logit'))` models:
mod1 spatial only; mod2 + elevation; mod3-5 add smooths of OL, ET, ST one at
a time; mod6-8 use a joint 3-D smooth of (OL, ET, ST) with different bases
(mod8 = thin-plate, k=200). Builds an AIC table, runs a "spatial effects
experiment" (models with subsets of space / elevation / cover), then refits
mod8 only. **mod8 is the selected model.** Roughly 40% of the file is
commented-out earlier versions (single-month test, non-interp point-data
ladder).
- Reads: `calibration_modern_lct_interp_bluesky.RDS`.
- Writes: `output/calibration/calibration_mod{1..8}_interp_<month>_bluesky.RDS`,
  `AIC_table.csv`, the spatial-experiment model files.

### `thornthwaite.R` (~330 lines)
A patched copy of `ClimClass::thornthwaite()` (monthly water balance with a
snowpack term). Function definition only; sourced by archive scripts, not by
the numbered pipeline. Needs `geosphere` and `ClimClass` but does not load them.

### `beta_veg_lct_modern.R` (~170 lines)
Older approach to modern LCT: built directly from raw modern pollen counts
(Canada + Alaska), not REVEALS. Superseded by script 1; nothing in the active
pipeline reads its outputs. Line 13 has an incomplete assignment
(`lct_modern =` followed by a blank line) that silently swallows the next
statement.

### `GCM_snow_prob.R` (~215 lines)
Despite the name, computes no snow probability. Extracts monthly CCSM3
paleoclimate (tmax, tmin, precip, GDD) at paleo site locations for each time
slice, with a 350 km buffer fallback for sites falling in NA cells.
Re-projects the NetCDF brick inside the innermost loop, so it is slow.
- Reads: `lct_paleo_reveals.RDS`, `data/GCM/ccsm3_22-0k_*.nc` (not in repo).
- Writes: `tmax_GCM.csv`, `tmin_GCM.csv`, `ppt_GCM.csv`, `gdd_GCM.csv`.

### `5_calibration_eval.R` (~1070 lines)
Evaluates the calibration fit and hands the chosen model to script 6. For each
month it loads mod8, re-saves it as the "selected" model, predicts on the
calibration data, simulates 100 draws, and plots model vs data (per-month PDF
pages, a 12-panel facet, difference histograms, coverage statistics). Also
compares the seven spatial-experiment models. The last ~180 lines are live
legacy code on the old non-interp fits (GAM AIC comparison, brms comparison).
- Reads: mod1-8 per month from `output/calibration/`, calibration data.
- Writes: `output/calibration/calibration_mod_interp_selected_<month>_bluesky.RDS`
  (the hand-off to script 6), `calibration_model_stats.csv`, `figures/cal_model_*`.

### `6_prediction_model.R` (~300 lines)
Applies the 12 selected monthly GAMs to paleo LCT: point predictions plus
100 posterior simulations per month, summarised to mean / sd / quantiles per
cell and age, then merged across months. A section headed `XXX OLD`
(line 110 onward) still runs and rewrites the non-interp
`data/paleo_predict_gam_*_bluesky.RDS` files that are committed in the repo.
- Reads: `lct_paleo_reveals_interp.RDS`, selected models from script 5.
- Writes: `output/prediction/paleo_interp_predict_gam[_summary|_samps]_*.RDS`.

### `6_prediction_model_spatial_eval.R` (~370 lines)
Sensitivity branch of script 6: re-runs the paleo prediction with the seven
alternative model structures (space / elevation / cover subsets) and plots
pairwise differences against the full model. Nothing downstream uses it.

### `7_plot_preds.R` (~2090 lines)
The figure factory for the albedo predictions: binned albedo maps by age and
month, uncertainty (sd, CV) maps, and successive-time-slice difference maps,
all with ice-sheet overlays on the 1 degree grid. The first ~1090 lines handle
the interp predictions; lines ~1345-1830 are a near-verbatim repeat for the old
non-interp predictions; two large posterior-sample blocks are commented out.
- Reads: prediction summaries from script 6, `grid.RDS`, ice shapefiles,
  glacier monthly albedo CSV, map polygons.
- Writes: `data/ice_fort*.RDS` (used by script 8), `data/alb_*_diffs_*.RDS`,
  ~25 figure files `figures/alb_*`.

### `7a_alb_diff_full.R` (~850 lines)
Computes the definitive per-cell, per-month albedo differences between
successive time slices, splitting the change into vegetation and ice-sheet
parts. Uses the Dalton et al. 2020 ice-fraction raster, cell areas, and fixed
or scaled glacier albedo, in both a threshold (>0.5 ice fraction) and an
area-weighted "parts" representation. Nested cell x month loop with rbind, so
slow.
- Reads: interp prediction summary, Dalton ice TIFF, glacier albedo CSV, grid.
- Writes: `data/ALB_diffs_bluesky.RDS` (the sole input to script 8).

### `8_radiative.R` (~350 lines)
Converts albedo differences to top-of-atmosphere radiative forcing by
multiplying each monthly change by albedo radiative kernels from HadGEM3,
CAM5 and CACKv1.0, restricted to 27-74 N. Ends with an exploratory block
inspecting large June forcing values.
- Reads: `ALB_diffs_bluesky.RDS`, `ice_fort*.RDS`, `data/radiative-kernels/*.nc`.
- Writes: `output/forcing/RF_holocene_all_cases.RDS`.

### `9_forcing_barplot.R` (~300 lines; added 2026-09-21)
Not part of the code as received. Aggregates `output/forcing/RF_holocene_all_cases.RDS`
to continental forcing by period and plots it beside the IPCC AR6 agents, in the
layout of EGU slide 18. Every aggregation choice (variant, kernel, period bounds,
summing of slice-pairs, month weighting, area weighting, domain-mean versus
global-equivalent normalisation) is an explicit assumption listed in the header.
A second block reruns the slide's original recipe, recovered from git `383002d`
(the April 2024 version of `8_radiative.R`, deleted in Feb 2025): script 7's seven
coarse slice-pairs, months feb/may/aug/nov, binary ice masking, unweighted mean.
Reads the IPCC values from `data/ipcc-ar6/`. Writes summary CSVs to
`output/forcing/` and figures. Logs a manifest.

## `scripts/archive/` (14 files, all superseded)
Earlier generations of the same pipeline. Rough mapping to current scripts:
- `1_pollen_modern.R`, `7_pollen_time.R`: LCT from raw pollen counts, modern
  and paleo. Replaced by `1_veg_lct_prep.R` (REVEALS-based).
- `archive_2_monthly_ABOVE.R`, `archive_2_monthly_GLOBALB.R`,
  `3_snow_probability.R`, `archive_2a_plot_albedo_product.R`: albedo/snow
  extraction from the ABOVE and GlobAlbedo products. Replaced by
  `2_calibration_lct_bluesky.R`.
- `4a_run_climateNA.R`, `4_thorn_modern.R`, `4b_thorn_modern.R`,
  `4c_merge_climate.R`, `5_plot_thorn.R`, `5_plot_clim.R`, `8_thorn_paleo.R`:
  a climate / Thornthwaite snow-model branch using the external ClimateNA
  application and CRU/GCM CSVs. Produced the `*_CRU.csv`, `climate_CRU.csv`
  and `calibration-albedo-climate*.RDS` files still in `data/`. No current
  script consumes them; `GCM_snow_prob.R` is the nearest descendant.
- `8_plot_preds.R`: earlier prediction/difference maps. Replaced by
  `7_plot_preds.R` and `7a_alb_diff_full.R`.

## Data in the repo vs data the scripts need
Present in `data/` and loadable (checked with R): calibration tables
(`calibration_modern_lct_bluesky.RDS`, `cal_data.RDS`, `lct_albedo_snow_modern_*`),
fitted non-interp models (`calibration_mod1..7_bluesky.RDS`,
`calibration_mod1..6_albclim.RDS`, `calibration_model*.RDS`), REVEALS LCT
tables (`lct_modern_reveals.RDS`, `lct_paleo_reveals.RDS`, `lct_paleo.RDS`),
non-interp paleo predictions (`paleo_predict_gam[_summary]_bluesky.RDS`),
`grid.RDS` (1 degree lon/lat raster), the blue-sky albedo GeoTIFF, CRU/GCM
climate CSVs, and political-boundary polygons.

Not in the repo but required by the live code path:
- `veg_pred_LGM_8.0.RDS`, `veg_posts_interp_ice.RDS` (REVEALS posteriors; script 1)
- `taxon2LCT_translation_v2.csv` (repo has `_v2.0.csv`; script 1)
- every `_interp` file: `lct_modern_reveals_interp.RDS`,
  `lct_paleo_reveals_interp.RDS`, `calibration_modern_lct_interp_bluesky.RDS`
- `lct_modern_reveals_point.RDS`, `calibration_modern_lct_bluesky_{coarse,point}.RDS`
- `scripts/make_grid.R` (sourced by script 3)
- `calibration_mod8_bluesky.RDS`, `calibration_model_selected_bluesky.RDS`,
  `calibration_brms_m*.RDS` (legacy blocks of scripts 5 and 6)
- `data/GCM/ccsm3_22-0k_*.nc`, `data/map-data/ice/glacier_shapefiles_21-1k.RDS`,
  `data/Dalton_QSR_2020_Ice/dalton_interpolated_LC6k.tif`,
  `data/albedo_glacier_monthly.csv`, `data/radiative-kernels/*`
- the `output/` and `figures/` directories (never created by the scripts)

## R packages used
Core: `terra`, `raster`, `sp`, `sf`, `mgcv`, `gam`, `dplyr`, `tidyr`,
`reshape2`, `ggplot2`, `scales`.
Plotting extras: `ggtern`, `tricolore`, `scatterpie`, `scico`, `tidyterra`,
`rasterVis`, `GGally`, `fields`, `ggbreak`, `gratia`.
Other: `elevatr` (network), `brms` (legacy), `SemiPar`, `pwiser`, `ncdf4`,
`maps`, `geosphere`/`ClimClass` (thornthwaite.R only).
Retired from CRAN and loaded by script 3: `rgdal`, `rgeos`.

## Run report (2026-09-16)

Environment: no system R and no sudo on this machine, so a user-space
micromamba env `paleo-rf` (R 4.4.x, conda-forge + CRAN) was created under
`~/micromamba`. Every main script was then run verbatim with `Rscript` in a
scratch copy of the repo (with empty `output/` and `figures/` dirs created).
No script in the numbered pipeline runs to completion from the repo as
committed. First failure per script:

| Script | First failure |
|---|---|
| `1_veg_lct_prep.R` | missing `data/veg_pred_LGM_8.0.RDS` |
| `2_calibration_lct_bluesky.R` | missing `data/lct_modern_reveals_point.RDS` |
| `3_plot_cal_lct_albedo.R` | `library(rgeos)`: package retired from CRAN (also `rgdal`) |
| `4_calibration_model.R` | missing `data/calibration_modern_lct_interp_bluesky.RDS` |
| `5_calibration_eval.R` | same missing file |
| `6_prediction_model.R` | `library(SemiPar)`: package archived on CRAN (loaded but never used) |
| `6_prediction_model_spatial_eval.R` | same |
| `7_plot_preds.R` | missing `data/map-data/ice/glacier_shapefiles_21-1k.RDS` |
| `7a_alb_diff_full.R` | missing `output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS` |
| `8_radiative.R` | missing `data/ice_fort.RDS` (written by script 7) |
| `GCM_snow_prob.R` | code error at line 42: `SpatialPointsDataFrame(..., proj4string = crs(alb_proj))`; in raster 3.6 `crs()` on a string returns a character, and `sp` 2.x requires a `CRS` object (a package-version incompatibility, not a missing file) |
| `beta_veg_lct_modern.R` | missing `data/veg_lct_binned_v8.0.csv` |
| `thornthwaite.R` | runs (function definition only) |

Packages that could not be installed: `rgdal`, `rgeos` (retired), `SemiPar`
(archived), `pwiser` (GitHub only), `ClimClass`. Everything else in the
package list above is installed in the env.

What does work: all 37 `.RDS` files in `data/` load (data frames, `mgcv`
`bam`/`gam` fits, `RasterLayer`, `SpatialPolygonsDataFrame`), and the
blue-sky GeoTIFF and `grid.RDS` open with `terra`. As a check of the
modelling code, the mod8 formula from script 4 was fitted to the shipped
non-interp March calibration data (505 sites) with reduced basis sizes
(k = 200 spatial, 100 land-cover instead of 500 / 200): it converged in
about 6 minutes on 4 threads with adjusted R^2 0.88 and predicted-vs-observed
correlation 0.95. At the script's full k, over 12 months and 8 models fitted
twice, script 4 is a multi-hour job.

Other issues noticed while reading (not exercised, since the scripts stop
earlier):
- `output/` and `figures/` are never created by the scripts.
- Script 1 reads `taxon2LCT_translation_v2.csv`; the repo has `_v2.0.csv`.
- Script 5 line 904 calls `AIC(..., mod7_free, ...)` but the `readRDS` for
  `mod7_free` is commented out.
- Script 5 saves spatial-experiment models under
  `output/calibration/spatial_experiment/` but script 6-spatial-eval reads
  them from `output/calibration/`.
- Script 7 page loops filter with `subset(alb_grid_sub, year==year)`, a
  self-comparison, so every page plots all years.
- Scripts 6 and 6-spatial-eval both contain a live `XXX OLD` block that
  rewrites the committed `data/paleo_predict_gam_*_bluesky.RDS` files.
- Several scripts use `ggplot2`, `sp`, `dplyr`, `units` without loading them;
  they work only if an earlier script left the package attached.
- `beta_veg_lct_modern.R` line 13 is an incomplete assignment (`lct_modern =`)
  that swallows the next statement.
- `4_calibration_model.R` hardcodes `nthreads = 8`.

## Running the non-interp path (branch `run-nointerp`, 2026-09-16)

The non-interp workflow is a **single-month (March) calibration**: the
committed model files, the calibration table and the paleo predictions all
carry March albedo only. With the edits on this branch (all marked
`# [run-nointerp]`), scripts 2 to 7 run end to end from the data in the repo:

| Script | Runtime | Result |
|---|---|---|
| 2 | ~3 min | regenerates `calibration_modern_lct_bluesky.RDS` identical to the committed file, plus `_coarse` and 26 albedo maps |
| 3 | ~1 min | LCT pie, tricolore and gridded calibration maps |
| 4 | ~90 min | March mod1-mod8 (+ mod7_free); mod8 is `calibration_model_selected` via script 5 |
| 5 | seconds | AIC/ANOVA table, model-vs-data figures (corr 0.95) |
| 6 | seconds | `paleo_predict_gam[_summary|_samps]_bluesky.RDS`; matches the committed predictions (corr 0.999, mean abs diff 0.007) |
| 7 | ~6 min | 13 `alb_preds_*` figures, no ice-sheet overlay |

Scripts 7a and 8 still cannot run: they need the Dalton ice raster, the
glacier albedo CSV and the radiative-kernel NetCDFs, none of which are in the
repo, and 7a reads only the interp predictions.

What had to change (see the commit messages on the branch for detail):
- A `run_interp` flag in each script, set from `file.exists()` on its interp
  input, wraps the interp sections in `if (run_interp) { ... }`; the interp
  code is otherwise untouched.
- The commented-out March model ladder in script 4 is live again; the
  `mod7_free` save bug is fixed; an unused, unsaved `mod9` at the end is
  commented out (it cost 45 min for nothing).
- `scripts/make_grid.R` is reconstructed for script 3; `rgeos`/`rgdal`
  (retired) and `SemiPar` (archived, unused) are no longer loaded.
- Script 7 builds an empty ice overlay when the shapefiles are missing.
- **Data inconsistency found:** `data/lct_modern_reveals.RDS` is stale (1029
  sites, cover in percent). Everything else non-interp uses 505 sites with
  cover as proportions, and the age-50 slice of `lct_paleo_reveals.RDS` is
  exactly the committed calibration site set. Script 2 now falls back to that
  slice when the modern table is on the percent scale. Fitting on the stale
  table gives a model that predicts albedo ~0 for all paleo cells.

Regenerated data files are left uncommitted in the working tree (10 tracked
files modified, 6 new). `git checkout data/` restores the committed versions.
