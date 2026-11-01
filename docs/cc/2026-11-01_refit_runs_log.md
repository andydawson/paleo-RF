# Refit runs on the MODIS albedo: log (from 1 November 2026)

Decisions: `2026-10-29_refit_plan_decisions.md`; input check shown to Chris on 31 October
(`2026-10-31_refit_input_check.md`). Chris, 31 October-1 November: fixed seed 1549466984 for every run;
the November-February runs reported month by month only, never their four-month "annual" total; main
run first; launch.

Model fitting runs in four month-split parts at once; each part needs its own worktree, so each runs at
its own code-identical commit on branch `refit-runs` (documentation-only commits).

## Commits for the parallel fitting parts
