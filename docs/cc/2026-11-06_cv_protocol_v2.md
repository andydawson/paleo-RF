# Cross-validation protocol for choosing the albedo model, version 2

**Status:** Chris’s decisions incorporated, 6 November 2026. Freeze this protocol and its input records before any version-2 fit.

**Benefit to the paper:** choose the albedo configuration on relevant modern prediction errors, then test whether its northeast vegetation response survives changes in location capacity and recovery of known effects.

This succeeds `2026-11-02_cv_protocol.md`. The first experiment stays on record. Its results informed this redesign, so version 2 uses development data, not untouched observations.

## Decisions: Chris, 5–6 November

- **Purpose, 6 November:** “Rather than just generalisation across CV folds, we also need to know if the new models we train can separate latitude from evergreen cover.” Also: “I had assumed that with the cross-validation we were doing an ML style hyperparameter tuning to try and produce a better model.”
- **Support, 5 November:** “being outside might not be a problem in itself, it is how far outside that is the problem ie too far and the model will struggle to extrapolate, just outside and it should be fine.” Keep one outside-hull flag with distance and band, area-weighted means, a separate comparison tool and the trimmed figures.
- **Choice, 6 November:** one tuning level; only withheld cells **< 250 km** from training choose the configuration. Far cells are reported beside it. Label the score a selection score and state its optimism. Fit by REML; report conditional AIC for all configurations from the April–May full-data fits only, with no AIC filter.
- **Separation, 6 November:** do both the real-data capacity comparison and synthetic recovery. Recovery is reported beside selection; failure prevents a northeast sign claim. Approve the draft’s seven points with Fable’s recommendations, including location `k = 12` and the fixed recovery rules below.
- **Pipeline and signs, 6 November:** run scripts **1–10 unchanged** for the winner, with no new plumbing. The northeast sign table shows the evergreen–summergreen swap at today’s **50 BP** and **6 ka** open land side by side.
- **Deep cover, 6 November:** after “Rethink the 250 km rule,” keep it; report deep-cover performance by departure direction beside the score. Accept and report the **1.5% nearby deep weight on two blocks**. Use synthetic recovery to test deep cover at the northeast’s own cells under a stipulated truth.

Sources: [redesign brief](2026-11-06_cv_redesign_brief.md), [protocol brief](2026-11-06_cv_protocol_v2_brief.md), [deep-band brief](2026-11-06_cv_deep_band_brief.md) and [final instructions](2026-11-06_cv_protocol_v2_final_brief.md). Quotations above are Chris’s recorded words; the remaining decisions are summaries.

## 1. Inputs

- Use the main refit’s calibration table: MODIS cells, all days, `full_75`, with the same preprocessing and monthly missingness.
- Use all twelve months and the configured historical cover slices, excluding modern 50 BP from the scoring target. Retain the existing area, ice-fraction and forcing inputs.
- Record the implementation version, configuration, input checksums, package versions and seeds.
- Reuse run 1’s full-data **REML prediction fits** for model 8 and its completed pipeline after checking inputs, formulas and settings. Do not substitute its ML ladder fits.
- Make a separate version-2 run record. Recreate directional memberships and predictions under this protocol; preserve the first experiment.

## 2. What the folds must imitate: the target

The target remains historical cell-slices outside that month’s **full modern training hull**: the outer boundary of the modern cover mixtures.

Use the existing forcing latitude window, strictly between 27° and 74° N. Give each historical slice and month equal weight **before restricting to outside-hull mixtures**. Within each slice, weight by cell area multiplied by ice-free fraction. Report exclusions for missing area, ice or cover.

Group by month, departure direction from the full modern hull, and cover-distance band. Freeze these target weights before fitting; do not redefine them against each fold’s smaller hull.

The **< 250 km** restriction applies to validation observations, not historical target weights. Missing target groups remain unrepresented; they receive neither zero error nor another direction’s error. Nearby validation still does not reproduce changed cover at exactly the same place.

## 3. Holdouts: made once before any fit

