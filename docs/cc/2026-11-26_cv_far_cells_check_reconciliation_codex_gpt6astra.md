**One-round reconciliation — Codex, 26 November 2026.**

**Verdict:** No numerical defect found in the supplied results. Accept Fable’s simplifications and stronger account of the thin far lead; retain geometry verification and correct the proposed assertions.

**Benefit:** This check helps Chris judge what distant withheld predictions contribute to model selection before commissioning buffered fits.

**1. Agreement**

**AGREE — the useful deletions.** Fable identifies about **18 lines of savings** that my review missed. The runner-up console section, repeated at-place totals and redundant feasibility column can go. Keep the underlying monthly directional weights so summaries remain reproducible.

**AGREE — the far lead is thin and concentrated.** Rechecking the saved score tables gives:

| Simpler model | Far difference / paired SE | Nearby |
|---|---:|---:|
| `loc30_tp50` | 1.33 | 5.89 |
| `loc12_tp50` | 1.44 | 7.98 |
| `loc30_linear` | 1.46 | 4.34 |
| `loc12_linear` | 1.56 | 4.81 |

Thus **33% larger reported SEs would admit a simpler model**. That is a sensitivity threshold, not an estimate of the correct uncertainty.

The shallow groups contain **527 of 6,940 far-scored rows but carry 58.36% of the weight**. All 36 holdout-months passing feasibility does not establish broad geographic evidence. My earlier summary gave these limitations insufficient prominence.

**AGREE — independent score recomputation belongs in the spec.** Pool `mse × cell_month_holdouts` from the two far bins of `by_distance_month.csv`, divide by pooled counts within each month/direction/cover-band group, then apply frozen target weights. This matches the score definition independently of the new selector. Although that report uses common rows with `mod8`, model 8 is complete here, so the route is valid for all 14 eligible candidates. I withdraw the proposed reversed-condition run as a necessary additional check.

**2. Disagreements and concessions**

**Geometry — DISAGREE with Fable’s written recommendation.** The supplied review actually says restoration is “not worth doing”; it does not recommend restoring the check.

The checksum in [read_predictions()](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tools/cross_validate_albedo.R:86) identifies originating holdouts. It does not establish unchanged prediction rows or geometry. The existing comparison at lines 406–415 does.

Independent score equality cannot replace this comparison. Two equal-weight rows with error differences 0 and 2 have mean difference 1 whether assigned to separate blocks or the same block; their bootstrap uncertainty differs. Changed coordinates can therefore preserve Fable’s score assertion while altering SEs and block contributions.

Apply the existing frozen-row comparison to the actual files in the required verification spec. No damaged predictions were demonstrated. A new production helper or runtime guard remains a separate architectural proposal.

**Target guard — AGREE with deletion; qualify the replacement.** Remove lines 87 and 92–95. Fable is right that month-by-direction target totals suffice to check the denominator used here; band-level reconstruction is unnecessary. However, matching those totals and requiring shares between zero and one does **not** test the at-place numerator. Setting every membership flag to false would pass both assertions. Retain one hand-worked membership/weight check.

**Lead interpretation — AGREE with Fable’s correction; UNRESOLVED uncertainty calibration.** The runner-up is `loc100_tp50`; its direction-1 and largest-block shares are 90.91% and 48.05%. For `loc12_linear`, they are 71.36% and 22.07%. Name the comparator each time. Neither review establishes how much the bootstrap SEs underestimate uncertainty.

**Settings — AGREE that restoration is unnecessary.** The calculation uses frozen analysis settings and checksum-checked inputs. Checking a current configuration that it does not use adds nothing here.

**3. Errors in Fable’s review**

- **“All of the shortfall is in direction 1” is false.** In `far_at_place.csv`, December’s shares are **53.69%, 97.33% and 99.42%** for directions 1–3. Direction 1 dominates the shortfall.
- **The proposed `max(..., na.rm = TRUE)` assertion can miss failures.** A missing matched model or missing score is discarded. Explicitly match the 14 eligible models and require finite values before comparing.
- **Independent score recomputation does not catch every changed prediction file**, as the block example above demonstrates.
- **“Both reviewers … probably too small” overstates my recorded conclusion.** My previous reconciliation called the uncertainty uncalibrated and its understatement unresolved.
- **Eighteen lines is a subtotal of savings.** After removing the aggregate rows, line 121’s `direction == 'all'` selection becomes empty. Its replacement must be included in the final line count.

**4. Consolidated action list**

These recommendations do not constitute approval for additions.

**Script changes:** line numbers refer to [check_cv_far_cells.R](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tools/check_cv_far_cells.R).

| Lines | Change | Estimated saving |
|---|---|---:|
| 116–119 | Remove runner-up console section; retain approved CSV contributions. | 4 |
| 96–103 | Write only 36 month-by-direction rows using one aggregation and division. | 6 |
| 87, 92–95 | Remove distance calculation and new target guard. | 5 |
| 35–36 | Use `f$feasible & f$far_blocks >= CV_MIN_BLOCKS`; adjust 109–110. | 1 |
| 8–11 | Shorten repeated header explanation. | 2 |
| 48–49 | Restore protocol-2 eligibility across every required fit; update comment. | 0 |

Rewrite lines 120–121 to derive monthly and overall shares from **summed numerators and denominators**, preserving the requested summaries. Allow about two additional lines: **approximately 16 lines saved overall**. These changes leave this run’s scores unchanged.

**Spec assertions:**

1. Compare every candidate’s prediction identities and frozen columns using protocol 2’s existing geometry comparison.
2. Independently reproduce all 14 eligible far scores from the saved monthly distance table; require complete, finite matches.
3. Confirm direction and block contributions each sum to the corresponding excess MSE, retaining negative contributions.
4. Match far counts by holdout-month, not just their grand total; confirm 6,940 rows and all 36 scored combinations.
5. Match the 36 target-weight totals to `target.csv`; check the at-place numerator with known monthly membership. The previous hand case gives numerator `3/8`, denominator `5/8`, share **0.60**.
6. Check the exact 250-km boundary and zero-weight exclusion; run the two existing CV test files through `tools/verify_change.R`.

Allow roughly **35–45 spec lines**, **6 record corrections** and **15 verification-report lines**, separately from the script reduction: approximately **+40–50 net lines** overall. No new framework or test file is needed.

**Questions for Chris:**

- Should the nearby score choose with geographic transfer reported beside it, should both have to agree, or should the separated score choose? The present script changes no pipeline choice.
- Are buffered fits still wanted, and would their result report or choose? This rescore cannot predict their winner.
- If a separated score chooses, should the existing one-SE heuristic remain, with its sensitivity disclosed? Its calibration remains unresolved.
- Are the direction/block contribution tables approved? Their calculation occupies lines 61–75. They expose model-specific concentration that group counts cannot show; the simpler alternative is reporting existing coverage counts alone. Retaining the new target guard would also require explicit approval; deletion is recommended.

Update the existing living questions file’s stale “nothing is designed or run” statement and carry forward the two questions for Andria: which prediction claim selection should support, and whether the location effect’s seasonality fits her climate interpretation.

**Not worth doing:** a new bootstrap, monthly contribution output, regional veto, configurable distance framework or separate test file.

**Limits:** No R or pipeline execution. Binary contents, bootstrap results, named geographic cells and Fable’s 84% May/October claim were not independently regenerated.

Files read: both reviews, brief, rules, overview, protocols/decisions, questions/configuration, CV helpers/tests and saved CSVs; **48 read-only shell calls including delegation; no writes or web calls.**