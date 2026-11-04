# Cross-validation protocol for choosing the albedo model: approved by Chris (2 November 2026)

**Benefit to the paper:** the albedo model is chosen on measured accuracy for land-cover mixes beyond the modern
range, which is where the hindcast extrapolates, so the paper can state that accuracy.

Built from Chris's decisions (`2026-11-02_cv_design_decisions.md`) and Astra's reconciled design
(`2026-11-02_cv_design_reconciliation_codex_gpt6astra.md`, "revised design"). Chris approved the four open points on
2 November (data, weights, block size, scheduling). This protocol is frozen: nothing in it changes after the first model
score is seen. Known before freezing, and stated here so no one can say it was hidden: on the 18 October raster
run, the model without the location term (`cover_elev`) gave the opposite northeast sign to model 8 (changelog,
northeast entry).

## 1. Inputs
- Calibration table and settings of the main refit (run 1: MODIS cells, all days, full_75 version), code at
  the commit the protocol is frozen on.
- Hindcast cover: the configured time slices except the modern 50 BP slice.

## 2. What the folds must imitate (the target)
- The hindcast cell-slices whose cover mix lies outside that month's training range (outside the convex hull of
  the training mixes on the cover triangle, `R/training_support.R`).
- Weights: each historical slice and each month equally; within a slice, by cell area times the ice-free
  fraction (ice-covered cells carry little vegetation albedo).

## 3. Holdouts (made once, before any fit, by a seeded script)
1. **Cover distance:** distance on the existing cover triangle (`cover_triangle_xy()`); 0.10 means ten
   percentage points of one cover type swapped for another.
2. **Directions:** for every outside-range hindcast mix, the direction from the nearest point of the training
   range; grouped into at most three broad directions (for example "more evergreen, less open land"). A plot of
   all directions is saved so that no small group is lost silently.
3. **One holdout per direction:** order the modern cells along that direction; the cells beyond the 80th
   percentile are withheld from training everywhere, in every month; the model is trained on the rest and scored
   on all withheld cells that have that month's albedo. The 70th or 90th percentile is used instead only if the
   80th fails the feasibility rules below; that choice is made from the cover data alone.
4. **No geographic buffers, no reserved blocks.**
5. **Geographic blocks**, used only to measure uncertainty (not to separate training from validation): squares
   of 5 x 5 one-degree cells.

## 4. Feasibility, declared before any fit
- For each month and holdout: training rows at least the coefficient count of the largest candidate (script 4's
  existing rule), and withheld cells in at least 10 geographic blocks. A month or direction that fails is
  reported as untested; it is not rescued by changing the cut, the models or the rows.
- The table of training rows, withheld cells and blocks per month and holdout, the direction plot and the
  comparison of distances (withheld cells to their training data, against hindcast cells to the full training
  data, in cover and in space) are brought to Chris before fitting.

## 5. Candidates (13; 11 can be chosen)

| Id | Formula (beta, logit link, one fit per month) | Role |
|---|---|---|
| mod1, mod2 | location; location + elevation | baselines only: no cover term |
| mod3 to mod8 | today's ladder, unchanged | candidates; mod8 is the comparator |
| cover_elev | elevation + tp(OL, ET, ST), no location | candidate |
| lin_cover | location + elevation + ET + ST (straight-line cover terms) | new candidate |
| lin_cover_noloc | elevation + ET + ST | new candidate |
| mod8_coarse_loc | model 8 with location k = 30 instead of 500 | new candidate |
| mod8_small_cover | model 8 with a two-dimensional cover smooth on the triangle coordinates, k = 50 | new candidate |

- Fitted by REML (predictions are compared, not likelihoods), with the existing fitting controls; one retry at
  2,000 steps for a fit that does not converge; a candidate still not converged in any required fold cannot be
  chosen. If model 8 fails, the comparison is reported as incomplete.

## 6. Score and choice
- **Score:** mean squared error of predicted albedo (response scale, the fitted mean, no simulations) on the
  withheld cells, weighted by the target weights of section 2 across month, direction and distance band
  (0-0.02, 0.02-0.05, 0.05-0.10, beyond 0.10); reported as its square root (RMSE), with the share of the target
  it represents.
