# The hindcast comparison tool: what was built, and the choices the protocol did not make

*Fable 5.2 (builder), 10 November 2026, branch `cv-compare-tool` (off `cv-v2`). Chris: "Now, but fable to build
then Astra review". For Astra's review and the verification run that follows it.*

**Benefit to the paper.** It sets the finished pipeline runs side by side, so that Chris and Andria can see what
the choice of calibration model does to the albedo, to the forcing by period and to the northeast over the hemlock
decline, with the tested limits beside the numbers.

## What was built

| File | What it is |
|---|---|
| `tools/compare_cv_hindcasts.R` | The tool of protocol 2, section 7. Reads the runs' saved products; writes five tables, four figures and a record into its own output folder. Nothing is fitted and nothing is written into a run folder. |
| `R/hindcast_comparison.R` | Its arithmetic as small functions: regional means with their support, script 9's period sums kept per cell and month, differences from the baseline, the northeast swaps, the monthly geographic support. |
| `tests/test_hindcast_comparison.R` | Hand-worked cases for each function; no model fitted, no run read. |
| `R/training_support.R`, `tools/plotting/plot_northeast_cover_and_location.R` | `cells_with_evergreen()` moved out of the northeast figure tool so both tools build the swap the same way (two call sites changed there, nothing else). |
| `R/cross_validation.R` | `slice_area_ice()` taken out of `cv_target_weights()` (lines moved unchanged) so the albedo means use the same area and ice-free fraction as the cross-validation's target. |
| `docs/cc/verification/2026-11-10_cv-hindcast-comparison.R` | The verification spec, commit to fill in; not run. |

Use: `Rscript tools/compare_cv_hindcasts.R <output-dir> <cv-output-dir> <baseline-run-dir> <run-dir> [<run-dir> ...]`.

## Choices the protocol did not make

1. **Any number of runs, the first being the baseline** (10 November: three runs). Each run is named by its model id
   from `config_used.R`. The tool stops if two runs share a model, or differ in any other analysis setting.
2. **The study area is the cells of script 8's forcing table**: 27 to 74 N, east of 170 W, with an ice fraction;
   2,655 cells. The same cells feed every run.
3. **Albedo table: the pipeline's albedo** (the mean of the simulated albedo, which the forcing is made from),
   weighted by area times ice-free fraction, as the cross-validation's target is. The year is the mean over months.
