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

## Two flavours of the pipeline, and months

Two independent choices are involved, and the code as received couples
them:

- **Flavour** of the land-cover input. **interp** (the current analysis,
  used in the EGU talk and the draft paper): the spatially complete,
  ice-masked maps on the full grid; files carry `_interp` in their names.
  **non-interp** (the original point-based version): only the ~505 cells
  that contain pollen sites. Kept for reference; not to be developed
  further (decision of 2026-09-17).
- **Months** to calibrate and predict for: one month or all twelve. The
  calibration is a separate model per month; interpolation has nothing to
  do with the calendar.

In the scripts today the two are tied together: the interp code path
loops over all twelve months, and the non-interp code path fits a single
month (March as received; on `chris-dev` the month is chosen by the
`CAL_MONTH` environment variable, default May). Either flavour should be
runnable for one month or for all months; decoupling the two switches is
on the roadmap for the config-file stage
(`docs/cc/2026-09-18_staged_plan_development_to_package.md`). Until
then, each script selects the flavour by a `run_interp` flag that tests
for the interp input files.

## Scripts (`scripts/`)

**This table and the data tables below describe the interp flavour only.**
The equivalent tables for the non-interp flavour are in
`docs/README_nointerp.md`. Files are named as the scripts write them, with
`<month>` standing for `jan` ... `dec`. Line numbers (`script:line`) refer
to the scripts on `chris-dev` and give the statement that loads the file. Everything the pipeline writes goes
under `output/` except where a script still writes into `data/`.

| Script | Does | Reads | Writes |
|---|---|---|---|
| `1_veg_lct_prep.R` | mean over the 200 posterior draws; ET/ST/OL per cell and slice; elevation from AWS terrain tiles (`elevatr`, network); modern (age 50) vs paleo split | `data/veg_posts_interp_ice.RDS` | `data/lct_modern_reveals_interp.RDS`, `data/lct_paleo_reveals_interp.RDS` |
| `2_calibration_lct_bluesky.R` | monthly blue-sky albedo at the modern cells, native pixel and 1-degree mean | `data/blue_sky_monthly_2000-2009.tif`, `data/grid.RDS`, `data/lct_modern_reveals_interp.RDS`, `data/map-data/geographic/pbs*.RDS` | `data/calibration_modern_lct_interp_bluesky.RDS`, `..._coarse.RDS`, albedo maps in `figures/` |
| `3_plot_cal_lct_albedo.R` | diagnostic plots of the calibration data (optional side branch) | `data/calibration_modern_lct_interp_bluesky.RDS`, `scripts/make_grid.R` | figures |
| `4_calibration_model.R` | model ladder mod1-mod8 for every month; AIC table; spatial-effects experiment | `data/calibration_modern_lct_interp_bluesky.RDS` | `output/calibration/calibration_mod{1..8}_interp_<month>_bluesky.RDS`, `AIC_table.csv`, `calibration_mod_{spatial,elev,cover,...}_<month>.RDS` |
| `5_calibration_eval.R` | fit diagnostics; saves model 8 as the selected model per month | the model files above | `output/calibration/calibration_mod_interp_selected_<month>_bluesky.RDS`, `calibration_model_stats.csv`, figures |
| `6_prediction_model.R` | hindcast albedo per slice and month with 100 draws | selected models, `data/lct_paleo_reveals_interp.RDS` | `output/prediction/paleo_interp_predict_gam[_samps|_summary]_<month>_bluesky.RDS` and the merged `..._bluesky.RDS` files |
| `6_prediction_model_spatial_eval.R` | sensitivity of hindcasts to model structure (optional side branch) | spatial-experiment fits, `data/lct_paleo_reveals_interp.RDS` | `output/prediction/*spatial_eval*`, figures |
| `7_plot_preds.R` | albedo, uncertainty and difference maps with ice overlays | `output/prediction/paleo_interp_predict_gam[_summary]_bluesky.RDS`, `data/grid.RDS`, `data/map-data/ice/glacier_shapefiles_21-1k.RDS`, `data/albedo_glacier_monthly.csv`, `pbs*.RDS` | figures, `data/ice_fort*.RDS`, `data/alb_interp_preds_diffs_bluesky.RDS` |
| `7a_alb_diff_full.R` | slice-to-slice albedo differences split into vegetation and ice parts | `output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS`, `data/Dalton_QSR_2020_Ice/dalton_interpolated_LC6k.tif`, `data/albedo_glacier_monthly.csv`, `data/grid.RDS`, `pbs*.RDS` | `data/ALB_diffs_bluesky.RDS` |
| `8_radiative.R` | forcing = albedo change x kernel, three kernels | `data/ALB_diffs_bluesky.RDS`, `data/ice_fort*.RDS`, `data/radiative-kernels/*.nc`, `pbs*.RDS` | `output/forcing/RF_holocene_all_cases.RDS` |

