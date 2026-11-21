# Astra's reconciliation with Fable's review of the cross-validation design, 2 November 2026

The revision should help the paper distinguish evidence about unfamiliar cover mixtures from evidence about predicting at unfamiliar locations.

**I accept Fable’s central objection and withdraw buffered geographic holdouts as the primary selection design. I do not accept that paired within-block differences automatically remove the spatial penalty.** I recommend unbuffered cover-tail holdouts for selection, with local contrasts as a supporting diagnostic where suitable pairs exist.

I read all three documents and checked the relevant code and literature. No files were changed and no R commands were run. Reference identities and accessible passages were checked online; the repository’s reference-checker programs were not run.

**F1 — PARTLY.** The central criticism is correct. Modern and historical cover come from the same underlying location table, and elevation is attached by location before the modern slice is extracted: [scripts/1_veg_lct_prep.R:53][prep]. Removing surrounding training cells therefore introduces a geographic prediction problem that much of the hindcast does not face. Merely calling that test “conservative” does not justify using it to choose whether the location term belongs.

Two qualifications matter:

- Geographic distance is zero for historical locations **present in that month’s fitted calibration data**, not necessarily every historical location. Monthly missing albedo and masking remove training rows (`R/model_registry.R:58–60`). The actual monthly distance distributions must be checked.
- Removing the buffer reduces the mismatch but cannot eliminate it. A geographically clustered cover-tail exclusion still removes modern observations from those locations. Block resampling estimates uncertainty; it does not repair this mismatch or remove confounding.

