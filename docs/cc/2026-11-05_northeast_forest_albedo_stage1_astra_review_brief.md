# Brief for Astra (ultra effort, read-only): review Fable's review of stage 1, and the code again

*Chris, 5 November 2026: Astra writes, Fable reviews, then Astra reviews. Issue #27.*

Read-only: change nothing. Read-only shell commands are allowed (git log/diff/show, rg, grep, cat, sed -n, ls, wc,
sha256sum), and `tools/rscript.sh` may be used only to parse files or run the four test files. Never open
`data/modis_albedo/requests/`. No network. Plain words, no time estimates.

You wrote commit cc65015 (stage 1, branch `northeast-forest-check`, this worktree). Fable reviewed it
independently: `docs/cc/2026-11-05_northeast_forest_albedo_stage1_review_fable.md`. Requirements: your brief
`docs/cc/2026-11-05_northeast_forest_albedo_build_brief.md`, the frozen settings
`docs/cc/2026-11-03_northeast_forest_albedo_settings.md` and the design v2.

1. For each Fable finding (1-6, each sub-item of 6) and each proposed verification check (1-8): agree, agree with a
   change, or disagree, with evidence (file and line, or a command you ran). Settle what Fable could not check:
   the `cb2920f6…` hash against `git show 1e37c26:tools/prepare_bluesky_albedo.R`; whether `terraOptions` accepts
   `parallel`; whether `northeast_check_grids` would stop on the HDF CRS (+a/+b against +R); that the four tests pass.
2. Fable's five questions for Chris: give your recommendation on each, in one or two plain sentences, and say
   whether it can change any result.
3. Review the code once more yourself for anything both of you missed, especially anything that could give a
   wrong pair table or wrong coverage numbers. Chris's rule: as simple, clear and parsimonious as possible.
4. End with: the list of changes you recommend before the coverage run (each with lines saved or added), and the
   final verification checks.
