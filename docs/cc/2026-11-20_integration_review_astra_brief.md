# Brief for Astra (ultra effort): review of all the single-config migration code before the final gate

*Chris McWilliams, 20 November 2026. Review only, read-only.*

## Access (read this first)
Your working directory is the worktree `/home/expert/Documents/contracting/Andria/paleo-RF-wt/gate-review`, a
detached checkout of `feature/single-config` at commit 9c8dea1, and every file named below is in it. Read files with
read-only shell commands (`cat`, `sed -n`, `grep`, `rg`, `ls`, `wc`, `git log`, `git show`, `git diff`): that is
expected and allowed. Do not run R, the pipeline or anything that writes. Do not search the web: everything you need
is local. Where the role below says you run no command, read it as: no R, no pipeline and nothing that writes;
reading files with shell commands is how you read.

## The task
This is the project's final integration review (GitHub issue #16, "integration gate"): the review of all the
migration code that the project's rules require before the full-run gate and before the migration branch is handed
over. The single-config migration moved every setting of the R pipeline into one file, `config.R` (with
`configs/legacy_config.R` reproducing the original analysis), and over October and November it also added the
scientific options Chris and Andria chose. The code to review is everything that changed between the pre-migration
base and the branch head:

    git diff --stat 1b9d5a9 9c8dea1 -- R scripts tools tests config.R configs     # 123 files, +15,089 / -5,129

Two questions above all:
1. **Legacy equivalence.** Under `configs/legacy_config.R`, does every script still compute what the original code
   computed (branch `legacy`, tag `v0-legacy`, and the base 1b9d5a9), apart from changes the changelog records as
   deliberate? Look for anything the anchors would not catch.
2. **The final configuration.** Under `config.R` as it stands, is every option's arithmetic right: units, signs,
   masks, joins and row order, the calendar, seeds and draws, the kernels, the ice options and split rules, the
   global-equivalent forcing, the slice labels, script 10's breakdown?

Then, in this order: what can be deleted or simplified (Chris's rules below: deletions first); failure honesty
(errors swallowed, partial outputs claimed as complete); provenance (run manifests, the stale-input check,
`allow_stale`, `fill_missing`); tests that cannot fail or test the wrong thing; whether `README.md`'s configuration,
run-order and provenance sections are right for Andria to run the pipeline herself.

## What to deliver
The report format of the role below, with these additions: put deletions and simplifications first; give each
finding's line cost (+added / -removed); end with "Not worth doing" and the total line cost of the fixes you
recommend. Say for each finding whether the planned gate runs (next section) would catch it.

## The gate that follows (planned, not yet approved by Chris)
- The legacy configuration run from scratch, scripts 1 to 10 including script 4's full refit (192 fits), its
  deterministic outputs compared byte for byte with `tests/anchors/` (land cover, calibration table, AIC table,
  point predictions; the tail from the frozen prediction summary), scripts 5 and 6 with seed 1 against
  `tests/anchors/interp-seed1-2026-10-14`.
- A full run of scripts 1 to 10 under `config.R`, with the test files as checks.
Say what these runs cannot catch.

## Read
- `AGENTS.md`, `CONTRIBUTING.md`, `README.md`.
- `docs/cc/2026-10-08_single_config_regression_contract.md` and `tests/anchors/README.md`: what counts as unchanged.
- `docs/cc/changelog_single_config_migration.md`: the record of every change, its reasons, Chris's decisions and its
  verification. A change recorded there as deliberate is not a defect for being a change; it can still be wrong.
- `docs/cc/2026-10-08_migration_issues_single_config_v2.md`, Part 4 "Risks for implementers and reviewers": check
  each risk against the code as it now stands.
- Earlier whole-code reviews: `docs/cc/2026-11-04_whole_code_review_codex_gpt6astra.md`,
  `docs/cc/2026-11-01_simplicity_review_codex_gpt6astra.md`, `docs/cc/2026-11-01_drift_conciseness_review_codex_gpt6astra.md`.
  Do not repeat findings since fixed; do report any still present, saying so.
- `docs/cc/questions_for_andria_general.md` and `docs/cc/questions_for_andria_scientific.md`: questions already put to
  Andria. Do not re-raise one as a finding unless the code is wrong whatever she answers.
- Then the code: `config.R`, `configs/legacy_config.R`, `R/`, `scripts/`, the verification tools
  (`tools/verify_change.R`, `tools/check_anchors.R`, `tools/compare_tables.R`, `tools/frozen.R`,
  `tools/check_merge_evidence.R`, `tools/check_comments_only.R`), `tests/`. The one-off builders and exploration
  tools in `tools/` (data preparation, cross-validation, comparisons) need only a lighter read: their outputs feed
  the pipeline or the meeting slides, so check what they hand on.

## Project facts
- Pipeline: script 1 land-cover preparation; 2 calibration table; 3 calibration plots; 4 calibration fits (the
  eight-model ladder, seven spatial experiments and the selected model for each month; about 20 hours in the last
  full run); 5 calibration evaluation; 6 prediction with simulated draws; 7 maps and coarse differences; 7a
  consecutive differences with the ice adjustment; 8 radiative forcing; 9 forcing summaries; 10 forcing by month and
  latitude.
- Branches: `chris-dev` is the project trunk; `feature/single-config` the migration branch (all of chris-dev is merged
  into it; nothing new on chris-dev since 3 November); `legacy` the frozen original; `main` changes only through a
  pull request Andria approves.
- Verification: `tools/verify_change.R` runs a spec under `docs/cc/verification/` from its own worktree; the merge
  check requires a PASS report for the merged code. The frozen inputs are listed in `tests/frozen_inputs.md5`.
- This time you are the only reviewer (the project's rule for the final integration): ignore the role's lines about
  pairing with another reviewer and reconciliation.

## Also given to Astra (not reproduced here)

The body of the project's science-reviewer role (as for Fable; its "run no command" line reworded to match the
Access section above), and Chris's rules on simplicity and architecture, which every design or review brief must
include.
