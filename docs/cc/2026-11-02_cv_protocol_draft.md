# Cross-validation protocol for choosing the albedo model: DRAFT for Chris's approval (2 November 2026)

**Benefit to the paper:** the albedo model is chosen on measured accuracy for land-cover mixes beyond the modern
range, which is where the hindcast extrapolates, so the paper can state that accuracy.

Built from Chris's decisions (`2026-11-02_cv_design_decisions.md`) and Astra's reconciled design
(`2026-11-02_cv_design_reconciliation_codex_gpt6astra.md`, "revised design"). Items marked **[to approve]** are
not yet decided by Chris. Once approved, this protocol is frozen: nothing in it changes after the first model
score is seen. Known before freezing, and stated here so no one can say it was hidden: on the 18 October raster
run, the model without the location term (`cover_elev`) gave the opposite northeast sign to model 8 (changelog,
northeast entry).

## 1. Inputs
- Calibration table and settings of the main refit (run 1: MODIS cells, all days, full_75 version), code at
  the commit the protocol is frozen on. **[to approve]**
- Hindcast cover: the configured time slices except the modern 50 BP slice.

## 2. What the folds must imitate (the target)
- The hindcast cell-slices whose cover mix lies outside that month's training range (outside the convex hull of
  the training mixes on the cover triangle, `R/training_support.R`).
- Weights: each historical slice and each month equally; within a slice, by cell area times the ice-free
  fraction (ice-covered cells carry little vegetation albedo). **[to approve]**

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
   of 5 x 5 one-degree cells. **[to approve: block size]**

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
- Shares the workstation with the refit queue: within the existing limit of four jobs at once. **[to approve:
  after the refit queue, or interleaved]**
