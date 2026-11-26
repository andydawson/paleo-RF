# Reconciliation of the two reviews of the far-cell check (Fable, 26 November 2026)

One round, read only. I read Astra's review in full and re-checked the points marked "re-checked". Nothing was run. Line numbers are those of `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tools/check_cv_far_cells.R` unless another file is named. "Far" means withheld cells 250 km or more from training; "nearby" means under 250 km.

## 1. Where we agree

- **No numerical defect.** We reached this by different hand checks. I re-did Astra's two worked examples (an at-place share of 0.60; margin shares of 120% and minus 20%) and they are right. Astra has not seen my two reproductions from protocol 2's saved tables.
- **Same score as protocol 2 with the distance condition reversed.** All 36 holdout-months qualify, so the far-cell feasibility rule changes nothing here.
- **Far rows are selected correctly; shares are additive and correctly signed.** Astra adds that the direction shares and the block shares are two splits of the same margin and must not be added together. Agreed.
- **The at-place share is 93.88% and is rightly weighted.** It describes the outside-range target only, not all past cells and not the forcing.
- **Skipping the settings check changes nothing.**
- **Nothing new in the script:** no guard, no option for the distance condition, no extracted function.
- **The verification is missing.** Re-checked: the repository has no spec or report dated 26 November.
- **Far minus nearby is not a distance effect.** The two scores use different cells and different groups (100% against 97.94% of the weight).
- **The standard errors are descriptive.** 153 of 1,000 resamples missed a group. Concentration should be disclosed, with no automatic veto.
- **Limits of the rescore.** It does not show what buffered fits would choose, hindcast accuracy, or the sign of the vegetation response.
- **The seed.** Re-checked in `record_score.txt`: 1978221365.

## 2. Disagreements

**2.1 The prediction-geometry check. Conceded for the verification; we never differed about the script.**
- Astra is right that skipping it removed an assurance. The checksum on each predictions file ties it to the holdouts, not to their rows.
- My "No" was too flat. My independent recomputation would miss two cases:
  - a candidate that lost rows: its far score goes missing, and my sketch dropped missing values;
  - changed coordinates on far rows, which feed the block table and the far standard errors.
- Verdict: the spec repeats `stage_score()`'s comparison (`tools/cross_validate_albedo.R:406-415`) on the 36 saved files. About 8 spec lines, none in the script.

**2.2 The guard (lines 87 and 92-95). Conceded.**
- I put it to Chris as a choice. Astra is right that an unapproved guard comes out by default, and the equality moves to the verification.
- One correction to Astra's check is in section 3.

**2.3 Eligibility (line 49). Conceded.**
- I listed dropping `& hm(predictions) %in% used` as a zero-line deletion. It changes no result here, and which form is right when a holdout-month is not far-feasible has never been decided.
- By my own rule that belongs under "not worth doing", where Astra put it. Leave the line.

**2.4 The reversed-condition run. Conceded.**
- I called it optional. Astra is right to require it: it is the only executable check that the script's route into the resampling and the choice is protocol 2's.
- It can be done inside the spec by turning `>=` to `<` on line 27 of a copy, with no option in the script.

**2.5 Two of Astra's verification items. Disagree on form.**
- The items are the boundary case (250, 260 and 249.999 km) and the hand-worked at-place case.
- `far_rows()` and the share live inside a flat script that runs on a real run folder. The existing test fixture stores the calibration table in place of the past cover and ice tables (`tests/test_cross_validation_stages.R:17-21`, re-checked), so the script's target rebuild would stop on it.
- They would need an extracted function, which Astra itself rules out, or a new fixture.
- Re-checked in `validation_cells.csv`: no row lies at exactly 250 km. The nearest are 249.83 and 250.89 km.
- What would settle it: the two assertions on the real rows (items 5 and 7 below). By my sums from `far_feasibility.csv`, far plus nearby equals the withheld rows in all 24 holdout-months of directions 1 and 2.

**2.6 Size of the verification. Conceded.** My "+15 lines" was too low. With the items above the spec is about 45 lines, as Astra estimated. The report is written by the tool.

**2.7 What the 93.9% shows. No disagreement on the sentence.** Astra says it measures a mismatch between prediction tasks and does not prove spatial validation unnecessary. I agree. My reading that the evidence weighs against the separated score choosing is mine alone. It also rests on the concentration figures, which Astra has not checked.

**2.8 Approval of the margin tables. Withdrawn.** Astra treats lines 61-75 as within scope. Both reconciliations of 24 November asked for the concentration of the margin to be shown. It is not a question for Chris.

## 3. Errors and omissions

