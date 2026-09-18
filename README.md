# paleo-RF

Estimating Holocene radiative forcing from land-cover change in North
America, using land cover inferred from fossil pollen, a modern
satellite-albedo calibration, and radiative kernels.

**Status: research code under active development.** This README is a
first draft (2026-09-18). The authoritative descriptions of the scripts
and data are in `docs/cc/`; see the index at the end.

## What the pipeline does

1. Land-cover fractions per 1-degree cell and time slice, three classes:
   evergreen trees (ET), summergreen trees (ST), open land (OL). These
   come from the REVEALS pollen-vegetation model followed by a Bayesian
   spatial interpolation with an ice mask, both done outside this
   repository (Dawson et al., Climate of the Past); the product is a
   fixed input here.
2. A modern blue-sky albedo climatology (MODIS MCD43A3 + ERA5, 2000-2009,
   monthly) is sampled at the modern cells.
3. Twelve monthly calibration models (beta-regression GAMs, `mgcv::bam`)
   relate albedo to location, elevation and the three cover fractions.
4. The models hindcast albedo for every Holocene slice from the paleo
   cover fractions, with posterior draws.
5. Albedo differences between consecutive slices are split into
   vegetation and ice-sheet contributions and multiplied by a radiative
   kernel to give forcing in W/m².

Diagram: `docs/cc/2026-09-17_methodology_schematic.png`.

## Two flavours of the pipeline

- **interp** (the current analysis, used in the EGU talk and the draft
  paper): the spatially complete, ice-masked land-cover maps on the full
  grid, all twelve months. Files carry `_interp` in their names.
- **non-interp** (the original point-based version): only the ~505 cells
  that contain pollen sites, March only. Kept for reference; not to be
  developed further (decision of 2026-09-17).

A switch between the two through a config file is planned; today each
script chooses by a `run_interp` flag that tests for the interp input
files, and the non-interp month is set by the `CAL_MONTH` environment
variable.

## Scripts (`scripts/`)

| Script | Does | Reads | Writes |
|---|---|---|---|
| `1_veg_lct_prep.R` | taxon fractions -> ET/ST/OL per cell and slice; projection, elevation, clipping; modern (age 50) vs paleo split | `veg_posts_interp_ice.RDS` (interp) or `veg_pred_LGM_8.0.RDS` (non-interp, not in repo); `grid.RDS`; taxon table | `lct_modern_reveals[_interp].RDS`, `lct_paleo_reveals[_interp].RDS` |
| `2_calibration_lct_bluesky.R` | monthly blue-sky albedo at modern cells, native and 1-degree mean | blue-sky GeoTIFF, `lct_modern_reveals*.RDS`, map polygons | `calibration_modern_lct[_interp]_bluesky[_coarse].RDS`, albedo maps |
| `3_plot_cal_lct_albedo.R` | diagnostic plots of the calibration data (side branch) | calibration tables | figures |
| `4_calibration_model.R` | model ladder mod1-mod8 per month | calibration table | `output/calibration/calibration_mod*_interp_<month>_bluesky.RDS` (interp) or `data/calibration_mod*_bluesky.RDS` (non-interp) |
| `5_calibration_eval.R` | fit diagnostics; saves model 8 as selected | model fits | `..._selected_<month>_bluesky.RDS`, figures |
| `6_prediction_model.R` | hindcast albedo per slice with 100 draws | selected models, paleo cover | `output/prediction/paleo_interp_predict_gam*_bluesky.RDS` |
| `6_prediction_model_spatial_eval.R` | sensitivity of hindcasts to model structure (side branch) | spatial-experiment fits | figures |
| `7_plot_preds.R` | albedo, uncertainty and difference maps with ice overlays | predictions, ice shapefiles, glacier albedo table | figures, `ice_fort*.RDS` |
| `7a_alb_diff_full.R` | slice-to-slice albedo differences split into vegetation and ice parts | predictions, Dalton ice raster, glacier albedo table | `ALB_diffs_bluesky.RDS` |
| `8_radiative.R` | forcing = albedo change x kernel, three kernels | `ALB_diffs`, kernel NetCDFs | `output/forcing/RF_holocene_all_cases.RDS` |
| `GCM_snow_prob.R`, `thornthwaite.R`, `beta_veg_lct_modern.R`, `scripts/archive/` | abandoned climate/snow branch and earlier versions | | |

Run order is 1 -> 2 -> 4 -> 5 -> 6 -> 7 -> 7a -> 8; 3 and 6-spatial-eval
are optional. Measured runtimes on this machine (8 cores): script 4 about
80 minutes for one month's ladder on ~500 cells; scripts 2 and 7 a few
minutes; the rest seconds. The interp ladder is 12 months at larger basis
sizes on ~2,900 cells and has not yet been timed.

## Data assets (`data/`)

Roles: **input** (external, cannot be rebuilt here), **derived** (written
by a script from inputs), **result**, **legacy** (read by no current
script). A full datasheet is planned; provenance marked "unknown" needs
confirming with Andria.

