This design will strengthen the paper by choosing the albedo model on its ability to predict unfamiliar land-cover mixtures, while showing which historical predictions remain beyond what the modern data can test.

**Recommendation.** Use five deliberately constructed land-cover holdouts, with spatial blocks and buffers separating validation cells from training cells. In each holdout, remove one end of a land-cover gradient from training everywhere—not just near the validation region. Compare eleven candidate models, choose one structure across months using only these out-of-range predictions, and assess the chosen model against model 8 on separately reserved geographic blocks. Examine the hindcast and northeast hemlock result only after that choice is locked.

This is a design only. I read the repository guidance, relevant scripts and decisions on `feature/single-config`; no files were changed and no R or pipeline runs were performed. The open questions below therefore remain in this document rather than being added to the living question files.

**Published methods support the components, but the combined recipe below is a project proposal.** I recommend recording that distinction explicitly when Chris approves the implementation.

| Published method | What it supports here | Recommendation |
|---|---|---|
| Roberts, D. R., et al. (2017), “Cross-validation strategies for data with temporal, spatial, hierarchical, or phylogenetic structure,” *Ecography* 40:913–929. DOI [10.1111/ecog.02881](https://doi.org/10.1111/ecog.02881). | Blocking for dependence and deliberately withholding predictor ranges. The paper specifically discusses matching the **magnitude and direction** of extrapolation to the prediction task. | Main foundation. A distant evergreen-rich mixture should not be represented solely by an equally distant open-land-rich mixture. |
| Valavi, R., Elith, J., Lahoz-Monfort, J. J., and Guillera-Arroita, G. (2019), “blockCV: An R package for generating spatially or environmentally separated folds for k-fold cross-validation of species distribution models,” *Methods in Ecology and Evolution* 10:225–232. DOI [10.1111/2041-210X.13107](https://doi.org/10.1111/2041-210X.13107). | Geographic blocks, exclusion buffers, environmental clustering, and predictor autocorrelation as guidance for separation distances. | Use the blocking and buffering principles. Ordinary environmental clusters alone are insufficient: a withheld central cluster can remain inside the training range. |
| Milà, C., Mateu, J., Pebesma, E., and Meyer, H. (2022), “Nearest neighbour distance matching Leave-One-Out Cross-Validation for map validation,” *Methods in Ecology and Evolution* 13:1304–1316. DOI [10.1111/2041-210X.13851](https://doi.org/10.1111/2041-210X.13851). | Matching validation-to-training geographic distances to prediction-to-training distances. | Adopt the requirement to compare the validation task with the actual prediction task. This method addresses geographic distance and does not itself solve substantial land-cover change. |
| Linnenbrink, J., Milà, C., Ludwig, M., and Meyer, H. (2024), “kNNDM CV: k-fold nearest-neighbour distance matching cross-validation for map accuracy estimation,” *Geoscientific Model Development* 17:5897–5912. DOI [10.5194/gmd-17-5897-2024](https://gmd.copernicus.org/articles/17/5897/2024/). | A less expensive, grouped version of geographic distance matching, including quantitative comparison of distance distributions. | Borrow the distance-distribution check. Do not describe the proposed joint geographic and cover procedure as an implementation of kNNDM. |
| Meyer, H., and Pebesma, E. (2021), “Predicting into unknown space? Estimating the area of applicability of spatial prediction models,” *Methods in Ecology and Evolution* 12:1620–1633. DOI [10.1111/2041-210X.13650](https://doi.org/10.1111/2041-210X.13650). | Predictor-distance diagnostics identifying where validation error can reasonably be applied. | Map the conditions actually tested. Retain a common, model-independent cover distance for candidate comparison rather than changing distance weights with each model. |
| King, G., and Zeng, L. (2006), “The Dangers of Extreme Counterfactuals,” *Political Analysis* 14:131–159. DOI [10.1093/pan/mpj004](https://doi.org/10.1093/pan/mpj004). | Convex-hull diagnostics and the growing dependence on model assumptions away from observations. | Retain the repository’s hull diagnostic, supplemented by distance to actual training observations. Being inside a hull does not guarantee nearby observations. |

The source identities and relevant methodological passages were checked against accessible papers and publisher records. This was not an automated RefChecker/refaudit run; the repository’s formal reference audit should accompany implementation.

**The folds should reproduce a specified cover departure, not merely divide the map.** The following choices form a small, fixed protocol rather than a search for folds that favour a model.

1. **Define the prediction population first.** Use the configured historical slices, excluding the modern 50 BP slice, within the reporting domain. My proposed weighting is equal weight per historical slice and month, with cell-area weighting within each slice. Report the subset contributing vegetation forcing separately. These weights are a project judgement: they avoid making the northeast or the hemlock interval disproportionately influential.

   Construct this target from land cover, coordinates, elevation and existing masks. Do not use predicted albedo, forcing, or the expected hemlock sign.

2. **Measure land-cover difference on the existing cover triangle.** The implemented predictors are open land (`OL`), evergreen trees (`ET`) and summergreen trees (`ST`), which should sum to one. Reuse `cover_triangle_xy()` from [R/training_support.R](R/training_support.R).

   For two compositions \(p\) and \(q\), distance on that equilateral triangle is

   \[
   d(p,q)=\sqrt{\frac{(p_{OL}-q_{OL})^2+(p_{ET}-q_{ET})^2+(p_{ST}-q_{ST})^2}{2}}.
   \]

   Replacing ten percentage points of one class with another gives distance 0.10. All three classes receive equal treatment; zeros cause no difficulty. This is the existing project geometry, not an assertion that ecological responses must be proportional to this distance.

   Record both:

   - **Nearest-observation distance:** distance to the closest actual training mixture.
   - **Distance outside the hull:** zero inside the training envelope; otherwise distance to its boundary.

   Also retain the signed changes in all three fractions towards the validation or hindcast point. Distance alone loses the biological direction.

3. **Choose geographic separation in kilometres.** Use a suitable projected grid to construct blocks and check exclusion distances geodesically. Do not calculate kilometre separation from raw longitude–latitude differences.

   Select a common buffer distance before candidate scoring, guided by the spatial correlation ranges of the predictor fields, following the blockCV approach. Record the evidence and chosen distance; a numerical distance cannot responsibly be supplied from code inspection alone. Use blocks large enough to contain multiple grid cells, with a buffer around the **whole held-out block**.

   Check remaining dependence in validation errors afterwards. If material dependence persists across the chosen separation, the claimed independence is inadequate; that is a limitation or reason for a separately documented redesign, not permission to tune the buffer until a preferred model wins.

4. **Reserve geographic blocks for final assessment.** Provisionally reserve about 15% of blocks, distributed across relevant cover conditions. Select them using predictors and availability, with a fixed seed. Their albedo observations and their surrounding guard bands must be absent from **every** development fit and development score.

   The percentage is a practical proposal, subject to the feasibility checks below. The reserved blocks’ predictors may inform fold geometry; their responses must remain unused until selection is complete.

5. **Construct five directional cover holdouts.** From each month’s full calibration hull, draw the departure from the nearest hull boundary to each outside-range hindcast mixture. Pool these departures under the target weights. Summarise them into at most three broad direction families, retaining a plot of the original directions so that a small family is not silently lost.

   Allocate at least one of the five holdouts to each represented direction; allocate the remaining holdouts according to target weight. Different holdouts use different geographic validation blocks where feasible.

   For a chosen direction, order modern mixtures along that gradient. Consider only three predeclared cut points: its 70th, 80th and 90th percentiles. Validation cells lie above the cut; **every training cell must lie below it**. Other above-cut cells remain excluded even when they are outside the geographic blocks being scored.

   This guarantees that each scored validation mixture is outside its training hull. For example, when withholding an evergreen-rich tail, evergreen-rich cells elsewhere cannot supply the missing training examples.

   Select the cut and geographic blocks before fitting candidates, using the actual buffered training sets. Among feasible alternatives, choose the cut with the smallest average mismatch in the 10th, 50th and 90th percentiles of nearest-observation and hull distances relative to the target direction. Record the three alternatives in a small table.

   The five holdouts, three cut choices and direction allocation are **our proposed practical design**, not a published universal optimum. These are repeated structured holdouts, not an exhaustive partition in which every cell must be scored once.

6. **Share assignments across months; calculate support separately by month.** Keep geographic blocks, directions and cover cuts common to all months. Fit separate monthly models, retaining only that month’s observed albedo and complete predictors. All candidates receive exactly the same rows.

   Recalculate hulls and distances from each month’s actual training subset. January cannot inherit May’s support. Missing observations remain missing, and a cell’s twelve months never become twelve independent validation replicates.

7. **Require feasibility before expensive fitting.** For every month and holdout, report training cells, distinct predictor configurations, validation cells, reserved assessment cells and separated blocks. Check model-matrix size and rank as well as row count. The refit documents report about 748 coefficients for the largest current models; winter exclusions may make some proposed splits impossible.

   Require several separated blocks in each reported direction—three is a minimum feasibility floor, not enough for precise uncertainty estimates. If no cut provides sufficient training and validation data, label that direction or month untestable. Do not quietly lower model 8’s basis size, weaken the buffer, or drop difficult validation observations.

8. **Freeze the protocol.** Save the cell memberships, buffers, cuts, target weights, supported distance ranges and candidate list before examining candidate errors. If observations occur in multiple holdouts, divide their scoring weight across appearances and keep those appearances together when estimating uncertainty.

**Demonstrate how closely the folds resemble the hindcast before interpreting their scores.** For each month and cover direction, show validation-to-fold-training and hindcast-to-full-training distributions side by side:

| Diagnostic | What it establishes |
|---|---|
| Nearest-cover distance and hull distance | Whether validation tests comparable amounts of novelty |
| Signed cover departures and absolute cover ranges | Whether it tests the same direction, and how far the analogy relies on shifting the observed range |
| Geographic nearest-training distance | Whether geographic separation resembles the prediction task |
| Locations and elevations of the nearest cover analogues | Whether a similar mixture is available only in a very different setting |
| Number of separated blocks and target share represented | How much independent evidence supports the comparison |

Use the existing hull-distance breaks—0.02, 0.05 and 0.10—for readable reporting, supplemented by the full distance distributions. Freeze the common set of represented month–direction–distance groups before scoring any model.

There is an unavoidable mismatch: many hindcast locations coincide with modern calibration locations, so their geographic distance to training is zero. Buffered validation makes that distance positive. These results should therefore be described as **tests of transfer across cover and spatial separation**, not unbiased estimates of historical prediction error. Small geographic and cover distances considered separately also do not establish that one training cell matches both.

A validation case at evergreen cover 0.45, trained only through 0.35, can test a departure of 0.10. It cannot establish accuracy at historical evergreen cover 0.80. Show those absolute ranges explicitly. Where historical directions, distances or compositions have no credible modern analogue, retain an “untested extrapolation” label; do not extend the measured error there by assumption.

**Compare eleven candidates, with only two new formulas.** Preserve the existing eight exactly, including model 8 as the comparator.

| Candidate | Purpose |
|---|---|
| Models 1–2: location, then location plus elevation | Establish how much transfer skill is available without cover. |
| Models 3–5: successive separate cover terms | Test the existing additive alternatives to the joint cover surface. |
| Models 6–8: existing joint cover smooths | Compare today’s alternative joint representations and flexibility. |
| Existing `cover_elev` | Model 8’s cover and elevation terms without location: tests whether removing competition with location improves transfer. |
| New linear cover with location | Replace the joint cover smooth with `ET + ST`, retaining current location and elevation smooths. Tests whether removing cover curvature and interactions improves transfer. |
| New linear cover without location | `ET + ST + s(elev, k = 50)`. Tests a small cover model without competition from location. |

All retain the beta response, logit link and separate monthly fits. `OL` is the reference fraction: an intercept plus all three fractions would be redundant. Both cover coefficients have freely estimated signs. “Linear” here means linear on the **logit scale**, not a physical linear mixture of surface albedos. This model class has established beta-regression precedent: Cribari-Neto, F., and Zeileis, A. (2010), “Beta Regression in R,” *Journal of Statistical Software* 34(2):1–24, DOI [10.18637/jss.v034.i02](https://www.jstatsoft.org/article/view/v034i02).

The with-location/without-location comparison addresses a recognised identification problem. Paciorek, C. J. (2010), “The Importance of Scale for Spatial-Confounding Bias and Precision of Spatial Regression Estimators,” *Statistical Science* 25:107–125, explains how allocation between spatial and covariate effects depends on their scales. It supports investigating that allocation; it does not establish that deleting location removes bias. DOI [10.1214/10-STS326](https://pmc.ncbi.nlm.nih.gov/articles/PMC3082155/).

I recommend no signed monotonicity constraint in this first comparison. Shape-constrained GAMs are established—Pya, N., and Wood, S. N. (2015), “Shape Constrained Additive Models,” *Statistics and Computing* 25:543–559, DOI [10.1007/s11222-013-9448-7](https://link.springer.com/article/10.1007/s11222-013-9448-7)—but the required scientific constraint must specify the month and which cover replaces which. The current northeast result cannot supply that justification.

The exact candidate set is our proposal. It avoids a large search over basis sizes, penalties and spatial restrictions. The existing location smooth uses longitude and latitude in degrees; preserve that in the exact model-8 comparison and identify projected-coordinate modelling as a separate, predeclared scientific choice if Chris wants it included.

**Choose the simplest model with comparable out-of-range predictive performance.** Use the following rule for the first implementation:

- Refit every candidate inside every training split using REML. This compares predictions, so the existing ML convention for comparing AIC values is not required. Smoothing parameters and all other fitted quantities must use training responses only.
- Score squared error of the predicted mean on the **albedo response scale**. Average within the frozen cover-direction and distance groups, then combine using their hindcast target weights and equal month weights. Report its square root as RMSE. This is a score for the represented departures; print the excluded target share beside it.
- Use identical validation observations and weights for every candidate. Report monthly RMSE, mean signed error and mean absolute error as supporting results; they do not change the selection rule.
- Find the lowest primary score. Treat a simpler candidate as comparable when its increase in mean squared error is no larger than one estimated standard error of that **paired increase**, using the same validation blocks for both models.
- Among comparable candidates, select the lowest average effective degrees of freedom across monthly fold fits. Break remaining ties by fewer fitted coefficients, then a fixed registry order.
- Select one structure for all months. Its coefficients and smoothness remain month-specific.

The paired simplicity rule is a declared adaptation of published uncertainty-aware selection practice, rather than a significance test. Yates, L. A., Aandahl, Z., Richards, S. A., and Brook, B. W. (2023), “Cross validation for model selection: A review with examples from ecology,” *Ecological Monographs* 93:e1557, discusses simpler models with comparable scores and the importance of correlation between model scores. DOI [10.1002/ecm.1557](https://esajournals.onlinelibrary.wiley.com/doi/full/10.1002/ecm.1557).

Estimate uncertainty by resampling geographic blocks, keeping all months, repeated appearances and paired model errors together. Resampling dependent observations in blocks has established precedent in Lahiri, S. N. (2003), *Resampling Methods for Dependent Data*, Springer, DOI [10.1007/978-1-4757-3803-2](https://link.springer.com/book/10.1007/978-1-4757-3803-2). These intervals remain approximate: overlapping training sets and few independent blocks limit their interpretation.

Predefine convergence handling. Use the repository’s fitting-loop and optimiser checks, not `bam$converged` alone. Allow a documented retry at a higher iteration limit without changing the formula. A candidate that remains unsuccessful cannot obtain a favourable score by omitting failed folds. If model 8 cannot be evaluated on the common required cases, the requested comparison is incomplete.

Models 1–2 remain eligible. If one wins, it predicts no vegetation-driven temporal change at fixed location and elevation. That means these data did not establish a transferable predictive contribution from cover under this test; it does **not** demonstrate that historical vegetation caused zero forcing.

**Separate choosing the model from demonstrating its advantage.** After selection is locked, evaluate only the chosen model and model 8 on the reserved blocks. For each holdout, score reserved cells satisfying that holdout’s excluded cover-tail condition, using the already fitted fold models. The reserved blocks were absent from all training fits, while the relevant cover tail was excluded everywhere, so both separations remain intact. This requires additional predictions, not another round of GAM fitting.

Report paired absolute and percentage RMSE differences, signed bias, uncertainty and the represented target share. If reserved coverage is narrower than development coverage, restrict both models to that same assessment subset and say so. Do not use the assessment result to choose a different candidate; an unsuccessful assessment is a result.

This separation addresses selection optimism described by Cawley, G. C., and Talbot, N. L. C. (2010), “On Over-fitting in Model Selection and Subsequent Selection Bias in Performance Evaluation,” *Journal of Machine Learning Research* 11:2079–2107. [Publisher paper](https://jmlr.org/papers/v11/cawley10a.html). It is a prospective assessment within an already explored project, not untouched external validation.

**Demonstrate the historical consequences only after selection.** Refit the chosen structure and model 8 on all available calibration observations using the same current MODIS input and other scientific settings. The earlier northeast diagnosis must not substitute for a current MODIS comparator.

Produce three compact sets of results:

1. **Predictive evidence:** the eleven-model development comparison and the reserved chosen-model-versus-model-8 comparison, with error plotted against cover departure and separated by month and direction.
2. **Historical consequences:** paired maps and regional time series of albedo and forcing; differences between the two models; and the proportion of each result resting on tested versus untested conditions.
3. **Northeast interpretation:** use the existing 80–66° W, 40–48° N box. Report every month and the annual forcing result, with 6 to 4.5 ka examined explicitly. Sum the existing 6–5.5, 5.5–5 and 5–4.5 ka forcing steps using the pipeline’s conventions, rather than substituting the broader 6–4 ka summary.

Show the actual reconstructed changes in all cover fractions alongside any illustrative evergreen-for-summergreen curve. Mark unsupported portions of those curves. Report the vegetation contribution and the configured total forcing, with the same kernels and ice treatment in both runs.

Evidence **consistent with an extrapolation artefact** would be independently improved prediction on relevant cover departures, reduced instability of the estimated cover response, and a substantial weakening or reversal of northeast warming after selection. A sign reversal alone is insufficient.

Evidence **against that explanation** would be model 8 matching or exceeding the alternative’s reserved transfer skill, with warming persisting among comparably successful models on relevant tested conditions. If the relevant northeast departures are untestable, either sign remains weakly constrained.

Location and elevation cancel between slices only on the logit scale. Their baseline values still affect response-scale albedo differences through the inverse link. The interpretation should not say that location has no effect on the resulting forcing.

**Keep implementation within the existing model registry and pipeline.** The earlier `6_prediction_model_spatial_eval.R` compares hindcasts from full-data models; it is not cross-validation and should not become the new driver.

| Location | Minimal proposed change |
|---|---|
| `R/training_support.R` | Extend existing geometry to return nearest-cover distance, departure direction and support for supplied monthly training rows. |
| New `R/cross_validation.R` | A few functions to construct the frozen holdout table, check its support, score predictions and apply the selection rule. |
| New `tools/cross_validate_albedo.R` | Read inputs through existing manifests, run the candidate–month–fold loop, and save memberships, predictions and scores. |
| [R/model_registry.R](R/model_registry.R) | Add two formulas and an explicit eleven-model comparison list; reuse `fit_calibration_model()`. Avoid automatically adding new candidates to every existing spatial-experiment loop. |
| `R/config_schema.R` | Permit the chosen additional model IDs in the existing `analysis$calibration$model_id`. |
| Existing support and northeast plotting tools | Use monthly support and permit a clearly labelled chosen-model-versus-model-8 comparison. |
| Scripts 4–10 | Continue using the selected monthly fits and existing prediction, differencing and forcing calculations. Do not duplicate those calculations in the CV tool. |

No new scientific configuration switch is necessary: the existing `model_id` selects the frozen winner. Fold definitions belong in one recorded protocol/table, not a collection of adjustable configuration options. Keep baseline and chosen-model products in separate existing `run$dir` locations.

Future implementation needs the repository’s independent scientific reviews and verification through `tools/verify_change.R`. Targeted checks should establish spatial exclusion, global exclusion of the cover tail, monthly membership, prevention of reserved-response use, common scoring rows and correct propagation of the selected model.

**Budget the fits explicitly.** Five holdouts × eleven candidates × twelve months means **660 monthly model fits**, before retries. The reserved assessment adds predictions only. Score predicted means; do not generate albedo simulations during model selection.

That is roughly 82.5 eight-model monthly batches by fit count, although runtime will differ because the additional candidates are simpler and training sets are smaller. Measure the first batch and project core-hours from it; do not promise linear speedup.

The current fitting helper uses eight threads. Follow the existing ceiling of four concurrent fitting jobs with one maths-library thread each, leaving at least sixteen of the workstation’s 48 cores available. Use fewer jobs when other work requires them, and preserve the approved worktree isolation.

After assessment, up to 24 selected monthly fits are needed for the two full-data models. However, running script 4 unchanged also refits its ladder and spatial experiments: it currently makes sixteen fits per month per run. Include that overhead in the schedule, or separately approve a small “prediction fits only” execution path. Reuse an existing baseline only when its inputs, configuration and fit provenance match exactly.

**The principal limits should remain visible in the paper.** This procedure tests modern transfer under constructed departures. It cannot observe past albedo, validate a historical composition never seen in modern observations, or identify a causal cover-substitution effect solely from accurate absolute-albedo predictions. Spatially interpolated cover also remains an uncertain, spatially dependent input; withholding cells here does not independently validate the upstream pollen reconstruction.

Snow and climate may change the cover–albedo relationship through time. Better CV does not resolve those changes. Model-based simulation intervals likewise do not automatically include reconstruction uncertainty, model-selection uncertainty or error from unsupported extrapolation. Keep measured validation error, conditional simulation uncertainty and disagreement between plausible models distinct.

**Open questions for Chris or Andria, with recommendations:**

| Question | Recommendation |
|---|---|
| Is the proposed combination of directional tail holdouts, spatial buffers and reserved blocks acceptable? | Approve it explicitly as the project’s adaptation of published methods before implementation. Freeze the small protocol table before scoring. |
| Which historical predictions should determine the weights? | Use equal configured historical slices and months with cell-area weights; report vegetation-contributing cells separately. Do not privilege the hemlock interval. |
| One model structure or separate monthly winners? | One structure across months initially, with separate monthly fits and full monthly reporting. |
| May a model without cover win? | Yes. Interpret it as failure to establish transferable cover information, not evidence of physically zero forcing. |
| Should projected spatial coordinates enter this comparison? | Keep exact current models for the initial comparison. If desired, add one clearly specified projected counterpart before any scoring; do not silently change model 8. |
| What if winter folds or historical directions cannot be tested adequately? | Report that limit and stop short of an all-month or whole-hindcast skill claim. Revise the protocol before seeing scores if a different feasible design is needed. |
| What happens if the reserved assessment does not confirm improvement? | Report the failed confirmation. Do not reselect using the assessment or the northeast sign; retain model 8 as the established comparator and treat replacement as unconfirmed. |
| How much workstation time is available? | Start with one feasibility-approved batch, estimate remaining core-hours, and schedule within the existing maximum of four fitting jobs. |