**In Astra's review.**
- **The 1.56 figure.** It reports `loc12_linear` at 1.56 standard errors as the figure of interest. Under the rule the nearest simpler model is `loc30_tp50` at 1.33, then 1.44 and 1.46 (`far_scores.csv`). The nearby score's figures are 4.3 to 8. This changes the summary.
- **An inconsistency in finding 1.** It deletes the distance column (line 87), then asks the verification to compare the rebuilt "groups and weights". Groups carry the distance band, which needs that column. The share uses month and direction only, and `far_at_place.csv` already carries those 36 weights.
- **"All five CSVs unchanged" has no committed baseline.** The first outputs are in a session scratch folder. Pin headline numbers instead.
- **Concentration is seen only through the margin** (one block, 48%). The weights were not examined: `groups.csv` puts 58% of the far score's weight on 527 of 6,940 rows.
- **Not checked by me:** its quotation of the commit message, and the passages of Roberts et al.

**In mine.**
- The gap in my recomputation sketch (2.1).
- The eligibility deletion (2.3).
- The guard framed as a question (2.2).
- The low line estimate (2.6).
- A question on the margin tables that was not needed (2.8).

## 4. Joint list

### Script changes

| Change | Lines | Backed by |
|---|---:|---|
| Delete the guard (92-95) and the distance column (87) | -5 | both |
| Leave eligibility (49) as it is | 0 | both |
| Delete the "runner-up" prints (116-119). The second-placed model is more complex than the leader, so the rule could never choose it. | -4 | Fable only |
| Write the at-place table as its 36 month-by-direction rows (one `aggregate()` and one division in place of 96-103). Print the monthly and overall shares from it. | -6 | Fable only |
| Carry `difference` and `se_difference` from `scores.csv` on lines 52-53, so the far and nearby distances in standard errors sit in one table | 0 | Fable only |
| Fold `far_feasible` into `scored` (35-36) and shorten the header (8-11) | -3 | Fable only, optional |

Total: -5 agreed, and up to -13 more on my reading alone (121 to 103 lines). Not in the script, both agree: the settings check, the geometry check, any guard, any distance option, any extracted function.

### Spec assertions

One spec, run by `tools/verify_change.R` at the corrected commit, about 45 lines.

1. The two cross-validation test files pass.
2. The 36 saved prediction files hold every frozen validation row once for each of the 15 candidates, with unchanged geometry. (Astra; conceded.)
3. A copy of the script with line 27 reversed reproduces `scores.csv` exactly: score, eligibility, standard error of the difference and choice. (Astra; conceded.)
4. The far score by an independent route, from `by_distance_month.csv` and `target.csv`, equals `far_score`. The candidates with a far score are exactly those with a nearby score. (Fable; not seen by Astra.)
5. The mask on the real rows.
   - In every holdout-month, far-scored plus nearby-scored rows equal the withheld rows in groups with weight.
   - Far-scored rows total 6,940, as in `groups.csv`.
   - All 36 holdout-months are scored, each with at least 10 far blocks.
   - This replaces the 250 km fixture.
6. Direction parts and block parts each sum to `far_difference` for every eligible candidate, negatives kept. (Both.)
7. The 36 month-by-direction target weights in `far_at_place.csv` equal `target.csv`'s sums, and every share lies between 0 and 1. This replaces the guard. (Both in substance.)
8. Pinned results: leader and choice `loc100_linear`, its far score 0.00346038, overall share 0.938791.

Left unasserted: which individual cells count as "at a fitted place". It is one expression, read by both of us and run by neither.

### Questions for Chris

1. **What is the separated score for?**
   - Checked by both reviewers:
     - On protocol 2's saved predictions, the score on cells 250 km or more from training picks the same model as the nearby score (`loc100_linear`).
     - 93.9% of the outside-range past target lies where the model was fitted that month.
     - The rescore cannot say what buffered fits would choose.
   - Checked by Fable only:
     - The nearest simpler model is 1.33 standard errors behind, against 4.3 in the nearby score.
     - 58% of the far score's weight rests on 527 of 6,940 rows.
   - Options:
     - (a) Protocol 2's nearby score chooses and the separated score is reported beside it.
     - (b) A choice is declared only if both agree.
     - (c) The separated score chooses.
   - Meanwhile the script changes nothing in the pipeline and protocol 2's choice stays provisional.
2. **Are the buffered fits (up to 2,160) still wanted?**
   - Options: (a) run them as a report beside protocol 2's choice; (b) do not run them; (c) run them as the chooser.
   - Meanwhile nothing is built.
3. **Add a share of the margin by month to the check (+1 line)?**
   - By my hand sums, about 64% of the lead over the second-placed model comes from May and 20% from October. A table would show that without hand sums.
   - Meanwhile the script writes shares by direction and block only.

For Andria, not blocking: the two standing questions of 24 November still need entering in the questions file. They are which claim the choice of model should support, and whether the location term stands for climate, chiefly snow.

Read this round: Astra's review in full; `record_score.txt`, `validation_cells.csv` and the verification folder, searched; the worktree's git pointer files, which no longer hold the quoted commit message. Tool calls: 9 this round, 78 in all before this hand-back.
