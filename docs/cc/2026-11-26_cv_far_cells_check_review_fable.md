# Review of the no-fit far-cell check (`tools/check_cv_far_cells.R`, commit 79de462)

Fable (science-reviewer role), 26 November 2026. Read only: nothing was run or changed, and I have not seen Astra's review. Figures marked "my sum" were worked by hand from saved text tables; nobody has checked them.

**Paths.**
- Script: `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tools/check_cv_far_cells.R`. Line numbers below are its lines unless another file is named.
- Its first outputs: `/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/farcheck/`.
- Protocol 2's saved tables: `/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2/`.

**Words used.**
- Far cell: a withheld cell 250 km or more from the nearest training cell of its holdout. Far score: protocol 2's score on far cells. Nearby score: protocol 2's own score, on cells under 250 km.
- Group: one month, one direction of cover departure, one band of distance outside the modern cover range. Shallow band: less than 0.02 outside.
- Directions 1, 2 and 3: less evergreen and more summergreen; less open land and more summergreen; less summergreen and more open land.
- Leader: `loc100_linear` (location term of 100, straight-line cover), protocol 2's choice. `loc100_tp50`: the same location term with curved cover. `loc12_...` and `loc30_...`: coarser location terms. Model 8: location 500, curved cover 200.

## Verdict

No arithmetic error found. The script computes what decision 1 asked for, and two of its numbers reproduce by hand from protocol 2's own saved tables. It can go to verification after small deletions. The summary drafted for Chris should be reworded first: as written it makes the far result look firmer and broader than it is.

## Benefit

Before up to 2,160 buffered fits are run, it shows Chris whether scoring only withheld cells far from training would change the chosen albedo model, and how much of the past target the hindcast predicts at places where the model was fitted.

## Short answers to the eight questions

1. **Same score except for the distance condition?** Yes, read against `stage_score()` (`/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tools/cross_validate_albedo.R:403-424`) and by hand checks (b) and (c).
   - The differences are the mask (line 27), the ten-block rule counted on far cells (lines 31-36) and eligibility judged over the scored months (line 49). The last two change nothing here, because all 36 holdout-months qualify.
   - One difference the brief does not name: the far score covers all 120 groups and the nearby score 108. Direction 2's deepest band (2.06% of the weight) has no nearby cell, so the two columns are not averages over the same groups.
2. **Far rows selected correctly?** Yes.
   - The far-scored counts in `far_feasibility.csv` equal protocol 2's own `far_cells` in `groups.csv` in all 36 month-direction cases (total 6,940; my sums).
   - In `validation_cells.csv` I counted 198 far rows for direction 1's holdout in December, as the script reports. The 8 rows of December's direction-1 shallow group are 287 to 485 km from training.
3. **Shares additive and correctly signed?** Yes.
   - For `loc12_linear` and `loc100_tp50` the three direction parts sum to `far_difference` to 13 digits.
   - Positive means the leader has the smaller squared error.
   - Shares are of the net margin. Parts can be negative, so a share can pass 100% (`loc30_tp50`, direction 1: 102%).
4. **"At a fitted cell's own place": right weights and cells?** Yes.
   - Weights are each past cell-slice's target weight, from `cv_target_weights()` with the settings saved in `holdouts.rds`.
   - Cells are those with that month's albedo and every predictor (line 84), the same cells that give the month's cover range in `stage_holdouts()`.
   - The four distinct month-by-direction target weights in `far_at_place.csv` equal the band sums of `target.csv` to 15 digits. The monthly, directional and overall rows add up (0.120314 / 0.128158 = 93.9%).
   - `comparison.csv` agrees: the 90th percentile of distance to a fitted cell is zero wherever the share is 97% or more, and positive where it is 91% or less.
   - Not checked: which individual cells match.
5. **Do the skipped checks matter?** No.
   - The settings check compares the run's present configuration with `holdouts.rds`. The script never reads that configuration: it takes ages, months and latitude window from `holdouts.rds` (lines 79-82), and line 22 still checks the three input files by MD5.
   - On this run folder the check would stop without `--fill-missing`: its `config_used.R` has no `fraction_source` (searched), the case of `tests/test_cross_validation_stages.R:121-135`.
   - The geometry check guards against a predictions file with missing rows or changed geometry. These files passed it when protocol 2 scored them, and line 40 still refuses files made for other holdouts. Check 1 of the verification list below would catch a file changed since.
