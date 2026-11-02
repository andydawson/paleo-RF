# Design brief: cross-validation that tests and improves how the albedo model generalizes (2 November 2026)

You are Astra, asked by Chris McWilliams (contractor on Andria Dawson's paleo-RF project) to **design** a
cross-validation approach for the albedo prediction model. Design only: no code changes, no runs.

## Working rules
- Read-only. You may and should run read-only commands to read the repository (git log/diff/show, rg, grep,
  cat, sed -n, ls, wc). Do not run R, the pipeline scripts, or anything that writes files.
- The repository root is the current directory, branch `feature/single-config`. Read `AGENTS.md` and
  `CONTRIBUTING.md` first.
- Web search is allowed for published methods. Ground every method in published practice and cite it
  (authors, year, venue, DOI where you have it); say plainly when something is your own proposal with no
  published precedent. Never invent a reference.
- Plain words, for a reader who is a scientist but not a statistician. No private shorthand or question ids.
- The code must stay as simple and concise as possible: no bloat, no overcomplicating. Andria must be able to
  read it. Prefer a design that a few clear functions in `R/` and one option in the configuration can carry.

## What the model is and where it is used
- Scripts 4-6 fit generalized additive models (mgcv) of monthly blue-sky albedo on land-cover fractions
  (evergreen, deciduous, open land and others; see `R/model_registry.R`, `scripts/4_calibration_model.R`),
  with a spatial (location) term in the larger models. Model 8 is the prediction model; script 6 predicts past
  albedo from pollen-based land-cover reconstructions (REVEALS, interpolated), and scripts 7-10 turn the
  albedo differences into radiative forcing.
- Training ("calibration") cells are modern grid cells; the hindcast cells are the same region in the past.
  The calibration table is built by script 2; the refit now uses MODIS cell means (`data/albedo_modis_cells.csv`).
- Existing pieces to read: `scripts/6_prediction_model_spatial_eval.R` (an earlier spatial evaluation),
  `R/training_support.R`, `tools/plotting/plot_training_support.R`,
  `tools/plotting/plot_forcing_vs_training_support.R`, `tools/plotting/plot_northeast_cover_and_location.R`,
  the scientific questions file `docs/cc/questions_for_andria_scientific.md` (search "cross-validation" and
  "spatial term"), the refit plan and decisions (`docs/cc/2026-10-29_refit_plan_*.md`), and the changelog
  `docs/cc/changelog_single_config_migration.md` (the training-support and northeast entries).

## The problem
- Recent analysis showed that some hindcast land-cover mixes lie outside the range of the training data. The
  clearest case is the northeast, where past evergreen cover reaches levels not represented among the modern
  training cells. That matters most for the hemlock decline (the mid-Holocene collapse of hemlock, roughly
  6 to 4.5 ka): losing evergreen cover should brighten the land surface (higher albedo) and so cool, but the
  current model attributes warming to that period in the northeast. One possible cause is that the model is
  extrapolating, with the location term and the cover terms sharing the signal in a way the training data
  cannot separate.
- Random cross-validation would overstate skill because neighbouring cells are alike. Spatially blocked
  cross-validation handles that, but it still does not test what the hindcast does: predict for land-cover
  mixes unlike those seen in training.

## What Chris wants
1. A cross-validation design that **handles space correctly and also makes each validation fold differ in
   land-cover mix from its training folds**, so that it imitates the shift from the modern training cells to
   the hindcast cells. The design should say how to measure that difference and how to check that the folds
   really reproduce the hindcast's departure from the training data (for example, by comparing the distance
   from validation cells to training cells with the distance from hindcast cells to training cells).
2. Use of that cross-validation to **choose the model**: today's eight models, plus simpler or constrained
   versions that you propose and justify from the literature (for example limits on the shape or flexibility of
   the cover terms, or different handling of the location term). Say what each candidate is meant to fix.
3. A way to **demonstrate** the result: how much skill the chosen model keeps on out-of-range data compared
   with model 8, and how the choice changes the hindcast and the forcing, including in the northeast.

## Chris's decisions for this design (2 November)
- **The hemlock-decline sign is an outcome, not a target.** The folds, the candidate models and the rule for
  choosing between them must be fixed in advance and judged only on out-of-range predictive skill. The 6 to
  4.5 ka sign in the northeast is reported afterwards. Say what result would count as evidence that the
  current warming is an extrapolation artefact, and what would count against that, and do not use the sign to
  choose the model.
- **Scope:** the folds and model choice (not only the folds).
- **Web search:** allowed, as above.

## What to deliver (one Markdown document, your final answer)
1. One sentence on the benefit to the paper or to Andria's use of the code.
2. Short summary of the recommended design, in plain words.
3. Published methods relevant here (spatial blocking, blocking or clustering in the space of the predictors,
   methods that match validation distances to prediction distances, area-of-applicability or similar
   diagnostics, and anything else you find), what each does, and which you recommend and why.
4. The fold design in detail: what space and what land-cover distance, how folds are formed, how many, how
   months are handled (separate per month, or shared folds), how to check the folds against the hindcast's
   departure from training, and what to do where the hindcast lies beyond anything the folds can test.
5. The candidate models and the pre-specified selection rule (which score, which tie-break, and how the
   simplest adequate model wins).
6. How to demonstrate the effect on the hindcast and the forcing, including the northeast and the hemlock
   decline, and the evidence for and against an extrapolation artefact.
7. How it fits the existing pipeline with the least code: which scripts and functions change or are added, and
   one configuration option if needed. Note the compute cost: one month's eight-model fit takes from tens of
   minutes to several hours on one core; the workstation has 48 cores, and other runs share it.
8. Risks, limits and what cannot be learned this way.
9. Open questions for Chris or Andria, each with your recommendation.
