# Review task: the refit code on branch refit-modis (paleo-RF, 29 October 2026)

Independent, adversarial review of a code change before any run. Read-only: change nothing, run no
pipeline scripts. You may run the branch's test files if your tools allow.

**The change.** Branch refit-modis, worktree /tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-refit-modis, commits 0c65aa7..1a041d1 (9 commits;
`git log 0c65aa7..1a041d1` and `git diff 0c65aa7..1a041d1` there; data/albedo_modis_cells.csv is a
7.8 MB committed data file, check it by its tests, not by reading it). It lets the calibration use the
rebuilt land-only MODIS albedo cell table instead of Andria's raster, as a configuration choice.

**Requirements (what Chris decided; review against these, do not reopen them):**
/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-refit-modis/docs/cc/2026-10-29_refit_plan_decisions.md, items 1-9. Background: the plan
(docs/cc/2026-10-29_refit_plan_codex_gpt6astra.md), its review (docs/cc/2026-10-29_refit_plan_review_fable.md),
the implementation brief /tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/refit_build/brief.md, and the implementer's report /tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/refit_build/build_report.md
(it lists six decisions it took itself and five open questions: assess each).
Project rules: AGENTS.md, CONTRIBUTING.md (readability before elegance, no duplicated code, the
regression contract docs/cc/2026-10-08_single_config_regression_contract.md, tests/anchors/).

**Check in particular:**
- Legacy path: does configs/legacy_config.R still produce byte-identical scripts 1-2 tables and the
  same scripts 4-10 behaviour? (Script 2's raster branch was restructured into if blocks, the grid
  read moved, three plots wrapped in print().) Any silent change to a legacy product?
- The reader cell_albedo_by_month() in R/preparation.R: joins, row order, NA handling, column
  selection per statistic/version, validation, units; the tests' hand-worked expectations.
- Script 2's MODIS branch: ice mask, zero floor, written table columns (script 3 melts every
  non-identifier column), run record, maps; the 48 ice cells, the 4 unmatched calibration cells and
  the 10 cells at 17.5 N.
- Script 5's denominator change: correct for both sources? In_credible NA handling? Which anchors
  change (the implementer says two: the seeded seed-1 anchor and the unseeded all-months anchor's
  tolerance) and what the right treatment is.
- Model 7: the control argument, the tool tools/check_model7_convergence.R (does it compare like with
  like: same data, same method, same rows?), fit_convergence()'s new row count.
- The build-script comment change and ACCEPTED_OLDER_SHAS entry: is it safe (comments only)?
- Config schema: the legacy rule; defaults; anything that makes a manifest check or a verification
  spec fail.
- Test changes: the implementer loosened two real-table checks (tolerance 2.5e-6 for 6-decimal
  rounding; replaced "equal days implies equal albedo" by a check on months and cells the 75-degree
  rule cannot touch). Are these sound?
- Anything missing for the planned runs (all-days, snow-free, snowy, any-quality, November-February
  no-rule, raster control).

**Report:** findings ranked by severity (blocker / should-fix / nit), each with file and line,
consequence, evidence and a proposed check or fix; then your view on each of the implementer's six
decisions and five open questions; then any question that belongs to Chris or to Andria. Plain words.
