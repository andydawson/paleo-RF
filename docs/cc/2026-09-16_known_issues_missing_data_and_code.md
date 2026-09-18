# Known issues, missing data and missing code

Prepared 2026-09-16 for the meeting with Andria, from a read-through of every
script and from running the pipeline in a fresh R environment. Nothing here
has been fixed on `main`; the `run-nointerp` branch contains workarounds for
the items marked *(worked around)*. Line numbers refer to `main`.

Vocabulary: **interp** = the workflow using REVEALS posteriors spatially
interpolated over the full grid with an ice mask (the current, all-months
path, introduced Feb 2024). **non-interp** = the older path using only grid
cells that contain pollen sites, fitted for March only. `_interp` in a file
name marks the former.

## 1. Known issues in the code

### 1.1 Things that stop a script from running

| # | Where | Issue |
|---|---|---|
| 1 | all scripts | `output/` and `figures/` are never created; every `saveRDS`/`ggsave` into them fails on a clean checkout. *(worked around)* |
| 2 | `1_veg_lct_prep.R` L32 | reads `taxon2LCT_translation_v2.csv`; the repo has `taxon2LCT_translation_v2.0.csv`. |
| 3 | `3_plot_cal_lct_albedo.R` L4-5 | loads `rgeos` and `rgdal`, removed from CRAN in Oct 2023. Neither is called directly. *(worked around)* |
| 4 | `3_plot_cal_lct_albedo.R` L53, L340 | sources `scripts/make_grid.R`, which is not in the repo. *(worked around with a reconstruction)* |
| 5 | `3_plot_cal_lct_albedo.R` | uses `%>%` and `group_by` without `library(dplyr)`. *(worked around)* |
| 6 | `6_prediction_model.R` L8, `6_prediction_model_spatial_eval.R` L8 | `library(SemiPar)`: archived on CRAN, never used. *(worked around)* |
| 7 | `6_prediction_model_spatial_eval.R` L223 | `library(pwiser)`: not on CRAN (GitHub only); its only use is commented out. |
| 8 | `GCM_snow_prob.R` L42 | `SpatialPointsDataFrame(..., proj4string = crs(alb_proj))`: with raster 3.6 `crs()` on a string returns a character, and sp 2.x requires a `CRS` object. Fails immediately. Fix: `CRS(alb_proj)`. |
| 9 | `5_calibration_eval.R` L904 | `AIC(..., mod7_free, ...)` but the `readRDS` for `mod7_free` on L901 is commented out, and `4_calibration_model.R` L738 saved `mod7` under the `mod7_free` filename, so the object never existed. *(worked around)* |
| 10 | `beta_veg_lct_modern.R` L13 | `lct_modern = ` followed by a blank line: R parses it together with the next statement, so `lct_modern` silently becomes the projection string. |
| 11 | `thornthwaite.R` | needs `geosphere::daylength` and `ClimClass::ExAtRa` but loads neither; `ClimClass` is not on CRAN any more. Only archive scripts use it. |
| 12 | several | packages used without being loaded: `ggplot2` and `sp` in the first 90 lines of `7_plot_preds.R`, `ggplot2` and `units` in `7a_alb_diff_full.R`, `loo` in `5_calibration_eval.R`. Works only if an earlier script left them attached. |

### 1.2 Path and naming mismatches between scripts

| # | Issue |
|---|---|
| 13 | `5_calibration_eval.R` L342-349 reads the spatial-experiment models from `output/calibration/spatial_experiment/`, but `4_calibration_model.R` L365-426 writes them to `output/calibration/`, and `6_prediction_model_spatial_eval.R` L65-100 reads from `output/calibration/` again. |
| 14 | `6_prediction_model_spatial_eval.R` L322 onward is a verbatim copy of the `XXX OLD` block from `6_prediction_model.R` and rewrites `data/paleo_predict_gam_*_bluesky.RDS`. |
| 15 | `6_prediction_model.R` L110 onward (`## XXX OLD`) is still live and rewrites the committed non-interp prediction files every time the interp path runs. |
| 16 | `6_prediction_model_spatial_eval.R` L272 defines `sc_fill_diverge` using `values`, which is only assigned at L280. |
| 17 | `6_prediction_model_spatial_eval.R` figure name `alb_diff_spatial_eval_tile_grid__bluesky.png` has a double underscore. |