1. **Cover geometry.** Reuse `cover_triangle_xy()`, `training_hull()` and `training_support()`. A swap of 0.10 between two cover classes travels 0.10 on this triangle. Hull distance is not necessarily a change in one particular class.
2. **Directions.** Reuse the grouping into at most three broad directions of historical departure. Save their angles, weights and direction plot.
3. **Directional tails.** Withhold cells beyond the 80th percentile along each direction, everywhere and in every month. If that direction is infeasible in **every month**, try the 70th percentile, then the 90th. Keep the first cut with a feasible month; individual infeasible months remain untested.
4. **Geographic distance.** For each withheld cell-month, calculate unrounded great-circle distance to the nearest **actual complete training row for that month and fold**. Nearby means **< 250 km**; far means **≥ 250 km**.
5. **One tuning level.** No buffers or nested folds. Keep geographic blocks of 5 × 5 one-degree cells for uncertainty calculations.
6. **Overlapping holdouts.** Keep every prediction, its holdout and its own departure direction. Keep all appearances of a geographic block together when resampling.
7. **In-range diagnostic.** Retain the seeded holdout of one fifth of geographic blocks, with no cover cut. This is one holdout, not five-fold CV. Fit only the winner and model 8; score only withheld cells inside their remaining monthly training hull.

## 4. Feasibility: declared before any fit

For each directional holdout and month, require enough complete training rows for the largest configuration, using the existing coefficient-count check, and at least **ten geographic blocks** containing nearby withheld observations in positive-weight target groups. This does not require ten blocks in every distance band.

Freeze the same feasibility mask and scoring rows for every configuration. Far cells cannot rescue an infeasible fold. For the in-range diagnostic, retain the training-row and ten-block requirements on withheld cells inside the remaining hull.

Before fitting, report training, withheld, nearby-scored and far-cell counts; blocks and feasible months; cuts and membership changes from run 1; represented and missing target weight; cover and geographic distances; and northeast coverage. Recalculate these under version 2’s mask.

These numerical limits are project judgements. If no useful comparison is feasible, report that; do not relax the rule after seeing predictions.

## 5. Configurations and fitting

Cross five location capacities with three cover forms. The five existing configurations keep their registry ids; only the ten new ones receive two-axis names. There are no aliases.

| Location term | Linear cover | Thin-plate cover, `k = 50` | Thin-plate cover, `k = 200` |
|---|---|---|---|
| Absent | `lin_cover_noloc` | `loc0_tp50` | `cover_elev` |
| GP, `k = 12` | `loc12_linear` | `loc12_tp50` | `loc12_tp200` |
| GP, `k = 30` | `loc30_linear` | `loc30_tp50` | `mod8_coarse_loc` |
| GP, `k = 100` | `loc100_linear` | `loc100_tp50` | `loc100_tp200` |
| GP, `k = 500` | `lin_cover` | `loc500_tp50` | `mod8` |

Every configuration includes an intercept and `s(elev, k = 50)`:

- Linear cover: `ET + ST`, with open land as the reference fraction.
- Nonlinear cover: `s(OL, ET, ST, bs = "tp", k = 50)` or the identical basis family with `k = 200`.
- Location, when present: `s(x, y, bs = "gp", k = ...)`.
- Response: beta distribution with logit link; smoothing parameters estimated by REML within each fit.

Write the ten new registry entries explicitly. Keep older definitions for their existing uses, but remove the other ladder entries and `mod8_small_cover` from this CV list. The latter changes cover representation as well as size; models without a cover term cannot represent vegetation change.

Location `k = 12` examines the gap between no location term and `k = 30`. Basis size limits available complexity; it is not fitted effective degrees of freedom. The grid, sizes and fixed elevation term are project judgements.

Reuse the ordinary fitter and convergence checks: initial iteration limit 500, one retry at 2,000 for nonconvergence, with errors, warnings, retries and final status recorded. A configuration with any failed or unconverged required tuning fit is ineligible; do not score only its easier fits. If model 8 fails, report the comparison as incomplete; if none is eligible, make no choice.

Save smoothing parameters and effective degrees of freedom by term. They describe the fits and do not reopen the grid.

## 6. Score and choice

### Selection score

Use squared error of the deterministic fitted mean on the albedo response scale:

1. Keep only feasible withheld observations **< 250 km** from training with positive target weight.
2. Assign each observation by its **own departure from its fold’s training hull**, not the holdout’s name.
3. Average squared errors within each month × direction × cover-distance group, giving observations equal weight within a group.
4. Combine group means with the frozen historical weights, renormalized over represented groups.
5. Report the square root as RMSE beside represented and missing target weight.

