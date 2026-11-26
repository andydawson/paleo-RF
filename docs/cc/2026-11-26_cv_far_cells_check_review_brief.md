# Brief: review of the no-fit far-cell check (`tools/check_cv_far_cells.R`, commit 79de462)

26 November 2026. The same packet goes to Fable (`science-reviewer`) and Astra (Codex, with that role), independently,
then one reconciliation round. Read only.

**What it is for.** Chris's decision 1 (`docs/cc/2026-11-26_cv_spatial_folds_decisions.md`) asks, before any buffered
fit, for a score of protocol 2's saved withheld predictions on cells 250 km or more from training, with the protocol's
own machinery. It also asks for the area-weighted share of the past outside-range target at a fitted cell's own place.
Its result decides whether the separated score should choose the model.

**What to read.**
- The script: `tools/check_cv_far_cells.R`, 121 lines.
- What it reuses: `R/cross_validation.R`, and the score stage of `tools/cross_validate_albedo.R`.
- The protocol: `docs/cc/2026-11-06_cv_protocol_v2.md`.
- The two review reconciliations: `docs/cc/2026-11-24_cv_spatial_folds_review_reconciliation_*.md`, which say what
  the check must show and which errors to avoid.

**What the implementer reported.**
- It ran on `/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts` in 20 s.
- With the condition switched to less than 250 km it reproduced protocol 2's saved `scores.csv` exactly.
- First outputs are in `/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/farcheck/`.
  They show:
  - All 36 holdout-months are feasible on far cells.
  - `loc100_linear` leads the far score and is chosen.
  - `loc12_linear` is 1.56 standard errors behind.
  - Over the runner-up, 91% of the margin comes from direction 1, and 48% from one Alaska block.
  - 93.9% of the outside-range target sits at a fitted cell's own place: 99.5% from March to September, 77-81% from
    November to January.
- Departures from protocol 2 that it named:
  - The settings check and the geometry check are skipped.
  - The per-cell target is rebuilt inline, guarded by a new `stop()`.
  - Eligibility is judged over the far-scored months.

**Press on these.**
1. Is it the same score as protocol 2, except for the distance condition?
2. Are the far rows selected correctly?
3. Are the block and direction shares additive and correctly signed?
4. Is "at a fitted cell's own place" computed with the right weights and the right calibration cells for each month?
5. Do the skipped checks matter?
6. Is the new guard needed?
7. What can these numbers support and not support for Chris's decision?
8. What could go, to make it shorter?

Findings carry file and line, consequence, evidence and a proposed check, with the lines each fix adds or removes.
Deletions come first. Include a "not worth doing" section. Plain words; no time estimates.
