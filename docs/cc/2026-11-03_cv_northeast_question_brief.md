# Question for Astra: can our cross-validation fix the northeast problem?

You are Astra, reviewing for Chris McWilliams, who maintains Andria Dawson's paleo-RF R code. Read-only: do not edit
files. Web search is allowed; ground every methodological claim in published practice and cite it. Plain words; no
private shorthand or question ids.

## Chris's question
Is it possible that our cross-validation approach will fix the northeast problem diagnosed below? If yes, how and how
far; if no, or only partly, why, and what would be needed besides. Be concrete and sceptical.

## The northeast problem (diagnosed 20-28 October)
Read section 1 of `docs/cc/questions_for_andria_scientific_from_2026-10-20.md` and your own interpretation
`docs/cc/2026-10-20_northeast_cover_effect_interpretation_codex_gpt6astra.md`. In short: in the northeast box
(80-66 W, 40-48 N, 83 cells), the hemlock decline (evergreen 0.40 to 0.22, summergreen 0.54 to 0.73, open land about
0.05-0.06, 6 to 4.5 ka) is predicted to DARKEN the surface, giving local warming, where conifer-to-deciduous change is
normally expected to brighten it. In today's data in the box, evergreen share follows latitude (r = 0.92); with
latitude held fixed the evergreen effect is not identifiable (+0.003, s.e. 0.003 per 0.1 evergreen); refitting May
without the location term flips the change from -0.095 to +0.042 but explained deviance falls from 97% to 67%. The past
mixes there have very little open land and lie outside today's range of mixes (100% of box cells at 4.5 ka); the
evergreen share itself is within today's range. Diagnostic tool: `tools/plotting/plot_northeast_cover_and_location.R`.

New today (3 November), the summed 6 to 4.5 ka change over the box (area-weighted box means, partial ice, vegetation
change only there), from the refit runs with the selected model (model 8: location gp smooth k=500 + elevation smooth +
a 3-D cover smooth):
| Run | albedo change | forcing HadGEM3 W/m2 | CAM5 W/m2 |
|---|---|---|---|
| 8: Andria's 0.25-degree raster (water mixed in) | -0.035 | +5.5 | +5.3 |
| 1: rebuilt land-only MODIS albedo, all days | -0.012 | +3.5 | +3.1 |
| 2: rebuilt land-only MODIS albedo, snow-free days only | -0.018 | +2.5 | +2.4 |
Every 500-year step is positive in every run. So the land-only albedo shrinks the darkening and snow-free days shrink
the forcing, but none reverses it.

## The cross-validation approach (approved by Chris; no model fitted yet)
This checkout (branch cv-design). Read:
- `docs/cc/2026-11-02_cv_protocol.md` (with the 3 November amendments at the end) and
  `docs/cc/2026-11-02_cv_design_decisions.md` (items 1-13, and what was filed for future work);
- `R/cross_validation.R`, `tools/cross_validate_albedo.R`, `R/model_registry.R` (the 13 candidates and which can be
  chosen), `R/training_support.R`;
- the design record: `docs/cc/2026-11-02_cv_design_codex_gpt6astra.md`, `_review_fable.md`,
  `_reconciliation_codex_gpt6astra.md`, and `docs/cc/2026-11-02_cv_code_review/`.
In short: directional cover-tail holdouts (each withholds, in every month, the modern cells beyond the 80th percentile
in one of three directions in which past mixes leave today's range); errors in predicted albedo on the withheld cells
grouped by month, the cell's own departure direction and distance band, weighted by the hindcast's target weight;
5x5-degree block bootstrap; the simplest eligible model within one standard error of the best is chosen. The holdout
stage has run on run 1's data: directions -68.8 deg (47% of the outside weight), 17.2 deg (45%), 156.5 deg (7%); all
36 holdout-months feasible. Chris decided the hemlock sign is an outcome to report, not a target.

## What to answer
1. **Can it fix it?** Would the cross-validation, as designed, be able to (a) detect that model 8's northeast
   behaviour generalises badly, and (b) choose a candidate that behaves better there? Consider: which of the three
   directions, if any, matches the northeast's departure (low open land, the evergreen/summergreen swap); whether
   withheld modern cells at the far end of that direction resemble the northeast's situation (same confounding of
   cover with latitude? same distance outside?); whether a holdout can test the identifiability problem at all, given
   that the problem is confounding of cover with location inside today's data rather than extrapolation alone; and
   whether the candidate list contains a model that could behave differently there (for example the coarse-location
   or no-location ones).
2. **What it cannot do.** Be explicit about what a scored error on modern withheld cells can and cannot tell us about a
   past cover change at fixed locations; cite the literature on spatial confounding, extrapolation and
   area-of-applicability (for example Hodges and Reich 2010; Paciorek 2010; Meyer and Pebesma 2021; Roberts et al.
   2017; Ploton et al. 2020; Wadoux et al. 2021), checking each claim you attribute.
3. **What would help**, simply and in proportion: changes or additions to the protocol (each with its benefit to the
   paper, its cost, and whether it would breach the protocol's rule that nothing is changed after seeing scores), or
   evidence outside the cross-validation (for example independent observations of conifer versus deciduous albedo in
   the northeast, a constrained or physically signed cover effect, reporting the northeast as unsupported). Say which
   you would do first.
4. **A verdict** in one paragraph Chris can act on: "yes", "partly" or "no", and why.

## Output
A markdown report: a summary of at most ten lines; one section per question above with file and line references and
references (with DOIs); a short list of recommendations ranked by benefit to the paper.
