# Review of cross-validation protocol 2: implementation, results and interpretation

*Fable 5.2 (main session), 10 November 2026, at Chris's request. Reviewed: the protocol
(`2026-11-06_cv_protocol_v2.md`), the code at commit 1d31cfc (`R/cross_validation.R`, `R/cv_separation.R`,
`R/calibration_fit.R`, `R/model_registry.R`, `tools/cross_validate_albedo.R`, `tools/check_cv_separation.R`), the
saved outputs of the 53 verification jobs, the three finished pipeline runs, and what the main session told Chris
on 7 to 9 November. Nothing in the repository's code or in any run folder was changed. The scripts I ran and
their outputs are in `2026-11-10_cv_protocol_v2_results_review_checks/`.*

**Benefit to the paper.** The forcing depends on how albedo responds to a change of cover at a fixed place. This
review asks whether the cross-validation tells us that response is right, and finds a simple physical check that
does more than the prediction score can.

Names used below: **the chosen model** is `loc100_linear` (location term with 100 basis functions, elevation,
straight-line cover); **model 8** is the original (location 500, thin-plate cover with 200 basis functions); **the
flexible-location rival** is `lin_cover` (location 500, straight-line cover); **the coarse-location model** is
`mod8_coarse_loc` (location 30, thin-plate cover 200), the first run's choice.

## Verdict

1. **Implementation: sound.** I recomputed the selection score from the saved predictions with separate code and
   got the saved values for all fourteen scored versions (largest difference 5e-17). The standard errors and the
   northeast contrasts also reproduce. I found no arithmetic defect.
2. **Results: the protocol's choice stands, but "predicts best" is weaker than reported.** Sixty-one per cent of
   the chosen model's margin over model 8 comes from four blocks in western and interior Alaska (50 cells). Without
   them the flexible-location rival ties the chosen model. The test does robustly reject the no-location and
   coarse-location versions and model 8's cover form.
3. **Interpretation: needs revising.** The April and May comparison hides a strong seasonal pattern. Set against
   published forest contrasts, every fitted model is physically wrong in some months on the all-days albedo. An
   exploratory check shows the chosen model's wrong winter sign disappears on snow-free albedo, where it matches
   the published contrasts in sign in eleven of twelve months. Model 8's wrong sign in the northeast does not
   disappear.
4. **For the paper.** The early-Holocene forcing is stable across the three pipeline runs; the last 6,000 years
   are not, including the sign for 4 to 6 ka. The northeast darkening is a property of model 8, not of the data.

## 1. Implementation checks

| Check | Result |
|---|---|
| Selection score recomputed from `predictions_*.rds` with separate code (`recompute_selection.R`) | Equal to `scores.csv` for all 14 scored versions, to 5e-17 |
| Paired standard errors by an independent block bootstrap, 2,000 resamples (`bootstrap_check.R`) | 0.000140 against the tool's 0.000143 (next-best version); 0.000584 against 0.000541 (model 8) |
| Contrast helper against plain `predict(type = "response")` | April: -0.002036 (chosen), -0.041151 (model 8); the tool gives -0.0020 and -0.0412 |
| Capacity table against the pipelines' own April and May prediction fits (`northeast_by_month.R`) | Identical to four decimals for the chosen model, model 8 and the coarse-location model |
| Settings of the three pipeline runs (`config_used.R`) | Identical apart from `model_id`, the run folder and `allow_stale` |
| The 53 verification reports | All PASS |

Points to know when reading the outputs; none is a defect.

- **"PASS" means the job ran cleanly at the frozen commit with its input checks.** It is not a statement about
  the science. Only `cv2-tests` and `cv2-holdouts` contain checks of content.
- **The location term is at its ceiling at every size**: effective degrees of freedom 11 of 12, 28 of 30, 91 of
  100 and about 410 of 500 (`separation/capacity.csv`). REML is not smoothing it; the basis size is. That is why
  the grid's coarse steps (30, 100, 500) matter so much.
