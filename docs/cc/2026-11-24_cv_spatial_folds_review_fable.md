# Review of the chosen cross-validation method (protocol 3), before it is built

Fable (science-reviewer role), 24 November 2026. Read only: nothing was run, changed or built, and I have not seen Astra's review. Numbers marked "my count" or "my sum" were worked by hand from the saved text tables and nobody has checked them.

Names used below:
- **Direction 1** is the cover departure "less evergreen, more summergreen" (47.3% of the target weight). **Direction 2** is "less open land, more summergreen" (45.2%). **Direction 3** is "less summergreen, more open land" (7.5%).
- **Tail**: the fifth of modern cells farthest along a direction, which protocol 2 already withholds.
- **h**: the buffer distance. **Ring**: the cells within h of the tested cells, removed from training.
- **Model 8**: location term of 500 basis functions, thin-plate cover of 200. **`loc100_linear`**: protocol 2's choice, location 100 and straight-line cover.

## Verdict

**Not ready to build as the score that chooses the model.** The construction is workable and the numbers I re-did are right. But the score would rank the models mainly on how the location term behaves when a whole region is left out; its standard errors would very probably be too small; and the 100 km option and the correlogram cannot do what the plan asks of them. A check on the saved predictions, with no fit, should come first.

## Benefit

The paper could say that the albedo model was chosen on cells whose cover mixture and whose whole neighbourhood were both absent from training, which answers Andria's and a referee's concern about spatial autocorrelation. It would not show that the response to a change of cover at a fixed place is right, and that response is what the forcing uses.

## Short answers to the six questions pressed

1. **Does a cell outside the cover range and at least h away measure what the hindcast needs?** No, for most of the target. It is too hard on the flexible location term and would rank location sizes for a reason the forcing barely shares (finding 1). It stays informative for comparing cover forms at the same location size.
2. **Is the target still represented, and what fails in winter?** Groups stay represented, more than now, because far cells count. The shallow band will thin by an amount only the holdouts stage can show. On training rows only December is tight, direction 3 first. The ten-block rule applied per split is the larger risk (findings 5 and 6).
3. **Are seeded k-means clusters sound units?** As folds, yes once made deterministic and measured in kilometres. As units of uncertainty, no: the tails are about eight whole regions (finding 2).
4. **Can the correlogram set h?** No (finding 4). And 100 km is not a buffer on this grid (finding 3).
5. **Is there a simpler method?** A score of the saved predictions far from training, with no fit, answers most of the question and predicts the result. The new fits add only the shallow band at a distance.
6. **Errors in the designers' numbers?** None in the numbers I re-did. One misdescription (tables called "kept" that do not exist), one overstatement Astra already corrected, and the 100 km option.

## Useful deletions first

| Deletion | Lines | Status |
|---|---:|---|
| Comparison with protocol 1's membership (`tools/cross_validate_albedo.R:222-238`, the third argument at `:135`, `:482`, `:488`, and `membership_changes` at `:246`) | -23 | Agreed by both designers; independent of the rest; can go now |
| Do not build the correlogram as the basis of h. `by_distance.csv` already shows, at fixed cover depth, where each model's error stops depending on distance (finding 4) | -30, not written | Chris approved the step, so his call. Keep it only as a description for Andria if wanted |
| No seed and no map projection for the clusters: `hclust()` and `cutree()` on great-circle kilometres, the idiom already at `R/cross_validation.R:131-132` | about 0; one seed and one open specification fewer | Needs Chris's yes (the plan says seeded k-means) |
| Leave `tools/compare_cv_hindcasts.R` and `validation_limits()` (`R/hindcast_comparison.R:150-160`) out of this change. They read protocol 2's tables, which stay true of tests near training. Keep `CV_NEARBY_KM`, `CV_KM_BANDS` and `km_band()` for them | about -100 of planned churn | Revisit only if the choice changes |
| The 70th and 90th percentile fallback (`CV_CUTS`, `R/cross_validation.R:21`; loop at `tools/cross_validate_albedo.R:173-182`) | -5 | Never used (every cut in `feasibility.csv` is 0.8). It removes Chris's rule of 3 November (decisions file, item 11), so it needs his explicit word |
| Recovery (up to 360 fits) and the winner's pipeline (192) only if the chosen model changes | 0 | Already in the plan; the saved outputs suggest it will not change |

## Hand check