### Inputs
| File | What | Provenance | Notes |
|---|---|---|---|
| `veg_posts_interp_ice.RDS` (334 MB, Git LFS) | interpolated land-cover posteriors: 2,870 cells x 25 slices x 200 draws x 3 classes, with `cell_area` and `ice` | Andria, 2026-09-17; REVEALS + Bayesian interpolation, Climate of the Past paper | root input of the interp flavour |
| `blue_sky_monthly_2000-2009.tif` | 12-band monthly blue-sky albedo, 0.25 degree, 2000-2009 mean | built from MODIS MCD43A3 v061 + ERA5 (manuscript §2.1); code not in repo | response variable |
| `grid.RDS` | 1-degree lon/lat raster with cell ids | unknown (committed 2023-05-16) | |
| `taxon2LCT_translation_v2.0.csv` | pollen taxon -> ET/ST/OL/NA | unknown | script 1 reads `_v2.csv` (name mismatch) |
| `map-data/geographic/pbs*.RDS`, `PoliticalBoundaries/` | political boundaries, lon/lat and projected | unknown | includes ocean polygons |
| `map-data/ice/glacier_shapefiles_21-1k.RDS` | 21 ice-margin polygon sets, 21 to 1 ka | Andria, 2026-09-17 | overlays and ice status in script 7 |
| *(missing)* `Dalton_QSR_2020_Ice/dalton_interpolated_LC6k.tif` | ice fraction per slice | Dalton et al. 2020, interpolation unknown | needed by 7a |
| *(missing)* `albedo_glacier_monthly.csv` | monthly glacier albedo | unknown | needed by 7 and 7a |
| *(missing)* `radiative-kernels/` (HadGEM3, CAM5, CACKv1.0) | albedo radiative kernels | public datasets; preprocessing unknown | needed by 8 |

### Derived and results present in the repo (non-interp flavour, March)
`lct_modern_reveals.RDS` (site-level, cover in percent; superseded by the
age-50 slice of `lct_paleo_reveals.RDS`, see known issues #29),
`lct_paleo_reveals.RDS`, `calibration_modern_lct_bluesky.RDS`,
`calibration_mod1..7_bluesky.RDS`, `paleo_predict_gam_bluesky.RDS`,
`paleo_predict_gam_summary_bluesky.RDS`, `preds_alb_diffs_sub_bluesky.RDS`.
No interp-flavour derived files or results are committed yet.

### Legacy (read by no current script)
`calibration_mod*_albclim.RDS`, `calibration_model*.RDS`, `cal_data.RDS`,
`calibration-albedo-climate*.RDS`, `lct_albedo_snow_modern_*.RDS`,
`lct_paleo.RDS`, `pollen-modern-slice_v2.0.RDS`, `*_CRU.csv`, `*_GCM.csv`,
`climate_CRU.csv`. Candidates for removal once confirmed.

Large files: anything over 50 MB is tracked with Git LFS; install
`git-lfs` before cloning or you will get pointer files.

## Environment

R 4.4 with `mgcv`, `terra`, `raster`, `sp`, `sf`, `dplyr`, `tidyr`,
`reshape2`, `ggplot2`, `gratia`, `tidyterra`, `scico`, `ggtern`,
`tricolore`, `scatterpie`, `fields`, `brms`, `elevatr` (needs network).
On the development machine there is no system R; a user-space
environment is used:

```
micromamba create -n paleo-rf -c conda-forge r-base=4.4 r-terra r-raster r-sp r-sf \
  r-dplyr r-tidyr r-ggplot2 r-reshape2 r-mgcv r-gam r-scales r-ggally r-rastervis \
  r-scico r-scatterpie r-ggtern r-brms r-fields r-units r-ggbreak r-ncdf4 r-maps r-geosphere
micromamba run -n paleo-rf Rscript -e 'install.packages(c("gratia","tidyterra","elevatr","tricolore"))'
```

Run scripts from the repository root, e.g.
`micromamba run -n paleo-rf Rscript scripts/4_calibration_model.R`. Cap
BLAS threads (`OPENBLAS_NUM_THREADS=8`) or the fits will oversubscribe
the machine. A package lockfile (`renv`) is planned.

## Working practices

See `CONTRIBUTING.md` (branches, commits, merges, where generated
material lives) and `AGENTS.md` (notes for AI-assisted sessions).
Branches: `main` (upstream), `legacy` (frozen copy of the code as
received), `chris-dev` (working trunk), topic branches off it.

## Documents (`docs/cc/`)

- `2026-09-16_code_map_original_scripts.md`: what every script does, in detail.
- `2026-09-16_known_issues_missing_data_and_code.md`: defects, missing data, missing code.
- `2026-09-17_manuscript_and_talk_outline.md`: structure of the draft paper and the EGU talk.
- `2026-09-17_methodology_questions_newcomer_review.md`: 58 fundamental questions about the method.
- `2026-09-17_methodology_schematic.*`: the full flowchart; `2026-09-17_nointerp_pipeline_diagram.*`: the March run.
- `2026-09-18_code_review_original_code.md` and `2026-09-18_staged_plan_development_to_package.md`.
- `questions_for_andria_general.md`, `questions_for_andria_scientific.md`: living lists of open questions.
