# Redesign: tune prediction, then test recovery of the cover effect

**Summary**

- Replace the heterogeneous candidate list with a controlled grid of 12 configurations.
- Keep REML: it already estimates smoothing penalties within every fit.
- Tune location capacity and cover complexity jointly.
- Nest tuning inside the existing directional holdouts to assess the tuning procedure.
- Test recovery of known cover and location effects on the real cells and covers.
- Use recovery to qualify the northeast interpretation, not to select the desired sign.
- Report prediction error against distance outside the training range.
- Nominal total: **2,328 fits before retries**, including diagnostics and full-data refits.
- Everything below is a proposal; no files or records were changed.

## 1. Tuning

**Benefit to the paper:** choose a model through a reproducible search over the features that control extrapolation, and distinguish its tuning score from its subsequent assessment.

### What needs tuning

The existing implementation already fits smoothing penalties by REML. The missing step is a systematic search over the permitted forms and capacities of the smooths. Basis size, `k`, limits the functions a smooth can represent; it does not directly determine its fitted wiggliness. [Wood, 2011](https://doi.org/10.1111/j.1467-9868.2010.00749.x); [official mgcv guidance on `k`](https://stat.ethz.ch/R-manual/R-devel/library/mgcv/html/choose.k.html).

Use this **complete 4 × 3 grid**:

| Location term | Linear cover: `ET + ST` | Existing cover smooth, `k = 50` | Existing cover smooth, `k = 200` |
|---|---:|---:|---:|
| Absent | ✓ | ✓ | ✓ |
| Existing GP basis, `k = 30` | ✓ | ✓ | ✓ |
| Existing GP basis, `k = 100` | ✓ | ✓ | ✓ |
| Existing GP basis, `k = 500` | ✓ | ✓ | ✓ |

Keep the nonlinear cover term as the existing `s(OL, ET, ST, bs = "tp")` throughout. The current `mod8_small_cover` changes both basis representation and size; it is not a clean test of reducing `k`.

This grid includes model 8, the previous coarse-location winner and the existing linear and no-location controls. Its purpose is to test combinations: a smaller cover surface may work differently with a coarse location surface than with a flexible one.

Keep these fixed:

- Beta response distribution and logit link.
- Elevation smooth at `k = 50`.
- Existing location and cover basis families.
- REML and the existing convergence/retry policy.

Do not add a second search over smoothing methods, arbitrary penalty multipliers or elevation sizes without evidence that those choices are limiting performance. Record estimated smoothing penalties, effective degrees of freedom and basis-adequacy diagnostics while each fit is available.

**The grid and its numerical values are our adaptation.** Published practice supports tuning and checking smooth complexity; it does not prescribe these values. This is a bounded search, not proof of a global optimum.

**Code effect:** replace `CV_MODELS` with the 12 configurations; add the missing combinations through a small, readable construction in `R/model_registry.R`. Remove the other ladder candidates from this CV search, while preserving their definitions and existing pipeline uses.

### How to tune and assess it

Use the existing three directional tail holdouts as **outer assessment holdouts**. Inside each:

1. Exclude the outer holdout’s cells from every monthly training dataset.
2. Construct inner directional holdouts from the remaining cells.
3. Fit all 12 configurations on those inner training sets.
4. Choose **one configuration across months**, using the pooled inner score.
5. Refit that configuration and fixed model 8 on all outer-training rows.
6. Predict the outer withheld observations.

After all three outer assessments, repeat the same tuning procedure on the full modern dataset to choose the final configuration.

The outer results assess the **tuning procedure**. They must not select the final configuration or revise the grid. This separation follows nested-validation practice; its application to these overlapping directional holdouts is our adaptation. [Varma and Simon, 2006, Background](https://doi.org/10.1186/1471-2105-7-91).

Freeze the historical target weights and direction angles before fitting. Retain the existing month × departure-direction × cover-distance target, with its area and ice-free weighting. For each validation observation, calculate its departure and distance against **that fit’s training hull**. Do not recalculate the historical scoring target against every nested hull: that would change the objective between searches.

The directional holdouts overlap. They are repeated extrapolation tests, not three independent samples. Preserve a geographic block’s observations together across months and holdout appearances when resampling errors.

### Feasibility before fitting

Nesting makes the training sets smaller. This is a real constraint: one existing December outer training set has 914 rows, while the largest configuration has 748 coefficients.

For each inner direction–month:

- Try the 80th-percentile cut.
- Require enough training rows for the largest configuration and at least ten geographic blocks containing positively weighted validation observations.
- If infeasible, try the 90th-percentile cut using the same checks.
- If neither passes, mark that combination untested for **every** configuration.

This fallback is a new, predictor-only adaptation. Freeze all memberships and feasibility masks before fitting. Show the represented target weight for each tuning exercise; missing groups must not count as zero error.

A failed candidate fit excludes that candidate under the existing rule. It does not permit changing its validation rows. A failed outer selected fit makes that assessment incomplete; outer results must not be used to choose a replacement.

### Selection rule and the in-range trade-off

Retain the existing rule: among eligible configurations within one standard error of the paired MSE difference from the best, choose the one with fewer coefficients, then use a fixed table order. Retain the block resampling.

Yates and colleagues discuss both uncertainty-aware selection and paired score differences. The project’s exact block-resampled rule remains an adaptation, rather than their exact modified one-standard-error formula. [Yates et al., 2023, equations 7–8](https://doi.org/10.1002/ecm.1557).

Keep the existing in-range holdout for the final configuration and model 8, reported separately. Because configuration selection has already used this dataset, call this a **development diagnostic**, not an independent assessment of the tuning procedure.

My recommendation is to retain the approved outside-range objective. However, Chris must explicitly accept that this can select a model that is worse inside the range. If acceptable in-range performance is to become a constraint, it must enter the inner selection rule before fitting.

Spatial blocks remain useful for the in-range diagnostic and error uncertainty. Replacing the directional holdouts with spatial blocks would change the question: geographic transfer and cover extrapolation are different tasks. Neither observes changed historical cover at the same modern location. [Roberts et al., 2017, Box 4](https://doi.org/10.1111/ecog.02881).

Finally, these observations have already informed earlier analyses and this redesign. Nesting limits optimism from the **new search**; it cannot make the dataset untouched again. Describe the result as a development-data assessment of the frozen tuning procedure.

**Code effect:** add nested memberships and orchestration to the existing holdouts–fit–score workflow. Reuse fitting, scoring, convergence checks and `cv_choose()`. Reduce the in-range model list to the final configuration and model 8.

### Fit count

Assuming three feasible directions and twelve months:

| Work | Fits |
|---|---:|
| Three outer holdouts × three inner holdouts × twelve months × twelve configurations | 1,296 |
| Outer-selected configuration and model 8 | 72 |
| Final tuning on all modern data | 432 |
| Full-data final configuration and model 8 | 24 |
| In-range diagnostic for those two configurations | 24 |
| Recovery experiment below | 480 |
| **Total before retries** | **2,328** |

Duplicate configurations and infeasible combinations reduce this count. The tuning search itself uses 432 fits, against the original 468; most additional fits provide assessment and recovery checks.

## 2. Can the model separate latitude from evergreen cover?

**Benefit to the paper:** establish whether accurate total albedo can conceal an incorrectly estimated vegetation response.

Spatial-confounding research shows that recovery of a covariate effect depends on its relationship with spatial variation, including their relative scales. Predicting the response well does not establish that its components have been allocated correctly. [Paciorek, 2010, §§2.1–2.4](https://doi.org/10.1214/10-STS326); [Dupont et al., 2022, §4](https://doi.org/10.1111/biom.13656).

### A small recovery experiment

Test three distinct configurations:

1. The final tuned configuration.
2. Original model 8.
3. The tuned configuration with its location term removed, retaining the same cover and elevation terms.

Use April and May, four known truths and twenty synthetic datasets per truth: **at most 480 fits**.

Keep the real cells, covers, elevation, coordinates and monthly missingness. Replace only albedo. Fit the synthetic datasets using the ordinary fitting function and convergence rules.

A concrete proposed generator is:

\[
\eta_i=a+0.5A\,z(OL_i)+0.25A\,z(elev_i)+bA\,z(ET_i)+g(x_i,y_i),
\]

\[
\mu_i=\operatorname{logit}^{-1}(\eta_i),\qquad
Y_i\sim\operatorname{Beta}(\mu_i\phi,(1-\mu_i)\phi).
\]

Here, \(z\) means centering and scaling across that month’s actual fitting cells. Freeze:

- \(a\): logit of the median observed monthly albedo;
- \(A\): standard deviation of the old model-8 fitted linear predictor;
- \(\phi\): its estimated beta precision.

These use the old fit to set plausible scales, **without copying its fitted cover or location functions as truth**.

| Synthetic truth | \(b\) | Known location effect |
|---|---:|---|
| Evergreen darkens | −0.5 | \(A\,z(y)\) |
| No evergreen–summergreen effect | 0 | Same |
| Evergreen brightens | +0.5 | Same |
| Evergreen darkens, with additional shorter-scale spatial variation | −0.5 | \(A\,z\{z(y)+\sin(2\pi y/4)\cos(2\pi x/8)\}\) |

The amplitudes, wavelengths, four cases and replication count are **our stress-test choices**, requiring Chris’s agreement before implementation. They are not published biological estimates. Print the resulting albedo contrasts and northeast cover–location correlations so their strength is visible.

Use identical synthetic datasets across configurations. Independent beta draws conditional on the specified spatial surface isolate allocation of mean structure. They do not test unmodelled spatial residual dependence or uncertainty in reconstructed cover.

### Measure the cover effect directly

At each eligible modern northeast cell, compare:

\[
(ET-0.05,\ ST+0.05,\ OL)
\quad\text{and}\quad
(ET+0.05,\ ST-0.05,\ OL).
\]

Require both evergreen and summergreen fractions to be at least 0.05. Keep location, elevation and open land fixed.

The second prediction minus the first is the effect of **ten percentage points more evergreen replacing summergreen**. Negative means evergreen darkens the surface.

Calculate the exact contrast from the synthetic truth and from each fitted model. Use common cell-area weights. Report cells with both endpoints inside the monthly hull separately from physically valid exchanges outside it, retaining their distances. Do not silently change the cell set to improve recovery.

Also evaluate the historical-size exchange: change evergreen from its 6 ka value to its 4.5 ka value while holding open land at its 6 ka value and adjusting summergreen to the remainder. Check that the mixture remains valid. This isolates the evergreen–summergreen exchange; it is distinct from the full historical change, which can also alter open land.

Recover the location component separately: compare the fitted location term with the known spatial surface on the link scale, centering both with the same northeast area weights. This detects compensating errors between cover and location.

### What constitutes recovery, failure or an unresolved result?

For each configuration, month and truth, report:

- Contrast bias and RMSE.
- All twenty recovered contrasts against the known value.
- Wrong-sign counts for nonzero truths.
- Invented contrasts under the zero-effect truth.
- Error in the centered location surface.
- Monte Carlo uncertainty and fit failures.

This follows published simulation-study guidance on specifying truth, estimands and performance measures. Twenty repetitions are deliberately modest: the worst-case Monte Carlo standard error of a sign frequency is about 0.11. They can expose persistent failures, but cannot certify a precise success rate. [Morris et al., 2019, §§3 and 5](https://doi.org/10.1002/sim.8086).

**Recovery** means tracking the known magnitude and sign, including the reversed and zero truths, while also recovering location. **Failure** includes systematic reversal, an appreciable invented null effect, or compensating component errors despite accurate total predictions. **Unresolved** means uncertainty is too large to distinguish these.

Recommend reporting recovery **beside predictive selection**. A failure prevents a confident northeast vegetation-sign claim from that configuration. It does not trigger selection of another model because that model gives the preferred sign. A numerical pass/fail gate would require a scientifically meaningful error tolerance fixed beforehand.

Passing establishes recovery under these stipulated truths. All configurations assume a common cover response across locations, so recovery in the northeast can depend on information elsewhere. It does not demonstrate that the real northeast response is identical to that elsewhere, or establish the historical sign.

### What the observations themselves can tell us

Add one small northeast summary, using the existing one-degree latitude rows:

- Evergreen range and number of cells at each latitude.
- Open-cover and elevation ranges beside them.
- Existing held-out prediction errors for cells with relatively high or low evergreen cover within those rows.

This checks whether observations actually provide variation that separates the predictors. The existing latitude-adjusted albedo plot is useful, but its adjustment does not also control open cover and elevation.

A spatial holdout that preserves the evergreen–latitude relationship does not break the confounding. Neither does randomly splitting those cells. Where comparable cells are absent, report insufficient local information.

**Code effect:** add one small recovery tool using the registry. Extract the existing fitting-and-retry operation into a shared helper returning the fitted object and status. Share the cover-exchange calculation with the northeast/comparison tools; remove duplicate implementations. No new modelling framework.

## 3. How far outside?

**Benefit to the paper:** replace a binary interpretation of extrapolation with observed prediction performance at relevant distances.

Retain `training_hull()`, `training_support()` and the existing bands:

- Inside: distance zero.
- Outside: 0–0.02, 0.02–0.05, 0.05–0.10 and beyond 0.10.

A simple exchange of 0.10 between two cover classes travels 0.10 on this triangle. Distance to the hull is a geometric distance; it need not describe a change in one particular class.

For the **outer assessment predictions**, report by month, departure direction and cover-distance band:

| Quantity | Purpose |
|---|---|
| RMSE and mean signed error | Accuracy and systematic brightening/darkening |
| Paired difference from model 8 | Whether tuning improves the tested task |
| Unique cells and geographic blocks | Amount of evidence |
| Actual distance range and central quantiles | How far the test observations reached |
| Historical target weight represented | Relevance to the reconstruction |

Retain geographic-distance bands beside these, and show northeast results explicitly. Do not fit an extrapolated error curve beyond observed distances.

This follows distance-profile and applicability practice. Reusing the triangle-hull distance, its bands and the historical weighting is our lighter adaptation. [Brenning, 2023](https://doi.org/10.1080/13658816.2022.2131789); [Meyer and Pebesma, 2021, §§2.5–2.6](https://doi.org/10.1111/2041-210X.13650).

Two corrections matter:

1. The existing distance report pools observations within bands; it is not the target-weighted primary score. Label it accordingly, or calculate a target-weighted summary with the existing scoring function.
2. Membership of the open-ended band does not demonstrate unlimited support. If its observed distances end at 0.112, a historical distance of 0.16 exceeds the tested span.

Likewise, `represented = 1` means every coarse target group has observations. It does not mean accurate or locally comparable prediction. The recorded northeast-relevant May tail has only fifteen cells in five blocks, with summergreen cover below the historical northeast value.

In the hindcast comparison, retain Chris’s **single outside-hull flag**, accompanied by numeric distance and its band. For a period, retain the existing endpoint rule and report the largest endpoint distance. Show the relevant validation errors beside the area shares.

Use wording such as:

> This result lies within the cover-distance span sampled by modern validation; the corresponding errors and observation counts are shown.

Do not translate that into “validated historical effect.” Equal distance does not imply equal mixture, location or snow conditions. If “shown to handle” must mean satisfactory accuracy, Chris and Andria need to define an acceptable error beforehand.

**Code effect:** extend existing distance summaries and the planned comparison table. Reuse monthly hull geometry; add no new support index or classification hierarchy.

## 4. What to rerun

**Benefit to Andria:** obtain one reproducible, interpretable result from a protocol that states exactly what was searched and assessed.

Rerun the entire CV under a new protocol. Preserve the first protocol and results as the previous experiment.

Reuse:

- The same calibration source and preprocessing.
- Historical covers, months, ages, area and ice inputs.
- Outer directional holdout rules, geographic blocks and distance bands.
- Existing fitting, convergence, scoring and record functions.
- The existing in-range diagnostic design.

Regenerate the outer holdout records from those inputs and confirm whether membership matches the first run. Construct and freeze the inner memberships before fitting. Do not mix old predictions into the new experiment.

The new protocol must state:

1. Prediction target, weights and what the assessment cannot establish.
2. All twelve configurations and fixed fitting settings.
3. Outer and inner construction, feasibility fallback and omitted-weight reporting.
4. Selection, tie-breaking, failure and retry rules.
5. Separation of tuning scores, outer assessment and in-range diagnostics.
6. Synthetic truths, scale-setting rules, seeds, contrasts and interpretation.
7. Distance summaries and any agreed accuracy tolerance.
8. Inputs, code version, package versions, output records and fit count.

Use the existing bounded queue for holdout–month commands. Each fit remains single-threaded; retain the current shared-machine job limit. No scheduler rewrite is needed.

After selection and diagnostics, run the final configuration and model 8 through the existing hindcast pipeline in separate run folders. Build the comparison tool **beside** the northeast figure tool, retaining Chris’s area weighting and Fable’s trimmed figure set.

**Code effect:** add nested records and recovery outputs; remove obsolete candidates from the CV workload. Preserve the old diagnostic and reuse pipeline stages.

## 5. Reviews, verification and records

**Benefit to the paper and Andria:** verify that the implementation follows the scientific design without introducing a second analysis workflow.

Before implementation, give Fable and Astra the same frozen design independently, beginning with the paper benefit and Chris’s simplicity rule. Give them the same implementation independently afterwards. Reconcile once. Use the change-reviewer for paths, records and execution plumbing.

Findings should carry file/line, consequence, evidence and a proposed check. Discard suggestions that add complexity without correcting a real defect, and record the number discarded and why.

Verify through `tools/verify_change.R`, in its own worktree at the exact implementation commit. Necessary checks include:

- Existing configurations reproduce their current formulas and predictions.
- Outer withheld responses cannot affect inner selection.
- Compared configurations use identical scoring rows and weights.
- Nested distances use the correct training hull.
- Missing groups and failed fits remain visible.
- Hand-worked selection examples give the expected answer.
- Synthetic exchanges preserve valid fractions, reverse correctly and have zero true contrast under the null.
- Cover and location recovery summaries match the stated truth.
- Distance tables retain actual sampled limits and correct denominators.

Run targeted executable checks first, then the registered CV and recovery experiment. Keep unchanged-output checks against existing anchors where applicable.

For future implementation, follow `CONTRIBUTING.md`: issue first, topic branch from `chris-dev`, atomic commits, verification evidence, pushes and the normal merge route. Record the protocol, decisions, scientific precedents and results under dated descriptive names. Update the two living question documents with unresolved questions and their origin.

Publisher identities and supporting passages were checked for this design, with source-access limits noted below. **The project’s combined RefChecker/refaudit check was not run in this read-only session.** Complete it before implementation and retain the claim-to-passage checks; resolving a DOI alone is insufficient.

No issue, branch, file, question record or run was changed in this session.

## 6. What Chris and Andria must decide

| Decision | Recommendation |
|---|---|
| Does outside-range accuracy remain the selection objective despite possible in-range loss? | Keep it, but state the trade-off explicitly. Any in-range constraint must enter inner tuning before fitting. |
| Is the 12-configuration search sufficient for this rerun? | Yes: jointly vary location and cover, keeping elevation and REML fixed. |
| Should the paper report assessment after tuning? | Use the nested directional design; call it development-data assessment, acknowledging prior use of these observations. |
| Are the proposed synthetic effects and spatial scales scientifically useful? | Approve or amend the four truths before fitting; print their actual albedo contrasts. |
| Should recovery select the model? | No. Use it to limit the northeast interpretation. Define tolerances first if a formal gate is wanted. |
| What error would count as acceptable at a given extrapolation distance? | Specify it if “shown to handle” needs a pass/fail meaning; otherwise report errors and sampled distances directly. |
| Is a common cover response across regions acceptable for interpreting the northeast? | Make this assumption explicit. If recovery fails or local information remains inadequate, retain competing reconstructions and qualify the sign. |

## Not worth doing

- A large automated or Bayesian search over every GAM setting.
- Repeating the old ladder merely to enlarge the candidate count.
- Testing every configuration under every synthetic truth and CV fold.
- Repeating the whole tuning procedure inside the recovery experiment: the proposed experiment tests fixed configurations.
- Choosing a configuration because it reproduces the expected historical sign.
- Shuffling cover to manufacture independence from latitude.
- Treating correlation, concurvity or good total predictions as proof of effect recovery.
- Automatically applying Spatial+ to the nonlinear compositional cover surface: the cited paper’s treatment of covariate effects is linear, so that would require a separate methodological design.
- A new applicability index, extra support labels or an error curve beyond observed distances.
- Precise success-rate or interval-coverage claims from twenty simulations.
- New infrastructure for cases the existing driver and records already handle.

## References with DOIs

- **Wood, S. N. (2011).** Fast stable restricted maximum likelihood and marginal likelihood estimation of semiparametric generalized linear models. *JRSS B*, **73**, 3–36. [DOI: 10.1111/j.1467-9868.2010.00749.x](https://doi.org/10.1111/j.1467-9868.2010.00749.x). Supports REML smoothing estimation; publisher abstract checked, with basis-size guidance checked in the official mgcv documentation.

- **Varma, S., and Simon, R. (2006).** Bias in error estimation when using cross-validation for model selection. *BMC Bioinformatics*, **7**, 91. [DOI: 10.1186/1471-2105-7-91](https://doi.org/10.1186/1471-2105-7-91). Background supports repeating tuning inside outer assessment.

- **Roberts, D. R., et al. (2017).** Cross-validation strategies for data with temporal, spatial, hierarchical, or phylogenetic structure. *Ecography*, **40**, 913–929. [DOI: 10.1111/ecog.02881](https://doi.org/10.1111/ecog.02881). Box 4 supports distinguishing geographic and environmental extrapolation.

- **Yates, L. A., Aandahl, Z., Richards, S. A., and Brook, B. W. (2023).** Cross validation for model selection: A review with examples from ecology. *Ecological Monographs*, **93**, e1557. [DOI: 10.1002/ecm.1557](https://doi.org/10.1002/ecm.1557). Equations 7–8 support uncertainty-aware comparison and distinguish the alternative selection thresholds.

- **Paciorek, C. J. (2010).** The importance of scale for spatial-confounding bias and precision of spatial regression estimators. *Statistical Science*, **25**, 107–125. [DOI: 10.1214/10-STS326](https://doi.org/10.1214/10-STS326). Sections 2.1–2.4 support testing effect recovery across spatial scales.

- **Dupont, E., Wood, S. N., and Augustin, N. H. (2022).** Spatial+: A novel approach to spatial confounding. *Biometrics*, **78**, 1279–1290. [DOI: 10.1111/biom.13656](https://doi.org/10.1111/biom.13656). Section 4 separates effect recovery from fitted-value accuracy; section 7 states the linear-covariate limitation.

- **Morris, T. P., White, I. R., and Crowther, M. J. (2019).** Using simulation studies to evaluate statistical methods. *Statistics in Medicine*, **38**, 2074–2102. [DOI: 10.1002/sim.8086](https://doi.org/10.1002/sim.8086). Sections 3 and 5 support explicit simulation aims, truths, estimands and Monte Carlo uncertainty.

- **Brenning, A. (2023; online 2022).** Spatial machine-learning model diagnostics: a model-agnostic distance-based approach. *International Journal of Geographical Information Science*, **37**, 584–606. [DOI: 10.1080/13658816.2022.2131789](https://doi.org/10.1080/13658816.2022.2131789). Publisher abstract supports prediction-error profiles against geographic distance; cover-hull distance is our adaptation.

- **Meyer, H., and Pebesma, E. (2021).** Predicting into unknown space? Estimating the area of applicability of spatial prediction models. *Methods in Ecology and Evolution*, **12**, 1620–1633. [DOI: 10.1111/2041-210X.13650](https://doi.org/10.1111/2041-210X.13650). Sections 2.5–2.6 support relating prediction conditions to those represented in validation and to the required accuracy.