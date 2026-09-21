# Run: non-interp pipeline, May, scripts 4 to 7 (RECONSTRUCTED)

**Note.** Repeat of the March run for May, chosen because May is the month
Andria shows in the EGU talk, so the results can be compared with her
slides directly. This is the **second** attempt: the first, launched
16:14, stalled completely and was killed (see below).

**Written by hand after the fact**, before `R/run_manifest.R` existed.

## Provenance

- when: 2026-09-17 18:52 to 22:51
- status: completed, scripts 4, 5, 6, 7. Scripts 1 to 3 not re-run; the
  calibration table from the March run was reused, since it already
  holds all twelve months. Scripts 7a and 8 blocked on missing data.
- commit: branch `run-may`, off `chris-dev`, at `e6f3d70`
- working tree: clean at launch
- host: beastly | cores used: 0-7 of 48, `nice -n 10`
- BLAS/OMP/MKL threads: 8 / 8 / 8
- R version 4.5.3 (2026-03-11)
- packages: mgcv 1.9.4, terra 1.9.50, raster 3.6.32, sp 2.2.3,
  dplyr 1.2.1, gratia 0.11.2, ggplot2 4.0.3

## Config

- flavour: non-interp (505 pollen-bearing cells)
- month: May, via `CAL_MONTH=may`
- alb_prod: bluesky
- outputs tagged `<month>_bluesky` so they do not overwrite March's

## Code changes required (marked `# [run-may]`, on top of the March set)

The calibration month was hard-coded as March in nine model formulas in
script 4 and in script 5's correlation, simulation summary and plots, and
no non-interp output carried a month, so a second month would have
overwritten the first. Scripts 4, 5, 6 and 7 now read
`cal_month = Sys.getenv('CAL_MONTH', 'may')`, use `get(cal_month)` in the
formulas (the same idiom the interp loops already use), and tag every
output and figure with `<month>_bluesky`.

## The first attempt, and why it failed

Launched 16:14 without capping the BLAS thread count. The conda build of
R started 48 linear-algebra threads inside the 8 cores it was pinned to
and thrashed: after 2 h 38 min not one model had been saved, against
roughly 9 min per model when healthy. Killed at 18:52 and relaunched with
`OPENBLAS_NUM_THREADS=8` and matching OMP and MKL caps, after which the
first model finished in 8 minutes. **This is why the manifest records
thread caps.**

## Inputs

  - data/calibration_modern_lct_bluesky.RDS (from the March run)
  - data/lct_paleo_reveals.RDS

## Outputs (anchored in tests/anchors/nointerp-may-2026-09-17)

  - data/calibration_mod{1..8,7_free}_may_bluesky.RDS (not anchored)
  - data/calibration_model_selected_may_bluesky.RDS
  - data/paleo_predict_gam[_samps|_summary]_may_bluesky.RDS
  - data/alb_preds_diffs_may_bluesky.RDS

## Timings measured

- script 4: 3 h 50 min for the nine-model ladder on 8 cores
- scripts 5 and 6 seconds each; script 7 ~8 min

## Results and the anomaly it exposed

Selected model adjusted R-squared 0.899, model-versus-data correlation
0.958, both slightly better than March.

The AIC table, however, **rose with model complexity**, from -169 for
model 1 to +2,939 for model 8. Correctly fitted nested models cannot lose
that much likelihood by gaining terms, so the comparison is unsound. This
prompted the investigation recorded as B4 in
`docs/cc/questions_for_andria_scientific.md`: the models are fitted by
REML and compared across differing mean structures, which is not a valid
likelihood comparison, and the cover models are rank deficient because
the three fractions sum to one. The interp run of 2026-09-20 later
produced a well-behaved, monotone AIC table, so the anomaly appears
specific to the small non-interp sample rather than general.

Continental mean albedo change per period agrees in sign with the talk's
May forcing bars in six of seven intervals; the exception is 4 to 6 ka,
where the talk shows the hemlock-decline cooling reversal and this run
shows weak warming. That disagreement persists in March, so it is not a
month effect.
