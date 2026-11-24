**Reconciliation — 23 November 2026**

**Benefit to the paper:** select the albedo model using tests of unfamiliar cover without nearby training observations, while preserving evidence about what those tests cannot establish.

**1. Agreement, deletion and reuse**

Both designs combine global cover-tail exclusions with geographic separation, retain the fifteen candidates and existing fitting machinery, and compare location terms on identical test observations. Neither establishes historical albedo accuracy, a causal vegetation response, or reduced Alaska influence.

Delete the obsolete protocol-1 membership comparison, approximately **23 lines**. Reuse the existing geometry, target weights, fitting, scoring and reporting functions. Retain the in-range diagnostic and monthly tested-depth evidence if adopting Fable’s tail-only tests.

**2. Differences and my recommendation**

| Difference | Recommendation after reconciliation |
|---|---|
| **Four clusters of tail cells versus my five west-to-east bands** | Prefer Fable’s narrower construction for the outside-hull question. It avoids withholding whole bands merely to test their tail cells and saves **540 tuning fits**. This is a design judgement: neither partition’s training loss or winter feasibility has been measured. Specify the clustering coordinates; compactness in longitude/latitude degrees is not compactness in kilometres. |
| **250 km versus a distance chosen from spatial-dependence evidence** | Retain my recommendation to examine the evidence before fixing the distance. Fable’s error table mixes geography, cover depth and months; its plateau cannot identify an autocorrelation range. Examine no-location residuals and response/predictor fields, not model-8 residuals alone. |
| **Tail cells/outside-hull target versus all test cells/full historical target** | **Fable is right to keep the narrower objective for this change.** My expansion changes the selection question substantially. The outside target is **12.8158%** of historical weight; incorporating the other **87.1842%** needs a separate scientific decision. Keep the existing in-range diagnostic beside selection. |
| **All four clusters must be feasible versus feasibility per split** | Retain feasibility per cluster–direction–month, with the same mask for every candidate and missing coverage disclosed. Fable’s all-four requirement is an additional refusal rule, not existing behaviour. |
| **5° block resampling versus my five geographic groups** | Retain the existing block resampling as a selection heuristic. Five groups would provide very limited replication; Fable’s direction-specific clusters also do not define common geographic units. Neither proposal establishes calibrated uncertainty. |
| **Repeated predictions** | Retain protocol 2’s treatment of holdout appearances and keep their physical blocks together during resampling. My additional within-cell averaging is unnecessary for this narrower revision. |
| **Influence reports** | Prefer additive contributions to the weighted squared-error difference. Removing a cluster and recalculating the score changes denominators; it is a different sensitivity analysis. Direction-specific cluster numbers must not be treated as common regions. |
| **Cover-cut fallback** | Make the fixed 80th-percentile choice explicit. Protocol 2 currently permits 70/90 fallbacks; “unchanged” and “fixed 80%” are different instructions. I recommend the fixed cut. |

