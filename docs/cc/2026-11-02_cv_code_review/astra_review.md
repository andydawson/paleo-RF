# Astra (GPT-6-Astra, max effort; science-reviewer role): review of the cross-validation code at b0cf6b1, 2 November 2026

**Verdict.** Block merge and production scoring at `b0cf6b1`: failure handling, target weighting and bootstrap selection need correction.

**Benefit.** This provides a prespecified comparison of albedo models under cover extrapolation, informing which model supplies the Holocene forcing estimates.

All line references below refer to `b0cf6b1`. The driver changed in the working tree during this review; those edits are outside this verdict.

**Hand check.**

For two cells, two historical slices and one month, the implemented area weighting gives:

| Slice | Cell | Area | Ice fraction | Ice-free area | Weight |
|---|---|---:|---:|---:|---:|
| 500 BP | A | 2 | 0.50 | 1 | 1/4 |
| 500 BP | B | 1 | 0 | 1 | 1/4 |
| 1000 BP | A | 2 | 0.75 | 0.5 | 1/6 |
| 1000 BP | B | 1 | 0 | 1 | 1/3 |

Each slice receives 1/2 and total weight is one. The code agrees **when ice fractions are present and the configured slices match all slices in the paleo table**. For consistent adjacent pairs, recovering the shared slice from both endpoints and deduplicating also works.

Two qualifications matter:

- If A’s ice fraction is missing at 500 BP, `sum()` inside `ave()` becomes `NA`; **both cells’ weights become missing**, including B’s known weight.
- If only A is outside the hull at 500 BP but both cells are outside at 1000 BP, conditioning the weights on outside support gives slice shares **1/3 and 2/3**, rather than equal shares.

The reconstruction uses script 7a’s **adjusted** fractions. For example, original fractions `(0, 0.8, 0.2)` at three ascending ages become `(0, 0.1, 0.2)` through the existing readvance adjustment. CV inherits that adjustment; it does not recover the original ice chronology.

For the score, take group weights 3:1. Model A has squared errors `(0.01, 0.09)` in the first group and `0.04` in the second:

\[
MSE_A=\frac{3(0.01+0.09)/2+0.04}{4}=0.0475,\qquad RMSE_A=0.21794.
\]

Model B with errors `(0.01, 0.01)` and `0.16` also scores `0.0475`. These can all arise from observed albedo 0.2 and predictions between 0.3 and 0.6. `cv_score()` agrees. With another unrepresented group of weight four, represented share is correctly 1/2.

The paired-SE formula is also correct for finite, comparable bootstrap scores: differences `(0, 0.02, 0, 0.02)` have sample SD `0.01155`. A simpler candidate worse by `0.005` qualifies. The problems concern which observations enter those scores and what happens when bootstrap groups disappear.

**Findings.**

1. **Blocker — `R/cross_validation.R:101`, `R/cross_validation.R:133`: empty bootstrap groups change the target and can permit a baseline winner.**  
   A resample with no observations in a group sets that group’s weight to zero and renormalizes over the remaining groups. Thus resamples need not estimate the same fixed target-weighted score.

   Worse, ten withheld blocks can satisfy feasibility while only one contains observations with positive target weight. Resampling ten blocks misses that block with probability \(0.9^{10}\approx0.349\), producing `0/0` scores. One such draw makes every paired SE missing. Eligible candidates then have `comparable = NA`, while baselines have `FALSE`; `order(!comparable, ...)` places baselines before the missing values and can select `mod1`.

   **Check:** construct exactly this ten-block case. Require an explicit unsupported-uncertainty result, finite SEs before automatic selection, and an invariant that an ineligible model is never chosen. Separately test a resample losing just one positive-weight group.

2. **Blocker — `tools/cross_validate_albedo.R:181`, `:189`, `:206`: an outright fitting error aborts the entire holdout-month.**  
   Neither fitting attempt nor prediction catches errors. Because saving occurs after the complete `lapply()`, an error in one candidate prevents saving earlier successful candidates and prevents later candidates from running. Merely adding missing predictions would still make the score stage reject the whole comparison.

   **Consequence:** one failing candidate prevents selection among otherwise valid candidates, instead of being recorded as ineligible.

   **Check:** inject an error in a middle candidate. Successful candidates must remain available, the failed candidate must have an explicit status, and its failure must not silently remove required folds from other candidates.

3. **Blocker — `tools/cross_validate_albedo.R:201`, `:185`: target and validation “direction” use different definitions.**  
   Historical groups use the nearest broad direction to the **actual departure angle**. Predictions instead use the **holdout label**. The prediction file saves distance but no departure angle or corresponding direction.

   A concrete counterexample uses training fractions `(OL, ET, ST)`:
   `(0.8,0.2,0)`, `(0.6,0.2,0.2)`, `(0.6,0.4,0)`, and withheld `(0.1,0.5,0.4)`. A 90° cut withholds the last cell. Its nearest-hull departure is nevertheless **30°**: the displacement is `(0.375, 0.216506)`. With broad directions 0° and 90°, its nearest direction is 0°. The score labels it 90°.

   **Consequence:** errors can receive weights for a different departure family.

   **Check:** use this geometry through prediction saving and scoring. Apply the same direction definition to historical and validation departures, retaining the holdout identifier separately. If nominal holdout direction is intended instead, that distinction needs an explicit protocol decision.

