Use a stand-alone calculation with the saved headline hindcasts, changing only the ice fractions. NADI-1 supplies all 22 required ages from 1,000 to 11,500 BP without interpolation. Carry its 1 ka fractions into the three younger slices, as agreed. Compare the old raster, fractions calculated from the old polygons, and NADI-1 using the same cells and area calculation.

**Readvance does not break the partial-ice total.** Its vegetation and ice components do, however, embody a particular attribution: during advance, vegetation change is counted on some land that ends under ice. That distinction matters when reporting the components separately.

**The existing averaging does not remove readvances.** On the 2,655 cells used for forcing, the old raster has 186 advancing cell-pairs; averaging produces 228, including 75 newly created advances. The meeting comparison should therefore say “readvances kept” versus “existing one-pass averaging.”

The specified saved run matches the current headline, and it contains vegetation albedo at every required cell, age and month. A Python replay reproduced its partial-ice albedo differences exactly. Numerical availability is established; the credibility of vegetation values beneath reconstructed ice remains a scientific qualification.

One implementation decision needs Chris’s approval: avoiding duplicated arithmetic requires a small shared-code refactor. It would preserve existing pipeline results, but would still edit pipeline code. The design below makes that proposal explicit.

---

**The files support the comparison, with two chronology qualifications.** I checked the repository, saved RDS tables, raster and NADI file metadata without changing files. No new ice-forcing results or figures have been generated.

The NADI download contains 147 shapefiles: 49 ages, at 500-year spacing from 25 to 1 ka, each with OPTIMAL, MIN and MAX alternatives. The coordinate system is WGS84. The inspected attribute table contains `Area_Km2`, without separate grounded-ice, floating-ice or lake classifications.

The paper’s relevant passages establish the following:

| Passage in Dalton et al. 2023 | What it supports |
|---|---|
| §1, p. 4 | Calendar-age reconstruction of Laurentide, Cordilleran and Innuitian ice; Greenland and separate western-US mountain glaciers excluded. |
| §2.6, p. 8; §4, p. 15 | MIN/MAX accommodate dating and mapping uncertainty: “the ice margin could have been anywhere between the minimum and maximum ice extents.” These are not statistical confidence intervals. |
| §§3.1–3.3; §4.6.3 | Marine margins are represented; reconstructing glacial lakes remains future work. Separate floating-shelf coverage was not established. |
| §3.8 | Advances at 9 ka near Quebec/Ontario and 11 ka into Manitoba, associated with the Pas moraine. |
| §3.7; §3.14 | Lake Gribben/Marquette and central Cordilleran advances at 11.5 ka. |
| §3.14–3.15 | Cordilleran reconstruction stops at 10 ka; Alaska Range remnants continue to 1 ka. |
| §4 | Snapshot spacing can miss smaller intervening advances. |

