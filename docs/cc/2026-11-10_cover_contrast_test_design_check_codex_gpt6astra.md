**Verdict: revise before Fable builds.** The centred 0.10 exchanges are a useful, simple way to describe the fitted response. The proposed interpretation is too strong, and the exploration can be substantially smaller.

Cut the “full swap” label, the all-days bracket, both significance flags, the hard 30-cell cutoff, and the initial sweep of fifteen versions. Keep historical exchanges in the separate hindcast comparison.

The benefit is a clearer answer to the paper’s immediate question: how much does the fitted modern cover response change when location size or cover form changes?

1. **The quantity is appropriate; multiplying it by ten does not produce a full replacement.**

   Keep the area-weighted mean of the **predicted albedo differences at the two endpoints**, holding location, elevation and the third cover class fixed. This applies consistently to straight-line and thin-plate versions. The existing calculation also correctly preserves covariance between endpoints and between cells. [Contrast calculation](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/R/cv_separation.R:78)

   There are three problems with “per full swap”:

   - The straight-line versions are linear **on the logit scale**, so their albedo response is curved too. [Model definition](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/R/model_registry.R:137)
   - A thin-plate response can change slope and sign beyond the small interval examined.
   - A full one-unit exchange is impossible while keeping a nonzero third class fixed.

   Ten times the contrast is a rescaled local response, not a prediction of replacing one vegetation class completely.

   **My recommendation:** report “albedo change for a 10 percentage-point cover exchange”. Put published full-class differences in a separate, clearly labelled panel in their original units. If a common numerical scale is essential, multiplying the published contrast by 0.10 gives an **ideal linear area-mixing reference**, an assumption supported by fractional mixing studies—not a measured partial-cover response. Ghimire et al.’s §2.3 provides that mixing precedent; it does not establish linearity for these fitted models. [Ghimire et al., 2014](https://doi.org/10.1002/2014GL061671)

2. **The comparison is useful context, but it is not a direct validation against matching observations.**

   Beside the table, state these differences explicitly:

   | Difference | What the reader needs to know |
   |---|---|
   | Quantity and scale | The project estimates a response around mixed one-degree cells; references describe classes, sites or adjacent vegetation pairs. |
   | Albedo definition | The project uses monthly means of **local-noon blue-sky** albedo. Jin uses local-noon black-sky; Zhao’s paired comparisons use white-sky; Hollinger uses tower radiation totals. Burakowski’s Figure 5 uses blue-sky albedo. |
   | Snow and quality | **“75%” is incorrect: it is 75° solar zenith**, combined with full BRDF inversions. Snow state comes from retrieval snow flags, not a 75% snow threshold. |
   | Vegetation classes | Broadleaf deciduous forest does not represent all summergreen vegetation, which includes larch and shrubs. Grass/crop comparisons do not represent the entire open-land mixture. |
   | Time and geography | Preserve each source’s months, region and averaging period. An annual or seasonal value is not twelve independent monthly observations. |
   | Uncertainty | Distinguish observational standard deviations, geographic ranges and model standard errors. They measure different things. |
   | Independence | Some references share MODIS observations with the project. Call them independently published references, rather than wholly independent measurements. |

   The project’s illumination, averaging and screening definitions are explicit in the [albedo preparation code](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/tools/prepare_bluesky_albedo.R:25).

   Two expectations need correction. **“Evergreen is darker in every season” is too absolute:** Hollinger reports winter exceptions involving southern pine and leafless hardwood sites. **“Summergreen and open land are about equal without snow” is also too broad:** its grassland and crop class means exceed broadleaf deciduous means in each reported snow-free season. Larch has a separate row and overlaps broadleaf values; that supplies no general shrub equivalence. [Hollinger et al., Table 2 and pp. 701–703](https://research.fs.usda.gov/treesearch/download/34733.pdf)

   Consequently, delete the design’s claim that a contrary sign proves the fitted response is not a vegetation effect. It warrants investigation; class composition, sampling and confounding remain possible explanations.

3. **The all-days bracket is not sound for this regression.**

   A contrast lies between its snow-free and snowy counterparts when **the same snow fraction weights both endpoints**, under otherwise matching conditions. A fitted all-days cover response does not impose that condition. If snow occurrence varies with cover, the response also contains the effect of that variation.

   Barnes and Roy’s equation 3 and Ghimire’s equation 1 prescribe snow-weighted mixtures. Neither establishes a bound on an independently fitted all-days GAM. [Barnes and Roy, §3.1](https://doi.org/10.1029/2010JG001428); [Ghimire et al., §2.3](https://doi.org/10.1002/2014GL061671)

   Use the snow-free and snowy fits for the respective numerical comparisons. Show all-days results throughout the year as model behaviour; comparisons with snow-free references are more defensible in virtually snow-free months.

   The existing cell table helps identify those months. Across all 83 northeast cells, before exchange filtering:

   - June–September have zero stored snowy shares.
   - May’s maximum snowy share is about **0.16%**; October’s is **0.034%**.
   - April’s maximum is **63%**, and November’s **33%**.
   - Stored unknown-snow shares are zero throughout the northeast.

   These are accepted-retrieval shares, at the table’s stored precision. They do not establish absence of snow on unobserved days. Also, continental training cells retain summer snow: a northeast all-days response can still inherit that influence through the shared fitted cover term. The snow-free calibration remains the cleaner comparison.

4. **Keep the regions and endpoint rule, but remove the 30-cell gate and report the actual coverage.**

   I checked the three saved calibration tables. The proposed rule retains:

   | Northeast table/months | Evergreen replaces summergreen | Evergreen replaces open land | Summergreen replaces open land |
   |---|---:|---:|---:|
   | All days, every month | 58 | 41 | **22** |
   | Snow-free, range across months | 45–58 | 32–41 | **17–22** |
   | Snowy, December–March | 58 | 41 | **22** |
   | Snowy, April | 42 | 25 | 13 |
   | Snowy, May | 3 | 1 | 1 |
   | Snowy, October | 2 | 0 | 0 |
   | Snowy, November | 25 | 16 | 6 |
   | Snowy, June and September | 0 | 0 | 0 |

   For all-days results, the retained shares of northeast area are **69.6%, 49.9% and 26.7%**, respectively. All 83 cells satisfy the physical fraction constraints; the endpoint hull rule causes these exclusions.

   Thus **the 30-cell cutoff removes every northeast summergreen–open-land result**. Thirty is not a defensible boundary between informative and uninformative here: these are evaluation cells for a continentally fitted model, not thirty independent observations supplying a local standard error.

   Show the estimate for the **eligible subset**, its cell count and retained area. Zero eligible cells gives no estimate. One or three cells should be described as those cells, not as a northeast average.

   Keep identical cells and weights across model versions. When claiming a difference between snow-state tables, compare common eligible cells; otherwise acknowledge that their geographic targets differ. Do not require one common set across all months and states—that would eliminate useful results.

   “Inside the modern range” also needs narrowing: this is the **continental cover-mixture hull**, not proof of nearby observations or of separating vegetation from location. [Support definition](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/R/training_support.R:10)

   Define “whole study area” using the existing forcing domain, including its 27–74°N window, rather than silently including every calibration cell. All three exchanges retain hundreds of cells there. The hull should still use the actual fitted training rows. [Domain definition](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/config.R:110)

5. **Four versions are the smallest balanced first comparison.**

   | Location basis size | Straight-line cover | Thin-plate cover, size 200 |
   |---|---|---|
   | 100 | Chosen version | Matching curved-cover version |
   | 500 | Flexible-location rival | Original model 8 |

   This separates location size from cover form and reveals whether their effects depend on each other. Three versions would leave one combination unexamined.

   Keep twelve months and the three existing albedo tables: seasonality and snow are central to the question. That gives **136 combinations**, rather than 510, with at most 102 new fits if all 34 original-model fits are reusable. Reuse other matching saved fits too.

   If Chris also wants the already-observed coarse-location behaviour represented, add location size 30 with both cover forms: **six versions, 204 combinations**. The four-version result must be described as a comparison of sizes 100 and 500, not of every location size.

   July and August snowy calibration data exist; those months lack the corresponding saved full set of fits. Their omission must not be described as absence of summer snow.

6. **Keep conditional uncertainty; cut both sign flags.**

   The existing standard error is a reasonable **approximate, conditional** description of uncertainty in this fitted mean contrast. It uses the full coefficient covariance correctly. It does not include smoothing-parameter uncertainty, residual spatial dependence, cover uncertainty or uncertainty in choosing the model. It may understate total uncertainty; one cannot assert that every individual standard error is necessarily too small. [Official `mgcv` documentation](https://stat.ethz.ch/R-manual/R-devel/library/mgcv/html/predict.gam.html)

   **Three standard errors does not “allow for the number of comparisons”.** For illustration, 72 independent Normal null comparisons have about an 18% chance of producing at least one three-standard-error result. The actual comparisons are dependent, so that is an illustration, not their calculated error rate.

   One estimate with **±2 conditional standard errors**, plainly labelled as individual descriptive intervals, is enough. No significance classification or claim of simultaneous coverage is needed.

7. **A short standalone script is clearer, while retaining shared calculations.**

   The proposed six-line change is incomplete: [`freeze_exchange()`](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/R/cv_separation.R:22) explicitly rejects any change to open land. Extending only `fixed_exchange()` would break both new open-land exchanges.

   Parameterize the exchanged classes and the held class, preserving the existing defaults and historical behaviour. Reuse the current support, weighting, contrast and fitting helpers.

   I favour a short `tools/explore_cover_contrasts.R`, with a straightforward read–fit–calculate–report flow. The existing protocol tool enforces all-days inputs, prepares April and May, and sets up recovery simulations. Adding this exploration there brings unnecessary dependencies. [Current preparation](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/tools/check_cv_separation.R:33)

   Existing tests already check covariance arithmetic, reversal, empty exchanges, both-endpoint support and reweighting. Add tests for all three class pairs, preservation of the held quantities and total cover, rejection of invalid pairs, and one small workflow check covering counts, area, failed fits and mismatched reused fits. Drop flag and cutoff tests with those features. Verify the eventual change through `tools/verify_change.R`.

8. **The precedent table needs these corrections and additions.**

   The primary passages below were read and their DOI identities checked.

   | Reference and passage read | What it supports |
   |---|---|
   | **Jin et al. (2002).** *How does snow impact the albedo of vegetated land surfaces as analyzed with MODIS data?* **Geophysical Research Letters 29**, 1374. [DOI: 10.1029/2001GL014132](https://doi.org/10.1029/2001GL014132). §§2–3, Table 1. | Snow-state class contrasts, including forest and open classes. November–January, 40–50°N, local-noon **black-sky** albedo; not matched northeast sites. |
   | **Hollinger et al. (2010).** *Albedo estimates for land surface models and support for a new paradigm based on foliage nitrogen concentration.* **Global Change Biology 16**, 696–710. [DOI: 10.1111/j.1365-2486.2009.02028.x](https://research.fs.usda.gov/treesearch/download/34733.pdf). Equation 2, Figure 2, Table 2, pp. 701–703. | Seasonal tower observations and comparison with model values. Supports the first **and second** precedent rows. Includes open classes, larch, geographic variation and winter exceptions. |
   | **Burakowski et al. (2016).** *Evaluating the Climate Effects of Reforestation in New England Using a Weather Research and Forecasting (WRF) Model Multiphysics Ensemble.* **Journal of Climate 29**, 5141–5156. [DOI: 10.1175/JCLI-D-15-0286.1](https://harvardforest1.fas.harvard.edu/publications/pdfs/Burakowski_JClimate_2016.pdf). **§2d(3)**, §3a(4), Figure 5. | Correct the section reference. December–March **blue-sky** observations by snow state and cover. Figure error bars are one standard deviation; distinguish observational bars from model bars. |
   | **Zhao and Jackson (2014).** *Biophysical forcings of land-use changes from potential forestry activities in North America.* **Ecological Monographs 84**, 329–353. [DOI: 10.1890/12-1705.1](https://jacksonlab.stanford.edu/sites/g/files/sbiybj20871/files/media/file/em2014.pdf). Methods pp. 333–335; p. 338 and Figures 5–6. | Adjacent vegetation comparisons, including forest–grass/crop differences and monthly seasonality. Paired albedo comparisons use **white-sky** values; snow states are not separated. |
   | **Bright et al. (2015).** *Radiative forcing bias of simulated surface albedo modifications linked to forest cover changes at northern latitudes.* **Biogeosciences 12**, 2195–2205. [DOI: 10.5194/bg-12-2195-2015](https://bg.copernicus.org/articles/12/2195/2015/bg-12-2195-2015.pdf). §§2.1–2.3 and Figure 2. | **Confirmed**, replacing “to be confirmed”. Evaluates model albedo schemes against MODIS and examines forest–open forcing differences. Norwegian snow seasons and black-sky spectral albedos limit direct numerical transfer. |
   | **Barnes and Roy (2010).** *Radiative forcing over the conterminous United States due to contemporary land cover land use change and sensitivity to snow and interannual albedo variability.* **JGR 115**, G04033. [DOI: 10.1029/2010JG001428](https://doi.org/10.1029/2010JG001428). §3.1, equation 3; Table 1. | Prescribed snow mixing using independent snow fractions. Table 1 also supplies annual forest/open-class context. Neither supports the proposed all-days bound. |
   | **Ghimire et al. (2014).** *Global albedo change and radiative cooling from anthropogenic land cover change, 1700 to 2005 based on MODIS, land use harmonization, radiative kernels, and reanalysis.* **GRL 41**, 9087–9096. [DOI: 10.1002/2014GL061671](https://doi.org/10.1002/2014GL061671). §§2.2–2.3, equation 1. | One-degree fractional mixing of classes, snow states and illumination, with stationary snow climatology. Supports a linear mixing reference, not extrapolation of this GAM’s local response. |
   | **Add Lejeune et al. (2020).** *Biases in the albedo sensitivity to deforestation in CMIP5 models and their impacts on the associated historical radiative forcing.* **Earth System Dynamics 11**, 1209–1232. [DOI: 10.5194/esd-11-1209-2020](https://esd.copernicus.org/articles/11/1209/2020/). §§2.1.1–2.3.1 and §4. | Particularly relevant: monthly regressions on cover fractions, separate snow states, area-weighted aggregation and comparison of modelled transitions with satellite estimates. Its extrapolation to pure classes explicitly uses **response-scale linear regressions**. |

   “Open-land references not yet found” should therefore become **“references exist, but none directly matches our mixed open-land class.”**

   **No direct field precedent was established** for this exact centred 0.10 exchange, its hull restriction, the 30-cell floor, the two sign flags or the proposed model subset. These are project choices. The covariance calculation has standard mathematical justification; that does not make the whole diagnostic a published field method.

9. **The most important omissions concern interpretation.**

   First, the averages describe **different eligible subsets** across exchanges, months and snow states. Changing samples can masquerade as changing response.

   Second, prediction at fixed coordinates does not establish a causal vegetation effect: the fitted cover and location terms were still estimated from spatially confounded observations.

   Third, harmonize the sign convention before joining references. The proposed evergreen increase is the reverse of the historical evergreen decline and of published “deciduous minus evergreen” contrasts.

   Fourth, a small regional mean can conceal opposing cellwise responses in thin-plate fits. It means a small average, not necessarily little response everywhere.

   Finally, modern agreement does not validate the historical exchange outside modern support. Keep that limitation separate and explicit.

No files were changed or committed. R could not start because the read-only environment prevented its temporary directory; the cell checks used in-memory Python reads. The independently calculated 58-cell northeast result and 69.6% area share matched existing saved endpoint results. I dropped two possible additions—a new local-support filter and spatial bootstrapping—because they would turn this descriptive exploration into a larger methods project.

The changes I recommend before Fable builds, in order, are:

1. Report actual 0.10 exchanges; remove “full swap”, universal sign claims and the all-days bracket.
2. Correct 75% to 75° and finish the reference table with explicit class, albedo, season and uncertainty definitions.
3. Start with the four matched versions; retain seasonal and snow-state coverage.
4. Replace the 30-cell gate with cell counts, retained area and explicit subset labels.
5. Retain conditional intervals and remove both sign flags.
6. Use a short standalone runner with shared helpers, fix both exchange functions, and run the targeted verification.

Questions for Chris:

- **Shall Fable start with four versions—location sizes 100 and 500, each with straight-line and thin-plate cover—or six, adding both cover forms at location size 30?** I recommend four initially.
- **Are you content to use the centred 10 percentage-point exchange as an explicitly project-chosen descriptive diagnostic, reporting sparse eligible subsets—including the 22-cell northeast summergreen–open-land result—with their area coverage?** I recommend that presentation; this exact diagnostic has no established field precedent.