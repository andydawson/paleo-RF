# Design: one cross-validation method for new places and new cover mixtures (Fable, 23 November 2026)

**Benefit to the paper:** the albedo model would be chosen on cells that are both a new place and a new cover mixture, so the score no longer rewards a model for copying its neighbours.

Design only. Nothing was built, written or run. I read the brief, `AGENTS.md`, `CONTRIBUTING.md`, protocol 2 and its briefs, the results review and Astra's check, the five code files, the model registry, the tests and the protocol 2 outputs.

Three things to know before reading:

- **The recommended method reverses Chris's decision 7 of 2 November** ("no geographic buffers: the hindcast predicts at the training cells' own locations"). I raised that objection myself on 2 November and it is still true. Section 2 says what it now costs.
- **The Alaska fragility is probably not reduced.** The saved outputs suggest it may get larger (section 2.5).
- **The verification folder is not where the brief says.** It is at `/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/`, one level higher than `../paleo-RF-verify/` from the worktree. I read that one.

The numbers I give from saved outputs are my own sums over `by_distance.csv`, `validation_cells.csv`, `target.csv` and the fit logs, made with `awk`. They are pooled over rows, not the hindcast-weighted score, and nobody has checked them.

## 1. Published precedent

**No paper found builds one fold that is blocked in geographic space and in cover space at once.** The ingredients are published; joining them is this project's adaptation and should be labelled a judgement.

