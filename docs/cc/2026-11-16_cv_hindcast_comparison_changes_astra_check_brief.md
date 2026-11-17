# Brief for Astra (ultra effort): check the six approved changes to the hindcast comparison tool

*Chris McWilliams, 16 November 2026. Read-only. Chris's arrangement from today: Astra designs and reviews, an Opus
agent implements, then the verification tool.*

## Rules
- Change no file; do not commit. You are in the worktree of branch `cv-compare-tool`, now at ab3d77c.
- R may not start in your sandbox. The implementing agent's tests and its rerun of the trial on the three finished
  runs are in
  `/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/compare_trial_2/`
  (`commands.sh`, `tests.log`, `main.log`, `reversed.log`, `comparison/`, `comparison_reversed/`,
  `compare_with_first_trial.R` and `.log`, `table_checks.log`). The first trial is in `../compare_trial/final/`
  beside it. Check numbers your own way from the saved files where you can (Python is available).
- Plain words, no private ids. Verdict first. Findings worst first, each with file and line, consequence, evidence
  and a proposed check. Simplicity is a requirement: say what can be cut.
- The repository is public. Never open `data/modis_albedo/requests/`.

## What was approved
Your review of 10 November, `docs/cc/2026-11-10_cv_hindcast_comparison_review_codex_gpt6astra.md`, recommended
six changes before verification. Chris: "Yes, all six", keeping the two outputs added beyond the protocol (the
study-area forcing over the hemlock interval, and the northeast exchange of historical size for all twelve months).
Not approved: removing the console tables or the arithmetic preamble, renaming the two albedo quantities, any other
tidy-up.

An Opus agent made the changes: commits 43d670e to ab3d77c (`git diff 27ce45d ab3d77c`). Its account, in short:
directions named in words (`direction_in_words()`) with the northeast's reach beside the tested limit
(`reach_by_direction()`; "every northeast mix outside the range leaves it in direction d2, as far as 0.107, while
nearby testing in d2 reached only 0.099"); `check_common_availability()` with the two-cell test; four swap endpoint
distance columns; both northeast endpoints checked against `predict()` and two verification claims narrowed; the
0.005 limit replaced by the largest fitted-minus-simulated gap (0.0012) and the count of sign disagreements (0 of
36); the kernel coverage line ("cack ... 2646 cells in jan and 2439 cells in dec; every other kernel and month has
2655"), and the subtitle wrapped at 90 characters; the spec brought in line, its commit still `TO_FILL` (to be
ab3d77c). It reports that every column that existed before is value-for-value identical to the first trial's in
all ten tables. It reported two things it did not fix: in the one-column reversed forcing map the title is cut by
one letter ("minus loc100_linea"); and the main checkout's `tools/verify_change.R` (branch `i16b-calibration`)
writes every check into one `checks.log`, overwriting it, while this branch's copy keeps one log per check.

## What to check
1. Was each of the six changes made as you intended, and was anything else changed?
2. Are the existing outputs really identical? Check the agent's comparison independently from the saved tables.
3. Are the new columns, header lines and the reach statement right? Recompute the northeast reach (0.107 against
   0.099) and the kernel cell counts from the inputs if you can.
4. Is the spec right and sufficient now? Which copy of the verification tool should run it, and does the
   difference in check logs matter for the evidence the report keeps?
5. The cut-off title: should it be wrapped like the subtitle (a one-line change), or left?
6. Anything else that is wrong, most important first.

End with your verdict (ready to verify, ready after named changes, or not ready) and the changes, in order, each
small enough for Chris to say yes or no to.