### 1.3 Probable bugs (do not stop the script, may affect results)

| # | Where | Issue |
|---|---|---|
| 18 | `7_plot_preds.R` L459, L1473 | page loops filter with `subset(alb_grid_sub, year==year)`, comparing the column to itself, so every page of the per-year PDFs plots all years. Probably meant `year == yr` with a differently named loop variable. |
| 19 | `4_calibration_model.R` L738 | `saveRDS(mod7, ...mod7_free...)` saves the wrong model (see #9). *(worked around)* |
| 20 | `2_calibration_lct_bluesky.R` L114-121 | `cols_fill` is assigned twice in a row; the first (`scale_fill_brewer`) is dead. Cosmetic. |
| 21 | `4_calibration_model.R` | `library(gam)` is loaded next to `mgcv`. Only `bam` is namespaced; `gam.check`, `anova.gam`, `vis.gam` resolve by search order. Works today but fragile. |
| 22 | `4_calibration_model.R` | the interp path fits mod1-8 for every month in the first loop (L202-295) and then fits mod8 again for every month in the last loop (L443-527): the expensive step runs twice. |
| 23 | `4_calibration_model.R` L776-784 | a `mod9` (select = TRUE) is fitted at the end of the March ladder, never saved or used; ~45 min wasted. *(worked around)* |
| 24 | `GCM_snow_prob.R` | reprojects the whole NetCDF brick inside the innermost loop (12 months x 24 slices x 3 variables), and grows data frames with `rbind`. Very slow. Also computes no snow probability despite its name, and overwrites `lct_paleo$site` with 1s. |
| 25 | `7a_alb_diff_full.R` | cell x month double loop with `rbind` accumulation; slow but correct. |
| 26 | `8_radiative.R` | loads `ice_fort*.RDS` and `ggbreak` and never uses them; builds ggplots inside the month loop that are never printed. The exploratory `bar` block (L304-345) runs before the final `saveRDS`. |
| 27 | `1_veg_lct_prep.R` | `elevatr::get_elev_point(src = "aws")` fetches elevation from the network for every point; results depend on the tile zoom level and can change between runs. The elevation column in the repo's files differs between generations (see #29). |
| 28 | `4_calibration_model.R` | `ctrl <- list(nthreads = 8, ...)` hardcoded five times. |

### 1.4 Data consistency problems inside the repo

| # | Issue |
|---|---|
| 29 | `data/lct_modern_reveals.RDS` (committed 2023-03-02) is site-level: 1029 pollen-site coordinates with cover in **percent** (0-100). `data/lct_paleo_reveals.RDS` (2023-05-16), `calibration_modern_lct_bluesky.RDS` (2023-05-12) and the committed model fits are grid-level: 505 one-degree cells with cover as **proportions** (0-1). The age-50 slice of the paleo file is exactly the committed calibration site set. Script 2 as committed reads the site-level file, so rerunning it produces a calibration table the model was never meant to see; fitting on it gives a model that predicts albedo ~0 for every paleo cell. The committed `1_veg_lct_prep.R` aggregates to cells before saving, so it cannot have produced the site-level file. *(worked around: script 2 falls back to the age-50 slice)* |
| 30 | `data/calibration_mod1..4_bluesky.RDS` were fitted to a response called `bs03` on 1028 rows; `mod5..7` to `mar` on 496 rows with different basis sizes from the script. The committed model files come from at least two different generations of the data and code. |
| 31 | `data/calibration_mod*_albclim.RDS`, `calibration_model*.RDS`, `cal_data.RDS`, `calibration-albedo-climate*.RDS`, `lct_albedo_snow_modern_*.RDS`, `*_CRU.csv`, `climate_CRU.csv`, `lct_paleo.RDS`, `pollen-modern-slice_v2.0.RDS`, `preds_alb_diffs_sub_bluesky.RDS` are read by no current script (archive scripts only). Unclear whether they are still needed. |
| 32 | The interp path has been the live code since Feb 2024, but not one `_interp` data file or `output/` product is in the repo, so the committed data cannot reproduce the current code's results and the current code cannot run on the committed data. |

### 1.5 Structure and documentation

| # | Issue |
|---|---|
| 33 | `README.md` lists the eight script names with no description. No statement of R version, package versions (no `renv.lock`, `DESCRIPTION` or `sessionInfo()` record), run order, expected runtimes, or which data files are inputs vs products. |
| 34 | Every script mixes the live path with commented-out or still-live older versions of itself (roughly 40% of script 4, half of script 7, the tail of script 5). Hard to tell what was run for the paper. |
| 35 | The non-interp workflow is March only; the interp workflow fits all twelve months. Which one the manuscript reports should be stated. |
| 36 | `7a_alb_diff_full.R` produces the definitive albedo differences for script 8, but `7_plot_preds.R` also writes `alb_*_diffs_*.RDS`; two parallel definitions of the same quantity. |

## 2. Missing data

Files the live scripts read that are not in the repository. Grouped by
source. "Derived" means a script in the repo would regenerate it given the
items above it.

### 2.1 Upstream inputs (cannot be rebuilt from anything in the repo)

| File | Read by | What it is |
|---|---|---|
| `data/veg_pred_LGM_8.0.RDS` | script 1 | REVEALS reconstruction output: taxon fractions per grid cell and time slice with simulation draws (`mediansim`). The root input of the non-interp path. |
| `data/veg_posts_interp_ice.RDS` | script 1 | The same posteriors spatially interpolated over the full grid with ice-covered cells masked. The root input of the interp path. **Highest priority.** |
| `data/map-data/ice/glacier_shapefiles_21-1k.RDS` | script 7 | Ice-sheet outlines for 21 ka to 1 ka, one polygon set per 1000 yr. Map overlays and ICE/no-ICE cell status. |
| `data/Dalton_QSR_2020_Ice/dalton_interpolated_LC6k.tif` | script 7a | Dalton et al. 2020 ice-fraction raster interpolated to the LandCover6k time slices. |
| `data/albedo_glacier_monthly.csv` | scripts 7, 7a | Monthly albedo assigned to ice-covered cells (`ice_albedo`). Source unknown. |
| `data/radiative-kernels/HadGEM3-GA7.1_TOA_kernel_L19.nc`, `CAM5/alb.kernel.nc`, `CACKv1.0/CACKv1.0.nc` | script 8 | Albedo radiative kernels. Public datasets; the exact files and any preprocessing should be recorded. |
| `data/GCM/ccsm3_22-0k_temp.nc`, `_prcp.nc`, `_gdd.nc` | `GCM_snow_prob.R` | CCSM3 transient paleoclimate. Only needed if the climate side-branch is still part of the analysis. |
| `data/veg_lct_binned_v8.0.csv` | `beta_veg_lct_modern.R` | Read and never used; only matters if that script is kept. |
| `data/taxon2LCT_translation_v2.csv` | script 1 | Probably the same as the `_v2.0.csv` in the repo; confirm. |

### 2.2 Derived files missing from the repo

| File | Written by | Needed by |
|---|---|---|
| `data/lct_modern_reveals_interp.RDS`, `data/lct_paleo_reveals_interp.RDS` | script 1 (from `veg_posts_interp_ice.RDS`) | 2, 4, 5, 6 |
| `data/lct_modern_reveals_point.RDS` | nothing in the repo | script 2 (point-scale extraction) |
| `data/calibration_modern_lct_interp_bluesky.RDS` (+ `_coarse`) | script 2 | 3, 4, 5 |
| `data/calibration_modern_lct_bluesky_coarse.RDS`, `_point.RDS` | script 2 | script 3 |
| `output/calibration/calibration_mod{1..8}_interp_<month>_bluesky.RDS` and the spatial-experiment fits | script 4 (many hours) | 5, 6 |
| `output/calibration/calibration_mod_interp_selected_<month>_bluesky.RDS` | script 5 | 6 |
| `output/prediction/paleo_interp_predict_gam[_summary|_samps]_*.RDS` | script 6 | 7, 7a |
| `data/calibration_mod8_bluesky.RDS`, `calibration_mod7_free_bluesky.RDS`, `calibration_model_selected_bluesky.RDS` | script 4/5 (non-interp) | 5, 6 *(regenerated on `run-nointerp`)* |
| `data/calibration_brms_m{1..8}_bluesky.RDS` | nothing in the repo | script 5 brms comparison, script 6 commented block |
| `data/ice_fort.RDS`, `ice_fort_diff_young.RDS`, `ice_fort_diff_old.RDS` | script 7 (needs the ice shapefiles) | script 8 (loaded, unused) |
| `data/ALB_diffs_bluesky.RDS` | script 7a | script 8 |
| `output/forcing/RF_holocene_all_cases.RDS` | script 8 | the paper |

Ideally the repo carries the upstream inputs in 2.1 plus the final products
(the selected models, the predictions, `ALB_diffs`, the forcing file), so that
each stage can be checked without rerunning the multi-hour fits.

### 2.3 Data for the archived scripts only

ABOVE albedo/snow GeoTIFFs (`data/ABOVE/`), GlobAlbedo NetCDFs
(`data/GLOBALBEDO/`), ClimateNA input/output CSVs, `pollen-sites-times-series-all_v2.0.RDS`,
`thorn_output_*.RDS`. Only needed if any archive script is revived.

## 3. Missing code

| # | What | Why it matters |
|---|---|---|
| 1 | **The REVEALS run**: scripts, pollen dataset version, site list, taxon list, pollen productivity estimates and fall speeds, number of simulations, how `veg_pred_LGM_8.0.RDS` was assembled. | It is the root of every result. The coauthors who ran it should add it (or a pointer to its own repository plus the exact commit). |
| 2 | **The spatial interpolation and ice mask** that turns REVEALS output into `veg_posts_interp_ice.RDS`. | Same; the interp path is the current analysis and nothing in the repo documents it. |
| 3 | `scripts/make_grid.R` (original). | Sourced by script 3; reconstructed on `run-nointerp` but the original may differ. |
| 4 | Whatever produced `data/lct_modern_reveals_point.RDS` and the site-level `lct_modern_reveals.RDS` (issue #29). | Needed to know whether the point-scale calibration is part of the analysis. |
| 5 | Preparation of `data/blue_sky_monthly_2000-2009.tif` (source product, 2000-2009 median, regridding). | The albedo climatology is the response variable; its provenance should be in the methods. |
| 6 | Preparation of `data/grid.RDS` (committed as a binary, 2023-05-16), `data/map-data/geographic/pbs*.RDS`, the ice shapefile RDS, the Dalton TIFF interpolation, and `albedo_glacier_monthly.csv`. | All are committed or expected as binaries with no generating code. |
| 7 | The brms model fits (`calibration_brms_m*`) that script 5 compares against. | Either add the fitting script or drop the comparison. |
| 8 | Download / preprocessing of the three radiative kernels. | Reproducibility of script 8. |
| 9 | An environment specification: R version, package versions (`renv.lock` or `sessionInfo()` output) at the time the paper's results were produced. | rgeos/rgdal/SemiPar/ClimClass are already gone from CRAN; without a lockfile the exact environment cannot be rebuilt. |
| 10 | A driver or README stating the run order, which flavour (interp vs non-interp, which months) the manuscript uses, and expected runtimes. | Script 4 alone is ~90 min for one month; the interp version is 12 months x 8 models x 2. |

## 4. What runs today

With the workarounds on `run-nointerp`, scripts 2 to 7 run end to end on the
committed data and reproduce the committed March predictions (correlation
0.999). Scripts 7a and 8 need items in 2.1. With
`veg_posts_interp_ice.RDS` alone, scripts 1 to 6 of the interp path could
be run; 7, 7a and 8 additionally need the ice, glacier-albedo and kernel
files.
