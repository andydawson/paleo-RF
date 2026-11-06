*Fable (science-reviewer role), 6 November 2026: review of commit 10c1886 (CV protocol 2 implementation, written by
Astra). Read-only, no R run. Summary filed by the main session.*

**Verdict.** No blocker: the code implements protocol 2 as written and the hand-checked arithmetic agrees (selection
score with the 250 km filter, delta-method SE, synthetic generator and null contrast, feasibility). Ready to run
after Chris decides how the thin-plate concurvity is reported, with a few line-removing trims that change no result.
The first run stays reproducible (new outputs in `output/cross_validation_v2/`; run 1's specs untouched). The tests
cover the protocol's verification list without material duplication. Run1-main's analysis settings match
`config.R` field by field, so the model-8 reuse check will pass.

**Findings.**
1. Should-fix (reporting): pairwise concurvity for the ten thin-plate configurations is numerically meaningless.
   The cause is in the model, not the call: OL + ET + ST = 1 exactly, so the thin-plate cover basis is exactly
   rank-deficient (its polynomial null space of 10 columns has rank 6 on a plane). mgcv fits such a model, but
   `concurvity()` divides by near-zero diagonals, hence 4.36 one way and 0.9995 the other. The linear-cover values
   are fine. Check: `fit$rank` against `length(coef(fit))` on the saved April model-8 fit. Options: (a) add rank and
   coefficient-count columns beside concurvity, with a caveat (+2 lines); (b) NA for thin-plate forms, with the reason.
   Must be settled before the capacity jobs run (they discard their fits). Chris decides.
2. Nit: `month_capacity` duplicates the historical exchange (-6 lines, removes duplicate CSV rows).
3. Nit: fixed interpretation prose written by code (`selection_notes.txt`, `interpretation.txt`) belongs in the run
   report; keep the numeric lines (-20 lines).
4. Nit: the twelve in-range specs could be four (-8 files).
5. Nit: make the "ET and ST at least 0.05" rule visible with one comment.
6. Nit: two record writers; `write_record` could take extra lines (-6 lines).
7. Nit, optional: `predicted_nearby_depth.csv` repeats `nearby_depth.csv` (-5 lines).

**Verification additions.** The rank check of finding 1; a logit-scale invariant for linear-cover configurations
(0.1(beta_ET - beta_ST) at every cell); one end-to-end hand number through the score stage; a test of "outside if
either endpoint is outside"; watch the holdouts spec's `identical()` against run 1 (attributes only could fail it).

**For Chris.** Concurvity reporting (a or b); four or twelve in-range jobs; prose in code or in the report.