6. **Is the new guard needed?** Something must tie the rebuilt target to the frozen one, because lines 79-91 copy `stage_holdouts()` (lines 145-158 there). It need not be a `stop()` in the script (finding 4).
7. **What can the numbers support?** See the section of that name. In short: same choice both ways, on thin and concentrated evidence. The share at a fitted place is the one number that bears directly on what the score should be for.
8. **What could go?** Up to 18 of 121 lines.

## Useful deletions first

| What | Lines | Saves | Why |
|---|---|---:|---|
| The "runner-up" prints | 116-119 | 4 | The runner-up by score (`loc100_tp50`, 198 coefficients) is more complex than the leader (151), so the one-standard-error rule could never choose it. The comparison that matters is with the simpler models (finding 1). All shares stay in the CSV files. |
| The four calls that build the margins of the at-place table | 96-103 | 6 | Write the 36 month-by-direction rows with one `aggregate()` and one division. Print the monthly and overall shares from them on lines 120-121. |
| The `stop()` and the column that only feeds it | 87, 92-95 | 5 | Only if Chris prefers the equality asserted in the verification spec (+3 lines there). Finding 4. |
| `far_feasible` as its own column | 35-36 | 1 | `feasible` already implies the training-row rule: `f$scored = f$feasible & f$far_blocks >= CV_MIN_BLOCKS`. The third count in the message on 109-110 then goes. |
| Header lines that repeat lines 1-4 | 8-11 | 2 | |
| "over the far-scored months" in eligibility | 49 | 0 | Drop `& hm(predictions) %in% used`. Eligibility is then protocol 2's rule word for word and one named departure disappears. No number changes. |

Considered and kept: the ten-block rule on far cells (lines 29-36). It changes nothing here, but it is what makes "the protocol's own machinery" true, and its counts (15 to 30 far blocks per holdout-month) are evidence in themselves.

## Hand check

No forcing, kernel, ice margin or sign of forcing is touched. The only sign is "model minus leader".

**(a) The smallest case, against lines 63-64 and `cv_score()`** (`R/cross_validation.R:222-227`).
- Two groups: g1 has weight 0.3 and two rows, in blocks A and B. g2 has weight 0.1 and one row, in block B.
- Squared errors: leader 0.01, 0.02, 0.04; other model 0.03, 0.02, 0.10.
- Scores: leader (0.3 x 0.015 + 0.1 x 0.04) / 0.4 = 0.02125; other (0.3 x 0.025 + 0.1 x 0.10) / 0.4 = 0.04375; difference 0.0225.
- Script: row weights 0.15, 0.15, 0.10; contributions (0.02 x 0.15, 0, 0.06 x 0.10) / 0.4 = 0.0075, 0, 0.0150; sum 0.0225. Block A gives 33%, block B 67%.
- Agrees: additive, and positive where the leader is better.

**(b) A margin by direction, from protocol 2's own tables.** Direction 3's part of `loc12_linear`'s margin, from `by_distance_month.csv` (rows at 250 km or more) and `target.csv`.
- Shallow band: the twelve monthly differences of mean squared error sum to 0.0208115. Times the group weight 0.000762393 gives 1.58665e-5.
- Next band: the twelve differences of group means (72 rows at 250 to 500 km and 20 to 25 beyond, pooled) sum to 0.0245885. Times 3.39899e-5 gives 8.3576e-7.
- (1.58665e-5 + 8.3576e-7) / 0.128158 = 1.303258e-4. The script's `far_by_direction.csv` has 1.303258e-4. Agrees to 9 digits.

**(c) One block, which turns out to be one cell.** The block "lon -165 to -160, lat 50 to 55" holds a single calibration cell: Unimak Island, 164.5 W, 54.5 N, 760 km from the nearest training cell. It is in direction 1's shallow group in eleven months.
- Model 8 minus leader, squared error, from `by_distance_month.csv`: 1.32703 summed over March to September (row weight 0.0032135 / 20), 0.33595 in October (0.0033738 / 10), 1.04451 over January, February and November (0.0033738 / 9).
- (2.13221e-4 + 1.13341e-4 + 3.91553e-4) / 0.128158 = 0.00560337. The script's `far_by_block.csv` has 0.00560337. Agrees to 8 digits.

