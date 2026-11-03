*Astra (gpt-6-astra, ultra effort, web search), 3 November 2026, for Chris: can the cross-validation fix the northeast problem? Brief: `2026-11-03_cv_northeast_question_brief.md`. Issue #24. Links are relative to the repository root, except the verification run folder.*

## Summary

**Partly: the cross-validation can improve model choice, but cannot by itself establish the northeast’s vegetation effect.**  
The relevant holdout is the **+17.2° direction toward less open land**, not the direction of the hemlock decline through time.  
That holdout removes **82 of today’s 83 northeast cells**, introducing substantial geographic transfer.  
Evergreen still closely follows latitude among those withheld cells: **r = 0.914**.  
The historical departures overlap the tested distances, but the deepest relevant May group contains only **15 cells in five blocks**.  
Coarse-location and no-location candidates could reduce or reverse the warming; that would need interpretation, not automatic acceptance.  
I would retain the selection rule, document these limitations before scoring, and obtain an independent local, seasonally matched albedo comparison.

## 1. Can it fix it?

**It can detect some relevant prediction failures and select a different model. It cannot reliably distinguish poor extrapolation from a poorly identified cover effect.**

I read the diagnosis, design, reviews, amendments and implementation. I also recalculated cover geometry from the final holdout inputs without fitting models or writing files. Input checksums matched the saved record, and all 36 saved modern holdout distance summaries were reproduced at their reported precision. The [verification report, lines 21–28](docs/cc/verification/2026-11-03_cv-holdouts-5_report.md:21) establishes that these calibration and cover inputs match run 1.

### Which direction tests the northeast?

The three directions broadly represent **less evergreen**, **less open land**, and **less summergreen**. The northeast’s outside-range mixtures at 6, 5.5, 5 and 4.5 ka all belong to the **less-open-land direction, +17.2°**, which carries about 45% of the overall outside-target weight.

The distinction matters:

- Replacing evergreen with summergreen at fixed open land moves along the triangle at **−60°**. The actual mean northeast change is approximately −58°.
- The protocol instead measures the direction **from the nearest modern hull boundary to a historical mixture**. That points into the low-open-land region.

Thus the −68.8° holdout is not the hemlock test merely because its angle resembles the temporal change. This follows directly from the [triangle coordinates](R/training_support.R:23) and [departure calculation](R/cross_validation.R:51).

### How closely do withheld cells resemble the northeast?

The correspondence is real but incomplete.

| Cases, using May’s training data | Outside their relevant training hull | Distance outside hull: 10th / median / 90th percentile |
|---|---:|---:|
| Northeast, 6 ka | 81/83 | 0.0067 / 0.0216 / 0.0330 |
| Northeast, 5.5 ka | 82/83 | 0.0197 / 0.0346 / 0.0479 |
| Northeast, 5 ka | 83/83 | 0.0266 / 0.0459 / 0.0711 |
| Northeast, 4.5 ka | 83/83 | 0.0392 / 0.0852 / 0.1019 |
| Modern cells in the relevant holdout | 563/563 | 0.0078 / 0.0325 / 0.0762 |

These are current **triangle-to-hull distances**, not the earlier nearest-modern-mixture statistic of approximately 0.12. The modern comparison agrees with the [saved May summary](/home/expert/Documents/contracting/Andria/paleo-RF-verify/6841c48/.rundirs/cv-holdouts-5/output/cross_validation/comparison.csv:18).

**Distance overlap exists.** The maximum northeast 4.5 ka departure is 0.107, below the modern holdout maximum of 0.112. But the historical median exceeds the modern holdout’s 90th percentile. In May’s actual scoring group beyond 0.10, there are only **15 modern cells in five geographic blocks**. The other holdouts contribute no additional cases to that group.

