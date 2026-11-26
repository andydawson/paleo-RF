**Verdict.** No numerical defect found in the supplied result; delete the unapproved target guard and complete the required recorded verification before merge.

**Benefit.** This check shows whether scoring already-withheld distant cells changes the preferred calibration model, and measures how closely those locations resemble the historical prediction target.

**Hand check.**

Take two historical cells, A and B, two slices and one month. Their areas are 1 and 3.

| Slice | Ice fractions A, B | Ice-free areas | Target weights A, B |
|---|---|---|---|
| Younger | 0, 0 | 1, 3 | 1/8, 3/8 |
| Older | 0, 2/3 | 1, 1 | 1/4, 1/4 |

Each slice receives half the weight. Suppose A is outside the monthly full-data cover hull in both slices; B is inside when younger and outside when older. Valid cover examples are pure evergreen, the equal-thirds mixture, and pure open land against the training triangle formed by edge midpoints: all fractions sum to one.

The outside target is therefore `1/8 + 1/4 + 1/4 = 5/8`. If A’s coordinates belong to that month’s complete calibration rows and B’s do not, the at-place share is:

`(1/8 + 1/4) / (5/8) = 0.60`.

This agrees with [the target-weight helper](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/R/cross_validation.R:66) and [the new aggregation](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tools/check_cv_far_cells.R:96). It is neither an unweighted cell count nor a mean of separately calculated slice percentages.

For the score, let two far validation rows represent those two outside groups, with normalized weights 0.6 and 0.4:

| Row | Distance | Observed | Leader prediction | Competitor prediction |
|---|---:|---:|---:|---:|
| A | 250 km | 0.20 | 0.22 | 0.24 |
| B | 260 km | 0.30 | 0.28 | 0.29 |

Leader MSE is `0.0004`. Competitor MSE is `0.6 × 0.0016 + 0.4 × 0.0001 = 0.0010`. Their difference is `0.0006`.

The row contributions are `+0.00072` and `−0.00012`: shares **120% and −20%**, summing to 100%. Thus negative shares are correct, and a positive contribution supports the leader. [Lines 63–68](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tools/check_cv_far_cells.R:63) implement this arithmetic correctly. Exactly 250 km enters the far score.

These are hand calculations against the source, not executed tests.

**Findings.**

1. **Should-fix — useful deletion: remove the unapproved runtime target guard.**  
   [tools/check_cv_far_cells.R:87](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tools/check_cv_far_cells.R:87), and lines 92–95.

   The commit message explicitly calls this “a new guard, to be put to Chris.” That is not approval under the supplied architecture rule.

   The equality it checks is useful verification: unchanged inputs do not alone prove that reconstructed target weights are unchanged. But this fixed-run diagnostic does not need a new permanent refusal mechanism to establish that equality. Check it in the already-required verification.

   Delete lines 92–95 and the now-unused distance calculation at line 87: **+0/−5 = −5 production lines**. This also removes a redundant `training_support()` call; `departure_angle()` already obtains support.

   **Proposed check:** aggregate the reconstructed target once in verification and compare its groups and weights with the frozen target. Confirm that removing the runtime guard leaves all five CSVs unchanged.

2. **Should-fix — the required verification evidence is missing from the packet and repository.**  
   [tools/check_cv_far_cells.R:13](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tools/check_cv_far_cells.R:13); decision 1 in [the decisions record](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/docs/cc/2026-11-26_cv_spatial_folds_decisions.md:7).

   Commit `79de462` adds only the script. I found no corresponding verification specification or report. The permitted `farcheck/` folder contains five CSVs, without an execution record tying them to this commit. The reported nearby-score reproduction is useful, but I cannot independently establish it from those artifacts.

   **Consequence:** the numbers are plausible and internally consistent, but their reproducibility and the new at-place calculation have not received the project’s required executable verification.

   **Proposed check:** use `tools/verify_change.R` at the exact corrected commit, with the focused assertions below. Estimated follow-up cost: **+45 verification/specification lines and +15 report lines, −0; approximately +60 lines**, using existing document types and machinery.

The core implementation otherwise fits the requested scope: existing scoring, choice, geometry and seed functions are reused; no fitting or pipeline changes are introduced. With the deletion above, the estimated necessary follow-up is **+60/−5 = +55 lines**, with verification additions shown separately from production deletion.

**What the code and outputs establish.**