This interpretation follows Linnenbrink, Milà, Ludwig and Meyer (2024), *Geoscientific Model Development* 17:5897–5912, DOI **10.5194/gmd-17-5897-2024**: their kNNDM method matches validation geography to prediction geography, and explicitly distinguishes geographic transfer from map accuracy. [Paper, introduction and algorithm](https://gmd.copernicus.org/articles/17/5897/2024/index.html).

The proposed paired score is useful, but its cancellation claim is too strong. For inverse-logit \(h\), even an identical location/elevation offset \(s\) gives

\[
\widehat{\Delta\alpha}=h(s+f_A)-h(s+f_B),
\]

which generally changes when \(s\) changes. Nearby cells also have different offsets. Exact cancellation occurs for the additive terms on the **link scale at identical location and elevation**, or for an identical additive error on the response scale. Neither is guaranteed by membership in one block. The implemented family is beta with a logit link ([R/model_registry.R:87][fit]).

The suggested references support the analogy, with important limits:

- **Duveiller, G., Hooker, J. and Cescatti, A. (2018), “The mark of vegetation change on Earth’s surface energy balance,” *Nature Communications* 9:679, DOI 10.1038/s41467-017-02810-8.** They estimate local relationships between vegetation fractions and biophysical quantities, including albedo, in 5×5 windows of 0.05° pixels, then difference predicted cover endpoints. Their companion methods require local vegetation contrasts and screen unsuitable terrain. This supports comparisons under similar background conditions; it does not establish a paired held-out CV selection score. [Original paper](https://www.nature.com/articles/s41467-017-02810-8); [companion methods, pp. 4–7, DOI 10.1038/sdata.2018.14](https://www.nature.com/articles/sdata201814.pdf).
- **Alkama, R. and Cescatti, A. (2016), “Biophysical climate impacts of recent changes in global forest cover,” *Science* 351:600–604, DOI 10.1126/science.aac8083.** This concerns temperature responses to observed forest change. Its identity and abstract are verified; its original full methods were inaccessible. An accessible paper coauthored by Cescatti distinguishes Alkama’s before/after approach, controlling local climatic variation, from Duveiller’s neighbouring-area substitution. They are not the same method. [Publication record](https://pubmed.ncbi.nlm.nih.gov/26912702/); [Duveiller et al. 2018, *Earth System Science Data*, introduction](https://essd.copernicus.org/articles/10/1265/2018/index.html).

I therefore recommend paired contrasts as a **secondary, explicitly proposed adaptation**, with both members withheld, matching based only on predictors, and unmatched cases reported. Neither reference establishes that they remove the location problem.

**F2 — PARTLY.** A fixed simplicity order is clearer, and three blocks cannot support a dependable uncertainty-based choice. However, `k = 500` is an upper bound on flexibility, not 500 fitted effective degrees of freedom; changing to coefficient counts also favours smaller location structures. Neither ordering inevitably selects `cover_elev`. [mgcv’s basis-dimension documentation](https://cran.r-project.org/web/packages/mgcv/mgcv.pdf).

I would freeze coefficient-count order, followed by registry order, before scoring. Retain the paired one-standard-error convention only with adequate geographic replication. I propose ten occupied scoring blocks per represented direction as a minimum practical guard, **not a published sufficiency threshold**; below it, report scores without an automatic replacement decision. Cite the conventional rule to Hastie, Tibshirani and Friedman (2009), *The Elements of Statistical Learning*, §7.10, DOI **10.1007/978-0-387-84858-7**; our paired-error adaptation remains a project choice. [Book](https://link.springer.com/book/10.1007/978-0-387-84858-7).

**F3 — AGREE** with making models 1–2 baselines only. Their purpose is to test whether cover contributes transferable information, not to turn absent evidence into a zero-forcing reconstruction.

The exact invariant concerns **predicted mean vegetation albedo** at fixed location and elevation (`R/model_registry.R:19–22`). Current downstream summaries use finite simulation means, which can introduce numerical differences (`scripts/6_prediction_model.R:55–78`). Total forcing can also remain nonzero through ice retreat ([R/differences.R:72][differences]). Neither qualification rescues a cover-free model as evidence of zero vegetation effect.

**F4 — AGREE** with adding both alternatives. Add model 8 with a smaller location basis, provisionally `k = 30`, and a smaller two-dimensional cover surface, provisionally `k = 50`, retaining model 8’s other terms.

For the latter I prefer the existing triangle coordinates over raw `ET, ST`: both remove the redundant dimension, but the triangle preserves equal geometric treatment of the three cover exchanges ([R/training_support.R:25][triangle]). Neither numerical basis size is a published optimum, and a smaller basis is not a specified kilometre correlation range.

Paciorek (2010), *Statistical Science* 25:107–125, DOI **10.1214/10-STS326**, supports investigating spatial scale and allocation between covariate and spatial effects; it does not prescribe these settings or prove that less spatial flexibility reduces bias. [Sections 2.1 and 2.5](https://pmc.ncbi.nlm.nih.gov/articles/PMC3082155/).

**F5 — PARTLY.** Report in-range performance, but **do not combine it with tail error for selection**: Chris explicitly requires selection to be judged only on out-of-range predictive skill ([brief:58][brief]). Fable’s alternative—state that limitation and report in-range skill separately—is compatible.

The 11.1% figure is from the older run and May-based support, not a current all-month MODIS target share (`R/training_support.R:54–61`; changelog:1327). Recalculate the shares. Near-edge dominance under population weighting is a real consequence to disclose; that models necessarily differ least there has not been established.

**F6 — PARTLY.** Correct: accurate levels do not establish an accurate evergreen-to-summergreen response. Add signed validation error against evergreen share within a prespecified low-open-land band, and matched contrasts where feasible. Neither diagnostic validates a slope at historical mixtures absent from modern observations.

The cited changelog establishes outside-hull percentages, **not** the stronger statement that every relevant 6 ka mixture has less open land than every modern cell. That needs checking on current inputs ([changelog:1360][northeast]). Evidence about the hemlock explanation must concern the relevant substitution and support, not just aggregate RMSE.

**F7 — PARTLY.** Feasibility must be settled before fitting candidates; my original design already required that, but should state the timing more firmly. Use actual month-by-holdout memberships, complete predictors and available albedo—not monthly totals alone.

“December is untestable for every direction” is unsupported. Fable’s calculation assumes removal fractions, and its own 90th-percentile example exceeds the coefficient floor. The recorded December total is 1,416, but a common cover cut need not remove the same fraction of each month’s observed rows (changelog:1459; original design:69–71). Any structure applied to untested months must be described as imposed there.

**F8 — AGREE.** After one prespecified higher-iteration retry, a candidate with unresolved convergence failure on any required case is **ineligible**, with no aggregate selection score. Do not score unconverged predictions or omit difficult folds. If model 8 fails, report the requested comparison as incomplete. Use the fitting-loop and optimiser evidence, including warnings; reaching the last iteration alone is ambiguous (`R/model_registry.R:96–128`).

**F9 — PARTLY.** Drop reserved blocks and guard bands, score all eligible tail cells, and consolidate support reporting into one table. Call the result a selection score.

Keep the predictor-distance comparison: an arbitrary 80th-percentile cut does not establish resemblance to the hindcast. An 80th-percentile default is reasonable, with a short, predictor-only comparison of the original 70/80/90 alternatives where feasibility or coverage requires it, completed before scoring.

Row counts also do not replace predictor-support or rank checks: [scripts/4_calibration_model.R:36][rowcheck] only checks counts against coefficient numbers. Reuse existing setup diagnostics rather than create another framework. Recognise documented compositional rank loss separately from new deficiencies.

Dropping the reserve sacrifices independent confirmation; prespecifying candidates does not eliminate selection optimism. [Cawley and Talbot (2010), *JMLR* 11:2079–2107](https://jmlr.org/papers/v11/cawley10a.html).

**F10 — AGREE.** Make the existing seven spatial-experiment IDs explicit, add a separate CV list, extend eligible prediction IDs, and remove the diagnostic’s model-8-only assumption. Otherwise adding formulas silently expands routine fitting. Evidence: `R/model_registry.R:53`, `R/config_schema.R:155`, and `tools/plotting/plot_northeast_cover_and_location.R:63`.

**F11 — PARTLY.** The target needs an explicit ice treatment. But `veg_ice_parts` uses continuous fractions; it does **not** apply the 0.5 classification threshold. Its vegetation component uses the older endpoint’s ice-free fraction, while retreat contributes another term ([R/differences.R:72][differences]).

Ice-free-area weighting is a defensible definition of a vegetation-focused target, not automatically the correct weighting for total-forcing error. Equal month weights likewise define an albedo objective. Script 8 applies monthly kernels before script 9 averages forcing, so equal-month albedo error is not equivalent to annual-forcing error (`scripts/8_radiative.R:99`; `scripts/9_forcing_barplot.R:162`).

**F12 — AGREE.** Record derived seeds for resampling and any random assignments, together with software and thread settings (`R/random.R:14–29`). Keep geographic distances in appropriate distance units and distinguish them from the fitted smooth’s degree coordinates. Verify reproducible memberships and numerical predictions; byte-identical saved model objects are unnecessary.

**F13 — PARTLY.** Agree on a dated protocol frozen before fitting and explicit acknowledgement that the old raster-data sign reversal is already known.

Disagree that leaving the living question files untouched breached this assignment: the direct read-only instruction prohibits those writes ([brief:7][readonly]). The questions remain below for subsequent recording. Formal section headings were not a scientific requirement.

For **Fable’s eight questions**, my positions are:

| Question | Position | Recommendation and evidence |
|---|---|---|
| 1. Which prediction task and score? | **PARTLY** | Remove imposed buffers; retain tail absolute-albedo error for selection. Use paired contrasts as a supporting diagnostic, for the reasons and references under F1. |
| 2. Models 1–2 eligible? | **AGREE** | Baselines only; report failure to establish transferable cover skill if they perform as well. `R/model_registry.R:19–22`. |
| 3. Keep reserved blocks? | **AGREE** | Drop them for this first comparison; relinquish independent confirmation. Cawley and Talbot (2010). |
| 4. Add in-range validation and combine scores? | **PARTLY** | Add the diagnostic; **DISAGREE** with combining scores under Chris’s standing decision. Brief:58–61. |
| 5. Population or equal departure weights? | **AGREE** | Population shares within the represented out-of-range target for selection; equal-group results as a reporting sensitivity. Recompute monthly shares rather than reuse May’s. `R/training_support.R:54–61`. |
| 6. Add both model alternatives? | **AGREE** | Smaller location basis and two-dimensional cover surface, with the qualifications under F4. Paciorek (2010). |
| 7. Declare testable months before fitting? | **PARTLY** | Yes, from actual fold intersections; do not predeclare December impossible from totals. Original design:69–71; changelog:1459. |
| 8. Equal or sunlight-weighted months? | **PARTLY** | Recommend equal months for the albedo selection objective. Fable’s appeal to script 9 is insufficient because that script averages already kernel-weighted forcing. Scripts 8:99 and 9:162. |

**The revised design I recommend is the following**—approximately one page.

1. **Freeze the target and protocol before candidate fitting.** Use current MODIS calibration inputs, historical cover, equal historical-slice and month weights, and cell-area weights. I recommend weighting the vegetation-focused target by ice-free area, explicitly distinguishing this from total-forcing accuracy. Record the already-known raster sign result.

2. **Use directional cover-tail holdouts without geographic buffers.** Derive up to three broad departure directions from historical-versus-modern cover support. Withhold each chosen tail everywhere and score all eligible tail cells. Start at the 80th percentile; examine the prespecified alternatives only for feasibility or inadequate target coverage, before errors are seen. With one cut and all tail cells scored, repeated identical directions add no validation information.

3. **Check what each holdout tests.** Share cuts across months but use each month’s actual training rows. Compare cover distances, absolute ranges, substitution directions and geographic nearest-training distances with the historical target. Label unmatched conditions “untested”; a similar departure distance does not validate an unseen absolute composition. If cover exclusion creates large geographic gaps, the results cannot cleanly decide the location-term question. Predictor-space withholding follows Roberts et al. (2017), *Ecography* 40:913–929, DOI **10.1111/ecog.02881**; this particular recipe remains our adaptation. [Paper](https://doi.org/10.1111/ecog.02881).

4. **Evaluate thirteen models, eleven eligible to win.** Retain the original eleven comparisons, make models 1–2 baselines, and add the two alternatives under F4. Keep monthly beta-logit REML fits, identical scoring rows, and no imposed sign constraint. Freeze feasibility and convergence rules first.

5. **Select only on represented out-of-range error.** Use weighted mean squared error of predicted mean albedo; report RMSE. Apply the paired one-standard-error convention and fixed coefficient-count order only when geographic replication meets the frozen requirement. Resample geographic blocks with months and repeated observations kept together. These are approximate, conditional uncertainty estimates; they do not remove selection optimism or geographic mismatch. Select one structure, documenting months where its use is extrapolated from other months.

6. **Report supporting checks without reselection.** After locking the choice, compare it with model 8 on one no-cut diagnostic holdout. Report in-range performance separately. Where suitable, jointly withhold nearby contrasting cells for the paired diagnostic; never use a training observation as its supposedly held-out partner. Report low-open-land error patterns and unsupported historical slopes.

7. **Demonstrate consequences and keep implementation small.** Refit the selected model and model 8 on identical full inputs; compare albedo and forcing, including the northeast’s 6–4.5 ka interval. Relevant predictive improvement plus improved contrast behaviour and weakened warming would support an artefact explanation; a sign change alone would not. Persistent warming among successful models would weigh against it only within tested conditions. Reuse the registry, fitting and support helpers, three small CV functions and one driver. Three tail holdouts require at most **468 fits**, plus **24** chosen-model/model-8 diagnostic fits, before retries and final refits. Measure the first batch and retain the existing four-job ceiling.

The remaining decisions for **Chris or Andria** are:

- **Approve the selection objective and adaptation.** I recommend tail absolute-albedo error, no imposed buffers, and secondary local contrasts. **Fable recommends paired differences as the primary score.**
- **Define the historical target weights.** I recommend equal slices/months, ice-free cell-area weights and population shares conditional on out-of-range support. **Fable additionally recommends mixing in-range and out-of-range scores; that would require changing Chris’s existing decision, so it is excluded here.**
- **Approve model eligibility and the two additions.** I now agree with Fable: cover-free baselines only, plus smaller-location and two-dimensional-cover candidates. The particular basis sizes and minimum block requirement are project judgements.
- **Accept the limits of a first comparison.** I recommend dropping reserved assessment, accepting a selection-score claim, and imposing one structure on untested months only with explicit qualification. Fable broadly agrees. If geographic mismatch or weak replication prevents a defensible replacement decision, report that rather than force a winner.
- **Set the compute allocation.** Measure a first feasible batch before committing the remaining workstation time; both recommendations agree.

[prep]: scripts/1_veg_lct_prep.R:53
[fit]: R/model_registry.R:87
[differences]: R/differences.R:72
[triangle]: R/training_support.R:25
[brief]: docs/cc/2026-11-02_cv_design_brief.md:58
[northeast]: docs/cc/changelog_single_config_migration.md:1360
[rowcheck]: scripts/4_calibration_model.R:36
[readonly]: docs/cc/2026-11-02_cv_design_brief.md:7