**(d) Agreement with the earlier approximation.** The far RMSEs (0.059, 0.075, 0.083, 0.093, 0.098, 0.102; 0.150 for model 8) are within about 0.003 of the month-pooled hand figures in the review of 24 November.

## Findings, worst first

### 1. Should-fix before it goes to Chris: the far lead is thinner than the drafted summary says, and the summary mixes two models

- **Where.** Lines 116-119, and the brief's bullets "`loc12_linear` is 1.56 standard errors behind" and "Over the runner-up, 91% ... 48%".
- **What.** The runner-up by score is `loc100_tp50`, 1.35 standard errors behind. The 91% and 48% are its figures. `loc12_linear` is fourth by score; its own shares are 71% from direction 1 and 22% from that block.
- **Evidence** (`far_scores.csv` and `scores.csv`; difference divided by its standard error):

| Simpler model (coefficients) | Far | Nearby |
|---|---:|---:|
| `loc30_tp50` (128) | 1.33 | 5.89 |
| `loc12_tp50` (110) | 1.44 | 7.98 |
| `loc30_linear` (81) | 1.46 | 4.34 |
| `loc12_linear` (63) | 1.56 | 4.81 |

- **Consequence.** If the far standard errors are a third too small, the rule chooses a coarser location term. In the nearby score they would have to be 4.3 times too small. Both reviewers held on 24 November that these standard errors are probably too small. Quoting only 1.56 hides this.
- **A related oddity to state.** The three models with location 500 are 0.019 to 0.020 worse than the leader, six times its whole score, yet only 1.13 to 1.18 standard errors behind. Their deficit comes from a handful of cells (finding 2).
- **Fix.** Reword the summary: name the runner-up and give the table above. Lines: -4 (delete 116-119), or -3 if one line printing each simpler model's ratio replaces them. Carrying `difference` and `se_difference` from `scores.csv` on lines 52-53 adds no line.
- **Check.** The table above recomputed from the two CSV files.

### 2. Should-fix before it goes to Chris: the far score rests on very few cells, and the script's tables do not show it

- **Where.** No line is wrong. The evidence is in protocol 2's `groups.csv` (column `far_cells`), which the report should quote.
- **Evidence** (`groups.csv`, `target.csv`, `validation_cells.csv`; my sums):

| Group, far cells only | Share of the far score's weight | Far rows a month | Where they are in July |
|---|---:|---|---|
| Direction 1, shallow band | 30.7% | 20 from March to September; 8 to 10 from October to February | 9 on Banks Island, 8 in southern Georgia and northern Florida, 3 single cells in Alaska |
| Direction 2, shallow band | 20.5% | 5 (12 in December) | 4 in British Columbia, 1 in Rhode Island |
| Direction 3, shallow band | 7.1% | 20 to 24 | not looked up |

  - Together 527 of the 6,940 far-scored rows carry 58.4% of the weight. The nearby score has 124, 161 and 124 rows in the same three groups in a summer month.
  - In a summer month the far score's weights are worth about 72 equally weighted rows (606 scored), against about 610 (851 scored) for the nearby score.
  - The Unimak cell alone carries 2.0% of the far score's weight. Model 8's squared error there is 0.70 in January (observed albedo 0.16). It supplies 29% of model 8's far deficit (hand check c), 29% of `loc30_tp50`'s, 17% of `loc12_linear`'s and minus 7% of the runner-up's.
  - The "one Alaska block" at 48% is 19 cells with 4.0% of a summer month's weight. The eleven blocks west of 150 W give about 75% of the margin over the runner-up. The block label uses a box that starts at 55 N, so the Unimak block reads "elsewhere".
  - By month, direction 1 gives about 64% of the margin over the runner-up in May and about 20% in October, the months of snow melt and snow onset.
  - December's direction-1 shallow group is 31% of December's weight. Its far cells are eight cells in Georgia and Florida, while 46% of that direction's December target has no fitted cell at all.
- **Consequence.** "Represented target weight 1.000" and "all 36 feasible" read as broad coverage. They are not: a few dozen cells decide the far score. Its standard errors come from resampling 63 blocks, of which a few carry most of the margin.
- **Fix.** Report the rows behind each group's weight from `groups.csv`. Lines: 0. Optional, and Chris's call: a share of the margin by month, `margin_share(e$month)`, +1 line.
- **Check.** The row counts above against `groups.csv`.

