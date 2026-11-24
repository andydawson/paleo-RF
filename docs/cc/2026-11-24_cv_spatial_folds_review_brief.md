# Brief: adversarial review of the chosen cross-validation method (protocol 3), before it is built

Given on 24 November 2026, the same packet to Fable (`science-reviewer` role) and to Astra (Codex, with that role
copied in). Neither reviewer took part in the design. Each reviews independently, then there is one reconciliation
round. Read only: nothing is built or run until the review is done.

## Chris's decisions, 24 November

Chris answered the design questions as follows:
- **The method:** the new score *chooses* the model, replacing protocol 2's score from nearby cells only. Protocol 2's
  choice stays on record. He asked whether the method had been reviewed adversarially; this review is the answer.
- **Geographic groups:** clusters of tail cells.
- **Buffer step:** approved. Correlogram plots of the residuals of the saved no-location fits; he will choose 100,
  250 or 500 km from them before any fold fit.

## The method under review

This is the joint recommendation as it stands after the reconciliation: section 4 of
`docs/cc/2026-11-23_cv_spatial_folds_reconciliation_codex_gpt6astra.md`, with the points both designers agreed in
`docs/cc/2026-11-23_cv_spatial_folds_reconciliation_fable.md`.

1. **Cover tails.** Keep protocol 2's three historical departure directions. Fix the cut of each tail at the 80th
   percentile; the 70/90 fallback goes.
2. **Geographic clusters.** Split each direction's tail cells into 4 compact geographic clusters with seeded k-means.
   The coordinates used still have to be specified: degrees are not kilometres.
3. **Each split** is one direction and one cluster:
   - **Test:** that cluster's tail cells.
   - **Training excludes:** the direction's whole tail, plus every cell within the buffer distance h of a tested cell.
4. **Two masks.** "Tested" and "excluded from training" become separate frozen fields. Today one `withheld` flag does
   both (`tools/cross_validate_albedo.R:114`).
5. **h** is fixed by Chris from correlograms of the saved no-location fits' residuals before any fold fit. The new
   step is about 30 lines.
6. **Score:** protocol 2's outside-hull target (12.8% of the hindcast weight) chooses, with the same grouping, frozen
   weights and squared error. Standard errors come from resampling 5-degree blocks. The one-standard-error rule
   applies. Feasibility is judged per split.
7. **Kept beside the score:**
   - the in-range holdout (24 fits);
   - the monthly tested-depth limits;
   - comparisons of each location size with no location at the same cover form;
   - additive block and cluster contributions to the paired differences.
8. **Deleted:** the comparison with protocol 1's membership (about 23 lines).
9. **Cost:** up to 2,160 main fits (4 x 3 x 12 x 15), plus up to 24, 360 and 192 for the in-range holdout, synthetic
   recovery and the winner's pipeline. That is against protocol 2's 540, which took 974 fit-minutes in total. About
   +1,200 / -150 lines, including records.

## Read

- The brief, the two designs and the two reconciliations, all `docs/cc/2026-11-23_cv_spatial_folds_*`.
- `docs/cc/2026-11-06_cv_protocol_v2.md` and the decisions of 2 November (`docs/cc/2026-11-02_cv_design_decisions.md`).
- The code: `R/cross_validation.R`, `R/cv_separation.R`, `tools/cross_validate_albedo.R`,
  `tools/check_cv_separation.R`, `R/hindcast_comparison.R`, `tools/compare_cv_hindcasts.R`, the tests and `config.R`.
- The protocol 2 outputs, read only:
  `/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2/`.

## Questions to press

1. Does a cell that is both outside the training cover range and at least h from training really measure what the
   hindcast needs? From March to September the hindcast predicts at the training cells' own places. Is the method
   too pessimistic for the location term, and does it then choose a model for the wrong reason?
2. After the buffer, is the outside-hull target still represented? Removing neighbours shrinks the training range of
   cover, so tested cells move to deeper cover bands. Which months and directions are likely to be infeasible in
   winter? (914 December rows against 748 coefficients in protocol 2.)
3. Are seeded k-means clusters of tail cells, made separately for each direction, sound units, given that blocks are
   resampled across overlapping holdouts?
4. Can a correlogram of no-location residuals, made from fits that include cover and elevation, set h? What does the
   literature this project relies on actually say? (Telford and Birks 2009; Trachsel and Telford 2016; Roberts et al.
   2017.)
5. Is there a simpler method that answers Chris's request just as well? Which parts are not worth building?
6. Any error in the designers' numbers or claims.

Findings carry file and line, consequence, evidence and a proposed check. Each says how many lines its fix adds or
removes. Useful deletions come first, and there is a "not worth doing" section. Plain words; no time estimates beyond
measured runtimes. Chris's general rules on simplicity and architectural additions were included in each reviewer's
prompt.
