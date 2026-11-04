# Whole-code review of paleo-RF (Astra, ultra effort), 4 November 2026

Read-only: change nothing; run no R or pipeline script. Read-only shell commands are allowed and expected: git log /
diff / show, rg, grep, cat, sed -n, ls, wc. Review the clean worktree at the tip of `feature/single-config` (this
directory, commit 55d8f5b). Plain words; no private ids or shorthand.

Since the last reviews (1 November, listed below) the branch gained: the cross-validation (`R/cross_validation.R`,
`tools/cross_validate_albedo.R`, four candidates in `R/model_registry.R`, two test files; changelog section
"Cross-validation that chooses the albedo model"), the archive of 18 old scripts in `archive/`, the path-catalogue and
script 2 cleanups, the refit and benchmark documents, and Astra's version-control review
(`docs/cc/2026-11-03_version_control_review_codex_gpt6astra.md`). Read the changelog's last sections for detail.

Previous whole-code reviews: 14 October readability (`docs/cc/2026-10-14_readability_review_codex_gpt6astra.md`);
15 October simplicity (`docs/cc/2026-10-15_simplicity_review_codex_gpt6astra.md`); 1 November drift and conciseness
(`docs/cc/2026-11-01_drift_conciseness_review_codex_gpt6astra.md`); 1 November simplicity and conciseness
(`docs/cc/2026-11-01_simplicity_review_codex_gpt6astra.md`). Say which of their findings are still open.

Chris's standard: the code must be "as simple and concise as possible. No bloat and no overcomplicating", readable by
people, laid out and reused well, and kept under version control by best practice. Andria (a scientist) must be able to
read, run and change it herself after hand-over. Keep Andria's original analysis code (what `configs/legacy_config.R`
reproduces byte for byte) apart: report drift or faults there, but do not propose restyling it.

## Checklist (the reviewer covers every item)
1. **Simple and concise.** Shortest plain code for each job. Bloat: comments that restate code
   or retell history, repeated explanations, defensive checks guarding nothing real, options
   nobody sets, wrappers with one caller, functions that could be three plain lines, tests that
   test the same thing twice. Overcomplication: any mechanism whose cost to a reader exceeds what
   it buys the paper or Andria; say keep, simplify (how), move out of Andria's way at hand-over,
   or remove. Count lines (code and comment) per file now against `legacy` and the last review.
2. **Human readability.** Can a scientist who knows R follow each script top to bottom and step
   through it? Names that say what a thing is; flat scripts; short functions with a stated
   purpose; comments that say why; plain words, no private ids or shorthand; how many concepts a
   newcomer must learn before running script 1 or changing a setting.
3. **Code reuse and layout.** No duplicated routine, constant, path or check (one function in
   `R/` when two places need it); the right home for each file: `scripts/` the pipeline, `R/`
   shared functions, `tools/` one-off preparation and checks (stand-alone, writing documented
   inputs the pipeline only reads), `tools/plotting/` diagnostics, `tests/` one test file per
   unit; dead code and leftovers of removed features.
4. **Version control.** Against `CONTRIBUTING.md`: one atomic change per commit with a
   why-focused message; topic branches off the trunk, merged when done and pushed; no stray or
   stale branches and worktrees; nothing committed to `legacy` or `main`; large or generated
   files committed only with a reason; the history explains every decision a reader would ask
   about.
5. **Drift.** Code that no longer matches its comments, headers, README, configuration notes or
   the records; stale references; comments that call something Chris's decision when the records
   do not say so.

Keep Andria's original analysis code (what `configs/legacy_config.R` reproduces byte for byte)
apart: report drift or faults there, but do not propose restyling it.

## Output the reviewer must give
A verdict of at most 200 words with line counts; then findings ranked by consequence, each with
file and line, what is wrong, the consequence, the proposed change, lines saved, size (small /
medium / large), risk to the anchored outputs and how to check nothing changed, marked "do now",
"at hand-over" or "leave"; the five changes to make first; and what is already as simple as it
should be.

Give special attention to the cross-validation code (new, about 900 lines with tests): is it as simple as it can be for what it must do, and can Andria follow it?