### 3. Should-fix: the verification as described would not test the new numbers

- **What.** The reproduction of `scores.csv` with the condition reversed was a temporary edit. It cannot be repeated from commit 79de462, and `AGENTS.md` asks for a spec, not an ad hoc driver. It also proves only the old path: the plumbing into `cv_score()` and `cv_choose()`. It says nothing about `far_rows()` or the margins.
- **Fix.** The spec assertions in the next section. About +15 lines in the spec, none in the script.

### 4. Should-fix, Chris's word needed either way: the new `stop()` (lines 92-95)

- **What it guards.** The at-place share is computed from a per-cell target rebuilt by a copy of `stage_holdouts()`'s lines. On this branch protocol 3 will change those functions, so drift is a real possibility. It is not vacuous.
- **Why it is a question.** It is a new guard, which needs Chris's explicit approval under the simplicity rules. The same protection can be a spec assertion on a table the script already writes. The share uses months and directions, not bands, so the band-level comparison adds nothing to it.
- **Options.** Keep it (0 lines, with approval). Or delete lines 87 and 92-95 (-5) and assert in the spec that the 36 month-by-direction target weights equal `target.csv`'s (+3). I recommend the second, since decision 1 says the script is run by a spec.
- **Evidence it holds now.** The four distinct values agree to 15 digits (short answer 4).

### 5. Nit: records