4. **Forcing table: three saved variants side by side** (Astra's check of the results review, 10 November): the
   vegetation part, the ice part and the total of the partial-ice split, for every run, period, month and kernel,
   in one row. They are script 8's saved columns `veg_part`, `ice_part` and `veg_ice_parts`, summed by script 9's
   rule. Scripts 9 and 10 saved the study-area means only, so the months, the northeast and the hemlock interval
   need the same sums again; **the tool stops unless it reproduces every number those scripts did save** (script
   9's totals for three kernels, its HadGEM3 parts from the variant table, script 10's monthly means). Scripts 9
   and 10 themselves are untouched (the protocol allows no pipeline change), so the period sum now exists in the
   tool's helper as well as in those scripts; the check guards against drift.
5. **The hemlock interval for both regions**, labelled `4.5 - 6 ka` like the other periods (the protocol asks for the
   northeast only; the same code serves both).
6. **Support.** Each month's training range comes from the calibration table's complete rows, and each fit is
   checked to have used exactly those rows. A mean's "outside part" is on the whole mean's denominator; the inside
   part is the rest. Bands are the cross-validation's. Outside shares in the northeast table are area shares.
7. **Validation errors and tested limits** (section 7: "beside them, without further support classes"): one small
   table taken from the cross-validation's `by_distance.csv` and `nearby_coverage.csv` for the runs' models. The
   tool does not assign a departure direction to hindcast cells.
8. **Geographic support by month** (same check, 10 November): for each month, the past cells with no fitting cell
   at their own place and those north of every fitting cell, for both regions. One table, no new method.
9. **Northeast table.** Fitted albedo from the saved `prediction_point` table, checked against `predict()` of the
   saved fit; the pipeline's simulated 6 to 4.5 ka change beside it. The swaps are exchanges on common valid
   cells, with the existing delta-method standard error. **One addition to section 7's list:** the historical-size
   exchange of the separation test, for all twelve months, because the review of 10 November reads the northeast
   through it. It reproduces the capacity table in April and May to 1e-12.
10. **Tables are CSV files that start with comment lines** (marked `#`) saying what they hold and stating the
    signs. Read them with `read.csv(file, comment.char = '#')`.
11. **Figures** are PNG. Albedo maps show the difference on the ice-free share of each cell, mean over months;
    forcing maps the HadGEM3 total for the seven periods; the April and May figure draws the lines at 50 BP open
    land and gives the share of area outside the range at each end in the panel titles.
12. **No pass or fail statement anywhere.** The comparison with published contrasts is an exploration only (Chris,
    10 November); `position_4.5ka` describes where a prediction sits against today's observed range.

## What did not fit the real files

- A straight-line cover model's fit does not carry the open-land column, so the training range cannot be built
  from `fit$model` as the older figure tools do; hence choice 6.
- Script 7a stores the cell area with its unit; it is converted to a plain number.
- The simulated-mean table is in another row order than the fitted table; rows are matched by cell, slice and month.
- The three steps of the hemlock interval sum to the end-to-end change only where there is no ice. The northeast
  has none in that interval (996 cell-months compared, none left out).
- "A run compared with itself gives zero" cannot be run, because the tool stops on two runs with one model. The
  spec checks the equivalent: with two runs' roles reversed every difference changes sign.
- Not done: scripts 9 and 10 were not rewritten to share the period sum (see choice 4); the northeast figure tool
  was parsed after its two-line change, not rerun (it needs a run folder with model-8 fits).

## What was run

- All files parse. `tests/test_hindcast_comparison.R`, `test_training_support.R`, `test_cross_validation.R`,
  `test_cross_validation_stages.R`, `test_cv_separation.R`, `test_forcing_periods.R` and `test_model_registry.R` pass.
- One trial of the tool on the three runs (model 8 as baseline, the chosen model, the coarse-location model),
  written to the scratchpad; about three minutes on one thread. All its built-in stops passed: forcing against
  scripts 9 and 10 (largest gap 2e-14 W/m2), the northeast steps (0), each fit's rows, the saved predictions.

### Key numbers from the trial (to be confirmed by the verification run)

Study-area forcing, HadGEM3, mean over months, W/m2 (positive is warming): vegetation part / ice part / total.

| Period | Model 8 | Chosen model | Coarse location |
|---|---|---|---|
| 0.05 - 0.5 ka | -0.56 / 0.00 / -0.56 | -0.14 / 0.00 / -0.14 | -0.16 / 0.00 / -0.16 |
| 0.5 - 2 ka | -0.57 / 0.00 / -0.57 | -0.09 / 0.00 / -0.09 | -0.30 / 0.00 / -0.30 |
| 2 - 4 ka | +0.34 / +0.01 / +0.35 | +0.05 / +0.01 / +0.06 | +0.38 / +0.01 / +0.38 |
| 4 - 6 ka | -0.56 / +0.11 / -0.45 | +0.11 / +0.09 / +0.20 | -0.25 / +0.09 / -0.17 |
| 6 - 8 ka | -0.07 / +1.58 / +1.51 | +0.07 / +1.46 / +1.54 | +0.27 / +1.39 / +1.66 |
| 8 - 10 ka | -0.22 / +5.18 / +4.96 | -0.05 / +5.00 / +4.95 | +0.30 / +4.82 / +5.12 |
| 10 - 12 ka (ends at 11.5 ka) | +1.14 / +2.99 / +4.13 | -0.03 / +2.90 / +2.87 | +0.91 / +2.75 / +3.65 |
| 4.5 - 6 ka (hemlock interval) | -0.54 / +0.11 / -0.44 | +0.03 / +0.09 / +0.12 | -0.60 / +0.09 / -0.51 |

Northeast over the hemlock interval (no ice there, so the total is the vegetation part), HadGEM3, W/m2: mean over
months +3.48 (model 8), -0.83 (chosen), -2.60 (coarse), the same signs with the other two kernels; April +6.71 / +0.29 / -8.82; May +15.36 / -0.65 / -7.98;
July +1.82 / -3.13 / -3.99; December -1.67 / +1.31 / -0.43. Every northeast cell has a cover mix outside the
month's training range at some end of the interval (largest distance 0.107).

Northeast fitted albedo change, 6 to 4.5 ka (positive is brighter): April -0.043 / -0.003 / +0.056; May -0.075 /
+0.003 / +0.043; July -0.008 / +0.013 / +0.017; December +0.053 / -0.041 / +0.012.

Geographic support, study area: past cells north of every fitting cell: 1,340 of 2,655 in December (fitting cells
reach 53.5 N; 38% of the area), 1,013 in January (58.5 N; 27%), 875 in November, 288 in February, 69 in October,
none from March to September (36 to 38 cells then have no fitting cell at their own place). In the northeast every past cell has a fitting cell at its place in every month. (The main session's
count of 1,344 and 1,017 of 2,659 is over all cover cells in 27 to 74 N; four of those are not in the forcing table.)

## What the verification spec checks

The five test files; the tool on the three runs; the tool again with model 8 and the chosen model in reversed
roles; then on the tables: every file written; the expected row counts; zero differences for the baseline; the
vegetation and ice parts adding up to the total in every row; the April and May historical-size exchange equal to
the capacity table's; the fitted and simulated 6 to 4.5 ka changes within 0.005; the geographic counts above;
and every difference changing sign when the roles are reversed.
