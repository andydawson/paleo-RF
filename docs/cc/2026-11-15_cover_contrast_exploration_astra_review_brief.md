# Brief for Astra (ultra effort): review Fable's cover-contrast exploration

*Chris, 10 November 2026: "Fable builds, Astra reviews." Read-only.*

## Rules
- Change no file; do not commit. You are in the worktree of branch `cover-contrasts` (off `cv-v2` at 88f0599).
- R may not start in your sandbox (it could not make its temporary directory on your earlier reviews). The
  builder ran the tests: `docs/cc/2026-11-15_cover_contrast_exploration_trial/tests.log`. The trial on real data
  (tables, records, logs, and the scripts of three checks with their logs) is in
  `docs/cc/2026-11-15_cover_contrast_exploration_trial/`. The same, plus the figure as four pictures
  (`final_page-1.png` to `final_page-4.png`), is in
  `/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/contrast_trial/`
  (use its `output/`; the folders `output_before_the_tool_was_committed` and `output_at_commit_3c58aa4` are
  superseded). Check numbers your own way from the saved products where you can, as you did in Python for the
  design. The finished runs the tool reads are under `/home/expert/Documents/contracting/Andria/paleo-RF-verify/`:
  `1d31cfc/.rundirs/cv2-holdouts` (all days), `8e3f3a4/.rundirs/run2-snowfree-2`, `74b5482/.rundirs/run7-snowy`.
- Never open `data/modis_albedo/requests/`.
- Plain words, no private ids. Verdict first. Findings worst first, each with file and line, consequence, evidence
  and a proposed check.
- **Simplicity is a requirement** (Chris): as simple, clear, readable and parsimonious as possible; readability
  before elegance; no overengineering; no duplicated code. Say what can be cut, with line counts.
- Where the tool makes a choice of method, say whether there is published precedent from this field (albedo and
  land cover, vegetation albedo forcing, palaeo-vegetation), with DOI and passage, or that it is a project choice.
  Chris, 10 November: "the closer to a published precedent the better".
- The repository is public.

## What was to be built
The design is `docs/cc/2026-11-10_cover_contrast_test_design_fable.md` (its second version, written after your
check of the first, `docs/cc/2026-11-10_cover_contrast_test_design_check_codex_gpt6astra.md`), with Chris's
decisions quoted in it:
- an exploration only: no pass or fail statement anywhere, and no effect on the choice of model;
- six versions of the model; three 10-point exchanges of cover, centred on each cell's own mix; the cells that
  count fixed before any fit; the area-weighted mean with its conditional standard error, and the cell count and
  area share always shown;
- the study area and the six regional boxes of `R/regions.R` (Chris, 10 November: the northeast and the hemlock
  decline are one test case among others, so results are reported by region generally);
- twelve months; three albedo tables (all days, snow-free, snowy), every fit made afresh;
- the published values in a panel of their own, and beside the model only multiplied by 0.10 as a guide;
- "the closer to a published precedent the better": the reading of the precedents is
  `docs/cc/2026-11-10_precedent_methods_report.md`. Its five undecided choices (section 3.4) were to stay
  undecided, with the design's choice kept in each case.

Fable's own account: `docs/cc/2026-11-15_cover_contrast_exploration_implementation.md`. Commits `fe82a98` to
`f8b249d` (`git diff 88f0599 f8b249d`): `R/cv_separation.R`, `tools/check_cv_separation.R`,
`tools/explore_cover_contrasts.R`, `tests/test_cv_separation.R`, `tests/test_explore_cover_contrasts.R`, five new
columns in `docs/cc/2026-11-10_published_albedo_contrasts.csv`, the spec
`docs/cc/verification/2026-11-15_cover-contrasts.R` (not yet run), and the trial folder. The exploration itself
(36 jobs, 212 fits) has not been run.

## What to check
1. **Does it do what the design and Chris's decisions say?** List anything missing, added without being asked, or
   done differently, including the fourteen choices the note lists (its section 5) and the committed trial folder.
2. **Arithmetic, units and signs.** The direction of each exchange and of "A to B", against the published
   table's `difference_a_minus_b` and its new `contrast` column: is every published value that is drawn in the
   right panel with the right sign? The two endpoints and what is held; the area weights; the rule for which
   cells count and the range it uses; the standard error (what it conditions on, which covariances it keeps); the
   spread; the area share and its denominator; the two snow-share columns; the count for the 10 % condition; the
   months of a period that crosses the year end; the guide's factor of 0.10 and which published values stand
   beside which albedo table.
3. **The changed helpers** (`fixed_exchange()`, `freeze_exchange()`, `held_class()`, `cell_areas()`,
   `area_of()`): is behaviour unchanged for protocol 2's callers (the separation tool and its tests)? The builder
   says the four frozen northeast exchanges of the 1d31cfc run are reproduced bit for bit: is that check right
   and sufficient?
4. **The published table's five new columns**, row by row for the 56 rows that are drawn: contrast, months, snow
   state and band, each against the row's own text and, where you can, its source. Is any row drawn that should
   not be, or left out that should be drawn?
5. **The inputs.** Does the fit command read what the note's section 4 says? Is its guard right (the
   repository's cell table must reproduce the run's calibration table exactly)? Is there anything in the three
   runs that makes their tables not comparable?
6. **What could mislead Chris or Andria** in the table's explanation, its columns, the figure and its captions:
   for example the guide read as a target; the all-days winter values; a few cells standing for a region; the
   same grey ticks in every region's panel; a separate vertical scale in every panel; months of the snowy table
   with almost no snowy retrievals; anything that reads as validation.
7. **Simplicity.** 361 lines of tool, 30 added to the helpers, 194 of tests, and a committed trial folder of
   about 1,700 lines of tables and logs. What can go without losing a required output? Is there duplicated logic
   with the cross-validation tools, or with the hindcast comparison tool on branch `cv-compare-tool`, that should
   be shared instead?
8. **Tests and the spec.** Are the tests enough for what must hold? Does the spec check the right things, and
   what should the verification run establish that it does not? Two tests were left out of the spec
   (`tests/test_config.R`, and `tests/test_paths.R`, which fails in this worktree and in `cv-v2`'s for want of a
   baseline output file): is that acceptable?
9. **The plan for the full run** (36 jobs; 212 fits; the versions with a location term of 500 not yet timed on a
   full table): what should change before it is launched: inputs, what is saved, anything that would make its
   results impossible to interpret afterwards?
10. **Anything else that is wrong**, most important first.

End with: your verdict (ready to verify, ready after named changes, or not ready); the changes you recommend
before the verification run and before the full run, in order, each small enough for Chris to say yes or no to;
your view, briefly and with precedent, on each of the eight questions the note puts to Chris (its section 9); and
any further question for Chris, written so that he can answer it without reading anything else.
