# Refit on the rebuilt albedo: Chris's decisions (29 October 2026)

**Benefit to the paper:** the calibration moves from Andria's undocumented, water-contaminated,
centre-pixel albedo raster to the documented land-only MODIS cell means
(`data/albedo_modis_cells.csv`, made by `tools/prepare_bluesky_albedo.R`), and the refit shows how
the forcing, and the northeast hemlock result, depend on that input.

Sources: Astra's plan (`2026-10-29_refit_plan_codex_gpt6astra.md`), Fable's adversarial review
(`2026-10-29_refit_plan_review_fable.md`), the brief both were given
(`2026-10-29_refit_plan_brief.md`). Chris chose between them on 29 October; only explicit choices are
recorded as his decisions.

## Decided by Chris

1. **Snow plan.** The plan of 19 October is live: calibrate on the snowy and on the snow-free albedo
   and mix the two by each cell-month's snow share. Built in steps: this refit lets the calibration
   use the all-days, snow-free or snowy albedo of the cell table; the mixing step is a separate,
   later change with its own plan. (Astra's plan used the superseded two-run plan of 16 October
   because the brief gave it; Fable found the error.)
2. **Runs.** Astra's six satellite runs, all-days and snow-free under each of: the main version
   (full inversions, 75-degree sun rule), any processed retrieval (75 degrees), and November to
   February without the sun-angle rule; plus one snowy run on the main version; plus a full refit on
   Andria's raster with the current settings, as a control (Astra's, not Fable's cheaper control).
3. **Code shape: Fable's minimal version.** One tested function in `R/` that reads and checks the
   cell table and attaches one albedo column per month by exact cell centre; one if/else in script 2
   between the raster and the cell table; counts in the run record, no new support product. The
   winter check is a run of November to February only, with the no-rule version selected, using the
   existing months setting: no new winter setting. Model 7: an optional fitting-control argument on
   the existing fitting function; refitted at 2,000 steps only in the months where it reached its
   500-step limit, plus one month where it converged, as a check that the result is unchanged.
4. **Script 5's interval-coverage share:** fixed everywhere, for both albedo sources, to count only
   cells with an observation; the one saved reference file it changes is updated in its own commit,
   recorded as this decision.
5. **Parallel runs:** up to four at once; eight cores per model-fitting job (the fitting code always
   starts eight threads), one maths-library thread; a separate code-identical commit for each run
   going at the same time; script 6 (the memory-heavy step) one at a time until its memory is
   measured on the first run.
6. **The cell table is committed to the repository** (7.8 MB), as the land elevation table was, and
   listed among the prepared inputs in `tests/test_paths.R`.
7. **Before building:** audit the references both plans cite (identity and full-text claim checks;
   started 29 October), and correct the seed records (done 29 October: the 19 October ice-cap run's
   prediction draws used seed 1384237515, the 18 October run's 1549466984, so the two were not paired).

8. **References audited (29 October):** see `2026-10-29_refit_references_audit_summary.md`. Chris
   then decided: the later snow-mixing step takes today's snow share from NASA's monthly snow-cover
   product (MOD10CM), averaged per cell over 2000-2009, as both published precedents do (Barnes and
   Roy 2010, Ghimire et al. 2014), with the share of snow-flagged albedo retrievals compared beside it.
   This replaces the 20 October default (the flag share). It does not affect this refit.
9. **Build:** start (29 October), code and tests only; no runs until Fable's and Astra's reviews of
   the code are back and Chris has seen the input check.

## Agreed by both agents, not yet put to Chris as a choice
- Join on exact cell centres from the modern predictors; the four modern cells absent from the cell
  table stay missing; both unmatched lists recorded; no filling, no coverage filter.
- Under the new albedo, script 2 draws a 1-degree map of the selected albedo and one of the gaps; the
  native-versus-coarse table and figures stay only for the raster.
- A fixed seed for the new runs, for reproducibility. (Fable: it does not pair the draws between
  runs, as Astra said; the draw noise on the forcing should be bounded once.)
- The snow-free run is described as calibration on snow-free retrievals only, never as forcing
  without snow.
- The original configuration keeps reproducing its anchors exactly.

## Still open
- Monthly training support (Astra) or May only (current): Fable suggests a loop over months in the
  existing tool "if at all".
- The verification gaps Fable lists (hand-made toy test, mixing identity on the real table, per-month
  counts in script 2, one MODIS scenario re-run for byte identity).
- References: section numbers are not cited until the audit reports.
