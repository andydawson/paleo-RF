# Reconciliation of the two cross-validation fold designs (Fable, 23 November 2026)

**Benefit to the paper:** one agreed method to put to Chris, so the albedo model is chosen on cells that are both a new place and a new cover mixture.

I read Astra's design in full and checked the claims that matter against the repository and the protocol 2 outputs. Nothing was changed or run. On two points I was wrong and Astra was right; they are marked.

## 1. Where the two designs agree

- **The mechanism.** Cross a geographic holdout with the three existing cover-tail exclusions, and remove training cells within a buffer distance of the tested cells.
- **Two masks.** "Tested" and "excluded from training" must become separate frozen fields; today one flag does both (`tools/cross_validate_albedo.R:114-118`).
- **Unchanged parts.** The fifteen candidates, the cover geometry, the directions, the 80th-percentile tails, the squared-error score, the hindcast weights by month, direction and cover band, the one-standard-error rule and the three-stage tool. No new package.
- **Deletions.** The separate in-range holdout with its 24 fits, and the comparison of memberships with run 1.
- **Reports at no extra fit.** Each location size against no location at the same cover form, and each geographic group's and block's share of the paired differences.
- **Fit count is the same formula:** groups × 3 × 12 × 15.
- **Limits.** It is not distance matching to the hindcast; it cannot show the response to cover change at a fixed place; it cannot promise less dependence on Alaska; the score is a selection score on development data.
- **Precedent.** Neither of us found a published recipe identical to the joint fold. Astra adds Wang et al. (2023), "Spatial+", doi:10.1016/j.jag.2023.103364, a joint geographic-and-feature method; I confirmed its identity against Crossref but did not read it.

## 2. The real differences

### 2.1 Geographic groups: Astra's bands, with one caution

I now recommend **Astra's five contiguous west-to-east groups of whole 5-degree columns**, with every complete cell in the held-out group tested.

- It is simpler than my seeded k-means clusters of tail cells: no seed, one partition for all three directions, and it can be drawn on a map for Andria.
- It gives inside-range predictions for all fifteen candidates from the same fits. I dismissed that in my design; in the band design it works.
- **Caution, not measured:** Alaska very probably falls wholly inside the westernmost group. Every model then extrapolates to all of Alaska with no Alaskan training cell, so the Alaska dependence becomes one of five units by construction. The calibration table is not readable without R, so I could not count the groups.
- The bands remove more training cells per fit than my clusters did (a fifth of the cells plus a strip on each side). The smallest protocol 2 training set is 914 rows in December against 748 coefficients (`feasibility.csv`), so some winter splits will probably be untested. Astra says the same.
- Most cells in a band will be much farther from training than the buffer. The holdouts stage must show the achieved distances before any fit.

### 2.2 Buffer distance: Astra is right

- **250 km is not an estimated range.** My table of error by distance mixes distance with cover depth, as I said, and Astra is right that it cannot fix the distance.
- **I was wrong that residual plots need twelve new fits.** Every finished pipeline run already holds full-data no-location fits for all twelve months (`calibration_mod_cover_elev_<month>.RDS`, for example in `run1-main`).
- I recommend Astra's course: plot the spatial dependence of those residuals first, and Chris fixes one distance before any fold fit.
- Two additions of mine:
  - There is no variogram or correlogram code in the repository, so this is about 30 new lines and needs approval as a step.
  - To avoid a search, choose among the existing band edges of 100, 250 and 500 km.
- Under the band design the buffer matters only for cells near a band edge.

### 2.3 Scored cells and target: test all cells, but I keep the outside-hull target for the choice

- **Tested cells: Astra's.** Test every complete cell of the held-out group.
- **Averaging: Astra's.** Average a cell's repeated appearances before the group mean; it is needed once a cell is predicted under three cover exclusions.
- **Target for the choice: I disagree.** Astra recommends the complete historical target. I recommend the outside-hull target chooses and the inside-hull score is reported beside it for all fifteen.
  - The inside-hull part is 87.2% of the weight (`target.csv` sums to 0.128158 outside).
  - Inside the hull, a new-place test measures geographic transfer at familiar cover. From March to September the hindcast does not do that; both designs say so.
  - With the complete target, cover novelty would be 13% of the score and the choice would be mostly a contest in geographic transfer.
  - It reverses Chris's decision 6 of 2 November ("skill inside the training range is reported, not mixed into the selection score").
- Astra's counter-argument is fair: a choice made on 13% of the hindcast is narrow. This is Chris's decision.

### 2.4 Uncertainty: unresolved