Historical area and ice weighting enters through target weights. Keep the existing outside-distance bands: **0–<0.02, 0.02–<0.05, 0.05–<0.10 and ≥0.10**. Inside-hull observations have distance zero and are identified separately.

### Selection rule

Resample geographic blocks 1,000 times, keeping months and holdout appearances together; use the same draws for every configuration. Find the eligible configuration with smallest MSE. Among those whose excess MSE is no greater than **one standard error of its paired difference from that best configuration**, choose the fewest coefficients, then the earliest in the configuration table, read row by row, left to right.

Freeze coefficient counts before fitting; do not use fitted effective degrees of freedom. Counts in table order are **52/99/249; 63/110/260; 81/128/278; 151/198/348; 551/598/748**.

Retain the existing treatment of bootstrap draws missing a group and report their number. If the uncertainty needed for selection is not finite, make no automatic choice. Choose one configuration across testable months; label its use in other months as untuned there.

With fifteen candidates, optimism may be about one bootstrap standard error of the selection score—a rule-of-thumb judgement, not measured bias or an upper bound; report that standard error in albedo units without using it as a bias correction.

### Reports that do not choose the configuration

Report monthly RMSE and signed error; errors against evergreen share where open land is at most 0.20; regional errors including the northeast; distance summaries; the winner/model-8 in-range diagnostic; conditional AIC and fit summaries; both separation tests; and the hindcast comparison. A preferred northeast sign or diagnostic does not trigger another choice; failure can restrict interpretation.

### Distance reporting and the deep-cover limit

Pool months in the main distance table, retaining holdout and **each cell’s own departure direction**; show the northeast separately and retain monthly results. Cross cover-distance bands with the existing geographic bands: **0–<100, 100–<250, 250–<500 and ≥500 km**.

For each band and direction, report RMSE, signed error, paired MSE difference from model 8 and its block-resampled standard error; prediction counts (cell-month-holdouts), unique cells and blocks; positive-target counts; and represented/missing historical weight. These are pooled diagnostic errors, not the historical-weighted selection score. Report selection-weight shares separately; far cells have zero selection weight.

In `comparison.csv`, add **`max_cover_distance_nearby`** and **`max_cover_distance_all`** beside the existing quantiles for each holdout-month. The nearby maximum uses eligible positive-target scoring rows; the all-distance maximum uses diagnostic rows. In the distance report, retain nearby cells, blocks and maximum tested depth by each cell’s own direction and month, so a pooled maximum cannot imply evidence in an untested combination. Missing combinations are untested, not depth zero.

Use common predicted rows for diagnostic pairs and disclose failures. Do not turn partial comparisons into selection scores or extend an error curve beyond observed distances: a historical distance in the ≥0.10 band can exceed every tested distance in that band.

The [deep-band check](2026-11-06_cv_deep_band_review_fable.md), using run 1’s geometry with protocol-2 weighting, found:

| Nearby cover evidence | Result |
|---|---|
| Target-weight share within 0.05 of the hull | 86.3% |
| Deep band, ≥0.10 | 1.5% of nearby weight; 36 cell-month-holdouts on two blocks, all in the less-evergreen direction |
| Northeast’s less-open-land direction | No nearby deep observations; tested nearby in the 0.05–<0.10 band, containing its 4.5 ka median depth of 0.085 |
| Deep northeast-direction evidence at 250–<500 km | 132 cell-months, about eleven cells per month in at most five blocks; reported only |

Accept and report the 1.5% weight on two blocks; recompute coverage before version-2 fitting. The brief’s 96%/88% shallow shares were incorrect: truncating run 1’s original weights gives 95.3% nearby and 84.5% over all distances, which are different weights from version 2’s.

**Deep northeast-direction performance near training is untested:** no modern validation cell < 250 km from training lies ≥0.10 outside the hull in that direction. Direction describes a cover departure, not a geographic region. Synthetic recovery below tests deep cover at the northeast’s own cells under a stipulated truth; it tests capability under that truth, not the real response. Do not widen the cutoff or add scattered holdouts.

### Conditional AIC

