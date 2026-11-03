# Refit runs on the MODIS albedo: log (from 1 November 2026)

GitHub issue: #23.

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

## The queue for the remaining runs (Chris, 2 November: keep things running until all the jobs are done)
- Order as decided: run 8's pipeline; runs 2, 3, 4 (fitting in three four-month parts each), 5 and 6
  (November-February: two two-month parts), 7 (snowy, ten months: jan-apr, may/jun/sep, oct-dec). One run's
  fitting at a time; up to four jobs at once; each run's pipeline (script 6 included) after the previous
  run's pipeline. Each job runs on its own documentation-only commit below.
- Settings checked with the configuration's own validation on 2 November (all valid). Calibration rows per
  month, worked out with script 2's own function on run 1's cells (the main run's counts match run 1's log):
  smallest are run 2 January 1227, run 6 January 1301, run 7 September 1091 (July and August left out);
  every fitted month is above the largest model's 748 coefficients.
- run8-raster: a documentation-only commit so that it gets its own worktree.
- run2-snowfree-fit-jan-apr: a documentation-only commit so that it gets its own worktree.
- run2-snowfree-fit-may-aug: a documentation-only commit so that it gets its own worktree.
- run2-snowfree-fit-sep-dec: a documentation-only commit so that it gets its own worktree.
- run2-snowfree: a documentation-only commit so that it gets its own worktree.
- run3-any75-fit-jan-apr: a documentation-only commit so that it gets its own worktree.
- run3-any75-fit-may-aug: a documentation-only commit so that it gets its own worktree.
- run3-any75-fit-sep-dec: a documentation-only commit so that it gets its own worktree.
- run3-any75: a documentation-only commit so that it gets its own worktree.
- run4-any75-snowfree-fit-jan-apr: a documentation-only commit so that it gets its own worktree.
- run4-any75-snowfree-fit-may-aug: a documentation-only commit so that it gets its own worktree.
- run4-any75-snowfree-fit-sep-dec: a documentation-only commit so that it gets its own worktree.
- run4-any75-snowfree: a documentation-only commit so that it gets its own worktree.
- run5-winter-fit-jan-feb: a documentation-only commit so that it gets its own worktree.
- run5-winter-fit-nov-dec: a documentation-only commit so that it gets its own worktree.
- run5-winter: a documentation-only commit so that it gets its own worktree.
- run6-winter-snowfree-fit-jan-feb: a documentation-only commit so that it gets its own worktree.
- run6-winter-snowfree-fit-nov-dec: a documentation-only commit so that it gets its own worktree.
- run6-winter-snowfree: a documentation-only commit so that it gets its own worktree.
- run7-snowy-fit-jan-apr: a documentation-only commit so that it gets its own worktree.
- run7-snowy-fit-may-jun-sep: a documentation-only commit so that it gets its own worktree.
- run7-snowy-fit-oct-dec: a documentation-only commit so that it gets its own worktree.
- run7-snowy: a documentation-only commit so that it gets its own worktree.

## Power cut, 2 November about 12:15 UTC
- The power cut stopped the four running jobs part-way: run 8's fitting (January-February, May-July and
  September-October done; March, August and November part-fitted) and the model 7 check (January and February
  done). None finished, so none has a report; their folders are kept as they are, unused.
- Partial model 7 check, from its log (`f44881b/.rundirs/run1-model7-check/checks.log`): at 2,000 steps
  January's refit stopped after 753 steps with AIC 2.2 lower than the saved 500-step fit, and February's after
  639 steps with the same AIC; fitted values moved by at most 4e-5. The rerun repeats every month.
- Rerun from the start under new names (the verification tool refuses an existing run folder): specs
  `2026-11-02_run8-raster-fit-{jan-apr,may-aug,sep-dec}-2.R` and `2026-11-02_run1-model7-check-2.R`, identical
  to the first ones except the name; same commits, cores and settings. `run8-raster` now copies the fits from
  the `-2` folders. Started 12:26-12:33 UTC (cores 8-31 and 32-39 as before).