- Astra resamples the five geographic groups. I would keep the existing resampling of 5-degree blocks.
- Astra's worry is sound: blocks inside one held-out band share their fits. The four adjacent Alaskan blocks failing together is the example, and block resampling called that 2.3 to 3.5 standard errors.
- But five units cannot support a one-standard-error rule, and decision 7 of 2 November allowed that rule only with at least ten blocks.
- My recommendation: keep block resampling for the rule, say plainly that its standard errors are probably too small, and report the choice with each of the five groups left out.

### 2.5 Fit count

| Design | Main fits |
|---|---:|
| Protocol 2, measured | 540 |
| Mine, four clusters | 2,160 |
| Astra, five bands | 2,700 |

I accept 2,700. Four bands would cost 2,160 but remove a quarter of the cells per fit, which makes the winter months worse.

## 3. Errors and gaps in Astra's design

1. **Inconsistent uncertainty.** It keeps the ten-block feasibility rule and the one-standard-error rule while resampling only five groups (section 2.4).
2. **Decision 6 is not named.** The complete target is flagged as needing Chris's decision, but not as a reversal of a recorded one. The same holds for decision 7 ("no geographic buffers"), which both designs reverse.
3. **The residual plots are treated as existing preparation work.** No such code exists, and no lines are shown for it.
4. **Its own caution is not applied to its bands.** It cites Meyer and Pebesma against ever more distant holdouts, but gives no expected distance from a band's interior to training.

Checked and correct:
- all seven recorded job runtimes (for example d2 January 6 h 48 min 53 s; the winner pipeline 22 h 53 min 08 s);
- the 914 December rows and the 12.8158% target share;
- the single-mask problem;
- the downstream consumer at `R/hindcast_comparison.R:148`;
- recovery "up to 360". My "up to 240" assumed reusing model 8's recovery fits, which the tool does not do in a new run folder.

Not checked: the Telford and Birks section numbers, and the Hu and Valavi passages.

## 4. Joint recommendation

**Method**
1. Five west-to-east groups of whole 5-degree columns, fixed across months.
2. Each crossed with the three cover tails at a fixed 80th percentile; drop the 70/90 fallback, which protocol 2 never used.
3. One buffer distance, fixed by Chris before any fold fit from residual plots of the saved no-location fits.
4. Test every complete cell of the held-out group; average repeated appearances first.
5. Report the outside-hull and inside-hull scores separately for all fifteen candidates. Which one chooses is question 1.
6. Report location pairs and the five groups' contributions, with the choice when each group is left out.
7. Run the holdouts stage and read feasibility, coverage and achieved distances before any fit.

I drop my "what neighbours were worth" table; the inside and outside scores by distance cover it.

**Fits**

| Work | Fits |
|---|---:|
| Main cross-validation | up to 2,700 |
| Residual plots | 0 |
| Recovery, only if the winner is new | up to 360 |
| Winner's pipeline, only if not already run | 192 |
| **Most** | **3,252** |

Protocol 2's 540 main fits took 974 fit-minutes summed over single threads, 587 of them model 8. No estimate is given for the new fits.

**Lines**

Astra's estimate is the better one; mine left out most of the downstream reporting changes and the generated reports.

| Part | Added | Removed |
|---|---:|---:|
| Code and tests | 425 | 390 |
| Method record, README, changelog, questions | 200 | 10 |
| Fifteen fit specifications and the others | 200 | 0 |
| Residual plot step | 30 | 0 |
| Generated verification reports | 425 | 0 |
| Conditional recovery and winner records | 250 | 0 |
| **Total** | **1,530** | **400** |

Net about +1,130; hand-written about +455.

**Questions that remain**

1. **Chris: which target chooses the model?** The complete historical target (Astra), or the outside-hull target with the inside-hull score reported (Fable)? The first reverses your decision 6 of 2 November.
2. **Chris: do you approve reversing decision 7 of 2 November** ("no geographic buffers"), which both designs need?
3. **Chris: are five west-to-east bands acceptable, knowing Alaska is probably one whole band?** The other course is geographic clusters of the tail cells, which keep some Alaskan cells in training but need a seed and test only tail cells.
4. **Chris: which unit is resampled for the one-standard-error rule?** Five groups (honest about shared fits, too few for the rule) or 5-degree blocks (enough units, standard errors probably too small).
5. **Chris: what buffer distance, after the residual plots?** And do winter months that become infeasible stay untuned?
6. **Chris: if the choice changes when one group is left out, does it stand with the dependence shown, or is no choice made?**
7. **Andria: what does the location term stand for?** If it helps predict places the model has not seen, is that enough to keep it as an empirical adjustment, with its meaning as climate left open? And would you carry its fine-scale pattern unchanged into the past?

### Critical Files for Implementation

- /home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/R/cross_validation.R
- /home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tools/cross_validate_albedo.R
- /home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/R/hindcast_comparison.R
- /home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tests/test_cross_validation.R
- /home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/docs/cc/2026-11-23_cv_spatial_folds_design_codex_gpt6astra.md
