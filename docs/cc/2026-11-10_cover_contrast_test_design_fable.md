# Exploring the fitted cover response beside published forest contrasts: design

*Fable 5.2 (main session), 10 November 2026. Chris: "#1 but have fable design it and then Astra check it, asking
me any questions needed." Second version, revised after Astra's check
(`2026-11-10_cover_contrast_test_design_check_codex_gpt6astra.md`). It follows the review of the same day
(`2026-11-10_cv_protocol_v2_results_review_fable.md`, sections 2.4 and 2.5).*

**Chris's decisions, 10 November:**
- "Let's just explore the contrasts for now, depending on the results we can decide if we include in the paper."
  So this is a description of how the fitted models behave, with no pass or fail and no effect on the choice of
  model.
- "Fable builds, Astra reviews."
- "Yes, open-access copies": the citation agents may download open-access copies of the reference papers.
- "Six versions."
- On the diagnostic: "I'm happy with something along these lines but the closer to a published precedent the
  better." A separate agent is reading the methods of Lejeune et al. (2020), Duveiller et al. (2018), Li et al.
  (2015) and Boisier et al. (2013) closely, so that the name, unit, reliability rules and presentation of the
  diagnostic follow them where they can (section 7). The build takes its final form from that reading.
- On scope: "I don't want to get too hung up on the north east and the hemlock decline. It is one interesting
  feature to look at because we know something happened then with the vegetation and we know the effect it should
  have had on Albedo. So it makes a good test case for the modelling. But there might be other times and regions
  where we can also say something interesting [...] so we should explore those options too." So the contrasts are
  reported for every region the project already names, not for the northeast alone (section 1), and a separate
  search for other case studies is under way.

**Benefit to the paper.** The vegetation forcing depends on how albedo responds when cover changes at a fixed
place, and the three pipeline runs disagree about it in every period. This shows that fitted response directly,
by month and snow state, for the versions that differ in location size and cover form, with published values
beside it as context.

## What changed after Astra's check

| First version | Now | Why |
|---|---|---|
| Contrast multiplied by ten and called "per full swap" | The actual change for a 10-point exchange | The models are curved on the albedo scale and a full swap is impossible with a third class present |
| Published values as the expected sign in every season | Published values shown beside, in their own units, as context | They are class and site means with exceptions (winter; larch); a contrary sign calls for a look, it proves nothing |
| All-days results bracketed between snow-free and snowy published values | No bracket | A fitted all-days response need not lie between the two |
| Two "sign" flags at two and three standard errors | One interval of plus or minus two conditional standard errors | Three standard errors does not allow for 72 comparisons; no classification is needed |
| Fewer than 30 cells: "not testable" | Every result shown with its cell count and share of area | The floor would remove every northeast summergreen and open-land result (22 cells) |
| Fifteen versions | Four or six (Chris to choose) | The smallest set that separates location size from cover form |
| Two commands added to the protocol's separation tool | One short stand-alone script | That tool is tied to the all-days table, April and May, and the recovery test |
| "75% rule" | A 75-degree limit on the sun's zenith angle | It was wrong |

## 1. What is described

For each version, month and albedo table: the model's own predicted change in albedo when 10 points of cover
are exchanged at the modern cells, with location, elevation and the third cover class held fixed.

| Exchange (10 points of cover) | Held fixed |
|---|---|
| Summergreen in place of evergreen | Open land |
| Open land in place of evergreen | Summergreen |
| Open land in place of summergreen | Evergreen |

- **Direction.** Each is written the way the published contrasts are (deciduous minus evergreen; open minus
  forest) and the way the hemlock decline went, so one sign convention holds throughout: positive is brighter.
- **The exchange** runs from 5 points below each cell's own mix to 5 points above (the protocol's existing "fixed
  exchange", `fixed_exchange()` in `R/cv_separation.R:49-54`, extended from one pair of classes to any pair).
- **Eligible cells:** both endpoints are valid fractions and lie inside that month's range of modern cover mixes
  for the whole continent. That range says the mix is familiar; it does not say similar cells are nearby.
- **The number:** the area-weighted mean of the predicted differences, with plus or minus two standard errors
  from the coefficient covariance (`exchange_contrast()`, `R/cv_separation.R:86-90`, unchanged). The standard
  error is approximate and conditional: it leaves out the uncertainty of the smoothing, spatial dependence, the
  cover data and the choice of model.
- **Regions:** the forcing's study area (27 to 74 N) and each of the six regions the project already names
  (`R/regions.R`: Southwest, Southern Plains, Southeast, Northeast, Upper Midwest and Great Lakes, Alaska and
  Yukon). The northeast is one of them, not the focus.
- **Always shown with it:** the number of eligible cells and their share of the region's area. From the saved
  tables, in the northeast on all-days albedo: 58, 41 and 22 of 83 cells for the three exchanges (70%, 50% and 27%
  of the area); on snowy albedo outside December to April only a handful, and none in June and September. A
  result from one or three cells is described as those cells, not as the northeast.