**(a) Target weights** (`target.csv`, my sum). Total 0.128158. Shallowest band (less than 0.02 outside the modern range) 0.074790, which is 58.4%. Each month carries 8.3 to 8.4%. Agrees with the designers and with `directions.csv`.

**(b) The designers' pooled errors by distance** (`by_distance.csv`, rows times mean squared error, my sum).
- Model 8 under 100 km: 4.9645 over 2,756 rows, RMSE 0.0424. At 250 to 500 km: 120.41 over 6,225, RMSE 0.1391.
- `loc100_linear`: 5.3784 over 2,756, RMSE 0.0442; 30.925 over 6,225, RMSE 0.0705.
- At 250 km and over, by direction 1, 2, 3: model 8 0.201, 0.094, 0.078; `loc100_linear` 0.062, 0.062, 0.084.
- All agree with Fable's design (0.042, 0.139, 0.044, 0.071; "about 0.20 against 0.06").

**(c) The buffer on the one-degree grid**, with the formula of `nearest_km()` (`tools/cross_validate_albedo.R:106-110`). Tested cell at 100.5 W, 45.5 N:

| Neighbour | km | Removed at 100 | at 250 | at 500 |
|---|---:|---|---|---|
| one cell east | 77.9 | yes | yes | yes |
| one cell north | 111.2 | **no** | yes | yes |
| two cells north | 222.4 | no | yes | yes |
| three cells east | 233.8 | no | yes | yes |
| three cells north | 333.6 | no | no | yes |

South of 26 N one degree of longitude exceeds 100 km (100.4 km at 25.5 N), so at 100 km nothing at all is removed round the 70 Mexican cells of direction 3.

**(d) December** (`feasibility.csv`). 1,087 + 329 = 1,040 + 376 = 914 + 502 = 1,416 cells have a December albedo. The largest model needs 748, so at most 668 may be left out. The tails take 329, 376 and 502, leaving 339, 292 and 166 cells for the ring in directions 1, 2 and 3. January leaves 640, 518 and 476.

**(e) Against the code.**
- `cv_scoring_rows()` (`R/cross_validation.R:32-34`) keeps only cells under 250 km (`tests/test_cross_validation.R:204-208`). Left as it is, it would score none of the new method's cells at 250 or 500 km, and at 100 km only those between 100 and 250 km, with no error.
- `cv_feasibility()` (`R/cross_validation.R:50-57`) applies the ten-block rule to whatever it is called on, so called per split it applies it per split.

## Findings, worst first

### 1. Blocker for the choice, not for building it as a report: the score would choose on regional extrapolation of the location term

**Where.** Items 3 and 6 of the method in the brief.