Those deepest modern cases have summergreen fractions **0.440–0.610**, against the northeast’s 4.5 ka mean of **0.725**. Matching distance from a reduced training hull therefore does not supply the historical absolute composition. Roberts et al. support matching extrapolation direction and magnitude; Meyer and Pebesma explain why measured error should be attached only to conditions that validation actually represents. Neither establishes that distance alone makes these situations equivalent. [Roberts et al., 2017](https://doi.org/10.1111/ecog.02881); [Meyer & Pebesma, 2021](https://doi.org/10.1111/2041-210X.13650).

**The geographic mismatch is substantial.** The relevant holdout removes 82 of the 83 modern northeast cells. Their nearest remaining training locations are approximately **167 / 340 / 524 km** away at the 10th, median and 90th percentiles. Their historical locations are present in the full modern calibration data, giving zero geographic distance.

Moreover, evergreen–latitude correlation is **0.917** across all 83 modern northeast cells and **0.914** among the 82 withheld cells. The test retains that association; it does not create otherwise comparable northern and southern forest mixtures.

Consequently, a location-dependent model can lose partly because it must predict across a geographic hole. A no-location model might benefit from that particular test. This is a limitation of the test’s relevance, not proof that its score is invalid. Matching validation geography to the intended prediction task is the relevant published principle. [Linnenbrink et al., 2024](https://doi.org/10.5194/gmd-17-5897-2024).

### Can the score detect model 8’s problem?

**Yes, if model 8 predicts those withheld modern albedos badly.** The global cover cut prevents equivalent extreme mixtures elsewhere from remaining in that fold’s training data.

But three qualifications restrict the conclusion:

1. **The test scores albedo levels, not the evergreen-to-summergreen response.** A model can predict modern levels accurately while allocating their geographic pattern incorrectly between cover and location.
2. **The overall score is broader than this event.** The four northeast slices from 6 to 4.5 ka supply approximately 5% of the outside-target weight. Errors are pooled by month, departure direction and distance, without a northeast category.
3. **Feasibility is not local evidential strength.** The ten-block requirement applies to the whole scored holdout-month. It does not guarantee ten blocks in the deepest relevant group. See the [feasibility calculation](tools/cross_validate_albedo.R:118) and [score pooling](R/cross_validation.R:124).

### Could a candidate behave better there?

Yes. The [registry](R/model_registry.R:23) contains meaningful alternatives:

| Candidate | How it could change the northeast result | Limitation |
|---|---|---|
| Cover plus elevation, without location | Changes how geographic variation is assigned to cover; the older May fit already reversed the sign | May assign climate or snow differences to vegetation |
| Model 8 with location basis reduced from 500 to 30 | Restricts the spatial patterns competing with cover | Does not establish a physically correct spatial scale |
| Linear cover, with or without location | Removes curvature in the cover response on the logit scale | Coefficient signs remain unconstrained |
| Smaller two-dimensional cover smooth; existing simpler smooths | Changes flexibility and extrapolation | Does not create missing local contrasts |

There is also a subtle case: **model 3 contains open land but no evergreen–summergreen distinction**. It is eligible. It predicts no response to their exact exchange at fixed open land. A greatly reduced hemlock signal under that model could therefore reflect its specification rather than evidence of a negligible physical effect.

None of the candidates explicitly represents snow-dependent cover effects or imposes a scientifically justified replacement sign. Coarse-location and no-location comparisons are useful sensitivity checks, not established cures for spatial confounding. [Paciorek, 2010](https://doi.org/10.1214/10-STS326).

## 2. What it cannot do

### Accurate modern levels do not identify a historical substitution

For model 8, the fitted mean has the form

\[
\widehat{\alpha}_{i,t}
=\operatorname{logit}^{-1}\{a_i+f(\text{cover}_{i,t})\},
\]

where \(a_i\) contains location, elevation and the intercept. Modern observations constrain their **sum**. When cover closely follows geography, different allocations between \(a_i\) and \(f\) can produce similar modern predictions but different historical cover contrasts.

Location cancels from a difference on the logit scale, but its baseline still affects the response-scale magnitude. Its inclusion also affects the fitted cover function itself. This is visible in the [model formulas and link](R/model_registry.R:107).

Hodges and Reich demonstrate competition between spatial effects and covariates in their linear spatial models. Paciorek shows how confounding depends on spatial scales and available unconfounded covariate variation. These support the diagnosis; they do **not** prove that this nonlinear model is biased in a particular direction, or that deleting location fixes it. [Hodges & Reich, 2010](https://doi.org/10.1198/tast.2010.10052); [Paciorek, 2010](https://doi.org/10.1214/10-STS326).

The latitude-adjusted northeast estimate therefore indicates weak local information about the sign. It is not evidence that the true effect is zero. Continental observations can inform the model, but transferring their cover relationship into this region remains an assumption.

### Environmental withholding and spatial resampling do different jobs

Roberts et al. explicitly distinguish **changed relationships among predictors** from prediction outside observed predictor space. Their discussion also warns that environmental splits can retain spatial structure. Here the tail cut tests missing cover mixtures, while the bootstrap measures variation in the resulting scores. Resampling blocks does not break the observed cover–latitude association or create independent vegetation contrasts. [Roberts et al., 2017](https://doi.org/10.1111/ecog.02881).

Ploton et al. show, in ecological mapping examples, how apparent predictive skill can depend heavily on spatial information. However, Wadoux et al. dispute treating spatially separated validation as a generally correct estimate of map accuracy: it can overrepresent difficult prediction settings. Together they support a precise description here—**a targeted modern transfer comparison**, not unbiased historical accuracy or validation of the vegetation mechanism. [Ploton et al., 2020](https://doi.org/10.1038/s41467-020-18321-y); [Wadoux et al., 2021](https://doi.org/10.1016/j.ecolmodel.2021.109692).

### “Represented by a scoring group” is weaker than “supported historically”

The code’s represented share means that a month–direction–distance group contains validation observations. It does not establish comparable absolute mixtures, latitude, elevation, snow conditions or residual cover variation.

Meyer and Pebesma’s area-of-applicability method uses multivariate predictor distances linked to validation. The project’s cover hull and broad distance bands are useful diagnostics, but are not automatically that formal method. Nor would an applicability assessment identify a causal replacement effect. [Meyer & Pebesma, 2021](https://doi.org/10.1111/2041-210X.13650).

The current low-open-land diagnostic is particularly limited: it uses open land ≤0.20 and pools signed errors by evergreen bin across months, regions and holdouts. It neither holds latitude fixed nor isolates the northeast. See [the implementation](tools/cross_validate_albedo.R:280).

Finally, the winning score is used for selection and has no independent assessment set. It should remain labelled a **selection score**; freezing candidates does not remove selection optimism. [Cawley & Talbot, 2010](https://jmlr.org/papers/v11/cawley10a.html).

Your three new refits show that the warming survives changes to calibration albedo and snow-day selection. They do not independently resolve the shared model structure’s cover–location ambiguity. I have treated those forcing totals as supplied results, rather than recomputing them.

## 3. What would help?

**The immediate benefit to the paper is to separate a better-performing prediction model from a defensible regional vegetation-change claim.**

I would first record the northeast-specific correspondence above before any score is examined. Then complete the approved comparison. The first additional scientific evidence I would pursue is a local albedo contrast that does not reproduce the same latitude gradient.

| Addition or action | Benefit to the paper | Cost | Relationship to the frozen protocol |
|---|---|---|---|
| Record northeast support, absolute mixtures, geographic gaps and cells/blocks per scoring group | Defines exactly what the CV can support | Low; existing inputs, no fits | Reporting clarification now; no selection change |
| Report low-open-land errors separately by month and region, alongside cover–latitude relationships | Exposes patterns hidden by pooled averages | Low; saved predictions plus descriptive analysis | Specify now. Added after scores, label exploratory and do not use for reselection |
| Complete the planned chosen-model versus model-8 hindcast comparison, with monthly northeast contrasts and support flags | Shows whether predictive selection changes the disputed result | Already budgeted | Already required by [protocol section 7](docs/cc/2026-11-02_cv_protocol.md:75) |
| Build a small northeast benchmark from comparable local forest classes, separated by snow and season | Directly challenges the replacement effect and magnitude | Moderate; class mapping, observations and quality checks | Separate benchmark; does not alter the CV winner |
| Revisit matched spatial differences or observed satellite-era change | Tests a quantity closer to the forcing calculation | Moderate to high; suitable contrasts may be scarce | Explicitly [filed for future work](docs/cc/2026-11-02_cv_design_decisions.md:67). Requires a separate agreed design |
| Introduce a physically constrained cover response | Makes an externally justified assumption explicit | Moderate to high; new formulation, review and verification | Changes candidates. Amend before scores, or conduct a separately declared subsequent comparison |

For the local benchmark, **unadjusted regional evergreen and deciduous averages would risk repeating the original confounding**. Compare nearby, otherwise comparable stands and match month, snow conditions and measurement footprint. Spatial albedo contrasts under similar background conditions have published precedent, although their application to hemlock replacement remains a project-specific adaptation. [Lejeune et al., 2020, section 2.1.2](https://esd.copernicus.org/articles/11/1209/2020/).

The expected brightening has empirical support, but should not become a universal monthly constraint. Betts and Ball found higher aspen than conifer albedos in their boreal observations; those sites are not northeastern hemlock replacements. In New Hampshire, Burakowski et al. measured a leafless deciduous canopy with broadband albedo around 0.10 on a snow-free March date, illustrating why season and snow must be matched. Neither study directly measures the historical substitution. [Betts & Ball, 1997](https://doi.org/10.1029/96JD03876); [Burakowski et al., 2015](https://doi.org/10.1016/j.rse.2014.11.023).

A small class-albedo calculation could then combine reconstructed fractions with locally appropriate monthly class values. Ghimire et al., section 2.3, provide direct precedent for combining cover fractions, class albedos and snow states. Their fixed modern snow climatology is an explicit assumption, not evidence that snow was stationary through the Holocene. The paper must settle whether it estimates vegetation effects under modern conditions or total historical albedo change. [Ghimire et al., 2014](https://doi.org/10.1002/2014GL061671).

Shape-constrained additive models are established statistically. Here any constraint must specify **evergreen replacing summergreen at fixed open land and relevant snow conditions**. Cooling obtained by imposing that constraint would be a consequence of the assumption, not validation. I would obtain local evidence first. [Pya & Wood, 2015](https://doi.org/10.1007/s11222-013-9448-7).

If adequate contrasts remain unavailable, report the northeast as **an unsupported estimate of vegetation-driven change**, with its model-dependent forcing shown separately. Preserve the original reporting denominator; omitting unsupported cells must not silently turn their forcing into zero.

I would also qualify the interpretation in [protocol lines 81–83](docs/cc/2026-11-02_cv_protocol.md:81): persistent warming with competitive scores argues against poor prediction **on the modern conditions tested**. Given the demonstrated mismatch, it would not establish that the historical warming is real or rule out confounding.

## 4. Verdict

**Partly.** Proceed with the approved cross-validation because it tests relevant cover departures and includes candidates capable of changing the northeast result. But its strongest northeast holdout removes almost the whole region, retains the modern cover–latitude association, and only sparsely represents the deepest historical departures. It can choose a better modern transfer model; it cannot establish the sign of vegetation change at fixed northeastern locations. Keep the hemlock sign outside selection, record these limitations before scoring, and interpret either persistence or reversal cautiously. If the northeast is central to the paper’s argument, obtain an independent, seasonally and geographically matched forest-albedo benchmark. Without that evidence, report its forcing as model-dependent and insufficiently supported.

## Recommendations ranked by benefit to the paper

1. **Obtain an independent local forest-albedo contrast:** the largest gain for the disputed scientific claim.
2. **Document support and confounding explicitly:** the immediate priority before scores, and inexpensive.
3. **Finish the frozen CV and planned hindcast comparison:** useful evidence for model choice, with a narrower accuracy claim.
4. **Defer new constraints or change-based selection until justified:** preserve the original comparison and treat later work separately.

## References

- **Hodges, J. S., & Reich, B. J. (2010).** Adding Spatially-Correlated Errors Can Mess Up the Fixed Effect You Love. *The American Statistician*, **64**, 325–334. DOI: [10.1198/tast.2010.10052](https://doi.org/10.1198/tast.2010.10052).
- **Paciorek, C. J. (2010).** The importance of scale for spatial-confounding bias and precision of spatial regression estimators. *Statistical Science*, **25**, 107–125. DOI: [10.1214/10-STS326](https://doi.org/10.1214/10-STS326).
- **Roberts, D. R., et al. (2017).** Cross-validation strategies for data with temporal, spatial, hierarchical, or phylogenetic structure. *Ecography*, **40**, 913–929. DOI: [10.1111/ecog.02881](https://doi.org/10.1111/ecog.02881).
- **Meyer, H., & Pebesma, E. (2021).** Predicting into unknown space? Estimating the area of applicability of spatial prediction models. *Methods in Ecology and Evolution*, **12**, 1620–1633. DOI: [10.1111/2041-210X.13650](https://doi.org/10.1111/2041-210X.13650).
- **Ploton, P., et al. (2020).** Spatial validation reveals poor predictive performance of large-scale ecological mapping models. *Nature Communications*, **11**, 4540. DOI: [10.1038/s41467-020-18321-y](https://doi.org/10.1038/s41467-020-18321-y).
- **Wadoux, A. M. J.-C., Heuvelink, G. B. M., de Bruin, S., & Brus, D. J. (2021).** Spatial cross-validation is not the right way to evaluate map accuracy. *Ecological Modelling*, **457**, 109692. DOI: [10.1016/j.ecolmodel.2021.109692](https://doi.org/10.1016/j.ecolmodel.2021.109692).
- **Linnenbrink, J., Milà, C., Ludwig, M., & Meyer, H. (2024).** kNNDM CV: k-fold nearest-neighbour distance matching cross-validation for map accuracy estimation. *Geoscientific Model Development*, **17**, 5897–5912. DOI: [10.5194/gmd-17-5897-2024](https://doi.org/10.5194/gmd-17-5897-2024).
- **Cawley, G. C., & Talbot, N. L. C. (2010).** On Over-fitting in Model Selection and Subsequent Selection Bias in Performance Evaluation. *Journal of Machine Learning Research*, **11**, 2079–2107. [Publisher full text](https://jmlr.org/papers/v11/cawley10a.html); indexed DOI: [10.5555/1756006.1859921](https://doi.org/10.5555/1756006.1859921).
- **Lejeune, Q., et al. (2020).** Biases in the albedo sensitivity to deforestation in CMIP5 models and their impacts on the associated historical radiative forcing. *Earth System Dynamics*, **11**, 1209–1232. DOI: [10.5194/esd-11-1209-2020](https://doi.org/10.5194/esd-11-1209-2020).
- **Betts, A. K., & Ball, J. H. (1997).** Albedo over the boreal forest. *Journal of Geophysical Research*, **102**, 28901–28909. DOI: [10.1029/96JD03876](https://doi.org/10.1029/96JD03876).
- **Burakowski, E. A., et al. (2015).** Spatial scaling of reflectance and surface albedo over a mixed-use, temperate forest landscape during snow-covered periods. *Remote Sensing of Environment*, **158**, 465–477. DOI: [10.1016/j.rse.2014.11.023](https://doi.org/10.1016/j.rse.2014.11.023).
- **Ghimire, B., et al. (2014).** Global albedo change and radiative cooling from anthropogenic land cover change, 1700 to 2005 based on MODIS, land use harmonization, radiative kernels, and reanalysis. *Geophysical Research Letters*, **41**, 9087–9096. DOI: [10.1002/2014GL061671](https://doi.org/10.1002/2014GL061671).
- **Pya, N., & Wood, S. N. (2015).** Shape constrained additive models. *Statistics and Computing*, **25**, 543–559. DOI: [10.1007/s11222-013-9448-7](https://doi.org/10.1007/s11222-013-9448-7).

*Reference identities and supporting passages were checked manually against publication records and full text. The combined automated reference audit was not run because its workflow requires file writes. No files were changed and no models were fitted.*