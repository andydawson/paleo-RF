# A declared check of the fitted cover response against published forest contrasts: design

*Fable 5.2 (main session), 10 November 2026. Chris: "#1 but have fable design it and then Astra check it, asking
me any questions needed." Draft for Astra's check; nothing is built or run until Chris approves. It follows the
review of the same day (`2026-11-10_cv_protocol_v2_results_review_fable.md`, sections 2.4 and 2.5).*

**Benefit to the paper.** The forcing depends on how albedo responds when cover changes at a fixed place. This
test checks that fitted response against independent published measurements, by month and snow state, before a
model is used for the hindcast. The prediction score cannot do this.

## 1. What is tested

For each calibration version, month and albedo table, the model's own answer to three small exchanges of cover at
the modern cells, with location and elevation held fixed:

| Exchange (0.10 of cover) | Third class | Published expectation |
|---|---|---|
| More evergreen in place of summergreen | Open land fixed | Darker, in every season; more so under snow |
| More evergreen in place of open land | Summergreen fixed | Darker; much more so under snow |
| More summergreen in place of open land | Evergreen fixed | About equal without snow; darker under snow |

- **The exchange** is 0.05 either side of each cell's own mix (the protocol's existing "fixed exchange",
  `fixed_exchange()` in `R/cv_separation.R:49-54`, extended from one pair of classes to any pair).
- **Cells:** those where both endpoints are valid fractions and lie inside that month's modern range, so the test
  judges what the model learned, not how it extrapolates. Fewer than 30 such cells: "not testable".
- **Regions:** the northeast box, and the whole study area.
- **The number:** the area-weighted mean change in albedo, with its standard error from the coefficient
  covariance (`exchange_contrast()`, `R/cv_separation.R:86-90`, unchanged). Reported per 0.10 of cover, and
  multiplied by ten as "per full swap" for the comparison with published class contrasts. That scaling assumes a
  straight response and is used for the comparison only.
- **Reported beside, not judged:** the northeast's historical-size exchange (6 to 4.5 ka evergreen at 6 ka open
  land) for all twelve months. It lies outside the modern range, so it cannot be judged against a benchmark.

## 2. Versions, months and albedo tables

- The fifteen versions of protocol 2, unchanged.
- Twelve months.
- Three existing calibration tables, all with the 75% rule: all days (the protocol 2 run), snow-free (run 2) and
  snowy (run 7, ten months: no July or August).
- Up to 510 full-data fits by REML with the ordinary fitter and its one retry. Most take seconds; the three
  versions with location 500 take about two minutes each (one took 26). Model 8's saved fits are reused.

## 3. The published benchmarks, fixed before any fit

One small table in the repository: one row per published value, with the contrast, months, snow state, region,
value or range, source, table or figure and page.

| Source | What it gives | Status |
|---|---|---|
| Hollinger et al. (2010), Table 2 and Fig. 2 | Deciduous minus evergreen needleleaf, snow-free, by season; sites include Howland (Maine) and Bartlett (New Hampshire) | Passage checked 5 November |
| Jin et al. (2002), Table 1 | The same contrast, November to January, 40 to 50 N, with and without snow | Passage checked 5 November |
| Burakowski et al. (2016), section 2c3 and Fig. 5 | New England, December to March, by forest type and snow state | Method checked 5 November; values still to be read from the figure or data |
| Zhao and Jackson (2014) | Annual means, paired sites, North America | Passage checked 5 November |
| Open land against forest, by snow state | Needed for the second and third exchanges | **Not yet found.** The citation agents search and check each value before the run |

- For the all-days table, a month's expected range runs from the published snow-free value to the snowy one.
- A month with no benchmark is reported, not judged.
- None of these papers is in the project's Zotero library yet; they are added when the table is made.

## 4. The rule, fixed before the run

For each version, table, region, exchange and benchmarked month, the fitted contrast per full swap is one of:

| Outcome | Meaning |
|---|---|
| Agrees | Its 95% interval overlaps the published range |
| Off in size | Resolved with the published sign, but outside the range |
| Unresolved | Its interval includes zero and misses the range |
| **Wrong sign** | It differs from zero by **three standard errors or more**, on the other side from the published value |

