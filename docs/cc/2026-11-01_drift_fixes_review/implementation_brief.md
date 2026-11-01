# Implementation brief: fixes from the drift and conciseness review (1 November 2026)

Work ONLY in the worktree /tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-drift (branch drift-fixes, from feature/single-config at 837f2d3). Never
touch the main checkout except to read data files, never switch branches, never push or merge, never edit
any worktree under paleo-RF-verify/ (refit runs are reading them). Commit each finding's fix atomically with
a why-focused message (imperative subject; body: what and why, citing the finding number) ending with:
Claude-Session: https://claude.ai/code/session_01UxGrk8eCToaRo9WLgzHPsd
No pipeline runs (scripts 1-10) and no verification runs; run the test files and small checks.
R: /home/expert/micromamba/envs/paleo-rf/bin/Rscript, PROJ_LIB=PROJ_DATA=/home/expert/micromamba/envs/paleo-rf/share/proj,
OPENBLAS_NUM_THREADS=1.

Read first: AGENTS.md, CONTRIBUTING.md (readability before elegance; no duplicated code; small functions in
R/ when shared; comments say why; never remove a library() without a run), and the review:
docs/cc/2026-11-01_drift_conciseness_review_codex_gpt6astra.md.

Fix these findings (and only these), each as small and plain as possible:
- Verification tools: 1 (run$dir resolving onto the baseline), 2 (compare_tables: no "within tolerance"
  verdict when no numbers were checked; unchecked columns reported as unchecked), 3 (verify_change: refuse a
  spec with no scripts, no checks and no anchors), 4 (seeded markers: record only files actually copied, and
  clear the marker when a script regenerates the file). Keep every existing test passing; add a test for each.
- Diagnostics: 5 (training-support figures: say plainly in titles/captions that the support is May's; stop
  with a clear message if May is not among the analysis months; do NOT add monthly support), 6 (northeast
  figure: require the comparison it is built for (prediction model 8 against cover_elev) or stop; compute the
  directions and the sign statements from the results instead of hard-coding them), 7 (R/forcing_periods.R:
  pass the configured slice sequence instead of appending 11500; refuse unmatched support lookups instead of
  dropping NAs; default endpoints must stay identical), 10 (pollen coverage: count absent region-slice
  combinations as zero before the median), 15 (one small shared helper in R/ for the preparation the three
  diagnostic tools copy: reading the May fit, its hull, the merged prediction table and May's cover rows; each
  figure keeps its own filtering and plotting).
- Labels and documentation: 8 (scripts 9 and 10: name the actual months instead of "annual" when fewer than
  12 run, and replace the inferred kernel statements with ones computed or plainly stated from the settings;
  table values and their bytes must not change; if any anchored product's bytes would change, stop and
  report), 20 (README.md, AGENTS.md pointer, tools/prepare_bluesky_albedo.R header line 14, config.R:15,
  R/preparation.R:7: bring them up to date with the MODIS refit; mark scripts/6_prediction_model_spatial_eval.R
  as not migrated), 21 (script 1's printed claim: remove the unsupported cutoff claim and the gradient
  assertion), 23 (script 9: replace the dated debugging narrative and the repeated manifest tutorial with brief
  pointers; keep scientific definitions, units, references).
Note on tools/prepare_bluesky_albedo.R: any edit changes its SHA-256; handle ACCEPTED_OLDER_SHAS exactly as
done before (comments-only, checked with code_of() from tools/check_comments_only.R).
Do not touch findings 11-14, 16-19, 22 or 24.

Report (final message): commits (subject lines), per finding what changed with file and line, tests run and
results, which anchored outputs could be affected and which verification runs are needed to show they are not
(name the existing specs under /home/expert/Documents/contracting/Andria/paleo-RF/docs/cc/verification/ to
model them on), and anything you could not do or decided yourself.