Reference: Dalton, A. S., et al. (2023), *Deglaciation of the North American Ice Sheet Complex in calendar years based on a comprehensive database of chronological data: NADI-1*, **Quaternary Science Reviews 321**, 108345, DOI **10.1016/j.quascirev.2023.108345**. [Institutional record](https://dspace.library.uvic.ca/items/fa82de09-6298-46e4-9a9d-f0d45083a54a/full); [full-text copy inspected](https://www.researchgate.net/publication/376111765_Deglaciation_of_the_North_American_Ice_Sheet_Complex_in_calendar_years_based_on_a_new_comprehensive_database_of_chronological_data_NADI-1). Cite the [NADI-1 dataset](https://zenodo.org/records/8161764), DOI **10.5281/zenodo.8161764**, separately.

Two distinctions must remain visible:

- **Snapshot versus vegetation bin.** Matching a NADI snapshot to a slice’s numerical label is the agreed project approximation. It does not turn that snapshot into an average over Andria’s vegetation bin. Use 11.5 ka ice for the oldest forcing slice; do not substitute 12 ka because the saved output labels that period “10–12 ka.”
- **Old dating convention remains unknown.** Dalton et al. 2020 retained uncalibrated radiocarbon chronology, while also providing calibrated equivalents. Neither the raster filenames nor the interpolation recollection establishes which scale was used to make this project’s raster. Comparing the operational files is valid; attributing every difference to improved reconstruction requires the missing provenance. Dalton et al. (2020), *An updated radiocarbon-based ice margin chronology…*, **QSR 234**, 106223, DOI **10.1016/j.quascirev.2020.106223**, introduction and Table 1. [Publisher](https://doi.org/10.1016/j.quascirev.2020.106223)

**Calculate ice fractions by intersecting the polygons with the existing cells.** This gives Andria a comparison in which the new and old polygons have undergone the same spatial calculation.

For cell \(C_i\) and ice polygon union \(P_t\), use

\[
f_{i,t}=\frac{\operatorname{area}(C_i\cap P_t)}
                   {\operatorname{area}(C_i)}.
\]

The implementation should:

1. Read cell boundaries and identifiers from `data/grid.RDS`; retain the existing grid alignment.
2. Preserve polygon holes, check validity and dissolve overlapping ice polygons within each age and alternative.
3. Calculate intersections and areas consistently using `sf`. A suitable implementation is an equal-area northern projection, with geographic cell edges sufficiently subdivided before projection to preserve their latitude boundaries. Record the projection and confirm that halving the subdivision changes fractions negligibly.
4. Use **whole-cell area**, as the existing forcing does. Do not introduce a land-only denominator or a new coastline mask during this comparison.
5. Retain missing coverage as missing, rather than interpreting an absent file or failed geometry as zero ice.
6. Check fractions against \([0,1]\), area conservation, and MIN–OPTIMAL–MAX nesting. Report meaningful nesting failures; do not silently reorder or alter the reconstructions.

The projection and numerical tolerances are implementation choices. The published principle is overlap-area conservation with consistent cell areas; the precedent and passage are given below.

Calculate the **21 old polygon sets with the same function**. Their native-age comparison with NADI is the cleanest comparison of polygon reconstructions. For displaying the old polygon-based mask at the pipeline’s half-millennium labels, reproduce its existing nearest-age rule, with ties to the younger age, and label it explicitly.

Do not make interpolated polygon vertices. Nor is a new interpolated old-polygon fraction series necessary for the main comparison: the old raster already supplies the operational forcing input. If fractional linear interpolation is later requested, distinguish that new project product from both the old mask and Andria’s unidentified interpolation procedure.

There are three useful spatial scopes:

| Scope | Purpose |
|---|---|
| Fixed union of prediction cells | Compare ice inputs without changes in vegetation coverage changing the map’s denominator. |
| **The saved run’s 2,655 forcing cells** | Primary old/new forcing and corresponding ice-area comparisons. |
| Native reconstruction extent | Source-level ice-area and readvance diagnostics, clearly separate from the study-area results. |

There are 2,657 prediction cells inside the geographic forcing limits. Two western cells lie outside the old raster: centres at **167.5°W, 65.5°N** and **166.5°W, 65.5°N**. Freeze the existing 2,655-cell set for the principal comparison; list the two exclusions rather than silently expanding the study area.

This calculation retains the project’s simplified treatment of mixed cells. It does not introduce changing palaeoshorelines, glacial-lake albedos or a separate marine-ice forcing model.

**Use three compact comparison tables and a small set of maps.**

| Output | Contents |
|---|---|
| Input and age table | Source, native ages, age convention, mapping to each vegetation slice, young-slice rule, spatial coverage and unresolved provenance. |
| Ice area by slice | Old raster, old polygons and NADI alternatives on fixed support; NADI-minus-old area; area-weighted absolute fractional difference; counts with any ice and over 50%. |
| Agreement and support table | Area where old fractions lie below, within or above NADI’s range; disagreement with the old vegetation ice flag; area dependent on vegetation predictions beneath old ice. |

For figures:

- Plot ice area through time, with NADI optimal as a line and MIN/MAX extent as a shaded range, subject to the nesting check.
- Make old-raster versus NADI-optimal fractional-difference maps at **11.5, 10, 8, 6 and 1 ka**. Put the complete slice series in a supplementary PDF.
- On selected margin maps, show the NADI MIN–MAX belt and old polygon outline.
- Give the modern disagreement a separate small panel: the original **48 cell-centre flags**, **28 cells over half ice**, and **156 cells with any raster ice** are different definitions, not three interchangeable estimates of glacier area. Recount them on explicitly stated support.

Old raster versus newly calculated old-polygon fractions cannot isolate a pure rasterisation effect: their source chronology may also differ. Say what each comparison holds constant.

**Inventory both net increases and advancing polygon edges.** A cell’s ice fraction can stay unchanged while ice retreats on one side and advances on another.

For each older-to-younger pair, retain:

\[
\Delta f=f_y-f_o,\qquad
\Delta A=\operatorname{area}(C_i)\Delta f.
\]

A positive \(\Delta f\) is a **net increase in reconstructed cell ice coverage**. For polygon inputs also calculate:

- newly covered area: \(P_y\setminus P_o\);
- newly exposed area: \(P_o\setminus P_y\).

This identifies advancing margins hidden by simultaneous retreat within a cell. The old raster cannot supply that subcell information.

Keep every positive numerical change in the audit table, flagging values at the geometry precision limit. Summarise increases **over 0.01** and **over 0.10** of a cell to match the existing audit. These are descriptive project thresholds, not published definitions of a physical readvance. Report square kilometres alongside fractions.

Each inventory row should give source, treatment, location, older and younger ages, endpoint fractions, increase, area gained, threshold category and NADI-range assessment. Polygon rows also give gross gain and loss. Count events once per cell and age pair, never once per month.

Run the source-level inventory over all supplied native dates; mark the subset entering the forcing. In particular, include **12→11.5 ka** in the diagnostic inventory, although it cannot enter the forcing because there is no 12 ka hindcast endpoint. Keep native 1,000-year old-polygon counts separate from 500-year NADI counts.

For NADI bounds \(L_t\) and \(U_t\), calculate

\[
L_y-U_o\ \leq\ \Delta f\ \leq\ U_y-L_o.
\]

This gives a transparent range check:

- lower bound positive: increase persists across the endpoint bounds;
- interval straddles zero: direction is unresolved by those bounds;
- upper bound nonpositive: increase is not supported within those bounds.

For an old-input advance, report **both** whether its endpoint fractions lie within NADI’s same-age bounds **and** whether its increase lies within this difference interval. These tests are not probabilities or proof of a jointly plausible history.

Use the following evidence ladder when interpreting an increase:

1. Does it exist in the native polygons?
2. Does it survive consistent area intersection?
3. Is it present before temporal assignment or interpolation?
4. Is it created or moved by the averaging?
5. Does its location and timing correspond to regional evidence discussed in the reconstruction?

A mapped increase should not automatically acquire a geological event name. Conversely, absence between snapshots does not prove that no readvance occurred.

The old-raster reconciliation is already established:

| Scope and treatment | Advancing cell-pairs | Distinct cells |
|---|---:|---:|
| Whole raster, raw | 215 | 103 |
| Existing forcing cells, raw | 186 | 85 |
| Existing forcing cells, raw increase \(>0.01\) | 97 | 54 |
| Existing forcing cells, raw increase \(>0.10\) | 16 | 10 |
| Existing forcing cells, after averaging | 228 | 62 |
| Saved albedo-difference table, including outer latitudes, after averaging | 237 | 66 |

Thus **2,844 = 237 × 12 months**. Within the forcing domain, **2,736 = 228 × 12**. Of those 228 adjusted advances, 153 persist from raw advancing pairs and 75 are newly introduced.

**The formula audit should separate correctness of the total from meaning of the components.** The relevant implementation is [R/differences.R](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/R/differences.R:38), with existing worked cases in [tests/test_differences.R](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/tests/test_differences.R:46).

Let \(f_o,f_y\) be older and younger ice fractions, \(a_o,a_y\) vegetation albedos, and \(A\) glacier albedo for the month. The exact mixed-cell change is

\[
D=\{f_yA+(1-f_y)a_y\}-\{f_oA+(1-f_o)a_o\}.
\]

The current components are

\[
V=(1-f_o)(a_y-a_o),\qquad
I=(f_y-f_o)(A-a_y).
\]

**Their sum equals \(D\)** for retreat, advance, unchanged ice, and zero, partial or complete ice. Independent Python checks of 3,136 combinations gave a maximum rounding residual of \(2.22\times10^{-16}\).

For the threshold sensitivity, define each endpoint as glacier albedo when \(f>0.5\), otherwise vegetation albedo, then subtract younger minus older. The threshold vegetation component applies only when both ends are classified as vegetation; otherwise the change belongs to its ice component.

These worked numbers use \(A=0.68,\ a_o=0.20,\ a_y=0.30\), **before averaging**:

| Ice fraction, old → young | Partial vegetation | Partial ice | Exact / partial total | Threshold vegetation | Threshold ice |
|---|---:|---:|---:|---:|---:|
| 0 → 0 | .100 | .000 | .100 | .100 | .000 |
| 0 → .3 | .100 | .114 | .214 | .100 | .000 |
| 0 → 1 | .100 | .380 | .480 | .000 | .480 |
| .3 → 0 | .070 | −.114 | −.044 | .100 | .000 |
| .3 → .3 | .070 | .000 | .070 | .100 | .000 |
| .3 → .7 | .070 | .152 | .222 | .000 | .480 |
| .7 → .3 | .030 | −.152 | −.122 | .000 | −.380 |
| .3 → 1 | .070 | .266 | .336 | .000 | .480 |
| 1 → 0 | .000 | −.380 | −.380 | .000 | −.380 |
| 1 → .3 | .000 | −.266 | −.266 | .000 | −.380 |
| 1 → 1 | .000 | .000 | .000 | .000 | .000 |
| .5 → .5 | .050 | .000 | .050 | .100 | .000 |

The threshold total is the sum of its last two columns. Structural non-applicable components are displayed as zero, following the existing completion helper.

For **no vegetation change**, set \(a_o=a_y=0.20\). Then \(V=0\) and \(D=I=0.48(f_y-f_o)\). Threshold change is zero within either class, \(+0.48\) on crossing into ice and \(-0.48\) on crossing out. Together with the endpoint definition, this covers all no-ice/partial/full combinations, both directions of partial change, unchanged fractions, and cases entirely above or below 50%.

For the executable audit, cross fractions \(\{0,.3,.5,.7,1\}\) at both endpoints with unchanged, increasing and decreasing vegetation albedo. That is clearer than maintaining a separate hand-written calculation for every case.

The attribution issue is concrete. For the `.3 → .7` advance above:

- current vegetation / ice: **.070 / .152**;
- vegetation confined to land remaining exposed, assuming nested margins: **.030 / .192**;
- total in both: **.222**.

The current split means “change vegetation while holding older ice fixed, then change ice using younger vegetation.” It is valid accounting, but is not vegetation change only on persistently exposed land.

The smallest alternative for **nested margins** is

\[
V_{\rm exposed}=(1-\max(f_o,f_y))(a_y-a_o),\qquad
I_{\rm exposed}=D-V_{\rm exposed}.
\]

For actual, potentially non-nested polygons, let \(L\) be persistently ice-free fraction, \(R\) newly exposed, \(G\) newly covered and \(Q\) persistently iced. Then

\[
D=L(a_y-a_o)+R(a_y-A_o)+G(A_y-a_o)+Q(A_y-A_o).
\]

Calling the first term vegetation and the remainder ice is geographically explicit. It requires polygon overlap and cannot be recovered uniquely from the old raster fractions. **Both attribution alternatives are proposals for Chris, not automatic changes.**

The remaining edge cases should be stated plainly:

- **Changing glacier albedo through time:** current total minus exact total is \(f_y(A_o-A_y)\). It is zero for both existing glacier-albedo variants, because each depends on month, not age. If age-dependent glacier albedo is introduced later, use complete endpoint states.
- **Vegetation beneath full ice:** its value cancels from the total but can affect the separate components. A missing value can also propagate through `NA × 0` even where the physical total is defined. Do not fill such values arbitrarily.
- **Threshold advance and double count:** these are genuine faults of the historical threshold arithmetic. The configured `endpoint` method already fixes them. The existing tests should demonstrate the old failure and current correction.
- **Different threshold and fractional answers:** these are expected consequences of two surface representations, not arithmetic defects.

**Audit averaging as an operation on the chronology, before calculating albedo.** It currently makes one simultaneous, unweighted neighbour substitution at [R/differences.R:45](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/R/differences.R:45). It does not iterate to monotonic retreat.

Two diagrams should accompany the formula examples:

- Youngest-first fractions `(.95, .95, .90, .10)` become `(.95, .925, .525, .10)`. Advances remain, and a previously equal youngest pair becomes an advance.
- At ages `50, 200, 500, 1000, 1500`, fractions `(.4, .4, .4, .4, .2)` become `(.4, .4, .4, .3, .2)`. Averaging creates an advance from 1,000 to 500 BP despite the raw carry-forward rule.

The youngest-pair index fault is separate: the code references a nonexistent younger neighbour. With two slices it fails; with longer sequences it can use recycled, inappropriate values. The smallest proposed correction is an explicit boundary rule—preferably stop with a clear message, or retain that endpoint if Chris chooses. The prescribed raw young-slice carry-forward should avoid this trigger in this analysis.

Carry the raw 1 ka fractions forward **before** either calculation. Do not silently carry them forward again after averaging: that would be a different adjustment and would prevent faithful replay.

A completely monotone chronology would be a new scientific treatment. No inspected source supports introducing one as a routine correction.

**Recompute forcing from the saved prediction summaries and fixed kernels.** The specified run has the requested model, MODIS settings, calibration exclusion, partial-ice headline and endpoint sensitivity.

Use `output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS`, specifically its saved `alb_mean`. Do not substitute deterministic point predictions or regenerate stochastic hindcasts.

The main calculation is a small factorial comparison:

| Ice input | Keep raw fractions | Existing one-pass averaging |
|---|---:|---:|
| Old raster | Calculate | Reproduce saved run |
| NADI optimal | Calculate | Calculate |
| NADI minimum | Calculate | Calculate |
| NADI maximum | Calculate | Calculate |

Use current component attribution for this comparison, labelled explicitly, unless Chris chooses otherwise. Keeping it fixed isolates the ice-input and averaging effects.

For each calculation:

1. Attach fractions to the same 2,655 cells at all 25 ages.
2. Call the shared difference function once per cell and month, with an explicit averaging choice.
3. Use the saved kernel values, verified invariant across ages for each cell and month.
4. Calculate vegetation, ice and total forcing using shared kernel arithmetic.
5. Assign periods and aggregate using the existing pair sums, monthly means and area weights.

Use **HadGEM3 all-sky TOA** for the meeting’s principal figures. Retain CAM5 all-sky TOA and CACK climatological-mean results in the tables. Preserve CACK’s missing values and its existing available-month treatment; it has 225 missing cell-month combinations, repeated over 24 pairs. HadGEM3 and CAM5 have complete kernel support here.

Report both:

- **study-area mean**, W/m² over the contributing study cells;
- **global equivalent**, W/m² using the configured Earth area.

The saved study-cell area is **19,223,828,407,176.9 m²**. Neither quantity should acquire an extra ice-free-area weighting after albedo mixing.

The seven actual intervals are **50–500 BP, 500–2,000 BP, 2–4, 4–6, 6–8, 8–10 and 10–11.5 ka**. Preserve “10–12 ka” only when matching saved labels; explain the actual endpoint in figures. Sum consecutive changes within each period; do not divide by its duration.

Keep threshold and seasonal-glacier-albedo sensitivities subordinate to the principal comparison. The shared difference calculation already supplies them; summarise them for old raster and NADI optimal without adding more ice reconstructions.

Show MIN, OPTIMAL and MAX forcing as **three reconstruction outcomes**. Their ordering in forcing need not match their ordering in ice area, and their range is not a confidence interval or an exhaustive forcing bound.

**Require the old-raster replay before accepting any NADI forcing.** Compare keys and missingness separately from numerical values, at these levels:

- adjusted fractions and all relevant albedo differences;
- cell-month-pair forcing;
- period totals and HadGEM3 component totals;
- monthly/latitude breakdown.

The read-only Python audit already reproduced partial-ice albedo differences exactly, forcing within \(2.85\times10^{-14}\) W/m², and HadGEM3 period means within \(5.4\times10^{-15}\) W/m². The implemented R calculation must independently pass its replay; these checks are supporting evidence, not its verification report.

An additional strong check is **telescoping**: with fixed monthly kernels and complete support, summed total forcing within a period must equal its endpoint mixed-albedo change times the kernel. Averaging only interior slices cannot change that total, although it can change the components. Therefore a small retained-versus-averaged total does not establish that readvances are absent.

For context, retaining raw **old-raster** readvances changed the global total most in 8–10 ka in the Python diagnostic: **−0.00017419 W/m²** relative to current averaging. This says nothing yet about the NADI effect.

**Numerical vegetation coverage is sufficient; scientific support still needs a table.** Every endpoint on the frozen forcing domain has finite saved vegetation albedo. The old ice flag did not remove all associated vegetation values from the prediction inputs.

For every slice, report the area that NADI exposes where the old land-cover product flagged ice, together with:

- whether the original cover values and saved predictions exist;
- their cover fractions and albedo ranges;
- their contribution to the old/new forcing difference.

That exposes reliance on under-ice counterfactuals without inventing new vegetation. It also keeps the meeting result accurately described as **the effect of changing ice while retaining the saved vegetation reconstruction**, rather than a fully consistent reconstruction of vegetation under the new ice history.

**Keep the agreed young-slice treatment, and present the alternatives as future choices.** Constant ice fractions do not imply identical young-slice forcing between old and new inputs: different retained ice fractions alter the area on which vegetation change acts.

| Alternative | Meaning and consequence |
|---|---|
| Carry 1 ka forward | Agreed calculation. Preserves the comparison rule but does not establish that either reconstruction represents all recent glaciers. |
| No ice at 50, 200 and 500 BP | Removes perennial ice from those slices and creates an ice transition between 1 ka and 500 BP. This is a project assumption. |
| Modern glacier inventory | Replaces the proxy with dated glacier outlines. Applying one modern inventory to all three bins still requires an assumption about earlier centuries. |
| MODIS permanent snow/ice class | Supplies classified persistent snow/ice area rather than glacier-outline area. |

For the read-only source note:

- **RGI 7.0:** RGI 7.0 Consortium (2023), *Randolph Glacier Inventory—A Dataset of Global Glacier Outlines*, DOI **10.5067/F6JMOVY5NAVZ**. The guide’s introductory passage defines a glacier snapshot targeting approximately 2000, with differing regional observation dates. It is a sensible consistent inventory candidate, not “today” or a reconstruction of medieval glaciers. [Guide](https://rgidata.org/user_guide/01_introduction.html)
- **GLIMS:** *GLIMS Glacier Database*, DOI **10.7265/N5V98602**. Its provider description covers multiple dated surveys and continuing additions. It offers temporal selection but requires an explicit selection rule and coverage audit. [NSIDC](https://nsidc.org/data/nsidc-0272/versions/1)
- **MCD12Q1.061:** Friedl and Sulla-Menashe (2022), DOI **10.5067/MODIS/MCD12Q1.061**. User Guide Table 3 defines class 15 using at least 60% snow/ice coverage for at least ten months annually. It is not a measurement of fractional glacier coverage within each pixel. The local cache contains only **27 files: three regional tiles for 2001–2009**, insufficient for study-wide modern ice coverage. [Guide, PDF p. 9](https://lpdaac.usgs.gov/documents/1409/MCD12_User_Guide_V61.pdf)

No new present-day data are needed or proposed for this analysis.

**The methodological precedents support the basic operations, not the project’s attribution or smoothing choices.**

| Reference and supporting passage | Scope of support |
|---|---|
| **Taylor, K. E. (2024).** *Truly conserving with conservative remapping methods*. **GMD 17**, 415–430. DOI **10.5194/gmd-17-415-2024**. §2, equations 4–6, constructs overlap-area weights and requires consistent areas; §4(a) addresses area fractions. [Paper](https://gmd.copernicus.org/articles/17/415/2024/) | Conservative spatial fractions and area checks. The particular projection and tolerances remain implementation choices. |
| **Madsen, M. S., et al. (2022).** *The role of an interactive Greenland ice sheet in the coupled climate-ice sheet model EC-Earth-PISM*. **Climate Dynamics 59**, 1189–1211. DOI **10.1007/s00382-022-06184-6**. §2.4 describes fractional ice masks and a 50% glacierized-cell criterion. [Paper](https://link.springer.com/article/10.1007/s00382-022-06184-6) | Precedent for fractional representation and a threshold sensitivity, not validation of this project’s precise threshold convention or component split. |
| **Ghimire, B., et al. (2014).** *Global albedo change and radiative cooling from anthropogenic land cover change, 1700 to 2005 based on MODIS, land use harmonization, radiative kernels, and reanalysis*. **GRL 41**, 9087–9096. DOI **10.1002/2014GL061671**. §2.3, equation 1, mixes albedos by fractions; equation 2 applies radiative kernels to albedo changes. [Paper, PDF pp. 3–4](https://wordpress.clarku.edu/wp-content/uploads/sites/22/2015/01/Ghimire_GRL_2014_GlobalAlbedoChange_RadiativeForcing_LandCoverChange.pdf) | Fractional albedo mixing and kernel forcing. Their forcing uses separate black-sky and white-sky quantities, so it is precedent for the principle, not an identical blue-sky implementation. |

The averaging rule, numerical reporting thresholds, attribution convention, slice-label matching, young carry-forward and frozen-hindcast experiment are **project choices**. The algebraic identities are mathematical checks.

The reference-checking procedures were followed for identity and claim support: primary records and supporting passages were inspected. Registry requests failed, so a completed Crossref/DataCite identity-and-correction audit cannot be claimed. That remaining registry check should be recorded for the implementer.

**Five slides would be enough.**

| Slide title | One message | Figure or table |
|---|---|---|
| “The newer ice fits our slice labels” | No interpolation is needed for the main NADI calculation; old dating provenance still matters. | Age-alignment strip and ice-area curves. |
| “Here is where the ice differs” | Locate differences and show which exceed NADI’s extent range. | Selected fractional-difference maps, uncertainty belt and modern inset. |
| “Advances occur—and averaging can create them” | Separate reconstructed advances from adjustment artefacts. | Readvance map, counts and one before/after chronology. |
| “The total works; the split needs a definition” | Readvance preserves the total identity but changes the interpretation of components. | Retreat/advance cell diagrams and the .3→.7 worked example. |
| “How much does this change the forcing?” | Show the ice-source effect and averaging effect separately. | Period vegetation/ice/total comparison, with HadGEM3 primary and reconstruction alternatives indicated. |

Make six reusable figure files: age/area comparison; spatial differences; readvance inventory; averaging examples; formula diagrams; forcing comparison. Put the complete slice atlas and full worked-case table in supplementary material. Build the slides afterwards from those outputs.

**The Opus implementation should stay on `ice-nadi1`, with the shared-code dependency settled first.** This worktree is clean and based on the appropriate development feature branch. Do not switch or modify the worktree containing the comparison tool under review.

The smallest maintainable arrangement is:

| File or group | Proposed work |
|---|---|
| `tools/compare_ice.R` | Stand-alone driver: inputs, scenarios, tables and figures. |
| `R/ice_comparison.R` | Small geometry and inventory functions reused for old polygons and all NADI alternatives. |
| `R/differences.R` | Add an explicit readvance-treatment argument, defaulting to existing behaviour; allow the stand-alone caller to keep raw fractions. |
| `R/kernels.R` and script 8 | Move kernel multiplication into one shared function; make both callers use it without changing arithmetic. |
| Existing period helpers | Reuse reviewed comparison helpers, or move script 9’s existing aggregation function unchanged into `R/forcing_periods.R` and call it from both places. Choose one route. |
| Tests and verification spec | Extend the existing arithmetic tests and add geometry/inventory checks plus saved-run replay. |

Existing functions to reuse are `pair_albedo_differences()`, `endpoint_albedo_differences()`, `assign_forcing_periods()`, `complete_threshold_components()` and `breakdown_forcing()`. After its review, `R/hindcast_comparison.R` can supply `period_cell_months()` and the study-area mean helpers. Do not copy or modify the in-flight version now.

There is a genuine constraint conflict: the current difference API **always smooths**, and `R/kernels.R` currently contains metadata rather than the multiplication. Literal prohibition on all pipeline-code edits cannot simultaneously deliver “keep readvances” and “no duplicated arithmetic.” The narrow refactor above is the proposal; dynamic parsing of script fragments would make the design harder to understand.

Implementation order:

1. Record this plan and Chris’s decisions in the required GitHub issue.
2. Settle the shared-code route and obtain the reviewed comparison dependency if used.
3. Establish the old-raster replay before generating NADI forcing.
4. Calculate fractions and native readvance inventories.
5. Run the eight principal scenarios, coverage audit and sensitivities.
6. Produce compact tables and figures.
7. Complete independent scientific reviews and `tools/verify_change.R` at the implementation commit, in its own verification worktree.
8. Record evidence, merge and push according to `CONTRIBUTING.md`.

Commit code, provenance/settings, compact CSVs, selected figures and verification records under a dedicated dated results location. Keep source downloads, full intersection products and large per-cell RDS tables outside Git. Update the README’s tool map and the living question files during implementation. This read-only session leaves them unchanged.

Verification should cover:

- empty, full and partial polygon overlap, holes and overlapping input polygons;
- area conservation and numerical stability;
- all configured ages, the carry-forward rule and fixed support;
- the endpoint matrix and existing historical failure cases;
- retained, removed, residual and newly created advances;
- kernel signs and units;
- component additivity and telescoping;
- exact baseline keys/NA patterns and numerical replay.

**Yes, the verification tool is required**, including for the stand-alone tool. No calibration refit is needed.

Measure geometry loading/intersection, difference calculation, aggregation, plotting, peak memory and total elapsed time separately. The historical script 7a run took about 76 minutes; that is not a forecast for this tool. Split cell/month input once and collect results before binding, avoiding repeated full-table scans while keeping the shared arithmetic unchanged.

**Three questions need Chris or Andria’s decision or information.**

1. **May Opus make the small shared-code refactor described above, while preserving all existing pipeline settings and results?** It is needed to retain readvances without duplicating the arithmetic. This asks about the literal scope of “no pipeline change.”
2. **What should the separately reported vegetation component mean?** The current calculation changes vegetation on the older ice-free area, including land subsequently covered by advancing ice. Keeping that definition permits exact comparison with the saved run. Restricting it to land exposed at both endpoints requires a different attribution; actual polygon overlap is needed where margins are not nested.
3. **Can Andria establish the time convention used to make the old raster and identify the older polygon source?** Specifically, were the Dalton 2020 ages converted to calendar years before interpolation, and is the generating code recoverable? The comparison can proceed, but that information determines how its differences can be interpreted.

No further decision is needed now about downloading data or carrying 1 ka ice forward; those instructions are already settled.

No files, branches or external records were changed, and nothing was committed or pushed. Relative to `feature/single-config`, the unmerged branches are `annotated-interp`, `cover-contrasts`, `cv-compare-tool`, `cv-hindcast-comparison`, `cv-v2`, `ice-nadi1`, `northeast-forest-check` and `refit-runs`. The ice branch awaits the decisions and implementation above; the comparison-tool branch awaits its stated review. Other branches’ remaining blockers were not established by this ice audit.

Occupied named worktrees are the main checkout plus `archive`, `benchmark`, `cleanups`, `compare-tool`, `comparison`, `contrasts`, `cv`, `cv2`, `feature`, `ice`, `northeast`, `organisation`, `questions` and `runs`; there are also 141 detached verification worktrees. Their retention or cleanup was outside this read-only task.