- **Sign is the criterion; size is reported.** The published values are class means and tower sites, not
  one-degree cover fractions, so size is a guide only.
- **Why three standard errors:** up to 72 comparisons per version and table (12 months, 3 exchanges, 2 regions),
  and standard errors that take the smoothing as known and ignore spatial correlation, so they are too small.
  Outcomes at two standard errors are shown beside for information.
- **A version fails on a table** if any benchmarked month is "wrong sign" in either region. What failing means
  for the choice of model is Chris's decision (section 6).
- These thresholds (0.10, 30 cells, three standard errors) are project judgements.

**Stated openly:** this rule is written after the review saw exploratory results for two of the fifteen versions
(the chosen model and its flexible-location rival) on the evergreen-summergreen exchange, in the northeast, read
from the coefficients. On those results the
chosen model fails on all days and passes on snow-free and snowy albedo; the rival fails on all days and passes
on snow-free albedo at three standard errors but not at two. The thresholds were set from the number of
comparisons, not from who passes.

## 5. Code: the smallest change

| Where | Change |
|---|---|
| `R/cv_separation.R` | `fixed_exchange()` takes the two classes to exchange (about six lines) |
| `tools/check_cv_separation.R` | A command that fits the versions on one run's calibration table for one month and writes the three exchanges for the two regions; a second that joins the benchmark table and applies the rule (about 80 lines in all) |
| `tests/test_cv_separation.R` | The third class stays fixed; reversed endpoints negate the contrast; each outcome at its boundary; the 30-cell floor |
| Benchmark table | One checked CSV under `data/` with its sources |

No pipeline change. Order: benchmark table made and checked; code written and reviewed; `tools/verify_change.R`
runs it; report to Chris.

## 6. What the result decides: for Chris

Three ways to use it; the design works with any of them.

1. **A gate (recommended).** A version that fails on a table cannot be the paper's model for that table. Among the
   versions that pass, the prediction score chooses as before. If every version fails on all-days albedo and the
   simple versions pass on snow-free and snowy albedo, the calibration moves to the snow-free and snowy pair mixed
   by snow fraction, as the snow-scenario design already proposes.
2. **Reported only.** No effect on the choice; failures restrict what the paper may claim, as with the
   made-up-truth test.
3. **Rank by agreement.** Choose the version that agrees in the most months. Not recommended: it selects on
   agreement with a benchmark that is only a guide in size.

## 7. Precedent in this field

| Step | Precedent | Status |
|---|---|---|
| Forest albedo contrasts by type, season and snow state as reference values | Jin et al. (2002); Hollinger et al. (2010); Burakowski et al. (2016); Zhao and Jackson (2014) | Passages checked 5 November |
| Judging a model's albedo response to forest cover against observations | Candidates: Hollinger et al. (2010), which sets tower values against land-surface-model values; Bright et al. (2015), on bias in simulated albedo change from forest cover | **To be confirmed by reading**; not yet read for this purpose |
| Snow-free and snowy albedo mixed by snow fraction | Barnes and Roy (2010), equation 3; Ghimire et al. (2014), section 2.3 | Checked 5 November in the snow-scenario design |
| The 0.10 exchange, the 30-cell floor, three standard errors | None: project judgements | |

## 8. Limits

- Published class means and tower sites are not one-degree cover fractions; summergreen here includes larch and
  shrubs, and open land mixes crops, grass, tundra and bare ground.
- The test judges the modern response at modern mixes. It does not test the step to past mixes outside the modern
  range, which in the northeast is nearly every slice from 0.5 to 8.5 ka.
- Agreement in sign with published contrasts does not prove the response is right; a wrong sign shows it is not a
  vegetation effect.
- The snowy table has few northeast cells outside December to April.

## 9. Questions

For Chris: how the result is used (section 6), and who writes the code.
For Andria (already in the open questions file, section 8, questions 4 and 5): whether published contrasts are an
acceptable check and which sources she would use for the northeast; whether a calibration split by snow state is
acceptable.