Report `AIC()` for all fifteen configurations from the **30 full-data April–May fits only**. Compare configurations on identical response rows within the same month; do not pool raw AIC across months or datasets. Report differences within each comparison.

Use conditional AIC from the REML-fitted GAMs; record whether mgcv’s smoothing-parameter uncertainty correction is available. This is neither a restricted-likelihood score nor AICc. AIC supplies no filter, veto or tie-break, and requires no additional fits.

### Separation test 1: the real-data capacity comparison

For April and May, fit all fifteen configurations to identical full monthly data, reusing model 8’s corresponding fits. At northeast cells (−80 ≤ longitude < −66; 40 ≤ latitude < 48), calculate the **historical-size evergreen–summergreen exchange at 6 ka open land**:

- First endpoint: the cell’s 6 ka cover.
- Second endpoint: its 4.5 ka evergreen fraction, open land fixed at 6 ka, and summergreen set to the remainder.
- Hold location and elevation fixed; calculate second-endpoint albedo minus first-endpoint albedo.

This isolates the forest exchange and differs from the actual historical change when open land changes. Freeze common valid cells before fitting; require valid fractions at both endpoints, report exclusions and retained area, and normalize cell-area weights. Report monthly hull status and endpoint distances.

For every configuration, report the area-weighted contrast and standard error, location effective degrees of freedom, pairwise location–cover concurvity, and a plot of contrast against location capacity with separate lines for cover form. For linear cover, label concurvity as involving the parametric block (intercept and ET/ST); with no location term report “not applicable.”

Use `lpmatrix` and full coefficient covariance `Vp`. With endpoint model-matrix rows \(X_{i0},X_{i1}\), fitted means \(\mu_{i0},\mu_{i1}\) and normalized area weights \(w_i\), the response-scale gradient and standard error are:

\[
G=\sum_i w_i\{\mu_{i1}(1-\mu_{i1})X_{i1}
             -\mu_{i0}(1-\mu_{i0})X_{i0}\},
\qquad SE=\sqrt{G V_p G^\mathsf{T}}.
\]

This retains covariance between endpoints and cells. Intervals are approximate and conditional on fitted smoothing parameters; different configurations’ errors are not independent.

Flag point-estimate sign reversals across location capacities; a 95% interval crossing zero leaves that sign unresolved. Report magnitude changes too. Agreement shows stability within the grid, not correct separation of cover and location. There is no concurvity cutoff or selection gate.

### Separation test 2: synthetic recovery

Test the winner, model 8, and the winner with location removed but the same cover and elevation terms. Deduplicate equivalent configurations. Use April and May, three truths and twenty replicates per truth. Keep real coordinates, elevation, cover and monthly missingness; replace only albedo:

\[
\eta_i=a+0.5A\,z(OL_i)+0.25A\,z(elev_i)+bA\,z(ET_i)+g(x_i,y_i),
\qquad \mu_i=\operatorname{logit}^{-1}(\eta_i),
\]
\[
Y_i\sim\operatorname{Beta}(\mu_i\phi,(1-\mu_i)\phi).
\]

For each month, freeze \(a\) as logit of median observed albedo, \(A\) as standard deviation of run 1 model 8’s fitted linear predictor, \(\phi\) as its estimated beta precision, and every centering/scaling constant in \(z\) from complete calibration rows. Apply the same constants to every prediction endpoint.

| Truth | \(b\) | Location surface |
|---|---:|---|
| Evergreen darkens | −0.5 | \(A\,z(y)\) |
| No evergreen–summergreen effect | 0 | \(A\,z(y)\) |
| Evergreen darkens with shorter spatial variation | −0.5 | \(A\,z\{z(y)+\sin(2\pi y/4)\cos(2\pi x/8)\}\) |

Here \(x,y\) are longitude and latitude in degrees. The +0.5 truth is omitted. Generate each dataset once, before fitting, with `derive_seed(CV_SEED, 'cross_validation', 'recovery', month, truth, replicate)`; record the seed and use identical data across configurations. Use the ordinary fitter and retry rule.

The synthetic cover response is linear on the logit scale: linear cover is correctly specified, and the nonlinear basis contains it. Models without location omit a known effect; finite location bases need not reproduce the shorter spatial surface exactly.

Evaluate two exchanges:

