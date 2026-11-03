*Astra (gpt-6-astra, ultra effort, web search), 3 November 2026, for Chris: are there useful methods or ideas in the scripts outside the pipeline, and what would deleting them lose? Brief: as asked by Chris; issue #26. Links are relative to the repository root.*

# Review for Chris: scripts outside the pipeline

## Summary

- **Archive all 18 scripts unchanged. None needs to remain in the active pipeline.**
- The most useful idea is testing whether location changes the inferred vegetation effect; a better diagnostic already exists.
- The old snow branch supplies neither a validated snow-cover fraction nor the proposed snowy/snow-free albedo mixture.
- The identified CCSM3 climate dataset could support future work on changing Holocene snow, but that would require substantial new scientific work.
- The raw-pollen scripts are historical predecessors, not alternatives to REVEALS.
- All 18 files match `legacy`; deleting their working copies would lose discoverability, not recoverable code.
- Git does not guarantee preservation of missing raw inputs, untracked figures or the inputs used for earlier results.
- Use one root-level `archive/` folder and a short README recording purpose, provenance, known limitations and replacements.

Reviewed `feature/single-config` at `c4f65b8`. The scientific questions dated 20 October were read from local `chris-dev`, because that file is absent from this checkout. No files were changed.

## 1. Model-structure sensitivity: `6_prediction_model_spatial_eval.R`

**Purpose and files.** The [script](scripts/6_prediction_model_spatial_eval.R:23) reads the interpolated paleo-cover table and seven saved models combining location, elevation and land cover. It writes deterministic predictions, 20 simulated responses per row, and simulation summaries; then compares absolute albedo between models using scatterplots and selected February maps. Relevant lines: inputs and predictions 23–117; simulations and outputs 119–217; comparisons 228–305.

