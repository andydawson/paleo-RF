Draft for `docs/cc/2026-11-06_cv_protocol_v2.md`. No files were changed.

# Cross-validation protocol for choosing the albedo model, version 2

**Status:** proposed for Chris’s approval, 6 November 2026. Freeze this protocol and its input records before any version-2 fit.

**Benefit to the paper:** choose the albedo configuration on relevant modern prediction errors, then test whether its northeast vegetation response survives changes in location capacity and recovery of known effects.

This succeeds `2026-11-02_cv_protocol.md`. The first protocol and its results remain the previous experiment. Its results informed this redesign; version 2 is therefore a development-data experiment, not an assessment on untouched observations.

Chris’s decisions of 6 November are incorporated: score only withheld cells within 250 km of training; use one tuning level; perform both separation tests; fit by REML and report conditional AIC without filtering candidates. The 5 November decisions on distance reporting, area weighting, the separate comparison tool and trimmed figures also stand.

The additional location size and recovery rules below are proposals. Their approval freezes them alongside the rest of the protocol.

## 1. Inputs

- Use the main refit’s calibration table: MODIS cells, all days, `full_75`, with the same preprocessing and monthly missingness.
- Use all twelve months and the configured historical cover slices, excluding the modern 50 BP slice from the scoring target.
- Retain the existing area, ice-fraction and forcing inputs.
- Record the implementation version, configuration, input checksums, package versions and seeds.
- Reuse run 1’s full-data **REML prediction fits** and completed model-8 pipeline after checking their inputs, formulas and settings. Do not substitute its ML ladder fits.
- Make a separate version-2 run record. Recreate the directional memberships and predictions under this protocol; preserve the first experiment unchanged.

The reconstructed cover follows Dawson et al. (2025), §2.3. That establishes the input’s reconstruction method, not the validity of its albedo calibration. The precise input selection is the project’s existing decision; see the precedent table.

## 2. What the folds must imitate: the target

The target remains historical cell-slices whose cover mixture lies outside that month’s **full modern training hull**.

Use the existing forcing latitude window, strictly between 27° and 74° N. Give each historical slice and month equal weight **before restricting to outside-hull mixtures**. Within each slice, weight by cell area multiplied by ice-free fraction. Report exclusions for missing area, ice or cover.

Keep the existing grouping by:

- month;
- direction of departure from the full modern hull;
- cover-distance band.

Freeze these target weights before fitting. Do not redefine them against each fold’s smaller hull.

**The new geographic restriction applies to validation observations, not historical target weights:** only withheld observations within 250 km of their fold’s training cells contribute to selection. Missing target groups remain unrepresented; they do not receive zero error.

Withholding environmental extremes has transfer-function precedent in Telford and Birks (2009), §7. The directional cover triangle, historical weights and 250 km limit are **our judgements**. Nearby modern validation still does not reproduce changed cover at exactly the same place.

## 3. Holdouts: made once before any fit

1. **Cover geometry.** Reuse `cover_triangle_xy()`, `training_hull()` and `training_support()`. A swap of 0.10 between two cover classes travels 0.10 on this triangle. Distance to the hull is not necessarily a change in one particular class.

2. **Directions.** Reuse the existing grouping into at most three broad directions of historical departure. Save their angles, weights and the direction plot.

3. **Directional tails.** Withhold cells beyond the 80th percentile along each direction, everywhere and in every month. If that direction is infeasible in **every month**, try the 70th percentile, then the 90th. Keep the first cut with a feasible month. Individual infeasible months remain untested.

4. **Geographic distance.** For each withheld cell-month, calculate the great-circle distance to the nearest **actual complete training row for that month and fold**. Use unrounded distances. “Within 250 km” means **distance ≤250 km**; far means **>250 km**.

5. **No buffers or nested folds.** There is one level of tuning. Keep geographic blocks of 5 × 5 one-degree cells for uncertainty calculations.

6. **Overlapping holdouts.** A cell may be predicted under more than one directional holdout. Keep each prediction, its holdout and its own departure direction. Keep all appearances of a geographic block together when resampling.

7. **In-range diagnostic.** Retain the existing seeded holdout of one fifth of geographic blocks, with no cover cut. This is one holdout, not five-fold CV. Fit only the selected configuration and model 8; score only withheld cells inside their remaining monthly training hull.