- **Fixed exchange:** at modern northeast fitting cells with ET and ST at least 0.05, compare `(ET − 0.05, ST + 0.05, OL)` with `(ET + 0.05, ST − 0.05, OL)`. Second minus first means ten percentage points more evergreen replacing summergreen.
- **Historical-size exchange:** exactly the real-data test’s endpoints, at **6 ka open land**, with the same sign convention. This tests a hindcast-sized forest exchange at the northeast’s own locations under the stated truth.

For each exchange, freeze valid cells and area weights across configurations and replicates. Calculate the **exact contrast from the generating truth**. Report inside-hull and outside-hull subsets beside the complete valid set.

**Pass rules, fixed before fitting**, applied separately to each configuration, month and exchange:

- For each nonzero truth, recover the true regional sign in **at least 18 of 20** replicates, and absolute bias of the mean recovered contrast must be **at most half the absolute exact true contrast**.
- For the null truth, the **mean absolute recovered contrast** must be **at most one quarter of the absolute exact generator contrast under the simple-latitude \(b=-0.5\) truth**, on the same month, exchange and cells. The threshold never uses a fitted reference contrast.
- All twenty fits must converge and produce finite contrasts; otherwise report incomplete. Do not replace failures or omit them. An empty cell set or zero reference contrast is untestable.

A configuration passes only if it passes both exchanges, both months and all three truths. Failure, incompleteness or an untestable result prevents a northeast vegetation-sign claim; predictive selection remains unchanged.

Report replicate contrasts, bias, RMSE, sign counts, null invented contrasts and Monte Carlo uncertainty. Twenty replicates give a worst-case Monte Carlo standard error of about 0.11 for a sign-recovery proportion: this is a limited capability check. The generator, amplitudes, wavelengths, replication count and thresholds are project judgements.

## 7. Afterwards: the effect on the hindcast

Reuse run 1’s model-8 pipeline. For the winner, set its registered model in the existing configuration and run **scripts 1–10 unchanged**, including script 4’s ladder, spatial experiments and twelve prediction fits. Its April–May prediction fits are repeated as part of that run; no saved-fit injection or skip switch is added. If model 8 wins, reuse its completed run.

Use separate run folders, matched scientific settings and the existing recorded simulation seeds. Add `tools/compare_cv_hindcasts.R` beside the northeast figure tool, with two run-directory arguments, fixed product paths and input checksums.

### Comparison tables

1. **Albedo:** both configurations and their difference, by month and slice, for the study domain and northeast.
2. **Forcing:** both configurations and their difference for existing periods, plus northeast 6–4.5 ka; retain kernel and component results.
3. **Northeast signs:** actual deterministic 6–4.5 ka albedo change; the modern-range evergreen–summergreen swap at **50 BP open land and 6 ka open land side by side**; outside-hull shares; and historical predicted albedo against the observed monthly northeast range.

For both swap columns, retain the original modern evergreen endpoints: the minimum and maximum among that month’s northeast fitting rows. Hold each cell’s open land at the column’s named slice, set summergreen to the remainder, and hold location and elevation fixed. Predict at the exact endpoints; **low-evergreen minus high-evergreen** means summergreen replacing evergreen. Use common valid cells for both columns and models; report exclusions and endpoint hull distances. These modern-range swaps differ from the historical-size exchange in the separation tests.

Use common cells and denominators for every comparison and area-weight regional means. Keep the pipeline’s ice treatment; do not apply ice-free fraction again to saved forcing. For northeast 6–4.5 ka, sum steps ending at 5500, 5000 and 4500 BP and check against the endpoint change on identical cells.

State signs in headers: **positive albedo change means brighter; positive forcing means warming**. Keep deterministic contrasts distinct from pipeline albedo means obtained through simulations.

### Support and figures

Use one outside-hull flag with numeric distance and band. A slice uses that month’s full-data hull. A period is outside if any endpoint of any included step is outside; report the largest endpoint distance and band. Area shares and signed contributions must add back to displayed totals. Show validation errors and tested limits beside them, without further support classes.

Keep albedo time series; winner-minus-model-8 albedo maps at 50 BP, 6 ka, 4.5 ka and the oldest actual slice; headline-total forcing difference maps for existing periods; and the April–May northeast cover-response figure. Drop the forcing series panel and separate vegetation-component forcing difference maps.

