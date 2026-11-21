*Astra (gpt-6-astra, ultra effort, web search), 3 November 2026, for Chris: design (only) of an independent local check of conifer versus deciduous albedo in the northeast. Brief: `2026-11-03_northeast_forest_albedo_design_brief.md`. Links are relative to the repository root.*

# Design for Chris: a local northeastern forest-albedo check

## Summary

- Estimate monthly deciduous-broadleaf minus evergreen-needleleaf albedo in nearby, comparable forests, separating satellite snow states.
- This would test the sign and provide a modern magnitude benchmark for the paper’s northeastern vegetation effect.
- The existing 500 m albedo is usable; no replacement albedo download is needed initially.
- Recommend MCD12Q1 forest type plus MOD44B percent tree cover for **2001–2009**, covering both countries.
- Forest-type downloads are approximately **0.35 GB**; canopy data need a confirmed transfer size, with about **6 GB** allowed for full-tile raster storage.
- Budget approximately **one working week** for implementation, checks, review and reporting, excluding acquisition delays.
- Treat this as a descriptive check beside the forcing: shared MODIS inputs, mixed forests and canopy-hidden snow limit its independence.
- Recommend approving the basic comparison first, with finer-resolution mapping considered after its coverage is known.

## 1. The comparison

### What it estimates

For each calendar month and snow category, estimate

\[
\Delta\alpha=\alpha_{\mathrm{deciduous\ broadleaf}}
             -\alpha_{\mathrm{evergreen\ needleleaf}}.
\]

Positive values mean that the deciduous forest is brighter. Report albedo in its native 0–1 units; a difference of 0.01 is one albedo percentage point.

The target population is **nearby forests of comparable tree cover and terrain within 80–66°W, 40–48°N**. This is a modern observational contrast, conditional on those restrictions. It is neither a direct observation of the hemlock decline nor the total consequence of replacing a forest, including changes in its structure.

### Published basis—and our adaptation

