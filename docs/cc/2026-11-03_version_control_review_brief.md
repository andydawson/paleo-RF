# Full version-control review of paleo-RF, for Chris (Astra, ultra effort)

You are Astra. Read-only: change nothing. Read-only shell commands are allowed and expected: git log / show / diff /
branch -a / worktree list / for-each-ref / merge-base / rev-list / ls-remote, rg, grep, cat, sed -n, ls, wc, du. Never run
anything that writes (no checkout, switch, fetch, merge, branch -d, push, worktree add/remove/prune, R). Web search
allowed for published version-control practice (cite it). Plain words; no time estimates.

## Why
Chris: "I'm concerned that both Astra and Fable gave bad advice on this organisation plan", and asked for a full
version-control review, including deleting the branches no longer needed ("I'm not able to review, just delete the ones
we don't need any more"). Be adversarial, including about your own earlier designs.

## Where
- Main checkout (this directory): `/home/expert/Documents/contracting/Andria/paleo-RF`, currently on branch
  `i16b-calibration` with about 200 untracked files (data and verification specs and reports it runs from). Chris's rule:
  never switch this checkout; running jobs read verification specs from it and run the verification tool from it.
- Working copies: `/home/expert/Documents/contracting/Andria/paleo-RF-wt/{runs,cv,feature,archive,benchmark,
  organisation,questions,cleanups}` and verification worktrees `/home/expert/Documents/contracting/Andria/paleo-RF-verify/<commit>/`
  (many; some hold run folders `.rundirs/<run>/` that are still needed: run1-main in d5d5df5, run8-raster in 795792f, the
  refit runs, and the cross-validation runs). The refit queue runs now and reads some of these.
- Remote `origin` = github.com/andydawson/paleo-RF, about 74 branches.
- Rules: `CONTRIBUTING.md`, `AGENTS.md` (trunk `chris-dev`; topic branches off it; the single-config migration integrates
  on `feature/single-config`, which merges to `chris-dev` at the migration's end; never touch `legacy` or `main`; `main`
  only by a PR Andria approves; atomic why-focused commits; push at checkpoints), and the version-control item of
  `.claude/skills/code-review/SKILL.md` (checklist item 4). The merge gate: `tools/check_merge_evidence.R` (installed as a
  git hook). GitHub issues are where open work is filed (`gh` is not available to you; read docs/cc and commit messages).
- Today's organisation designs: `docs/cc/2026-11-03_repository_organisation_design_codex_gpt6astra.md` (yours) on
  `feature/single-config`, and Fable's review of it (summary: adopt with changes: three documentation branches, each
  experiment README written on its experiment's branch, link not copy, never move the checking tools). Chris's reaction:
  "Having multiple branches with different documentation sounds highly complicated and error prone". Chris then chose to
  merge finished work promptly into `feature/single-config` (done today for refit-runs, northeast-benchmark,
  repo-organisation; cv-design waits for its code review) and to write documentation in one place.
- Results: full run folders are about 7.7 GB each (fitted models and predictions), so they cannot go into git; Chris
  chose to commit each run's small result tables (forcing tables, manifests, cross-validation tables) to the trunk and
  keep the full run folders in `../paleo-RF-results/`, never deleted with a worktree.

## What to deliver
1. **Verdict** (at most 200 words): is version control being done well; the worst problems.
2. **Branch inventory**: every local and remote branch, with: last commit date, merged into `feature/single-config`
   and/or `chris-dev` (ancestor check), whether any worktree has it checked out, whether a running job or a kept run
   depends on its commits (the commits named in docs/cc/verification specs as `commit = '...'` must stay reachable: say
   whether they remain reachable from a kept branch if the branch is deleted), and a recommendation: delete (merged, not
   needed), keep (why), or merge first (what it holds). Give the exact commands for the deletions you recommend, local and
   remote, in a separate block, safe ones only (fully merged into a branch that is kept and pushed); list separately
   anything unmerged that you think is obsolete, with what would be lost. Never `legacy`, `main`, `chris-dev`,
   `feature/single-config`, `i16b-calibration` (the main checkout), or a branch a worktree or running job uses.
3. **Worktrees**: which `paleo-RF-verify/*` and `paleo-RF-wt/*` worktrees can go and which must stay (hold a kept run,
   used by the running queue), and how to move kept runs to `../paleo-RF-results/` safely later (after the queue).
4. **The organisation advice**: judge both reviewers' advice on branches and documentation against Chris's concern and
   published practice; recommend the simplest sound arrangement (for example: one integration branch where all
   documentation lives; short-lived topic branches merged promptly; what to do about the two parallel lines
   `chris-dev` and `feature/single-config`, and about `i16b-calibration` in the main checkout). Say what you got wrong
   before, if anything.
5. **Practice checks**: commit messages, atomicity, direct commits to trunks (one docs commit went straight to
   `chris-dev` today, eaf9afe), pushes, untracked files in the main checkout that should be committed or ignored, large
   or generated files in git, `.gitignore`, the merge-gate hook, tags.
6. **The five changes to make first**, and whether a dedicated skill or role for branch and worktree housekeeping is
   worth adding (Chris expected one), with its outline if so.

Output a markdown report.