For the April–May curves, retain each cell’s modern open land, location and elevation. Derive modern evergreen and observed albedo ranges from that month’s northeast fitting rows; show actual historical-mixture points separately and identify extrapolated curve endpoints.

## 8. Code and verification

### Smallest code changes

| Location | Adds or changes | Removes from this experiment |
|---|---|---|
| `R/model_registry.R` | Ten explicit new entries and fixed CV order; preserve five existing ids. | Other ladder/baseline entries and `mod8_small_cover` from `CV_MODELS`. |
| `R/cross_validation.R` | Shared < 250 km scoring mask, feasibility, weights and distance maxima. | Far observations from selection; extra in-range models. |
| `tools/cross_validate_albedo.R` | Same mask at holdout and score stages; each cell’s direction in the distance table; fit summaries. | Nested orchestration and AIC per tuning fit. |
| Shared fitting helper in `R/` | Move the fit-and-retry operation for CV and separation tests to share. | Duplicate fitting/retry logic. |
| One separation-test tool | April–May capacity comparison and AIC, seeded recovery and summaries. | +0.5 truth, duplicate configuration fits and location-surface recovery error. |
| Shared contrast helper in `R/` | Valid exchanges, exact predictions, area-weighted contrasts and covariance-aware uncertainty. | Repeated exchange calculations across tools. |
| `tools/compare_cv_hindcasts.R` | Two-run tables and trimmed figures. | No existing northeast tool is deleted or renamed. |

Reuse hull geometry, regions, scoring, bootstrap, choice rule, pipeline products and existing configuration validation. No pipeline plumbing changes. Reviews follow `AGENTS.md`; verification uses `tools/verify_change.R`.

Targeted verification must establish:

- unchanged existing formulas/predictions and the fifteen setup counts listed in section 6;
- identical training/scoring rows across configurations; monthly distances to actual complete training rows;
- a cell at 240 km enters selection, one at 260 km cannot change it, and exactly 250 km is excluded;
- target weights and direction assignment, with represented/missing weight recomputed under the nearby feasibility mask;
- expected choices on hand-worked scores, and correct failure, retry and incomplete handling;
- identical seeded synthetic data across configurations and frozen standardization at every endpoint;
- contrast-helper invariants: valid fractions sum to one, open land/location/elevation stay fixed, identical endpoints give zero, reversed endpoints negate the contrast;
- response-scale uncertainty retains covariance, the exact generator null contrast is zero, and thresholds use the exact nonzero generator contrast;
- pass boundaries: 18/20 correct signs passes the sign rule and 17/20 fails; equality at the bias and null limits passes, exceeding them fails;
- AIC compares only identical response rows within one full-data month (the same dataset/month restriction as for a holdout), with no tuning-fit AIC included;
- per-direction cells, blocks and distance maxima, common-cell report denominators, period sums and endpoint agreement;
- correct reuse of model-8 fits and unchanged pipeline behaviour for the winner.

The precedent table retains the supporting passage record. Combined reference checkers remain to be run before implementation; the Pirzamanbein section heading was checked against the primary text for this final protocol.

## 9. Fit count and execution

Assuming three feasible directions, twelve months and fifteen configurations:

| Work | New fits before retries |
|---|---:|
| Directional tuning: 3 × 12 × 15 | 540 |
| Full-data April–May comparison: 2 × 15, less two reused model-8 fits | 28 |
| Recovery: at most 3 configurations × 2 months × 3 truths × 20 replicates | 360 |
| In-range diagnostic: winner and model 8 × 12 months | 24 |
| Winner’s unchanged pipeline: 12 × (8 ladder + 7 spatial + 1 prediction) | 192 |
| **Maximum new fits** | **1,144** |

The pipeline’s 192 include twelve model-7 fits and both repeated April–May prediction fits. Reusing run 1’s model-8 fits/pipeline is assumed; equivalent configurations, model 8 winning and infeasible combinations reduce the count. Retries are separate. AIC adds no fits. Use the existing queue, at most six concurrent single-thread CV/separation fits, without scheduler changes.

## What the result can and cannot show

It can identify better measured performance on represented modern cover departures < 250 km from training, show errors by distance and direction, reveal sensitivity of the northeast contrast to location capacity, and test recovery under stipulated truths.

