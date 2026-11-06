*Fable (science-reviewer role), 6 November 2026: review of Astra's CV redesign
(`2026-11-06_cv_redesign_codex_gpt6astra.md`). Read-only.*

**Verdict.** The 4 x 3 grid and the distance grading are right in kind and reuse the existing code, but do not build
the design as written. The tuning objective it keeps rewards geographic transfer, which the hindcast never performs:
the first winner's whole advantage lies 250 km or more from any training cell, and it is worse where the hindcast
predicts and in the northeast. Nesting is the largest block of new code and answers a question Chris did not ask.
The recovery experiment can only answer a conditional question, and the cheap real-data test of whether the cover
effect is stable across location capacities is missing.

**Hand check.** One synthetic northeast cell under Astra's generator (truth b = -0.5): ten points more evergreen
darkens by 0.013, as stated. Under this generator the linear-cover configurations are the true model (the
thin-plate null space contains linear functions). An exchange of 0.10 between any two classes moves 0.10 on the
triangle.

**Findings.**
1. **Decide before fitting: the tuning objective scores geographic transfer, not cover extrapolation at known
   places.** `by_distance.csv`: 31% of the score's weight lies within 100 km of a training cell, 41% at 100-250 km,
   22% at 250-500 km and 6% beyond; the hindcast predicts at 0 km. Paired MSE difference of `mod8_coarse_loc` from
   `mod8`: significantly worse within 100 km (+0.0012, se 0.0003; +0.0013, se 0.0007); the overall win (-0.0029)
   comes entirely from cells 250 km or more from training. In the deepest cover band (beyond 0.10, where the
   northeast's 4.5 ka mixes sit) the coarse model is worse at every distance. Northeast, less-open-land holdout:
   April RMSE 0.085 against 0.031; May 0.060 against 0.042. A 12-configuration search on this objective will again
   pick the coarsest location term for crossing geographic gaps. Proposed: score withheld cells within 250 km of a
   training cell (65% of the present weight), with far cells reported beside (about 2 lines). The 3 November rule
   (the choice stands even if the advantage is far from training) was for the first run; the new protocol reopens
   it. Chris decides.
2. **Add the real-data test.** The recovery experiment answers "could a model of this class allocate correctly if
   the world were like truth T". Truths 1-3 use a straight-line latitude truth that every location term represents,
   with a continent-wide evergreen-latitude correlation of 0.04, so only the no-location configurations fail, which
   is known. Truth 4's misallocation depends on an arbitrary pattern. Add, for April and May, all 12 configurations
   on the full data (24 fits). At the northeast cells report the historical-size exchange contrast with its
   standard error (lpmatrix and Vp), and the concurvity between the location and cover terms. If the contrast's
   sign and size move with location capacity, the data do not determine the split and no cross-validation can; if
   stable, they do. About 20 lines. Keep the simulation as the capability check.
3. **The grid does not bracket the location optimum** (k = 30 beat 500; absent lost): add k of about 12 (+3
   configurations).
4. **Simplicity: nesting.** The 72 outer refits are the single-level fits. December's inner training sets fall
   below the largest configuration's 748 coefficients. Nesting needs two masks, an inner feasibility path and
   per-outer records. What it buys, an RMSE free of selection optimism, serves the paper's reported number, not
   Chris's questions; the optimism is about one standard error. Recommend a single level, with the score labelled a
   selection score and that one sentence of quantification; nest only if a referee asks. Removes about 1,368 fits
   and the largest block of new code. Chris decides.
5. **Fix the recovery reading before fitting**, for example: sign recovered in at least 18 of 20 replicates and
   |bias| at most half the true contrast; a null invented contrast at most a quarter of the b = -0.5 contrast; a
   configuration that fails cannot carry the northeast sign claim; selection unaffected. Chris sets the thresholds.
6. Nit: truth 3 (+0.5) adds little; the null already measures the allocation error (-120 fits).
7. Nit: state that under a linear truth the linear configurations are the true model.
8. Nit: if nesting stays, use the outer cut rule.
9. Nit: write the new registry entries out, ids naming both axes (for example `loc100_tp50`); state the tie-break
   order.
10. Nit: pool months in the distance report; record the maximum tested distance per holdout (the 0.112 limit is in
    no saved table).
11. Nit: model 8's full-data fit and pipeline already exist (run 1): -12 fits.

**Verification additions.** The contrast-against-capacity profile and its invariants; the same rows for every
configuration under the km filter; seeded synthetic data identical across configurations; the location term's
effective degrees of freedom per fit.

**Compute (measured, one thread per fit).** Model 7 (gp cover) 11-242 min, the bulk of the first run and absent from
the new grid; model 8 3.7-9.3 min (December 20); lin_cover 1.4-2.7; mod8_coarse_loc 0.5-1.4; cover_elev 0.2-0.5;
mod8_small_cover 2.1-4.2. The whole first CV ran from 15:12 UTC on 4 November to 14:13 on 5 November at up to six
jobs. Every configuration in the new grid is cheap; the case against nesting is code and December feasibility, not
compute.

**Questions.** Chris: the objective (all cells, or within 250 km); nesting; recovery thresholds, truth 3, the
k of about 12 row. Andria: is a common cover response across regions acceptable for reading the northeast?