- **Choice:** the lowest score wins, unless a simpler candidate is within one standard error of the paired
  difference; the standard error comes from resampling the geographic blocks (1,000 resamples, months kept
  together, seed derived and recorded). Simpler means fewer coefficients, then registry order. One model
  structure for all testable months; it is applied to the untested months and said to be.
- **Reported beside it, never used to choose:** monthly RMSE, mean signed error, error against evergreen share at
  low open land, and skill inside the training range (one extra holdout with no cover cut: a fifth of the
  geographic blocks, chosen with a recorded seed, withheld in turn; chosen model and model 8 only).

## 7. Afterwards: the effect on the hindcast
- The chosen model and model 8 are fitted on all the data and run through the existing pipeline (scripts 4 to
  10) in separate run folders.
- Compared: albedo and forcing maps and series, and the northeast (80-66 W, 40-48 N) from 6 to 4.5 ka as the sum
  of the three 500-year steps, every month; the share of each result resting on tested versus untested cover
  mixes.
- Reading it: better accuracy on the relevant withheld mixes together with weaker or reversed northeast warming
  supports an extrapolation artefact; model 8 as accurate as the alternative, with the warming persisting,
  argues against it; a sign change alone shows neither.

## 8. Code (as small as possible)
- `R/cross_validation.R`: three functions (make the holdout table, score predictions, apply the choice rule).
- `tools/cross_validate_albedo.R`: the driver (one holdout, month and candidate at a time, existing fitting
  function, saves memberships, predictions and scores).
- `R/model_registry.R`: the four new formulas; `SPATIAL_MODELS` written out as today's seven so that script 4
  does not start fitting the new ones; a `CV_MODELS` list of the thirteen.
- `R/config_schema.R`: allow the chosen id as `model_id`; the northeast figure tool: accept a model other than 8.
- Tests: no training row beyond the cut; every withheld row outside its training range; the same rows for every
  candidate; distance function against a hand-worked case; the choice rule on made-up scores with a known
  answer; the same holdout table from the same seed.
- Reviews and verification as for any scientific change (Fable and Astra; `tools/verify_change.R`).

## 9. Compute
- At most 3 holdouts x 13 candidates x 12 months = 468 fits, plus 24 for the in-range holdout and 24 full-data
  refits, before retries. The first batch is measured before the rest is scheduled.
- Shares the workstation with the refit queue: the cross-validation fits start after the refit queue has finished, within the
  existing limit of four jobs at once.

## Amendments before any model is fitted (Chris, 3 November 2026)

Made after the code reviews, before any fold fit or score (`2026-11-02_cv_design_decisions.md`, items 9-12):
- Section 2: the target is the past cell-slices in the forcing's latitude window (27-74 N, script 8), with an area
  and an ice fraction; weights are equal per slice and month before the restriction to mixes outside the range.
- Section 3: the cut is the 80th percentile in every direction; the 70th, then the 90th, only for a direction that
  fails the feasibility rules in every month. A month that fails is untested (as section 4 already said).