It cannot establish unbiased performance of the selection procedure, historical albedo accuracy, deep northeast-direction accuracy near training, accuracy beyond the tested span, correct separation of real vegetation/snow/climate/location effects, or a causal hemlock effect. Recovery covers only the stated truths; independent beta draws do not test unknown residual spatial dependence or reconstructed-cover uncertainty.

A stable real-data contrast and successful recovery strengthen a conditional interpretation; neither establishes the historical sign. A sign change between hindcasts alone does not demonstrate an extrapolation artefact.

## Precedent table and passage record

Passages are paraphrased. Numerical settings without direct precedent are project judgements. The [4 November published basis](2026-11-02_cv_protocol.md#published-basis-of-the-geographic-sensitivity-reports-4-november-2026) supplies the geographic distance-table and in-range-holdout precedents, references and checked passages.

| Step | Precedent, DOI and passage read | Support and limit |
|---|---|---|
| Reconstructed cover | Dawson et al. (2025), §2.3: [10.5194/cp-21-2031-2025](https://doi.org/10.5194/cp-21-2031-2025). | REVEALS-GMRF interpolation with elevation; not validation of albedo calibration. |
| Compare albedo configurations | Bright et al. (2015), supplement §S4, PDF p. 12: [10.5194/bg-12-2195-2015](https://doi.org/10.5194/bg-12-2195-2015); Hu et al. (2018), §3: [10.1029/2018MS001403](https://doi.org/10.1029/2018MS001403). | Candidate comparison using performance and complexity; our grid and sizes are judgements. |
| Withhold environmental extremes | Telford and Birks (2009), §7, p. 1315: [10.1016/j.quascirev.2008.12.020](https://doi.org/10.1016/j.quascirev.2008.12.020). | They described and criticised extreme holdouts: potentially useful for extrapolation, unsuitable as evidence of spatial independence. Their account was read, not the original experiment. Our directions, cuts and weights are adaptations. |
| Report geographic transfer | Hu et al. (2018), §3.4: [10.1029/2018MS001403](https://doi.org/10.1029/2018MS001403). | Reciprocal-area forest-albedo tests; no domain justification for our 250 km cutoff. Geographic distance tables and the in-range holdout follow the 4 November basis linked above. |
| Simpler configuration within uncertainty | Yates et al. (2023), equations 7–8: [10.1002/ecm.1557](https://doi.org/10.1002/ecm.1557). | Neighbouring ecology; our paired block-resampled rule is an adaptation, not an optimism estimate. |
| REML and conditional AIC | Wood et al. (2016), §5: [10.1080/01621459.2016.1180986](https://doi.org/10.1080/01621459.2016.1180986); Pirzamanbein et al. (2020), §2.2, “Testing the Model Performance,” and Table 2: [10.1029/2018EA000547](https://doi.org/10.1029/2018EA000547). | GAM theory supports conditional AIC; palaeo-vegetation practice reports DIC beside CV. DIC is not AIC; neither implies an AIC filter. Primary text confirms §2.2, correcting the earlier precedent note’s §2.5. |
| Cover-exchange contrast and uncertainty | Duveiller et al. (2018), Methods, “Retrieving the local biophysical signal,” equations 11–13: [10.1038/s41467-017-02810-8](https://doi.org/10.1038/s41467-017-02810-8). | Vegetation-replacement predictions with covariance; historical-sized exchanges and the GAM capacity test are adaptations. |
| Synthetic recovery | Telford and Birks (2009), §4, DOI above; Morris et al. (2019), §§3 and 5: [10.1002/sim.8086](https://doi.org/10.1002/sim.8086). | Transfer-function simulations expose misleading spatial skill; general simulation guidance supports explicit truths and performance measures. Exact generator and thresholds are judgements. |
| Distance-graded cover error | Telford and Birks (2011), Results and Fig. 6: [10.1007/s10933-011-9523-z](https://doi.org/10.1007/s10933-011-9523-z). | Errors along environmental gradients; our hull bands, pooling and limits are adaptations. Weighting cannot supply missing deep observations. |
| Hindcast comparison | Duveiller et al. (2018), Methods; Dawson et al. (2025), §4.2.3, DOIs above. | Vegetation replacement and northeast reconstruction context; periods, area summaries, flags and figures are reporting judgements. |

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
