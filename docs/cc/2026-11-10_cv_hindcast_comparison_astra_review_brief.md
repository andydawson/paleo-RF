# Brief for Astra (ultra effort): review Fable's hindcast comparison tool

*Chris, 10 November 2026: "Now, but fable to build then Astra review." Read-only.*

## Rules
- Change no file; do not commit. You are in the worktree of branch `cv-compare-tool` (off `cv-v2`).
- R may not start in your sandbox (it could not make its temporary directory on your last two reviews). The main
  session ran the tests for you: `/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/compare_review/tests.log`
  (all four pass). The tool's trial run on the three finished pipeline runs, with its logs and outputs, is in
  `/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/compare_trial/final/`
  (`comparison/` is the main run, `comparison_reversed/` the same with two runs swapped; each CSV starts with `#`
  lines saying what it holds). Check numbers your own way from the saved products where you can.
- Never open `data/modis_albedo/requests/`.
- Plain words, no private ids. Verdict first. Findings worst first, each with file and line, consequence, evidence
  and a proposed check.
- **Simplicity is a requirement** (Chris): as simple, clear, readable and parsimonious as possible; readability
  before elegance; no overengineering; no duplicated code. Say what can be cut, with line counts.
- Where the tool makes a choice of method, say whether there is published precedent from this field (albedo and
  land cover, vegetation albedo forcing, palaeo-vegetation), with DOI and passage, or that it is a project choice.

## What was to be built
`tools/compare_cv_hindcasts.R`, as fixed in `docs/cc/2026-11-06_cv_protocol_v2.md` section 7 ("Comparison tables",
"Support and figures") and section 8's verification list, with these choices of Chris:
- a new tool beside the northeast figure tool, reusing its helpers;
- area-weighted regional means, common cells and denominators for every comparison;
- one outside-range flag with its numeric distance and band; a period is outside if any endpoint of any included
  step is outside; area shares and signed contributions add back to the displayed totals;
- the northeast sign table with the modern-range evergreen-to-summergreen swap at 50 BP open land and at 6 ka open
  land side by side;
- the trimmed figure set of section 7, nothing more;
- 10 November: the northeast tables for all twelve months; three finished runs compared, baseline first (model 8
  `paleo-RF-verify/f05628d/.rundirs/cv-mod8`, the chosen model `1d31cfc/.rundirs/cv2-winner`, the coarse-location
  model `e82f399/.rundirs/cv-chosen`);
- added after your check of the review: the vegetation part, the ice part and the total side by side for every
  run and period; and the hindcast's geographic support by month (past cells with no fitting cell at their place,
  and those north of every fitting cell);
- no pass or fail statement anywhere: the comparison with published contrasts is an exploration only.

Fable's own account: `docs/cc/2026-11-10_cv_hindcast_comparison_implementation.md`. Commits `ce6cbb4` to `a54de1b`
(`git diff ff1614e a54de1b`): `R/hindcast_comparison.R`, `tools/compare_cv_hindcasts.R`,
`tests/test_hindcast_comparison.R`, two helpers moved (`cells_with_evergreen()` to `R/training_support.R`,
`slice_area_ice()` out of `cv_target_weights()` in `R/cross_validation.R`), the spec
`docs/cc/verification/2026-11-10_cv-hindcast-comparison.R` (not yet run).

## What to check
1. **Does it do what section 7 and the choices above say?** List anything missing, added without being asked, or
   done differently, including the choices Fable made that the protocol did not (its note lists them).
2. **Arithmetic, units and signs.** Area weights and denominators; common cells; the period sums against the
   endpoint change; the vegetation and ice parts adding to the total; positive albedo change is brighter and
   positive forcing is warming in every header and column; the two swap columns' endpoints and what is held fixed;
   the outside-range flag for periods; the geographic support counts. Fable says the tool stops unless it
   reproduces every number scripts 9 and 10 saved (largest gap 2e-14 W/m²): is that check right and sufficient?
3. **The two moved helpers:** is behaviour unchanged for their existing callers (the cross-validation and the
   northeast figure tool)?
4. **What could mislead Chris or Andria** in the tables, headers and figures: for example simulated-mean albedo
   set beside deterministic contrasts; the "10 - 12 ka" label for a period that ends at 11.5 ka; northeast forcing
   quoted as a mean over months; anything read as validation.
5. **Simplicity.** 539 lines of tool and 149 of helpers: what can go without losing a required output? Is there
   duplicated logic with scripts 8 to 10 or with the cross-validation tools that should be shared instead?
6. **Tests and the spec:** are the tests enough for the invariants in section 8 that apply; does the spec check
   the right things; what should the verification run establish that it does not?
7. **Anything else that is wrong**, most important first.

End with: your verdict (ready to verify, ready after named changes, or not ready); the changes you recommend
before the verification run, in order, each small enough for Chris to say yes or no to; and any question for
Chris, written so that he can answer it without reading anything else.