**Evidence.**
- **Where the hindcast is** (`comparison.csv`, column `km_past`). For directions 2 and 3 the 90th percentile of distance from an outside-range past cell to a fitted cell is zero in all twelve months. For direction 1 it is zero from March to October. Only direction 1 in winter is away from fitted cells: medians 111, 1,360 and 373 km in November, December and January. Bounding from those quantiles and the target weights, **between 79% and 94% of the target weight sits at a fitted cell's own place** (my bounds; rows are not area-weighted). The rest are high-latitude winter cell-months with too little sun for a MODIS albedo, so their part in the forcing is small. That part has not been measured.
- **What the location term does to the forcing.** Location and elevation are the same in every time slice, so on the link scale they cancel in every slice-to-slice difference (`questions_for_andria_scientific.md:367-389`, exact only on the logit scale). The error the separation adds, a location surface carried across a gap, is one the forcing largely does not have.
- **What separates the models at a distance today.** Shallowest band, RMSE by distance to the nearest training cell (`by_distance.csv`; model 8's cell counts in brackets). Cover depth is the same along each row; only geography changes.

| | under 100 km | 100-250 | 250-500 | 500 and over |
|---|---:|---:|---:|---:|
| Direction 1, model 8 | 0.036 (72) | 0.040 (52) | 0.103 (19) | 0.508 (1) |
| Direction 1, `loc100_linear` | 0.041 | 0.043 | 0.047 | 0.109 |
| Direction 2, model 8 | 0.043 (84) | 0.066 (77) | 0.065 (8) | 0.063 (5) |
| Direction 2, `loc100_linear` | 0.043 | 0.043 | 0.060 | 0.035 |
| Direction 3, model 8 | 0.034 (55) | 0.061 (69) | 0.063 (24) | none |
| Direction 3, `loc100_linear` | 0.042 | 0.072 | 0.066 | none |

  In directions 2 and 3 model 8's error is flat from 100 km outward. The separation changes the ranking through direction 1, where the review of 10 November traced the failure to predictions far too bright in western and interior Alaska once neighbours were withheld (May: observed 0.23, model 8 0.47).
- **The likely outcome.** Scoring only the existing cells 250 km or more from training, with the target weights by direction and band (months pooled, no resampling; my approximation):

| Model | RMSE far from training | Share from direction 1 | Protocol 2's nearby score |
|---|---:|---:|---:|
| `loc100_linear` | 0.058 | 46% | 0.049 |
| `loc100_tp50` | 0.078 | 66% | 0.051 |
| `loc12_linear` | 0.085 | 59% | 0.073 |
| `loc12_tp50` | 0.096 | 77% | 0.066 |
| `loc30_tp50` | 0.100 | 83% | 0.062 |
| `loc30_linear` | 0.103 | 79% | 0.071 |
| Model 8 | 0.151 | 85% | 0.066 |

  One cell (11 cell-months) supplies about a fifth of model 8's figure. I summed seven of the fifteen models. **The most likely result of the new fits is the same choice, resting even more on the north-west.** The dependence on Alaska is not reduced.
- **History.** On 2 November both reviewers agreed, and Chris accepted, that buffered holdouts should not choose the model, for this reason (decisions file, item 7; Astra's reconciliation of 2 November, lines 5 and 14). The designs of 23 November do not answer the objection; they list it as a limit.

**Where the method is right.** Removing neighbours does stop the flexible location term from copying them. A comparison of cover forms at the same location size stays informative, because the location error is largely common to the pair. Comparisons across location sizes are the ones confounded with extrapolation. Andria's question, whether a location term helps at new places, is already answered by protocol 2's far cells: without one the RMSE is 0.15 to 0.27 at 250 km or more.

**Consequence.** If this score chooses alone, the paper's model is chosen on a property the forcing hardly uses, mostly in the snow months (finding 9). The choice between candidates whose vegetation forcing differs in sign from 4 to 12 ka is no better founded than now.

**Checks.**
- No fit: a verification specification that scores the saved protocol 2 predictions on cells 250 km or more from training with the protocol's own weighting, beside the nearby score. If it picks the same model, the new fits firm up only the shallow band. Adds about 15 lines in a specification, none in code.
- No fit: print the weighted share of the target at zero distance from a fitted cell. Adds 2 lines.
- The test that would settle whether the score chooses for the right reason: one month of made-up data with a known cover effect (`recovery_response()`, `R/cv_separation.R:182-190`), scored through the new folds for four models, about 48 fits. Both `loc100_linear` and model 8 recovered the cover effect under those truths; if the score ranks them far apart, it is ranking location extrapolation. I do not recommend building it unless the score is to choose alone.

### 2. Should-fix: the tested units are a few whole regions, so "at least h" understates the distance and the block standard errors are too small

**What.** The tail cells are not scattered. From `validation_cells.csv` (all 1,688 June rows read; my count):
- Direction 1: 233 cells from Alaska to Banks and Victoria Islands, and 329 in the eastern United States.
- Direction 2: about 42 in interior Alaska, 195 from Yukon down the Cordillera to northern California, 14 in Saskatchewan, 312 from Ontario to Labrador and the Appalachians.
- Direction 3: 61 in the High Arctic, and 502 in one piece from central Mexico to the Canadian prairies.

The winter counts in `feasibility.csv` (329 and 502) are exactly the southern regions.

**Consequences.**
- **Distance.** The whole tail is left out of every fit, so the distance to training is set by the size of the region. Before any buffer the median is 270, 174 and 292 km and the 90th percentile 672, 423 and 730 km (`comparison.csv`, March to September). The buffer moves only the edge cells. Telford and Birks's method leaves out the neighbours of one sample at a time (as the design's table describes it), so each test sample's nearest training sample is just beyond h. Here most are several times h. Their way of setting h does not carry over, and "unduly pessimistic" (Trachsel and Telford, as the design quotes it) applies with more force.
- **Uncertainty.** All cells of a cluster share a fit and fail together: four adjacent Alaskan blocks gave 61% of protocol 2's margin. Resampling 5-degree blocks treats about a hundred blocks as independent when there are about eight regions, fewer in winter. Clusters cannot be resampled instead, because a cell in two tails belongs to two clusters. So the design has no calibrated standard error. Both designers said as much, but the method keeps the one-standard-error rule.
- **The rule has a known tilt** (`2026-11-02_cv_protocol.md:176`): wider errors bring simpler models inside one standard error and the fewest coefficients then win. In protocol 2 the choice passes to `loc30_linear` (81 coefficients) if the true standard errors are 4.3 times those reported (0.002547 over 0.000587, `scores.csv`).

**Checks.**
- No fit: recompute protocol 2's paired standard errors with 10- and 20-degree blocks (`cv_block()` takes the size, `R/cross_validation.R:172`). If they grow, 5-degree blocks are not independent units. Adds 5 lines in a specification.
- Report the multiple of the standard errors at which a simpler model would be chosen. Adds 2 lines in the score stage.

### 3. Should-fix: 100 km is not a buffer on this grid

**What.** Hand check (c): at 100 km only the east and west neighbours go, the cells directly north and south stay in training at 111 km, and south of 26 N nothing goes. The review of 10 November already records that "under 100 km" holds only east-west neighbours.

**Consequence.** The three options are really two. A correlogram class ending at 100 km would hold east-west pairs only.

**Fix.** Offer 250 or 500 km, or state the buffer in rows of cells. Also write down: strictly less than h or at most h; and that the ring is drawn round all the cluster's tail cells whether or not they have that month's albedo, which keeps one membership per split as now. No lines.

### 4. Should-fix: the correlogram cannot set the distance

- **What the literature says** (I have no web access in this session; these are the project's records and my memory, not a re-reading). Telford and Birks, and Trachsel and Telford, take the variogram of the residuals of the model being tested, detrended, for models with no location term. Roberts et al. say to block even where the fitted model accounts for the correlation, and warn that blocking can force extrapolation and overstate error when the task is interpolation. None gives a distance for a model that contains its own location surface. None sets the buffer for such a model from the residuals of a different model without one.
- **For three candidates it is the right plot; for twelve it is not.** The candidates without location match the published recipe. For those with location, their own residuals have little structure left, which would give almost no buffer.
- **The plot will probably not discriminate.** The no-location residuals contain the continental gradient of latitude and snow. Expect correlation still positive at 500 km in most months; read literally that points to the largest option.
- **Alignment hazard.** The saved fits (`cv2-winner/output/calibration/calibration_mod_cover_elev_<month>.RDS`; the twelve files exist) have no x or y in the formula, so the model frame carries no coordinates. Residuals must be joined to cells by row. A wrong join gives no error and a flat correlogram, which would argue for a short distance. `check_full_month_rows()` (`R/cv_separation.R:123-131`) tests exactly this; call it. Adds 1 line if the step is kept.
- **The choice is not blind.** The effect of each distance on each model is already in `by_distance.csv`.
- **Simpler evidence already on file.** In directions 2 and 3 model 8's shallow-band error stops depending on distance beyond 100 km (table in finding 1). Two rows of cells, 250 km, remove the borrowing. That supports 250 km as a stated judgement without the new step.

### 5. Should-fix: five points of the specification that decide results and are not written down

- **Unit of the ten-block rule.** "Feasibility is judged per split" plus `cv_feasibility()` gives ten blocks per split. Small pieces cannot reach ten blocks: the 61 High Arctic cells, the 42 in interior Alaska, and the few northern cells that have an albedo in October, November, January or February. They would drop out, and each month's group means would come from different regions. Chris's rules of 2 and 3 November say ten blocks per direction (decisions file, items 7 and 13). Proposal: training rows per split; ten blocks per direction and month over the cells of its feasible splits; a table of which splits each month rests on. About 5 lines changed.
- **The scoring mask.** Remove the distance condition from `cv_scoring_rows()` and pin it with a test (hand check e). About 3 lines changed.
- **Eligibility.** One unconverged fit makes a model ineligible. Each model had 36 required fits and one of the 540 failed. Now each has up to 144, on smaller training sets. At the observed rate about four failures are expected, each removing a model. If the failed fit is the leading model's, the choice passes to another by default. Chris's call, before any fit. No lines.
- **Clusters.** Kilometres and no seed (deletions table). Made once from all tail cells and frozen in `holdouts.rds`.
- **Output folder and names.** `cv_file()` hard-codes `cross_validation_v2` (`tools/cross_validate_albedo.R:37`) and `check_inputs()` requires version 2 (`:76`). Protocol 3 needs its own folder. It must not reuse the name `nearby_coverage.csv` for cells far from training: `tools/compare_cv_hindcasts.R:407-408` reads that name and prints it as tested "near training" (`:416`, `:450`, `:493`). Fable's design proposed keeping that table for that reader. About 3 lines changed.

### 6. Should-fix: what the buffer does to coverage and to winter can be measured only at the holdouts stage

- **Groups.** Every tail cell is now scored, so groups only gain cells. The one group missing in protocol 2 (direction 2, 0.10 and deeper, 2.06% of the target) has 15 far cells a month. Represented weight will read close to 100% while resting on tests at a distance. That should be said beside it.
- **Depth.** Cells can only move deeper: the training set is a subset, so the range is a subset. The range is a convex hull, so its edge moves only where a corner cell is removed. The ring removes exactly the cells nearest in cover to the tested ones, so some retreat is likely in each split, limited by the near-cut cells kept round the other clusters. I could not measure it. The shallow band holds 58% of the weight on 144, 166 and 148 cells a month in summer (`coverage.csv`, near plus far).
- **Winter.** On training rows only December is tight, direction 3 first: 166 cells of allowance per split. My rough count of the ring is 50 to 80 cells per piece at 250 km and 100 to 165 at 500 km, give or take half. So 250 km probably leaves every month testable and 500 km puts December's direction 3 at the limit.
- **Check.** Before any fit the holdouts stage prints, per split and month: training rows, tested and scored cells, blocks, distance quantiles, and band counts beside protocol 2's. Chris reads it first. About 10 lines, inside the plan.

### 7. Should-fix: records

- **Two "kept" tables do not exist.** `cv_paired_by_band()` compares with model 8 only (`R/cross_validation.R:250`), so location pairs are new. No function for block or cluster contributions exists in `R/`, `tools/` or `tests/`. Each is about 15 lines and each needs Chris's explicit yes. On the block-share table the record of 10 November says "Not yet decided" (results review, section 5, item 5).
- **Three recorded decisions are reversed:** no geographic buffers (2 November, item 7); only cells under 250 km choose (6 November; "Do not widen the cutoff", `2026-11-06_cv_protocol_v2.md:134`); the 70/90 fallback (3 November, item 11). The brief gives the decisions of 24 November in paraphrase and I cannot check them. The protocol 3 record should carry Chris's words and name each reversal.
- **A stale reason in the code.** The header of `R/cross_validation.R:8-9` still gives the reason against a buffer. The reason stays true; the record should say why the buffer is added in spite of it.
- **Questions files.** The entry of 15 November still says nothing is designed (`questions_for_andria_scientific_from_2026-10-20.md:408-409`). The designers' questions for Andria are in neither file.
- About 10 lines of records.

### 8. Nit: numbers

- 2,160 is an upper bound: the northern pieces have no cells in winter. "Up to" is right.
- 974 fit-minutes: both designers report it; I did not open the logs.
- Fable's design, line 77 ("no better than no location beyond 250 km"), is wrong for the straight-line pair, as Astra showed.
- I could not fault: 914 and 748; 12.8158%; 58%; 295, 190 and 322 far cells; 57 far shallow cells (20 + 13 + 24); the in-range median of 111 km.

### 9. Note, carried over from protocol 2 and made larger: the snow months decide

`scores_by_month.csv`, all withheld cells:
- Model 8's RMSE is 0.038 in July and August and 0.11 to 0.17 in April, May, June and October. With months equal, May and June are 37% of its squared error and July and August 2%.
- In July and August the straight-line model with no location term (0.028, 0.029) does as well as or better than `loc100_linear` (0.038, 0.036). From February to June and in October it is two to five times worse.

This is evidence already on file for Andria's reading of the location term as climate, chiefly snow. With months weighted equally and no kernel, a score at a distance is mostly a test of carrying snow-season albedo into a region left out. No change proposed here; it goes to Andria as a question.

### What I could not fault

Keeping the cover tails at a fixed 80th percentile; separating the two masks; keeping the target, grouping and weights frozen; keeping the in-range holdout and the monthly depth table; judging training rows per split; the fit-count arithmetic.

## What the proposed verification misses

"The fits ran and the tests pass" is not evidence for the new score. Assert these, about 20 lines in the existing test files and specifications:

1. With the buffer set to zero, the holdouts stage reproduces protocol 2's saved `validation_cells.csv` row for row. This anchors the two-mask change and says nothing about the buffer.
2. The clusters of a direction partition its tail: their union equals `cv_holdouts(cal, angle, 0.8)` and no cell is in two.
3. Per split and month: no tested cell in training; the smallest tested-to-training distance is at least h; no training cell within h of a tested cell; every excluded cell is in the tail or within h of a tested cell.
4. For each tested cell and month, cover distance and kilometres are at least protocol 2's, and training rows at most protocol 2's.
5. The small case of hand check (c), including the neighbour at 111 km.
6. A tested cell at 260 km and one at 600 km, in a group with target weight, are both scored.
7. A block that straddles two clusters is resampled as one unit.
8. A score worked by hand for two splits pooled into one group, so no weight is counted twice.
9. If the correlogram is kept: `check_full_month_rows()` passes before residuals are placed on the map.

## Not worth doing

- A map projection for clustering; month-specific rings; a rule for a cell at exactly h (north-south spacings are multiples of 111.19 km, never 100, 250 or 500).
- Fitting a variogram model, detrending, or estimating a range.
- A search over the number of clusters or over h using scores.
- A distance that adds kilometres to cover fractions; distance-matching machinery; any new package.
- Resampling by cluster, or a two-way bootstrap. No simple valid one exists here; report the multiple of finding 2 instead.
- Extending the in-range holdout to all fifteen models (156 more fits).
- Rewording the hindcast comparison now.
- Kernel or month weights in the score as part of this change.
- Reweighting, capping or removing Alaska.
- Guarding `nearest_km()` against rounding (about 10 cm) or the date line. Neither occurs here.

## Questions

### For Chris

1. **What is the new score for?** It tests every cell at least h, and typically several hundred kilometres, from any training cell. Between about 79% and 94% of the target it is weighted to lies at a fitted cell's own place, and the error the separation adds belongs to the location term, which largely cancels in the forcing. Existing predictions suggest it will pick the same model as protocol 2, on evidence concentrated in the north-west.
   - (a) It chooses on its own, as the brief records you decided on 24 November.
   - (b) It is reported beside protocol 2's score and a choice is declared only if both pick the same model.
   - (c) It is a report and protocol 2's choice stands.
   - Meanwhile nothing is built; `config.R` names model 8 and protocol 2's choice is recorded as provisional.
2. **A check without fits first?** Scoring the saved protocol 2 predictions on cells 250 km or more from training needs about 15 lines in a verification specification.
   - (a) Run it, then decide whether the 2,160 fits are still wanted.
   - (b) Go straight to the fits.
3. **Which buffer distance?** On a one-degree grid 100 km removes only the east and west neighbours.
   - (a) 250 km, two rows of cells, as a stated judgement backed by the existing error-by-distance table.
   - (b) 500 km, which puts December's direction 3 at the limit of the training-row rule.
   - (c) Wait for the correlogram, knowing it fits the candidates without a location term only.
   - And is the correlogram still wanted as a description for Andria?
4. **The one-standard-error rule.** The block standard errors will very probably be too small and this design has no simple valid alternative.
   - (a) Keep the rule with 5-degree blocks and report how many times larger the errors would have to be for a simpler model to win (4.3 in protocol 2).
   - (b) No automatic choice: scores, paired differences and that multiple are reported and you and Andria choose.
   - Meanwhile `cv_choose()` applies the rule.
5. **One region carrying the margin.** If one region supplies most of the winner's margin, as four Alaskan blocks did in protocol 2, does the choice stand with that shown, or is no choice made? Fable's reconciliation asked this; it is not among the decisions in the brief.
6. **A failed fit.** Each model now needs up to 144 converged fits instead of 36, and one failure makes it ineligible. If the leading model has one failed fit:
   - (a) the rule stands and the choice passes to the next model;
   - (b) no choice is made and the failure is reported.
7. **Ten geographic blocks.**
   - (a) Per direction and month, counted over the cells of its feasible splits, as your rules of 2 and 3 November say.
   - (b) Per split, which drops the small pieces.
8. **Approvals this review cannot give.** The table of location pairs (about 15 lines). The table of block and cluster contributions (about 15 lines; "not yet decided" on 10 November). Removing the 70th and 90th percentile fallback (your rule of 3 November). Clusters by `hclust()` on kilometres instead of seeded k-means.

### For Andria

1. **Which claim should the choice of model support?** (a) That the model predicts albedo at places it has never seen. (b) That it gives the right change in albedo when cover changes at a place it has seen. The new test measures (a). The forcing uses (b), and no modern test observes (b) directly.
2. **What the location term stands for.** On withheld cells a model with no location term predicts July and August albedo as well as the chosen model (RMSE 0.028 and 0.029 against 0.038 and 0.036). From February to June and in October it is two to five times worse. Does that fit your reading of the location term as a stand-in for climate, chiefly snow? If so, are you content that the hindcast carries today's pattern unchanged into the past?
3. The open question on winter cell-months north of every fitted cell (question 8 of section 8 in the questions file) decides how much those cases should count. It is not repeated here.

## Line cost of what this review proposes

Against the plan's +1,200 / -150. None of this is authorised by the review.

| | Lines |
|---|---:|
| Deletions: protocol 1 comparison -23; fallback -5; correlogram -30 if dropped; hindcast-comparison changes deferred, about -100 | up to -158 |
| Additions: tests +20; specifications +22 (far-only score 15, zero-distance share 2, block-size check 5); score stage +2; alignment check +1 if the correlogram is kept; records +10 | about +55 |
| New items needing Chris's explicit yes: the two tables called "kept"; the standard-error multiple; the far-only score if it goes into the tool and not a specification; the made-up-truth test (not recommended) | as stated |

## Limits and what I did not check

- No R and no commands. Every count, sum and score of mine is by hand from text tables.
- The far-only scores pool months, are not the protocol's per-month grouping, and have no resampling.
- The December ring sizes are rough counts, give or take half. The retreat of the cover range after the buffer is reasoned, not measured.
- Literature: no web access. Telford and Birks, Trachsel and Telford, and Roberts et al. are cited from the project's records and my memory. The reference checkers were not run.
- Read only in part: `R/cv_separation.R` (lines 118-199), `2026-11-02_cv_protocol.md` (lines 150-219), the two questions files. Searched, not read: `tools/compare_cv_hindcasts.R`, `tools/check_cv_separation.R`, `scripts/4_calibration_model.R`, `R/regions.R`, `config.R`, the design documents of 2 to 6 November.
- Not opened: any `.rds` file; the fit logs (so the 974 fit-minutes); Chris's words of 24 November, which are not in the packet.
- Astra's findings: not seen.

## Files

Repository root: `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds`. Protocol 2 outputs: `/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2`.

- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/docs/cc/2026-11-24_cv_spatial_folds_review_brief.md`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/docs/cc/2026-11-23_cv_spatial_folds_design_fable.md`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/docs/cc/2026-11-23_cv_spatial_folds_design_codex_gpt6astra.md`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/docs/cc/2026-11-23_cv_spatial_folds_reconciliation_fable.md`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/docs/cc/2026-11-23_cv_spatial_folds_reconciliation_codex_gpt6astra.md`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/docs/cc/2026-11-06_cv_protocol_v2.md`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/docs/cc/2026-11-02_cv_design_decisions.md`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/docs/cc/2026-11-02_cv_protocol.md`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/docs/cc/2026-11-10_cv_protocol_v2_results_review_fable.md`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/docs/cc/questions_for_andria_scientific.md`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/docs/cc/questions_for_andria_scientific_from_2026-10-20.md`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/R/cross_validation.R`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/R/cv_separation.R`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/R/hindcast_comparison.R`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tools/cross_validate_albedo.R`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tools/compare_cv_hindcasts.R`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tests/test_cross_validation.R`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tests/test_cross_validation_stages.R`
- `/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2/by_distance.csv`
- `/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2/validation_cells.csv`
- `/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2/comparison.csv`
- `/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2/feasibility.csv`
- `/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2/target.csv`
- `/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2/coverage.csv`
- `/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2/scores.csv`
- `/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2/scores_by_month.csv`
- `/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2/inrange_by_distance.csv`
- `/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2/fit_status.csv`

Files read: 37 in full or in part, and 5 more searched only. Tool calls: 69 before this hand-back.