Not part of the interp pipeline: `GCM_snow_prob.R`, `thornthwaite.R`,
`beta_veg_lct_modern.R` and `scripts/archive/` (abandoned climate/snow
branch and earlier versions).

Run order is 1 -> 2 -> 4 -> 5 -> 6 -> 7 -> 7a -> 8; 3 and 6-spatial-eval
are optional. Measured runtime so far: the non-interp version of script 4
took about 80 minutes for one month's ladder on ~500 cells with 8 cores.
The interp ladder (12 months, larger basis sizes, ~2,900 cells) has not
been timed yet.

## Data assets, interp flavour (`data/`, `output/`)

Legend: 🟧 **missing** = required by a script and not in the repository;
<mark>unknown</mark> = provenance not yet confirmed with Andria. Roles:
**input** (external, no script here produces it), **derived** (produced
by a numbered script), **result** (end product). Derived files and
results of the interp flavour do not exist yet because the interp
pipeline has not been run on this machine; they are listed so the
expected outputs are known.

### External inputs

| File | Role | What | Provenance | Status |
|---|---|---|---|---|
| `data/veg_posts_interp_ice.RDS` (334 MB, Git LFS) | input to 1 (`1:218`) | interpolated land-cover posteriors: 2,870 cells x 25 slices x 200 draws x 3 classes, with `cell_area` and `ice` | Andria, 2026-09-17; REVEALS + Bayesian spatial interpolation with ice mask, from the Climate of the Past land-cover paper | present |
| `data/blue_sky_monthly_2000-2009.tif` | input to 2 (`2:290`; non-interp half `2:95`) | 12-band monthly blue-sky albedo, 0.25 degree, 2000-2009 mean | MODIS MCD43A3 v061 + ERA5 as described in manuscript §2.1; <mark>unknown</mark> who built it and with what code | present |
| `data/grid.RDS` | input to 1, 2, 7, 7a (`1:34`, `2:39`, `7:254`, `7a:201`) | 1-degree lon/lat raster with cell ids (-172 to 127 E, 17 to 79 N) | <mark>unknown</mark> (committed 2023-05-16, no generating code) | present |
| `data/map-data/geographic/pbs.RDS`, `pbs_ll.RDS`, `PoliticalBoundaries/` | input to 2, 3, 6, 7, 7a, 8 (`2:36-37`, `3:39-40`, `6:283`, `7:24-26`, `7a:166-167`, `8:54-55`) | political boundaries, projected and lon/lat; includes ocean polygons | <mark>unknown</mark> | present |
| elevation (not a file) | input to 1 (`1:230`; non-interp half `1:96`) | point elevation at cell centres | fetched from AWS terrain tiles by `elevatr` at run time; values can differ between runs | network |
| `data/map-data/ice/glacier_shapefiles_21-1k.RDS` | input to 7 (`7:57`) | 21 ice-margin polygon sets, 21 to 1 ka | Andria, 2026-09-17; <mark>unknown</mark> original source of the margins | present |
| `data/albedo_glacier_monthly.csv` | input to 7, 7a (`7:273`, `7a:264`) | monthly albedo assigned to ice-covered cells | <mark>unknown</mark> | 🟧 **missing** |
| `data/Dalton_QSR_2020_Ice/dalton_interpolated_LC6k.tif` | input to 7a (`7a:84`) | ice fraction per cell and slice | Dalton et al. 2020, interpolated to the slices; <mark>unknown</mark> who did the interpolation | 🟧 **missing** |
| `data/radiative-kernels/HadGEM3-GA7.1_TOA_kernel_L19.nc` | input to 8 (`8:58`) | HadGEM3 albedo kernel, clear-sky, top of atmosphere, W/m² per 1% | Smith (2019), Zenodo doi:10.5281/zenodo.3594673, CC-BY-4.0 | downloaded 2026-09-19 (git-ignored; see `data/radiative-kernels/README.md`) |
| `data/radiative-kernels/CAM5/alb.kernel.nc` | input to 8 (`8:163`) | CAM5 albedo kernel; the script reads `FSNSC`, a **surface** flux | Pendergrass (2017), doi:10.5065/D6F47MT6, CC-BY-4.0 | downloaded 2026-09-19 (git-ignored) |
| `data/radiative-kernels/CACKv1.0/CACKv1.0.nc` | input to 8 (`8:197`) | CACK albedo kernel, band 3 | Bright and O'Halloran (2019), EDI doi:10.6073/pasta/d77b84b11be99ed4d5376d77fe0043d8 | 🟧 **missing**: the EDI portal is behind a human-verification check, so it needs a manual download |
| `scripts/make_grid.R` | sourced by 3 (`3:57`, `3:345`) | helper building a 2-degree grid for the diagnostic maps | original not in repo; the copy present is a reconstruction (2026-09-16) | present (reconstructed) |