| Paper | Method | What it says about the two spaces | How I read it |
|---|---|---|---|
| Telford and Birks (2009), *Quat. Sci. Rev.* 28, 1309–1316, doi:10.1016/j.quascirev.2008.12.020 | h-block cross-validation for transfer functions: leave out every training sample within h km of the test sample; h from the variogram range of detrended residuals | Withholding the environmental extremes does not show spatial independence while neighbours stay in training (the project's record of section 7) | Not opened today. Its account in Trachsel and Telford, and the project's earlier reading |
| Trachsel and Telford (2016), *Clim. Past* 12, 1215–1223, doi:10.5194/cp-12-1215-2016 | Three ways to set h | h too short is over-optimistic; h too long is "unduly pessimistic". For real data they compare removing the environmentally closest samples with removing the spatially closest. This is the nearest palaeo statement on both spaces, as a comparison and not as one fold | Pages 1215–1218 read today |
| Roberts et al. (2017), *Ecography* 40, 913–929, doi:10.1111/ecog.02881 | Review of blocked cross-validation, with simulations | Table 1 names blocking in "both predictor space and structure". Box 4: purely environmental splits "are unlikely to account for spatial autocorrelation or structural overfitting because blocks may be spatially intertwined", and the two kinds of extrapolation add up. Box 1: blocks must be much larger than the residual autocorrelation range; a buffer at the distance where it reaches zero suffices. Blocking is "required" to "infer causal predictors". Blocking can also be "overly pessimistic" | Pages 913–918 and 922–925 read today |
| Le Rest et al. (2014), *Glob. Ecol. Biogeogr.* 23, 811–820, doi:10.1111/geb.12161 | Spatial leave-one-out for variable selection, threshold at the range of residual autocorrelation | Geographic only. AIC selects autocorrelated variables too often | Abstract only (Crossref) |
| Ploton et al. (2020), *Nat. Commun.* 11, 4540, doi:10.1038/s41467-020-18321-y | Remote-sensing biomass map: spatial folds from geographic clusters just larger than the autocorrelation range, and buffered leave-one-out | Geographic only. Skill fell from about half the variance to almost none once the buffer passed the range | PMC text through the fetch tool; paraphrased |
| Meyer and Pebesma (2022), *Nat. Commun.* 13, 2208, doi:10.1038/s41467-022-29838-9; (2021), *Methods Ecol. Evol.* 12, 1620–1633, doi:10.1111/2041-210X.13650 | Match the test-to-training distances to those of the prediction task; area of applicability in predictor space | Geographic gaps often go with predictor gaps. Neither paper prescribes a joint fold | 2022: PMC text through the fetch tool. 2021: not re-read; the project's record of sections 2.5–2.6 |
| Milà et al. (2022), doi:10.1111/2041-210X.13851; Linnenbrink et al. (2024), doi:10.5194/gmd-17-5897-2024 | Distance matching, leave-one-out and k-fold | Geographic. The CAST package documentation offers a feature-space version marked experimental | Checked by the project on 4 November; package documentation through search |
| Valavi et al. (2019), *Methods Ecol. Evol.* 10, 225–232, doi:10.1111/2041-210X.13107 | blockCV: spatial blocks, buffers, environmental clusters | Offers the two kinds separately | Abstract only (Crossref) |
| Wadoux et al. (2021), *Ecol. Model.* 457, 109692, doi:10.1016/j.ecolmodel.2021.109692 | Counter-view | Spatial cross-validation is biased for map accuracy when predictions are made where the samples are | Abstract through search only |

The reference checkers were not run. Identities of Meyer and Pebesma 2022, Le Rest, Valavi and Wadoux were checked against Crossref today; the others rest on the project's earlier checks.

## 2. The recommended method: cover tails tested as new places

### 2.1 Folds

1. **Keep protocol 2's cover construction unchanged.** Three directions, the 80th-percentile tail of each withheld everywhere, in every month.
2. **Split each direction's tail cells into K = 4 geographic clusters** by k-means on their coordinates (base R, seeded). Compact clusters keep the excluded ring small; scattered 5-degree blocks would not, because a 250 km ring around a 5-degree block is larger than the block.
3. **For each direction and cluster, fit without** (a) that direction's whole tail, as now, and (b) every other cell within **h = 250 km** of a tested cell.
4. **Tested cells** are the tail cells of that cluster. Each is at least h from every training cell by construction, and outside the training range of cover.
5. **Feasibility is declared before any fit**, as now. A direction-month is tested only if all K of its fits have enough training rows and its tested cells lie in at least ten blocks.

Why not plain spatial blocks: the existing blocked holdout of 5-degree blocks has a median distance to training of 111 km (`inrange.csv`), nearer than protocol 2's tails. Blocks without a buffer do not remove neighbours.

### 2.2 Score, weights and choice

Unchanged from protocol 2:

- squared error of the fitted mean albedo;
- each cell grouped by month, its own departure direction and its cover-distance band;
- groups combined with the frozen hindcast weights;
- standard errors from resampling 5-degree blocks;
- the one-standard-error rule, then fewest coefficients.

**How the two distances combine.** Cover novelty is graded and weighted to the hindcast. Geographic distance is a threshold: every scored cell is a new place. It cannot be weighted to the hindcast, because from March to September the hindcast's own distance to training is zero (`comparison.csv`), which no held-out cell can have.

### 2.3 Three small reports beside the score

- **Location pairs.** Each location size against no location term at the same cover form, as a paired difference with its block standard error. This is Andria's comparison.
- **Leave one cluster out.** The score and the choice with each geographic cluster removed in turn. This is the block-share table the review proposed, at the scale of the folds.
- **What neighbours were worth.** For tail cells that had a training neighbour in protocol 2, each model's error there against its error here, on the same cells, from protocol 2's saved predictions.

### 2.4 What the saved outputs already show

Pooled RMSE of protocol 2's existing predictions by distance to the nearest training cell:

| Model | under 100 km | 100–250 km | 250–500 km | 500 km and over |
|---|---:|---:|---:|---:|
| Model 8 (location 500) | 0.042 | 0.082 | 0.139 | 0.130 |
| `lin_cover` (location 500) | 0.041 | 0.081 | 0.140 | 0.125 |
| `loc100_linear` (protocol 2's choice) | 0.044 | 0.062 | 0.071 | 0.075 |
| `loc12_linear` | 0.066 | 0.079 | 0.085 | 0.087 |
| `loc0_tp50` (no location) | 0.148 | 0.149 | 0.150 | 0.152 |
| `lin_cover_noloc` (no location) | 0.158 | 0.166 | 0.200 | 0.265 |

- A location term helps at every distance; the no-location models are worst throughout.
- The flexible location term is best beside its neighbours and no better than no location beyond 250 km. That is the borrowing from neighbours.
- The error of location 500 levels off beyond 250 km. That is my basis for h = 250 km; it is a judgement, and cover depth also rises with distance in this table.

**Why new fits are still needed.** About half of the withheld cells are already 250 km or more from training (295, 190 and 322 of about 563 per direction in June). But the shallowest cover band carries 58% of the target weight, and only about 57 such cells are that far away. Scoring existing far cells alone would rest most of the weight on them.

### 2.5 What it can and cannot show

**Can show:**
- Which model predicts best where it has neither the cover mixture nor any neighbour.
- Whether a location term, and of what size, helps at new places (the pairs table). The saved outputs already suggest yes for coarse sizes.
- How much of each model's protocol 2 skill came from neighbours.
- Whether the choice depends on one region.

**Cannot show:**
- The response to a change of cover at a fixed place, which is what the forcing uses. No modern holdout observes it. Scoring differences between paired cells was filed by Chris on 2 November and is not reopened here.
- Whether the location term is right for the past, when climate differed.
- Accuracy inside the modern cover range, which is 87% of the hindcast's weight.
- Anything beyond the distances tested, such as the December hindcast cells more than 1,000 km north of any fitted cell.

**It is harder than the hindcast from March to September.** The hindcast knows each cell's own modern albedo; this test hides it. If the fine-scale location pattern is real and lasting, the test penalises the flexible location term unfairly. If it stands for climate or snow, as Andria thinks, the test is the right one. Roberts and Trachsel and Telford both warn of this pessimism.

**The Alaska fragility.** Not reduced by construction, and probably not in practice. Among existing cells 250 km or more from training, location 500 fails mainly in the first direction, which holds the Alaskan cells (RMSE about 0.20 against 0.06 for `loc100_linear`); in the other two directions the two are close (0.07–0.09 against 0.06–0.08). The saved tables cannot say how much of that is Alaska. The method makes the dependence a standard output, and the failure is relevant: in winter the hindcast predicts north of every fitted cell.

### 2.6 The one alternative: re-score protocol 2 with matched distances, no fits

Add the distance band to the scoring group and weight each group by the hindcast's own share at that cover depth and distance (the Meyer and Pebesma principle in both spaces). About 25 lines, no fits.

It is honest about the hindcast's geography, including the far-north winter. It does not deal with autocorrelation from March to September, where all the weight would fall on cells under 100 km from training (about 70 to 110 per direction). I do not recommend it as the answer to Chris's request.

## 3. Reuse, replacement and deletion

**Reused unchanged:** the cover triangle and hull, directions, tails, target weights, `withheld_departure()`, `cv_score()`, `cv_choose()`, `cv_paired_by_band()`, `cv_by_region()`, `nearest_km()`, the block bootstrap, the fitter and its retry, the three-stage tool, and the fifteen registered candidates. No new package.

**Replaced:** the rule "scored if under 250 km" becomes "tested cells are at least 250 km from training". `cv_nearby_coverage()` is kept under a plain name, since `compare_cv_hindcasts.R` reads its table.

**Deleted:**
- the in-range blocked holdout and `inrange_report()`; its question is now asked by the main folds, and its protocol 2 result stays on record;
- `cv_nearby_depth()`, `cv_distance_maxima()` and the northeast depth table; with one scored population the near/all split is gone;
- the comparison of memberships with run 1.

Protocol 2's outputs and document stay as the record of the test with neighbours present.

**Estimated lines:**

| Part | Added | Removed | Net |
|---|---:|---:|---:|
| `R/cross_validation.R`, `tools/cross_validate_albedo.R`, `R/hindcast_comparison.R` | 85 | 115 | −30 |
| Tests | 55 | 100 | −45 |
| Protocol 3 document | 120 | 0 | +120 |
| Twelve verification specifications (one per direction and cluster, all months in each) | 120 | 0 | +120 |
| README, changelog, question files | 20 | 0 | +20 |
| **Total** | **400** | **215** | **+185** |

**Additions that need Chris's explicit approval**, shown apart from the deletions:

| Addition | Lines |
|---|---:|
| The geographic exclusion at h, which reverses decision 7 | about 15 |
| The K geographic clusters | about 10 |
| The three report tables | about 35 |

## 4. Cost in model fits

| Work | Fits |
|---|---:|
| Protocol 2, measured: directional fits | 540 |
| Protocol 2, measured: in-range fits (deleted here) | 24 |
| **Recommended, K = 4: 4 × 3 × 12 × 15** | **2,160** |
| With K = 3 or K = 5 | 1,620 or 2,700 |
| Recovery, only if the winner is new | up to 240 |
| The winner's pipeline, only if it is not one of the three already run | 192 |
| The alternative | 0 |

Measured runtimes of protocol 2 (fit logs, single thread, six at once):
- the 540 directional fits took 974 fit-minutes in total;
- model 8 took 587 of them, and one of its fits took 342 minutes;
- `loc500_tp50` took 136, `lin_cover` 79, `cover_elev` 60 (one fit did not converge), and each other candidate under 40;
- the 24 in-range fits took 72 fit-minutes.

I give no estimate for the new fits. Their training sets are smaller, and whether that changes fitting or convergence is not known.

## 5. Questions

**For Chris**

1. Do you reverse decision 7 of 2 November, so that the new-place score chooses the model? The other course is to report it beside protocol 2's choice.
2. Is h = 250 km acceptable as a judgement resting on the table in 2.4? The published way is a variogram of residuals, which needs twelve quick fits and about 25 lines, and is a new step.
3. Is K = 4 acceptable at 2,160 fits? K = 3 costs 1,620 and removes more training cells per fit.
4. If the choice changes when one geographic cluster is left out, does the choice stand with the dependence shown, as in protocol 2, or is no choice made among the models that swap?
5. Do the three report tables go in?

**For Andria**

6. Is the fine-scale pattern in the location term something you would carry unchanged into the past, or does it stand for climate and snow? If the second, judging the model on places it has not seen is the right test; if the first, it is too hard on the flexible location term.
7. The test tells us whether a location term helps predict new places. It cannot tell us whether the term is right for the past. Is that enough for the question you raised on the call?

The winter cells north of every fitted cell are already question 8 of section 8 in the scientific questions file; this method tests that kind of prediction, so its answer matters here.

## 6. Not worth doing, and limits

**Not worth doing**

- **Plain spatial block folds without a buffer.** Most tested cells would sit beside a training cell.
- **A buffer round every tail cell at once, with no clusters.** Same fit count as protocol 2, but it removes so many cells that the winter months are likely to fail the training-row rule. Not measured.
- **Withholding all three tails in one fit** to cut fits. It trains on core mixtures only and changes the approved cover construction.
- **Leave-one-out h-block.** One fit per tested cell.
- **Trimming the candidate list.** It needs a second list beside the one the separation tool uses, and the four cheapest-to-drop candidates took only 138 of the 974 measured fit-minutes.
- **Predicting the buffer cells as an in-range report.** Few of them would be far from training.
- **Equal weight per cluster to damp Alaska.** It would leave the hindcast weighting.
- **A new package** for folds or variograms.

**Limits**

- This is the third selection on the same development data; the score is a selection score and is optimistic.
- The joint fold has no direct precedent.
- h and K are judgements.
- Removing neighbours shrinks the training range of cover, so tested cells move to deeper bands. Coverage of the shallow band, which carries 58% of the weight, must be read from the holdouts stage before any fit.
- The reference checkers were not run, and several papers were read as abstracts or through a summarising fetch tool, as marked in section 1.

### Critical Files for Implementation

- /home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/R/cross_validation.R
- /home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tools/cross_validate_albedo.R
- /home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tests/test_cross_validation.R
- /home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tests/test_cross_validation_stages.R
- /home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/R/hindcast_comparison.R
