# Refit runs on the MODIS albedo: log (from 1 November 2026)

Decisions: `2026-10-29_refit_plan_decisions.md`; input check shown to Chris on 31 October
(`2026-10-31_refit_input_check.md`). Chris, 31 October-1 November: fixed seed 1549466984 for every run;
the November-February runs reported month by month only, never their four-month "annual" total; main
run first; launch.

Model fitting runs in four month-split parts at once; each part needs its own worktree, so each runs at
its own code-identical commit on branch `refit-runs` (documentation-only commits).

## Commits for the parallel fitting parts
- part 2: a documentation-only commit so that part 2 gets its own worktree
- part 3: a documentation-only commit so that part 3 gets its own worktree
- part 4: a documentation-only commit so that part 4 gets its own worktree

## Decisions during the runs
- **Snowy run (run 7) months, Chris, 1 November:** every month except July and August. Snowy cells per
  month under the main version on run 1's calibration cells (after the ice mask; largest model 748
  coefficients): Jan 1389, Feb 2025, Mar 2352, Apr 2182, May 1796, Jun 1253, Jul 470, Aug 360, Sep 1091,
  Oct 1737, Nov 1327, Dec 1079. July and August cannot support the unchanged models; June and September
  are thin but fit.
- **Code:** all eight runs use the code at 837f2d3 (refit-runs is documentation-only on top of it), so
  they stay comparable; the drift fixes chosen on 1 November go in separately, and the diagnostic figures
  are redrawn with the fixed tools afterwards.

## Run 1 (main)
- Fitting started 1 November 2026, about 08:37 UTC: four parts (jan-mar 5ddcb94, apr-jun be277d7,
  jul-sep f9f9e46, oct-dec 8db4a5e), THREADS=1, cores 0-31. Rows to fit: Jan 1726, Feb 2397, Mar 2806,
  Apr-Sep 2808, Oct 2662, Nov 1866, Dec 1416.
- Fitting parts apr-jun, jul-sep and oct-dec finished with exit status 0. Model 7 reached its 500-step limit in
  January, April, June and October (May 436 steps, July 86, August 62, September 98, November 170, December 215;
  February and March still fitting).
- The rest of the pipeline (scripts 1-3, 5-10) runs once from the four parts' fits as `run1-main`, on d5d5df5,
  started automatically when the last part finishes (cores 0-7, eight threads).
- Run 8 (raster control) fitting part 1: a documentation-only commit so that it gets its own worktree.
- Run 8 (raster control) fitting part 2: a documentation-only commit so that it gets its own worktree.
- Run 8 (raster control) fitting part 3: a documentation-only commit so that it gets its own worktree.
- Model 7 convergence check on run 1: a documentation-only commit so that it gets its own worktree.
- Fitting part jan-mar finished 1 November about 22:50 UTC (about 14 hours; jul-sep took about 3, oct-dec 5, apr-jun
  6.5). Model 7 also reached its limit in February and March, so the months at the limit are January-April, June
  and October.
- `run1-main` (scripts 1-3, 5-10 from the four parts' fits): PASS, 2 November about 01:40 UTC; about 2 hours 50
  minutes, mostly scripts 7 (70 min) and 7a (76 min); script 6 took 11 minutes.

## Run 8 (raster control) and run 1's model 7 check
- Started 2 November about 07:24 UTC: run 8's fitting in three four-month parts (jan-apr b689642, may-aug 280a9a0,
  sep-dec bd174cf; cores 8-31) and the model 7 check (`run1-model7-check`, f44881b, cores 32-39: January-April,
  June and October, with July, converged in 86 steps, as the control).
- Run 8's calibration table in all three parts has MD5 8119f5066dc82d79571e94f7a6e791e6, the 18 October run's, as
  required: the raster source is reproduced exactly by the refit code.
