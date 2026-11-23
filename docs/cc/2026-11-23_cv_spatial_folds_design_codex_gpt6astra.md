**Design: one cross-validation method for new places and unseen cover**  
**Astra (Codex), 23 November 2026 — proposal only**

**Benefit to the paper:** choose the albedo model using withheld observations that test both geographic transfer and unfamiliar cover mixtures, while showing which historical conditions remain untested.

I recommend **geographic holdouts crossed with the existing directional cover exclusions, with a geographic buffer around each holdout**. Test all complete observations in the held-out geographic area. This supplies inside-range and outside-range predictions from one method and replaces the separate in-range experiment.

The design needs Chris’s approval before implementation. Its geographic separation distance cannot responsibly be specified from the available records: **250 km was a previous selection judgement, not an estimated autocorrelation range.**

**1. Useful deletion and reuse first**

Two existing branches of work become unnecessary:

- **Remove the separate in-range holdout, fitting round and reporting branch.** The combined folds below supply those predictions for every candidate, saving the existing 24 diagnostic fits.
- **Remove the comparison with protocol 1’s holdout membership.** That transition is already recorded; its approximately 23 lines of code and associated output do not help this experiment.

Keep the historical protocols and results. Keep the capacity and synthetic-recovery evidence: predictive CV does not replace their question about separating cover from location.

The main reusable components are:

| Existing component | Use in this design |
|---|---|
| `cover_triangle_xy()`, `training_hull()`, `training_support()` | Cover geometry and novelty relative to each actual training set. |
| `cv_directions()`, `cv_holdouts()` | Historical departure directions and global cover-tail exclusions. |
| `cv_block()`, `nearest_km()`, `complete_rows()` | Existing geographic cells, kilometre distances and monthly availability. |
| `cv_target_weights()`, `slice_area_ice()` | Historical area and ice weighting. |
| `fit_calibration_retry()`, fit summaries | Existing REML fitting, convergence checks and retry policy. |
| `cv_score()`, `cv_choose()`, paired comparison helpers | Grouped errors, paired comparisons and the existing simplicity rule. |
| Existing holdouts → fit → score commands | Preparation, fitting and reporting, without another driver or workflow stage. |

The necessary structural change is small but substantive: **test membership and exclusion from training must become separate frozen fields**. Currently one `withheld` flag serves both purposes. Merely adding buffer cells to it would score those cells too, defeating the intended gap. See [the current membership and fitting code](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tools/cross_validate_albedo.R:114).

**2. Published precedent**

The literature supports the ingredients and their combination in principle. **I found no established albedo recipe identical to this proposal.** Its particular fold construction and weighting are project judgements.