4. **Blocker — `tools/cross_validate_albedo.R:59`, `:66`: missing ice can silently remove an entire slice’s target contribution.**  
   Missing fractions survive the merge. One missing ice-free area makes the slice denominator missing; `aggregate()` subsequently omits missing weights. The printed merge count does not expose this loss.

   **Consequence:** the direction distribution and selection weights can omit known cells alongside the unknown cell, violating the declared weighting.

   **Check:** use the two-cell example above with one missing fraction. Verify the chosen missing-data policy explicitly, report excluded coverage, and ensure a known cell never loses its weight merely because another cell’s fraction is unknown.

5. **Should-fix — `tools/cross_validate_albedo.R:54`, `:60`: pair reconstruction ignores configured ages.**  
   `slices` comes from every age in script 1’s paleo table; script 7a pairs **configured** ages. With paleo ages `(50,200,500)` and configured ages `(50,500)`, the older endpoint of the 50–500 pair is incorrectly assigned to 200 BP. The driver similarly derives months from available calibration columns rather than the run’s configured months.

   **Check:** use a valid sparse-age configuration and a month subset. Require exact agreement with script 7a’s pair endpoints and the configured target. This defect does not establish that the supplied full-age development run was misindexed.

6. **Should-fix — `tools/cross_validate_albedo.R:159`, `:182`, `:214`: convergence reporting does not implement the complete failure contract.**  
   Returned non-converged fits receive predictions and numerical aggregate scores; eligibility alone is changed. If model 8 fails, there is no explicit “comparison incomplete” result, although §5 requires one. Warnings from both attempts are suppressed, and saved predictions retain only a Boolean—not the attempt history or convergence evidence.

   The predicate also omits Hessian/gradient information reported by the existing convergence checker. Whether those diagnostics disqualify a fit should be stated explicitly, rather than inferred.

   **Check:** cover successful retry, unsuccessful retry, model-8 failure, no eligible candidates, and convergence exactly at the iteration limit. Preserve the evidence needed to distinguish these outcomes.

7. **Should-fix — `tools/cross_validate_albedo.R:178`, `:235`: “skill inside the range” includes outside-range cells.**  
   The random geographic holdout can remove hull vertices. Distance is calculated and saved, but the reported RMSE uses every withheld row, including positive-distance rows and non-converged fits.

   **Consequence:** a mixture of interpolation and extrapolation error is labelled in-range skill.

   **Check:** withhold a block containing a unique cover extreme. Report genuinely inside-hull predictions separately, with counts and excluded/outside coverage. One sampled fifth is consistent with the protocol’s stated fit count; the problem is the reported population.

8. **Should-fix — `tools/cross_validate_albedo.R:164`, `:126`, `:212`: frozen memberships and results are insufficiently bound to their inputs.**  
   Membership includes coordinates, but fitting applies its logical vector by row position without checking those coordinates. Reordering the calibration table between stages can put an originally withheld cell into training. Existing prediction files are accepted by filename, without establishing that they belong to the current holdouts and inputs.

   Derived assignment/bootstrap seeds are neither saved nor printed, contrary to §6. The represented share is printed but absent from the saved score table.

   **Check:** reorder calibration rows, change one predictor, or replace holdouts while retaining prediction files. Require either correct keyed alignment or rejection. Save the derived seeds and enough input/holdout identity to reproduce the comparison.

9. **Should-fix — `R/cross_validation.R:53`, `:67`; `tools/cross_validate_albedo.R:76`: reported direction shares describe a different partition from the target.**  
   Shares come from hierarchical-clustering memberships; target membership is reassigned to the nearest cluster mean. Those partitions differ in the supplied development outputs:

   | Direction | `directions.csv` share | Share implied by `target.csv` |
   |---|---:|---:|
   | d1 | 52.40% | approximately 49.84% |
   | d2 | 39.99% | approximately 42.60% |
   | d3 | 7.61% | approximately 7.57% |

   **Check:** aggregate the actual target labels and require agreement with reported shares. Also satisfy §3’s direction-plot requirement: `plot_directions()` plots compositions coloured by group, not the original angular distribution, so small angular families within a broad group cannot be assessed directly.

10. **Should-fix / unresolved specification — `tools/cross_validate_albedo.R:66`, `:75`: “each historical slice and each month equally” needs a precise population.**  
    Equality holds before outside-hull filtering, not generally within the final outside score. The hand check shows the distinction. Both interpretations are possible scientific choices; the implementation should not silently settle it.

    **Check:** use slices—and then months—with different outside-area shares. Assert the explicitly approved normalized weights.

