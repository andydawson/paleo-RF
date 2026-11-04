# Design for Astra (ultra effort): the version-control fixes, as a concrete ordered plan

Read-only: change nothing. Read-only shell commands allowed (git log/show/diff/branch -a/worktree list/for-each-ref/
merge-base/rev-list, rg, cat, sed -n, ls, du). Web search allowed for published practice; cite it. Plain words; no time
estimates. Keep everything as simple as possible (project rule: no bloat, readability before elegance).

Your version-control review of 3 November is `docs/cc/2026-11-03_version_control_review_codex_gpt6astra.md` in this
checkout (`feature/single-config`, now including the cross-validation, merged as e00a8d0 with a hand-resolved changelog
conflict: the merge hook did not run, and running `tools/check_merge_evidence.R check HEAD` afterwards printed "no code
changes" although the merge brought the cross-validation code; the merged commit was then verified directly,
`docs/cc/verification/2026-11-03_cv-merge-feature_report.md`). Chris's decisions since: merge finished work promptly into
`feature/single-config` and keep documentation in one place; commit each run's small result tables and manifests to
the trunk and keep full run folders (about 7.7 GB each) in `../paleo-RF-results/`; delete the branches not needed (your
guarded script; the permission system would not let the session run it, so Chris may run it himself). The refit queue
is still running (runs 4-7) and reads the main checkout `/home/expert/Documents/contracting/Andria/paleo-RF` (on
`i16b-calibration`, never switched) and its verification worktrees.

Design, each item with: the problem in one sentence, the change (exact files, commands or text), how it is checked,
what must wait for the refit queue, and the order:
1. **Reconcile `chris-dev` and `feature/single-config`** (70 and 510 unique commits; diverging rules in CONTRIBUTING.md /
   AGENTS.md and question registers): the merge direction and steps under the recorded rules (CONTRIBUTING.md), which
   files conflict and how each is resolved, one current scientific-question file, and how the session should work
   afterwards (where new questions go until the migration ends).
2. **Pin verification specs** that name branches to the exact commits recorded in their reports, without editing specs
   a running job reads, and the archival reference for `52a6237` (the orphaned spatial-ml commit).
3. **`.gitignore`** so each run's small tables and manifests can be committed (the parent-directory exclusion), and the
   exact list of files per run to commit (sizes), and where they go in the repository.
4. **The results folder**: the copy-verify-update-remove procedure for kept runs after the queue, as a short script or
   checklist, and which worktrees can then be removed.
5. **The merge gate's gaps**: why `check HEAD` printed "no code changes" for e00a8d0; the smallest changes so a
   conflict-resolved merge, a fast-forward and a direct commit are covered (or the written claims corrected); tests.
6. **A housekeeping skill**: its full text (SKILL.md, short), to run at task close and session end, following your
   outline; and whether the verify tool's one-worktree-per-commit naming should change after the queue.
Output a markdown plan with the items in the order to do them, then what Chris must decide.
