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
  -0.696; 0.5-2 ka -0.668 / -0.684; 2-4 ka +0.489 / +0.493; 4-6 ka -0.575 / -0.573; 6-8 ka +1.102 / +1.101;
  8-10 ka +4.547 / +4.553; 10-12 ka +4.429 / +4.441. Close but not identical (largest difference 0.016, in
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
- In all four parts every fit whose convergence script 4 prints (the eight ladder models and the prediction fit,
  nine a month, 36 a part; the seven spatial-experiment fits print none) reached full convergence of the smoothing
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

## Run 2 (snow-free days): finished
- `run2-snowfree-2` PASS, 3 November 19:42 UTC (pipeline about 3 hours). Run 5's January-February fitting
  (`-2`) PASS 19:07 UTC.
- **Forcing, study-area mean, partial ice, W/m2, HadGEM3 kernel; run 8 (raster) / run 1 (all days) / run 2
  (snow-free days):** 0.05-0.5 ka -0.696 / -0.556 / -0.312; 0.5-2 ka -0.684 / -0.567 / -0.289; 2-4 ka +0.493 /
  +0.346 / -0.023; 4-6 ka -0.573 / -0.448 / +0.233; 6-8 ka +1.101 / +1.511 / +2.262; 8-10 ka +4.553 / +4.964 /
  +7.038; 10-12 ka +4.441 / +4.125 / +4.464. CAM5 and CACK move the same way.
- Snow-free albedo halves the late-Holocene cooling, reverses the sign at 2-4 and 4-6 ka, and raises the
  early-Holocene warming by about 40% at 8-10 ka. Not yet explained; to be looked at with the diagnostic
  figures before it is interpreted.

## The northeast over the hemlock decline, month by month (3 November, corrected)
- The annual figures given earlier (box 80-66 W, 40-48 N, 83 cells, 6 to 4.5 ka as the sum of the three 500-year
  steps, area-weighted; HadGEM3: run 8 +5.5, run 1 +3.5, run 2 +2.5 W/m2) are right, but "every run darkens the
  northeast" holds for the annual mean only (Fable's review of 3 November). By month, albedo change / HadGEM3 forcing
  (W/m2), run 8 (raster) | run 1 (all days) | run 2 (snow-free):

  | Month | Run 8 | Run 1 | Run 2 |
  |---|---|---|---|
  | Jan | +0.001 / -0.06 | +0.045 / -2.23 | -0.015 / +0.75 |
  | Feb | +0.018 / -1.39 | +0.005 / -0.38 | -0.051 / +3.98 |
  | Mar | -0.037 / +4.01 | -0.062 / +6.66 | -0.034 / +3.66 |
  | Apr | -0.094 / +14.60 | -0.043 / +6.71 | -0.022 / +3.43 |
  | May | -0.094 / +18.96 | -0.076 / +15.36 | -0.014 / +2.75 |
  | Jun | -0.034 / +8.83 | -0.049 / +12.79 | -0.015 / +4.01 |
  | Jul | -0.021 / +5.12 | -0.007 / +1.82 | -0.018 / +4.34 |
  | Aug | -0.020 / +4.72 | -0.006 / +1.31 | -0.016 / +3.79 |
  | Sep | -0.033 / +4.95 | -0.008 / +1.23 | -0.015 / +2.22 |
  | Oct | -0.050 / +3.94 | -0.016 / +1.15 | -0.013 / +1.03 |
  | Nov | -0.033 / +1.73 | +0.020 / -1.04 | +0.003 / -0.17 |
  | Dec | -0.022 / +0.68 | +0.052 / -1.67 | 0.000 / +0.00 |

- Run 1 brightens from November to February, the expected direction over snow, but those months carry little
  sunlight; March to June darken strongly and dominate. Run 2 darkens in nearly every month, with no winter
  brightening. Every box cell has all twelve months in each step, and the ice part is zero in every box row.
  Columns: `alb_diff_veg_ice_parts` and `rf_hadgem_veg_ice_parts` of `output/forcing/RF_holocene_all_cases.RDS`.
  To be made for each later run.

## Run 3 (any retrieval quality, all days): finished
- `run3-any75` PASS, 4 November 04:37 UTC (pipeline about 3 hours, 7850d46). Its three fitting parts finished before:
  September-December (2 November, first attempt) and the `-2` reruns of January-April and May-August. Runs 4-6's
  fitting parts finished overnight except run 4's January-April `-2`; run 7's three fitting parts are running.
- **Forcing, study-area mean, partial ice, HadGEM3, W/m2; run 8 / run 1 / run 2 / run 3:** 0.05-0.5 ka -0.696 / -0.556
  / -0.312 / -0.635; 0.5-2 ka -0.684 / -0.567 / -0.289 / -0.736; 2-4 ka +0.493 / +0.346 / -0.023 / +0.706; 4-6 ka
  -0.573 / -0.448 / +0.233 / -0.668; 6-8 ka +1.101 / +1.511 / +2.262 / +1.425; 8-10 ka +4.553 / +4.964 / +7.038 /
  +4.596; 10-12 ka +4.441 / +4.125 / +4.464 / +4.149. Run 3 is close to run 1 (and the raster) except at 2-4 ka.
- **Northeast over the hemlock decline (6 to 4.5 ka, box mean):** annual albedo change about 0 (+0.0002) but forcing
  still +2.77 W/m2. By month, run 3 brightens strongly in winter (January +0.142, December +0.081: deciduous over snow,
  with the backup retrievals filling the winter months) and darkens from March to October (May -0.063, +12.75 W/m2);
  spring carries the sunlight, so the year still warms. Monthly HadGEM3 forcing Jan-Dec: -6.94, -1.16, +3.34, +8.48,
  +12.75, +12.39, +2.82, +1.64, +1.56, +1.54, -0.54, -2.59.

## Runs 4, 5 and 6: finished (4 November)
- `run4-any75-snowfree` PASS 09:06 UTC; `run5-winter` PASS 09:47; `run6-winter-snowfree` PASS 10:27 (runs 5 and 6 fit
  only January, February, November and December, with no low-sun rule, `full_nocut`). Run 7's fitting is running.
- **Run 4 (any quality, snow-free days), study-area forcing, HadGEM3, W/m2:** 0.05-0.5 ka -0.352; 0.5-2 ka -0.381;
  2-4 ka +0.069; 4-6 ka +0.059; 6-8 ka +1.982; 8-10 ka +6.451; 10-12 ka +4.310: like run 2 (snow-free, full
  inversions), weaker late-Holocene cooling and stronger early warming than the all-days runs.
- **Northeast over the hemlock decline, run 4:** annual albedo -0.021, forcing +2.96 W/m2; darker in every month but
  November.
- **Northeast winter months** (albedo change / HadGEM3 forcing, W/m2), run 1 (full_75, all days) | run 3 (any_75, all
  days) | run 5 (no sun rule, all days) | run 6 (no sun rule, snow-free): January +0.045 / -2.23 | +0.142 / -6.94 |
  -0.008 / +0.40 | -0.037 / +1.80; February +0.005 / -0.38 | +0.016 / -1.16 | -0.007 / +0.56 | -0.046 / +3.55; November
  +0.020 / -1.04 | +0.010 / -0.54 | -0.017 / +0.85 | +0.002 / -0.12; December +0.052 / -1.67 | +0.081 / -2.59 | +0.060 /
  -1.91 | -0.004 / +0.13. Every snow-free version darkens the northeast in winter; with snow days included the winter
  usually brightens, most strongly with any quality (run 3).

## Run 7 (snowy days): finished (4 November)
- `run7-snowy` PASS 16:32 UTC (pipeline about 2 hours, 74b5482). Run 7 fits every month but July and August, so its
  sums leave out two summer months and are not directly comparable with the other runs; it is meant to be mixed with
  run 2 by snow fraction (snow-mixing decision of 4 November), not read on its own.
- **Study-area forcing, partial ice, HadGEM3, W/m2 (ten months):** 0.05-0.5 ka -0.557; 0.5-2 ka -0.186; 2-4 ka -0.410;
  4-6 ka -0.033; 6-8 ka +1.292; 8-10 ka +2.658; 10-12 ka +2.680.
- **Northeast over the hemlock decline (6 to 4.5 ka, box mean, 83 cells), albedo change / HadGEM3 forcing:** Jan +0.090
  / -4.40; Feb -0.014 / +1.08; Mar -0.025 / +2.76; Apr -0.053 / +8.08; May -0.078 / +15.61; Jun -0.030 / +7.79; Sep
  +0.127 / -19.20; Oct -0.039 / +3.03; Nov +0.229 / -12.15; Dec +0.115 / -3.71. Snowy days brighten the northeast in
  winter, as expected over snow, and darken it in spring. The September (+0.127) and November (+0.229) brightening is
  large and rests on few snowy cells (September has the fewest, 1091); it is to be checked before the mixing uses it,
  since in the mix those months carry small snow fractions.
- **Checked (4 November):** of the 83 northeast cells, the snowy-day calibration has 83 in December to March, 61 in
  April, 42 in November, 7 in May, 6 in October and none in June or September. So run 7's northeast values for June
  and September, and nearly so for May and October, are extrapolated from snowy cells elsewhere; September's
  brightening has no local support. In the mix these months take their weight from MOD10CM's snow fraction, near
  zero there, so they should contribute little; the mixing code should still report the snowy share by month and
  region, so this stays visible.

## Where the files are (4 November)
- Each passed run's small files (forcing and calibration tables, run records, `config_used.R`, `SEEDED.txt`) are
  copied byte for byte into `results/<run>/`, tracked. The full run folders stay in `paleo-RF-verify/<commit>/.rundirs/<run>/`
  until they are moved to `../paleo-RF-results/` after the cross-validation fits.

| Run | Commit | Full folder |
|---|---|---|
| `run1-main` | `d5d5df5` | `paleo-RF-verify/d5d5df5/.rundirs/run1-main` |
| `run1-main-fit-apr-jun` | `be277d7` | `paleo-RF-verify/be277d7/.rundirs/run1-main-fit-apr-jun` |
| `run1-main-fit-jan-mar` | `5ddcb94` | `paleo-RF-verify/5ddcb94/.rundirs/run1-main-fit-jan-mar` |
| `run1-main-fit-jul-sep` | `f9f9e46` | `paleo-RF-verify/f9f9e46/.rundirs/run1-main-fit-jul-sep` |
| `run1-main-fit-oct-dec` | `8db4a5e` | `paleo-RF-verify/8db4a5e/.rundirs/run1-main-fit-oct-dec` |
| `run1-model7-check-2` | `f44881b` | `paleo-RF-verify/f44881b/.rundirs/run1-model7-check-2` |
| `run2-snowfree-2` | `8e3f3a4` | `paleo-RF-verify/8e3f3a4/.rundirs/run2-snowfree-2` |
| `run2-snowfree-fit-jan-apr` | `74c4cf7` | `paleo-RF-verify/74c4cf7/.rundirs/run2-snowfree-fit-jan-apr` |
| `run2-snowfree-fit-may-aug` | `5164b91` | `paleo-RF-verify/5164b91/.rundirs/run2-snowfree-fit-may-aug` |
| `run2-snowfree-fit-sep-dec-2` | `e04de82` | `paleo-RF-verify/e04de82/.rundirs/run2-snowfree-fit-sep-dec-2` |
| `run3-any75` | `7850d46` | `paleo-RF-verify/7850d46/.rundirs/run3-any75` |
| `run3-any75-fit-jan-apr-2` | `014e8a3` | `paleo-RF-verify/014e8a3/.rundirs/run3-any75-fit-jan-apr-2` |
| `run3-any75-fit-may-aug-2` | `e71b6ee` | `paleo-RF-verify/e71b6ee/.rundirs/run3-any75-fit-may-aug-2` |
| `run3-any75-fit-sep-dec` | `ac05239` | `paleo-RF-verify/ac05239/.rundirs/run3-any75-fit-sep-dec` |
| `run4-any75-snowfree` | `c2ccdb1` | `paleo-RF-verify/c2ccdb1/.rundirs/run4-any75-snowfree` |
| `run4-any75-snowfree-fit-jan-apr-2` | `0df176d` | `paleo-RF-verify/0df176d/.rundirs/run4-any75-snowfree-fit-jan-apr-2` |
| `run4-any75-snowfree-fit-may-aug` | `f6ca119` | `paleo-RF-verify/f6ca119/.rundirs/run4-any75-snowfree-fit-may-aug` |
| `run4-any75-snowfree-fit-sep-dec-2` | `54decc7` | `paleo-RF-verify/54decc7/.rundirs/run4-any75-snowfree-fit-sep-dec-2` |
| `run5-winter` | `4946d09` | `paleo-RF-verify/4946d09/.rundirs/run5-winter` |
| `run5-winter-fit-jan-feb-2` | `9ea33e1` | `paleo-RF-verify/9ea33e1/.rundirs/run5-winter-fit-jan-feb-2` |
| `run5-winter-fit-nov-dec` | `9a08244` | `paleo-RF-verify/9a08244/.rundirs/run5-winter-fit-nov-dec` |
| `run6-winter-snowfree` | `ba5e69a` | `paleo-RF-verify/ba5e69a/.rundirs/run6-winter-snowfree` |
| `run6-winter-snowfree-fit-jan-feb` | `baa4ae2` | `paleo-RF-verify/baa4ae2/.rundirs/run6-winter-snowfree-fit-jan-feb` |
| `run6-winter-snowfree-fit-nov-dec` | `31ac4d7` | `paleo-RF-verify/31ac4d7/.rundirs/run6-winter-snowfree-fit-nov-dec` |
| `run7-snowy` | `74b5482` | `paleo-RF-verify/74b5482/.rundirs/run7-snowy` |
| `run7-snowy-fit-jan-apr` | `7e6f30c` | `paleo-RF-verify/7e6f30c/.rundirs/run7-snowy-fit-jan-apr` |
| `run7-snowy-fit-may-jun-sep` | `fce14d1` | `paleo-RF-verify/fce14d1/.rundirs/run7-snowy-fit-may-jun-sep` |
| `run7-snowy-fit-oct-dec` | `58bd502` | `paleo-RF-verify/58bd502/.rundirs/run7-snowy-fit-oct-dec` |
| `run8-raster` | `795792f` | `paleo-RF-verify/795792f/.rundirs/run8-raster` |
| `run8-raster-fit-jan-apr-2` | `b689642` | `paleo-RF-verify/b689642/.rundirs/run8-raster-fit-jan-apr-2` |
| `run8-raster-fit-may-aug-2` | `280a9a0` | `paleo-RF-verify/280a9a0/.rundirs/run8-raster-fit-may-aug-2` |
| `run8-raster-fit-sep-dec-2` | `bd174cf` | `paleo-RF-verify/bd174cf/.rundirs/run8-raster-fit-sep-dec-2` |

## Cross-validation: the chosen model and model 8 through the pipeline (5 November)
- The score stage (`cv-run1-score`, PASS) chose `mod8_coarse_loc` (model 8 with location k = 30): RMSE 0.084 on the
  withheld cells against model 8's 0.100 (difference 0.0029 in squared error, standard error 0.0014). The in-range
  check (`cv-run1-score-2`, PASS; reported only) gives model 8 0.046 and the chosen model 0.051.
- As the protocol's section 7 sets out, both are fitted on all the data and run through scripts 1-10 in separate run
  folders, on the same code (the tip of refit-runs), seed 1549466984, run 1's settings otherwise: `cv-chosen` (model_id
  `mod8_coarse_loc`) and `cv-mod8` (model_id `mod8`). Fitting in four month parts each, as run 1.
- cv-chosen-fit-jan-mar: a documentation-only commit so that it gets its own worktree.
- cv-chosen-fit-apr-jun: a documentation-only commit so that it gets its own worktree.
- cv-chosen-fit-jul-sep: a documentation-only commit so that it gets its own worktree.
- cv-chosen-fit-oct-dec: a documentation-only commit so that it gets its own worktree.
- cv-chosen: a documentation-only commit so that it gets its own worktree.