Hu et al. (2018), §3.4, provides direct forest-albedo precedent for transfer tests. Telford and Birks distinguish environmental-extreme tests from spatial-independence tests. Neither prescribes these cuts, blocks or distances.

## 4. Feasibility: declared before any fit

For each directional holdout and month, require:

- enough complete training rows for the largest configuration, using the existing coefficient-count check;
- at least ten geographic blocks containing **nearby withheld observations in positive-weight target groups**.

The ten-block rule applies across that holdout-month’s scoring observations. It does not imply ten blocks in every distance band.

Freeze the same feasibility mask and scoring rows for every configuration. Far cells cannot rescue a fold that fails the nearby requirement.

For the in-range diagnostic, retain the existing training-row requirement and ten-block requirement on withheld cells inside the remaining hull.

Before fitting, present:

- training, withheld, nearby-scored and far-cell counts;
- block counts and feasible months;
- the selected cuts and membership comparison with the first experiment;
- represented and missing target weight;
- cover and geographic distance distributions, including maxima;
- northeast coverage explicitly.

If no useful tuning comparison is feasible, report that result. Do not relax the rule after seeing predictions.

These numerical feasibility limits are retained project judgements. Recalculate coverage: the first experiment’s represented weight does not establish version 2’s coverage.

## 5. Configurations and fitting

### The proposed 15 configurations

Cross five location capacities with three cover forms:

| Location term | Linear cover | Thin-plate cover, `k = 50` | Thin-plate cover, `k = 200` |
|---|---|---|---|
| Absent | `loc0_linear` | `loc0_tp50` | `loc0_tp200` |
| GP, `k = 12` | `loc12_linear` | `loc12_tp50` | `loc12_tp200` |
| GP, `k = 30` | `loc30_linear` | `loc30_tp50` | `loc30_tp200` |
| GP, `k = 100` | `loc100_linear` | `loc100_tp50` | `loc100_tp200` |
| GP, `k = 500` | `loc500_linear` | `loc500_tp50` | `loc500_tp200` |

Every configuration includes an intercept and `s(elev, k = 50)`.

- Linear cover: `ET + ST`, with open land as the reference fraction.
- Nonlinear cover: `s(OL, ET, ST, bs = "tp", k = 50)` or the identical basis family with `k = 200`.
- Location, when present: `s(x, y, bs = "gp", k = ...)`.
- Response: beta distribution with logit link.
- Smoothing parameters: estimated by REML within each fit.

`loc500_tp200` is model 8. Reuse the existing definitions for equivalent configurations; do not fit aliases twice. Write the new registry names and entries explicitly. Keep older definitions for their existing uses, but remove them from this CV candidate list.

The previous `mod8_small_cover` is excluded because it changes the cover representation as well as its size. Models without a cover term, and the remaining heterogeneous ladder entries, are also excluded from this search.

The `k = 12` row is proposed to examine the gap between no location term and `k = 30`. Basis size limits available complexity; it is not the fitted effective degrees of freedom.

### Fitting and failures

Reuse the ordinary fitting function, convergence checks and controls:

- initial iteration limit 500;
- one retry at 2,000 iterations for nonconvergence;
- record errors, warnings, retries and final status.

A configuration cannot be selected if any required tuning fit fails, remains unconverged or lacks a finite required scoring prediction. Do not drop its difficult rows and give it a partial selection score.

If model 8 fails, report the comparison as incomplete. If no configuration is eligible, make no choice.

Save smoothing parameters, effective degrees of freedom by term and existing basis-adequacy diagnostics. These describe the fits; they do not reopen the grid.

Bright et al. (2015), supplement §S4, and Hu et al. (2018), §3, support comparing plausible albedo formulations. **The grid, its sizes and the fixed elevation term are our judgements.**

## 6. Score and choice

### Selection score

Use squared error of the deterministic fitted mean on the albedo response scale.

For each eligible configuration:

1. Keep only feasible withheld observations at distance ≤250 km with positive target weight.
2. Assign each observation using its **own departure from its fold’s training hull**, not simply the holdout’s name.
3. Average squared errors within each month × direction × cover-distance group.
4. Combine those group means using the frozen historical weights, renormalized over represented groups.
5. Report the square root as RMSE, alongside represented and missing target weight.

Within a group, observations contribute equally, as in the existing scorer. Historical area and ice weighting enters through the target weights.

Use the existing outside-distance bands, with lower endpoints included:

- 0 to <0.02;
- 0.02 to <0.05;
- 0.05 to <0.10;
- ≥0.10.

