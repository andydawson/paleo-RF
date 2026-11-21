# Astra: choosing the model on predicted change rather than predicted albedo, 2 November 2026

Choosing on a credible albedo-change score would bring model selection closer to the quantity that drives the paper’s forcing estimates.

**I would revise my recommendation: prefer error in matched spatial differences, provided a check made before fitting establishes suitable pairs and relevant cover changes.** Otherwise retain the reconciled state-error score and explicitly leave change skill unvalidated. Observed temporal change is the stronger eventual test, but requires a substantial new data preparation step. This conditional recommendation is **my proposal**; the literature supports its components, not this exact protocol.

**1. Good state prediction does not establish good change prediction.**

All three supplied references are verified:

- Rapacciuolo et al. (2012), *PLoS ONE* 7:e40212, DOI [10.1371/journal.pone.0040212](https://doi.org/10.1371/journal.pone.0040212), found good prediction of distributions but poor prediction where occupancy changed.
- Rapacciuolo, Roy, Gillings and Purvis (2014), *Methods in Ecology and Evolution* 5:407–420, DOI [10.1111/2041-210X.12181](https://doi.org/10.1111/2041-210X.12181), developed temporal validation plots specifically to expose this distinction.
- Piirainen et al. (2023), *Diversity and Distributions* 29:654–665, DOI [10.1111/ddi.13687](https://doi.org/10.1111/ddi.13687), compared observed and predicted temporal differences and again found much weaker change prediction.

Their lesson carries over: persistent spatial patterns can make state prediction look successful while the response to changing predictors is wrong. Their particular species-occurrence metrics need not carry over to continuous albedo.

For albedo, the arithmetic is straightforward: if endpoint prediction errors are \(e_1\) and \(e_2\), change error is \(e_2-e_1\). A shared offset cancels; opposing errors accumulate. Consequently, the model with smallest state error need not have smallest change error. The appropriate quantity here is the **difference of response-scale albedos**, not a difference of logits. However, these ecological papers test actual temporal observations; they do not establish that neighbouring cells provide equivalent evidence.

**2. Spatial differences have published precedent—including for model selection.**

The strongest additional reference is **Rolling and Yang (2014), “Model selection for estimating treatment effects,” *Journal of the Royal Statistical Society B* 76:749–769, DOI [10.1111/rssb.12043](https://academic.oup.com/jrsssb/article/76/4/749/7076033)**. Their cross-validation matches held-out treated and untreated observations on background covariates, differences their observed outcomes, and selects models by error against those approximate effects. This directly supports Fable’s underlying idea. Its application here remains an adaptation: vegetation fractions are continuous, observations are spatially dependent, and matching cannot guarantee removal of confounding.

There is also direct albedo precedent:

- **Duveiller, Hooker and Cescatti (2018), *Nature Communications* 9:679, DOI [10.1038/s41467-017-02810-8](https://doi.org/10.1038/s41467-017-02810-8)** estimate potential cover effects using local spatial contrasts. Their method uses 5×5 windows of 0.05° pixels and screens unsuitable conditions. This is effect estimation.
- **Lejeune et al. (2020), *Earth System Dynamics* 11:1209–1232, DOI [10.5194/esd-11-1209-2020](https://esd.copernicus.org/articles/11/1209/2020/)** evaluate climate models’ forest-to-crops/grasses **albedo differences** against satellite-derived spatial estimates, then examine consequences for historical forcing. This is genuine model-evaluation precedent.
- **Wang, Yue and Luyssaert (2023), *Biogeosciences* 20:75–92, DOI [10.5194/bg-20-75-2023](https://bg.copernicus.org/articles/20/75/2023/)** compare spatial estimates with observed before/after changes corrected using unchanged controls. Their analysis includes albedo; much disagreement depends on comparing partial actual conversion with hypothetical complete conversion.

The remaining problem is what a pair measures. Predictions at two locations include differences in geography and elevation; a model can reproduce those while having the wrong cover response. Predicting both compositions at one common location removes that particular difference, but the observed pair still contains differences in soil, snow climate and vegetation history. Neither construction automatically supplies temporal truth.

This matters especially here: neighbouring **1° cells** are much less local than Duveiller’s pixels. Tight matching may also discard the unusual cover mixtures we most need to test. Moreover, a shared location offset does not disappear from response-scale differences through the inverse-logit transformation.

**3. Observed MODIS-era change is feasible as a pilot, but is not already available for scoring.**

The calibration cover is **pollen-derived**, not contemporary satellite land cover. [Script 1 selects `ages == 50`](scripts/1_veg_lct_prep.R:63) from REVEALS/Bayesian interpolated posteriors. The published reconstruction’s youngest bin is **1850–2024**, although the repository still leaves this particular input file’s bin/version unresolved. Its evergreen and summergreen categories include shrubs; open vegetation includes grasses, herbs and low shrubs. Thus “50 BP” should not simply be treated as a 1900 snapshot. **Dawson et al. (2025), *Climate of the Past* 21:2031–2060, DOI [10.5194/cp-21-2031-2025](https://cp.copernicus.org/articles/21/2031/2025/index.html), §2.2.**

Script 2 attaches **2000–2009 monthly MODIS/ERA5 albedo climatologies**, averaged over each 1° cell’s land pixels. No satellite cover-change input was found in the repository inventory. The existing albedo builder already calculates yearly quantities before averaging, so that machinery can be reused, but it currently stops in 2009. [Repository provenance](README.md:187); [builder](tools/prepare_bluesky_albedo.R:118).

Suitable external data exist:

| Candidate | Use and limitation |
|---|---|
| **USGS (2024; updated 2026), Annual NLCD**, USGS data release, DOI [10.5066/P94UXNTS](https://www.usgs.gov/centers/eros/science/about-annual-nlcd) | Annual 30 m cover through 2025; covers the conterminous US, not the entire project region. |
| **Canadian annual forest land-cover series**, methods in Hermosilla et al. (2022), *Remote Sensing of Environment* 268:112780, DOI [10.1016/j.rse.2021.112780](https://doi.org/10.1016/j.rse.2021.112780) | Annual coverage spanning the MODIS era over Canadian forest ecosystems. Requires a consistent mapping into project classes. |
| **Massey et al. (2023), boreal canopy and deciduous fractions**, ORNL DAAC, DOI [10.3334/ORNLDAAC/2296](https://daac.ornl.gov/cgi-bin/dsviewer.pl?ds_id=2296) | Continuous 30 m estimates for several epochs around 2000–2015; promising for composition changes, but deciduous fractions are valid only above 25% canopy cover. |

Satellite forest classes or canopy fractions are not automatically equivalent to pollen-derived trees-and-shrubs fractions. Mixed forest, shrub regrowth and exposed ground require explicit treatment. Simply differencing annual MODIS land-cover labels is particularly unsuitable: its producers warn against that use. **Sulla-Menashe and Friedl (2022), NASA/LP DAAC, *MCD12 Collection 6.1 User Guide*, no DOI, [pp. 1–2](https://lpdaac.usgs.gov/documents/1409/MCD12_User_Guide_V61.pdf).**

**My proposed pilot** would compare same-month, multiyear albedo before and after independently identified cover changes, subtracting contemporaneous changes in nearby unchanged controls, following Wang et al.’s general approach. Aggregate both cover and albedo to the existing 1° cells. Select events from cover information, never from favourable albedo changes.

Its main limitations are snow and weather differences, retrieval coverage, and disturbance effects absent from the predictors—char, exposed soil, canopy height and forest age. Removing snowy observations would also remove part of the winter vegetation effect. Small harvests may scarcely change whole-cell albedo; sufficiently large changes may occur in too few independent cells. Neither adequate numbers nor adequate signal has been established. Forest clearing also does not necessarily test evergreen-to-summergreen substitution. Under Chris’s decision, temporal cases wholly within training support would remain supporting evidence.

**4. The simplest selection rule I now favour.**

Before candidate fitting, establish whether the existing tails admit enough comparable pairs. Match without using albedo, using proximity, elevation and background climate, while checking that cover-change direction and magnitude resemble the historical transitions. Require at least one endpoint outside fold training support, both endpoints withheld, and the accepted geographic replication.

If that succeeds, use

\[
\frac{\sum w_{ij}\left[(\hat\alpha_i-\hat\alpha_j)-(\alpha_i-\alpha_j)\right]^2}
{\sum w_{ij}}.
\]

Use full response-scale predictions at the actual locations and describe the result as **skill on local spatial contrasts**. Do not claim exact spatial cancellation. A fixed pair table, preferably without reused cells, and one subtraction in the scoring function suffice. Retain the agreed weighting, simplicity order, block uncertainty and other accepted rules.

If comparable pairs do not cover the relevant departures, retain state error as the predeclared fallback. **This choice must precede seeing model scores.** Report both scores; do not introduce an arbitrary weighted blend. The hemlock sign remains an outcome.

| Option | Additional work beyond the reconciled design |
|---|---|
| State score | None. |
| Spatial-difference score | Pair membership and matching checks. **No additional scheduled fits** if partners are excluded before the existing fits; fewer training rows require renewed feasibility checks. |
| Observed temporal change | New cover harmonisation, period-specific albedo, controls and quality checks. Predictions alone need no new fits if evaluation observations are independent of training; otherwise each additional split costs \(13\times M\) fits, at most **156** for twelve months. |
| State and difference reporting | Little additional scoring code once pairs exist; no extra fits. |

Thus the planned maximum remains **468 tail fits plus 24 diagnostic fits** when pairing is incorporated beforehand, excluding retries and final refits. Observed-change preparation is the substantial extra task.

I used read-only inspection and web sources. No files, reference-checker programs, R code or pipeline scripts were run or changed.