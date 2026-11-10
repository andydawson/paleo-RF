# Exploring the fitted cover response against published forest contrasts: design

*Fable 5.2 (main session), 10 November 2026. Chris: "#1 but have fable design it and then Astra check it, asking
me any questions needed." Draft for Astra's check. It follows the review of the same day
(`2026-11-10_cv_protocol_v2_results_review_fable.md`, sections 2.4 and 2.5).*

**Chris's decisions, 10 November:**
- "Let's just explore the contrasts for now, depending on the results we can decide if we include in the paper."
  So this is an exploration: the contrasts are computed and set beside the published values, with no pass or
  fail and no effect on the choice of model. Sections 4 and 6 are written accordingly.
- "Fable builds, Astra reviews."
- "Yes, open-access copies": the citation agents may download open-access copies of the benchmark papers.

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
- Three existing calibration tables, all with the 75-degree limit on the sun's zenith angle (`full_75`): all
  days (the protocol 2 run), snow-free (run 2) and snowy (run 7, ten months: no July or August).
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

## 4. How the table is read (no pass or fail)

For each version, table, region, exchange and month the output gives the fitted contrast per full swap, its
standard error, and the published value or range beside it where one exists. Two plain flags help the eye:

| Flag | Meaning |
|---|---|
| Sign at two standard errors | Whether the contrast differs from zero by two standard errors or more, and in which direction |
| Sign at three standard errors | The same at three |

- **Why both:** there are up to 72 comparisons per version and table (12 months, 3 exchanges, 2 regions), and the
  standard errors take the smoothing as known and ignore spatial correlation, so they are too small. Two standard
  errors is the usual reading; three allows for the number of comparisons.
- **Size is a guide only.** The published values are class means and tower sites, not one-degree cover fractions.
- The 0.10 exchange and the 30-cell floor are project judgements.

**Stated openly:** the review already saw exploratory results for two of the fifteen versions (the chosen model
and its flexible-location rival) on the evergreen-summergreen exchange, in the northeast, read from the
coefficients. This exploration repeats them properly and adds the other versions, exchanges and the study area.

## 5. Code: the smallest change

| Where | Change |
|---|---|
| `R/cv_separation.R` | `fixed_exchange()` takes the two classes to exchange (about six lines) |
| `tools/check_cv_separation.R` | A command that fits the versions on one run's calibration table for one month and writes the three exchanges for the two regions; a second that joins the benchmark table and writes the summary and one figure (about 80 lines in all) |
| `tests/test_cv_separation.R` | The third class stays fixed; reversed endpoints negate the contrast; the sign flags at their boundaries; the 30-cell floor |
| Benchmark table | One checked CSV under `data/` with its sources |

No pipeline change. Order: benchmark table made and checked; code written and reviewed; `tools/verify_change.R`
runs it; report to Chris.

## 6. What happens with the result

Chris and then Andria look at the tables and the figure. Whether the comparison goes into the paper, and whether
it should guide the choice of model or the move to snow-free and snowy calibrations, is decided then. Nothing in
this exploration changes the protocol's choice.

## 7. Precedent in this field

| Step | Precedent | Status |
|---|---|---|
| Forest albedo contrasts by type, season and snow state as reference values | Jin et al. (2002); Hollinger et al. (2010); Burakowski et al. (2016); Zhao and Jackson (2014) | Passages checked 5 November |
| Judging a model's albedo response to forest cover against observations | Candidates: Hollinger et al. (2010), which sets tower values against land-surface-model values; Bright et al. (2015), on bias in simulated albedo change from forest cover | **To be confirmed by reading**; not yet read for this purpose |
| Snow-free and snowy albedo mixed by snow fraction | Barnes and Roy (2010), equation 3; Ghimire et al. (2014), section 2.3 | Checked 5 November in the snow-scenario design |
| The 0.10 exchange and the 30-cell floor | None: project judgements | |

## 8. Limits

- Published class means and tower sites are not one-degree cover fractions; summergreen here includes larch and
  shrubs, and open land mixes crops, grass, tundra and bare ground.
- The test judges the modern response at modern mixes. It does not test the step to past mixes outside the modern
  range, which in the northeast is nearly every slice from 0.5 to 8.5 ka.
- Agreement in sign with published contrasts does not prove the response is right; a wrong sign shows it is not a
  vegetation effect.
- The snowy table has few northeast cells outside December to April.

## 9. Questions

For Chris: answered on 10 November (above).
For Andria (already in the open questions file, section 8, questions 4 and 5): whether published contrasts are an
acceptable check and which sources she would use for the northeast; whether a calibration split by snow state is
acceptable.