**Useful idea and scientific basis.** This addresses a serious current question: does the location term change the inferred effect of replacing evergreen with summergreen vegetation? Spatial effects and spatially patterned predictors can compete to explain the same observations. [Paciorek (2010)](https://doi.org/10.1214/10-STS326) establishes that problem, but does not establish that removing location produces the correct vegetation effect.

Much of the useful work already exists. The [current northeastern diagnostic](tools/plotting/plot_northeast_cover_and_location.R:61) checks that models use identical observations, compares the actual 6–4.5 ka change, and examines constrained evergreen-to-summergreen replacement and extrapolation (lines 61–73, 114–144). The newer scientific questions report an earlier May result changing from −0.095 to +0.042 albedo without location. That result needs reassessment with the rebuilt calibration; it is not evidence about a completed new refit.

**What using it would require and add.** Extend that maintained diagnostic to the months and regions contributing materially to forcing, using matching fits and the existing differencing and kernel calculations. This could add substantially to the paper’s interpretation. The seven model formulas already survive in [the model registry](R/model_registry.R:35).

Use deterministic predictions for this comparison. The old script instead compares means of only 20 simulated responses, adding unnecessary random variation. Models containing only fixed location and elevation should predict no vegetation-driven change through time at a given cell.

This is sensitivity analysis, not independent validation. Spatially blocked validation is a separate, already proposed task, supported by [Roberts et al. (2017)](https://doi.org/10.1111/ecog.02881).

**Deletion would lose; recommendation.** It would obscure the original experiment’s filenames, settings and plots, but lose no unique model formula. The dependencies, undefined `values` around line 278, obsolete tail from line 326, and unconfigured paths make repairing it unattractive. **Archive the original; retain and selectively extend the maintained diagnostic.**

## 2. ABoVE albedo and snow extraction

Files: `archive_2_monthly_ABOVE.R` and `3_snow_probability.R`.

**Purpose and files.** The [ABoVE script](scripts/archive/archive_2_monthly_ABOVE.R:4) samples custom monthly albedo rasters at modern pollen locations, divides albedo by 1,000, and fills missing values from progressively larger buffers: 25, 50, 100, 250 and 375 km. It writes `lct_albedo_modern.RDS`, then adds monthly snow values and writes `lct_albedo_snow_modern.RDS` (lines 4–81, 95–175).

The [snow-probability script](scripts/archive/3_snow_probability.R:8) duplicates the snow-extraction block: `snow-month-%02d.tif` becomes columns `psnow01`–`psnow12` (lines 8–88).

**Useful idea and scientific basis.** Checking whether albedo follows observed snow seasonality is relevant. These scripts do not establish what their “snow probability” measures, however, and do not separate snowy and snow-free albedo.

The published ABoVE daily blue-sky dataset is documented by [Solvik et al. (2019)](https://doi.org/10.3334/ORNLDAAC/1605). **The custom monthly filenames here cannot be confidently attributed to that dataset.** Their source version, years and aggregation remain unknown.

For the current question, the relevant precedent is monthly mixing of snowy and snow-free albedo using independently measured snow cover: [Barnes and Roy (2010), equation 3](https://doi.org/10.1029/2010JG001428), and [Ghimire et al. (2014), equation 1](https://doi.org/10.1002/2014GL061671). Those papers support the mixture, not these extraction and filling rules or the particular GAM implementation. Chris’s MOD10CM decision is already recorded in the [reference-audit summary, lines 16–24](docs/cc/2026-10-29_refit_references_audit_summary.md:16).

**What using them would require and add.** Recover the raster metadata and construction first. Direct snow extractions are unscaled, whereas buffered replacements are divided by 1,000 (`3_snow_probability.R`:16 versus 25–77). One convention must be wrong unless different transformations were intended and omitted. Filling across 375 km also replaces local conditions with potentially different climates and vegetation.

A properly matched second-product comparison might provide modest reassurance if current northern results remain problematic. Recovering this branch offers little immediate benefit over the agreed MOD10CM work.

**Deletion would lose; recommendation.** Preserve the custom paths, projection, scaling, filling distances and unresolved source identity. The snow algorithm is duplicated, so neither file contains an otherwise unique method. **Archive both.**

## 3. GlobAlbedo extraction and product comparison

Files: `archive_2_monthly_GLOBALB.R` and `archive_2a_plot_albedo_product.R`.

**Purpose and files.** The [extractor](scripts/archive/archive_2_monthly_GLOBALB.R:20) reads point-based modern REVEALS locations and extracts monthly **2004** `BHR_SW` and `Snow_Fraction` from `GlobAlbedo.merge.albedo.005.2004%02d.nc`. It writes `lct_albedo_snow_modern_glob.RDS` (lines 20–55). `BHR_SW` is shortwave white-sky albedo.

The [comparison script](scripts/archive/archive_2a_plot_albedo_product.R:5) plots a May ABoVE–GlobAlbedo comparison and a March 2004 map. Its GlobAlbedo input name, `lct_albedo_modern_glob.RDS`, differs from the extractor’s output. Map gaps are filled within 180 km and out-of-range values are clipped before saving figures (lines 5–12, 36–48, 75–76, 120–121).

**Useful idea and scientific basis.** Product sensitivity can be informative, especially for the **forest–open-land albedo contrast** driving forcing. [Lejeune et al. (2020), section 2.1.1](https://doi.org/10.5194/esd-11-1209-2020), provide a relevant example: they use a multi-year GlobAlbedo climatology and compatible illumination and spatial aggregation.

A single white-sky year is not directly comparable to the project’s decade-long blue-sky target. Agreement in mean albedo would also not establish agreement in the vegetation contrast.

**What using them would require and add.** Recover the raw products and match years, illumination, land masks, quality and spatial support. A focused comparison could add moderate confidence if winter vegetation contrasts remain decisive; it ranks below completing the existing snow analysis.

**Deletion would lose; recommendation.** Preserve the 2004 selection, exact variables, filenames and plotting transformations. The public product is already discussed in current literature notes; these particular processing choices are the additional historical information. **Archive both; rebuild only a focused comparison if a current result warrants it.**

## 4. Paleo-climate extraction: `GCM_snow_prob.R`

**Purpose and files.** Despite its name, the [script](scripts/GCM_snow_prob.R:8) computes no snow probability. It extracts maximum and minimum temperature, precipitation and growing degree days from CCSM3 files at paleo-cover locations, with 350-km buffer replacement for missing values. Outputs are `tmax_GCM.csv`, `tmin_GCM.csv`, `ppt_GCM.csv` and `gdd_GCM.csv` (lines 8–44, 122–203, 212–215).

**Useful source identified.** The exact NetCDF filenames occur in [Lorenz et al. (2016), Table 1](https://doi.org/10.1038/sdata.2016.48), and their [Dryad deposit](https://doi.org/10.5061/dryad.1597g):

- `ccsm3_22-0k_temp.nc`
- `ccsm3_22-0k_prcp.nc`
- `ccsm3_22-0k_gdd.nc`

These provide downscaled climate at 0.5° resolution, with decadal means for individual calendar months. The script’s explanation of decade zero and 1950 also matches the paper. This specific source attribution was not found elsewhere in the current repository documentation.

**What using it would require and add.** Published transient climate could eventually help investigate changing Holocene snow. These are climate drivers, however, not snow-cover observations. Reuse would require verified time coordinates, appropriate spatial aggregation, a justified snow model and modern validation. That is substantial scientific development; it adds little to the immediate modern-snow sensitivity analysis.

**Historical mismatch.** The three committed temperature/precipitation tables contain `year = 1…10`. They originate with April 2022 commit `dbae71e`, whose script saved the selected-slice index. The current script instead writes physical ages at lines 140, 160 and 180. Therefore the committed tables are **not outputs of the current recipe**, and their `year` column must not be read as years BP.

**Deletion would lose; recommendation.** Preserve the identified dataset, its time convention, the two code generations and the old tables’ index meaning. **Archive; rebuild extraction only if changing paleo-snow becomes an agreed analysis.**

## 5. Thornthwaite water budget and snow experiments

Files: `thornthwaite.R`, `4_thorn_modern.R`, `4b_thorn_modern.R`, `8_thorn_paleo.R`, `5_plot_thorn.R`.

**Purpose and files.**

- [thornthwaite.R](scripts/thornthwaite.R:99) adapts a ClimClass routine for monthly evapotranspiration, soil-water balance and snow water equivalent. It contains local cold-weather modifications and prescribed melt fractions (lines 99–208).
- [4_thorn_modern.R](scripts/archive/4_thorn_modern.R:21) reads temperature/precipitation CSVs and the GlobAlbedo site table, restricts climate to 2000–2017, and uses a 0°C threshold with melt fractions `(0.5, 0.25, 0.25)` (lines 21–57).
- [4b_thorn_modern.R](scripts/archive/4b_thorn_modern.R:54) changes these to 1°C and `(0.3, 0.4, 0.3)`. Both modern drivers write `climate_CRU.csv` and overwrite the same `thorn_output_glob_sm1.RDS` (lines 38, 139).
- [8_thorn_paleo.R](scripts/archive/8_thorn_paleo.R:22) applies the latter settings to the GCM tables and writes `thorn_output_paleo.RDS` (lines 22–98, 149).
- [5_plot_thorn.R](scripts/archive/5_plot_thorn.R:3) compares two supposed variants with satellite snow and albedo, writing `calibration-albedo-climate.RDS` and displaying scatterplots (lines 3–45, 54–133). It expects an `sm2` file neither current driver writes.

**Scientific basis and limits.** Thornthwaite–Mather water accounting is established practice. The [official ClimClass manual](https://cran.r-project.org/web/packages/ClimClass/ClimClass.pdf) documents snow water equivalent, temperature thresholds and prescribed melt fractions; the script retains the original authors and references at lines 26–64.

That precedent does **not** justify converting snow water equivalent ≥75 mm into snow-covered area. All three drivers make that binary conversion. Averaging it across years measures the frequency of exceeding a modeled threshold, not fractional area or daily snow duration. No justification for 75 mm or validation across North America was found. Changing the temperature threshold and melt schedule together also prevents attributing differences to either choice.

The paleo calculation has a deeper problem. The helper expects consecutive years and carries snow between them (`thornthwaite.R`:124–137, 208). The committed GCM tables make widely separated climate slices look consecutive; regenerated tables would leave most intervening years absent. Neither represents a defensible transient snow history.

**What using it would require and add.** Snow persistence and melt timing matter, but recovering a water-budget model does not directly answer the project’s albedo question. A valid revival would require new model justification, calibration, temporal treatment and conversion to snow cover. The current observed-snow approach offers much more direct value.

**Deletion would lose; recommendation.** Preserve the ClimClass attribution, local changes, parameter values, 75-mm rule and conflicting output names. These may explain earlier exploratory figures. **Archive the group; do not maintain the copied helper or rebuild this branch now.**

## 6. ClimateNA preparation, merges and plots

Files: `4a_run_climateNA.R`, `4c_merge_climate.R`, `5_plot_clim.R`.

**Purpose and files.** [4a_run_climateNA.R](scripts/archive/4a_run_climateNA.R:32) prepares `climateNA_input.csv`, assigning site identifiers by row, reversing longitude sign and taking elevation from column five. It does **not** execute ClimateNA. It reads externally generated output and reshapes temperature, precipitation, snowfall, frost-free days and degree days into `*_CRU.csv` files (lines 32–41, 64–175).

[4c_merge_climate.R](scripts/archive/4c_merge_climate.R:23) restricts these to 2000–2017 and writes monthly and seasonal climate tables. [5_plot_clim.R](scripts/archive/5_plot_clim.R:3) summarizes them, joins GlobAlbedo observations, writes two `calibration-albedo-climateNA*.RDS` tables and explores bivariate relationships (lines 3–51, 59–292).

**Useful idea and scientific basis.** ClimateNA’s downscaling and derived variables have published support in [Wang et al. (2016)](https://doi.org/10.1371/journal.pone.0156720). Its precipitation-as-snow variable measures estimated snowfall, not snow-covered fraction. It cannot directly replace MOD10CM in an albedo mixture.

Checking contemporary albedo against snow seasonality could be useful with the current products. Adding climate predictors would require a separate scientific argument and defensible Holocene values.

**Implementation and provenance problems.** Monthly frost-free-day records are labelled `season` (`4a`:113–120), then joined to monthly climate on site/year alone (`4c`:57). That creates multiple matches and loses the intended monthly correspondence.

The retained files also represent different generations: temperature and precipitation CSVs span 1901–2019, whereas the active input filename in `4a`:66 says 2000–2019. Committed `climate_CRU.csv` contains only precipitation and temperature fields, not the additional variables written by `4c`:61–64.

**Deletion would lose; recommendation.** Preserve the manual ClimateNA step, site-coordinate transformations, periods and median summaries. In particular, `*_CRU.csv` is not sufficient evidence that these are direct CRU observations. Recovering the absent raw outputs and software settings would be necessary for reproduction. **Archive all three; their additional value to the current paper is low.**

## 7. Early modern pollen: `1_pollen_modern.R` and `beta_veg_lct_modern.R`

**Purpose and files.** [1_pollen_modern.R](scripts/archive/1_pollen_modern.R:9) pools modern pollen counts by site, selects North American locations, removes taxa with total counts ≤40, translates retained taxa into land-cover classes, normalizes counts and queries point elevation. Outputs include `pollen-modern-proportions.RDS`, `LCT_table.RDS`, `pollen_modern_pivot.RDS` and `lct_modern.RDS` (lines 9–96, 116–149, 151–178).

The [beta script](scripts/beta_veg_lct_modern.R:9) is an earlier near-duplicate, restricted to Canada and Alaska. It also reads `veg_lct_binned_v8.0.csv` without using it (lines 9–13, 47–53).

**Useful idea and scientific basis.** These are descriptive pollen proportions. They do not correct for differences in pollen production, dispersal or basin characteristics. Those corrections are central to REVEALS: [Sugita (2007)](https://doi.org/10.1177/0959683607075837) and the project’s own [Dawson et al. (2025), section 2.2](https://doi.org/10.5194/cp-21-2031-2025).

The taxon-to-class mapping remains relevant to the shrub/tree question, but these scripts contain no solution to it. Any change should be traced through the upstream reconstruction, rather than substituting raw pollen proportions.

**Deletion would lose; recommendation.** Preserve the count filter, geographical selection, normalization after exclusions, translation-table version and elevation lookup as historical provenance. They do not document the current land-cover product’s construction. **Archive both; no rebuild warranted.**

## 8. Pollen through time: `7_pollen_time.R`

**Purpose and files.** The [script](scripts/archive/7_pollen_time.R:11) reads `pollen-sites-times-series-all_v2.0.RDS`, applies geographical and taxon filters, pools counts into 2,000-year bins from 0 to 20 ka, and normalizes land-cover-class counts. It writes `lct_paleo.RDS`, adds elevation and site identifiers, and exports `climateNA_input_paleo.csv` (lines 11–65, 97–152, 155–201).

**Useful idea and scientific basis.** Count aggregation is a legitimate description of the input pollen, but it is not quantitative vegetation reconstruction for the reasons above. The coarse binning neither represents the current time slices nor propagates age uncertainty.

Recovering the raw data could help explain an old figure or investigate sample selection. Rebuilding this workflow would add little to current forcing analysis.

**Deletion would lose; recommendation.** Preserve the 2,000-year bin edges, pooling and exclusion rules, site identifiers and ClimateNA export convention. The raw time-series input is missing from this checkout. **Archive.**

## 9. Old prediction plots: `8_plot_preds.R`

**Purpose and files.** The [script](scripts/archive/8_plot_preds.R:10) reads `lct_paleo_preds.RDS`, immediately replaces it with `cal_data.RDS`, assigns predictions to grid cells, plots selected ages, and writes `preds_alb_diffs_all.RDS` and `preds_alb_diffs_sub.RDS` (lines 10–11, 107–118, 214–218, 286–296).

**Useful idea.** Mapping changes and inspecting latitude patterns are sensible descriptive checks, already covered by scripts 7, 7a and 10. No distinctive scientific method needs rescuing.

**Historical significance.** The two difference products have opposite signs: all-age differences are older minus younger, while coarse differences are negated to younger minus older. The purported grid aggregation also retains original coordinates in its grouping.

There is a documentation discrepancy: [README_nointerp.md:55](docs/cc/README_nointerp.md:55) attributes `preds_alb_diffs_sub_bluesky.RDS` to this script, but line 296 writes the name **without** `_bluesky`. That attribution is not an exact reproduction recipe.

**Deletion would lose; recommendation.** Preserve the input ambiguity, difference signs, age selections and filename discrepancy for interpreting earlier results. **Archive; do not rebuild.**

## What to document before archiving

These are documentation recommendations, not edits made during this review.

1. **The newly identified GCM source:** Lorenz paper, Dryad DOI, exact filenames, units and decadal/monthly time convention. Record that committed GCM `year` values are old selection indices.
2. **Unidentified ABoVE inputs:** custom monthly filenames, unknown source/version/period, scaling discrepancy and 25–375 km filling. Do not assign a dataset citation without confirming the files.
3. **GlobAlbedo choices:** 2004 only, white-sky shortwave albedo, `Snow_Fraction`, missing raw files and the comparison script’s different input filename.
4. **ClimateNA lineage:** external manual execution, unrecorded version/settings, coordinate transformations, misleading `_CRU` names and the mismatch between committed tables and final generators.
5. **Water-budget provenance:** adapted ClimClass source, local cold-weather modifications, parameter values, 75-mm binary rule and colliding output names.
6. **Early pollen recipes:** raw count proportions, taxon exclusions, geographical domains and 2,000-year bins; distinguish these explicitly from REVEALS.
7. **Earlier-result uncertainties:** correct the old prediction-table attribution and record difference signs. Establish with Andria which retained figures or tables depended on these branches and whether their actual inputs and outputs survive.
8. **Replacement links:** point the old spatial experiment to the maintained northeastern diagnostic, and the snow branch to the agreed MOD10CM analysis.

The existing historical data inventory can hold the provenance details. Questions about unidentified inputs and earlier figures belong in the living general questions; unresolved scientific choices belong in the scientific questions.

## Simple archive arrangement

Move the 18 files unchanged into one root-level `archive/` directory. Add `archive/README.md` with a compact table: original path, purpose, main inputs/outputs, why retired, and current replacement where one exists.

Record the pre-move commit and `legacy` as recovery points. State that the archived scripts retain historical paths and are not a runnable alternative pipeline. Keep `scripts/make_grid.R` where it is.

Archiving scripts should be separate from any decision about historical data or figures. Neither deletion nor moving code establishes that those assets are expendable.

## References

- **Barnes, C. A., and Roy, D. P. (2010).** Radiative forcing over the conterminous United States due to contemporary land cover land use change and sensitivity to snow and interannual albedo variability. *Journal of Geophysical Research*, **115**, G04033. DOI: [10.1029/2010JG001428](https://doi.org/10.1029/2010JG001428). Sections 2 and 3.1 support separate snow observations and monthly albedo mixing.
- **Ghimire, B., et al. (2014).** Global albedo change and radiative cooling from anthropogenic land cover change, 1700 to 2005 based on MODIS, land use harmonization, radiative kernels, and reanalysis. *Geophysical Research Letters*, **41**, 9087–9096. DOI: [10.1002/2014GL061671](https://doi.org/10.1002/2014GL061671). Section 2.3 supports snow-state mixing and explicitly retains a stationary modern snow climatology.
- **Paciorek, C. J. (2010).** The importance of scale for spatial-confounding bias and precision of spatial regression estimators. *Statistical Science*, **25**, 107–125. DOI: [10.1214/10-STS326](https://doi.org/10.1214/10-STS326).
- **Roberts, D. R., et al. (2017).** Cross-validation strategies for data with temporal, spatial, hierarchical, or phylogenetic structure. *Ecography*, **40**, 913–929. DOI: [10.1111/ecog.02881](https://doi.org/10.1111/ecog.02881).
- **Lorenz, D. J., et al. (2016).** Downscaled and debiased climate simulations for North America from 21,000 years ago to 2100AD. *Scientific Data*, **3**, 160048. DOI: [10.1038/sdata.2016.48](https://doi.org/10.1038/sdata.2016.48). Data: [10.5061/dryad.1597g](https://doi.org/10.5061/dryad.1597g).
- **Wang, T., Hamann, A., Spittlehouse, D., and Carroll, C. (2016).** Locally Downscaled and Spatially Customizable Climate Data for Historical and Future Periods for North America. *PLOS ONE*, **11**, e0156720. DOI: [10.1371/journal.pone.0156720](https://doi.org/10.1371/journal.pone.0156720).
- **Lejeune, Q., et al. (2020).** Biases in the albedo sensitivity to deforestation in CMIP5 models and their impacts on the associated historical radiative forcing. *Earth System Dynamics*, **11**, 1209–1232. DOI: [10.5194/esd-11-1209-2020](https://doi.org/10.5194/esd-11-1209-2020).
- **Solvik, K. K., et al. (2019).** ABoVE: MODIS-Derived Daily Mean Blue Sky Albedo for Northern North America, 2000–2017. ORNL DAAC. DOI: [10.3334/ORNLDAAC/1605](https://doi.org/10.3334/ORNLDAAC/1605). A possible related product, not confirmed provenance for the custom rasters.
- **Sugita, S. (2007).** Theory of quantitative reconstruction of vegetation I: pollen from large sites REVEALS regional vegetation composition. *The Holocene*, **17**, 229–241. DOI: [10.1177/0959683607075837](https://doi.org/10.1177/0959683607075837).
- **Dawson, A., et al. (2025).** Holocene land cover change in North America: continental trends, regional drivers, and implications for vegetation–atmosphere feedbacks. *Climate of the Past*, **21**, 2031–2060. DOI: [10.5194/cp-21-2031-2025](https://doi.org/10.5194/cp-21-2031-2025).
- **Thornthwaite, C. W. (1948).** An Approach toward a Rational Classification of Climate. *Geographical Review*, **38**, 55–94. DOI: [10.2307/210739](https://doi.org/10.2307/210739).
- **Thornthwaite, C. W., and Mather, J. R. (1955; 1957).** *The water balance*; *Instructions and tables for computing potential evapotranspiration and the water balance*. *Publications in Climatology*, **8**(1), **10**(3). No DOI established. The implementation’s meaning was checked against the [official ClimClass manual](https://cran.r-project.org/web/packages/ClimClass/ClimClass.pdf); the original volumes were not read.

Verification was by source inspection, git history, selected CSV inspection and published passages, not execution of the archived analyses. A fresh paired reference-checker lookup failed because Crossref DNS resolution was unavailable; this report does not claim a new complete automated reference audit.