- **Same cells for every version** within a table, month, region and exchange. Tables are compared on their
  common eligible cells where a difference between them is claimed.

Not in this exploration: the northeast's historical-size exchange, which lies outside the modern range. The
hindcast comparison tool reports it.

## 2. Versions, months and albedo tables

| Location term | Straight-line cover | Thin-plate cover, 200 |
|---|---|---|
| 100 | `loc100_linear` (the chosen model) | `loc100_tp200` |
| 500 | `lin_cover` (its flexible-location rival) | `mod8` (the original) |
| 30 | `loc30_linear` | `mod8_coarse_loc` (the first run's choice) |

- Six versions (Chris, 10 November): location size crossed with cover form, covering all three finished pipeline
  runs (model 8, the coarse-location model, the chosen model).
- Twelve months; three existing calibration tables with the 75-degree limit on the sun's zenith angle
  (`full_75`): all days (the protocol 2 run), snow-free (run 2) and snowy (run 7).
- A month is fitted for a version only where the table has at least as many complete cells as the version has
  coefficients (the protocol's existing rule).
- Every fit is made afresh by REML with the ordinary fitter and its one retry: at most 216 fits. Most take
  seconds; those with location 500 about two minutes (one took 26). Refitting all is simpler than checking saved
  fits for reuse, and costs under an hour on twelve cores.

## 3. Published values shown beside

A small table, one row per published value, with its classes, months, snow state, region, kind of albedo, value
and spread, source, table or figure and page. A separate agent assembled it on 10 November from open-access
copies: 103 rows, 96 of them read in the source (22 from figures), from Hollinger et al. (2010), Boisier et al.
(2013), Burakowski et al. (2015, 2016), Bright et al. (2015), Euskirchen et al. (2016) and Lutz and Howarth
(2015). It could not obtain Jin et al. (2002), Barnes and Roy (2010), Ghimire et al. (2014) or Zhao and Jackson
(2014); Astra read Jin's Table 1 the same day and confirmed its two values. Every published value is seasonal or
by snow period; none is for a single calendar month.

| Source | What it gives | Kind of albedo |
|---|---|---|
| Hollinger et al. (2010), Table 2, pp. 701-703 | Tower means by plant type and season, snow-free; forest and open classes; larch separately; winter exceptions | Tower radiation totals |
| Jin et al. (2002), Table 1 | Classes with and without snow, November to January, 40 to 50 N | Black-sky at local noon |
| Burakowski et al. (2016), section 2d(3), Fig. 5 | New England, December to March, by cover and snow state | Blue-sky (ours is too) |
| Zhao and Jackson (2014), pp. 333-338, Figs 5-6 | Adjacent forest and grass or crop pairs, by month | White-sky; snow states not separated |
| Barnes and Roy (2010), Table 1 | Annual context for forest and open classes | |

- The figure shows the published class differences in a separate panel, in their own units and months.
- For the eye only, the model panels carry the published difference multiplied by 0.10, labelled "ideal linear
  mixing: a guide, not a measurement" (mixing by area fraction: Ghimire et al. 2014, section 2.3).
- Snow-free and snowy published values are set beside the snow-free and snowy fits. All-days fits are shown
  through the year as model behaviour; beside snow-free values they are comparable only from June to September,
  when the northeast has no snowy retrievals.
- Stated beside the table: the references are classes, sites or neighbouring pairs, ours a response around mixed
  one-degree cells; summergreen includes larch and shrubs, and open land mixes crops, grass, tundra and bare
  ground; some references use the same MODIS observations as the project, so they are independently published,
  not wholly independent; their spreads and our standard errors measure different things.

## 4. Output

- One table: albedo table, month, version, region, exchange, eligible cells, share of area, contrast, standard
  error, whether the fit converged.
- One figure: contrast against month, a line per version with its interval, a panel per exchange and region, a
  page per albedo table; the published panel beside.
- A record of the code version, the inputs' checksums and the fits' convergence.

## 5. Code: the smallest change

| Where | Change |
|---|---|
| `R/cv_separation.R` | `fixed_exchange()` and `freeze_exchange()` take the two classes exchanged and the class held; defaults keep today's behaviour (`freeze_exchange()` now stops on any change of open land, `:22-25`) |
| `tools/explore_cover_contrasts.R` (new, short) | Read one run's calibration table, fit the versions for the months asked, compute the exchanges, write the table; a second command stacks the tables and draws the figure |
| `tests/test_cv_separation.R` | All three pairs keep the held class, total cover, location and elevation; an invalid pair stops; existing tests of reversal, support and weights stay |
| One small check of the script | Counts, area shares, a failed fit reported and not dropped |
| The table of published values | One CSV with its sources, tracked in the repository |

No pipeline change. Fable builds on a branch off `cv-v2`; Astra reviews; `tools/verify_change.R` runs it.

## 6. What happens with the result

Chris and then Andria look at the table and figure. Whether it goes into the paper, and whether it should bear on
the choice of model or on splitting the calibration by snow state, is decided then.

## 7. Precedent in this field

Passages read by Astra on 10 November unless noted.

| Step | Precedent | What it does not support |
|---|---|---|
| Albedo contrasts by cover type, season and snow state as reference values | Jin et al. (2002); Hollinger et al. (2010); Burakowski et al. (2016); Zhao and Jackson (2014) | Acceptance limits for this calibration |
| Setting a model's albedo by cover type against observations | Hollinger et al. (2010), tower values against land-surface-model values; Burakowski et al. (2016), section 2d(3) and Fig. 5, model against MODIS by class and snow state; Bright et al. (2015), sections 2.1-2.3 and Fig. 2, model schemes against MODIS for forest and open land | A rule of sign by month |
| Monthly regressions of albedo on cover fractions, by snow state, compared with satellite estimates of cover transitions | **Lejeune et al. (2020)**, sections 2.1.1-2.3.1 and 4; Duveiller et al. (2018), Methods, equations 11-13, for contrasts from endpoint predictions with their covariance | Our continental model; their regressions are local and straight on the albedo scale |
| Snow-free and snowy albedo mixed by snow fraction | Barnes and Roy (2010), section 3.1, equation 3; Ghimire et al. (2014), sections 2.2-2.3, equation 1 | That a fitted all-days response lies between the two |
| The centred 10-point exchange, the range restriction, the choice of versions | **None: project choices** | |

## 8. Limits

- The averages describe different eligible cells across exchanges, months and tables; a change of cells can look
  like a change of response.
- A prediction at fixed coordinates is not a causal vegetation effect: cover and location were estimated from
  observations in which they vary together.
- A small regional mean can hide opposite responses in different cells of a thin-plate fit.
- Agreement at modern mixes says nothing about the step to past mixes outside the modern range, which in the
  northeast is nearly every slice from 0.5 to 8.5 ka.
- Snow-free values rest on retrievals classed as snow-free; some rest on very few (review, section 2.5). The
  script reports, beside each result, the typical share of that month's retrievals that stand behind the eligible
  cells, from the albedo build's cell table (`full_75_share_snowfree`, `full_75_share_snowy`).

## 9. Questions

For Chris: answered on 10 November (above).
For Andria (open questions file, section 8, questions 4, 5 and 7).

## References

Checked by Astra on 10 November (titles, DOIs and the passages named above), except Duveiller et al., checked
for protocol 2.

- Barnes, C. A., & Roy, D. P. (2010). Radiative forcing over the conterminous United States due to contemporary
  land cover land use change and sensitivity to snow and interannual albedo variability. *JGR*, 115, G04033.
  doi:10.1029/2010JG001428
- Bright, R. M., et al. (2015). Radiative forcing bias of simulated surface albedo modifications linked to forest
  cover changes at northern latitudes. *Biogeosciences*, 12, 2195-2205. doi:10.5194/bg-12-2195-2015
- Burakowski, E. A., et al. (2016). Evaluating the climate effects of reforestation in New England using a
  Weather Research and Forecasting (WRF) model multiphysics ensemble. *Journal of Climate*, 29, 5141-5156.
  doi:10.1175/JCLI-D-15-0286.1
- Duveiller, G., Hooker, J., & Cescatti, A. (2018). The mark of vegetation change on Earth's surface energy
  balance. *Nature Communications*, 9, 679. doi:10.1038/s41467-017-02810-8
- Ghimire, B., et al. (2014). Global albedo change and radiative cooling from anthropogenic land cover change,
  1700 to 2005 based on MODIS, land use harmonization, radiative kernels, and reanalysis. *GRL*, 41, 9087-9096.
  doi:10.1002/2014GL061671
- Hollinger, D. Y., et al. (2010). Albedo estimates for land surface models and support for a new paradigm based
  on foliage nitrogen concentration. *Global Change Biology*, 16, 696-710. doi:10.1111/j.1365-2486.2009.02028.x
- Jin, Y., et al. (2002). How does snow impact the albedo of vegetated land surfaces as analyzed with MODIS data?
  *GRL*, 29, 1374. doi:10.1029/2001GL014132
- Lejeune, Q., et al. (2020). Biases in the albedo sensitivity to deforestation in CMIP5 models and their impacts
  on the associated historical radiative forcing. *Earth System Dynamics*, 11, 1209-1232.
  doi:10.5194/esd-11-1209-2020
- Zhao, K., & Jackson, R. B. (2014). Biophysical forcings of land-use changes from potential forestry activities
  in North America. *Ecological Monographs*, 84, 329-353. doi:10.1890/12-1705.1
