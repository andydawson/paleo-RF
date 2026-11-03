# Archived scripts

Scripts from earlier stages of the analysis. The pipeline (`scripts/`, run in order 1-10) does not run
them and reads none of their outputs. They are kept here unchanged, as history: they still use their
original paths and inputs, several of which are no longer in the repository, so they do not run as
they stand. Moved here on 3 November 2026 (Chris, issue #26), after Astra's review of what they hold
(`docs/cc/2026-11-03_old_scripts_review_codex_gpt6astra.md`). Each is identical to its copy on the
`legacy` branch; the last commit before the move is `c4f65b8`.

| Script (former place) | What it did | Why it is not run; what replaces it |
|---|---|---|
| `1_pollen_modern.R` (`scripts/archive/`) | Modern pollen counts pooled by site, taxa with total counts of 40 or fewer dropped, translated to land-cover classes and normalised; point elevations | Raw pollen proportions, not corrected for pollen production and dispersal; replaced by the REVEALS land cover (Dawson et al. 2025) |
| `beta_veg_lct_modern.R` (`scripts/`) | An earlier near-copy of the above, for Canada and Alaska only | As above |
| `7_pollen_time.R` (`scripts/archive/`) | Pollen counts through time in 2,000-year bins (0-20 ka); export for ClimateNA | As above; the time slices are now REVEALS's |
| `archive_2_monthly_ABOVE.R`, `3_snow_probability.R` (`scripts/archive/`) | Monthly albedo and "snow probability" from custom rasters (files `snow-month-%02d.tif`) sampled at pollen sites; gaps filled from 25-375 km buffers | Source of the rasters unknown (possibly derived from Solvik et al. 2019, not confirmed); direct snow values unscaled but buffered ones divided by 1,000. Replaced by the rebuilt MODIS albedo (`tools/prepare_bluesky_albedo.R`); snow by the planned MOD10CM mixing |
| `archive_2_monthly_GLOBALB.R`, `archive_2a_plot_albedo_product.R` (`scripts/archive/`) | GlobAlbedo 2004 white-sky shortwave albedo (`BHR_SW`) and `Snow_Fraction` at pollen sites; a May comparison with the ABoVE albedo | One year of white-sky albedo, not comparable with the decade of blue-sky albedo used now. The comparison script reads `lct_albedo_modern_glob.RDS`, which the extractor does not write (it writes `lct_albedo_snow_modern_glob.RDS`) |
| `GCM_snow_prob.R` (`scripts/`) | Despite the name, no snow: monthly maximum and minimum temperature, precipitation and growing degree days from CCSM3 at the past cover cells, with 350 km gap filling | Climate is not used by the pipeline. Source: see below |
| `thornthwaite.R` (`scripts/`) | A locally modified copy of the Thornthwaite-Mather water balance from the ClimClass package, with snow water equivalent | ClimClass is no longer on CRAN; used only by the three scripts below |
| `4_thorn_modern.R`, `4b_thorn_modern.R`, `8_thorn_paleo.R`, `5_plot_thorn.R` (`scripts/archive/`) | Modern and past water balance; snow cover taken as snow water equivalent of 75 mm or more | The 75 mm rule has no published basis found; the past calculation treats widely separated time slices as consecutive years. Snow: the planned MOD10CM mixing |
| `4a_run_climateNA.R`, `4c_merge_climate.R`, `5_plot_clim.R` (`scripts/archive/`) | Input for ClimateNA (run by hand outside R) and its outputs reshaped, merged and plotted against GlobAlbedo | The `*_CRU.csv` names do not mean CRU observations; frost-free days are joined on site and year only, so months are mismatched |
| `8_plot_preds.R` (`scripts/archive/`) | Maps of an early version's predicted albedo change | Covered by scripts 7, 7a and 10. Its two difference tables have opposite signs (all ages older minus younger; coarse ones younger minus older), and it writes `preds_alb_diffs_sub.RDS` without the `_bluesky` that `docs/cc/README_nointerp.md` gives |
| `6_prediction_model_spatial_eval.R` (`scripts/`) | Predictions from seven models with and without location, to see whether location changes the vegetation effect | Does not run (needs SemiPar and pwiser; undefined `values` near line 278; reads files that no longer exist from line 326). The question is now answered by `tools/plotting/plot_northeast_cover_and_location.R`; the model formulas are in `R/model_registry.R` |

## Sources recorded nowhere else

- **CCSM3 climate** (`GCM_snow_prob.R`): the files `ccsm3_22-0k_temp.nc`, `ccsm3_22-0k_prcp.nc` and
  `ccsm3_22-0k_gdd.nc` are the downscaled, debiased CCSM3 simulations of Lorenz et al. (2016), *Scientific
  Data* 3, 160048, doi:10.1038/sdata.2016.48; data doi:10.5061/dryad.1597g. 0.5-degree grid, decadal means
  for each calendar month; decade zero is 1950. The committed tables `tmax_GCM.csv`, `tmin_GCM.csv` and
  `ppt_GCM.csv` come from an April 2022 version of the script (commit `dbae71e`): their `year` column
  (1-10) is the index of the selected slice, not years before present.
- **ClimateNA** (`4a`, `4c`, `5_plot_clim.R`): run by hand outside R; its version and settings were not
  recorded. The input reverses the sign of longitude and takes elevation from column five.
- **Water balance** (`thornthwaite.R` and its drivers): adapted from ClimClass, whose authors and
  references are kept in the script. The modern drivers use a 0 C threshold with melt fractions
  (0.5, 0.25, 0.25) (`4_thorn_modern.R`) and 1 C with (0.3, 0.4, 0.3) (`4b_thorn_modern.R`), and both
  write the same `thorn_output_glob_sm1.RDS`; `5_plot_thorn.R` expects an `sm2` file neither writes.

## References

- Dawson, A., et al. (2025). Holocene land cover change in North America. *Climate of the Past* 21, 2031-2060. doi:10.5194/cp-21-2031-2025
- Lorenz, D. J., et al. (2016). Downscaled and debiased climate simulations for North America from 21,000 years ago to 2100AD. *Scientific Data* 3, 160048. doi:10.1038/sdata.2016.48
- Solvik, K. K., et al. (2019). ABoVE: MODIS-derived daily mean blue sky albedo for northern North America, 2000-2017. ORNL DAAC. doi:10.3334/ORNLDAAC/1605