- The brief says the result "decides" whether the separated score chooses. The decisions file says the question is "left open until the check is seen". No rule turns the result into the decision, so the report should give numbers and options, not a conclusion.
- The margin tables (lines 61-75) are not named in decision 1. The reconciliation of 24 November asked for approval of a contribution table, and the decisions file records no answer.
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/docs/cc/questions_for_andria_scientific_from_2026-10-20.md:403-409` still says nothing is designed or run. The reviewers' two questions for Andria of 24 November are in neither questions file (searched). About +6 lines of records.

## What the proposed verification misses

Assert these in the spec, on the script's CSV outputs.

1. **The far score by an independent route.** Recompute it from `by_distance_month.csv` and `target.csv`; it must equal `far_score` for the 14 eligible models. Hand checks (b) and (c) are two pieces of exactly this. Sketch, not run:

```r
bd = bd[bd$region == 'all' & bd$km_band %in% c('[250,500)', '[500,Inf)'), ]
bd$group = paste(bd$month, bd$own_direction, bd$cover_band)
bd = bd[bd$group %in% target$group[target$weight > 0], ]
g = aggregate(cbind(sse = mse * cell_month_holdouts, n = cell_month_holdouts) ~ group + model, bd, sum)
g$w = target$weight[match(g$group, target$group)]
again = sapply(split(g, g$model), function(m) sum(m$w * m$sse / m$n) / sum(m$w))
stopifnot(max(abs(again[far$model] - far$far_score), na.rm = TRUE) < 1e-10)
```

2. **Additivity.** For every eligible model the direction parts and the block parts each sum to `far_difference`.
3. **Rows.** `far_scored_cells` sums to `groups.csv`'s `far_cells` over groups with weight (6,940). Every holdout-month is scored, with at least 10 far blocks.
4. **At place.** The 36 month-by-direction target weights equal `target.csv`'s sums, and every share lies between 0 and 1.
5. **The two cross-validation test files** at the commit.

With check 1 in place I would not add the reversed-condition run. If it is to be cited, the spec must do it; otherwise the report should call it a one-off.

What none of this shows: the far standard errors, the 153 resamples that missed a group and the far choice rest on `cv_score()`'s resampling. Only the unit tests and protocol 2's own run anchor it.

## What the numbers can and cannot support

**They can support:**
- On protocol 2's fits, scoring only far cells gives the same leader and the same choice, `loc100_linear`.
- A location term of 500 does as badly far from training as no location term (far scores 0.022 to 0.023, against 0.017 and 0.024). Near training it was close to the leader (0.0035 to 0.0044, against 0.0024).
- 93.9% of the outside-range target weight lies at a place where that month's full-data model was fitted: 99.5% from March to September, 77 to 81% from November to January. All of the shortfall is in direction 1 (54 to 62% at place in those three months).

**They cannot support:**
- **That the far choice is firm.** The nearest simpler model is 1.33 standard errors behind, on standard errors both reviewers think too small.
- **That the far score is a broad test.** See finding 2.
- **What the buffered fits would choose.** Here 58% of the weight rests on about 57 cells. The buffered design would test several hundred shallow-band cells a month, with different fits.
- **That distance explains far minus nearby.** The two scores use different cells, months and group sizes.
- **That the nearby score matches the hindcast's task.** Both scores test cells left out of training. Neither observes changed cover at a place the model has seen.
- **Hindcast accuracy or the vegetation response.**
- **The share for the whole hindcast.** 93.9% is of the outside-range mixes only, which are 12.8% of the past target. For all past cells the record of 10 November gives 38% of the study area in December and 27% in January north of every fitted cell.
- **How much the 6.1% matters for forcing.** It sits in the dark months and has not been measured.

## Questions

**For Chris.**

1. **Does the separated score choose the model?** This is his open decision 2.
   - (a) Protocol 2's nearby score chooses; the far score, and the buffered score if run, is reported beside it.
   - (b) A choice is declared only if both agree. On protocol 2's fits they do.
   - (c) The separated score chooses.
   - My reading: the evidence weighs against (c). The target sits at fitted places, the far evidence is concentrated and thin, and nothing here suggests a different choice.
   - Meanwhile the script chooses nothing for the pipeline and protocol 2's choice stays provisional.
2. **Are the buffered fits still wanted?** The check cannot predict them.
   - (a) Run them as a report beside protocol 2's choice.
   - (b) Do not run them.
   - (c) Run them as the chooser.
   - Meanwhile nothing is built.
3. **The guard.** Keep the `stop()` in the script (needs his approval), or move the equality to the spec (-5 and +3 lines)? Meanwhile the script stops if the rebuilt target differs.
4. **The margin tables.** Approve the tables by direction and block (15 lines, written now)? I recommend yes: they are the evidence on concentration. Also add the share by month (+1 line)?
5. **The rule on far cells.** If a far or separated score is ever to choose, does the one-standard-error rule stand with the multiple (1.33 here) reported beside it? This was asked on 24 November and is not among the recorded answers.

**For Andria (not blocking).**
- The two standing questions of 24 November, still to be entered in the questions file: which claim the choice of model should support, and whether the location term stands for climate, chiefly snow.
- A new fact for the second: about 84% of the far lead over the second-placed model comes from May and October in direction 1.

## Not worth doing

- **Restoring the settings check.** It would need the `--fill-missing` plumbing (about +3 lines) to guard a configuration the script never reads.
- **Restoring the geometry check.** It is 10 inline lines of `stage_score()`, not a function, and these files already passed it.
- **Moving `stage_holdouts()`'s per-cell target into a shared function now.** The no-duplication rule favours it, but it touches protocol 2's frozen tool, needs the holdouts re-verified, and protocol 3 will restructure that code. Revisit only if this check outlives the decision.
- **Reusing `geographic_support()`** (`R/hindcast_comparison.R:133-139`). It would pull in that file and its packages to replace one expression.
- **Recomputing the nearby score inside the script, or a far option on `cv_scoring_rows()`.**
- **New analyses nobody asked for:** larger-block resampling, a kernel-weighted share, a far score without Alaska.
- **A test file for the script.** The spec's assertions on its outputs suffice.
- **Cosmetics:** the region label in `block_name()`, the constant columns `far_represented` and `far_resamples_missing_a_group`, the message from `pipeline_paths()`.

## Line cost

| | Lines |
|---|---:|
| Script, deletions | up to -18 (121 to 103), of which -5 depend on question 3 |
| Verification spec, assertions (tests of agreed behaviour) | about +15 |
| Records | about +6 |
| Optional, each needing Chris's yes | share by month +1; print of the simpler models' ratios +1 |

None of this is authorised by the review.

## Not checked

- No R was run. That covers the script's own run, the reversed-condition reproduction (the implementer's statement), the standard errors, the 153 resamples and the far choice.
- Directions 1 and 2 of the margins, except through their sums and the one block of hand check (c).
- Which individual past cells count as "at a fitted place". No `.rds` file can be opened here.
- `far_by_block.csv` beyond line 363 was searched, not read in full.
- Whether the working copy I read is byte-identical to commit 79de462.
- Astra's findings: not seen.

Files read in full or in part: 31 (18 in the repository, 5 outputs in the scratchpad folder, 8 in the protocol 2 run folder); 7 more searched only. Tool calls: 69 before this hand-back.
