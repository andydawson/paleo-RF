# Brief for Astra (ultra effort): review the Duveiller comparison as built

*Chris McWilliams, 17 November 2026. Read-only.*

## Rules
- Change no file; do not commit; download nothing. You are in the worktree of branch `duveiller-comparison` (at
  fa9e465). R may not start in your sandbox; Python is available. The builder's tests and trial are in
  `/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/duveiller_trial/`
  (`tests.log`, `cover_contrasts_duveiller.csv`, `.pdf` and `.png`, `record_duveiller.txt`, `duveiller.log`,
  `check_duveiller.log`), and its four deliberately broken copies of the tool with their test results in
  `.../scratchpad/mutants/summary.txt`. The inputs: the saved run
  `/home/expert/Documents/contracting/Andria/paleo-RF-verify/7c12534/.rundirs/cover-contrasts-full/` and the data set
  `/home/expert/Documents/contracting/Andria/paleo-RF/data/duveiller2018/albedo_IGBPdet.nc`. Check numbers your own way.
- Plain words, verdict first, findings worst first with file and line, consequence, evidence and a proposed check.
  Simplicity is a requirement: say what can be cut. The repository is public. Never open `data/modis_albedo/requests/`.

## What was to be built
Your design (`docs/cc/2026-11-16_duveiller_comparison_design_codex_gpt6astra.md`) with Chris's decisions
(`docs/cc/2026-11-17_duveiller_comparison_decisions.md`): all three exchanges; no uncertainty summary (the published
cell uncertainties are left out, recorded as an open question). An Opus agent built it: commits ccc3edc (shared
plotting helpers, the report's pages pixel-identical and its tables byte-identical after), 9c815d1 (the command and
tests), 452e8c2 (the real-data check), 298243b (spec, commit TO_FILL), fa9e465 (README and note section 11).

## What to check
1. Does it do what the design and decisions say, and nothing else? Is the refactor of ccc3edc safe and worth it?
2. Reading the file: transitions and months by coordinate, the sign of transition 23, NaN against zero, scaling by
   0.10, the grid match. Matching and weights: the same cells and renormalised area weights for both means; the two
   coverage shares.
3. The builder chose to report the share of the region's calibration area as 0% where no cell is eligible (Alaska and
   Yukon in December, polar night), where your shortcut formula gives 0/0. Which is right?
4. The page and table wording: is anything readable as validation, or hiding sparse coverage?
5. Tests, the real-data check and the spec: sufficient for the verification run?
6. Anything else wrong, most important first.

End with your verdict (ready to verify, ready after named changes, or not ready) and the changes in order, each small
enough for Chris to say yes or no to.