- Section 4: the 10 blocks are counted on the withheld cells the score uses, those in a group (month, own
  direction, distance band) with positive target weight, not on all withheld cells (Fable's review; Chris, 3 November).
- Section 5: a candidate whose fit fails outright, or does not converge after the retry, in any required fold cannot be
  chosen; its failures are recorded, not dropped. If model 8 cannot be chosen, the comparison is reported incomplete.
  If the resampled uncertainty is not finite, no automatic choice is made.
- Section 6: each withheld cell's error is grouped by the direction in which it lies outside its own fold's
  training range (the same rule as for the past mixes), its holdout kept beside it; the number of cells whose
  direction differs from their holdout's is reported.

## What the cross-validation can and cannot say about the northeast (Chris, 3 November 2026, before any score)

Recorded before any fold is fitted, from Astra's review (`2026-11-03_cv_northeast_question_codex_gpt6astra.md`),
on run 1's data:
- The northeast's past mixes (6 to 4.5 ka) lie outside today's range in the **less-open-land direction** (d2,
  +17.2 degrees), not in the direction of the evergreen-to-summergreen change itself (about -60 degrees).
- That holdout withholds 82 of the 83 northeast cells. Among them evergreen share still follows latitude
  (r = 0.914), so the holdout keeps the confounding of cover with location; their nearest training cells are
  167 / 340 / 524 km away (10th / 50th / 90th percentiles), whereas the hindcast predicts at their own places.
- The departures overlap in distance (northeast at 4.5 ka: median 0.085, at most 0.107; the holdout's withheld
  cells: 90th percentile 0.076, at most 0.112), but the deepest May group (beyond 0.10) has 15 cells in five blocks,
  with 44-61% summergreen against 73% in the northeast at 4.5 ka. The northeast's four slices carry about 5% of the
  outside target weight.
- So the score measures transfer to modern cover mixes like the northeast's; it can choose a model that predicts
  them better, but it cannot establish the sign of the albedo effect of the hemlock decline at fixed northeastern
  places. The winning score is a selection score.
- **Added report** (section 6, reported only, never used to choose): the withheld cells' errors by diagnostic region
  (`R/regions.R`), month and own direction for each model, with the number of cells and blocks behind each, the cells
  with low open land, and the correlation of evergreen share with latitude among them (`by_region.csv`).
- **Reading the hindcast comparison** (section 7): persistent northeast warming under a competitive model argues
  against poor prediction on the modern conditions tested; it does not show the warming is real or rule out
  confounding. An independent local check of conifer versus deciduous albedo is being designed separately.
- **Model 3** has open land but no evergreen-summergreen distinction, so it predicts no response to the exchange of
  the two at fixed open land. It stays eligible (Chris, 3 November); if it is chosen, a weak or absent hemlock
  signal reflects its specification, not evidence that the physical effect is negligible.
- **The geographic hole** (d2 withholds almost the whole northeast, so a location-dependent model may lose partly
  for having to predict across it): measured and reported, not corrected; see the next section.
- The by-region table counts each withheld cell once in its cell, block and low-open-land counts and in the
  correlation, and once per holdout in the errors; all descriptive tables use converged fits only.

## Geographic sensitivity (Chris, 3 November 2026, before any fit)

From Astra's design (`2026-11-03_cv_geographic_sensitivity_design_codex_gpt6astra.md`) and Fable's review of it. The
selection score and the choice rule are unchanged; everything here is reported beside them, never used to choose, and
no diagnostic, nor the hemlock sign, triggers a new choice. It is not a geographic penalty that could be subtracted: a
cell's error mixes cover and geographic error, and no additive split exists.
- **Tail predictions, no extra fits:** each candidate's paired difference from model 8 (mean squared error, with its
  block-resampled standard error) by distance to the nearest training cell, [0, 100), [100, 250), [250, 500) and
  500 km or more, within each cover-distance band, on the rows both models predicted (a failed fit drops that row
  for that model only, Chris), with the cell-month-holdouts and blocks behind each and each band's share of the
  selection score's weight (`by_distance.csv`). These tables pool cell-months within a band; a band with no cells has
  no row.
- **The in-range holdout** (the seeded fifth of the 5 x 5 degree blocks, no cover cut) is fitted for the pairs that
  differ only in the location term, model 8, `cover_elev`, `mod8_coarse_loc`, `lin_cover` and `lin_cover_noloc`, and
  the chosen model, after the tail score (the order is immaterial, the rule being frozen). More candidates may be
  added later (Chris); being reported only, that changes no choice. Before any fit, `inrange.csv` gives, for each
  month, the training rows, the withheld cells, those inside the month's remaining training range, their blocks and
  distances. Only cells inside that range are scored; a month without enough training rows for the largest model, or
  with scored cells in fewer than 10 blocks, is untested.
