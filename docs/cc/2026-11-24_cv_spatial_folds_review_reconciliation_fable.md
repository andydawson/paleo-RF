# Reconciliation of the two reviews of protocol 3 (Fable, 24 November 2026)

One round, read only. I read Astra's review in full and re-checked the claims marked "re-checked" against the code and the saved tables. Nothing was run. Directions 1, 2 and 3 are the cover departures "less evergreen, more summergreen", "less open land, more summergreen" and "less summergreen, more open land". h is the buffer distance.

## 1. Where we agree

- **The exclusion logic is sound.** A tested tail cell stays outside the training range however many neighbours are removed, and the two masks are needed (`tools/cross_validate_albedo.R:114`). Re-checked by reasoning and against the stop at `:176`.
- **The test does not match the hindcast.** Past cells sit at fitted cells from March to September, and the December median for direction 1 is 1,360 km (`comparison.csv`, read by both). The score can prefer a coarser location term because it carries across space better. That shows neither a more accurate hindcast nor a more correct vegetation response.
- **Astra's finding 2 is right and I missed it.** Fable's design (lines 96 and 170) says the new-place test is "the right one" if location stands for climate. That is unsupported: the pipeline carries today's location surface unchanged through time (`scripts/6_prediction_model.R:45`, re-checked).
- **The buffer distance is a judgement, not an estimate.** Name the model and the residual type, keep every month, record the limits, and do not default to the largest radius.
- **Coverage.** "Represented" counts cover groups, not geography. A piece can drop out while every group stays represented, and when a group is lost the score is renormalised over those that remain (`R/cross_validation.R:222-227`, re-checked). Astra's two worked examples are the clearest statement of this; my review said it less sharply.
- **Standard errors are a rule of thumb.** In protocol 2, 135 of 1,000 draws missed a group (`scores.csv`, re-checked). Five degrees of longitude is 190 km at 70 N (re-computed), smaller than a 500 km buffer.
- **Numbers.** December allowances of 339, 292 and 166 cells; 58.4% in the shallowest band; 12.8158%; 2,160 and 2,736 fits. I re-counted two entries of Astra's block table by hand from the cell lists: December has 24 blocks in direction 1 and 29 in direction 2. Both match.
- **Keep and delete.** Keep the in-range holdout and the monthly depth table. Delete the protocol 1 comparison (23 lines). No rule requiring all four pieces, no radius search, no bootstrap over cluster labels, no regional reweighting.
- **Tests.** Astra's test that a zero buffer reproduces the pooled all-distance score, and its two coverage fixtures, are right and sit beside mine.
- **Agreed but unchecked by me:** the fit-minute totals (Astra read the logs) and the passages of the three papers (Astra read them; I had no web access). Its reading that Trachsel and Telford use cross-validated residuals is more exact than my recollection.

## 2. Disagreements

### 2.1 Is the direct construction the simplest defensible one, and can re-scoring replace it? Conceded.

- **Astra is right on both counts.** For the experiment as chosen I found no simpler construction. One ring round the whole tail would remove every cell just inside the cover cut and so empty the shallow band. My rough count also puts December's direction 3 at about 160 ring cells, give or take half, against an allowance of 166.
- **Re-scoring cannot supply the shallow-cover evidence.** Only 57 cells of the shallowest band, which carries 58% of the weight, are 250 km or more from training, and they are not the region-edge cells the new fits would test. My phrases "answers most of the question" and "add only the shallow band" were too strong.
- **What I keep:** the re-score as a preview, not a substitute. It shows whether the choice is likely to change and how much rests on the north-west, for about 15 lines and no fit. Astra did not ask for it. It is question 2.

### 2.2 Does the question of what the score is for go back to Chris? Unresolved.

