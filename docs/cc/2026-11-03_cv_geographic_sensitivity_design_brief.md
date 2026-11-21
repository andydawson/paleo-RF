# Design request for Astra: separating the geographic penalty from cover-extrapolation skill in the cross-validation

You are Astra, designing for Chris McWilliams (paleo-RF, Andria Dawson's R code). Read-only: do not edit files. Web
search allowed; ground every method in published practice and cite it with DOIs; say plainly where a step is our own
adaptation. Plain words. Keep it simple: the project's rule is simple, concise code with no bloat.

## The problem (your own finding)
In `docs/cc/2026-11-03_cv_northeast_question_codex_gpt6astra.md` you found that the holdout matching the northeast's
departure (d2, less open land) withholds 82 of the 83 northeast cells, so every candidate must predict 167 / 340 / 524 km
(10th / 50th / 90th percentile) from its nearest training cell, whereas the hindcast predicts at the training cells' own
places. "A location-dependent model can lose partly because it must predict across a geographic hole; a no-location model
might benefit from that particular test." Chris asked whether the CV approach should be fixed rather than the caution
merely recorded. My answer to him: it cannot be removed, because unusual cover mixes are clustered in space (withholding
only some of them puts the mix back inside the training range), but the geographic part could be measured separately;
the protocol already has an in-range holdout (a seeded fifth of the 5x5-degree blocks withheld with no cover cut, for
model 8 and the chosen model only, reported, never used to choose). Chris chose: you design how to separate each
candidate's geographic penalty from its cover-extrapolation skill, Fable reviews, Chris decides before any fit.

## Read
In this checkout (branch cv-design): `docs/cc/2026-11-02_cv_protocol.md` (all, including the amendments and the
northeast section), `docs/cc/2026-11-02_cv_design_decisions.md` (items 1-14), `R/cross_validation.R`,
`tools/cross_validate_albedo.R`, `R/model_registry.R`, the design record (`docs/cc/2026-11-02_cv_design_codex_gpt6astra.md`,
`_review_fable.md`, `_reconciliation_codex_gpt6astra.md`), the code reviews in `docs/cc/2026-11-02_cv_code_review/`,
and your northeast answer. The verified holdout outputs of run 1's data are in
`/home/expert/Documents/contracting/Andria/paleo-RF-verify/11356e0/.rundirs/cv-holdouts-7/` (read-only; no model has
been fitted yet).

## What to design
1. **Whether it is worth doing at all**: what the geographic hole can do to the choice (which candidates it favours or
   penalises, and by how much it could matter), and whether the existing design (one standard error rule, paired
   differences, block bootstrap) already limits the harm. If the honest answer is "measure and report, do not change the
   rule", say so.
2. **Options, simplest first**, each with its published basis, what it costs (extra fits: the candidates are 13, months
   12; each fit takes minutes to hours), what it changes in the choice, and its risks. Candidates you might weigh:
   - the in-range holdout for all candidates, reported beside the choice;
   - a rule that uses it (for example, judging each candidate's cover-tail score relative to its own in-range
     geographic score at matched distance to training cells; or requiring the chosen model to be within one standard
     error of the best in-range score too);
   - matching the in-range holdout's geographic distances to those of the cover-tail holdouts (as in kNNDM,
     Linnenbrink et al. 2024), so the two scores differ in cover extrapolation, not in distance;
   - anything better you find.
3. **Your recommendation**, with the exact protocol text it would add (short), the code it needs (functions, files,
   lines; as little as possible), the tests (hand-worked cases), and how it is verified. It must be fixed before any
   score is seen and must not use the hemlock sign.

## Output
A markdown design for Chris: summary of at most ten lines; sections 1-3; what Chris must decide; references with DOIs.
Do not give time estimates.