The buffer recommendation follows *Technical note: Estimating unbiased transfer-function performances in spatially structured environments*, Trachsel and Telford (2016), §2, DOI **10.5194/cp-12-1215-2016**, which examines residual variograms and warns against excessive separation. Roberts et al. (2017), *Cross-validation strategies for data with temporal, spatial, hierarchical, or phylogenetic structure*, DOI **10.1111/ecog.02881**, also warns that fitted models can conceal dependence in residuals. Neither supplies a distance for this dataset. [Trachsel and Telford](https://cp.copernicus.org/articles/12/1215/2016/cp-12-1215-2016.pdf), [Roberts et al.](https://www.biom.uni-freiburg.de/mitarbeiter/dormann/roberts-et-al-2017-ecography.pdf/at_download/file).

**3. Errors and omissions in Fable’s design**

- **The in-range deletion is unjustified.** [Line 113](docs/cc/2026-11-23_cv_spatial_folds_design_fable.md) says its question is answered by the main folds, contradicting line 93. Tail cells are outside the remaining hull; the existing diagnostic specifically selects distance-zero observations at [tools/cross_validate_albedo.R:346](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tools/cross_validate_albedo.R:346). Retaining it costs up to **24 fits**.

- **Removing the nearby/far distinction does not justify deleting monthly depth evidence.** The proposed deletion at line 114 loses month-by-direction maxima and untested combinations. The downstream report explicitly relies on that distinction at [tools/compare_cv_hindcasts.R:495](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tools/compare_cv_hindcasts.R:495). Retain the information with the new tested population.

- **“No better than no location beyond 250 km” is false.** Line 77 contradicts the saved same-cover linear comparison:

  | RMSE | 250–500 km | ≥500 km |
  |---|---:|---:|
  | Location 500 | 0.140 | 0.125 |
  | No location | 0.200 | 0.265 |

  These reproduce from [by_distance.csv](/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2/by_distance.csv). Comparing old and buffered fits would measure the effect of additional training exclusion, not uniquely identify “what neighbours were worth.”

- **“Reuse unchanged” understates the necessary changes.** Test membership must be separated from training exclusion: the current function tests every withheld cell at [tools/cross_validate_albedo.R:114](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tools/cross_validate_albedo.R:114). Also, [validation_limits():148](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/R/hindcast_comparison.R:148) explicitly filters to distances below 250 km. Renaming coverage alone would leave that consumer wrong.

- **The cost omits required records.** Twelve verification reports alone add approximately **276 lines**, absent from Fable’s **+400/−215** estimate. Its **240 recovery fits** are attainable through reuse, but the [current driver:157](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tools/check_cv_separation.R:157) can refit all three models, costing **360**. Reuse requires a scoped change.

- **The precedent claim needs narrowing.** Wang, Khodadadzadeh and Zurita-Milla (2023), *Spatial+: A new cross-validation method to evaluate geospatial machine learning models*, DOI **10.1016/j.jag.2023.103364**, combines geographic and feature information in constructing folds. It supports joint validation in principle, not this particular cover-tail-and-buffer recipe. [Published paper, §§2.2.1–2.2.2](https://ris.utwente.nl/ws/portalfiles/portal/420737852/1-s2.0-S1569843223001887-main.pdf).

Fable’s target shares, distance table, June far-cell counts and runtime totals otherwise check out. Its warning that Alaska influence need not diminish is correct; predicting that it will increase remains conjecture. I dropped one immaterial rounding discrepancy.

**4. Recommended reconciliation, cost and decisions**

Recommend **four geographic clusters within each of three fixed cover tails**, testing only cluster tail cells and excluding the whole directional tail plus a common geographic buffer from training. Choose that distance from spatial-dependence evidence before candidate scoring. Retain outside-hull weighting, per-split feasibility, the in-range diagnostic, monthly depth limits, matched location comparisons and block contributions.

This is my proposed reconciliation, not a claim that Fable has endorsed these corrections.

| Work | Fits before retries |
|---|---:|
| Main comparison: 4 × 3 × 12 × 15 | Up to **2,160** |
| Existing in-range diagnostic | Up to **24** |
| Recovery, if required, using current driver | Up to **360** |
| New winner’s unchanged pipeline, if required | **192** |
| **Maximum with those follow-ups** | **2,736** |

Twelve full-data no-location fits already exist under `cv2-winner/output/calibration/`; inspect those before proposing additional residual-analysis fits. Their binary contents were not checked here.

Measured protocol-2 totals are **973.9 fit-minutes** for 540 directional jobs and **71.6** for 24 in-range jobs. These are sums of logged durations, not forecasts.

Allow approximately **+1,200/−150 = +1,050 lines**, including code, tests, method updates, verification specifications/reports and conditional follow-up records. Separate the proposal’s **+1,200/−127** from the unrelated **23-line deletion**. This is a planning allowance, not a measured patch.

Remaining questions:

- **Chris:** Should the geographically separated cover-tail score replace nearby-only selection, retaining the outside-hull target, or remain a diagnostic beside it? The proposed mechanism enables simultaneous geographic separation and cover novelty; the current score cannot. The simpler alternative retains current selection. It affects the existing CV and hindcast-comparison helpers/tools, their tests and records, at the line cost above.
- **Chris:** After spatial-dependence plots are examined, what common buffer distance is acceptable? If it leaves winter splits infeasible, may those remain explicitly untuned rather than weakening separation?
- **Andria:** Is improved prediction of unfamiliar cover at new modern places sufficient evidence to retain a location term? Interpreting it as climate or snow does not establish that its modern relationship applies through the Holocene.

**Not worth doing:** a new fold framework, candidate registry, radius search, automatic instability veto, or regional reweighting to suppress Alaska.

**Limits:** no files changed, no R or pipeline execution, and no new feasibility calculation. Published passages were checked; dedicated reference checkers were not run. Questions remain here under the read-only instruction.