- **Same score for this run:** yes, with the distance restriction reversed. All 36 holdout-months remain feasible, so the additional feasibility restriction changes none of them. Group means, historical weights, represented-group normalization and paired block resampling use `cv_score()` unchanged.
- **Eligibility is not literally unchanged in general.** Line 49 considers only far-scored holdout-months; protocol 2 considers every required fitted holdout-month. Here those sets coincide. The existing June d1 failure keeps `cover_elev` ineligible under both calculations.
- **Far selection is correct by inspection:** finite distance, `≥250`, positive target weight, and a fitted, far-feasible holdout-month. Grouping retains each prediction’s own departure direction, including overlapping holdout appearances.
- **Contributions are additive and correctly signed.** For runner-up `loc100_tp50`, the three direction contributions sum to `0.0021826673076274`, its reported excess MSE. Direction 1 supplies **90.91%**; the block at 165–160°W, 65–70°N supplies **48.05%**. These are two overlapping decompositions of the same margin; their percentages must not be added together.
- **At-place weighting is correct for protocol 2’s target.** It uses each month’s complete calibration rows, full-data hull, historical slices excluding 50 BP, and area × ice-free fraction with equal slice/month weights before outside-hull restriction. The pooled share is `0.120313502738503 / 0.128157920602757 = 93.8791%`. It describes the **outside-range target**, not all historical cells or the forcing contribution.
- **Skipping the current-settings check does not change this calculation.** The script uses frozen `holdouts$analysis` and checks the three input files against their frozen checksums. It does not use current configuration values to rebuild the target.
- **Skipping prediction-geometry validation removes a real assurance.** The predictions’ holdout checksum identifies their originating holdouts; it does not prove that every candidate still contains every frozen row with unchanged geometry. Protocol 2 checks that explicitly. I found no evidence of damaged predictions here; verify the supplied files using that existing comparison rather than inventing another production guard.

The CSVs confirm `loc100_linear` wins both scores. Its far MSE is **0.00346038**, versus nearby **0.00243945**. Far represented target weight is **100%**, versus **97.9445%** nearby. Consequently, subtracting these scores would not isolate a geographic-distance penalty: both observations and represented weights differ.

**What the proposed verification misses.**

Nearby-score reproduction checks the reused machinery, but cannot alone establish the new calculations. A compact verification should cover:

- The actual prediction files match frozen validation rows, using protocol 2’s existing comparison.
- The reversed boundary admits 250 and 260 km, excludes 249.999 km, and still excludes zero-weight groups.
- Direction and block contributions each sum to the corresponding excess MSE, retaining negative contributions.
- The hand-worked at-place numerator and denominator above, including monthly calibration missingness; reconstructed aggregate target weights match the frozen target.
- Nearby reproduction compares the corresponding score, eligibility, paired-SE and choice fields. The complete CSV schemas differ.

Stochastic behavior is preserved **within the far comparison**: 1,000 block resamples, seed **1978221365**, shared draws across candidates, and restoration of the previous random state. Changing the selected block population changes what those draws represent; the same seed does not create a paired far-versus-near experiment. The seed-1 pipeline anchor and historical simulation tolerances do not validate this diagnostic.

**Questions for Chris or Andria.**

**Should geographic transfer choose the model, or remain diagnostic beside protocol 2?** The decision record explicitly leaves this open. Meanwhile, this script reports a far choice separately; it does not replace protocol 2’s saved choice.

The result supports stability of the winner under **this particular rescore**. It does not establish the winner of buffered refits, independent errors at 250 km, historical albedo accuracy, or the vegetation-response sign. Buffered fits would change training data, coefficients and cover geometry.

The **93.9%** at-place share quantifies a mismatch between prediction tasks; it does not prove that spatial validation is unnecessary. Published work supports both concern about spatial dependence and matching validation to the prediction objective. See Roberts et al. (2017), *Cross-validation strategies for data with temporal, spatial, hierarchical, or phylogenetic structure*, *Ecography* 40, 913–929, [DOI: 10.1111/ecog.02881](https://doi.org/10.1111/ecog.02881), particularly its discussion of induced extrapolation.

Likewise, `loc12_linear` being **1.56 paired standard errors** behind is descriptive under the existing bootstrap, not a significance result or calibrated uncertainty bound. There are **153/1,000** resamples missing a group. The concentration of the margin deserves disclosure, without an automatic regional veto.

**Not worth doing.**

I dropped three possible expansions from the findings: a generic empty-result framework, special handling for tied-margin percentages, and a new bootstrap or regional selection rule. None fixes an observed numerical defect in this packet.

Do not introduce a configurable distance framework merely to reverse one comparison. Do not extract the short target reconstruction into a new abstraction for hypothetical reuse.

The eligibility expression could simply lose `& hm(predictions) %in% used` to retain protocol 2’s exact requirement: **+1/−1, net zero lines**. That would simplify the contract but would not change this run’s result.

**Not checked.**

No R, fits, pipeline scripts or verification were run. Binary RDS contents and exact bootstrap results were not independently regenerated. Published passages were read directly; no dedicated reference checker was run. Questions files remain unchanged under the read-only instruction.

An access mistake occurred: the evidence delegate listed the scratchpad parent and read sibling `near.log`, outside the permitted `farcheck/` folder. It stopped, and that log was excluded from this review.

Files read: project rules/README, regression contract, relevant questions/configuration, protocol/decisions/both prior reconciliations, changed script, CV/model/geometry/random/path helpers and tests, relevant pipeline callers, and saved CSVs/records; tools: **56 read-only shell calls including delegation, and 3 published-literature calls; no writes or R execution.**