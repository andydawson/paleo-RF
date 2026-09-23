# Glossary: column names, variable names and conventions in the paleo-RF pipeline

Written 2026-09-23 to accompany the annotated scripts on branch `annotated-interp`.
Covers the interp flavour only. Names are as they appear in the code and saved files;
line references are to the annotated scripts.

## Conventions that apply everywhere

| Convention | Meaning |
|---|---|
| **Fractions** | `ET`, `OL`, `ST` and every albedo are fractions in 0..1, never percent. The one exception is inside script 8, where albedo differences are multiplied by 100 to match kernels quoted per 1%. |
| **`x`, `y`** | Longitude and latitude in **degrees**, despite the names. Never projected metres. Every spatial smooth and every distance in the pipeline is in degrees. |
| **`long`, `lat`** | Also longitude and latitude in degrees, but the **grid-cell centre** (from `data/grid.RDS`) rather than the coordinate the row was originally built from. Identical to `x`, `y` in practice since the interp cells are already centred. |
| **`ages` / `year`** | Years before present (BP). Script 1 calls the column `ages`; script 6 renames it `year` and everything after uses `year`. 25 values: 50, 200, 500, 1000, ..., 11500. |
| **`year` in a difference table** | The **younger** slice of the pair the row describes. A row with `year = 8000` compares 8,000 BP with 8,500 BP. |
| **"young" and "old"** | Suffixes `_young` / `_old` mean the younger and older slice of a pair. |
| **Sign of a difference** | Always young minus old (`-diff()` of a series sorted young to old). Albedo falling through time is negative. |
| **Sign of a forcing** | Positive = warming. A negative albedo difference times a negative kernel (HadGEM3, CAM5), or times minus a positive kernel (CACK), gives positive forcing. |
| **`month`** | Three-letter lowercase: `jan` ... `dec`. Used as column names (script 2's table), as a column (everything from script 6 on), and as loop variables. |
| **`get(month)`** | In a model formula, "the column whose name is the current value of `month`". Saved models keep this literal formula, so `month` must exist wherever `predict()` or `simulate()` is called on them. |
| **50 BP = "modern"** | The slice closest to the 2000-2009 satellite albedo the calibration uses. |
| **12,000 BP** | Does not exist in the data. Script 7 relabels 11,500 as 12,000 so the coarse period set can end at "12 ka" (question C7). Script 7a and 8 keep 11,500. |
| **`alb_prod`** | Always `"bluesky"`: which albedo product was used. It appears in most file names. |
| **REVEALS** | The pollen-to-vegetation model (Sugita 2007) that converts pollen percentages into land-cover fractions before the spatial interpolation; run outside this repository. |
| **ka** | Thousand years before present; 8 ka = 8,000 BP. |
| **ERF** | Effective radiative forcing, the IPCC's global-mean forcing measure (W/m²); what the AR6 tables in script 9 hold. |
| **`interp`** in a file name | The spatially complete land-cover product (this flavour). Files without it belong to the point flavour. |

## The three land-cover classes

| Name | Meaning |
|---|---|
| `ET` | Evergreen trees: fraction of the cell in evergreen (mostly conifer) forest. |
| `ST` | Summergreen trees: fraction in deciduous forest. |
| `OL` | Open land: everything not forest (grassland, tundra, crops, bare). |

`ET + ST + OL = 1` in every row. Because of that, the three carry only two degrees of freedom, which is why a smooth over all three at once (models 6 to 8) is the right construction and three separate smooths (model 5) partly repeat themselves.

## Files and their columns, in pipeline order

### `data/veg_posts_interp_ice.RDS` (input to script 1)
| Column | Meaning |
|---|---|
| `cell_area` | Area of the cell, km². Dropped by script 1. |
| `cell_id` | Integer id of the 1-degree cell. Dropped by script 1 and re-derived later from `grid.RDS`. |
| `x`, `y` | Longitude, latitude (degrees). |
| `ages` | Slice, years BP. |
| `iter` | Posterior draw, 1..200. Averaged away by script 1. |
| `LCT` | Land-cover type: `"ET"`, `"ST"` or `"OL"`. |
| `value` | Fraction of the cell in that class, for that draw. |
| `ice` | Flag for cell-slices under the ice sheet. Dropped by script 1. |

### `data/lct_modern_reveals_interp.RDS`, `lct_paleo_reveals_interp.RDS` (script 1)
| Column | Meaning |
|---|---|
| `ages` | Slice (paleo file only). |
| `x`, `y` | Longitude, latitude. |
| `elev` | Elevation in metres from the AWS terrain service, fetched at run time. |
| `ET`, `OL`, `ST` | Class fractions, posterior mean over the 200 draws. |

### `data/calibration_modern_lct_interp_bluesky.RDS` (script 2)
Columns of the modern table above, plus twelve albedo columns `jan` ... `dec`: the blue-sky albedo of the 0.25-degree pixel at the cell centre, from the 2000-2009 MODIS climatology; `NA` where the satellite has no value (polar night). Exact zeros replaced by 0.0001 for the beta regression. The `_coarse` twin holds the 1-degree cell-average albedo instead.

### `output/calibration/calibration_mod<k>_interp_<month>_bluesky.RDS` (script 4)
Fitted `bam` objects, one per model `k` = 1..8 and month. The `_selected_` files (script 5) are copies of model 8. See script 4's header for what each model contains.

### `output/calibration/AIC_table.csv` (script 4)
| Column | Meaning |
|---|---|
| `model` | 1..8. |
| `jan` ... `dec` | Rounded AIC of that model for that month. Lower is better. |

### `output/calibration/calibration_model_stats.csv` (script 5)
| Column | Meaning |
|---|---|
| `month` | |
| `correlation` | Pearson correlation between observed and modelled (simulated median) albedo across cells. |
| `data in credible interval` | Fraction of ALL 2,860 cells whose observed albedo lies inside the model's 95% simulation interval; cells with no observation (polar night) count as outside, which is why Nov-Jan are low. |
| `diff lower / upper (model - data; 2.5% / 97.5%)` | Quantiles of modelled-minus-observed albedo. |

### `output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS` (script 6)
| Column | Meaning |
|---|---|
| `year` | Slice, years BP (was `ages`). |
| `x`, `y`, `elev`, `ET`, `OL`, `ST` | As input. |
| `alb_mean` | Mean of 100 simulated albedo values for the cell-slice. (In `paleo_interp_predict_gam_bluesky.RDS` the same name holds the model's fitted mean instead: deterministic, no simulation.) |
| `alb_sd` | Standard deviation of the 100 draws. |
| `alb_lo`, `alb_mid`, `alb_hi` | 2.5%, 50% and 97.5% quantiles of the draws. |
| `month` | |

The spread here is the scatter the model expects around its mean, not uncertainty in the model or in the land cover (script 6's header).

### `data/alb_interp_preds_diffs_bluesky.RDS` (script 7)
Differences between consecutive **coarse** slices (50, 500, 2000, 4000, 6000, 8000, 10000, 12000): seven pairs.
| Column | Meaning |
|---|---|
| `year` | Younger slice of the pair. |
| `long`, `lat`, `x`, `y`, `cell_id`, `month` | As above. |
| `alb_mean`, `alb_sd` | Vegetation albedo at the young slice (`alb_mean` is `NA` if the cell is ice). |
| `alb_mean_ice` | Albedo at the young slice with ice cells given the monthly `ice_albedo`. |
| `alb_bin`, `alb_sd_bin`, `alb_cv`, `alb_cv_bin` | Binned versions for the maps. |
| `facets` | Age label for maps. |
| `alb_mean_ice_old`, `alb_mean_ice_young` | With-ice albedo at each end of the pair. |
| `ice_young`, `ice_old` | `"ICE"` or `NA`: binary ice flag from the polygons at each end. |
| `alb_diff` | Vegetation albedo, young minus old; `NA` if either end is ice. |
| `alb_diff_ice` | With-ice albedo, young minus old. |

### `data/ice_fort.RDS`, `ice_fort_diff_young.RDS`, `ice_fort_diff_old.RDS` (script 7)
Ice-margin polygons flattened for ggplot: `long`, `lat`, `order`, `hole`, `piece`, `id`, `group` (ggplot2's `fortify` columns), plus `ice_year` (which polygon set) and `ages` (which coarse slice it stands for). The two `_diff_` files lack the outlines for the youngest one or two periods because of a bug noted in script 7 (the coarse age is compared with the polygon year); they are not empty.

### `data/ALB_diffs_bluesky.RDS` (script 7a) and `output/forcing/RF_holocene_all_cases.RDS` (script 8)
Differences between **consecutive** slices (24 pairs), then the same table with kernels and forcings added.

| Column | Meaning |
|---|---|
| `cell_id`, `lat`, `long`, `x`, `y`, `year`, `month` | As above; `year` is the younger slice. |
| `area`, `area_km2` | Cell area in m² and km², from the grid polygons on the ellipsoid. |
| `ice_frac_young`, `ice_frac_old` | Fraction of the cell under ice at each end, from the Dalton raster (after smoothing out steps where ice appears to grow). |
| `alb_diff_veg_thresh` | Vegetation albedo change; `NA` if either end is more than half ice. |
| `alb_diff_ice_thresh` | Young vegetation albedo minus old **fixed** ice albedo, where the old end was ice; 0 if both ends ice. |
| `alb_diff_icesc_thresh` | Same with the **seasonal** ice albedo. |
| `alb_diff_veg_ice_thresh`, `alb_diff_veg_icesc_thresh` | The vegetation and ice threshold terms combined (exclusive except for a readvance across the 50 % line, which gives 0 rather than NA; C2). |
| `alb_diff_veg_part` | Vegetation albedo change, weighted by the non-ice fraction at the old end. |
| `alb_diff_ice_part`, `alb_diff_icesc_part` | (young vegetation albedo minus ice albedo) times the fraction of the cell that deglaciated. |
| `alb_diff_veg_ice_parts`, `alb_diff_veg_icesc_parts` | Vegetation part plus ice part: the area-weighted total. |
| `long360`, `lat180` | Longitude in 0..360 and latitude in 0..180, for sampling the kernel grids (script 8 only). |
| `rk_hadgem`, `rk_cam5`, `rk_cack` | Kernel values at the cell for that month. HadGEM3 and CAM5: W/m² per 1% albedo, negative. CACK: W/m² per unit albedo, positive; sampled one degree south of the cell (script 8's header, C3) and NA in Dec/Jan north of 69 N. |
| `rf_<kernel>_<variant>` | Forcing in W/m²: the `alb_diff_<variant>` column times the kernel (with the unit and sign handling in script 8). 30 columns. |

Naming pattern, once seen: `alb_diff_` + **who** (`veg`, `ice`, `icesc`, `veg_ice`, `veg_icesc`) + `_` + **how** (`thresh` = all-or-nothing at 50% ice; `part`/`parts` = area-weighted). `icesc` = "ice, seasonal", i.e. the `ice_albedo_sc` column of `albedo_glacier_monthly.csv`.

### `output/forcing/forcing_by_period*.csv` (script 9)
| Column | Meaning |
|---|---|
| `period` | One of the seven coarse periods, e.g. `8 - 10 ka`. |
| `kernel` / `variant` | Which kernel or which `alb_diff` variant. |
| `domain_mean` | Area-weighted mean forcing over the study area, W/m². |
| `global_equiv` | Total flux over the study area divided by Earth's surface area, W/m². The like-for-like comparison with IPCC global means. |
| `area_m2` | Total area of the cells that contributed. |

## Variable names worth knowing inside the scripts

| Variable | Where | Meaning |
|---|---|---|
| `ctrl` | 4 | `list(nthreads=8, maxit=500)`: options for every `bam()` call. |
| `mod1_interp` ... `mod8_interp` | 4, 5 | The ladder of fitted models. |
| `cal_interp_data` | 4, 5 | The calibration table (script 2's output). |
| `cal_interp_model` | 5, 6 | The selected model (model 8) for the current month. |
| `lct_interp_paleo` | 6 | The paleo land-cover table with `ages` renamed `year`. |
| `alb_interp_preds` | 7, 7a | Script 6's summary table, being enriched. |
| `alb_grid`, `alb_grid_sub`, `alb_grid_full` | 7, 7a | The same after cell ids and centres (and, in 7a, areas) are attached; `_sub` = coarse slices only (7), `_full` = all slices (7a). |
| `alb_cell`, `alb_cell_filled` | 7, 7a | One cell-month's rows inside the loop; `_filled` padded to every slice. |
| `alb_diff_df` | 7, 7a | The growing difference table. |
| `ice`, `ice_years` | 7 | The 21 polygon sets and their ages. |
| `ice_dalton_interp`, `ice_dalton_years` | 7a | The Dalton raster and its layer years. |
| `ice_sub`, `ice_fort` | 7 | Ice outlines for drawing. |
| `idx_ice`, `idx_veg` | 7a | Row indices that are more / not more than half ice. |
| `is_ice_young`, `is_ice_old`, `is_ice_both`, `is_ice_missing` | 7a | Per-pair flags inside the loop. |
| `alb_diff` | 8 | The forcing table being built (starts as script 7a's output). |
| `alb_diff_spatial`, `alb_diff_spatial_cack` | 8 | Point objects for sampling the kernels. |
| `rk_hadgem`, `rk_cam5`, `rk_cack` | 8 | The kernel rasters. |
| `bar`, `foo2` | 8, 7a | Throwaway subsets for exploratory plots. |
| `main`, `sens`, `modern`, `egu` | 9 | The aggregated tables: by kernel, by variant, the IPCC agents, the recovered recipe. |
| `ages`, `ages_sub`, `years` | many | All 25 slice ages; the eight coarse ages; the eight coarse ages again under another name. |
| `labels_period`, `labels_year`, `facets` | 7, 7a, 8, 9 | Period and age labels for plots. |
| `pbs`, `pbs_ll` | many | Political boundaries, projected and lon/lat. |
| `grid`, `grid_NA` | 2, 7, 7a | The 1-degree raster. |
| `proj_WGS84`, `ll_proj` | many | The same lon/lat CRS written two ways. |