Inside-hull observations have distance zero and are identified separately.

### Selection rule

Resample geographic blocks 1,000 times, keeping all months and holdout appearances together. Use the same draws for every configuration.

Find the eligible configuration with the smallest MSE. Among configurations whose excess MSE is no greater than **one standard error of its paired difference from that best configuration**, choose:

1. the one with the fewest coefficients;
2. then the earliest in the table above, read row by row, left to right.

Use coefficient counts, not fitted effective degrees of freedom. Freeze the counts before fitting; if setup counts differ among required datasets, use each configuration’s maximum.

Retain the existing treatment of bootstrap draws missing a group and report how many such draws occurred. If the uncertainty required by the rule is not finite, make no automatic choice.

Choose one configuration across testable months. Apply it to untested months, explicitly labelled as untuned there.

**This is a selection score: Fable’s “about one score standard error” is a rough judgement about its optimism, not a measured bias or upper bound; report the score’s bootstrap standard error in albedo units without presenting it as a bias correction.**

Yates et al. (2023), equations 7–8, discusses uncertainty-aware selection in neighbouring ecological applications. Our paired-difference rule is a project adaptation, not their exact modified one-standard-error rule.

### Reports that do not choose the configuration

Report beside selection:

- monthly RMSE and mean signed error;
- errors against evergreen share where open land is at most 0.20;
- regional errors, including the northeast;
- distance summaries below;
- the in-range diagnostic for the selected configuration and model 8;
- conditional AIC and fit diagnostics;
- both separation tests;
- the hindcast comparison.

Neither a preferred northeast sign nor any diagnostic triggers another choice. A failure can restrict interpretation without changing the predictive selection.

### Distance reporting

Pool months in the main distance report, retaining holdout and departure-direction information. Show the northeast separately and keep monthly results available in the existing monthly and regional tables.

Cross cover-distance bands with geographic bands:

- 0 to <100 km;
- 100 to 250 km, inclusive;
- >250 to <500 km;
- ≥500 km.

For each reported comparison include RMSE, mean signed error, paired MSE difference from model 8 and its block-resampled standard error, prediction count, unique cells and blocks.

Label these as **pooled diagnostic errors**. They are not the historically weighted selection score. Report their scoring-weight shares separately; far cells have zero version-2 selection weight.

Save actual cover-distance minima, central quantiles and maxima, including the **maximum tested distance per holdout**, separately for nearby scoring observations and all diagnostic observations. Retain monthly and directional maxima so that a pooled maximum cannot imply support in an untested month or direction.

Use common predicted rows for each diagnostic pair and disclose failures. Do not turn partial diagnostic comparisons into selection scores.

A historical distance in the ≥0.10 band can exceed every tested distance in that band. Report that explicitly; do not extend an error curve beyond observed distances.

Telford and Birks (2011), Results and Fig. 6, supports examining error along environmental gradients rather than relying on a pooled error. Our hull distance, bands and pooling are judgements.

### Conditional AIC

Report `AIC()` for **every configuration in every required tuning fit**, and for every full-data April–May fit used below.

Compare AIC only among configurations fitted to the same response rows in the same month and holdout. Report within-comparison differences; do not pool raw AIC across months or folds.

Use conditional AIC from the REML-fitted GAMs. Record whether mgcv’s smoothing-parameter uncertainty correction is available. This is not comparison of restricted-likelihood scores and is not AICc.

No AIC filter, veto or tie-break is used. No extra all-month full-data grid is fitted solely for AIC.