11. **Should-fix / unresolved specification — `tools/cross_validate_albedo.R:97`, `:101`: fallback selection adds an unstated ranking rule.**  
    The driver evaluates all three cuts and selects the first maximizing the number of feasible months. §3 permits alternatives if 80% fails, but §4 says a failed month or direction “is not rescued by changing the cut.” The code’s resolution of this tension is not explicit in the frozen protocol.

    The supplied run uses 80% everywhere, so this branch has not affected those memberships.

    **Check:** supply feasibility tables where 80% passes some months and an alternative passes more. Freeze the expected common cut and untested months before scores are available.

12. **Should-fix — `R/config_schema.R:155`; `tools/plotting/plot_northeast_cover_and_location.R:63`: §8’s downstream integration remains incomplete.**  
    Five eligible winners—including `cover_elev`—are rejected by `model_id` validation. The northeast tool still stops for any prediction model other than `mod8`.

    **Check:** propagate each eligible identifier through configuration validation, then demonstrate the selected model through the promised downstream comparison. If this is a separate implementation step, describe this change as partial rather than complete protocol implementation.

The four new formulas, unchanged existing ladder, explicit seven spatial models, thirteen-model roster, REML fitting, response-scale predicted means, and ordinary finite-score tie-breaks match the protocol. I found no substantial abstraction bloat. Removing blanket warning suppression is more useful than forcing the small geometry helpers into exactly three functions.

**What the proposed verification misses.**

`tests/test_cross_validation.R` checks useful helper arithmetic, but it does not exercise the complete holdout–fit–score workflow. Add:

- Target reconstruction with configured age subsets, missing ice and consistent shared endpoints; explicit slice/month weight totals.
- Actual departure direction carried into saved predictions and scoring.
- Common training/validation rows across all candidates and months, including missing observations and reordered inputs.
- Whole-holdout reproducibility, recorded seeds, repeated numerical predictions, and preservation of the caller’s random state.
- Block multiplicities shared across months, models and overlapping appearances; missing target groups and zero-weight draws.
- Real-registry tie-breaks, no eligible candidate, missing/nonfinite SEs, and the invariant that baselines never win.
- Both retry outcomes, outright errors, model-8 incompleteness, and genuinely in-range reporting.
- The cover-free zero-change invariant and propagation of an eligible winner.

Fable’s earlier overlap-weight bookkeeping check is also absent: repeated appearances are counted separately, although they are correctly kept together during block resampling. The buffer/reserved-block checks were superseded by the approved protocol.

I found no verification spec or PASS report covering these commits. Verification must use `tools/verify_change.R`. Legacy byte identity would establish preservation of the old path; neither that nor the seed-1 anchors validates these new scoring and selection rules. Historical stochastic tolerances likewise do not validate CV uncertainty.

The development tables establish **feasibility, not resemblance or accuracy**. All 36 combinations pass, with at least 911 training rows against 748 coefficients and at least 21 withheld blocks. Cover departures are generally larger in validation: for example, d3 March has median 0.041 versus 0.0066 historically.

The packet’s geographic summary needs qualification. For d1, historical median distances are **440 km in January, 110 km in November and 1,400 km in December**; corresponding withheld medians are 320, 320 and 330 km. Many other historical medians are zero. These are unweighted percentiles, not summaries weighted by the target weights.

Consequently the folds test transfer across cover and geography, with mismatch varying by month and direction. They cannot supply an unbiased hindcast-error estimate or cleanly isolate whether the location term belongs. No model’s superiority has been established by this first-stage run.

**Questions for Chris or Andria.**

- **Weighting:** equal slice/month contributions *within outside support*, or equal full-population contributions subsequently conditioned outside? The code currently implements the latter.
- **Ice:** use script 7a’s adjusted fractions or original fractions? For unknown fractions, stop or exclude and explicitly report coverage? At this head, adjusted fractions are used and missing values can poison a whole slice.
- **Fallback:** retain 80% and mark failed months untested, or select one alternative cut per direction using an explicitly defined feasibility rule? The code maximizes feasible-month count.
- **Overlap:** split repeated-cell scoring weight as the earlier design proposed, or treat each holdout prediction as a separate validation case? The code does the latter.
- **Interpretation:** proceed with this qualified transfer-based selection, or reconsider the protocol before fitting because of the geographic mismatch? The current driver proceeds once feasibility passes.

These remain questions for the living scientific record, not decisions attributed to Chris.

**Not checked.**

No R, tests, fitting or pipeline execution was performed. I did not deserialize the RDS inputs, independently verify their provenance, establish the actual frequency of missing ice/group-mismatch cases, or inspect the PDF itself; I viewed the supplied PNG. Kernel scaling, forcing arithmetic and downstream scientific outcomes were not revalidated. I found no direct response leakage with unchanged, correctly ordered inputs, and no score or hemlock-sign dependency in fold construction. The earlier design reviews were consulted only after forming the initial findings.

Files read: the four changed files; `AGENTS.md`, `CONTRIBUTING.md`, README/config excerpts; CV protocol, decisions, brief, design, prior review and reconciliation; regression contract and question files; supporting training-support/random/differences/preparation/config/path code; scripts 1, 2, 4 and 7a; convergence and northeast tools; support/random/convergence tests; verification records; four development CSVs and `directions-1.png`. Tool calls: 49 read-only shell calls and one image read; no R execution or writes.