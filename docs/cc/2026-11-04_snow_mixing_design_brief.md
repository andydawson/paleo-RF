# Design for Astra (ultra effort): mixing snowy and snow-free albedo with an independent snow-cover product

Read-only: change nothing, download nothing, never open `data/modis_albedo/requests/` in the main checkout
(`/home/expert/Documents/contracting/Andria/paleo-RF`). Read-only shell commands allowed. Web search allowed; ground
every step in published practice and cite it with DOIs; say plainly where a step is our own adaptation. Plain words; no
time estimates. Keep it simple (project rule: no bloat; one-off data building in a stand-alone tool script).

## Why now
The refit runs show the forcing depends heavily on how winter and snow are sampled. Study-area forcing (HadGEM3,
W/m2, partial ice) for run 1 (full inversions, all days) / run 2 (snow-free days) / run 3 (any quality, all days):
0.05-0.5 ka -0.556 / -0.312 / -0.635; 2-4 ka +0.346 / -0.023 / +0.706; 4-6 ka -0.448 / +0.233 / -0.668; 8-10 ka +4.964 /
+7.038 / +4.596. In the northeast over the hemlock decline (6 to 4.5 ka), run 3 brightens strongly in winter (January
+0.142) where run 1 barely does, yet all runs darken in spring. The runs log
(`docs/cc/2026-11-01_refit_runs_log.md`, this checkout) has the tables. At 500 m, January full-inversion retrievals are
rare in the northeast (under three days a year per pixel). Runs 5-7 (winter, winter snow-free, snowy) are still running.

## What exists
- The rebuilt MODIS albedo (`tools/prepare_bluesky_albedo.R`: per pixel and month, day counts and albedo sums for all,
  snowy and snow-free days, four quality/zenith versions; `data/albedo_modis_cells.csv` per 1-degree cell, with
  coverage and snow shares).
- Earlier decisions and questions on snow: `docs/cc/2026-10-29_refit_plan_decisions.md`, the reference-audit summary
  `docs/cc/2026-10-29_refit_references_audit_summary.md` (lines 16-24: the MOD10CM decision), the questions files
  (`docs/cc/questions_for_andria_scientific_from_2026-10-20.md` on branch chris-dev; read it with
  `git show origin/chris-dev:docs/cc/questions_for_andria_scientific_from_2026-10-20.md`: sections 2 and 3), and the
  refit plan and brief (`docs/cc/2026-10-29_refit_plan*`).
- Published precedent noted so far: Barnes and Roy 2010 (equation 3), Ghimire et al. 2014 (section 2.3), Lejeune et
  al. 2020, which mix snowy and snow-free albedo by an independent monthly snow-cover fraction.

## What to design
1. **What the mixed albedo should represent** for this paper (vegetation effect under today's snow climatology, the
   project's open question), and why mixing by an independent snow cover is better than the all-days albedo (which
   weights snow by retrieval success, not by how often snow is there).
2. **The snow-cover product**: MOD10CM (monthly 0.05-degree climate-modelling grid) or alternatives (MOD10C1 daily,
   MOD10A1/A2 at 500 m, others), their definitions (snow-covered area versus snow under canopy), years to match
   2000-2009, resolution, how to obtain them, sizes. The canopy problem: MODIS snow products under forest.
3. **The calculation**: per 1-degree cell and month, albedo = f x snowy + (1 - f) x snow-free; what to do where one
   panel is missing (no snowy retrievals in a snowy month, the winter gap), which quality version for each panel, and how
   it enters script 2 as a new `analysis$albedo$statistic` value (one new option, the legacy and current settings
   untouched).
4. **How it would be checked** (hand-worked cases; comparison with the all-days and snow-free tables) and what it would
   cost in runs (a ninth refit run).
5. **Recommendation**: whether to do it, what it would add to the paper, and what Chris and Andria must decide.
Output a markdown design: summary of at most ten lines; sections 1-5; references with DOIs.