Pirzamanbein et al. (2020), **§2.2 and Table 2**, reports DIC beside CV for reconstructed vegetation. That supports distinct reporting roles, not interchangeability of DIC and AIC. Wood et al. (2016), §5, and the [official mgcv documentation](https://stat.ethz.ch/R-manual/R-devel/library/mgcv/html/logLik.gam.html) support the GAM calculation.

### Separation test 1: the real-data capacity comparison

For April and May, fit all fifteen configurations to identical full monthly data. Reuse the corresponding model-8 fits.

At northeast cells, defined by −80 ≤ longitude < −66 and 40 ≤ latitude < 48, calculate the **historical-size evergreen–summergreen exchange**:

- first endpoint: the cell’s 6 ka cover;
- second endpoint: its 4.5 ka evergreen fraction, while holding open land at its 6 ka value and setting summergreen to the remainder;
- hold location and elevation fixed;
- calculate second-endpoint albedo minus first-endpoint albedo.

This isolates the evergreen–summergreen exchange. It differs from the actual historical change when open land also changes.

Freeze the common valid cell set before fitting. Require valid cover fractions at both endpoints; report exclusions and retained area. Use normalized cell-area weights. Report monthly hull status and endpoint distances.

For every configuration, report:

- area-weighted contrast and its standard error;
- location effective degrees of freedom;
- pairwise location–cover concurvity;
- a plot of contrast against location capacity, with separate lines for cover form.

For linear cover, label concurvity as involving the **parametric block, including the intercept and ET/ST**. With no location term, report “not applicable,” not zero.

Calculate contrast uncertainty from `lpmatrix` and the full coefficient covariance `Vp`. On the response scale, use the area-weighted gradient of the difference:

\[
G=\sum_i w_i\{\mu_{i1}(1-\mu_{i1})X_{i1}
             -\mu_{i0}(1-\mu_{i0})X_{i0}\},
\qquad
SE=\sqrt{G V_p G^\mathsf{T}}.
\]

This retains covariance between endpoints and cells. Label intervals as approximate and conditional on the fitted smoothing parameters. Do not treat different configurations’ errors as independent.

**Reading fixed before fitting:** flag point-estimate sign reversals across location capacities; an approximate 95% interval crossing zero leaves that configuration’s sign unresolved. Report magnitude changes even without reversal. Agreement shows stability within this tested grid, not proof that cover and location have been correctly separated. No numerical concurvity cutoff or selection gate is introduced.

Duveiller et al. (2018), Methods, equations 11–13, provides direct precedent for vegetation-replacement contrasts with covariance-aware uncertainty. The GAM calculation and capacity comparison are our adaptations; implementation follows [mgcv’s prediction documentation](https://stat.ethz.ch/R-manual/R-devel/library/mgcv/html/predict.gam.html).

### Separation test 2: synthetic recovery

Test three distinct configurations:

1. the selected configuration;
2. model 8;
3. the selected configuration with location removed, keeping its cover and elevation terms.

Deduplicate equivalent configurations. Use April and May, three truths and twenty replicates per truth.

Keep real coordinates, elevation, cover and monthly missingness. Replace only albedo:

\[
\eta_i=a+0.5A\,z(OL_i)+0.25A\,z(elev_i)+bA\,z(ET_i)+g(x_i,y_i),
\]

\[
\mu_i=\operatorname{logit}^{-1}(\eta_i),\qquad
Y_i\sim\operatorname{Beta}(\mu_i\phi,(1-\mu_i)\phi).
\]

For each month, freeze:

- \(a\): logit of median observed albedo;
- \(A\): standard deviation of run 1 model 8’s fitted linear predictor;
- \(\phi\): its estimated beta precision;
- every centering and scaling constant in \(z\), calculated on that month’s complete calibration rows.

Apply those same constants to all prediction endpoints; never recalculate them on historical or swapped mixtures.

| Truth | \(b\) | Location surface |
|---|---:|---|
| Evergreen darkens | −0.5 | \(A\,z(y)\) |
| No evergreen–summergreen effect | 0 | \(A\,z(y)\) |
| Evergreen darkens with shorter spatial variation | −0.5 | \(A\,z\{z(y)+\sin(2\pi y/4)\cos(2\pi x/8)\}\) |

Here \(x,y\) are longitude and latitude in degrees. Drop the +0.5 truth.

Generate each dataset once with a recorded seed and use it for every tested configuration. Use the ordinary fitter and retry rule.

**True-model note:** the synthetic cover effect is linear on the logit scale, so linear cover is correctly specified and the nonlinear cover basis contains that linear response. Configurations without location still omit the known spatial effect; finite location bases need not reproduce the shorter-scale surface exactly.

Evaluate two exchanges:

- **Fixed exchange:** compare `(ET − 0.05, ST + 0.05, OL)` with `(ET + 0.05, ST − 0.05, OL)` at modern northeast fitting cells with ET and ST at least 0.05. The second minus first prediction measures ten percentage points more evergreen replacing summergreen.
- **Historical-size exchange:** use exactly the endpoints and sign convention of the real-data test.

For each exchange, freeze its valid cell set and area weights across configurations and replicates. Calculate the exact contrast from the generating truth. Report inside-hull and outside-hull subsets beside the complete valid set.

**Proposed pass rules, fixed before fitting**

Apply the following separately to each configuration, month and exchange:

- For **each nonzero truth**, recover the true regional sign in at least **18 of 20** replicates, and require absolute bias of the mean recovered contrast to be no greater than **half the absolute true contrast**.
- For the **null truth**, require the **mean absolute recovered contrast** to be no greater than **one quarter of the absolute contrast under the simple-latitude \(b=-0.5\) truth**, using the same month, exchange and cells.
- Require all twenty fits to converge and produce finite contrasts before awarding a pass. Otherwise report incomplete. Do not replace failed replicates or silently omit them.
- An empty cell set or zero reference contrast makes that assessment untestable, not passed.

A configuration passes the northeast recovery requirement only if it passes both exchanges, both months and all three truths. A failed, incomplete or untestable configuration **cannot carry the northeast vegetation-sign claim**. Its predictive selection remains unchanged.

Report all replicate contrasts, bias, RMSE, sign counts, null invented contrasts and Monte Carlo uncertainty. Also report error in the fitted location surface after centering it and the known surface with the same northeast area weights. Location recovery is diagnostic; these thresholds certify only the stated contrast checks.

Twenty replicates give a worst-case Monte Carlo standard error of about 0.11 for a sign-recovery proportion. Passing is a limited capability check, not certification of a precise success rate.

Telford and Birks (2009), §4, supplies transfer-function precedent for simulations exposing misleading spatial skill. Morris et al. (2019), §§3 and 5, supplies general simulation guidance. **The generator, amplitudes, wavelengths, replication count and thresholds are our judgements.**

## 7. Afterwards: the effect on the hindcast

Reuse run 1’s model-8 pipeline. For the selected configuration, reuse its full-data April–May fits, fit the remaining months, and supply the standard prediction-fit products to the existing downstream pipeline. Do not refit the ladder or spatial experiments merely to obtain these prediction fits.

Use separate run folders and matched scientific settings. Reuse the existing simulation seed arrangement; record it.

Add `tools/compare_cv_hindcasts.R` beside the existing northeast location-term figure tool. It takes two run-directory arguments, reads the fixed product paths, and records inputs and checksums.

### Comparison tables

Produce:

1. **Albedo:** both configurations and their difference, by month and slice, for the study domain and northeast.
2. **Forcing:** both configurations and their difference for existing periods, plus northeast 6–4.5 ka; retain kernel and component results.
3. **Northeast signs:** actual deterministic 6–4.5 ka albedo change, the modern-open-land evergreen–summergreen contrast, outside-hull shares, and historical predicted albedo against the observed monthly northeast range.

Use common cells and denominators for each comparison. Regional means are area-weighted. Retain the pipeline’s existing ice treatment; do not apply ice-free fraction a second time to saved forcing.

For northeast 6–4.5 ka, sum the three steps ending at 5500, 5000 and 4500 BP. Check the sum against the endpoint change on identical cells.

State signs in table headers: **positive albedo change means brighter; positive forcing means warming**.

Keep deterministic contrast calculations distinct from pipeline albedo means obtained through simulations.

### Support reporting

Use one outside-hull flag, accompanied by numeric distance and band.

- For a slice, use that month’s full-data hull.
- For a period, flag outside if **any endpoint of any included step** is outside.
- Report the largest endpoint distance and its band.

Report area shares and signed contributions with denominators that add back to the displayed totals. Show the relevant validation errors and tested distance limits beside these summaries. Do not create further support classes.

### Trimmed figures

Keep:

- albedo time series;
- chosen-minus-model-8 albedo maps at 50 BP, 6 ka, 4.5 ka and the oldest actual slice;
- headline-total forcing difference maps for the existing periods;
- the April–May northeast cover-response figure.

Drop the forcing time-series panel and separate vegetation-component forcing difference maps.

For the April–May curves, retain each cell’s modern open land, location and elevation. Derive the modern evergreen and observed albedo ranges from that month’s northeast fitting rows. Show actual historical-mixture points separately and identify extrapolated curve endpoints.

Duveiller et al. supports counterfactual vegetation comparisons, and Dawson et al. supplies the reconstruction context. The periods, weights, support summaries and figure selection are project reporting decisions.

## 8. Code, reviews and verification

### Smallest code changes

| Location | Adds or changes | Removes from this experiment |
|---|---|---|
| `R/model_registry.R` | Explicit two-axis configuration names, missing formulas and fixed CV order; reuse equivalent existing entries. | Heterogeneous ladder and baseline entries from `CV_MODELS`. |
| `R/cross_validation.R` | Shared ≤250 km scoring mask, associated feasibility and weight reporting, observed distance limits. | Far observations from selection; extra location-pair models from the in-range workload. |
| `tools/cross_validate_albedo.R` | Apply the same mask at holdout and score stages; retain AIC and fit summaries; save reusable full-data fits. | Any proposed nested orchestration. |
| Shared fitting helper in `R/` | Move the existing fit-and-retry operation so CV and separation tests use one implementation. | Duplicate fitting and retry logic. |
| One separation-test tool | Full-data capacity comparison, seeded synthetic datasets and recovery summaries. | The +0.5 truth and duplicate configuration fits. |
| Shared contrast helper in `R/` | Valid exchanges, exact predictions, area-weighted contrasts and covariance-aware uncertainty. | Repeated exchange calculations across tools. |
| `tools/compare_cv_hindcasts.R` | Two-run comparison, tables and trimmed figures. | No existing northeast tool is deleted or renamed. |
| Configuration validation, paths and records | Admit the new model names and pass saved fits into existing downstream stages with provenance. | Unnecessary repeated full-data fits. |

Reuse the existing hull geometry, regions, scoring, bootstrap, choice rule, pipeline products and verification tool. Do not add a modelling framework, scheduler or alternative support index.

### Reviews

Give Fable and Astra the same protocol and implementation independently, beginning with the paper benefit and Chris’s simplicity rule. Reconcile once. Use the change-reviewer for paths, records and execution plumbing.

Findings must identify file and line, consequence, evidence and a proposed check. Before presenting findings to Chris, discard suggestions that add complexity without fixing a real defect; report how many were discarded and why.

### Verification

Use `tools/verify_change.R` with a committed specification, in its own worktree at the exact implementation version. Do not edit or switch a checkout while a run is reading it.

Targeted checks must establish:

- unchanged formulas and predictions for existing equivalent configurations;
- identical training and scoring rows across configurations;
- correct monthly training distances and inclusion of exactly 250 km;
- far predictions cannot affect selection;
- correct target weights, missing-group reporting and direction assignment;
- expected choices on hand-worked score examples;
- correct failure, retry and incomplete-result handling;
- identical seeded synthetic data across configurations;
- frozen standardization at every synthetic endpoint;
- valid, zero and reversed exchanges;
- correct response-scale contrast uncertainty;
- exact null contrasts from the generator and correct pass-rule boundary cases;
- saved distance maxima and correct report denominators;
- common-cell period sums and endpoint agreement;
- proper reuse of saved fits and unchanged pipeline outputs where expected.

Reference identities and supporting passages have been checked against primary sources for this draft. The project’s combined reference-checker workflow was not run in this read-only session; complete it before implementation and retain the claim-to-passage record.

During implementation, follow `CONTRIBUTING.md`: issue first, topic branch, atomic commits, verification evidence and normal merge procedure. Record precedents in the changelog and resulting paper methods.

Update the living scientific questions with the remaining question for Andria: **is a common cover response across regions acceptable for interpreting the northeast?** Record this protocol’s separation tests as its source. Review the general questions file and revise any affected logistical questions.

## 9. Fit count and execution

Assuming three feasible directions, twelve months and fifteen configurations:

| Work | New fits before retries |
|---|---:|
| Directional tuning: 3 × 12 × 15 | 540 |
| Full-data April–May comparison: 2 × 15, less two reused model-8 fits | 28 |
| Recovery: at most 3 configurations × 2 months × 3 truths × 20 replicates | 360 |
| In-range diagnostic: selected configuration and model 8 × 12 months | 24 |
| Selected configuration’s remaining full-data months | 10 |
| **Maximum new fits** | **962** |

This count requires reuse of the winner’s April–May fits and run 1’s model-8 full-data fits and pipeline. Equivalent configurations and infeasible combinations reduce it. Retries are recorded separately.

AIC is extracted from these fits and adds none. An all-month full-data AIC grid is not included.

Use the existing shared-machine queue, with at most six concurrent single-thread fits. No scheduler changes are required.

## What the result can and cannot show

The result can identify a configuration with better measured performance on the represented modern cover departures within 250 km of training. It can show where errors worsen with distance, how the northeast contrast changes with location capacity, and whether selected configurations recover stipulated effects.

It cannot establish:

- unbiased performance of the selection procedure;
- historical albedo accuracy;
- accuracy beyond the tested distance span;
- successful separation of real vegetation, snow, climate and location effects;
- a causal hemlock effect;
- recovery under untested truths, including the dropped positive-effect truth.

The synthetic experiment uses independent beta draws conditional on its specified mean surface. It does not test unknown residual spatial dependence or uncertainty in reconstructed cover.

A stable real-data contrast and successful recovery strengthen a conditional interpretation. Neither establishes the historical sign. A sign change between hindcasts alone does not demonstrate an extrapolation artefact.

## Precedent table and passage record

Passage descriptions are paraphrases. Numerical settings without direct precedent are identified as project judgements.

| Step | Precedent, DOI and passage read | What it supports—and its limit |
|---|---|---|
| Reconstructed cover inputs | Dawson et al. (2025), §2.3: [10.5194/cp-21-2031-2025](https://doi.org/10.5194/cp-21-2031-2025). | REVEALS-GMRF interpolation with elevation. Does not validate the albedo transfer model. |
| Compare albedo configurations | Bright et al. (2015), supplement §S4, PDF p. 12: [10.5194/bg-12-2195-2015](https://doi.org/10.5194/bg-12-2195-2015); Hu et al. (2018), §3: [10.1029/2018MS001403](https://doi.org/10.1029/2018MS001403). | Direct albedo precedent for candidate-form comparison using performance and complexity. Our GAM grid and sizes are judgements. |
| Withhold environmental extremes | Telford and Birks (2009), §7, p. 1315: [10.1016/j.quascirev.2008.12.020](https://doi.org/10.1016/j.quascirev.2008.12.020). | Transfer-function precedent for extrapolation tests; explicitly distinct from spatial independence. Their account of the earlier extreme-holdout experiment was read, not its original methods. Our directions, cuts and weights are adaptations. |
| Restrict selection geographically; report transfer separately | Hu et al. (2018), §3.4: [10.1029/2018MS001403](https://doi.org/10.1029/2018MS001403). | Direct forest-albedo reciprocal-area transfer tests. No direct precedent found for 250 km; that cutoff is our judgement. |
| Simpler configuration within paired uncertainty | Yates et al. (2023), equations 7–8: [10.1002/ecm.1557](https://doi.org/10.1002/ecm.1557). | Neighbouring ecological methodology, not albedo-specific. Our exact block-resampled rule is an adaptation and does not estimate selection optimism. |
| REML and conditional AIC | Wood et al. (2016), §5: [10.1080/01621459.2016.1180986](https://doi.org/10.1080/01621459.2016.1180986); Pirzamanbein et al. (2020), §2.2 and Table 2: [10.1029/2018EA000547](https://doi.org/10.1029/2018EA000547). | General GAM theory supports conditional AIC. Palaeo-vegetation practice supports an information criterion beside CV, but uses DIC. No AIC filter is implied. |
| Cover-exchange contrast and uncertainty | Duveiller et al. (2018), Methods, “Retrieving the local biophysical signal,” equations 11–13: [10.1038/s41467-017-02810-8](https://doi.org/10.1038/s41467-017-02810-8). | Direct vegetation-change precedent for prediction differences and their covariance. Historical-sized exchanges and the GAM capacity test are adaptations. |
| Synthetic recovery | Telford and Birks (2009), §4: [10.1016/j.quascirev.2008.12.020](https://doi.org/10.1016/j.quascirev.2008.12.020); Morris et al. (2019), §§3 and 5: [10.1002/sim.8086](https://doi.org/10.1002/sim.8086). | Transfer-function simulations expose misleading spatial skill; general statistical guidance supports explicit truths and performance measures. The exact albedo generator and pass rules have no direct precedent found and are judgements. |
| Distance-graded error | Telford and Birks (2011), Results and Fig. 6: [10.1007/s10933-011-9523-z](https://doi.org/10.1007/s10933-011-9523-z). | Transfer-function errors examined along environmental gradients. Our hull distance, bands, pooling and reporting limits are adaptations. |
| Hindcast comparison and interpretation | Duveiller et al. (2018), Methods; Dawson et al. (2025), §4.2.3, DOIs above. | Vegetation-replacement predictions and the northeast reconstruction context. Our periods, area summaries, support flags and figures are reporting judgements. |

## References

- **Bright, R. M., Myhre, G., Astrup, R., Antón-Fernández, C., & Strømman, A. H. (2015).** Radiative forcing bias of simulated surface albedo modifications linked to forest cover changes at northern latitudes. *Biogeosciences*, 12, 2195–2205. DOI: [10.5194/bg-12-2195-2015](https://doi.org/10.5194/bg-12-2195-2015).
- **Dawson, A., et al. (2025).** Holocene land cover change in North America: continental trends, regional drivers, and implications for vegetation–atmosphere feedbacks. *Climate of the Past*, 21, 2031–2060. DOI: [10.5194/cp-21-2031-2025](https://doi.org/10.5194/cp-21-2031-2025).
- **Duveiller, G., Hooker, J., & Cescatti, A. (2018).** The mark of vegetation change on Earth’s surface energy balance. *Nature Communications*, 9, 679. DOI: [10.1038/s41467-017-02810-8](https://doi.org/10.1038/s41467-017-02810-8).
- **Hu, X., Cherubini, F., Vezhapparambu, S., & Strømman, A. H. (2018).** From Remotely-Sensed Data of Norwegian Boreal Forests to Fast and Flexible Models for Estimating Surface Albedo. *Journal of Advances in Modeling Earth Systems*, 10, 2495–2513. DOI: [10.1029/2018MS001403](https://doi.org/10.1029/2018MS001403).
- **Morris, T. P., White, I. R., & Crowther, M. J. (2019).** Using simulation studies to evaluate statistical methods. *Statistics in Medicine*, 38, 2074–2102. DOI: [10.1002/sim.8086](https://doi.org/10.1002/sim.8086).
- **Pirzamanbein, B., Poska, A., & Lindström, J. (2020).** Bayesian Reconstruction of Past Land Cover From Pollen Data: Model Robustness and Sensitivity to Auxiliary Variables. *Earth and Space Science*, 7. DOI: [10.1029/2018EA000547](https://doi.org/10.1029/2018EA000547).
- **Telford, R. J., & Birks, H. J. B. (2009).** Evaluation of transfer functions in spatially structured environments. *Quaternary Science Reviews*, 28, 1309–1316. DOI: [10.1016/j.quascirev.2008.12.020](https://doi.org/10.1016/j.quascirev.2008.12.020).
- **Telford, R. J., & Birks, H. J. B. (2011).** Effect of uneven sampling along an environmental gradient on transfer-function performance. *Journal of Paleolimnology*, 46, 99–106. DOI: [10.1007/s10933-011-9523-z](https://doi.org/10.1007/s10933-011-9523-z).
- **Wood, S. N., Pya, N., & Säfken, B. (2016).** Smoothing parameter and model selection for general smooth models. *Journal of the American Statistical Association*, 111, 1548–1575. DOI: [10.1080/01621459.2016.1180986](https://doi.org/10.1080/01621459.2016.1180986).
- **Yates, L. A., Aandahl, Z., Richards, S. A., & Brook, B. W. (2023).** Cross validation for model selection: A review with examples from ecology. *Ecological Monographs*, 93, e1557. DOI: [10.1002/ecm.1557](https://doi.org/10.1002/ecm.1557).

---

# Points needing Chris’s approval

1. **Fifteen configurations:** add location `k = 12`; retain the full five-by-three grid, explicit two-axis names and stated tie-break order.

2. **Recovery specification:** approve the three generators and twenty replicates, with thresholds applied to **both exchanges and both months**: 18/20 correct signs, bias at most half the true contrast, and mean absolute null contrast at most one quarter of the reference contrast.

3. **Incomplete recovery:** require all twenty converged fits to award a pass; missing fits or untestable contrasts cannot support the northeast sign claim.

4. **Real-data interpretation:** use the capacity profile descriptively, flag sign reversals and intervals crossing zero, and introduce no arbitrary concurvity threshold.

5. **Reporting scope:** pool months in distance summaries while retaining relevant maxima; restrict the in-range fits to the winner and model 8; obtain AIC from existing tuning fits and full-data April–May fits.

6. **Reuse:** retain the true-model qualification, reuse run 1’s model-8 fits and pipeline, and reuse the winner’s April–May fits. This gives at most **962 new fits before retries**.

7. **Optimism wording:** accept “about one standard error” only as Fable’s explicitly unverified judgement. The proposed single-level experiment does not measure the actual selection bias.