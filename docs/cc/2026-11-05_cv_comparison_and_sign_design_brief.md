# Brief for Astra (ultra effort, read-only): design the cross-validation comparison, the northeast sign table and
# the literature comparison

Read-only: change nothing. Read-only shell commands are allowed (git log/diff/show, rg, grep, cat, sed -n, ls, wc).
Never open `data/modis_albedo/requests/`. Web search allowed; cite with DOIs. Plain words, no time estimates.

**Simplicity (Chris's rule, again):** the smallest design that does the job; as simple, clear, readable and
parsimonious as possible; no overengineering. Andria (a scientist who knows R) must be able to read it. Reuse what
exists; say for each step whether it adds or removes code. Anything for a case that has not happened and cannot
change a result goes under "not worth doing".

## Background
- CV protocol section 7 (`docs/cc/2026-11-02_cv_protocol.md:75-83`, this worktree at `feature/single-config`): the
  chosen model (`mod8_coarse_loc`) and model 8 are fitted on all data and run through the pipeline in separate run
  folders, then compared: albedo and forcing maps and series, the northeast (80-66 W, 40-48 N) from 6 to 4.5 ka every
  month, and the share of each result resting on tested versus untested cover mixes. Not built yet. The two refits
  are running now (verification specs `2026-11-05_cv-chosen-fit-*` and `2026-11-05_cv-mod8-fit-*`, then pipeline
  specs `2026-11-05_cv-chosen` and `2026-11-05_cv-mod8`, in
  `/home/expert/Documents/contracting/Andria/paleo-RF/docs/cc/verification/`; run folders will be under
  `/home/expert/Documents/contracting/Andria/paleo-RF-verify/<commit>/.rundirs/<name>/`). Earlier runs there (run 1,
  `d5d5df5/.rundirs/run1-main`) show the output layout.
- The northeast pair check (issue #27) was dropped (`git show northeast-forest-check:docs/cc/2026-11-05_northeast_forest_albedo_dropped.md`).
  Chris chose instead (5 November): for the model's sign, **a 12-month by 2-model table plus the April and May
  figure, built inside the section 7 comparison**, and for which forest is brighter, **the published comparisons**.
- Your assessment and Fable's review of it, which this design must follow:
  `git show northeast-forest-check:docs/cc/2026-11-05_northeast_simpler_routes_codex_gpt6astra.md` and
  `git show northeast-forest-check:docs/cc/2026-11-05_northeast_simpler_routes_review_fable.md`. Fable's points:
  the supported reading at today's open land, not 6 ka's; each month's own training hull, not May's
  (`R/training_support.R:59-69`; Chris has not chosen yet, so recommend); table columns (6 to 4.5 ka change; swap at
  today's open land inside today's evergreen range; share of cells outside the month's hull; predicted 4.5 ka albedo
  against the region's modern minimum and maximum); the extension's checks (link-scale invariance, same sign
  everywhere, zero swap gives zero, caption says the points are the actual mixes, the modern-range bound).
- Existing code to reuse: `tools/plotting/plot_northeast_cover_and_location.R` (and its 5 November log under
  `paleo-RF-verify/c86e4b5/.rundirs/northeast-figure-run1/`), `R/training_support.R`, `R/regions.R`,
  `tools/plotting/plot_forcing_vs_training_support.R`, `R/model_registry.R`, scripts 6-10.

## What to design
1. **The section 7 comparison**, as small as possible: what is compared, read from which existing outputs of the
   two run folders, in what form (a few tables and figures), and where the code lives (one tool, or extending an
   existing one). The "tested versus untested mixes" share: define it simply, with each month's own support.
2. **The northeast sign table and the April-May figure** inside it, with Fable's corrections. The exact definition
   of each column, which fits it reads, and the hand-worked checks.
3. **The literature comparison**: one short paragraph and at most one small table for the paper, which forest is
   brighter by season and snow, from Jin 2002, Hollinger 2010, Zhao and Jackson 2014, Burakowski 2016 or better
   sources; with the exact pages and numbers, marked where you could not read the passage. The project's reference
   checkers (RefChecker, refaudit) must run before any number enters the paper: say which claims they must check.
4. **Reviews and verification** in proportion (AGENTS.md: arithmetic and scientific options get Fable and Astra
   reviews; `tools/verify_change.R`).
5. **What Chris and Andria must decide.**

Output: a markdown design with a summary of at most ten lines; sections 1-5; "not worth doing"; references with DOIs.