- **In-range reports:** each model's score with the testable months weighted equally and its paired difference from
  model 8 (block-resampled standard error); a model whose fit failed or did not converge in any testable month has no
  score and is reported as incomplete, never dropped
  (`inrange_scores.csv`); the same by distance band (`inrange_by_distance.csv`; its 500 km band is empty, the
  holdout's cells lying at most about 350 km from training); and by region (`inrange_by_region.csv`): the holdout
  withholds 61 of the 83 northeast cells, about 51 of them inside the range, in four blocks, so the northeast's
  in-range errors beside its d2 errors are the one near-matched comparison of ordinary against unusual cover, thinly
  replicated.
- **A known tilt, stated and not corrected:** the hole can raise the location models' errors and widen the uncertainty
  of the paired differences, so that more candidates fall within one standard error, and the tie-break by fewest
  coefficients then favours the two models without a location term (52 and 249 coefficients, against 551-748 for those
  with the full location term).
- **If the winner's advantage over model 8 lies only in cells far from training,** the choice stands; the paper
  reports the distance tables beside it and the section 7 hindcast with both the winner and model 8.
- **Before the fits,** the holdouts stage is rerun at the commit used for fitting, so `holdouts.rds` carries the
  in-range support table (its other tables are unchanged, as the verification records show).


## Published basis of the geographic sensitivity reports (4 November 2026)

Carried over from the design (`2026-11-03_cv_geographic_sensitivity_design_codex_gpt6astra.md`), which quotes the
supporting passages. The five references were checked against Crossref on 4 November (DOI, title, authors, year,
journal, volume, pages; no retraction or correction).
- **Distance tables:** binning each candidate's existing predictions by distance to training is a lighter adaptation of
  Brenning's distance-based prediction-error profiles; no error curve is extrapolated. The four distance bands and the
  equal weighting of months are this project's reporting judgements.
- **Blocking and extrapolation, and the in-range holdout:** Roberts et al. separate the error of blocked holdouts from
  that of extrapolation; nearest-neighbour distance matching (Milà et al.; Linnenbrink et al.) compares holdout
  distances with prediction distances. Using an in-range holdout only as a report beside the choice is this project's
  adaptation.
- **Paired differences with their uncertainty, and the simplest model within one standard error:** Yates et al. The
  exact rule, block-resampled standard errors of the paired differences, is this project's adaptation.

References
- Brenning, A. (2023; online 2022). Spatial machine-learning model diagnostics: a model-agnostic distance-based approach.
  *International Journal of Geographical Information Science*, 37, 584–606. doi:10.1080/13658816.2022.2131789
- Linnenbrink, J., Milà, C., Ludwig, M., & Meyer, H. (2024). kNNDM CV: k-fold nearest-neighbour distance matching
  cross-validation for map accuracy estimation. *Geoscientific Model Development*, 17, 5897–5912.
  doi:10.5194/gmd-17-5897-2024
- Milà, C., Mateu, J., Pebesma, E., & Meyer, H. (2022). Nearest neighbour distance matching Leave-One-Out
  Cross-Validation for map validation. *Methods in Ecology and Evolution*, 13, 1304–1316. doi:10.1111/2041-210X.13851
- Roberts, D. R., et al. (2017). Cross-validation strategies for data with temporal, spatial, hierarchical, or
  phylogenetic structure. *Ecography*, 40, 913–929. doi:10.1111/ecog.02881
- Yates, L. A., Aandahl, Z., Richards, S. A., & Brook, B. W. (2023). Cross validation for model selection: a review with
  examples from ecology. *Ecological Monographs*, 93, e1557. doi:10.1002/ecm.1557

## Corrections of 4 November 2026 (descriptions only; the method is unchanged)

- **Section 8:** `R/cross_validation.R` now holds more than three functions: the holdouts, each withheld cell's
  departure and group, the score and its block bootstrap, the choice, and the descriptive and geographic reports. The
  tool has three stages (holdouts, fit, score).
- **Section 9:** the in-range holdout fits the five location-pair models and the chosen model for each testable month: up to 60 fits
  if the chosen model is one of the five, 72 otherwise, not 24. The fits run up to six jobs at once on the workstation
  (load rule of 3 November), not four.
- **Section 7 is not built yet.** `tools/plotting/plot_northeast_cover_and_location.R` compares model 8 with and
  without its location term and rightly requires model 8; the comparison of the chosen model with model 8 is still to
  be written, after the score.