- **"Under 100 km" holds only east-west neighbours.** A cell's north-south neighbour is 111 km away and falls in
  the 100 to 250 km band (`CV_KM_BANDS`, `R/cross_validation.R:27`). Half of the scored rows are within 128 km.
- **`allow_stale = TRUE` in the model-8 and coarse-location pipeline runs** flagged 104 inputs of script 5 only,
  because script 4 had run as separate jobs with no record in that folder. Script 6 onward read inputs marked ok.
- **The open questions file was stale**: it still said the results were pending and that the concurvity cause was
  only suspected. Updated with this review.

## 2. Findings on the results, most important first

### 2.1 The preference for location 100 over location 500 rests on 50 cells in Alaska

- **Where:** the score and choice (`R/cross_validation.R:209-233`, `:342-361`;
  `tools/cross_validate_albedo.R:406-415`). The tool reports scores and standard errors, not where a difference
  comes from.
- **Evidence** (`bootstrap_check.R`, `alaska_check.R`, `final_checks.R`). The 9,070 scored rows lie in 94 blocks.
  Four blocks (within 160 to 150 W and 55 to 70 N; 50 cells, 546 rows) give 61% of the difference between model 8
  and the chosen model; ten blocks give 89%; in 47 of the 94 blocks model 8 is the better of the two.

| Selection RMSE | Chosen (`loc100_linear`) | `loc100_tp50` | Rival (`lin_cover`, location 500) | `loc500_tp50` | Model 8 | `loc30_tp50` |
|---|---:|---:|---:|---:|---:|---:|
| All scored rows | 0.0494 | 0.0512 (1.2 SE) | 0.0630 (2.3 SE) | 0.0595 (2.2 SE) | 0.0660 (3.5 SE) | 0.0625 (5.9 SE) |
| Without the four Alaskan blocks | 0.0482 | 0.0492 (0.8 SE) | 0.0483 (0.04 SE) | 0.0486 (0.2 SE) | 0.0557 (2.9 SE) | 0.0583 (5.2 SE) |
| East of 100 W only (no standard error computed) | 0.0399 | 0.0424 | 0.0353 | 0.0394 | 0.0473 | not computed |

  Bracketed values are the paired difference from the chosen model in its standard errors.
- **Why.** In those blocks the flexible-location versions run away when the neighbouring cells are withheld:
  January mean albedo observed 0.37, chosen model 0.29, model 8 0.84. That is the location term extrapolating at
  the north-west corner of the map. The hindcast never does this: it predicts at the fitted cells' own places.
- **Consequence.** The protocol's rule returns the same model without those blocks (lowest score, fewest
  coefficients), so the choice stands as the protocol's output. But "location 100 predicts unfamiliar cover better
  than location 500" is not supported outside Alaska. The two tied versions give different northeast answers in
  spring (April -0.002 against -0.036; May +0.003 against -0.043).
- **What is robust**, with or without those blocks: no location term is far worse (0.14 to 0.15); location 12 or 30
  is worse (5 SE or more); model 8 is worse than the simpler cover forms at its own location size (against
  `loc500_tp50`: 4.1 SE with the blocks, 3.7 SE without; against the rival: 1.4 SE with, 3.2 SE without).
- **Proposed check.** Add a small table of each block's share of the paired differences to the score stage, and
  report the score with and without the dominant blocks.

### 2.2 The linear and the 50-basis cover forms at location 100 are not separated

The next-best version is 1.2 SE behind (95% interval of the difference -0.00008 to +0.00047; the chosen model is
ahead in 91% of resamples). With each month's errors standardised by that month's spread of albedo the order
flips (0.430 against 0.436). Leaving out May flips it too. The rule's preference for the simpler form decides it.

### 2.3 The score speaks to 13% of the hindcast; inside the range the models tie