Duveiller et al. estimate vegetation contrasts using local regressions within moving windows, requiring local coexistence of the vegetation classes and screening unsuitable terrain. Their companion methods use approximately **25 km-wide windows**, constructed from 5 × 5 cells at 0.05°. They do not use five native 500 m pixels. This supports keeping comparisons local, but does not guarantee identical climate or soils. [Duveiller et al., 2018a](https://doi.org/10.1038/s41467-017-02810-8); [2018b](https://doi.org/10.1038/sdata.2018.14).

Lejeune et al. support comparing monthly vegetation-albedo contrasts separately under snowy and snow-free conditions. Their application concerns trees versus crops–grasses, and their snow-fraction thresholds cannot simply be transferred to our retrieval-day counts. [Lejeune et al., 2020, §§2.1.2 and 2.3.1](https://doi.org/10.5194/esd-11-1209-2020).

**Our adaptation would use matched forest pixels and direct differences**, avoiding a second fitted vegetation-response model. Matching and checking covariate balance before examining outcomes follow established observational-study practice. The particular regional tolerances below are judgements for Chris’s approval. [Stuart, 2010](https://doi.org/10.1214/09-STS313).

### Proposed matching rules

Use fixed, non-overlapping **25 × 25 km windows**, clipped to the northeastern box. Within each window, choose nearby opposite-class pixels without reusing pixels. A deterministic ordering makes the matches reproducible.

| Proposed rule | Purpose |
|---|---|
| Same forest label throughout 2001–2009; normal classified-land quality | Reduce uncertain class assignments |
| Centre pixel surrounded by the same class in its 3 × 3 neighbourhood | Reduce edges and obvious mixed footprints |
| Pair separation ≤5 km; latitude difference ≤0.02° | Prevent the regional north–south gradient from supplying the contrast |
| Elevation difference ≤50 m | Reduce elevation-related climate differences |
| Difference in percent tree cover ≤10 percentage points | Compare broadly similar canopy cover |
| Local elevation range ≤100 m within each pixel’s 3 × 3 GMTED neighbourhood | Restrict the first comparison to relatively gentle terrain |
| Exclude mapped water, shorelines and wetlands | Reduce dark-water and wetland contamination |

**These numerical rules are proposed settings, not published validated thresholds.** First inspect their coverage and balance without examining albedo differences. If they leave few suitable forests, report that limitation and revise the design explicitly before calculating the contrast.

Use the 2001–2009 median MOD44B tree cover to select fixed pairs; require the annual tree-cover difference also to satisfy the tolerance in contributing years. MOD44B supplies a **tree-cover proxy**, not a direct measurement of canopy closure, height or leaf area. Matching seasonal leaf area would risk removing part of the evergreen–deciduous mechanism itself.

### Calculation and reporting

For each matched pixel, year, month and snow category:

1. Divide the stored albedo sum by its corresponding count.
2. Require both pixels to have observations in that year–month–category. A proposed minimum is **five qualifying retrieval days per pixel**; this is a coverage rule, not five independent observations.
3. Subtract evergreen from deciduous albedo.
4. Average pairs within each window and year, then give contributing years equal weight and contributing windows equal weight.

This averaging order is **our descriptive aggregation choice**. It prevents forests with more pixels or clearer weather from dominating solely through their retrieval counts.

Report the mean contrast, the distribution of window contrasts, year-to-year variation, and counts of pairs, windows, years and retrieval days. The spread among windows is **heterogeneity, not a confidence interval**. Do not calculate pixel-based significance tests or treat adjacent windows as independent replicates.

Produce separate snow-free, snow-flagged and all-days panels. Show changing geographic coverage between panels: the snowy and snow-free results may involve different subsets of the fixed pairs.

Bright et al. provide precedent for combining snow-specific albedos using common snow-cover weights. However, our retrieval-day fractions are not independent measurements of ground snow cover. I recommend leaving the snow panels separate in the first version. Bright et al.’s principal result concerns temperature and non-radiative processes; it does not validate this matching estimator. [Bright et al., 2017, Methods equation 4](https://doi.org/10.1038/nclimate3250).

## 2. Data

### What is usable on disk

I inspected the monthly directory and the metadata and layers of `h12v04_2005_01.tif`.

| Existing input | Finding and use |
|---|---|
| Monthly albedo | **4,484 GeoTIFFs**, 38 tiles × 118 months, March 2000–December 2009; **192.3 GB decimal**, approximately 179 GiB |
| Northeastern subset | Tiles `h11v04`, `h12v04`, `h13v04`; their complete monthly files occupy approximately **25.35 GB** |
| Example raster | 2,400 × 2,400 pixels; sinusoidal projection; **463.313 m** grid spacing, conventionally called 500 m |
| Albedo layers | Four versions: `full_75`, `any_75`, `full_70`, `full_nocut`; each retains `n_all`, `n_snow`, `n_free`, `s_all`, `s_snow`, `s_free` |
| Other layers | `land_days`, `shore_days`, `read_days`: **27 bands altogether** |
| MOD44W | Existing **2015**, nominal 250 m water mask and quality layer |
| GMTED2010 | Existing **30-arc-second mean elevation**; useful for broad elevation and relief screening |
| Forest type | No MCD12Q1, MOD44B, NLCD, EOSD or other recognisable fine-resolution forest map found in the main project and this checkout’s data directories |

The [preparation script](tools/prepare_bluesky_albedo.R:1) records the processing choices: MCD43A3/A2 Collection 6.1, full inversions, noon zenith ≤75°, ERA5 diffuse fraction, and the record-wide majority-land rule.

Use **`full_75`** initially. The values are monthly averages of qualifying **local-noon blue-sky albedos**, not daily sunlight-weighted albedos. The MCD43 retrievals share observations across overlapping 16-day windows. [Wang et al., 2018](https://doi.org/10.1016/j.rse.2018.02.001).

The monthly files suffice for this first comparison. They cannot recover exact observation dates, within-month variances, or simultaneous snow conditions. Consequently, “matched month and year” must not be described as “matched observation day”. Unknown-snow counts and sums can be recovered by subtraction from the all-days totals; they must remain separate from snow-free observations.

### Recommended acquisitions

| Product | Resolution, period and role | Accuracy and class limitations | Access, licence and size |
|---|---|---|---|
| **MCD12Q1.061** | Nominal 500 m, annual from 2001. Use IGBP evergreen needleleaf **1** and deciduous broadleaf **4**; exclude mixed **5** initially. Same native grid as albedo. | No hemlock class. Dominant-type labels do not establish pure stands. The published **73.6% overall accuracy concerns the primary LCCS layer globally**, not northeastern IGBP or hemlock accuracy. | NASA open data; Earthdata login through Earthdata Search/LAADS. Three tiles × nine years: **about 0.35 GB**, estimated from listed 2001 tile sizes. [Dataset](https://doi.org/10.5067/MODIS/MCD12Q1.061); [method](https://doi.org/10.1016/j.rse.2018.12.013). |
| **MOD44B.061** | Nominal 250 m annual percent tree cover, with quality, cloud and uncertainty information. Aggregate aligned 250 m cells to each albedo cell. | Tree cover, not forest type, age or directly measured closure. Annual periods begin on day 65, so record their actual dates. | NASA unrestricted data; Earthdata login. **Compressed transfer size remains unverified.** Twenty-seven complete tiles contain approximately **5.60 GB of uncompressed raster values**; allow about 6 GB for that payload, with working space additional. [Dataset and documentation](https://doi.org/10.5067/MODIS/MOD44B.061). |

Before acquisition, replace these estimates with a named-file manifest and exact provider sizes. A regional, selected-layer subset could reduce storage substantially.

Require MCD12Q1’s normal classified-land quality; exclude climate-reassigned forest labels, identified by **quality value 9**. Also use its hydrological classification to screen woody wetlands. The guide warns that wetlands are underrepresented and annual classifications should not be used to infer land-cover change. Therefore, persistent labels are a confidence screen, **not evidence of undisturbed forest**. [Official guide](https://lpdaac.usgs.gov/documents/1409/MCD12_User_Guide_V61.pdf).

Use **2001–2009** as the primary period because MCD12Q1 begins in 2001. State the one-year difference from the fitted model’s albedo climatology.

### Alternatives worth retaining, without acquiring them initially

| Alternative | Advantages and limitations | Licence, acquisition and planning size |
|---|---|---|
| **NLCD land cover and tree canopy** | US-only, 30 m. Land cover for 2001/2006/2011; a 2001 canopy layer exists. Evergreen/deciduous classes require >75% respective foliage type, but neither identifies hemlock. Useful for measuring mixed and edge fractions within MODIS pixels. | Public US federal data through MRLC/USGS; historical canopy availability needs checking. Two byte layers covering the entire box would be approximately **2.22 GB uncompressed**, less after US clipping and compression. Exact transfer unknown. [Class definitions](https://www.mrlc.gov/data/legends/national-land-cover-database-class-legend-and-description); [accuracy study](https://doi.org/10.1016/j.rse.2010.01.018). |
| **Canadian EOSD circa 2000** | 25 m, contemporary with the albedo. Coniferous/broadleaf/mixedwood and closure classes. Dominance uses basal area, unlike NLCD’s foliage definition; coniferous can include deciduous larch. No checked northeastern hemlock accuracy. | Historical NRCan/NFIS distribution; current raster access and licence require confirmation. Full-box byte raster approximately **1.59 GB uncompressed**; Canadian subset smaller. Actual archive size unknown. [Method](https://doi.org/10.5589/m08-066). |
| **Land Cover of Canada 2010** | 30 m, imagery from 2009–2011. Accessible forest classes, but later than most albedo observations and not hemlock-specific. National overall accuracy **76.6%** does not establish local forest-type accuracy. | Open Government Licence–Canada; public GeoTIFF. Full-box byte layer approximately **1.11 GB uncompressed**; actual transfer unknown. [Government record](https://open.canada.ca/data/en/dataset/c688b87f-e85f-4842-b0e1-a8f79ebf1133); [method](https://doi.org/10.3390/rs9111098). |
| **USFS forest types/groups, circa 2004** | US-only, 250 m; detailed hemlock-related types exist. Local species accuracy is insufficiently reliable for an unvalidated hemlock selector, and climate/terrain predictors complicate independence. | Unrestricted USFS data; listed CONUS archives **170 MB for types**, **160 MB for groups**. [Downloads](https://data.fs.usda.gov/geodata/rastergateway/forest_type/index.php); [method](https://doi.org/10.14358/PERS.74.11.1379). |

The high-resolution sizes above are **planning calculations**, not download quotations. My first optional addition would be an NLCD purity check on the US portion, rather than immediately constructing a national-map mosaic across the border.

## 3. How it maps onto the model

### The classes are related, but unequal

Dawson et al.’s reconstruction represents evergreen trees **and shrubs**, summergreen trees **and shrubs**, and open vegetation. These are reconstructed vegetation fractions, not fractions of satellite pixels labelled as forest. [Dawson et al., 2025](https://doi.org/10.5194/cp-21-2031-2025).

The project’s [taxon translation](data/taxon2LCT_translation_v2.0.csv) places:

- **Tsuga**, pine, spruce and fir in ET.
- Maple, oak, birch and other broadleaved taxa in ST.
- **Larix**, a deciduous conifer, in ST.
- Several taxa containing shrubs in the tree/shrub categories.

Thus ENF is an analogue for part of ET, and DBF for part of ST. A mixed forest contains both; discarding mixed pixels selects particular modern stands. Tree-cover matching also selects a structural condition that may not describe the prehistoric replacement.

This mismatch chiefly limits **magnitude and historical attribution**. A local sign disagreement remains informative, but does not by itself prove that the historical model is wrong.

### Compare a defined exchange at fixed location

For each supported northeastern 1-degree cell, take its actual 6 ka reconstruction and define

\[
q_i=ET_{i,6\,ka}-ET_{i,4.5\,ka}.
\]

Calculate the fitted model’s response to moving exactly \(q_i\) from ET to ST:

\[
\Delta\widehat{\alpha}_{i,m}
=
\widehat{\alpha}_m(ET_i-q_i,\ ST_i+q_i,\ OL_i,\ x_i,y_i,z_i)
-
\widehat{\alpha}_m(ET_i,\ ST_i,\ OL_i,\ x_i,y_i,z_i).
\]

Keep location, elevation and open land fixed. Check that the constructed compositions are valid; do not silently clip them. Show the actual full 6–4.5 ka model change separately because its small open-land change is a different quantity.

The approximate regional exchange is 0.18, but use **cell-specific reconstructed values**, not rounded regional means.

Beside this, show the corresponding local forest contrast. An illustrative mixture benchmark is

\[
\Delta\alpha^{\mathrm{benchmark}}_{i,m}
\approx q_i\,\Delta\alpha^{\mathrm{local}}_{i,m}.
\]

Combining cover fractions with geographically appropriate class albedos has published precedent. Applying it here assumes that an ET-to-ST cover exchange can be represented by the matched forest-patch contrast; **that crosswalk is our approximation**, especially where canopy gaps and mixed stands matter. [Ghimire et al., 2014, §2.3](https://doi.org/10.1002/2014GL061671).

Calculate each local product before averaging. Compare model and benchmark over the **same supported locations and weights**. Show how much of the northeastern region lacks suitable contrasts; do not extrapolate the benchmark into those gaps.

Use the all-days contrast beside an all-days model. Snow-specific contrasts should be compared with compatible snow-specific fits, where available, and otherwise serve as diagnostics. The all-days comparison retains differences in snow occurrence and retrieval availability.

Report these results beside the forcing as evidence about sign, seasonality and plausible scale. They would **not select the CV winner, constrain its coefficients or replace its forcing estimate**. Agreement would support consistency under modern conditions; disagreement would expose a discrepancy requiring explanation.

## 4. Pitfalls

| Issue | Treatment and remaining limitation |
|---|---|
| **Mixed pixels and edges** | Exclude mixed labels and require surrounding same-class pixels. This improves homogeneity but does not prove purity. A later 30 m audit can measure contamination; do not divide by an assumed purity percentage. |
| **Topography** | Match elevation and restrict local relief. Existing GMTED is coarser than the albedo pixels and cannot establish equivalent fine-scale slope or aspect. Report the resulting restriction to gentler terrain. |
| **Snow hidden by canopy** | A snow flag describes the retrieval’s snow category, not snow beneath the forest. Dense conifers can hide snow and alter which observations enter the snowy sample. Nearby matching cannot remove that selection. This problem has direct MODIS and New Hampshire precedents. [Jin et al., 2002](https://doi.org/10.1029/2001GL014132); [Burakowski et al., 2015](https://doi.org/10.1016/j.rse.2014.11.023). |
| **Winter solar zenith** | At the winter solstice, noon zenith across 40–48°N is approximately 63–71°. The 75° rule should not geometrically remove the whole box; the 70° alternative can remove northern observations. Compare versions on common support so a changed sample is not mistaken for a changed forest effect. |
| **Different observation dates** | Monthly sums cannot establish simultaneous observations. This particularly weakens winter and snowmelt comparisons. Exact-day matching would require separately approved daily data acquisition or recovery. |
| **Forest age and disturbance** | Stable class labels and similar tree cover do not match age, height, management, disease or past disturbance. These remain alternative explanations for part of a contrast. |
| **Wetlands and water** | Combine the existing land rule, MOD44W and forest-map wetland flags. MOD44W is from 2015; historical shorelines may differ, and forested wetlands can remain undetected. |
| **Shared measurement inputs** | Albedo, forest type and tree cover all use MODIS optical information. Their errors may be related. Independence is from the fitted 1-degree vegetation–latitude relationship, not from its sensor observations. |
| **Transfer to the Holocene** | Modern climate, snow, species mixtures and forest structure are held as analogues. The result cannot establish a hemlock-specific prehistoric causal effect or a net temperature response. |

## 5. Effort and implementation

Implement one stand-alone script, provisionally **`tools/check_northeast_forest_albedo.R`**, with a short settings block and small named functions. Reuse existing shared functions where appropriate. It should read approved local inputs and produce tables, figures and a provenance note.

| Order | Work | Main risk |
|---|---|---|
| **1** | Confirm acquisitions, exact sizes, versions, grid alignment and period definitions. | An apparently compatible map uses different footprints or dates. |
| **2** | Build forest candidates, masks and fixed pairs; report coverage and covariate balance before examining albedo differences. | Homogeneous nearby examples may be scarce, especially for hemlock-bearing mixed landscapes. |
| **3** | Extract monthly sums/counts and calculate snow-specific and all-days contrasts. | Unequal retrieval availability changes the sampled forests and dates. |
| **4** | Calculate the fixed-location model exchanges and compare them over matched geographic support. | Forest-patch contrasts and pollen fractions have different meanings. |
| **5** | Produce a monthly contrast figure, support map, balance/count table and concise interpretation. | A regional average conceals disagreement or missing coverage. |
| **6** | Verify and independently review the implementation. | Sign, weighting or denominator mistakes create a persuasive but incorrect result. |

Verification should use **`tools/verify_change.R`** with an approved spec. Targeted checks should cover sum/count arithmetic, unknown-snow residuals, missing values, grid alignment, matching tolerances, subtraction sign, averaging order and identical model/benchmark support.

Because the implementation contains scientific arithmetic and choices, it needs the project’s independent **Fable and Astra reviews**, followed by reconciliation.

**Planning estimate:** roughly four to six working days including implementation, verification and review. Runtime should be measured on one tile first. The relevant existing albedo occupies about 25 GB, so stream selected layers and matched pixels rather than loading the full archive. A first run should produce a small diagnostic dataset; a finer-resolution mapping stage would be separately scoped.

## What Chris must decide

1. **Approve the initial data choice:** MCD12Q1 plus MOD44B, 2001–2009, with exact transfer sizes confirmed before downloading.
2. **Approve the proposed matching and eligibility rules**, including stable classes, terrain restriction, tree-cover tolerance and minimum retrieval counts.
3. **Accept the initial scope:** a descriptive modern forest-type benchmark, with winter results explicitly qualified by canopy-hidden snow and unmatched observation dates.
4. **Approve the approximate pollen-to-forest crosswalk for magnitude comparison**, while keeping the raw observed contrast visible.
5. **Choose whether finer-resolution confirmation is needed before publication.** My recommendation is to decide after seeing the initial support and class-homogeneity diagnostics.

No files were changed or data downloaded. Questions are recorded here rather than added to the living question files, following the read-only instruction. The prohibited account-request directory was not accessed.

## References

Core identities were checked against publisher or institutional records, and the methodological passages described above were read. The automated reference-checker workflow was **not completed**: its report-writing steps conflict with this session’s read-only restriction. That check remains outstanding before implementation.

- **Duveiller, G., Hooker, J. & Cescatti, A. (2018a).** The mark of vegetation change on Earth’s surface energy balance. *Nature Communications*, **9**, 679. DOI: [10.1038/s41467-017-02810-8](https://doi.org/10.1038/s41467-017-02810-8).
- **Duveiller, G., Hooker, J. & Cescatti, A. (2018b).** A dataset mapping the potential biophysical effects of vegetation cover change. *Scientific Data*, **5**, 180014. DOI: [10.1038/sdata.2018.14](https://doi.org/10.1038/sdata.2018.14).
- **Lejeune, Q., Davin, E. L., Duveiller, G., Crezee, B., Meier, R., Cescatti, A. & Seneviratne, S. I. (2020).** Biases in the albedo sensitivity to deforestation in CMIP5 models and their impacts on the associated historical radiative forcing. *Earth System Dynamics*, **11**, 1209–1232. DOI: [10.5194/esd-11-1209-2020](https://doi.org/10.5194/esd-11-1209-2020).
- **Bright, R. M., Davin, E., O’Halloran, T., Pongratz, J., Zhao, K. & Cescatti, A. (2017).** Local temperature response to land cover and management change driven by non-radiative processes. *Nature Climate Change*, **7**, 296–302. DOI: [10.1038/nclimate3250](https://doi.org/10.1038/nclimate3250).
- **Stuart, E. A. (2010).** Matching methods for causal inference: A review and a look forward. *Statistical Science*, **25**, 1–21. DOI: [10.1214/09-STS313](https://doi.org/10.1214/09-STS313).
- **Wang, Z., Schaaf, C. B., Sun, Q., Shuai, Y. & Román, M. O. (2018).** Capturing rapid land surface dynamics with Collection V006 MODIS BRDF/NBAR/Albedo (MCD43) products. *Remote Sensing of Environment*, **207**, 50–64. DOI: [10.1016/j.rse.2018.02.001](https://doi.org/10.1016/j.rse.2018.02.001).
- **Sulla-Menashe, D., Gray, J. M., Abercrombie, S. P. & Friedl, M. A. (2019).** Hierarchical mapping of annual global land cover 2001 to present: The MODIS Collection 6 Land Cover product. *Remote Sensing of Environment*, **222**, 183–194. DOI: [10.1016/j.rse.2018.12.013](https://doi.org/10.1016/j.rse.2018.12.013).
- **DiMiceli, C., Sohlberg, R. & Townshend, J. (2022).** MODIS/Terra Vegetation Continuous Fields Yearly L3 Global 250m SIN Grid V061. *NASA LP DAAC*, dataset. DOI: [10.5067/MODIS/MOD44B.061](https://doi.org/10.5067/MODIS/MOD44B.061).
- **Wickham, J. D., Stehman, S. V., Fry, J. A., Smith, J. H. & Homer, C. G. (2010).** Thematic accuracy of the NLCD 2001 land cover for the conterminous United States. *Remote Sensing of Environment*, **114**, 1286–1296. DOI: [10.1016/j.rse.2010.01.018](https://doi.org/10.1016/j.rse.2010.01.018).
- **Wulder, M. A., et al. (2008).** Monitoring Canada’s forests. Part 1: Completion of the EOSD land cover project. *Canadian Journal of Remote Sensing*, **34**, 549–562. DOI: [10.5589/m08-066](https://doi.org/10.5589/m08-066).
- **Latifovic, R., Pouliot, D. & Olthof, I. (2017).** Circa 2010 Land Cover of Canada: Local Optimization Methodology and Product Development. *Remote Sensing*, **9**, 1098. DOI: [10.3390/rs9111098](https://doi.org/10.3390/rs9111098).
- **Ruefenacht, B., et al. (2008).** Conterminous U.S. and Alaska Forest Type Mapping Using Forest Inventory and Analysis Data. *Photogrammetric Engineering & Remote Sensing*, **74**, 1379–1388. DOI: [10.14358/PERS.74.11.1379](https://doi.org/10.14358/PERS.74.11.1379).
- **Dawson, A., et al. (2025).** Holocene land cover change in North America: continental trends, regional drivers, and implications for vegetation–atmosphere feedbacks. *Climate of the Past*, **21**, 2031–2060. DOI: [10.5194/cp-21-2031-2025](https://doi.org/10.5194/cp-21-2031-2025).
- **Ghimire, B., Williams, C. A., Masek, J., Gao, F., Wang, Z., Schaaf, C. & He, T. (2014).** Global albedo change and radiative cooling from anthropogenic land cover change, 1700 to 2005 based on MODIS, land use harmonization, radiative kernels, and reanalysis. *Geophysical Research Letters*, **41**, 9087–9096. DOI: [10.1002/2014GL061671](https://doi.org/10.1002/2014GL061671).
- **Jin, Y., Schaaf, C. B., Gao, F., Li, X., Strahler, A. H., Zeng, X. & Dickinson, R. E. (2002).** How does snow impact the albedo of vegetated land surfaces as analyzed with MODIS data? *Geophysical Research Letters*, **29**, 1374. DOI: [10.1029/2001GL014132](https://doi.org/10.1029/2001GL014132).
- **Burakowski, E. A., et al. (2015).** Spatial scaling of reflectance and surface albedo over a mixed-use, temperate forest landscape during snow-covered periods. *Remote Sensing of Environment*, **158**, 465–477. DOI: [10.1016/j.rse.2014.11.023](https://doi.org/10.1016/j.rse.2014.11.023).