### Derived files and results (produced by the scripts)

| File | Written by | Read by | Status |
|---|---|---|---|
| `data/lct_modern_reveals_interp.RDS`, `data/lct_paleo_reveals_interp.RDS` | 1 | 2 (`2:255`), 6 (`6:23`) | not yet produced |
| `data/calibration_modern_lct_interp_bluesky.RDS`, `..._coarse.RDS` | 2 | 3 (`3:323`), 4 (`4:27`), 5 (`5:25`) | not yet produced |
| `output/calibration/calibration_mod{1..8}_interp_<month>_bluesky.RDS`, `AIC_table.csv`, spatial-experiment fits | 4 | 4, 5, 6-spatial-eval | not yet produced |
| `output/calibration/calibration_mod_interp_selected_<month>_bluesky.RDS`, `calibration_model_stats.csv` | 5 | 6 (`6:43`) | not yet produced |
| `output/prediction/paleo_interp_predict_gam[_samps|_summary]_<month>_bluesky.RDS`; merged `paleo_interp_predict_gam_bluesky.RDS`, `..._summary_bluesky.RDS` | 6 | 7 (`7:112`), 7a (`7a:25`) | not yet produced |
| `data/ice_fort.RDS`, `ice_fort_diff_young.RDS`, `ice_fort_diff_old.RDS`, `data/alb_interp_preds_diffs_bluesky.RDS` | 7 | 8 (`8:25`; loaded but unused) | not yet produced |
| `data/ALB_diffs_bluesky.RDS` (result: albedo differences) | 7a | 8 (`8:76`) | not yet produced |
| `output/forcing/RF_holocene_all_cases.RDS` (result: forcing) | 8 | | not yet produced |

### Other files in `data/`

Everything else in `data/` belongs to the non-interp flavour (see
`docs/README_nointerp.md`) or to abandoned branches: the `_albclim`,
`calibration_model*`, `cal_data`, `calibration-albedo-climate*`,
`lct_albedo_snow_modern_*`, `lct_paleo.RDS`, `pollen-modern-slice`,
`*_CRU.csv`, `*_GCM.csv` and `climate_CRU.csv` files are read by no
current script and are candidates for removal once confirmed.

Large files: anything over 50 MB that exists nowhere else is tracked with
Git LFS; install `git-lfs` before cloning or you will get pointer files.
Published, citable datasets are git-ignored and fetched instead by
`bash scripts/download_kernels.sh` (see `data/radiative-kernels/README.md`),
which keeps the LFS quota for data that cannot be downloaded.

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
