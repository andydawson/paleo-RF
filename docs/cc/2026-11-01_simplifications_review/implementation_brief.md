# Implementation brief: four simplifications (1 November 2026)

Work ONLY in the worktree /tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-simplify (branch simplify-2026-11-01, made from drift-fixes, which is under
review; do not edit what the drift fixes changed unless an item requires it). Never touch the main checkout
except to read data files, never switch branches, never push or merge, never touch anything under
/home/expert/Documents/contracting/Andria/paleo-RF-verify/ (live runs read it). One atomic commit per item with
a why-focused message ending with:
Claude-Session: https://claude.ai/code/session_01UxGrk8eCToaRo9WLgzHPsd
No pipeline or verification runs; run the test files and small checks (R: /home/expert/micromamba/envs/paleo-rf/bin/Rscript,
PROJ_LIB=PROJ_DATA=/home/expert/micromamba/envs/paleo-rf/share/proj, OPENBLAS_NUM_THREADS=1).

Chris's standard (1 November): "as simple and concise as possible. No bloat and no overcomplicating."
Read AGENTS.md, CONTRIBUTING.md and the review docs/cc/2026-11-01_simplicity_review_codex_gpt6astra.md.
Chris chose its items 1, 2, 7 and 8 (see its header). Implement exactly those:
1. Shared plot styling: one small theme function for the map theme repeated in scripts/7_plot_preds.R (nine
   copies; keep the larger text size and the final plot's different axes explicit), and one base plot with the
   facet added per plot for the three repeated plots in scripts/5_calibration_eval.R. Plotted data, filters and
   scientific choices unchanged; numerical products unchanged. If the theme is used by more than one script,
   it goes in R/map_helpers.R; otherwise it stays in the script.
2. Script 1's optional diagnostics (scripts/1_veg_lct_prep.R from about line 35 and 102 on): one named helper
   with explicit inputs, called under the existing diagnostic flag; plotting dependencies stay inside the
   diagnostic route; the two prepared tables unchanged. Keep every library() call (AGENTS.md).
3. (Review item 7) One catalogue expansion: R/paths.R's expansion accepts the required catalogue ids and
   tools/verify_change.R calls it instead of its own copy; remove include_spatial_eval if nothing enables it.
   Expanded file lists must be identical for baseline and redirected runs (test it).
4. (Review item 8) Test setup: schema tests in tests/test_config.R change settings as lists instead of editing
   config text (keep text fixtures only where loading syntax is under test); one shared cell fixture for
   tests/test_differences.R and tests/test_forcing_components.R; in tests/test_bluesky_albedo.R replace the
   copied equation-of-time formula with fixed, independently checked expected values and drop the test of
   literal arithmetic (line ~40). Coverage must not drop: each test must still reject what it rejected.

Report (final message): commits, per item what changed with file and line and lines saved, tests run and
results, which anchored outputs could be affected and which verification runs are needed (name existing specs
under /home/expert/Documents/contracting/Andria/paleo-RF/docs/cc/verification/ to model them on), and any
decision you took yourself.
