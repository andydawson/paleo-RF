*Astra (gpt-6-astra, ultra effort, web search), 3 November 2026: the revised design, adopting Fable's review of the first (`2026-11-03_northeast_forest_albedo_design_codex_gpt6astra.md`). Brief: `2026-11-03_northeast_forest_albedo_design_v2_brief.md`. Issue #27.*

**Revised design: northeastern forest-albedo check**  
*Astra, 3 November 2026. Design for Chris and Andria; incorporates Fable’s review.*

**1. What to expect from the literature**

This check would give the paper a local observational benchmark for the sign and approximate size of evergreen-to-deciduous albedo change.

Define the contrast throughout as

\[
\Delta\alpha=\alpha_{\mathrm{deciduous\ broadleaf}}
             -\alpha_{\mathrm{evergreen\ needleleaf}}.
\]

Positive means deciduous forest is brighter. Values use albedo’s 0–1 scale.

The three suggested references are correctly identified. Their checked passages support the following:

- **Jin et al. (2002), Table 1:** across 40–50°N during November–January, snow-free black-sky albedo is 0.122 for deciduous broadleaf forest and 0.105 for evergreen needleleaf forest: **+0.017**. With snow, the corresponding values are 0.294 and 0.213: **+0.081**. These are broad latitude-band averages, not northeastern paired observations. [DOI: 10.1029/2001GL014132](https://doi.org/10.1029/2001GL014132).
- **Hollinger et al. (2010), Table 2, p. 701:** subtracting northern and southern evergreen group means from deciduous means gives snow-free contrasts of **+0.034 to +0.061 in April–May**, **+0.047 to +0.073 in June–August**, and **+0.039 to +0.057 in September–October**. These span differences between grouped seasonal means; they are not uncertainty intervals or northeastern monthly limits. [DOI: 10.1111/j.1365-2486.2009.02028.x](https://doi.org/10.1111/j.1365-2486.2009.02028.x).
- **Zhao and Jackson (2014), p. 338:** paired annual white-sky means are 0.166 for deciduous and 0.138 for evergreen forest: **+0.028**. Evergreen forest is darker at most paired sites throughout the year. Their January zonal contrast at 45–60°N is about **+0.06**, but is **not separated by snow state**. [DOI: 10.1890/12-1705.1](https://doi.org/10.1890/12-1705.1).

The resulting monthly expectations are below. **No checked source supplies all twelve northeastern monthly ranges separately for snowy and snow-free conditions.** Unsupported entries therefore remain unquantified.

| Month | Snow-free expectation | Snowy expectation |
|---|---|---|
| January | Positive; winter reference +0.017 | Positive; winter reference +0.081 |
| February | Positive expected; monthly range unquantified | Positive expected; using January’s scale would be an extrapolation |
| March | Positive expected; monthly range unquantified | Positive expected; spring range unquantified |
| April | Positive; April–May reference +0.034–0.061 | Positive expected where snow remains; range unquantified |
| May | Positive; April–May reference +0.034–0.061 | Range unquantified |
| June | Positive; summer reference +0.047–0.073 | No usable seasonal reference |
| July | Positive; summer reference +0.047–0.073 | No usable seasonal reference |
| August | Positive; summer reference +0.047–0.073 | No usable seasonal reference |
| September | Positive; autumn reference +0.039–0.057 | Range unquantified |
| October | Positive; autumn reference +0.039–0.057 | Positive expected where snow occurs; range unquantified |
| November | Positive; winter reference +0.017 | Positive; winter reference +0.081 |
| December | Positive; winter reference +0.017 | Positive; winter reference +0.081 |

These are expectations to test, never filters for accepting observations. Leaf-out, leaf loss and species composition can produce departures. Black-sky, white-sky and measured broadband albedos also differ from this project’s local-noon blue-sky product.

**Required precision:** approximately **±0.02 albedo per unit cover exchanged** is sufficient to distinguish the large illustrated model discrepancy. This is a project decision target, not a promised confidence interval or satellite accuracy specification. It would not necessarily resolve a winter contrast near +0.017.

Fable’s hand example needs one arithmetic correction:

\[
1.68/12-0.95/10=+0.045,\qquad
0.18\times0.045=+0.0081.
\]

The stated +0.0072 uses the rounded contrast +0.04. Likewise, \(-0.094/0.18=-0.522\). The sign and scale argument survives, although the precise provenance of −0.094 needs resolving below.

**2. Scope and the main threat**

**Site selection is the main threat.** Pure conifer stands occur on particular soils, drainage conditions and managed sites. Nearby hardwoods can differ in those respects even after elevation and terrain screening. Matching reduces broad environmental differences; it does not establish that replacing the conifers would cause the measured difference.

The target is therefore a **descriptive contrast between nearby, consistently labelled forest stands**, within **80–66°W and 40–48°N**, during **2001–2009**.

Expect this selection to test **spruce–fir and pine against hardwoods more than hemlock against hardwoods**. Hemlock-bearing mixed forests will often fail the pure-class screen. However, neither the proportion excluded nor Fable’s suggested concentration north of about 45°N has been measured here. Those are questions for the coverage results, not established properties of the sample.

Before examining contrasts, report candidate and paired coverage in the one-degree latitude bands **40–41°N through 47–48°N**, including:

- Eligible ENF and DBF pixels, matched ENF pixels, and unique DBF partners.
- Pipeline cells represented and cells without pairs.
- Pair distances, elevation differences and DBF reuse.
- Woody-wetland flags and losses at each eligibility screen.

A sign that persists across adequately represented latitude and wetland strata, and across supported months, is the usable result. A pooled sign driven by one northern stratum is insufficient evidence for the southern hemlock-decline region. Magnitude remains more vulnerable than sign, and even stable signs cannot eliminate shared measurement bias.

**3. First-pass estimator**

The published precedents support the components, rather than this exact recipe. Zhao and Jackson used local vegetation comparisons, terrain restrictions and one-degree aggregation; their neighbourhood method differs from ours. Stuart supports nearest-neighbour matching with replacement and checking balance before examining outcomes. The specific distances, thresholds and averaging order below are project judgements for Chris’s acceptance. [Zhao and Jackson, methods pp. 333–335, DOI: 10.1890/12-1705.1](https://doi.org/10.1890/12-1705.1); [Stuart, §§1 and 3.1.3, DOI: 10.1214/09-STS313](https://doi.org/10.1214/09-STS313).

**Candidates and fixed pairs**

Use MCD12Q1 only for the new forest classification input.

| Rule | First-pass specification |
|---|---|
| Forest classes | `LC_Type1=1` ENF and `LC_Type1=4` DBF; mixed forest excluded |
| Persistence | Same class throughout 2001–2009 |
| Neighbourhood | Same-class 3×3 block in each year; handle tile boundaries correctly |
| Classification quality | `QC=0`, classified land, throughout the selection period |
| Land and water | Existing record-wide majority-land rule, with MOD44W water/shore screening |
| Terrain | Pair elevation difference ≤50 m; each candidate’s local GMTED 3×3 elevation range ≤100 m |
| Distance | Nearest eligible DBF centre within **5 km ground distance** for each ENF centre |
| Replacement | DBF reuse allowed |
| Latitude | No additional latitude-difference restriction |
| Windows | No 25 km windows |

The MCD12Q1 forest definitions require tree cover above 60%; they do not prove pixel purity. `QC=0` identifies classified land, not a probability of correct forest type. Stable labels likewise do not prove absence of disturbance. [MCD12Q1 Collection 6.1 guide, Tables 3 and 11 and product cautions](https://lpdaac.usgs.gov/documents/1409/MCD12_User_Guide_V61.pdf).

Use geographic distance, not uncorrected Euclidean distance in the sinusoidal projection. Resolve exact distance ties by pixel identifier solely for reproducibility.

Retain forest candidates flagged as woody wetlands so that their results can be inspected. A simple proposed stratification is:

- **Unflagged:** neither member was labelled woody wetland during 2001–2009.
- **Flagged:** at least one member was labelled woody wetland during that period.

Within the flagged group, distinguish both flagged from only one flagged in the diagnostic table. This exposes wetland mismatch without adding another matching algorithm. `LC_Prop3=27` supplies the flag; wetlands are underrepresented, so “unflagged” does not establish dry ground. [MCD12Q1 guide, Table 10 and known limitations](https://lpdaac.usgs.gov/documents/1409/MCD12_User_Guide_V61.pdf).

Freeze the pair table before reading albedo sums. Keep it fixed across months, years and snow panels. Retrieval failures remove a pair from a particular panel; they do not trigger a search for another partner.

**Retrieval balance and contrasts**

Use `full_75` initially. For each pair, year and calendar month:

1. Require positive all-days counts for both members.
2. Require
   \[
   r=\frac{\min(n_{\mathrm{all,DBF}},n_{\mathrm{all,ENF}})}
           {\max(n_{\mathrm{all,DBF}},n_{\mathrm{all,ENF}})}
     \geq0.7.
   \]
3. Within each reported category, require at least **five qualifying retrieval days for each member**.
4. Calculate each pixel’s albedo as its stored sum divided by its corresponding count, then subtract ENF from DBF.

The 0.7 threshold and five-day minimum are coverage judgements, not published guarantees of comparable observation dates. Five retrieval days are not five independent observations.

Report all-days, snow-free and snowy panels. Recover unknown-snow counts and sums by subtracting snowy and snow-free totals from all-days totals; retain them as diagnostics.

For every month, report the count-ratio distribution, signed DBF-minus-ENF count difference, category-specific counts, and the fraction failing the balance rule. Show these before and after selection. In March–May, also map failures and compare snow shares between members.

Monthly sums cannot establish simultaneous observations. Even equal counts can represent different sides of snowmelt. If spring failures are widespread, label those results as limited by retrieval timing; do not relax the threshold after seeing the sign.

**Aggregation**

Assign each pair to the **ENF member’s pipeline cell**, using the existing mapping `floor(lon)+0.5`, `floor(lat)+0.5`. Its DBF partner may lie across a cell boundary.

For each month and snow category:

1. Average eligible pair contrasts within each cell and year.
2. Average contributing years equally within each cell.
3. Average contributing cells equally.

Report missing years and changing cell coverage beside every result.

Also report a **pair-weighted mean**, defined explicitly as the mean over all eligible pair–year contrasts for that month and category. It answers a different weighting question and lets dense groups of pairs contribute more. Neither summary weights observations by retrieval count.

Show cell and year variation as descriptive spread, not a confidence interval. Reused DBF pixels and spatial dependence make ordinary pixel-level significance tests inappropriate. Snow-separated comparison has published precedent, but the published methods do not validate our retrieval-count thresholds. [Lejeune et al., §2.3.1, DOI: 10.5194/esd-11-1209-2020](https://doi.org/10.5194/esd-11-1209-2020).

**4. Comparison with the model**

Report the model’s **implied albedo contrast per unit cover exchanged**, for:

- Model 8.
- The cross-validation winner, using its recorded selection and final fitted models.

Do not choose the winner using this satellite check.

For northeastern cell \(i\), define

\[
q_i=ET_{i,6000}-ET_{i,4500}.
\]

Starting from that cell’s 6 ka composition, move \(q_i\) from ET to ST, holding OL, location and elevation fixed:

\[
\Delta\widehat{\alpha}_{i,m}
=
\widehat{\alpha}_m(ET_i-q_i,ST_i+q_i,OL_i,x_i,y_i,z_i)
-
\widehat{\alpha}_m(ET_i,ST_i,OL_i,x_i,y_i,z_i).
\]

Then calculate

\[
C_{i,m}=\Delta\widehat{\alpha}_{i,m}/q_i,\quad q_i\ne0.
\]

Use `predict(type="response")`. Check compositions rather than clipping them. At \(q_i=0\), the change is exactly zero and the normalized contrast is undefined.

Reuse the fixed-location construction in [plot_northeast_cover_and_location.R](tools/plotting/plot_northeast_cover_and_location.R:129), extracting shared code rather than copying it. Its present curve sets a common ET value across cells; the new calculation applies the explicitly defined cell-specific exchange.

For each model and month, report the equal-cell mean and distribution of \(C_{i,m}\), the distribution of \(q_i\), and training-support diagnostics. The mean of cell ratios is not generally the ratio of regional means.

Place these model contrasts beside the observed contrast. **Drop the earlier per-cell, \(q_i\)-weighted satellite benchmark and matched-support weighting exercise.** Show observational coverage separately, including latitude strata, so the reader can see differences in represented geography.

Compare an all-days fit directly with the all-days observation. Snow-specific panels diagnose mechanisms and sampling unless corresponding snow-specific model fits already exist.

The pollen and satellite classes remain unequal. The repository maps Tsuga, pine, spruce and fir to ET, while ST includes hardwoods **and Larix**, with shrubs represented in the reconstruction’s broader categories. ENF and DBF are therefore partial analogues for ET and ST, not interchangeable measurements. [Dawson et al., DOI: 10.5194/cp-21-2031-2025](https://doi.org/10.5194/cp-21-2031-2025); [repository taxon translation](data/taxon2LCT_translation_v2.0.csv).

**The −0.094 check needs an identified fixture.** The existing plotting script’s historical change uses actual compositions at both dates, including changing OL. A saved diagnostic log reports −0.095 to three decimals. This does not establish that Fable’s −0.094 is wrong—it may concern a different snapshot or the fixed-OL exchange—but its fit, inputs and definition must be frozen before it becomes an expected test value. The implementation must not be adjusted merely to hit it.

**5. Inputs, biases and later options**

The main checkout contains **4,484 monthly albedo GeoTIFFs, 192.29 GB**. The three northeastern tiles contain **354 files, 25.35 GB**, including 2000. The proposed 2001–2009 analysis uses **324 tile-month files**.

The preparation code retains the required sums and counts for all-days, snowy and snow-free observations, alongside land/shore/read counts. These represent qualifying local-noon blue-sky retrievals, not sunlight-weighted daily albedo.

The benchmark checkout lacks the raw-input directories. The main checkout has them under:

`/home/expert/Documents/contracting/Andria/paleo-RF/data/`

In particular, `gmted2010/` currently contains the **extracted `mn30_grd/`**, `info/`, the auxiliary file and `mn30_grd.zip`. Thus Fable’s “zip only” concern does not describe the current main checkout. Use an explicit shared-input path or the repository’s worktree input arrangement; another elevation download is unnecessary.

Remaining limitations must accompany the results:

- **Canopy-hidden snow:** retrieval snow state is not an independent measurement of snow beneath trees. Jin et al. explicitly discuss missed snow under strong vegetation shading. [DOI: 10.1029/2001GL014132](https://doi.org/10.1029/2001GL014132).
- **Shared MODIS labels:** selection can inflate positive DBF-minus-ENF differences if darker pixels are preferentially assigned ENF. This is a plausible bias direction, not a measured correction. Fable’s winter-darkness shorthand needs qualification: Collection 6 classification uses snow-free spectral metrics, so direct selection on winter albedo is not established. [MCD12Q1 guide, algorithm description](https://lpdaac.usgs.gov/documents/1409/MCD12_User_Guide_V61.pdf).
- **Purity:** consistent 3×3 labels do not prove pure species composition. A later NLCD audit on the US portion can test whether the labelled groups differ in independent mapped purity; it cannot eliminate every shared-observation error.
- **Terrain and stand history:** coarse elevation screening does not match fine slope, aspect, soil, stand age, management or disturbance.
- **Changing support:** snow categories and retrieval rules can select different forests in different months.
- **Historical transfer:** modern forest contrasts do not establish a hemlock-specific Holocene causal effect.

**MOD44B remains a later sensitivity**, after the first results show whether canopy-cover information would change the interpretation. Fable’s approximate 80% saturation concern has published support for **Collection 5**, rather than a verified threshold for Collection 6.1. [Sexton et al., conclusion p. 444, DOI: 10.1080/17538947.2013.786146](https://doi.org/10.1080/17538947.2013.786146).

Flux towers—**Harvard Forest hemlock and hardwood, Howland and Bartlett**—are later options after the first satellite results. No tower acquisition or analysis belongs in this first pass.

**6. First download proposed for Chris**

Acquire **MCD12Q1.061 only: three tiles × nine years = 27 annual HDF4 granules**.

- Tiles: `h11v04`, `h12v04`, `h13v04`.
- Years: 2001–2009 inclusive.
- Product: *MODIS/Terra+Aqua Land Cover Type Yearly L3 Global 500m SIN Grid V061*. [Dataset DOI: 10.5067/MODIS/MCD12Q1.061](https://doi.org/10.5067/MODIS/MCD12Q1.061).
- Read `LC_Type1`, `QC`, `LC_Prop3` and the land/water information from the native files.

**The exact filename manifest is not yet complete.** Available NASA listings exposed these six published filenames and rounded sizes:

| Year | Published filename | Listed size |
|---|---|---:|
| 2001 | `MCD12Q1.A2001001.h11v04.061.2022146060256.hdf` | 15.06 MB |
| 2001 | `MCD12Q1.A2001001.h12v04.061.2022146050354.hdf` | 14.74 MB |
| 2001 | `MCD12Q1.A2001001.h13v04.061.2022146060649.hdf` | 8.20 MB |
| 2009 | `MCD12Q1.A2009001.h11v04.061.2022159184319.hdf` | 11.11 MB |
| 2009 | `MCD12Q1.A2009001.h12v04.061.2022159194525.hdf` | 12.36 MB |
| 2009 | `MCD12Q1.A2009001.h13v04.061.2022159204454.hdf` | 6.85 MB |

Sources: [NASA’s 2001 directory](https://ladsweb.modaps.eosdis.nasa.gov/archive/allData/61/MCD12Q1/2001/001/) and [2009 directory](https://ladsweb.modaps.eosdis.nasa.gov/archive/allData/61/MCD12Q1/2009/001/).

The remaining catalogue selections are:

| Acquisition label | Tiles | Outstanding metadata |
|---|---|---|
| `A2002001` | h11v04, h12v04, h13v04 | Production suffixes and sizes |
| `A2003001` | h11v04, h12v04, h13v04 | Production suffixes and sizes |
| `A2004001` | h11v04, h12v04, h13v04 | Production suffixes and sizes |
| `A2005001` | h11v04, h12v04, h13v04 | Production suffixes and sizes |
| `A2006001` | h11v04, h12v04, h13v04 | Production suffixes and sizes |
| `A2007001` | h11v04, h12v04, h13v04 | Production suffixes and sizes |
| `A2008001` | h11v04, h12v04, h13v04 | Production suffixes and sizes |

These are exact acquisition selections, **not claimed full filenames**. The relevant provider directories and metadata endpoints were inaccessible through the available web access. The original approximately 0.35 GB remains a planning estimate, not a verified total.

To obtain them, use [Earthdata Search’s MCD12Q1.061 collection](https://search.earthdata.nasa.gov/search/granules?p=C2484079608-LPCLOUD) or the [LAADS annual directories](https://ladsweb.modaps.eosdis.nasa.gov/archive/allData/61/MCD12Q1/). Select exactly these 27 granules, export their native-file URLs and metadata, and complete the manifest with full filenames, byte sizes and available checksums. After Chris’s download approval, retrieve the files through Earthdata Login and preserve their published names. No regional reprojection or replacement albedo acquisition is needed.

**7. Repository organisation and implementation**

Keep one readable driver with a short settings block and small functions. Use the current repository conventions; this check does not need its own experiment framework.

| Component | Proposed location |
|---|---|
| Analysis driver | `tools/check_northeast_forest_albedo.R` |
| Shared MODIS geometry and land functions | `R/modis_albedo_helpers.R` |
| Matching, reduction and reusable model-exchange functions | `R/northeast_forest_albedo.R` |
| Shared-helper tests | `tests/test_modis_albedo_helpers.R` |
| Check-specific tests | `tests/test_northeast_forest_albedo.R` |
| Downloaded MCD12Q1 files and acquisition records | `data/mcd12q1/` |
| Pair table, cell/year results, regional summaries and diagnostics | `output/northeast_forest_albedo/` |
| Figures | `figures/diagnostics/northeast_forest_albedo/` |
| Run manifests | `runs/check_northeast_forest_albedo/` |
| Design, changelog, references and interpretation | Dated, descriptive files under `docs/cc/` |
| Verification specification and PASS report | `docs/cc/verification/` |

Use the existing run-directory redirection for separate approved experiments. Record settings, code revision, input versions, exact granules, pair-table identity and model identities in each run.

**Move, rather than copy**, these functions from `tools/prepare_bluesky_albedo.R` into `R/`:

- `tile_template`, `pixel_lonlat` and their grid constants.
- `is_land`, preserving its strict-majority rule and explicit handling of the selected land rule.

Move their existing tests with them and add coordinate, tile-boundary and cell-boundary cases. Both tools should source the shared implementation.

The preparation script currently records its own hash and checks accepted historical hashes. Extraction must also record the shared helper code and preserve acceptance of existing files whose equivalence is demonstrated. A code-only extraction should not require rebuilding the albedo archive.

Implementation order:

1. Complete acquisition metadata and establish shared-input paths.
2. Extract and verify shared functions.
3. Build candidates and fixed pairs; inspect coverage and balance before outcomes.
4. Calculate monthly contrasts and retrieval diagnostics.
5. Calculate both model comparisons.
6. Produce figures, tables and interpretation; complete independent review.

Update README’s script/input/output tables when the tool is added. Put the scientific precedents and the explicitly approved judgements in the implementation changelog and, where used, the paper.

**8. Verification**

Every code change goes through `tools/verify_change.R`, from its separate worktree at the exact commit, with a committed specification and PASS report. Preserve the existing blue-sky tests and compare appropriate regenerated outputs with anchors.

Fable’s six invariants are adopted with the necessary qualifications:

| Invariant | Required test |
|---|---|
| **1. Self-pair** | A pixel paired with itself gives exactly zero in every populated, eligible panel. Missing panels remain missing. |
| **2. Snow mixture** | For each pixel/year/month, `share_snowy × snowy + share_free × free + share_unknown × unknown = all`, within tolerance derived from float32 storage. A zero-share component contributes zero even when its mean is missing. |
| **3. Label reversal** | Reversing subtraction labels flips every mean’s sign **with pair IDs, eligibility, cell assignments and weights held fixed**. Rematching is not covered: ENF-to-DBF nearest-neighbour matching is asymmetric. |
| **4. Outcome blindness** | Replacing albedo values/sums with noise, while retaining counts and selection inputs, leaves the geographic pair table identical. |
| **5. Weighting** | One cell with one pair at +0.02 and another with 50 pairs at +0.06 gives **+0.040000** equally by cell and **+0.0592157** by pair. Include unequal-year coverage too. |
| **6. Model exchange** | At `q=0`, change is exactly zero and change/q is missing. Reproduce the May **−0.094** reference once its exact fit, inputs and quantity are identified; separately preserve the existing historical-change diagnostic. |

The mixture identity applies before category-specific pair selection. Separately selected regional snow panels cannot generally be recombined using one regional snow share.

Additional targeted checks cover:

- The +0.045 hand example and its +0.0081 scaled value.
- Counts, missing values and unknown-snow residuals.
- The inclusive 0.7 balance threshold and five-day rule.
- Nearest eligible partner, replacement, no eligible partner and tile-edge matching.
- Ground-distance and elevation thresholds.
- Pipeline-cell assignment and explicit averaging order.
- Valid model compositions and unchanged OL/location/elevation.
- Unchanged existing albedo results after helper extraction.

Scientific arithmetic and choices require independent Fable and Astra reviews of the same code and requirements, followed by reconciliation. Unresolved scientific disagreements become questions for Chris or Andria.

**9. Decisions and records**

Chris has already chosen the simpler estimator, MCD12Q1 first, and towers later. Those choices are incorporated.

**Chris must settle:**

1. Approval of the **27-granule MCD12Q1 acquisition**, once the outstanding published filenames and sizes complete the reviewable manifest.
2. Acceptance of the remaining numerical judgements: persistent 3×3 labels, terrain limits, five days, count ratio ≥0.7, wetland stratification and stated weighting.
3. Acceptance of ±0.02 as the practical discrimination target, with weak winter contrasts allowed to remain unresolved.
4. Identification of the exact May −0.094 fixture.
5. After first results, whether coverage and bias require MOD44B, an NLCD purity audit or the later tower comparison.

**Chris and Andria must settle the scientific interpretation:**

| Question | Why it matters |
|---|---|
| Which modern stands are acceptable analogues for the hemlock decline? | The selected sample may chiefly represent spruce–fir and pine, with little southern coverage. |
| What vegetation change does the reported forcing represent? | A fixed ET-to-ST exchange differs from the full reconstructed change, which also changes OL and may imply structural changes. |
| Is the ENF/DBF-to-ET/ST crosswalk acceptable for magnitude comparison? | Satellite forest classes and reconstructed tree/shrub fractions measure different things. |
| What conclusion is justified if the sign varies by latitude, wetland status or month? | Such variation should remain visible rather than be reduced to one regional claim. |

When writing is authorised, place acquisition and input-path matters in `questions_for_andria_general.md`; place the stand analogy, forcing interpretation and crosswalk in `questions_for_andria_scientific.md`. Each entry should identify this design and Fable’s review as its source. Record answers in the relevant design or interpretation document and remove resolved questions.

**References and checking record**

- Jin, Y., Schaaf, C. B., Gao, F., Li, X., Strahler, A. H., Zeng, X. & Dickinson, R. E. (2002). How does snow impact the albedo of vegetated land surfaces as analyzed with MODIS data? *Geophysical Research Letters*, **29**(10), 1374. [10.1029/2001GL014132](https://doi.org/10.1029/2001GL014132).
- Hollinger, D. Y., et al. (2010). Albedo estimates for land surface models and support for a new paradigm based on foliage nitrogen concentration. *Global Change Biology*, **16**, 696–710. [10.1111/j.1365-2486.2009.02028.x](https://doi.org/10.1111/j.1365-2486.2009.02028.x).
- Zhao, K. & Jackson, R. B. (2014). Biophysical forcings of land-use changes from potential forestry activities in North America. *Ecological Monographs*, **84**, 329–353. [10.1890/12-1705.1](https://doi.org/10.1890/12-1705.1).
- Stuart, E. A. (2010). Matching methods for causal inference: A review and a look forward. *Statistical Science*, **25**, 1–21. [10.1214/09-STS313](https://doi.org/10.1214/09-STS313).
- Lejeune, Q., et al. (2020). Biases in the albedo sensitivity to deforestation in CMIP5 models and their impacts on the associated historical radiative forcing. *Earth System Dynamics*, **11**, 1209–1232. [10.5194/esd-11-1209-2020](https://doi.org/10.5194/esd-11-1209-2020).
- Sexton, J. O., et al. (2013). Global, 30-m resolution continuous fields of tree cover: Landsat-based rescaling of MODIS vegetation continuous fields with lidar-based estimates of error. *International Journal of Digital Earth*, **6**, 427–448. [10.1080/17538947.2013.786146](https://doi.org/10.1080/17538947.2013.786146).
- Dawson, A., et al. (2025). Holocene land cover change in North America: continental trends, regional drivers, and implications for vegetation–atmosphere feedbacks. *Climate of the Past*, **21**, 2031–2060. [10.5194/cp-21-2031-2025](https://doi.org/10.5194/cp-21-2031-2025).
- Friedl, M. & Sulla-Menashe, D. (2022). *MODIS/Terra+Aqua Land Cover Type Yearly L3 Global 500m SIN Grid V061*. NASA LP DAAC. [10.5067/MODIS/MCD12Q1.061](https://doi.org/10.5067/MODIS/MCD12Q1.061).

Identities and supporting passages were checked against publisher, author or institutional sources. Automated RefChecker/refaudit verification was not completed in this session and remains a recorded requirement before implementation.

No files were edited or downloaded, and nothing under `data/modis_albedo/requests/` was opened.