| Reference and passage read | What it supports |
|---|---|
| **Telford, R. J. & Birks, H. J. B. (2009). “Evaluation of transfer functions in spatially structured environments.” *Quaternary Science Reviews* 28, 1309–1316. DOI [10.1016/j.quascirev.2008.12.020](https://doi.org/10.1016/j.quascirev.2008.12.020).** §§5–7, pp. 1314–1315. | Direct palaeoecological precedent for **h-block CV**: exclude training observations within a distance of the test observation, guided by residual spatial correlation. Their discussion distinguishes withholding environmental extremes from establishing spatial independence. It supports adding geographic exclusion to the cover test, but supplies no distance for this dataset. |
| **Roberts, D. R. et al. (2017). “Cross-validation strategies for data with temporal, spatial, hierarchical, or phylogenetic structure.” *Ecography* 40, 913–929. DOI [10.1111/ecog.02881](https://doi.org/10.1111/ecog.02881).** Box 4 and pp. 923–925. | Environmental blocking can remain optimistic when spatial dependence remains. Structural folds should also reflect the magnitude and direction of predictor extrapolation relevant to prediction. Their Douglas-fir example compares several schemes; it does not prescribe this exact combined algorithm. |
| **Valavi, R., Elith, J., Lahoz-Monfort, J. J. & Guillera-Arroita, G. (2019). “blockCV: An R package for generating spatially or environmentally separated folds for k-fold cross-validation of species distribution models.” *Methods in Ecology and Evolution* 10, 225–232. DOI [10.1111/2041-210X.13107](https://doi.org/10.1111/2041-210X.13107).** §§4–5. | Spatial blocks, buffers and environmental clusters are separate strategies. Buffers address neighbours across block boundaries; correlation ranges inform separation. The paper does not establish that environmental clustering simultaneously ensures geographic separation. Following its principles does not require adding the package. |
| **Meyer, H. & Pebesma, E. (2021). “Predicting into unknown space? Estimating the area of applicability of spatial prediction models.” *Methods in Ecology and Evolution* 12, 1620–1633. DOI [10.1111/2041-210X.13650](https://doi.org/10.1111/2041-210X.13650).** §§2.1–2.5 and discussion. | Measure predictor novelty against the training observations remaining in each fold, and restrict interpretation to conditions represented in validation. Their importance-weighted predictor distance differs from our cover-hull distance; this is precedent for checking applicability, not for replacing our geometry. |
| **Meyer, H. & Pebesma, E. (2022). “Machine learning-based global maps of ecological variables and the challenge of assessing them.” *Nature Communications* 13, 2208. DOI [10.1038/s41467-022-29838-9](https://doi.org/10.1038/s41467-022-29838-9).** Figure 1 and accuracy-assessment discussion, pp. 2–3. | Validation distances should resemble the prediction task where possible. Geographic and predictor gaps both matter. This cautions against interpreting increasingly distant holdouts as automatically better validation. Relevant published passages were retrieved through indexed text; direct publisher access encountered a cookie redirect. |
| **Hu, X., Cherubini, F., Vezhapparambu, S. & Strømman, A. H. (2018). “From Remotely-Sensed Data of Norwegian Boreal Forests to Fast and Flexible Models for Estimating Surface Albedo.” *Journal of Advances in Modeling Earth Systems* 10, 2495–2513. DOI [10.1029/2018MS001403](https://doi.org/10.1029/2018MS001403).** §3.4. | Direct forest-albedo precedent: fit in each of two Norwegian areas and predict the other, reporting prediction errors. It tests geographic transfer without deliberately imposing cover novelty. |
| **Wang, Y., Khodadadzadeh, M. & Zurita-Milla, R. (2023). “Spatial+: A new cross-validation method to evaluate geospatial machine learning models.” *International Journal of Applied Earth Observation and Geoinformation* 121, 103364. DOI [10.1016/j.jag.2023.103364](https://doi.org/10.1016/j.jag.2023.103364).** §§2.2.1–2.2.2. | An explicitly joint geographic-and-feature method exists, including an above-ground-biomass application. It combines geographic clustering with ensembles using coordinates, covariates and response. That machinery is unnecessary here; the existing cover geometry permits direct exclusions. |

The distance-matching algorithm associated with the Meyer–Pebesma discussion is **Milà, C., Mateu, J., Pebesma, E. & Meyer, H. (2022), “Nearest neighbour distance matching Leave-One-Out Cross-Validation for map validation,” *Methods in Ecology and Evolution* 13, 1304–1316**, DOI [10.1111/2041-210X.13851](https://doi.org/10.1111/2041-210X.13851). Its §2.1 matches geographic prediction distances; it does not jointly impose cover novelty.

DOI identities and supporting passages were checked against publisher records or identified published copies. **The project’s dedicated reference checkers were unavailable and were not run.** That verification remains outstanding before implementation.

**3. Recommended method**

**Build fifteen combined splits**

1. **Keep the existing inputs and fifteen candidates.** Use the all-days, `full_75` calibration and monthly complete rows. Retain all three cover forms crossed with absent location and location sizes 12, 30, 100 and 500. No new formulas, model IDs or configuration options are needed.

2. **Make five contiguous geographic groups.** Reuse the existing 5° blocks. Group their longitude columns into five west-to-east bands, placing boundaries near cumulative fifths of calibration-cell counts while keeping whole columns together. Use coordinates and cell counts, not albedo or model performance. Fix these groups across months.

   This direct partition avoids scattering buffer boundaries throughout the continent. Five groups and this orientation are project judgements, not published optima.

3. **Keep three global cover-tail exclusions.** Derive the existing historical departure directions and exclude observations beyond the 80th percentile along each direction. Use one fixed cut. Remove the old 80/70/90 fallback from this experiment rather than inventing a search over cuts for each geographic group.

4. **Cross each geographic group with each cover exclusion.** For one such split:

   - **Test:** all complete monthly observations in the held-out geographic group.
   - **Train:** complete monthly observations outside that group, outside its geographic buffer, and outside the selected cover tail everywhere.
   - **Exclude without scoring:** buffer observations and cover-tail observations outside the test group.

   Thus a held-out tail observation has neither nearby training observations nor the globally withheld cover extreme available to the model. Other observations in the same geographic holdout supply tests of familiar cover at new places.

5. **Calculate both distances after all exclusions.** For every test observation, calculate nearest-training distance and its inside/outside status, departure direction and depth relative to the actual remaining monthly training hull.

This is one level of CV, with fifteen training/test splits. It is not nested CV.

**Choose the geographic buffer from evidence**

Use one common distance \(h\), fixed before candidate scoring. Exclude training cells within \(h\) kilometres of any calibration-cell centre in the held-out geographic group, including group cells lacking that month’s response.

After approval, the existing preparation work should examine empirical spatial-distance plots for available full-data residuals, including no-location fits, alongside the response and predictor fields. **Model 8’s residuals alone are insufficient:** its location term may absorb the dependence being investigated. Published guidance also warns that residual correlation can understate structural overfitting. [Roberts et al., discussion of block size](https://www.biom.uni-freiburg.de/mitarbeiter/dormann/roberts-et-al-2017-ecography.pdf/at_download/file).

The records inspected do not establish a defensible numerical \(h\). Its choice needs scientific judgement after those plots, recorded before fitting. No automatic range optimizer or radius search is proposed.

Retain the existing feasibility requirements of enough complete training rows for the largest candidate—748 coefficients—and at least ten occupied 5° test blocks with positive target weight. These are practical support requirements, not proof of independence. Freeze feasibility for all candidates together.

Winter feasibility is uncertain: protocol 2’s smallest training set contains only **914 December rows** before these additional exclusions. An infeasible split remains untested; do not reduce the buffer or change its cut after seeing errors.

**Score the historical target explicitly**

I recommend extending selection to the **complete historical weighting target**, including mixtures inside the full modern hull. This is an explicit change from protocol 2’s outside-only objective and requires Chris’s decision.

Retain:

- Historical slices excluding modern 50 BP.
- Latitude strictly between 27° and 74° N.
- Equal month and slice weights before grouping.
- Cell area × ice-free fraction within each slice.

Define groups as month × cover support: one inside-hull group, plus the existing departure-direction × distance-band groups outside. Historical membership uses each month’s **full modern hull**, frozen before fitting. Test membership uses each fit’s **remaining training hull**.

For each candidate:

1. Calculate squared error of the deterministic response-scale albedo prediction.
2. Average repeated appearances within the same physical cell, month and support group first.
3. Average those cell errors within each group.
4. Combine group means with the frozen historical weights and report their square root.

Each historical weight is counted once. A cell can inform different support groups under different training exclusions; its three predictions are not three independent observations.

Missing groups retain their reported missing target weight. Renormalization over represented groups must be stated beside the score. Keep inside-range and outside-range results separately visible, particularly the northeast-relevant departure direction.

The previous target was **12.8158%** of the complete historical weight. Moving to the complete target therefore materially changes selection; it must not be described as merely correcting the old score. [Independent target check](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/docs/cc/2026-11-10_cv_protocol_v2_results_review_check_codex_gpt6astra.md:40).

Geography enters through training exclusion; cover novelty enters through both exclusion and weighting. **Do not invent a combined distance that adds kilometres to cover fractions.**

These weights describe historical albedo conditions. They do not include radiative kernels and do not make the score an error estimate for vegetation forcing.

**Selection and uncertainty**

Retain the existing failure policy and paired one-standard-error simplicity rule. Resample the five geographic groups, keeping their months and all cover-exclusion appearances together.

With only five geographic units, this supplies **a rough selection heuristic, not a well-calibrated confidence interval**. Report the five geographic contributions and the existing count of bootstrap draws missing a target group. Such draws currently renormalize over remaining groups, so their variation can include changing target coverage.

The winning score remains a development-data selection score. These observations have already influenced earlier designs.

**What the method can establish**

For each cover form, compare each location model with its existing no-location counterpart on identical test observations. Report paired differences overall, inside cover support, and by outside direction/depth and geographic distance. These comparisons require no extra fits.

They answer: **does including location improve modern prediction at the geographic separations and cover departures tested here?**

They cannot establish that location represents climate, that modern spatial relationships persist through the Holocene, or that the fitted cover response is causal.

Nor is this literal geographic distance matching to the hindcast. Most March–September target locations coincide with calibration locations, whereas winter targets include substantial geographic gaps. The proposed score measures deliberately separated transfer capability, weighted towards historical cover conditions. It is not an unbiased hindcast RMSE.

**Alaska fragility**

The design broadens testing beyond the old tail observations and prevents nearby training assistance throughout the test areas. **It cannot guarantee reduced Alaska influence.** Rare cover and geography remain concentrated there.

Use the same weighted errors to report each geographic group’s and existing 5° block’s contribution to paired MSE differences. This makes concentration visible without another fit or a new selection rule.

Do not remove Alaska or cap its influence to produce stability. The recorded 61% concerns the **additive squared-error margin**, not an RMSE margin. The new design must earn a more geographically distributed result; it cannot assume one. [Revised evidence](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/docs/cc/2026-11-10_cv_protocol_v2_results_review_fable.md:84).

**4. Implementation scope, verification and line cost**

Update the existing CV helpers and tool directly. Preserve the model registry and pipeline configuration structure.

The downstream comparison also needs changing: `validation_limits()` currently filters to **<250 km**, and the comparison tool reads `nearby_coverage.csv` and describes limits “near training.” Those consumers must describe the new tested observations consistently. Otherwise the hindcast report would retain the old scientific meaning. See [the current consumer](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/R/hindcast_comparison.R:148).

The selected model still reaches the pipeline through the configured model ID: script 4 fits it on full data, script 5 supplies the prediction fit, and scripts 6 → 7a → 8 → 9/10 produce albedo and forcing. No automatic application of the CV winner is proposed.

Planning estimate, including required follow-up records:

| Work | Added | Removed |
|---|---:|---:|
| `R/cross_validation.R` | 90 | 70 |
| `tools/cross_validate_albedo.R`, excluding the independent deletion below | 165 | 147 |
| Existing hindcast comparison helper and tool | 50 | 50 |
| Existing targeted tests | 120 | 100 |
| Authoritative method record; README, changelog and living-question updates | 200 | 10 |
| Verification specifications | 200 | 0 |
| Generated verification reports | 425 | 0 |
| Conditional recovery, winner-pipeline and comparison specifications/reports | 250 | 0 |
| **Method and follow-up subtotal** | **1,500** | **377** |
| Independent deletion: obsolete protocol-1 membership comparison | 0 | 23 |
| **Total** | **1,500** | **400** |

**Estimated total: +1,500 / −400 = +1,100 lines.** This is a planning allowance, not a measured patch. The additions are shown separately from the unrelated deletion. No new schema or dependency is proposed.

Required verification records account for much of this cost: existing fit specifications have about ten lines and their reports about 23. Fifteen combined-split jobs alone therefore produce approximately 495 lines.

After approval, use `tools/verify_change.R` with focused checks of:

- Separate test and exclusion masks, achieved geographic separation and global cover exclusion.
- Monthly training rows and hull geometry.
- Hand-calculated weights, repeated appearances and missing target mass.
- Identical rows for matched location comparisons.
- Consistent tested-support reporting downstream.

Replace obsolete nearby and separate-in-range expectations in the existing tests. Do not add a parallel test framework.

**5. Fit cost and measured runtime evidence**

| Component | Protocol 2, before retries | Proposed new work |
|---|---:|---:|
| Main CV | 540 | Up to **2,700** |
| Separate in-range diagnostic | 24 | **0** |
| Full-data capacity comparison | 28 new, two reused | **0**, if existing inputs and formulas remain applicable |
| Synthetic recovery | 360 | **0** if existing evidence covers the winner; otherwise up to **360** through the existing procedure |
| Winner’s unchanged pipeline | 192 | **0** if an applicable completed run exists; otherwise **192** |

The main count is **5 geographic groups × 3 cover exclusions × 12 months × 15 candidates = 2,700 fits**, five times protocol 2’s main CV. Actual feasibility can reduce it. Retries are additional.

Protocol 2 used **952 new fits before its winner pipeline**, or **1,144 including that pipeline**. The proposed work ranges from the feasible CV fits alone to **3,252 fits** if all CV combinations are feasible and recovery and a winner pipeline are needed. AIC, matched location comparisons and influence summaries add no fits.

Recorded elapsed job runtimes provide context only:

| Protocol-2 job | Recorded elapsed |
|---|---:|
| d3 March, fifteen candidates | 10 min 26 s |
| d1 April, fifteen candidates | 13 min 36 s |
| d3 December, fifteen candidates | 32 min 23 s |
| d1 June, including a failed retry | 62 min 39 s |
| d2 January, including a model-8 retry | 6 h 48 min 53 s |
| Recovery jobs, sixty fits each | 57 min 26 s–66 min 08 s |
| Whole winner pipeline | 22 h 53 min 08 s |

These are measured jobs, not forecasts for the proposed folds. Counts and execution arrangements are documented in the [protocol-2 run record](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/docs/cc/2026-11-06_cv2_run_order.md:30) and its linked verification reports.

**6. Decisions for Chris or Andria**

These are questions for the subsequent decision; no approval is inferred from this design.

1. **Chris — the combined mechanism:** Do you approve five contiguous geographic groups crossed with the three fixed 80th-percentile cover exclusions, with separate test/training-exclusion masks and a common geographic buffer? This enables simultaneous geographic separation and cover novelty; the present single mask and nearby-only score cannot provide it. Spatial blocks alone are simpler but do not ensure cover novelty. The affected files and approximately **+1,500/−377** mechanism-and-follow-up cost are listed above; the independent 23-line deletion is separate.

2. **Chris — the selection target:** Should selection represent the complete historical area-and-ice-weighted target, as recommended, rather than only its approximately 13% outside the modern cover hull? The choice determines whether ordinary-cover performance can outweigh an advantage on unusual mixtures.

3. **Chris — geographic separation:** After approved preparation examines spatial dependence, what common buffer distance is scientifically acceptable? Neither the existing 250 km cutoff nor 5° block size establishes that distance. If an adequately separated winter comparison is infeasible, should those months remain explicitly untuned rather than weakening separation?

4. **Andria — interpretation of location:** If location improves geographically separated modern prediction, is that sufficient to retain it as an empirical spatial adjustment while leaving its interpretation as climate unresolved? This tests predictive usefulness; it does not identify the process represented by the term.

5. **Chris and Andria — persistent disagreement:** If geographically separated prediction remains similar between candidates whose vegetation forcings differ, should the paper present that difference as model sensitivity and leave the northeast sign unresolved? CV cannot choose between equal prediction scores using an unobserved historical response.

**Not worth doing**

- A new fold framework, model registry, scheduler, dependency or approval register.
- Searches over block orientations, radii, cover cuts and candidate grids in this experiment.
- Nested CV solely to turn these repeatedly inspected data into an allegedly untouched assessment.
- Geographic distance matching that assigns zero selection weight to the separated summer tests.
- Adding regional weighting or deleting Alaska after seeing which choice produces the preferred result.
- Replacing the existing cover geometry with a learned predictor-distance metric.
- Treating successful prediction or synthetic recovery as proof of the historical vegetation effect.

**Limits of this design and this review**

The exact combination, five geographic bands, fixed cover cut and complete-target score are proposed adaptations requiring approval. The buffer distance and achieved feasibility remain unresolved empirical quantities. Five geographic groups provide limited replication, and a single west-to-east partition does not test every form of geographic transfer.

No modern holdout observes historical albedo, past climate or a cover intervention at a fixed location. Validation support must still be reported by month, direction and tested depth; an open-ended ≥0.10 band cannot validate arbitrarily deep departures.

I read the project rules, overview, specified method records, relevant code and consumers, tests, reviews and accessible protocol-2 tables. No current Fable design was consulted. No files were changed, no R or pipeline scripts were run, and no issue, commit or push was made. The questions above remain in this record rather than being written to the living question files, as required by this session’s read-only access.