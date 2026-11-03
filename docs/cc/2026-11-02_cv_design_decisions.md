# Cross-validation design for the albedo model: Chris's decisions (2 November 2026)

**Benefit to the paper:** the albedo model is chosen on measured skill where the hindcast needs it, on land-cover
mixes beyond the modern range and on how albedo changes with cover, so the paper can state that skill (or its
absence) instead of only flagging the extrapolated cells.

Sources, all on branch `cv-design`: the brief (`2026-11-02_cv_design_brief.md`); Astra's design
(`2026-11-02_cv_design_codex_gpt6astra.md`, GPT-6-Astra, ultra effort); Fable's independent review
(`2026-11-02_cv_design_review_fable.md`); Astra's reconciliation
(`2026-11-02_cv_design_reconciliation_codex_gpt6astra.md`); Astra on scoring change
(`2026-11-02_cv_design_change_score_brief.md`, `2026-11-02_cv_design_change_score_codex_gpt6astra.md`).
Only explicit choices are recorded as Chris's decisions.

## Decided by Chris

1. **Aim (brief).** Cross-validation that handles space correctly and makes each validation fold differ in land
   cover from its training data, so that it imitates the hindcast's departure from the modern data; used to
   choose the model and to show the effect on the hindcast.
2. **The hemlock-decline sign is an outcome, not a target.** Folds, candidates and the selection rule are fixed
   before any score is seen; the northeast 6 to 4.5 ka sign is reported afterwards and never used to choose.
3. **Scope:** the folds and the model choice (candidates beyond today's eight allowed).
4. **Web search** allowed for the design work.
5. **Independent review:** Fable reviewed Astra's design; Astra answered in one reconciliation round.
6. **Skill inside the training range is reported, not mixed into the selection score.**
7. **Accepted, as agreed by both reviewers after reconciliation:** no geographic buffers (the hindcast predicts
   at the training cells' own locations); models 1 and 2 (no cover term) are baselines only, never chosen; two
   added candidates (model 8 with a coarser location term, and model 8 with a smaller two-dimensional cover
   term); no reserved assessment blocks (the result is a selection score); simplicity order fixed in advance by
   coefficient count; the one-standard-error rule only with at least 10 geographic blocks per direction;
   testable months and directions declared from the data before any fit.
8. **The score that chooses the model: error in predicted albedo** on the withheld cover-tail cells (Chris,
   later on 2 November: "for simplicity at this stage, we should focus on getting accurate albedo predictions,
   and then maybe discuss change and the literature around it in the discussion"). This replaces his earlier
   choice the same day of Astra's paired-change rule (matched pairs of withheld cells, with albedo error as the
   fallback); no pair score is built for now. For the paper's discussion: judging models on change rather than
   state (Rapacciuolo et al. 2012, PLoS ONE, 10.1371/journal.pone.0040212; Rapacciuolo et al. 2014, Methods in
   Ecology and Evolution, 10.1111/2041-210X.12181; Piirainen et al. 2023, Diversity and Distributions,
   10.1111/ddi.13687), choosing models on matched held-out differences (Rolling and Yang 2014, JRSS B,
   10.1111/rssb.12043) and judging albedo differences from spatial contrasts (Lejeune et al. 2020, Earth System
   Dynamics, 10.5194/esd-11-1209-2020); identities checked by Astra, not yet by the reference audit.

## After the code reviews (Chris, 2-3 November)

Both code reviews (`2026-11-02_cv_code_review/`) and Fable's reconciliation found no leakage and no error in the
score arithmetic, and asked for fixes before any fit, plus decisions:

9. **Target area: the forcing's cells only** (27-74 N, as script 8 uses), not every past cell.
10. **Accepted as coded, with the reviewers' agreed fixes made:** weights equal per slice and month before
    restricting to out-of-range mixes; the in-range holdout is one fifth of the blocks, withheld once; script 7a's
    adjusted ice fractions, missing ones dropped and counted; no splitting of a cell's weight across holdouts;
    convergence is the fitting loop stopping before its limit plus full convergence of the smoothing-parameter
    optimiser.
11. **Cut rule:** the 80th percentile everywhere; a month that fails is reported untested; the 70th, then the
    90th, only for a direction that fails in every month.
12. **A withheld cell's error counts under the direction in which it lies outside its own fold's training range**
    (as the past mixes are grouped), not its holdout's (Chris, 3 November, frozen before any score). Chris asked
    whether this leaks hindcast information into training; Astra (ultra effort,
    `2026-11-02_cv_code_review/direction_astra.md`): no, neither option is leakage; past cover shapes the folds by
    design, no withheld albedo enters its own fold's fit, and no past albedo or prediction is used. The number of
    cells whose direction differs from their holdout's is reported, never used to switch rules.

## Filed for future work (Chris: drop for now)

- **Scoring predicted change with matched pairs of withheld cells** (Fable; Astra's revised rule), as above.
- **Testing against real change in the satellite era.** Score the model on 1-degree cells whose land cover
  really changed (harvest, fire, regrowth) during the MODIS years, against the observed albedo change
  corrected with nearby unchanged cells (as in Wang, Yue and Luyssaert 2023). Needs new cover data mapped to the
  pollen cover types (US annual NLCD, the Canadian annual forest series, or boreal canopy and deciduous
  fractions; not MODIS's own land-cover labels, which their producers advise against differencing) and
  before-and-after albedo. Not known whether enough cells changed enough. Astra's notes:
  `2026-11-02_cv_design_change_score_codex_gpt6astra.md`, section 3.

## Next

The protocol, approved by Chris on 2 November with its four open points (run 1 data; weights by area times
the ice-free fraction; 5 x 5 degree blocks; fits after the refit queue): `2026-11-02_cv_protocol.md`.
