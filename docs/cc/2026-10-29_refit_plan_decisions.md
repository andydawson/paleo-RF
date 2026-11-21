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

## Decided by Chris after the code reviews (30 and 31 October)

Fable and Astra reviewed the built code independently, then one reconciliation round each
(`2026-10-30_refit_code_review/`). No blocker, no arithmetic error. Chris then decided:

10. **Apply every fix both reviewers agreed, then verify the original configuration** (30 October):
    the model-7 tool refuses a refit that is not like with like (same rows, formula, family and
    link; the saved fit's controls with only the step limit changed); script 4 prints the rows each
    month can be fitted on and stops before fitting if a month has fewer than the largest model's
    coefficients; script 5 stops if an observed cell has no interval; a test that the looser albedo
    versions keep no fewer retrievals than the stricter ones; corrected attributions, a sourcing fix
    and two small tidies.
11. **The older all-months anchor** (`tests/anchors/interp-allmonths-2026-09-20`, compared within
    0.02): stop comparing its "data in credible interval" column, whose meaning changed with item 4;
    the file and its other checks stay (30 October).
12. **Retrieval support in script 2's run record** (30 October): per month, the median and 10th
    percentile of the selected version's pixel coverage and days per pixel, labelled as the support
    of all qualifying retrievals (not of the snow-free or snowy days alone); no filtering or weighting.
13. **The snowy run's months** are chosen by Chris from script 2's counts before any fitting (30
    October). Provisional counts: July 470 and August 360 snowy cells, below the 748 coefficients of
    models 7 and 8.
14. **A drift-and-conciseness review of the whole code** after this merge (30 October).
15. **Script 5's new check** compares the missing-value patterns value by value (31 October): the
    first form also compared the "2.5%" names that quantile() attaches and stopped the legacy run
    although no cell was wrong.

The implementer's two reworded real-table tests (a 2.5e-6 rounding bound for the snow mixing
identity; the version check restricted to months and cells the 75-degree rule cannot touch) were
accepted by both reviewers; they were not put to Chris as a separate choice.

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

## Still open (to put to Chris with the input check, before the runs)
- The November-February run: both reviewers advise reporting its four months from script 10's
  per-month column beside the same months of the main run, and never quoting the four-month
  aggregate (scripts 9 and 10 call it "annual"); no code change.
- The raster control: check its calibration table's MD5 against the 18 October script-2 manifest.
- A fixed seed for the new runs, stated as reproducibility, not pairing (both agents).

## Still open (from the plan review)
- Monthly training support (Astra) or May only (current): Fable suggests a loop over months in the
  existing tool "if at all".
- The verification gaps Fable lists (hand-made toy test, mixing identity on the real table, per-month
  counts in script 2, one MODIS scenario re-run for byte identity).
- References: section numbers are not cited until the audit reports.
