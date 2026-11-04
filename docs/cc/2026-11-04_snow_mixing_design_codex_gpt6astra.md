*Astra (gpt-6-astra, ultra effort), 4 November 2026: design of mixing snowy and snow-free albedo by MOD10CM. Brief: `2026-11-04_snow_mixing_design_brief.md`. Absolute paths are this workstation's.*

**Summary**

- This would test whether the paper’s forcing depends on the snow frequencies represented in successful albedo retrievals.
- Recommend MOD10CM Collection 6.1, consistent with Chris’s 29 October decision.
- Mix the existing snowy and snow-free `full_75` panels using its monthly snow climatology.
- Leave a mixture missing whenever a component with positive weight is missing.
- Treat the ninth refit as a sensitivity analysis: it cannot repair winter gaps or resolve the northeast model’s confounding.
- Mixing observations before fitting is an adaptation, different from the previously proposed mixing of two models’ predictions.
- Barnes and Roy (2010) and Ghimire et al. (2014) support independent mixing; Lejeune et al. (2020) does not supply that precedent.
- No files were changed, datasets downloaded, or forbidden request directories opened.

## 1. What the mixed albedo should represent

The intended quantity should be **land-surface albedo associated with vegetation under the 2000–2009 snow climatology**, with that climatology held fixed when interpreting past vegetation changes. It includes the effect of vegetation masking snow. It does not reconstruct Holocene snow changes or vegetation-driven changes in snow accumulation and melt.

