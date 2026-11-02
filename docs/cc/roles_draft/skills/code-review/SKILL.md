---
name: code-review
description: Whole-code review of paleo-RF for simplicity and conciseness, human readability, code reuse and layout, version-control practice and drift. Use when Chris asks for a code review, a simplicity, conciseness, drift or bloat review, after a large merge, and before hand-over. Not for reviewing one change (that is the change-reviewer or science-reviewer role).
---

# Whole-code review (paleo-RF)

**Chris's standard (1 November 2026):** the code must be "as simple and concise as possible. No
bloat and no overcomplicating", readable by people, laid out and reused well, and kept under
version control by best practice. Andria (a scientist) must be able to read, run and change it
herself after hand-over.

## Who and how
1. Review a clean worktree at the branch tip (normally `feature/single-config`, or `chris-dev`
   after the migration), never a checkout a run is reading.
2. Astra reviews by default: build the prompt from the checklist below, the branch and commit,
   the previous reviews (list at the end) and the changes since the last one (changelog), and run
   from the worktree: `codex exec -m gpt-6-astra -c 'model_reasoning_effort="max"' --sandbox read-only -o <result> - < <prompt>`.
   Chris may ask for another effort, or for Fable (the science-reviewer role) as a second,
   independent reviewer; then one reconciliation round, as for change reviews.
3. Read-only: the reviewer changes nothing and runs no R or pipeline script. Astra reads files
   through the shell, so its prompt must say that read-only commands (git log/diff/show, rg, grep,
   cat, sed -n, ls, wc) are allowed; otherwise a role's "never run any command" stops it reading.

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

## Afterwards
1. File the result as `docs/cc/<date>_<subject>_codex_gpt6astra.md` (or `_fable.md`) on a topic
   branch, with the prompt's location.
2. Put the findings to Chris through the question interface, grouped, with a recommendation; he
   chooses what to act on. Nothing is changed without his choice.
3. Each fix: one atomic commit on a topic branch, the usual review in proportion to risk
   (AGENTS.md), and the verify-change skill before merge.

## Previous whole-code reviews
- 14 October 2026: readability (`docs/cc/2026-10-14_readability_review_codex_gpt6astra.md`)
- 15 October 2026: simplicity (`docs/cc/2026-10-15_simplicity_review_codex_gpt6astra.md`)
- 1 November 2026: drift and conciseness (`docs/cc/2026-11-01_drift_conciseness_review_codex_gpt6astra.md`)
- 1 November 2026: simplicity and conciseness (`docs/cc/2026-11-01_simplicity_review_codex_gpt6astra.md`)
