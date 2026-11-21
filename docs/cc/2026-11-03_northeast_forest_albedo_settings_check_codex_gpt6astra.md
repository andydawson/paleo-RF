**Verdict: keep the core design, but do not freeze Fable’s settings verbatim.** The 5 km pairing, 50 m elevation difference, 100 m relief limit and proposed averaging are defensible starting choices. They can give the paper a useful local comparison of deciduous and evergreen forest albedo. Their exact thresholds are project judgements, not values established by the cited studies.

I recommend **a labelled `any_75` winter check**, retaining `full_75` results wherever they qualify. I would remove the automatic relaxation ladder, correct the coverage and precision claims, and make the water-grid and boundary rules explicit.

Nothing was changed or downloaded. Nothing under `data/modis_albedo/requests/` was opened.

The settings I would change are:

| Setting | Fable’s value | Mine | Why | Evidence |
|---|---|---|---|---|
| Coverage adjustment | Five-step relaxation ladder | **No automatic relaxation.** Keep main settings fixed; use the declared sensitivities. If feasibility targets fail, return to Chris before examining contrasts. | The 50→75 m step contradicts Chris’s decision. The remaining ladder adds complexity and leaves “pairs” undefined across months and years. | Chris’s instruction; [approved design](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/docs/cc/2026-11-03_northeast_forest_albedo_design_v2_codex_gpt6astra.md:104). |
| Winter version | `full_75` Mar–Oct, `any_75` Nov–Feb | Show **separate, labelled `full_75` and `any_75` series throughout the year**. Use `any_75` for the supplementary winter interpretation. | Avoid a seasonal curve whose retrieval method changes at November and March. Full-inversion winter absence has not been established. | Local counts below; Wang et al., cited below. |
| Solar-angle sensitivity | Treat 70° and 75° as indistinguishable | Retain 75° main; add the existing **`full_70` comparison separately**. | They differ in northern January and December cells. | [December CSV row](/home/expert/Documents/contracting/Andria/paleo-RF/data/albedo_modis_cells.csv:12145); [NASA guidance](https://modis-land.gsfc.nasa.gov/ValStatus.php?ProductID=MOD43). |
| Water screening | None of the 36 subpixels is water | Require **all 36 explicitly classified land**, with correct global-grid alignment; missing/fill fails. Apply to both members. | “Not water” can accidentally admit missing values. The cropped mask begins partway through a 500 m block. | [Alignment record](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/docs/cc/2026-10-15_albedo_rebuild_reconciliation_codex_gpt6astra.md:23). |
| Geographic scope | Box, 83 cells, partners outside by 5 km | Explicitly restrict ENF centres to the **83 existing pipeline cells** inside the box. Require complete search and classification neighbourhoods. Outside-partner allowance follows each run’s radius. | The rectangle contains 112 possible cells. The three `v04` tiles end at 40°N, so southern searches cannot silently extend beyond their coverage. | [Grid geometry](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/tools/prepare_bluesky_albedo.R:209). |
| Wetland sensitivity | Looser flag requires ≥5 of 9 years | Keep the **any-year centre flag unchanged**. Use neighbourhood wetland exclusion only as a separate restriction of the unflagged group. | Otherwise occasional wetland labels become “unflagged,” changing the meaning of the comparison. | This is a design judgement; product definitions below. |
| Reporting threshold | 30 pairs/3 cells means “supported” | Call it **“coverage threshold met.”** Count distinct pairs, and report unique DBF partners and contributing years separately. | Repeated years, reused partners and nearby pixels are not independent replicates. This threshold establishes neither statistical support nor ±0.02 precision. | [Approved averaging and uncertainty rules](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/docs/cc/2026-11-03_northeast_forest_albedo_design_v2_codex_gpt6astra.md:128); Stuart below. |
| Precision variants | ±0.02 main; ±0.01 strict; ±0.05 “sign only” | Keep **±0.02 solely as the project’s discrimination target**; remove the other settings. | Precision is not an analysis switch. ±0.05 cannot reliably resolve the sign of a +0.02 contrast. | Approved design; arithmetic. |
| Sign stability | Same pooled signs and ≥⅔ cells | Retain as **descriptive sign agreement**, with zeros counted as nonagreement; assess adequately represented latitude and wetland strata separately. | A pooled sign can conceal a southern or wetland reversal. The rule is not a significance test. | Approved design’s geographical interpretation requirements. |
| Sensitivity bundles | Everything stricter/looser together | Bundle the numerical screening rules. Keep retrieval version, wetland definitions and reciprocal matching separate. | These change different aspects of the comparison and are not a single ordered scale of strictness. | Matching and product evidence below. |

**The local data checks confirm most quoted numbers, but not the inference drawn from them.**

At 72.5°W and 41.5–47.5°N, I reproduced:

| Month/version | Coverage range | Qualifying days range |
|---|---:|---:|
| January `full_75` | 0.0129–0.3158 | 0.06–2.90 |
| January `any_75` | 0.6276–0.9781 | 9.54–25.11 |
| April `full_75` | 0.6217–0.9087 | 5.36–19.31 |
| July `full_75` | 0.5324–0.9323 | 6.41–12.86 |
| November `full_75` | 0.1488–0.9556 | 1.58–14.38 |
| December `full_75` | 0.0019–0.4779 | 0.01–3.02 |
| February `full_75` | 0.0316–0.4069 | 0.14–3.17 |

These are **all-land cell averages**, including zero-day pixels, averaged over cell-years with some qualifying data. Entirely empty cell-years are omitted. They are neither forest-specific counts nor distributions of individual pixel counts. Also, March–December can include **2000**, whereas this check uses **2001–2009**. The definitions are explicit in [the cell-table code](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/tools/prepare_bluesky_albedo.R:893).

Consequently, “almost no winter pixel has five qualifying days” remains unverified. November at 41.5°N has **14.38 days per land pixel and 95.56% coverage**, directly contradicting a blanket description of November–February as nearly empty.

Other checked facts:

- **Snow shares:** Fable’s figures describe `full_75`. January’s northern values round to 1.00 but are not all exactly one. At 47.5°N, January snow share is **0.999556 for `full_75` versus 0.928431 for `any_75`**. April’s southern “zero” is also rounded: at 42.5°N it is 0.000099 for `full_75`, versus 0.013637 for `any_75`. Keep the version attached to every snow-share statement.
- **70° versus 75°:** April and July match across the 83 cells at stored precision. January differs slightly in 13 northern-row cells. At 72.5°W, 47.5°N in December, `full_75` versus `full_70` gives **0.70 versus 0.55 days**, coverage **0.1369 versus 0.1216**, and albedo **0.190886 versus 0.198939**.
- **Unknown snow:** all four versions’ recorded unknown shares are zero across the 83-cell CSV subset. They are rounded to six decimals; retain the underlying count checks.
- **Cell counts:** 83 cells; latitude-row counts **6, 9, 8, 6, 12, 14, 14, 14**; **29 south and 54 north** of 44°N—all correct.
- **Hand arithmetic:** all-days **+0.0108333**, snow-free **+0.045**, snowy absent, snow-share difference **−0.166667**—correct. The weighting example gives **0.040000** equally by cell and **0.059215686** by pair.
- **Geometry:** the same-column step is **618.733 m** near 44°N, 73°W. But **1.39 km is not a universal minimum ground separation** between opposite-class 3×3 centres: three columns plus one row gives approximately **1.084 km** while their neighbourhoods remain disjoint. Great-circle distance is the correct rule.
- **Water:** the stored 2015 C6.1 mask is native sinusoidal. Its crop starts **7,447 columns and 5,279 rows** from the global origin. Form the 2×2 subpixel groups from global coordinates, not the cropped array’s first row and column. [Input record](/home/expert/Documents/contracting/Andria/paleo-RF/data/mod44w/2015/README.md:47).

**The product and literature checks support the general approach, with these qualifications.**

1. **Land-cover codes are correct.** ENF=1, DBF=4, mixed forest=5; the forest definitions require tree cover >60%. `QC=0` means classified land, **not high confidence in forest type**. `LC_Prop3=27` means woody wetlands, including shrub/tree cover >10%, height >1 m and permanent or seasonal inundation. Nine identical labels are not independent confirmations: HMM processing already suppresses annual instability. The guide warns against interpreting annual label changes as reliable land-cover change. [MCD12Q1 C6.1 guide, algorithm description and Tables 3, 10–11](https://lpdaac.usgs.gov/documents/1409/MCD12_User_Guide_V61.pdf). The associated reference is Sulla-Menashe et al. (2019), *Hierarchical mapping of annual global land cover 2001 to present: The MODIS Collection 6 Land Cover product*, **Remote Sensing of Environment 222**, 183–194, [DOI 10.1016/j.rse.2018.12.013](https://doi.org/10.1016/j.rse.2018.12.013).

2. **The footprint concern is real; the neighbourhood sizes remain judgements.** Tan et al. (2006), *The impact of gridding artifacts on the local spatial properties of MODIS data*, **Remote Sensing of Environment 105**, 98–114, [DOI 10.1016/j.rse.2006.06.008](https://doi.org/10.1016/j.rse.2006.06.008), discusses observation/grid mismatch and patch-scale comparisons in §§4.3–4.4. It does not validate these particular 3×3, 5×5 or seven-year rules. [Checked passage](https://sites.bu.edu/cliveg/files/2013/09/tanbin03.pdf).

3. **GMTED accuracy was remembered reasonably for this layer.** Danielson and Gesch (2011), *Global multi-resolution terrain elevation data 2010 (GMTED2010)*, USGS Open-File Report 2011–1073, [DOI 10.3133/ofr20111073](https://doi.org/10.3133/ofr20111073), Table 7 gives **26.72 m global RMSE** for the 30-arc-second mean layer. That does not specify local pair-difference error or resolve variation within a pixel. Keep Chris’s **50 m main limit**. The 3×3 range is a coarse relief screen, not a slope measurement.

4. **The five-day precision calculation is invalid.** Wang et al. (2018), *Capturing rapid land surface dynamics with Collection V006 MODIS BRDF/NBAR/Albedo (MCD43) products*, **Remote Sensing of Environment 207**, 50–64, [DOI 10.1016/j.rse.2018.02.001](https://doi.org/10.1016/j.rse.2018.02.001), describes overlapping 16-day inputs and reports forest validation RMSEs around 0.014–0.024, depending on forest and quality. These are not independent daily errors. Keep five days as an availability rule; delete \(0.02\sqrt{2/5}\). [Methods and Table 5](https://harvardforest1.fas.harvard.edu/publications/pdfs/Wang_RemoteSensingEnv_2017.pdf).

5. **Cescatti does not validate snowy winter `any_75`.** Cescatti et al. (2012), *Intercomparison of MODIS albedo retrievals and in situ measurements across the global FLUXNET network*, **Remote Sensing of Environment 121**, 323–334, [DOI 10.1016/j.rse.2012.02.019](https://doi.org/10.1016/j.rse.2012.02.019), used Collection 5, snow-free, full-inversion retrievals and solar elevation above 20° (§2.2). [Checked paper](https://www.cen.uni-hamburg.de/en/icdc/data/land/docs-land/cescattietal-rse-2012.pdf).

6. **The matching precedents need narrower attribution.**
   - Zhao and Jackson (2014), *Biophysical forcings of land-use changes from potential forestry activities in North America*, **Ecological Monographs 84**, 329–353, [DOI 10.1890/12-1705.1](https://doi.org/10.1890/12-1705.1), used a **15 km radius**, slope <15°, elevation difference <10 m, and averages of eligible partners. Their three-pair rule concerned one-degree forcing grids. These support components, not our exact thresholds.
   - Duveiller, Hooker and Cescatti (2018), *A dataset mapping the potential biophysical effects of vegetation cover change*, **Scientific Data 5**, 180014, [DOI 10.1038/sdata.2018.14](https://doi.org/10.1038/sdata.2018.14), used approximately **25×25 km regression windows**.
   - Li et al. (2015), *Local cooling and warming effects of forests based on satellite observations*, **Nature Communications 6**, 6603, [DOI 10.1038/ncomms7603](https://doi.org/10.1038/ncomms7603), describes its window as approximately **50×28 km**, not 45×25 km.
   - Stuart (2010), *Matching methods for causal inference: A review and a look forward*, **Statistical Science 25**, 1–21, [DOI 10.1214/09-STS313](https://doi.org/10.1214/09-STS313), supports outcome-blind matching and replacement, while warning about dependence and concentrated reuse. It does not justify “effective sample size = pairs/3.”

Fable’s “size only” distinction should be deleted: distance, terrain, retrieval rules and aggregation can all change the sign by changing the sample or its weights. Likewise, canopy-hidden snow does not guarantee negative bias in both separated panels. All-days avoids conditioning on the detected snow label; it remains exposed to retrieval and availability biases.

**For winter, I recommend `any_75` as a supplementary result rather than abandoning the check.** Coverage is substantially better, and the choice can be declared now. However, magnitude inversions use prior BRDF information: in Collection 6 this comes from each pixel’s recent high-quality retrievals, separately for snow-covered and snow-free conditions. Winter therefore needs an explicit lower-quality label, not the same evidential weight as well-covered full inversions. [Wang et al., §2.1.3](https://harvardforest1.fas.harvard.edu/publications/pdfs/Wang_RemoteSensingEnv_2017.pdf).

Keep full inversions visible wherever they pass. Report the magnitude-inversion share for each member, and compare versions on their common eligible pair-year subset as well as their full available samples. A winter panel that fails its coverage rules stays thin or absent. NASA’s >70° caution also remains relevant; the stored `full_70` comparison cannot provide an equivalent `any_70` test. [NASA validation guidance](https://modis-land.gsfc.nasa.gov/ValStatus.php?ProductID=MOD43).

The following is the **final settings table I recommend freezing**. “Fixed” means unchanged across sensitivities; alternative thresholds never replace the main result after seeing outcomes.

| Setting | Main value | Stricter check | Looser check |
|---|---|---|---|
| Contrast | DBF minus ENF; albedo on 0–1 scale | Fixed | Fixed |
| Period and footprint | 2001–2009; ENF centres in the 83 pipeline cells within 80–66°W, 40–48°N | Fixed | Fixed |
| Forest classes | `LC_Type1` 1 versus 4; mixed forest excluded | Fixed | Fixed |
| Centre stability | Same class in all nine years, both members | Fixed | Fixed |
| Neighbourhood | Entire 3×3 same class in every year | 5×5 every year | Entire 3×3 same class in ≥7 years; centre still stable all nine |
| Classification QC | Centre `QC=0` in all nine years, both members | Fixed | Fixed |
| Land/water | Both centres pass record-wide `is_land`; all 36 aligned MOD44W-2015 subpixels beneath each 3×3 explicitly land | All 100 beneath 5×5 land | Centre’s own four subpixels land |
| Wetland strata | Centre `LC_Prop3=27` in any year flags member; neither/one/both reported; missing flags never silently called unflagged | Separate unflagged subset with no flag anywhere in either 3×3 | No alternative flag definition |
| Elevation source | Native GMTED2010 30-arc-second mean cell containing each centre; retain native georeferencing | Fixed | Fixed |
| Pair elevation difference | **≤50 m** | ≤25 m | ≤100 m, diagnostic only |
| Local relief | Each centre’s containing GMTED cell and eight neighbours: range ≤100 m; complete valid neighbourhood required | ≤50 m | ≤200 m |
| Pair distance | Nearest eligible DBF within **5 km great-circle distance**; exact ties by fixed pixel ID | 3 km | 10 km |
| Boundary handling | Complete search and neighbourhood coverage; count excluded boundary centres. No silently truncated searches at 40°N | Apply same rule to chosen radius | Apply same rule to chosen radius |
| Replacement | DBF reuse allowed; report unique partners and reuse distribution | Reciprocal nearest-pair subset as a **separate diagnostic** | Same as main |
| Albedo versions | `full_75` and `any_75` reported separately throughout; `any_75` supplies supplementary Nov–Feb interpretation | Existing `full_70`, separately | No additional version |
| Minimum days | Both members ≥5 days on that panel’s own count | 8 | 3 |
| Count ratio | `min(n_all)/max(n_all) ≥0.7`, within pair/year/month/version | ≥0.8 all-days and ≥0.7 own-panel | ≥0.5 all-days |
| Snow panels | Corresponding `s_all/n_all`, `s_free/n_free`, `s_snow/n_snow`; unknown share and DBF−ENF snow-share difference reported, never filtered | Fixed | Fixed |
| Aggregation | Pair mean → cell-year mean → equal-year cell mean → equal-cell mean; alongside mean of all eligible pair-year contrasts | Cell-year requires ≥3 pairs | Same as main |
| Coverage display | ≥30 distinct pairs across ≥3 cells: “coverage threshold met”; otherwise “thin”; always show unique DBFs and years | 50/5, display only | 10/2, display only |
| Latitude | Eight one-degree bands and 40–44°N/44–48°N halves, assigned by ENF cell | Fixed | Fixed |
| Sign agreement | Nonzero equal-cell and pair-weighted means agree; ≥⅔ contributing cell means share sign; assess represented strata separately | Fixed | Fixed |
| Precision target | ±0.02 as a practical target, **not a claimed uncertainty interval** | No alternative | No alternative |
| Feasibility targets | ≥300 distinct structural pairs; ≥30 cells with ≥3 pairs; separately report southern cells, with <5 raised to Chris | Fixed | Fixed |
| Adjustment after coverage | **None automatically.** Failure prompts review before contrasts are read | — | — |

The all-stricter and all-looser bundles can remain **joint stress tests** using neighbourhood, water, elevation, relief, distance, days, ratio and cell-year eligibility. An unchanged bundled sign does not prove insensitivity to each component: opposing changes can cancel. Any subsequent one-at-a-time runs must be labelled diagnostic and cannot redefine the headline result.

Freeze every declared geographic pair table before reading albedo sums. Keep it fixed across months, years, snow panels and retrieval versions; a failed retrieval removes the pair from that panel without finding a replacement. Dropping the separate positive-count step is safe after the own-panel minimum has passed, provided zero and missing denominators are handled explicitly. Unknown snow can remain a reported share, while residual counts and sums are retained internally for the approved mixture check.