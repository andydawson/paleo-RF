# Brief for Astra (ultra effort): check the approved changes to the cover-contrast tool

*Chris McWilliams, 16 November 2026. Read-only. Chris's arrangement from today: Astra designs and reviews, an Opus
agent implements, then the verification tool. Chris has approved the timing job and the full run to follow,
once the changes are checked and verified.*

## Rules
- Change no file; do not commit. You are in the worktree of branch `cover-contrasts`, now at 7c12534.
- R may not start in your sandbox. The implementing agent's tests, repeated trial, saved fits, logs and figure
  pages are in
  `/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/contrast_trial_2/`
  (pictures: `output/page-1.png` to `page-4.png`, and `output/zoom_snowy_northeast_open-3.png`, which shows the
  Southwest panel, summergreen to open land, snowy). The committed trial folder is
  `docs/cc/2026-11-15_cover_contrast_exploration_trial/`. Check numbers your own way from the saved files where
  you can (Python is available).
- Plain words, no private ids. Verdict first. Findings worst first, each with file and line, consequence, evidence
  and a proposed check. Simplicity is a requirement: say what can be cut.
- The repository is public. Never open `data/modis_albedo/requests/`.

## What was approved
Your review of 15 November, `docs/cc/2026-11-15_cover_contrast_exploration_review_codex_gpt6astra.md`. Chris
approved all four groups of its changes: the published references (its findings 1 and 5, and Jin's values), the
figure and wording (findings 3 and 6), saving the fitted models (finding 4), and the stronger verification
(finding 2 and its notes on tests). Not approved: any of the five choices the precedent report left open, a
co-occurrence filter, a recombined all-conditions number, Duveiller's data set, a local regression, placing
Euskirchen's snow periods on the month axis, removing files from the committed trial folder, any other tidy-up.

An Opus agent made the changes: commits b8dbc8f, aba9a0f, 50947ab, b0d1db7 and 7c12534 (`git diff 73fd063
7c12534`). Its account, in short:
- the two mosaic values kept off every guide beside the model (`beside_model = no`) and labelled on the published
  page; the four Burakowski 2015 values marked as single days; Lutz's three drawn once each as annual means from
  separate sites; Burakowski 2016's placement labelled; Jin's two values entered and marked as read by you only;
  two columns, `qualification` and `beside_model`, added to every line of the published table;
- under every panel, by month: eligible cells, area share (%), and the retrieval share (%), snowy on the snowy and
  all-days pages, snow-free on the snow-free page; the caption's qualifications; the 10 % count reworded;
- each fit saved as `fit_<table>_<month>_<version>.rds` and each month's exchanges as `cases_<table>_<month>.rds`;
- a new `tools/check_cover_contrasts.R` (158 lines) with `inputs`, `exchanges` and `job` checks taking their
  inputs as arguments; the spec (commit still `TO_FILL`, to be 7c12534) runs ten test files, the snowy July and
  August job, its report and the three checks;
- the repeated trial gives all 420 rows identical to the first; the snowy July and August job took 5 min 17 s at
  0.76 GB peak memory.
It notes that one commit is not purely atomic, that two earlier trial scripts are now repeated by the new checks
but kept, that `tests/test_paths.R` needed a link to the main checkout's frozen file in this worktree (as the
verification tool makes), and it proposes commands for the timing job and the full run (in its report; reproduced
in the implementation note's section 10 if it wrote them there).

## What to check
1. Was each approved change made as you intended, and was anything else changed?
2. The published table: every line gained two columns; were any existing fields changed? Are `beside_model` and
   `qualification` right row by row for the rows that are drawn? Are Jin's two rows right?
3. The figure: is the support shown as you asked, and readable? Look at the pictures.
4. The saved fits and the `job` check: is the reload check real (does it compare against independently saved
   numbers, not against themselves)?
5. The spec and the new check tool: right and sufficient for the verification run? Can anything be cut?
6. The plan for the timing job and the full run (output folder, what is saved, how completion is checked, how to
   choose the number of jobs at once from the timing job's peak memory): anything to change before launch?
7. Anything else that is wrong, most important first.

End with your verdict (ready to verify, ready after named changes, or not ready) and the changes, in order, each
small enough for Chris to say yes or no to.