There is direct precedent. Barnes and Roy combine snowy and snow-free albedo by an independent monthly MOD10CM fraction in equation 3. Ghimire et al. do this at 1° resolution and explicitly hold modern snow climatology fixed through their historical reconstruction. Their albedos are land-cover-class estimates, however, rather than responses for this project’s pollen-based GAM. [Barnes and Roy, 2010](https://doi.org/10.1029/2010JG001428); [Ghimire et al., 2014, §2.3](https://doi.org/10.1002/2014GL061671).

The existing all-days albedo weights snowy conditions by their share of **accepted albedo retrievals**. Clouds, inversion quality and the sun-angle screen influence that share. Independent snow weighting removes its direct dependence on albedo retrieval acceptance. It does **not** remove retrieval bias within either albedo panel, nor MOD10CM’s own cloud and forest limitations.

There is an important distinction from the [recorded snow plan](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/docs/cc/2026-10-29_refit_plan_decisions.md:10). That plan proposed fitting snowy and snow-free models separately and mixing their predictions. The requested new script-2 statistic instead mixes observed responses and fits one model. These operations are not equivalent. [Model 8](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/R/model_registry.R:33) has additive location, elevation and vegetation terms; it does not explicitly allow the vegetation effect to vary with snow fraction.

**For this bounded change, describe run 9 as “sensitivity to independent modern snow weighting of the calibration albedo.”** Interpreting it as a vegetation effect under fixed modern snow remains the intended approximation, rather than a demonstrated causal separation.

The reference check also corrects the brief: Lejeune et al. select nearly snow-free and nearly fully snow-covered cells for separate regressions. They do not implement the proposed independent MOD10CM mixture. [Lejeune et al., 2020, §2.3.1](https://doi.org/10.5194/esd-11-1209-2020).

## 2. Snow-cover product

**Use Terra MOD10CM Collection 6.1.** This follows the existing decision and the two direct precedents, while avoiding a new daily processing method.

| Product | What it supplies | Suitability and approximate volume |
|---|---|---|
| [MOD10CM.061](https://doi.org/10.5067/MODIS/MOD10CM.061) | Monthly snow-cover percentage, global 0.05° grid; starts March 2000. | Recommended. **118 monthly files** through December 2009; nominally about **3.3 GB** globally.* |
| [MOD10C1.061](https://doi.org/10.5067/MODIS/MOD10C1.061) | Daily 0.05° snow extent, cloud extent and clear index; starts 24 February 2000. | Allows daily support checks and a custom monthly calculation. Up to **3,599 files**, nominally **14.4 GB** globally.* |
| [MOD10A1.061](https://doi.org/10.5067/MODIS/MOD10A1.061) | Daily nominal 500 m snow detection/NDSI and quality information; starts 24 February 2000. | Better spatial matching, substantially more processing. Nominally **7.2 GB per tile** for the period.* NDSI divided by 100 is **not** snow-covered area fraction. |
| [MOD10A2.061](https://doi.org/10.5067/MODIS/MOD10A2.061) | Eight-day maximum snow extent at 500 m, with snow chronology. | Averaging its maximum-extent layer would overrepresent persistence. Nominally **0.45 GB per tile** for the period.* |
| [ESA Snow_cci MODIS SCFG v4.0](https://doi.org/10.5285/375ffdb8f0a445e380b4b9548655f5f9) | Daily ground snow fraction at about 1 km, with canopy correction; covers February 2000–2023. | A closer match to **ground snow beneath forest**, but a larger workflow. The complete archive is **819 GB**; approximately **340 GB** for 2000–2009 is an extrapolation from its average file size, before regional subsetting. |

\*The NASA guide lists approximate file sizes under the ambiguous unit label “Mb”; these totals interpret it as megabytes. They are planning figures, not measured download totals. Confirm archive sizes before acquisition. [NASA Collection 6.1 guide, Table 1](https://modis-snow-ice.gsfc.nasa.gov/uploads/snow_user_guide_C6.1_final_revised_april.pdf). Snow_cci volume comes from its [official catalogue](https://catalogue.ceda.ac.uk/uuid/375ffdb8f0a445e380b4b9548655f5f9/).

**What MOD10CM measures.** Its daily precursor counts 500 m land observations classified as snow, rather than measuring fractional ground snow within each 500 m footprint. MOD10CM averages days with clear index above 70%, adjusting the observed snow percentage for cloud-obscured area. One qualifying day can produce a monthly value. It also applies a low-snow filter based on the mean of nonzero daily contributions—not a blanket removal of monthly means below 10%. Thus it is independently processed snow extent, not an unbiased record of every calendar day. [MOD10C1 guide, §§2.4.1–2.4.3](https://nsidc.org/sites/default/files/mod10c1-v061-userguide_0.pdf); [MOD10CM guide, §2.4](https://nsidc.org/sites/default/files/mod10cm-v061-userguide_0.pdf).

**Years and access.** Obtain MOD10CM.061 HDF-EOS2 files through NSIDC/Earthdata Search, using Earthdata Login. Select March 2000–December 2009 and retain granule identifiers and checksums. January and February have at most nine years; other months have ten. Record actual availability. March 2000 includes four days before the existing albedo build starts on 5 March: retaining the monthly product is a disclosed approximation.

**The forest problem.** Canopies conceal ground snow, with visibility also changing with viewing angle. Consequently, MOD10CM can confuse less visible snow with less snow occurrence. Its separate processing does not make its errors independent of MODIS albedo. Rittger et al. document these mechanisms and a canopy-adjustment method; they do not justify applying an improvised correction to MOD10CM. [Rittger et al., 2020](https://doi.org/10.1029/2019WR024914).

For this project, that creates a particular concern: the snowy albedo panel already contains forest masking, while the snow weight can also depend on forest visibility. This is our inference from the product definitions. Accept MOD10CM as a documented proxy for this sensitivity; consider Snow_cci only if Andria requires an estimate specifically tied to ground snow beneath canopy.

## 3. Calculation and script-2 integration

For cell \(c\) and calendar month \(m\):

\[
\alpha_{\mathrm{mixed},cm}
=
f_{cm}\alpha_{\mathrm{snowy},cm}
+
(1-f_{cm})\alpha_{\mathrm{free},cm}.
\]

Here \(f\) is a fraction from 0 to 1, and both albedo panels describe the observed land surface, including vegetation. The snowy panel is not the albedo of bare snow.

**Build \(f\) once.**

1. Read valid MOD10CM snow percentages and documented good-quality values. Treat water, cloud, night, fill and other invalid codes as missing.
2. Within each year and month, average the 0.05° values into the project’s 1° cells using land-area weights. Derive those weights from the existing albedo land mask, so coastal water does not count as snow-free land. The MOD10CM internal mask still differs; record the land area actually represented.
3. Average those annual cell values equally over available years, then convert percentages to fractions. Record years contributing and land coverage; do not weight years by successful albedo retrieval counts.
4. Use available valid support without adding an arbitrary coverage threshold. A cell-month with no valid snow estimate remains missing.

The independent monthly mixture follows Barnes and Roy and Ghimire. **The exact land weighting, equal-year averaging and missing-support rule above are our adaptations**, proposed for Chris’s approval. They preserve the project’s existing approach to averaging and reporting coverage; the cited papers do not prescribe this precise recipe.

**Keep the existing albedo panels.** Use `full_75_snowy` and `full_75_snowfree` for run 9. Full inversions have precedent in Barnes and Roy; the 75° screen follows Jia et al. This keeps the albedo quality choice aligned with run 1. Do not silently use `any_75` for whichever panel is missing. [Barnes and Roy, 2010, §2](https://doi.org/10.1029/2010JG001428); [Jia et al., 2022, §2.2.2](https://doi.org/10.1029/2021JD035987).

The [existing panel calculation](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/tools/prepare_bluesky_albedo.R:529) retains retrieval weighting within each panel, including annual snow-share weights. These are not independently equal-year panel means. Multiplying separately averaged snow fraction and panel albedos is therefore a **cell-climatology approximation**: it need not equal averaging mixtures over individual years or smaller areas. The ninth run should isolate this weight replacement, with that limitation stated.

**Missing panels: use an explicit rule.**

| Available snow fraction | Required albedo | Result |
|---|---|---|
| \(f=0\) | Snow-free panel | Use it even if snowy albedo is missing. |
| \(f=1\) | Snowy panel | Use it even if snow-free albedo is missing. |
| \(0<f<1\) | Both panels | Missing if either panel is missing. |
| Missing \(f\) | — | Missing mixture. |

Do not round small positive snow fractions to zero to rescue observations. Do not substitute all-days albedo, another month or a neighbouring cell.

Published gap filling exists, but it borrows albedo **within land-cover classes**. Barnes and Roy borrow across ecoregions; Ghimire uses progressively larger spatial neighbourhoods. Borrowing an unconditioned neighbouring cell’s albedo into this vegetation regression would be a different method. Leaving required panels missing is our conservative choice. [Barnes and Roy, §3.1](https://doi.org/10.1029/2010JG001428); [Ghimire et al., §2.2](https://doi.org/10.1002/2014GL061671).

The winter gap remains. Missing calibration responses are omitted from fitting, but the existing pipeline still predicts elsewhere. Those predictions remain extrapolations; independent snow weights do not make them observed.

**Minimal code shape.**

- One stand-alone `tools/prepare_snow_mixed_albedo.R` produces a companion CSV and provenance note. It uses the existing cell table, retained land-mask information and MOD10CM; no daily albedo rebuild is needed. Reuse shared land-mask code rather than copy it.
- The companion contains exact cell/month keys, \(f\), snow-product coverage, contributing years, `full_75_snowmixed`, and a reason where the mixture is missing.
- Add only `analysis$albedo$statistic = "snow_mixed"`. Initially accept it with `source = "modis_cells"` and `version = "full_75"`; reject incompatible combinations.
- Script 2 reads and checks the companion, attaches its mixed column, then uses the existing [exact-centre reader](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/R/preparation.R:95). Register its input paths and provenance. Existing defaults and legacy outputs remain unchanged.

The current CSV’s days and coverage describe **all accepted retrievals**, not each panel. Label them accordingly. Actual panel-specific counts must come from retained monthly sums; multiplying all-days counts by climatological snow shares would not recover them correctly.

## 4. Checks and cost in runs

These are arithmetic and implementation checks, not additional scientific methods.

**Hand-worked cases**

| Snowy albedo | Snow-free albedo | \(f\) | Expected mixture |
|---:|---:|---:|---:|
| 0.60 | 0.20 | 0.25 | 0.30 |
| Missing | 0.20 | 0 | 0.20 |
| 0.60 | Missing | 1 | 0.60 |
| Missing | 0.20 | 0.25 | Missing |
| 0.60 | 0.20 | Missing | Missing |

Also check land weighting: two contributing areas weighted 3:1, with snow fractions 0.8 and 0, must give 0.6. Check equal-year averaging, invalid product codes, reversed latitude ordering, duplicate keys and endpoint handling without evaluating `0 × NA`.

**Use the existing table to explain the change.** Every nonmissing unknown-snow share in the inspected CSV is zero. Where both panels exist, let \(q\) be the existing retrieval snow share. Then:

\[
\alpha_{\mathrm{mixed}}-\alpha_{\mathrm{all}}
=
(f-q)(\alpha_{\mathrm{snowy}}-\alpha_{\mathrm{free}}).
\]

For the first example, \(q=0.10\) gives all-days albedo 0.24 and an increase of 0.06 after mixing. Check this identity within the existing CSV rounding tolerance, and confirm every mixture lies between its two panels.

Before fitting, compare by month and region:

- MOD10CM \(f\) against retrieval share \(q\).
- Mixed, all-days and snow-free albedo on **common cells**.
- Cells lost because of missing snow weights or either panel.
- Snow-product coverage and the separately labelled albedo support.

The read-only inventory already shows a material constraint:

| Existing full-quality panel availability | Cells with both panels |
|---|---:|
| January, all 2,866 table cells | 892 |
| December, all table cells | 937 |
| July / August, all table cells | 518 / 408 |
| January, northeast’s 83 cells | 68 |

These are **not** final mixed-table counts: exact zero or one weights can retain cells with only one panel. All 83 northeast January cells have both panels under `any_75`, illustrating the quality dependence. Summer counts also matter: a small positive external snow fraction can make a previously usable snow-free response missing.

Use the existing monthly fitting gate—currently 748 coefficients for the largest models—after the ice mask and all missing-value checks. Passing the count gate is necessary, but does not establish adequate vegetation coverage.

Verify code through `tools/verify_change.R` in its separate worktree, including unchanged current/legacy preparation results. Scientific code changes require the project’s independent Fable and Astra reviews, followed by reconciliation.

**Run cost: one ninth full refit.** Use the existing workflow through scripts 1–10, including 7a, with new monthly fits and the same recorded seed, models, kernels and ice settings as run 1. Existing snowy and snow-free fits cannot replace fits to mixed responses. No additional full refits are needed for the input-table comparisons.

Report period forcing and monthly northeast albedo/forcing beside runs 1 and 2; use runs 3–7 to interpret quality and winter sensitivity. Examine spring as well as January: the existing runs show that spring darkening can dominate annual forcing. Retain the existing uncertainty calculation, explicitly conditional on the prepared snow and albedo climatologies.

## 5. Recommendation and decisions

**Proceed with the prepared mixed table and, if its monthly support is adequate, a ninth sensitivity run.** It would add a direct, literature-grounded test of whether independent snow weighting changes the forcing’s signs and magnitudes. It would also reveal where missing state-specific albedo prevents that test.

It should not yet replace the headline estimate. Neither independent weighting nor a successful refit establishes the northeast vegetation effect, and the method cannot remove the winter observation gap.

| Decision | Recommendation |
|---|---|
| **Andria: what should the paper estimate?** | State vegetation-associated change under fixed modern snow/climate. Historical snow change needs a separate analysis. |
| **Andria: is MOD10CM’s snow definition adequate?** | Accept its detection-based fraction for this sensitivity, with the forest limitation explicit. Ground-snow claims require considering a canopy-corrected product. |
| **Chris: mixed responses or mixed predictions?** | Approve the requested mixed-response run as a bounded sensitivity. Record that it differs from the earlier two-model prediction plan. |
| **Chris: quality, averaging and gaps?** | Use both `full_75` panels, the stated cell-climatology approximation, and no filling of required missing components. Inspect monthly support before launching. |

These decisions belong in the scientific questions record during implementation; it has not been edited in this read-only session.

## References

- **Barnes, C. A., and Roy, D. P. (2010).** Radiative forcing over the conterminous United States due to contemporary land cover land use change and sensitivity to snow and interannual albedo variability. *Journal of Geophysical Research: Biogeosciences*, **115**, G04033. DOI: [10.1029/2010JG001428](https://doi.org/10.1029/2010JG001428).
- **Ghimire, B., Williams, C. A., Masek, J., Gao, F., Wang, Z., Schaaf, C., and He, T. (2014).** Global albedo change and radiative cooling from anthropogenic land cover change, 1700 to 2005 based on MODIS, land use harmonization, radiative kernels, and reanalysis. *Geophysical Research Letters*, **41**, 9087–9096. DOI: [10.1002/2014GL061671](https://doi.org/10.1002/2014GL061671).
- **Jia, A., Wang, D., Liang, S., Peng, J., and Yu, Y. (2022).** Global Daily Actual and Snow-Free Blue-Sky Land Surface Albedo Climatology From 20-Year MODIS Products. *Journal of Geophysical Research: Atmospheres*, **127**, e2021JD035987. DOI: [10.1029/2021JD035987](https://doi.org/10.1029/2021JD035987).
- **Lejeune, Q., Davin, E. L., Duveiller, G., Crezee, B., Meier, R., Cescatti, A., and Seneviratne, S. I. (2020).** Biases in the albedo sensitivity to deforestation in CMIP5 models and their impacts on the associated historical radiative forcing. *Earth System Dynamics*, **11**, 1209–1232. DOI: [10.5194/esd-11-1209-2020](https://doi.org/10.5194/esd-11-1209-2020).
- **Rittger, K., Raleigh, M. S., Dozier, J., Hill, A. F., Lutz, J. A., and Painter, T. H. (2020).** Canopy Adjustment and Improved Cloud Detection for Remotely Sensed Snow Cover Mapping. *Water Resources Research*, **56**, e2019WR024914. DOI: [10.1029/2019WR024914](https://doi.org/10.1029/2019WR024914).
- **Hall, D. K., and Riggs, G. A. (2021).** MODIS/Terra Snow Cover, Collection 6.1. NASA NSIDC DAAC. Dataset DOIs: [MOD10CM](https://doi.org/10.5067/MODIS/MOD10CM.061), [MOD10C1](https://doi.org/10.5067/MODIS/MOD10C1.061), [MOD10A1](https://doi.org/10.5067/MODIS/MOD10A1.061), [MOD10A2](https://doi.org/10.5067/MODIS/MOD10A2.061).
- **ESA Snow_cci (2025).** Daily global Snow Cover Fraction—snow on ground—from MODIS, 2000–2023, version 4.0. CEDA. DOI: [10.5285/375ffdb8f0a445e380b4b9548655f5f9](https://doi.org/10.5285/375ffdb8f0a445e380b4b9548655f5f9).