- The queue scripts now live outside the temporary folder (`../refit-queue/`), so a reboot no longer loses them.

## Run 8 (raster control) and the model 7 check: finished
- Run 8's fitting reruns finished 2 November (May-August 19:25 UTC; the other two by about 21:10 UTC); its
  pipeline (`run8-raster`, 795792f) PASS, 3 November 00:10 UTC, about 3 hours.
- **Run 8 against the 18 October run** (both on Andria's raster, seed 1549466984; same calibration table, MD5
  as required): partial-ice study-area mean, HadGEM3 kernel, W/m2, 18 October / run 8: 0.05-0.5 ka -0.692 /
  -0.696; 0.5-2 ka -0.668 / -0.684; 2-4 ka +0.489 / +0.494; 4-6 ka -0.575 / -0.573; 6-8 ka +1.102 / +1.101;
  8-10 ka +4.547 / +4.553; 10-12 ka +4.429 / +4.442. Close but not identical (largest difference 0.016, in
  0.5-2 ka): the code and fitting settings changed in between (one maths-library thread instead of 48, the
  fixes since 18 October), and the simulated draws follow any small change in the fits. Run 1's differences
  from the raster (0.1 to 0.4 W/m2 per period) are ten or more times larger, so they come from the albedo
  source, not from the code.
- **Model 7 check (`run1-model7-check-2`, PASS 2 November):** refitted at 2,000 steps, model 7 converges in
  631-841 steps in every month where it had stopped at 500; AIC moves by at most 2.2 (January -2.2,
  February 0.0, March 0.0, April -1.9, June -0.6, October -0.2); fitted values by at most 0.0002; July, the
  control, unchanged. Against model 8 (run 1's AIC table) the ranking is unchanged: model 8 is lower in March,
  June and October, the two tie within 1 in February and April, and model 7 leads by 3 in January (by 1
  before). Model 8 stays the prediction model.
- 2-3 November night: the queue runner stopped at each milestone and waited to be restarted, so run 2's
  third fitting part did not start until 07:59 UTC. The runner now never stops for milestones.
- 3 November 07:59 UTC: replacing the runner killed run 2's September-December part one minute after it
  started (stopping a background task kills everything it started). Rerun as `run2-snowfree-fit-sep-dec-2`
  from 08:01 UTC; run 2's pipeline spec now copies from that folder. Jobs are now launched detached from the
  runner.
- **Chris, 3 November: up to six jobs at once, and the next runs' fitting no longer waits for the previous
  run's fitting** ("don't let the machine sit idle"). Pipelines still run one after another. The queued
  fitting specs of runs 3-7 no longer pin cores (a fit uses about one core); results do not depend on which
  cores are used. From 08:18 UTC: run 2's two remaining parts, run 3's three and run 4's January-April part.

## Run 2 fitting and run 4 May-August: finished
- Run 2 (snow-free albedo), all three fitting parts PASS: January-April 08:36 UTC 3 November (681 min of
  fitting), May-August 02:38 UTC (323 min), September-December (`-2`) 15:48 UTC (464 min). Run 2's pipeline
  started next.
- Run 4 (any-quality 75 degrees, snow-free), May-August PASS, 14:24 UTC (345 min).
- In all four parts every one of the 36 fits (9 models x 4 months) reached full convergence of the smoothing
  parameters within the 500-step loop: none stopped at the limit, model 7 included (on run 1's all-days
  albedo it stopped at 500 in six months).

## Machine restart, 3 November
- Run 3 September-December fitting PASS before the restart.
- About 16:30 UTC the machine had to restart (a driver fault). It stopped six jobs: run 2's pipeline, run 3's
  January-April and May-August fitting, run 4's January-April and September-December fitting, and run 5's
  January-February fitting (started 16:13). Each is rerun under a `-2` name, its spec identical but for the
  name; runs 3-5's pipeline specs now copy from the `-2` folders. Restarted 16:43-16:46 UTC, six at once.
- The restart also emptied the temporary folder holding the working copies; they now live in
  `../paleo-RF-wt/`.