- We agree on the facts (Astra's finding 2, my finding 1). Astra keeps the decision of 24 November and corrects the wording.
- I recommend asking Chris again, because three things were not in the designs he decided on:
  - between 79% and 94% of the target sits at a fitted cell's own place (my bounds);
  - the tails are about eight whole regions, so most tested cells are several times h from training;
  - the saved far cells suggest the same model would win, resting more on the north-west.
- Neither reviewer can settle this. It is question 1.

### 2.3 The correlogram. Largely conceded.

- **Astra is right that it can stand as a stated judgement,** and Chris approved the step. I withdraw "do not build it"; that deletion becomes optional.
- **I keep three points Astra does not address:**
  - 100 km is not a real option (section 3);
  - the saved fits carry no coordinates, so `check_full_month_rows()` (`R/cv_separation.R:123-131`) must pass before residuals are placed on the map;
  - the existing error-by-distance table belongs beside the plot.
- **We expect opposite failures.** Astra expects too short a range, because cover and elevation absorb structure. I expect too long a range in the snow months, where a model without location is two to five times worse on withheld cells (`scores_by_month.csv`), and a short one in July and August. Neither of us has seen a plot; the monthly plots settle it.

### 2.4 Where the ten-block rule applies. Disagree.

- **Positions.** Astra: per split, and do not pool across clusters. Fable: per direction and month, as now, with training rows judged per split.
- **Evidence.** The rule today is per directional holdout and month (protocol 2, section 4; decisions of 2 and 3 November). Per split it is up to four times stricter. By my hand count the whole Cordillera south of 53.5 N lies in 8 blocks, so no compact piece of it can be tested in December under a per-split rule. Astra's own table gives direction 3 only 35 blocks to share among four pieces in summer.
- **What would settle it:** the holdouts stage, with no fit, printing blocks per split and per direction and month. It is question 5.

### 2.5 When to update the hindcast comparison's reader. A difference of timing.

- Astra is right that if protocol 3's score becomes the basis, `validation_limits()` and the captions must change before the comparison is next used.
- I would not do it in the same change. Protocol 3 should write to its own folder now, and the reader should follow once the basis is confirmed and the result is in.

### 2.6 Smaller differences

- **Clustering.** Astra keeps seeded k-means with a recorded seed and one stated distance measure. I prefer `hclust()` on kilometres with no seed. This is a simplicity preference, not a scientific difference.
- **Winter.** Astra names January and November as the next concerns after December. My rough ring counts (50 to 165 cells per piece) against allowances of 476 and more suggest they are not at risk on training rows. Neither is measured; the holdouts stage settles it.

## 3. Errors in Astra's review

- **It accepts "100, 250 or 500 km".** On the one-degree grid north and south neighbours are 111.2 km apart, so 100 km removes only east and west neighbours, and none south of 26 N. Its own check that every scored cell meets h would pass with adjacent training cells. The review of 10 November already records this.
- **It calls the per-split requirements "existing" and "approved".** The existing code has no splits; the existing ten-block rule is per directional holdout and month. The brief lists per-split feasibility in the method under review, not among Chris's three decisions.
- **"The score arithmetic agrees with the stated method" holds for `cv_score()` only.** The score stage first applies `cv_scoring_rows()`, which keeps cells under 250 km (`R/cross_validation.R:32-34`; `tools/cross_validate_albedo.R:421-422`), and `cv_feasibility()` uses the same mask. Astra flags the downstream reader of that cutoff but not the mask in the score itself.
- **Omissions that matter.**
  - The tails are whole regions, so "at least h" understates the distance.
  - Each model now needs up to 144 converged fits, and one failure makes it ineligible.
  - The two tables the brief calls "kept" (location pairs; block and cluster contributions) do not exist in the code, though Astra's test list assumes the second.
  - Three recorded decisions are reversed and should be recorded as such.
- **The kernel hand check** is arithmetically right (re-done) but outside this change. I did not check the kernel units it quotes.

## 4. What Chris should decide before anything is built

Both reviews say the folds should not be fitted yet.

1. **What is the separated score for?** It tests cells with neither their cover mixture nor any training cell within the buffer. Most are several hundred kilometres from training, while most of the past target sits at a fitted cell's own place. Both reviewers agree it may prefer a coarser location term because that carries across space better, which shows neither a more accurate hindcast nor a more correct vegetation response.
   - (a) It chooses alone, recorded as a choice for transfer to separated modern places. This is Astra's position.
   - (b) It is reported beside protocol 2's score and a choice is declared only if both pick the same model.
   - (c) It is a report and protocol 2's choice stands.
   - **Recommendation: (b).**
2. **A preview from the saved predictions before any fit?** Scoring protocol 2's saved predictions on cells 250 km or more from training takes about 15 lines in a verification specification. It cannot replace the fits, because too few shallow-cover cells are that far away. It would show whether the choice is likely to change and how much rests on the north-west. **Recommendation: run it first.** Astra did not ask for it.
3. **Which buffer distance?** It is a judgement; the cited papers give no way to estimate it for a model with its own location term. On this grid 100 km removes only east and west neighbours. At 500 km December's direction 3 is at the limit of the training-row rule. **Recommendation: 250 km, recorded as a judgement.** Keep the correlogram as a description, by month, with the alignment check and the existing error-by-distance table beside it.
4. **Round which cells is the ring drawn?** Either every tail cell of the cluster in every month, giving one frozen membership per split, or only the cells tested that month, which keeps a few more winter training cells. **Recommendation: every tail cell of the cluster.**
5. **Where does the ten-block rule apply?** Either per direction and month over all its tested cells, as now, or per split. Per split, some pieces can never be tested in winter and direction 3 is short even in summer. **Recommendation: per direction and month, with training rows judged per split and a table per split shown.** Astra recommends per split with the losses stated.
6. **When a piece drops out,** does the score still choose with the missing geography listed, or is that month and direction untested? **Recommendation: it still chooses,** with coverage labelled as cover-group weight and the per-split table beside it, and no rule requiring all four pieces. This is consistent with Astra's proposed correction.
7. **The one-standard-error rule.** Both reviewers hold that the block standard errors are a rule of thumb and probably too small. **Recommendation: keep the rule and report how many times larger the errors would have to be for a simpler model to be chosen** (4.3 in protocol 2; 2 lines). Also check the saved predictions with 10- and 20-degree blocks (5 lines in a specification, no fit). Astra asks only that the caveat be kept.
8. **One region carrying the margin.** If one region supplies most of the winner's margin, as four Alaskan blocks did in protocol 2, does the choice stand? **Recommendation: it stands with the contributions shown, and there is no automatic rule.** Both reviewers reject an automatic veto.
9. **A failed fit.** Each model now needs up to 144 converged fits instead of 36, and one failure makes it ineligible. One of 540 failed in protocol 2. **Recommendation: the rule stands, and every ineligible model is listed beside the choice,** so that a choice made in a strong candidate's absence is visible.
10. **Approvals.**
    - The table of location pairs and the table of block and cluster contributions, about 15 lines each. Both are new. **Recommendation: yes.**
    - Removing the 70th and 90th percentile fallback, which was never used. It is your rule of 3 November. **Recommendation: yes.**
    - Clusters by `hclust()` on kilometres with no seed, or seeded k-means with a recorded seed. **Recommendation: the first.** Either works if frozen in `holdouts.rds`.
    - Protocol 3 writes to its own output folder. **Recommendation: yes,** with the hindcast comparison's reader updated once the basis is confirmed.

**For Andria, not blocking the build.**
- Which claim should the choice of model support: that it predicts albedo at places it has never seen, or that it gives the right change in albedo when cover changes at a place it has seen?
- Does the evidence that the location term matters in the snow months but not in July and August fit her reading of it as climate?
- Astra's question to her, whether separated modern skill is enough to keep location as an empirical adjustment, is the first of these from the other side.

Read for this round: `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/docs/cc/2026-11-24_cv_spatial_folds_review_codex_gpt6astra.md` in full; `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/scripts/6_prediction_model.R` lines 28-55; one count in `/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2/validation_cells.csv`. Three tool calls before this hand-back.