- **Evidence.** The historical target outside the modern range of cover mixes is 12.8% of the hindcast's weight
  (`target.csv`); by slice 4% to 17% (approximate: April's range, area as cosine of latitude, no ice weighting).
  In the northeast box it is 81% to 100% of every slice from 0.5 to 8.5 ka.
- Inside the range, the withheld-blocks diagnostic gives 0.0455 (chosen) against 0.0456 (model 8). Model 8 is
  better within 100 km (0.038 against 0.043, 1.5 SE); the chosen model is slightly better beyond 250 km (1.0 SE).
- Within 0.02 of the training range (60% of the score's weight) the chosen model, its rival, `loc100_tp50`,
  `loc500_tp50` and model 8 all score 0.042 to 0.046. The choice is made on the 40% that lies deeper.
- **Consequence.** Yet the pipelines differ most where cover is mostly inside the range:

| Forcing, study-area mean, HadGEM3 kernel (W/m²; positive is warming) | Model 8 | Coarse location | Chosen |
|---|---:|---:|---:|
| 0.05 to 0.5 ka | -0.56 | -0.16 | -0.14 |
| 0.5 to 2 ka | -0.57 | -0.30 | -0.09 |
| 2 to 4 ka | +0.35 | +0.39 | +0.06 |
| 4 to 6 ka | -0.45 | -0.17 | +0.20 |
| 6 to 8 ka | +1.51 | +1.66 | +1.54 |
| 8 to 10 ka | +4.96 | +5.12 | +4.95 |
| 10 to 12 ka | +4.13 | +3.65 | +2.87 |

  The chosen model's pipeline run passed (`2026-11-07_cv2-winner_report.md`). The other two kernels give the same
  pattern. So the split between location and cover matters across the whole study area for the last 6,000 years,
  and neither test measures the response to a change of cover at a fixed place.

### 2.4 Set against published contrasts, each model is wrong in some months

The capacity comparison covers April and May only (the protocol's choice, to limit fits). The pipelines' saved
fits allow the same calculation for every month with no new fit (`northeast_by_month.R`).

Northeast, historical-size exchange: evergreen falls by 0.18 on average (0.40 to 0.22) with open land held at 6 ka.
Positive means brighter after the decline. All 83 cells are outside the modern range in every month.

| Month | Chosen | Coarse location | Model 8 | Published contrast times 0.18 |
|---|---:|---:|---:|---|
| Jan | -0.036 ± 0.010 | +0.004 ± 0.053 | +0.050 ± 0.042 | +0.003 without snow, +0.015 with snow |
| Feb | -0.006 ± 0.009 | +0.074 ± 0.071 | +0.009 ± 0.035 | |
| Mar | +0.030 ± 0.007 | -0.014 ± 0.042 | -0.056 ± 0.025 | |
| Apr | -0.002 ± 0.004 | +0.052 ± 0.051 | -0.041 ± 0.019 | +0.006 to +0.011 (snow-free) |
| May | +0.003 ± 0.005 | +0.045 ± 0.049 | -0.074 ± 0.021 | +0.006 to +0.011 |
| Jun | +0.010 ± 0.004 | -0.017 ± 0.031 | -0.049 ± 0.018 | +0.008 to +0.013 |
| Jul | +0.013 ± 0.003 | +0.016 ± 0.010 | -0.007 ± 0.013 | +0.008 to +0.013 |
| Aug | +0.012 ± 0.003 | +0.021 ± 0.011 | -0.005 ± 0.014 | +0.008 to +0.013 |
| Sep | +0.011 ± 0.003 | +0.014 ± 0.013 | -0.007 ± 0.014 | +0.007 to +0.010 |
| Oct | +0.010 ± 0.004 | +0.022 ± 0.032 | -0.014 ± 0.023 | +0.007 to +0.010 |
| Nov | -0.011 ± 0.004 | +0.023 ± 0.024 | +0.020 ± 0.024 | +0.003 without snow, +0.015 with snow |
| Dec | -0.039 ± 0.008 | +0.009 ± 0.054 | +0.050 ± 0.051 | +0.003 without snow, +0.015 with snow |

Published values (deciduous broadleaf minus evergreen needleleaf, a full swap): Hollinger et al. (2010), snow-free,
+0.034 to +0.061 in April and May, +0.047 to +0.073 in June to August, +0.039 to +0.057 in September and October;
Jin et al. (2002), November to January at 40 to 50 N, +0.017 without snow and +0.081 with snow. They are class
means and tower sites, not one-degree cover fractions, so they are a guide to sign and size, not acceptance limits.
The passages were checked for this project on 5 November (`2026-11-05_northeast_simpler_routes_codex_gpt6astra.md`,
branch `northeast-forest-check`); I did not re-check them.

- **The chosen model** agrees with the published contrast in June to October, in sign and size, and has the
  published sign in March. It is flat in February, April and May. It has the wrong sign in November to January.
  Its coefficients in the snow season do not order the cover types as snow requires: in March it makes
  summergreen brighter than open land.
- **Model 8** has the wrong sign from March to October, by more than two standard errors in March to June. Its
  May value implies evergreen brighter than summergreen by 0.4 per full swap, where forest albedo is about 0.12.
  This is not only extrapolation: at the modern northeast mixes (70% of cells inside the range) 0.10 more
  evergreen brightens its April to June albedo by +0.027 to +0.048 (2.9 to 4.5 SE).
- **The coarse-location model** has the published sign in ten months and resolves it in none.
- **The flexible-location rival** (April and May from the capacity table): -0.036 ± 0.006 and -0.043 ± 0.006, the
  wrong sign, tightly estimated.

Full capacity table, April then May (`separation/capacity.csv`), which the report of 7 November showed only in part:

| Location size | Straight-line cover | Thin-plate, 50 | Thin-plate, 200 |
|---|---|---|---|
| None | -0.045 ± 0.005; -0.023 ± 0.004 | -0.086 ± 0.020; -0.026 ± 0.029 | +0.006 ± 0.153; +0.040 ± 0.120 |
| 12 | -0.024 ± 0.003; -0.006 ± 0.003 | +0.043 ± 0.027; +0.074 ± 0.033 | +0.046 ± 0.074; +0.067 ± 0.072 |
| 30 | -0.009 ± 0.003; +0.000 ± 0.003 | +0.048 ± 0.022; +0.065 ± 0.028 | +0.052 ± 0.051; +0.045 ± 0.049 |
| 100 | **-0.002 ± 0.004; +0.003 ± 0.005** | +0.018 ± 0.015; -0.002 ± 0.016 | +0.025 ± 0.025; +0.002 ± 0.025 |
| 500 | -0.036 ± 0.006; -0.043 ± 0.006 | -0.046 ± 0.015; -0.085 ± 0.018 | -0.041 ± 0.019; -0.074 ± 0.021 |

Brightening at the coarse sizes comes only from the thin-plate forms and is mostly unresolved. With straight-line
cover the answer is darkening or zero at every size. All three versions at location 100 are within their
uncertainty of zero, and the published +0.006 to +0.011 lies inside their intervals or at the edge (the chosen
model's April interval ends at +0.006).

### 2.5 Snow explains the chosen model's wrong winter sign, not model 8's (exploratory)

**Status: exploratory, outside protocol 2.** I fitted two small models to the existing snow-free and snowy
calibration tables of runs 2 and 7 (58 fits in all; nothing saved but the tables; `winner_by_snow_state.R`,
`rival_by_snow_state.R`). Model 8's rows use its existing saved fits (`northeast_snow_states.R`). If these results
are to be used they must be redone through the usual route.

Summergreen minus evergreen albedo for a full swap, at the northeast's mean albedo of that month (the cover
coefficients are continental; positive is the published sign):

| Month | Chosen, all days | Chosen, snow-free | Chosen, snowy | Rival, all days | Rival, snow-free |
|---|---:|---:|---:|---:|---:|
| Jan | -0.216 ± 0.061 | +0.017 ± 0.023 | +0.001 ± 0.080 | +0.005 ± 0.084 | -0.043 ± 0.033 |
| Feb | -0.033 ± 0.052 | -0.014 ± 0.020 | +0.004 ± 0.063 | -0.081 ± 0.078 | -0.074 ± 0.031 |
| Mar | +0.170 ± 0.038 | +0.027 ± 0.017 | -0.018 ± 0.056 | -0.129 ± 0.061 | -0.012 ± 0.026 |
| Apr | -0.012 ± 0.023 | +0.025 ± 0.015 | +0.080 ± 0.051 | -0.228 ± 0.039 | -0.022 ± 0.023 |
| May | +0.016 ± 0.027 | +0.046 ± 0.011 | +0.074 ± 0.051 (7 cells) | -0.277 ± 0.044 | +0.026 ± 0.020 |
| Jun | +0.053 ± 0.022 | +0.085 ± 0.012 | no northeast cells | -0.024 ± 0.037 | +0.057 ± 0.021 |
| Jul | +0.070 ± 0.016 | +0.076 ± 0.012 | no snowy table | +0.083 ± 0.028 | +0.038 ± 0.020 |
| Aug | +0.069 ± 0.015 | +0.066 ± 0.012 | no snowy table | +0.068 ± 0.025 | +0.026 ± 0.020 |
| Sep | +0.060 ± 0.017 | +0.061 ± 0.012 | no northeast cells | +0.058 ± 0.030 | +0.028 ± 0.020 |
| Oct | +0.057 ± 0.023 | +0.036 ± 0.012 | +0.194 ± 0.071 (6 cells) | -0.076 ± 0.039 | +0.016 ± 0.020 |
| Nov | -0.066 ± 0.024 | +0.059 ± 0.014 | -0.034 ± 0.083 | -0.089 ± 0.039 | +0.038 ± 0.020 |
| Dec | -0.242 ± 0.053 | +0.027 ± 0.020 | -0.168 ± 0.091 | -0.122 ± 0.068 | +0.007 ± 0.026 |

- **Chosen model on snow-free albedo:** the published sign in eleven of twelve months (February is within one
  standard error of zero), and close to the published size from May to October. Its winter wrong sign is gone.
  Open land is brighter than evergreen by 0.03 to 0.07 in every month and about equal to summergreen.
- **Chosen model on snowy albedo:** open land is brighter than both forest types by 0.24 to 0.27 in January to
  March, as snow requires. Evergreen against summergreen is not resolved (standard errors 0.05 to 0.09).
- **The rival (location 500):** on all-days albedo the published sign only in July to September (January is zero
  within a wide error); on snow-free albedo in eight of twelve months, at about half the published size. So the physical check separates the two
  location sizes that the prediction score could not, in favour of the chosen one.
- **Model 8 on snow-free albedo:** at the modern northeast mixes, 0.10 more evergreen still brightens it by
  +0.006 to +0.023 from January to October (2 SE or more from February to October). Snow is not what makes
  model 8 wrong there.
- **What this suggests, not proves.** Under snow-free conditions the hemlock decline brightened the northeast
  slightly (0.18 times the snow-free column: +0.003 to +0.015 in eleven months), as the published contrasts say. Under snow the
  data do not resolve it. The darkening in model 8 does not survive either check.

### 2.6 The made-up-truth test is far easier than the real data

Both tested models pass with large margins (largest bias 0.0017 against limits of 0.0027 to 0.0131), and the test
does confirm the contrast code end to end. But the recovered contrasts scatter by 0.0002 to 0.0022, where the
real-data standard errors are 0.004 to 0.021. The noise is independent between cells, the cover effect is one
straight line, and the location effect is a latitude plane, which the location term fits without penalty (its
unpenalised part has three dimensions: checked). Passing shows the code and the models work on easy data; it says
little about separating cover from location in the real data. The protocol already says this in general terms.

## 3. Corrections to what was reported to Chris on 7 to 9 November

| Said | Should be |
|---|---|
| "It wins outright." | It is 1.2 SE ahead of the same model with a 50-basis cover term, and its lead over the flexible-location versions depends on four Alaskan blocks. |
| "The coarse ones (12 to 30) make it brighter." | Only with thin-plate cover, mostly unresolved. With straight-line cover the coarse sizes give slight darkening or zero. |
| "No cross-validation can settle it either." | Too absolute. This one does not; it does rule out the no-location and coarse-location versions and model 8's cover form. |
| "It says the hemlock decline barely changed northeast spring albedo." | True of April and May. It gives brightening in March and June to October and darkening in November to January. |
| "`loc100_linear` is the best predictor." | On the test outside the modern range, which is 13% of the hindcast. Inside the range it ties with model 8. |
| "The data can't decide between them." | The prediction score cannot. Published contrasts point to the chosen model's location size and against model 8's northeast response (exploratory, section 2.5). |

## 4. What this means for the paper

1. **Stable:** the forcing before 6 ka, within about 10% for 6 to 10 ka across the three runs.
2. **Not stable:** the forcing since 6 ka, including the sign for 4 to 6 ka. It needs a range across versions or
   a better-grounded model before it is stated.
3. **The northeast:** the darkening after the hemlock decline is model 8's, and model 8's northeast response fails
   the published-contrast check on all-days and on snow-free albedo. The evidence leans to a slight brightening in
   snow-free conditions; under snow it is unresolved.
4. **A common cover response** (straight lines, one slope for the continent) is what gives the physically
   sensible answer. Whether that is acceptable for the northeast remains Andria's question.
5. **All-days albedo without snow in the model** is the weak point. The planned split into snow-free and snowy
   calibrations, mixed by snow fraction (Barnes and Roy 2010; Ghimire et al. 2014, as in the snow-scenario design
   of 5 November), is also the likely route to a credible vegetation response, with the simple cover form.

## 5. Recommendations, for Chris to decide

1. **Have Astra review this review** (the Alaska result, the twelve-month tables, the snow-state check), read-only.
2. **Make the published-contrast check a declared test.** Extend the real-data comparison from April and May to
   all twelve months and to the snow-free and snowy tables, for all fifteen versions, with the published values
   beside it and the rule stated before the run. Precedent in this field for the benchmark: Jin et al. (2002),
   Hollinger et al. (2010), Zhao and Jackson (2014), Burakowski et al. (2016). Astra to design, briefed for
   simplicity; the existing capacity tool needs little change.
3. **Fold the result into the snow design** before choosing the paper's model: the simple form on snow-free and
   snowy albedo may be the calibration that passes.
4. **Build the hindcast comparison tool as agreed**, with the northeast table for all twelve months.
5. **Add the block-share table** of 2.1 to the score stage (about ten lines).
6. **In the paper for now:** forcing before 6 ka as it is; since 6 ka as a range; no northeast sign.

## 6. Questions added to the open questions file for Andria

Section 8 of `questions_for_andria_scientific_from_2026-10-20.md`, questions 4 to 6: whether a calibration split
by snow state is acceptable; whether published forest contrasts are an acceptable check on the fitted cover
response; how to present forcing since 6 ka that depends on the model version.

## 7. Not checked

- The unit tests were not re-run, and the hull geometry, direction clustering and target weights were read, not
  recomputed (the earlier code reviews hand-checked them).
- Scripts 1 to 10 and the forcing arithmetic; I compared their outputs only.
- The references: quoted from the project's checked table, not re-verified. The reference checkers were not run.
- Paired standard errors east of 100 W; why the flexible location term runs away in Alaska; why model 8 makes
  evergreen brighter in the northeast on snow-free albedo.
