# Exploring the fitted cover response: what was built

*Fable 5.2, 15 November 2026, for Chris. Built to the design of 10 November
(`2026-11-10_cover_contrast_test_design_fable.md`, second version, after Astra's check) and Chris's decisions
recorded there: explore only, six versions, Fable builds and Astra reviews, "the closer to a published precedent
the better". Astra has not reviewed this yet, the verification tool has not been run, and the exploration itself
(all months, all three albedo tables, six versions) has not been run: that needs Chris's go-ahead.*

*16 November: Astra's review (`2026-11-15_cover_contrast_exploration_review_codex_gpt6astra.md`, "ready after named
changes") and the changes Chris approved from it are in section 10. Where an earlier section is out of date, section
10 says so. The verification tool has still not been run, nor the exploration.*

*17 November: the comparison with Duveiller et al. (2018) is built (section 11); it has not been reviewed or verified yet.*

## In brief

- **What it is for.** It shows, by region and month, how each candidate model's fitted response to a change of
  cover compares with published forest albedo contrasts. That is the evidence asked for on whether the location
  term distorts the vegetation effect.
- **What exists.** The exchange helpers now take any two cover classes; a new stand-alone tool fits the six
  versions and reports three exchanges for the study area and the six named regions; tests; a verification spec.
  Branch `cover-contrasts`, off `cv-v2`.
- **What was run.** The tests, and a small trial on real data (two months of each albedo table, cheap versions
  only). Three checks on real data agree with independent numbers (section 6).
- **What it says so far.** Nothing to interpret yet: the trial covers two months and at most four versions.

## 1. What was built

| File | Lines | What changed |
|---|---|---|
| `R/cv_separation.R` | 273 (+30) | `fixed_exchange()` takes the class that gains and the class that loses; `freeze_exchange()` takes the class to hold; `held_class()`; `cell_areas()` and `area_of()`. The defaults are protocol 2's exchange |
| `tools/check_cv_separation.R` | 268 (-3) | Calls `cell_areas()` and `area_of()` in place of its own copy of that lookup |
| `tools/explore_cover_contrasts.R` | 361 (new) | The tool: a fit command and a report command |
| `tests/test_cv_separation.R` | 317 (+32) | The defaults to the last bit; all six ordered pairs; invalid pairs; the area lookup |
| `tests/test_explore_cover_contrasts.R` | 162 (new) | Hand-worked cells, a stand-in fitter, the report, the published values and their new columns row by row, the input guard |
| `docs/cc/2026-11-10_published_albedo_contrasts.csv` | 103 rows | Five columns added that a script can read; no existing field changed |
| `docs/cc/verification/2026-11-15_cover-contrasts.R` | 29 (new) | The verification spec, commit left as `TO_FILL` |
| `docs/cc/2026-11-15_cover_contrast_exploration_trial/` | | The trial of section 6: its tables, records and logs, and the scripts of the checks |

No pipeline script changed.

## 2. How it is run

```
Rscript tools/explore_cover_contrasts.R fit <run-dir> <output-dir> <month> [<month> ...]
Rscript tools/explore_cover_contrasts.R report <output-dir>
```

- **fit** reads one finished run (since 16 November it also saves each fit and the month's exchanges: section 10). The run's own configuration says which albedo its calibration table holds (all
  days, snow-free or snowy). For each month it fits the six versions afresh (REML, the ordinary fitter and its one
  retry) and writes `contrasts_<table>_<month>.csv`, `fits_<table>_<month>.csv` and a record. Jobs for different
  runs and months can run side by side. Nothing is written into the run that is read.
- **report** stacks whatever is in the output folder into `cover_contrasts.csv` (its explanation is in the file's
  first lines) and `fits.csv`, writes `published_guide.csv` (the published values drawn beside the model), and draws
  `cover_contrasts.pdf`: a page per albedo table, then a page of the published values.

## 3. What a row of the table says

For one albedo table, month, version, region and exchange:

| Column | Meaning |
|---|---|
| `exchange` | "A to B": predicted albedo with 5 points more of B and 5 fewer of A than the cell's own mix, minus predicted albedo with 5 points more of A and 5 fewer of B. The third class, location and elevation are held. Positive is brighter |
| `region_cells` | The region's cells of the calibration table that have an area |
| `fitted_cells` | Those with albedo that month: the cells the versions were fitted to |
| `eligible_cells`, `area_share` | Those whose two endpoints are valid fractions inside that month's range of modern cover mixes for the whole continent, and their share of the region's area |
| `cells_10pct` | Eligible cells in which both exchanged classes cover at least 10 % of the cell |
| `contrast`, `se` | Area-weighted mean of the predicted differences over the eligible cells, and its standard error from the coefficient covariance (covariance between the two endpoints and between cells kept). Approximate and conditional |
| `spread` | Area-weighted standard deviation of the cells' own differences: how unlike the cells are, not an uncertainty |
| `snowfree_share`, `snowy_share` | Median, over the eligible cells, of the share of that month's accepted retrievals flagged snow-free and snowy |
| `converged`, `fit_status` | Whether the fit converged, failed, or was not made, and why |

The three exchanges are evergreen to summergreen, evergreen to open land, and summergreen to open land. The
eligible cells are fixed before any fit, so every version is described at the same cells.

## 4. The inputs the fit command reads, traced to their source

| Albedo table | Run folder (under `paleo-RF-verify/`) | Run's commit | Calibration table, MD5 |
|---|---|---|---|
| All days | `1d31cfc/.rundirs/cv2-holdouts` (the protocol 2 run, 6 November) | `1d31cfc` | `67f258c3a2d97f729bb7139ae4940fc5` |
| Snow-free | `8e3f3a4/.rundirs/run2-snowfree-2` (3 November) | `8e3f3a4` | `0e67a3d38ee2af12c08ab1b2e78d5928` |
| Snowy | `74b5482/.rundirs/run7-snowy` (4 November) | `74b5482` | `c907790dc87b5b9d2a1c171550557b60` |

- **Calibration table** (`data/calibration_modern_lct_interp_bluesky.RDS` in each run): written by script 2 in
  that run, from the albedo setting in that run's `config_used.R` (MODIS cells, version `full_75`, statistic
  `all_days`, `snow_free` or `snowy`). Checked: all three load under this branch's configuration rules, and the
  three tables hold the same 2,812 cells with the same cover and elevation; only the albedo differs.
- **Cell areas** (`data/ALB_diffs_bluesky.RDS` in each run, script 7a's table): the snow-free and snowy runs made
  their own; the all-days run's copy came from the main refit's run (`d5d5df5/.rundirs/run1-main`), as its
  verification spec of 6 November records. Checked: every cell has the same area in all three. 2,866 cells have an
  area; 2,808 of the 2,812 calibration cells are among them. The other four are left out (two west of 170 W, which
  script 7a drops; two at 65.5 N, 167.5 W and 166.5 W).
- **The albedo build's cell table** (`data/albedo_modis_cells.csv`, tracked, MD5
  `d73c54cca47b864284e430f87ef9ce3f`): the same file in git at all three runs' commits and on this branch. The fit
  command also shows this on the numbers: it rebuilds the run's calibration albedo from this file and stops unless
  the two agree exactly. It did agree for all three runs.
- **The published values** (report command only): `docs/cc/2026-11-10_published_albedo_contrasts.csv`.

Each job's record lists these files with their MD5 sums, the commit, and the six versions' terms.

## 5. Choices the design did not fix

1. **Names and direction.** An exchange is named from the class that gives up cover to the class that takes it
   ("evergreen to summergreen"), and its value is albedo after minus albedo before, as published transitions are
   named and signed (Duveiller et al. 2018, equation 11; Lejeune et al. 2020, section 2.3.1).
2. **The study area** is the forcing's window from the run's configuration: west limit and latitude limits as
   scripts 7a and 8 apply them. The six regions are the boxes of `R/regions.R` unchanged; three of them reach a
   little beyond the study area (south of 27 N, north of 74 N).
3. **The share of area** is of all the region's cells with an area, whether or not they have albedo that month. So
   it also falls where a month has no albedo (polar night; no snowy retrievals), which the count of fitted cells
   shows separately.
4. **Retrieval support** is two columns, the typical snow-free and snowy shares, for every table. One column for
   the table's own snow state would not help to read the all-days results.
5. **A count adapting one element of Lejeune et al.'s filter** (both classes at least 10 % of the cell) is shown beside each result and not applied (see section 7).
6. **The spread** is weighted by area, like the mean.
7. **A fit that did not converge after its retry** gets no numbers, as in the protocol's own contrasts.
8. **Every job fits all six versions.** There is no option to choose versions.
9. **The published values drawn.** Of the table's 103 rows, 56 are drawn: a number read in its source, for one of
   the three contrasts, broadband, one snow state, calendar months. Not drawn: the rows not read (among them Jin
   et al. 2002, whose two values Astra confirmed but the table still holds as placeholders), Bright et al.'s
   single spectral bands, and Euskirchen et al.'s snow periods, which are not calendar months.
10. **The guide beside the model.** Each published value is one grey tick at each month it covers, multiplied by
    0.10, the same in every region's panel: no band and no average. Snow-free values stand beside the snow-free
    fits and snow-covered values beside the snowy fits. Beside the all-days fits only the snow-free values of June
    to September are shown, as the design says. Annual all-conditions values are on the published page only.
11. **The figure.** Colour is the size of the location term, line type the cover term; each panel has its own
    vertical scale and carries the fewest and most eligible cells of any month in its title.
12. **The record** flags uncommitted changes in `R/`, `scripts/`, `config.R` and the tool itself, not in other
    tools or tests.
13. **The input guard** of section 4 (the cell table must reproduce the run's calibration table).
14. **The area lookup** became two shared functions, so the protocol's separation tool was edited to call them.

## 6. The trial of 15 November

The fit jobs ran from the committed tool (commit `06357f4`) and the report from `ed6021c`, which changed only
the order of one table; their records say so. The trial's tables, records and logs, and the scripts of the
checks below with their logs, are kept in `2026-11-15_cover_contrast_exploration_trial/`. The figure is not
kept there.

| Job | What ran | Measured |
|---|---|---|
| Snowy table, July and August, through the command line | 470 and 360 complete cells: four versions fitted, the two with a location term of 500 reported as not fitted | Fits: 0.0, 0.5, 0.1 and 1.7 minutes (July); 0.0, 0.3, 0.1 and 2.4 minutes (August). Whole job 5 minutes 13 seconds |
| All-days table, January and July, two cheapest versions only | Straight-line cover with location 30 and 100 | Fits 0.1 to 0.2 minutes each. Whole job 51 seconds |
| Snow-free table, January and July, two cheapest versions only | The same | Fits up to 0.2 minutes each. Whole job 47 seconds |
| Report on the three | 420 rows, four pages | 7 seconds |

No fit with a location term of 500 on a full table was made, so their time is not measured here.

**Checks on real data, each against numbers from elsewhere:**

- **Protocol 2's own exchanges are unchanged.** With the new helpers, the four northeast exchanges frozen in the
  protocol 2 run on 6 November (the fixed and the historical one, April and May) are reproduced bit for bit.
- **The eligible cells match Astra's independent count.** For the northeast, Astra counted the eligible cells in
  Python from the same three tables (its check of the design, point 4). The tool gives the same in every case:
  58, 41 and 22 for all days in every month (69.6, 49.9 and 26.7 % of the area); 45 to 58, 32 to 41 and 17 to 22
  for snow-free; for snowy 58, 41 and 22 from December to March, 42, 25 and 13 in April, 3, 1 and 1 in May, 2, 0
  and 0 in October, 25, 16 and 6 in November, none in June and September.
- **Three rows recomputed by plain code** (all days, July, location 30 with straight-line cover, northeast): the
  contrast and the spread agree to nine decimal places, and the standard error agrees within 2 % with the spread
  of the contrast over 4,000 draws of the coefficients.

**What the trial rows look like** (the chosen version, location 100 with straight-line cover; northeast;
evergreen to summergreen; per 10 points of the cell; plus or minus two standard errors):

| | January | July |
|---|---|---|
| All-days albedo | -0.022 ± 0.012 (58 cells; typical snowy share of retrievals 0.97) | +0.0070 ± 0.0032 (58 cells) |
| Snow-free albedo | +0.0016 ± 0.0046 (45 cells; typical snow-free share 0.13) | +0.0075 ± 0.0023 (58 cells) |

Published deciduous minus evergreen, multiplied by 0.10: +0.0047 to +0.0073 for June to August (Hollinger et al.
2010, towers; Boisier et al. 2013); +0.0023 to +0.0040 for snow-free winter (Boisier; Burakowski et al. 2016).
This repeats, from committed code, the pattern the unsaved fits of 10 November showed for this version: the
published sign on snow-free albedo, the opposite sign in winter on all-days albedo. It is two months of one
version, and the cause is not isolated.

The trial also shows what the support columns are for. In the snowy table's July, the study area has 388 fitted
cells of 2,623 and at most 225 eligible ones, and the typical snowy share of the retrievals at those cells is
0.1 to 0.4 %.

## 7. Closer to published practice, and what was left undecided

Adopted, as conventions of reporting only: the naming and sign of a transition; the published values scaled by
the fraction converted (0.10) beside the model; a count adapting one element of Lejeune et al.'s filter (2020, p. 1213);
the spread across cells kept apart from the standard error (Boisier et al. 2013, Table 2); the standard error
described as Duveiller et al. (2018, equations 12 and 13) describe theirs; the kinds of albedo named beside the
published values.

The reading of the precedents (`2026-11-10_precedent_methods_report.md`, section 3.4) left five choices open.
None is made here; the tool keeps the design's choice in each case. They are questions 1 to 5 below.

## 8. Not done

- The exploration itself: 36 jobs (three tables, twelve months). By the rule on cells and coefficients, 212 of the
  216 fits would be made; the four not made are the two versions with a location term of 500 in the snowy table's
  July and August.
- Astra's review, and the run of the verification tool.
- A comparison of two albedo tables on their common eligible cells. The tool makes no claim that needs one.
- A sensitivity table (another size of exchange, another minimum share), the recombined all-conditions contrast,
  the comparison with Duveiller et al.'s data set, a local regression in Lejeune's manner.
- Entering Jin et al.'s two values in the table, and placing Euskirchen et al.'s snow periods on a month axis.

## 9. Questions for Chris

1. **Scale.** The tool reports the albedo change for 10 points of the cell and sets the published differences
   beside it multiplied by 0.10. The alternative with a direct precedent (Boisier et al. 2013, equation 2) divides
   the model's number by 0.10 and reports a change per unit of cover, to set beside the published differences as
   they are. Astra advised against that because the models are curved on the albedo scale. Keep it as built?
2. **A local rule for which cells count.** A cell counts if both ends of the exchange lie inside the range of
   cover mixes seen anywhere on the continent that month. The papers instead require both classes to be present
   locally (Lejeune's filter includes a minimum share of each class, beside a regression-error condition). The
   tool counts the cells in which both classes cover at least 10 %, as a rule of that kind, without applying it.
   In the trial such a rule would remove none of the northeast's cells and 7 to 9 % of the study area's in July
   for the two evergreen exchanges. Apply it, keep counting it, or drop it?
3. **A recombined all-conditions number.** Should the tool also mix the snow-free and snowy contrasts by each
   cell's snow share and show that beside the all-days fit (Boisier's equation 1)?
4. **Duveiller et al.'s one-degree monthly data set** as the observation-based comparison: still open from
   10 November; it needs your decision on a download and on how its classes map to the project's three.
5. **A local regression on the project's own cells**, in Lejeune's manner: wanted or not?
6. **Published values for boreal sites.** Euskirchen et al. (2016) give tower values for Alaska and north-west
   Canada by snow period (for example "mid-April to late August"), not by calendar month, so they are not drawn.
   Should they be placed on the month axis by a stated rule, so that the Alaska and Yukon panels have a nearby
   reference?
7. **Jin et al. (2002).** The table holds its two values as placeholders because the paper could not be obtained;
   Astra read them (+0.017 without snow, +0.081 with snow, November to January). Enter them on Astra's reading?
8. **The full run.** It needs your go-ahead. The cheap fits are measured above; the fits with a location term of
   500 are not.

## 10. Changes after Astra's review, 16 November

Chris approved the review's changes for findings 1 to 6, and its answer on Jin, and nothing else (none of the five
choices of section 7, no filter, no recombined number). So question 7 of section 9 (Jin) is answered yes, and
section 8's item on Jin is done; questions 1 to 6 and 8 stay open. Branch `cover-contrasts`, five commits after
`73fd063`.

| Finding | What changed |
|---|---|
| 1 and 5: published references | The published table has two more columns (`qualification`, `beside_model`; its note says how they were set). Burakowski et al. (2015)'s two comparisons with a crop, forest, grass and shrub mosaic are no longer drawn beside the model, only, labelled, on the published page. That paper's four values are marked single-day (9 March 2013); Lutz and Howarth's three are annual means at separate sites, drawn once each as a line across the year; Burakowski et al. (2016)'s winter placement follows the paper's comparison window, the MODIS averaging period not being stated. On the published page the shape of each mark gives its qualification; beside the model a small circle marks a qualified guide. `published_guide.csv` keeps the classes, kind of albedo and qualification. Jin et al. (2002)'s two values are entered as Astra read them, and the table says that the builders did not see the paper. 58 of the 103 rows are now drawn (section 5, choice 9 said 56) |
| 3 and 6: figure and wording | Under every panel, by month, the eligible cells, their share of the area of the region's calibration cells and the median share of retrievals in the page's snow state (snowy beside the all-days fits); the panel title gives the region's calibration cells instead of the fewest and most eligible cells (section 5, choice 11). The area share is said to be of the modern calibration cells represented, not of the box. Three qualifications in the caption: continental fits evaluated at regional cells; the same published values in every region; different vertical scales. June to September is no longer called snow-free everywhere (choice 10). The 10 % count is described as an adaptation of one element of Lejeune et al.'s filter, not their rule (section 3, section 7) |
| 4: fitted models | The fit command saves what the fitter returned (the model and its attempts) as `fit_<table>_<month>_<version>.rds` whenever it ran, and the month's exchanges as `cases_<table>_<month>.rds`, in the output folder, outside git. In the trial a saved fit takes 0.6 to 4.4 MB |
| 2: verification | `tools/check_cover_contrasts.R` (158 lines): `inputs` (the three runs, by recorded MD5 sums, and the same cells, cover, elevation and areas), `exchanges` (protocol 2's frozen exchanges at the verified commit), `job` (the snowy July and August output: 12 fit records, 8 converged and 4 not fitted; 252 uniquely identified rows; the same support for every version; numbers exactly where a converged fit has eligible cells; the known support of three regions; three numbers within 1e-6 in contrast and 0.1 % in standard error of the first trial; one saved fit reproducing its 21 contrasts and standard errors). The spec adds these and `tests/test_config.R` and `tests/test_paths.R`, and is to be launched from the main checkout. The tests cover every distinct start and end period of the published table. The README lists the tool and its check |

**The trial repeated** (commit `b0d1db7`, the same six jobs; logs in the trial folder): every one of the 420 rows is
identical to that of 15 November. Whole jobs: snowy July and August 5 minutes 17 seconds, peak memory 0.76 GB; the
two cheap jobs 54 and 50 seconds, about 1.0 GB. Report 7 seconds. The ten test files pass, and the three checks pass
on the real data.

**Astra's check of these changes** (`2026-11-16_cover_contrast_changes_check_codex_gpt6astra.md`): ready after three
small changes to the spec and this note, made on 16 November: the spec names commit `7c12534`; two passages that
still called the 10 % count Lejeune's condition now call it a count adapting one element of their filter; and the
plan for the full run is recorded below. Chris approved the full run on 15 November ("Timing job then all"), once
the changes are checked and verified, so question 8 of section 9 is answered.

**The plan for the full run.** From the verified commit's worktree
(`/home/expert/Documents/contracting/Andria/paleo-RF-verify/7c12534`), into a fresh output folder kept apart from
the trial and the verification output, with one thread per job and `/usr/bin/time -v` around each:

1. The timing job first: the all-days table, July, all six versions, including the two with a location term of
   500. It is also the first of the 36 jobs. Its elapsed time, peak memory and saved-file sizes are recorded.
2. The other 35 jobs, as many at once as free cores and memory allow, allowing 1.5 times the timing job's peak
   memory per job (a judgement, not a measured guarantee) and watching the first batch.
3. The report command, only after the completion checks: 36 jobs that exited without error; 216 fit-status
   records; 4,536 contrast rows, unique by table, month, version, region and exchange; 36 case files and 212
   saved fits; exactly four fits not made by design (the two versions with a location term of 500 in the snowy
   table's July and August). Failed fits are reported apart from missing jobs, and numbers must be present exactly
   where a converged fit has eligible cells. The report command stacks whatever files it finds, so it cannot
   itself show that the run is complete.

## 11. The comparison with Duveiller et al. (2018), 17 November

*Built by an Opus agent to Astra's design (`2026-11-16_duveiller_comparison_design_codex_gpt6astra.md`) with Chris's
decisions (`2026-11-17_duveiller_comparison_decisions.md`), which answer question 4 of section 9: the file was
downloaded, and all three exchanges are compared. Not yet reviewed by Fable and Astra, and not yet run through the
verification tool.*

**What it is.** A third command of the tool, which sets the six versions' all-days results beside the monthly change in
albedo that Duveiller et al. published for the nearest of their vegetation transitions, on the cells both cover:

```
Rscript tools/explore_cover_contrasts.R duveiller <saved-contrast-dir> <netcdf-file> <output-dir>
```

It reads the all-days cases and fits that the full run of 16 November saved (twelve months, 72 fits; nothing is
refitted) and `albedo_IGBPdet.nc` (Figshare version 1, MD5 `96125db41154fa176c53b51596893ad6`, in `data/duveiller2018/`
of the main checkout with its provenance note, not in git). For each month, region and exchange it keeps the saved
eligible cells that have a published estimate (a finite `Delta_albedo`) for the matched transition, renormalises their
areas into weights, and averages both estimates with those weights: the published change times 0.10 (Lejeune et al.
2020, eq. 11), and each version's predicted change for the 10-point exchange, which is not scaled. The transitions are
23 (needleleaf evergreen to broadleaf deciduous forest; the file holds it the other way round, so its sign is
reversed), 38 (needleleaf evergreen forest to grassland) and 28 (broadleaf deciduous forest to grassland). Cells are
matched by exact centre, months and transitions by their coordinate values. Beside each mean: the eligible and common
cells, the common area, its share of the eligible area and of the region's calibration area, and the fewest and most
published samples behind the common cells. It writes `cover_contrasts_duveiller.csv` (1,512 rows, with its
explanation), `cover_contrasts_duveiller.pdf` (one page in the layout of the report's pages, the published means as
black diamonds) and `record_duveiller.txt` (inputs with MD5 sums, the mapping and settings, the time of each step).

| File | Lines | What changed |
|---|---|---|
| `tools/explore_cover_contrasts.R` | 681 (+291, -31) | The `duveiller` command. The six versions' styling, the panels and the support text are now four small functions shared by the report's pages and the comparison's page; the report's four pages are pixel-identical before and after. The record writer takes extra lines and MD5 sums computed earlier |
| `tests/test_explore_cover_contrasts.R` | 345 (+142, -4) | A miniature of the published file written by the test; the saved job of the hand-made run for all twelve months; the guards |
| `tools/check_cover_contrasts.R` | 276 (+119, -1) | `duveiller`: the check of the command's output on the full saved run |
| `docs/cc/verification/2026-11-17_duveiller-comparison.R` | 33 (new) | The verification spec, its commit left as `TO_FILL` |
| `README.md` | | The two rows of the tool table |

**Choices made in building it.**

1. **No summary of the published uncertainties** (Chris, 16 November). The tool does not read `SD_Delta_albedo`; the
   check reads it only to confirm that every estimate of the three transitions has one. **Open, for Chris to return to
   if he wants:** how, if at all, to summarise the published cell uncertainties for a region. The file gives a standard
   deviation for each one-degree cell but no covariance between cells, so an interval for a regional mean needs an
   assumption about how the cells' errors are related. Astra's proposal, not built: the area-weighted mean of the cells'
   standard deviations multiplied by 0.10, labelled as describing the cells and not the regional mean; a project choice
   with no published precedent found.
2. **The share of the region's calibration area where no cell was eligible** (Alaska and Yukon in December, polar
   night) is 0, as its definition gives (common area over the region's calibration area, which is not empty); the
   design's shortcut (the saved area share times common over eligible area) would give 0/0 there. It is missing only
   for a region without calibration cells. The share of the eligible area is missing wherever nothing was eligible.
3. **The published method's rule of at least 20 samples** is checked, not used as a filter: the command stops if an
   estimate rests on fewer. None does.
4. **The region's calibration cells** are carried from the saved results into the table, for the panel titles.
5. **The tests** are in the tool's own test file, so that they reuse its hand-made run and stand-in fitter.

**The trial of 17 November** (commit `9c815d1`, the command as committed, on the full saved run; its outputs are kept
outside git). 1,512 rows. Measured: hashing and reading the inputs 2.5 seconds; recomputing the six versions on the
common cells 115.7 seconds; writing the table and figure 2.5 seconds; the whole command 2 minutes 1 second; peak memory
0.48 GB. The check passes in 7 seconds, the test file in 38. The northeast's common cells are those the design's
inspection counted (January 20, 1 and 11 of 58, 41 and 22 eligible; July 40, 5 and 12).

**What the trial shows** (a description, not a verdict; changes per 10 points of cover):

- **Coverage is partial.** Typically a quarter to a third of the eligible cells' area, and a tenth to a fifth of a
  region's calibration area, has a published estimate. Some panels rest on very few cells: the northeast's evergreen to
  open land on 1 cell in January and February and 4 or 5 otherwise; Alaska and Yukon's summergreen to open land on 0 to
  2 cells all year; none of Alaska and Yukon's cases in January and December.
- **The published changes are brightenings almost everywhere:** evergreen to open land +0.003 to +0.027, summergreen to
  open land +0.001 to +0.038 (largest in winter), evergreen to summergreen +0.001 to +0.007, with three small negative
  means (Alaska and Yukon in February, two cases in spring).
- **Two examples beside them** (northeast, evergreen to summergreen, location term 100 with straight-line cover): in
  January the version predicts -0.021 where the published mean is +0.006; in July +0.0069 beside +0.0036. No pooled
  score is given: counting every version, region and month alike would weigh sparse panels and overlapping regions as
  much as the rest (Astra's review of 17 November).

**Not done.** Astra's review of the code (Chris's arrangement of 16 November: Astra reviews, no Fable review); the verification tool's run (the
spec should then name the reviewed commit); the changelog entry; the GitHub issue; a registry check of the four
references (the design's checks could not reach Crossref); and the update of the existing scientific question on how
the classes correspond.

## References

As in the design, plus (the comparison of section 11 cites the references of its own design):

- Boisier, J. P., de Noblet-Ducoudré, N., & Ciais, P. (2013). Inferring past land use-induced changes in surface
  albedo from satellite observations: a useful tool to evaluate model simulations. *Biogeosciences*, 10,
  1501-1516. doi:10.5194/bg-10-1501-2013
- Euskirchen, E. S., et al. (2016). Consequences of changes in vegetation and snow cover for climate feedbacks in
  Alaska and northwest Canada. *Environmental Research Letters*, 11, 105003. doi:10.1088/1748-9326/11/10/105003
