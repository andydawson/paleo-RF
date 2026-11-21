*Astra (gpt-6-astra, ultra effort, web search), 3 November 2026: full version-control review for Chris, including which branches can be deleted. Brief: `2026-11-03_version_control_review_brief.md`. Absolute paths are this workstation's.*

**Verdict — version control is strong at recording changes, but weak at closing work and preserving runnable evidence.**

The history generally explains changes well, scientific work has substantial verification records, and `main` and `legacy` remain untouched. However, branch and worktree housekeeping has fallen behind: there are **85 local branches, 74 cached remote branches and 118 worktrees**.

The worst problems are:

- Current questions and repository rules disagree between `chris-dev` and `feature/single-config`.
- Verification specs use branch names that move or disappear. `spatial-ml` already fails this way; its tested commit has no containing branch or tag.
- Kept results remain inside disposable verification worktrees. The chosen external results directory does not yet exist.
- The merge hook provides less protection than the written rules claim.

My earlier organisation plan added unnecessary branching to this situation. Chris’s preference for prompt integration and one documentation destination is sound.

The apparent untracked-file crisis is smaller than it looks: **222 of 224 files already have identical committed copies elsewhere**. Preserve their current paths for the queue.

**Audit basis and limits.** This report describes the inspected snapshot on 3 November 2026. Nothing was changed; no R was run. I read the repository protocol and applied item 4 of the [code-review checklist](/home/expert/Documents/contracting/Andria/paleo-RF/.claude/skills/code-review/SKILL.md:38).

Live `git ls-remote` failed because `github.com` could not be resolved. Therefore, “remote” below means the **74 locally cached `origin/*` branch refs**, excluding symbolic `origin/HEAD`. Their present state on GitHub remains unverified. Host processes were also outside the sandbox’s visibility; queue records and Chris’s statement that it is running govern retention.

**Branch inventory.** There are **87 distinct branch names: 72 present locally and remotely, 13 local-only, and two remote-only**. Every same-name local/cached-remote pair has an identical tip.

The table uses:

- **F** = `feature/single-config`; **C** = `chris-dev`.
- **F/C** shows whether the tip is an ancestor of each integration branch, including equality.
- **L/R** means local and cached remote; dates are tip commit dates, all in **2026**.
- **Delete → F/C** means all commits remain reachable from that kept branch. No candidate name is checked out or referenced as a verification spec’s `commit`. Any run depending on those commits retains its history.
- **Keep: spec name** means a spec directly names the branch. Its commits survive through F, but deleting the name would break lookup. Pin the spec to the **actual tested SHA from its report**, then retire the branch.
- Worktree names refer to `../paleo-RF-wt/`, except `main checkout`.

| Branch | Refs | Date | Tip | F/C | Worktree | Recommendation / dependency |
|---|---|---|---|---|---|---|
| `adversarial-review-config` | L | 10-07 | `3882b9f` | Yes/Yes | — | Delete → F |
| `adversarial-review-issues` | L | 10-08 | `8cdd849` | Yes/Yes | — | Delete → F |
| `albedo-build` | L/R | 10-29 | `adceede` | Yes/No | — | Keep: spec name; commits retained by F |
| `anchor-guard` | L/R | 10-15 | `89d2c79` | Yes/No | — | Keep: spec name; commits retained by F |
| `annotated-interp` | L/R | 09-30 | `e1714de` | No/No | — | Keep: 13 unique commits; reference annotations |
| `centre-elevation-tool` | L/R | 10-15 | `6ba1479` | Yes/No | — | Keep: spec name; commits retained by F |
| `chris-dev` | L/R | 11-03 | `4b2d453` | No/Yes | `questions` | Keep: protected trunk; reconcile into F |
| `clean-script-3` | L | 09-30 | `d49f178` | Yes/Yes | — | Delete → F |
| `cleanups-2026-11-03` | L/R | 11-03 | `220d758` | Yes/No | `cleanups` | Keep while checked out; merged |
| `convergence-report` | L/R | 10-22 | `71d6452` | Yes/No | — | Keep: spec name; commits retained by F |
| `cv-design` | L/R | 11-03 | `28f0dad` | No/No | `cv` | Merge first after review: 33 unique commits; CV evidence depends on it |
| `design-review-config` | L | 10-07 | `e609630` | Yes/Yes | — | Delete → F |
| `diagnostic-plots` | L/R | 10-27 | `84875f0` | Yes/No | — | Keep: spec name; commits retained by F |
| `docs-nits-2026-11-03` | L/R | 11-03 | `003bb05` | Yes/No | — | Delete → F |
| `drift-fixes` | L/R | 11-01 | `5bb5df4` | Yes/No | — | Keep: spec name; commits retained by F |
| `feature/single-config` | L/R | 11-03 | `b514213` | Yes/No | `feature` | Keep: migration integration branch |
| `file-reviews-2026-10-18` | L/R | 10-18 | `a9dcdc2` | Yes/No | — | Delete → F; pinned run commit survives |
| `fix-readme-cack-year` | L | 10-07 | `fb03523` | Yes/Yes | — | Delete → F |
| `fix-variant-components` | L/R | 10-19 | `bb76c87` | Yes/No | — | Keep: spec name; commits retained by F |
| `forcing-breakdown` | L/R | 10-16 | `fa47c98` | Yes/No | — | Keep: spec name; commits retained by F |
| `headline-partial-ice` | L/R | 10-19 | `6dd60c4` | Yes/No | — | Keep: spec name; commits retained by F |
| `housekeeping-2026-10-17` | L | 10-17 | `f0be70e` | Yes/No | — | Delete → F; pinned fitting commit survives |
| `housekeeping-2026-10-17-trunk` | L | 10-17 | `37a0a7d` | No/Yes | — | Delete → C |
| `i01-regression-contract` | L/R | 10-09 | `310c5a4` | Yes/No | — | Delete → F |
| `i02-month-indexing` | L/R | 10-12 | `c602e27` | Yes/No | — | Delete → F |
| `i03-config` | L/R | 10-13 | `66bdf29` | Yes/No | — | Delete → F |
| `i04a-settings` | L/R | 10-14 | `05be8e1` | Yes/No | — | Delete → F |
| `i04b-settings` | L/R | 10-14 | `13c3d83` | Yes/No | — | Delete → F |
| `i05-manifests` | L/R | 10-14 | `a597bd9` | Yes/No | — | Delete → F |
| `i06-wiring` | L/R | 10-14 | `e8fe4f5` | Yes/No | — | Delete → F |
| `i07-paths` | L/R | 10-13 | `cca2c1b` | Yes/No | — | Delete → F |
| `i11-pair-differences` | L/R | 10-14 | `4b39b40` | Yes/No | — | Delete → F |
| `i15-figure-notes` | L/R | 10-13 | `a41a5fd` | Yes/No | — | Delete → F |
| `i15a-comments` | L/R | 10-15 | `9e061c5` | Yes/No | — | Keep: spec name; commits retained by F |
| `i15b-helpers` | L/R | 10-15 | `fba4aec` | Yes/No | — | Keep: spec name; commits retained by F |
| `i15c-script1` | L/R | 10-15 | `e069728` | Yes/No | — | Keep: spec name; commits retained by F |
| `i15c-script2` | L/R | 10-15 | `6633484` | Yes/No | — | Keep: spec name; commits retained by F |
| `i15c-script2-albedo-names` | L/R | 11-03 | `007ec99` | Yes/No | — | Delete → F |
| `i15c-script3` | L/R | 10-15 | `5f5c5de` | Yes/No | — | Keep: spec name; commits retained by F |
| `i15c-script5` | L/R | 10-15 | `7f1b61a` | Yes/No | — | Keep: spec name; commits retained by F |
| `i15c-script6` | L/R | 10-15 | `ea35cd2` | Yes/No | — | Keep: spec name; commits retained by F |
| `i15c-script8` | L/R | 10-15 | `9b6ac12` | Yes/No | — | Keep: spec name; commits retained by F |
| `i15c-script9` | L/R | 10-15 | `04443fa` | Yes/No | — | Keep: spec name; commits retained by F |
| `i15c-scripts7` | L/R | 10-15 | `6e9b1da` | Yes/No | — | Keep: spec name; commits retained by F |
| `i16a-tail` | L/R | 10-14 | `e542652` | Yes/No | — | Delete → F |
| `i16b-calibration` | L/R | 10-15 | `451ea5c` | Yes/No | main checkout | Keep: protected execution checkout and spec name |
| `i16c-elevation` | L/R | 10-15 | `da5c158` | Yes/No | — | Keep: spec name; commits retained by F |
| `i17-path-readability` | L/R | 10-14 | `208df7a` | Yes/No | — | Delete → F |
| `ladder-aic` | L/R | 10-16 | `29fa5d9` | Yes/No | — | Keep: spec name; commits retained by F |
| `legacy` | L/R | 09-13 | `c9d525e` | Yes/Yes | — | Keep: protected frozen original |
| `main` | L/R | 09-13 | `c9d525e` | Yes/Yes | — | Keep: protected upstream |
| `merge-check-trunks` | L/R | 10-15 | `fd5ca15` | Yes/No | — | Keep: spec name; commits retained by F |
| `migration-issues-design` | L | 10-08 | `199aeae` | Yes/Yes | — | Delete → F |
| `migration-issues-v2` | L | 10-08 | `b0bc98f` | Yes/Yes | — | Delete → F |
| `northeast-benchmark` | L/R | 11-03 | `07d7053` | Yes/No | `benchmark` | Keep while checked out; merged |
| `northeast-location-plot` | L/R | 10-28 | `b7294fc` | Yes/No | — | Keep: spec name; commits retained by F |
| `northeast-title` | L/R | 11-02 | `f86ce1a` | Yes/No | — | Keep: spec name; commits retained by F |
| `old-scripts-archive` | L/R | 11-03 | `f052a0a` | Yes/No | `archive` | Keep while checked out; merged |
| `question-d4-coverage` | L | 10-12 | `9f27356` | Yes/Yes | — | Delete → F |
| `questions-cv-basis` | L/R | 11-03 | `4e5aee1` | No/Yes | — | Delete → C |
| `questions-diagnostics-and-mod7` | L/R | 10-27 | `1514951` | No/Yes | — | Delete → C |
| `questions-mod7-refit-stopped` | L/R | 10-26 | `cf1a0a4` | No/Yes | — | Delete → C |
| `questions-northeast-wording` | L/R | 10-28 | `16dc953` | No/Yes | — | Delete → C |
| `questions-old-scripts` | L/R | 11-03 | `979d474` | No/Yes | — | Delete → C |
| `questions-refit-plan` | L/R | 10-29 | `025845a` | No/Yes | — | Delete → C |
| `questions-snow-share` | L/R | 10-29 | `038eb0c` | No/Yes | — | Delete → C |
| `questions-winter-gap` | L/R | 10-29 | `5c4d36c` | No/Yes | — | Delete → C |
| `record-issue-numbers` | L | 10-08 | `d8c8eea` | Yes/Yes | — | Delete → F |
| `references-audit` | L/R | 10-29 | `374b843` | Yes/No | — | Delete → F |
| `refit-modis` | L/R | 10-31 | `77ad84c` | Yes/No | — | Keep: spec name; commits retained by F |
| `refit-plan` | L/R | 10-29 | `f0efc8e` | Yes/No | — | Delete → F |
| `refit-runs` | L/R | 11-03 | `c1f5d3e` | Yes/No | `runs` | Keep while checked out; run commits now retained by F |
| `repo-organisation` | L/R | 11-03 | `5ae5b1c` | Yes/No | `organisation` | Keep while checked out; merged |
| `review-simplicity-rule` | L/R | 11-01 | `d3c6a92` | Yes/No | — | Delete → F |
| `roles-sync` | L/R | 11-02 | `9800dc7` | Yes/No | — | Delete → F |
| `run-interp` | R | 09-23 | `54792f6` | Yes/Yes | — | Keep documented historical run address; commits retained by F/C |
| `run-nointerp` | R | 09-16 | `ce840a3` | Yes/Yes | — | Keep documented historical run address; commits retained by F/C |
| `seed-config-option` | L | 10-08 | `a902b9f` | Yes/Yes | — | Delete → F |
| `simplicity-review-2026-11-01` | L | 11-01 | `f2dbcb2` | Yes/No | — | Delete → F |
| `simplify-2026-11-01` | L/R | 11-01 | `1b61f16` | Yes/No | — | Keep: spec name; commits retained by F |
| `simplify-anchor-check` | L/R | 10-15 | `2c0b884` | Yes/No | — | Keep: spec name; commits retained by F |
| `simplify-docs` | L/R | 10-15 | `cebc75c` | Yes/No | — | Delete → F |
| `simplify-redundant-io` | L/R | 10-16 | `a98a5a1` | Yes/No | — | Keep: spec name; commits retained by F |
| `vc-practice-2026-11-02` | L/R | 11-02 | `839cb01` | No/Yes | — | Delete → C |
| `verification-records-2026-10` | L/R | 11-02 | `dda22d9` | Yes/No | — | Delete → F |
| `verify-tool` | L/R | 10-15 | `635c98d` | Yes/No | — | Keep: spec name; commits retained by F |
| `writing-tools` | L/R | 10-16 | `9563164` | Yes/No | — | Keep: spec name; commits retained by F |

**Verification-commit retention.** I inspected the spec values across the main checkout, named worktrees and all local branch tips: **86 distinct `commit` values**.

| Values | Retention finding |
|---|---|
| 44 literal SHAs | Reachable from F, including the refit queue’s existing and pending commits |
| Nine literal CV SHAs | Reachable from `cv-design`; retain it until integration |
| 32 resolvable symbolic values | Currently resolve to commits retained by F; names remain necessary until specs are pinned |
| `spatial-ml` | Already unresolved; its report identifies an otherwise unreferenced commit |

The nine CV SHAs are `057b9f2`, `11356e0`, `25cde3a`, `44d0605`, `5bf769e`, `6841c48`, `8b85be9`, `b0cf6b1`, and `b7a5772`.

The symbolic values are already a reproducibility defect even before deletion. For example, [the script-1 “before” spec](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/docs/cc/verification/2026-10-15_i15c-script1-before.R:4) names `origin/feature/single-config`, which now resolves to `b514213`. Its [report](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/docs/cc/verification/2026-10-15_i15c-script1-before_report.md:4) records the tested commit as `f2bacb52fe973da2bbb4131956e8d3cb2f029e69`. Rerunning the unchanged spec would test different code.

Repair these against the reports, preserving the original evidence. Do not substitute today’s branch tips indiscriminately or edit specs currently being read by jobs.

**Unmerged work that should not be deleted blindly.**

| Work | Assessment | What deletion would put at risk |
|---|---|---|
| `cv-design` | Active; merge after the outstanding review | 33 unique commits: CV implementation, registry/config changes, tests, protocol, reviews and nine verification pairs |
| `annotated-interp` | Obsolete as executable development code; still useful as a teaching reference | 13 unique commits containing annotations, glossary, walkthrough, review and run records |
| Former `spatial-ml` | Deliberately abandoned scientific change; branch already deleted | Two commits, including the precise code tested by its retained PASS report |

Do not merge the stale annotation code wholesale. Retire its branch only after useful teaching material is extracted or its history receives a durable published archival reference.

For `spatial-ml`, the [changelog](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/docs/cc/changelog_single_config_migration.md:1130) explicitly records rejection of the change. Preserve it as historical evidence without restoring it to the analysis.

**Exact branch-deletion commands — conditional, not executed.** The reviewed scope is **43 local names and 30 remote names**. An independent check confirmed their ancestry, worktree exclusion and absence from the searched runnable branch references.

Because live publication could not be checked, there is no unconditional remote-deletion recommendation. The following Bash block stops before any deletion unless the kept branches are published at the audited tips, candidates still pass ancestry checks, and remote candidate tips match. It then deletes local names and uses explicit expected-tip leases for remote deletion.

Recheck host job use before applying this snapshot if work has continued. This block removes no worktree and switches no checkout.

```bash
set -euo pipefail

repo=/home/expert/Documents/contracting/Andria/paleo-RF
feature_wt="${repo}-wt/feature"
chris_wt="${repo}-wt/questions"

feature_tip=b514213563aa50e5b1dd114b0b137882c2e4f66a
chris_tip=4b2d453e33489baf8f9671afd02ace51ffe75360

feature_topics=(
  adversarial-review-config adversarial-review-issues clean-script-3
  design-review-config docs-nits-2026-11-03 file-reviews-2026-10-18
  fix-readme-cack-year housekeeping-2026-10-17
  i01-regression-contract i02-month-indexing i03-config
  i04a-settings i04b-settings i05-manifests i06-wiring i07-paths
  i11-pair-differences i15-figure-notes i15c-script2-albedo-names
  i16a-tail i17-path-readability migration-issues-design
  migration-issues-v2 question-d4-coverage record-issue-numbers
  references-audit refit-plan review-simplicity-rule roles-sync
  seed-config-option simplicity-review-2026-11-01 simplify-docs
  verification-records-2026-10
)

chris_topics=(
  housekeeping-2026-10-17-trunk questions-cv-basis
  questions-diagnostics-and-mod7 questions-mod7-refit-stopped
  questions-northeast-wording questions-old-scripts questions-refit-plan
  questions-snow-share questions-winter-gap vc-practice-2026-11-02
)

remote_topics=(
  docs-nits-2026-11-03 file-reviews-2026-10-18
  i01-regression-contract i02-month-indexing i03-config
  i04a-settings i04b-settings i05-manifests i06-wiring i07-paths
  i11-pair-differences i15-figure-notes i15c-script2-albedo-names
  i16a-tail i17-path-readability references-audit refit-plan
  review-simplicity-rule roles-sync simplify-docs
  verification-records-2026-10
  questions-cv-basis questions-diagnostics-and-mod7
  questions-mod7-refit-stopped questions-northeast-wording
  questions-old-scripts questions-refit-plan questions-snow-share
  questions-winter-gap vc-practice-2026-11-02
)

# Read-only preflight. A failed remote lookup aborts all deletion.
live=$(git -C "$repo" ls-remote --heads origin)

remote_sha() {
  awk -v ref="refs/heads/$1" '$2 == ref { print $1 }' <<< "$live"
}

[[ "$(remote_sha feature/single-config)" == "$feature_tip" ]]
[[ "$(remote_sha chris-dev)" == "$chris_tip" ]]
[[ "$(git -C "$repo" rev-parse refs/heads/feature/single-config)" == "$feature_tip" ]]
[[ "$(git -C "$repo" rev-parse refs/heads/chris-dev)" == "$chris_tip" ]]

worktrees=$(git -C "$repo" worktree list --porcelain)

for branch in "${feature_topics[@]}" "${chris_topics[@]}"; do
  git -C "$repo" show-ref --verify --quiet "refs/heads/$branch"
  if grep -Fxq "branch refs/heads/$branch" <<< "$worktrees"; then
    printf 'STOP: branch is checked out: %s\n' "$branch" >&2
    exit 1
  fi
done

for branch in "${feature_topics[@]}"; do
  git -C "$repo" merge-base --is-ancestor "refs/heads/$branch" "$feature_tip"
done

for branch in "${chris_topics[@]}"; do
  git -C "$repo" merge-base --is-ancestor "refs/heads/$branch" "$chris_tip"
done

leases=()
deletions=()

for branch in "${remote_topics[@]}"; do
  expected=$(git -C "$repo" rev-parse "refs/remotes/origin/$branch")
  [[ "$(git -C "$repo" rev-parse "refs/heads/$branch")" == "$expected" ]]
  [[ "$(remote_sha "$branch")" == "$expected" ]]
  leases+=("--force-with-lease=refs/heads/$branch:$expected")
  deletions+=(":refs/heads/$branch")
done

# Local deletions: only branches proved merged into a published keeper.
git -C "$feature_wt" branch -d "${feature_topics[@]}"
git -C "$chris_wt" branch -d "${chris_topics[@]}"

# Remote deletions: reject the whole push if any candidate has moved.
git -C "$repo" push --atomic "${leases[@]}" origin "${deletions[@]}"
```

The explicit ancestry checks matter: `git branch -d` checks the configured upstream, or HEAD when there is no upstream. A topic tracking its own remote topic can pass that check without being integrated into the retained trunk. [Git branch documentation](https://git-scm.com/docs/git-branch)

**Worktrees: retain results before retiring working copies.** The 118 worktrees comprise the main checkout, eight named working copies, and **109 detached verification worktrees**. Every verification worktree contains `.rundirs` results despite clean Git status.

| Named working copy | Recommendation |
|---|---|
| Main checkout | Keep on `i16b-calibration`; preserve its tool, specs and input paths |
| `feature` | Keep as the current integration checkout |
| `questions` | Keep while `chris-dev` remains a separate active line |
| `cv` | Keep for unfinished CV review and integration |
| `archive` | Can retire after checking host use; work is merged |
| `benchmark` | Can retire after checking host use; work is merged |
| `cleanups` | Can retire after checking host use; work is merged |
| `organisation` | Can retire after checking host use; work is merged |
| `runs` | Can retire after checking host use; queue does not execute from this working copy |

All eight named copies have no changed, untracked or ignored untracked files and no `.rundirs`. The five retirement candidates are absent from the queue scripts. Their branches remain excluded from the deletion block because they are currently checked out.

The [queue launcher](/home/expert/Documents/contracting/Andria/refit-queue/launch.sh:4) executes the **main checkout’s** verifier and specs. Verification worktrees also contain **28,449 input symlinks** back to the main checkout; none was broken in the inspection. The main checkout remains an execution dependency even after individual jobs finish.

The following classification accounts for **every existing verification directory** beneath `../paleo-RF-verify/`.

| Group | Count | Disposition |
|---|---:|---|
| Refit runs and fitting parts | 23 | Keep through queue completion and result preservation |
| CV attempts and comparisons | 9 | Keep until their retained outputs are preserved |
| Historical full runs and fitting parts | 8 | Keep pending preservation of comparison evidence |
| Historical check-input directories | 2 | Preserve their referenced products before removal |
| Orphaned `spatial-ml` worktree | 1 | Keep until its commit has a durable published reference |
| Other verification directories | 66 | Removal candidates after queue and evidence checks |

**The 23 refit directories:**

```text
014e8a3 0df176d 280a9a0 5164b91 54decc7 5ddcb94
74c4cf7 795792f 8db4a5e 8e3f3a4 9a08244 9ea33e1
ac05239 b689642 baa4ae2 bd174cf be277d7 d5d5df5
e04de82 e71b6ee f44881b f6ca119 f9f9e46
```

In particular:

| Retained result | Location |
|---|---|
| Run 1 full pipeline | `d5d5df5/.rundirs/run1-main` |
| Run 1 fitting parts | `5ddcb94`, `be277d7`, `f9f9e46`, `8db4a5e` |
| Run 1 model-7 checks | `f44881b` |
| Run 8 full pipeline | `795792f/.rundirs/run8-raster` |
| Run 8 fitting parts | `b689642`, `280a9a0`, `bd174cf` |
| Run 2 full and interrupted attempts | `8e3f3a4/.rundirs/run2-snowfree{,-2}` |
| Run 2 fitting parts | `74c4cf7`, `5164b91`, `e04de82` |

Queue records show six jobs started without a recorded exit:

| Directory | Job |
|---|---|
| `014e8a3` | `run3-any75-fit-jan-apr-2` |
| `e71b6ee` | `run3-any75-fit-may-aug-2` |
| `0df176d` | `run4-any75-snowfree-fit-jan-apr-2` |
| `54decc7` | `run4-any75-snowfree-fit-sep-dec-2` |
| `9a08244` | `run5-winter-fit-nov-dec` |
| `baa4ae2` | `run6-winter-snowfree-fit-jan-feb` |

Pending consumers also need completed fits in `ac05239`, `f6ca119` and `9ea33e1`.

The queue names nine further commits whose worktrees had not yet appeared: `7850d46`, `c2ccdb1`, `4946d09`, `31ac4d7`, `ba5e69a`, `7e6f30c`, `fce14d1`, `58bd502`, `74b5482`. All remain reachable from F.

Keep interrupted attempts explicitly designated as retained in the [refit log](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/docs/cc/2026-11-01_refit_runs_log.md:88).

**The nine CV directories:**

```text
057b9f2 11356e0 25cde3a 44d0605 5bf769e
6841c48 8b85be9 b0cf6b1 b7a5772
```

These include the named comparison baseline in `11356e0`, evidence in `6841c48`, and the latest attempt in `b7a5772`.

**The eight historical comparison directories:**

```text
1716516 294e201 4ba4d2a 8e715d2
a9dcdc2 ce2577e f0be70e 44d6a06
```

`4ba4d2a` contains both October full runs; `44d6a06` contains `headline-partial-ice-2`. These are named comparisons in the [refit brief](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/docs/cc/2026-10-29_refit_plan_brief.md:67).

**Two further directories, `2bd4ab5` and `4672560`, supply historical check inputs.** Preserve those inputs and record replacement locations before removing the working copies: `2026-10-19_headline-partial-ice_check.R` refers to them.

**The orphan is `52a6237`.** Its full commit is:

```text
52a62376a55db04e5740df61cfd0b10c46077a8b
```

No local branch, cached remote branch or tag contains it. Preserve an archival reference before removing the worktree. Of all 109 verification HEADs, **99 are retained by F, nine by `cv-design`, and this one by neither**.

**The remaining 66 removal candidates:**

```text
019ec98 03f0cab 0e73cb5 1158f29 117bfdb 1ce2ca1
1ea8de4 200b414 2138f8f 21409f4 22330cd 2664599
28011db 29d964c 2ca4171 2eda936 2f5f066 300c2a6
334afa3 3ba159a 3d6a05a 41c1701 44b4b84 4bb95e1
4d2c1b1 4f4245e 4f7e8db 51888b4 527ea1c 5895f97
5deabac 61b5447 66fedb3 70a30aa 75945ee 79f1491
7c2bec3 83415db 837f2d3 88356cf 95fedfa 9ca2ed8
9ec468c a3cfe68 a83d9d5 ac90729 b0c706c b43e7e3
b835c95 c0098cb c3ef429 cca9ece ccb6da6 d766260
d784aea d8b6ab1 dbff5bd dd6e0fc df59853 e15faed
eee1a3f eee9a2c f0ff501 f2bacb5 f756cd3 f93628e
```

These are candidates for retirement **after** retained specs, reports, configurations, logs and required products are accounted for and no process uses them. Clean status alone cannot authorize removal of ignored results. `git worktree prune` merely removes administrative records for missing working copies; it does not perform this preservation work. [Git worktree documentation](https://git-scm.com/docs/git-worktree)

**Moving kept runs safely after the queue.** The chosen `../paleo-RF-results/` directory does not yet exist. Observed sizes include 7.7 GB for run 1, 7.8 GB for run 8, 15 GB in the run-2 worktree including its interrupted attempt, and 18 GB in `4ba4d2a`.

The purpose of this move is to preserve the paper’s results independently of temporary code checkouts.

1. Confirm that producers and downstream consumers have finished.
2. Record each retained attempt’s stable identifier, full code SHA, spec/report, configuration, input inventory, old path and destination.
3. **Copy first** into a distinct directory beneath `../paleo-RF-results/`. Include models, predictions, tables, manifests, logs, `config_used.R` and `SEEDED.txt`. Keep designated interrupted attempts separately.
4. Compare source and destination file inventories, sizes and checksums. Inspect symlinks and preserve their required targets or document the external inputs.
5. Commit each run’s small tables and manifests, plus the results-location index, on the integration branch. Keep different runs distinct.
6. Update current readers and future specs to the durable locations, preserving historical records of original paths.
7. Remove obsolete worktrees only after these checks and confirmation that required commits have published references.

A sibling results directory protects against worktree removal. It still needs an independent backup. The input symlinks also mean that preserving `.rundirs` alone does not preserve all frozen inputs.

**Judgment on the organisation advice.** Chris’s objection was justified.

My [actual design](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/docs/cc/2026-11-03_repository_organisation_design_codex_gpt6astra.md:274) proposed **four documentation branches plus a header branch**. It did say to merge and push them, so it was not a proposal for permanent documentation branches. Nevertheless, splitting modest navigation work that finely was unnecessary. I should have challenged that granularity, specified one authoritative documentation destination, and included branch/worktree closeout.

Atomic commits do not require a branch for each README group.

Fable’s reported recommendations to link instead of copy and keep checking tools in place were good. Writing an experiment’s README alongside unfinished experiment code is also sensible. Treating that branch as the continuing home of its documentation would perpetuate the problem. I did not find Fable’s full organisation review in the inspected repository history; this judgment uses Chris’s supplied summary.

Published practice supports short-lived branches for related work, followed by integration and deletion. GitHub explicitly includes documentation in that workflow. Neither source requires separate enduring branches for document categories. [Pro Git: Branching Workflows](https://git-scm.com/book/en/v2/Git-Branching-Branching-Workflows), [GitHub flow](https://docs.github.com/en/get-started/using-github/github-flow)

There is already a more consequential documentation split:

| Evidence | Consequence |
|---|---|
| `chris-dev...feature/single-config` has **70 C-only and 510 F-only commits** | The lines have substantially diverged |
| Their merge base is `6d5bda1`, dated 13 October | Today’s three documentation merges did not reconcile the trunks |
| C contains the 2 November GitHub-issue rule; F lacks it | Agents read different workflow requirements |
| C identifies `questions_for_andria_scientific_from_2026-10-20.md` as current; F still points to the frozen predecessor | Questions and answers can go to the wrong register |
| F contains verification and merge-gate rules missing from C | The declared protocol depends on the checkout |

The simplest sound arrangement is:

- **During the migration, use F as the common integration and documentation destination.** Keep experiment summaries, questions, decisions, verification records and small results there through short task branches.
- Merge C into F under the recorded stage-boundary rule. Reconcile both versions of the protocol and the question registers deliberately; avoid ongoing manual copying between branches.
- Keep CV code pending until its required review is complete. A common index can identify pending work without presenting it as integrated.
- Retain C as the pre-migration review line only for the purpose that justified it. Define migration completion independently of every later scientific experiment.
- After the whole-migration review and full-run gate, merge F into C and return to **one development integration line**. Preserve the existing history.
- Keep the main checkout pinned to `i16b-calibration`. Use the feature working copy for development. Any later relocation of launchers/spec dependencies is a separate controlled change; it does not require switching this checkout.
- Leave checking tools at their established paths. Use a short index and links to evidence.

Chris’s decision to commit small numerical results improves the earlier advice. Interpretation and links alone do not preserve the values supporting the paper.

**Practice checks.**

| Area | Finding | Recommended treatment |
|---|---|---|
| Commit messages | Generally strong explanations of purpose, decisions and evidence | Preserve this standard |
| Atomicity | Mostly coherent changes; some related review fixes bundled | Improve selectively; avoid retrospective history rewriting |
| `main` and `legacy` | Both remain at `c9d525e` | Keep untouched |
| Direct trunk commit `eaf9afe` | One scientific-questions file, 27 added lines; violated the topic-branch rule | Record the exception; do not rewrite it for appearances |
| Pushes | Same-name local/cached-remote tips match | Verify actual remote heads before cleanup |
| Upstreams | Several topics track F or C rather than their own remote topic | Use explicit refs when assessing publication and integration |
| Untracked files | Mostly committed elsewhere | Preserve execution paths; reconcile selectively |
| Generated/large files | Existing anchors and inputs have documented reasons | Preserve them; keep new full runs outside Git |
| Ignore rules | Small-table exceptions are ineffective | Fix the parent-directory exclusion or use a clearly tracked results location |
| Merge hook | Useful but incomplete enforcement | Correct the claims and cover actual integration paths |
| Tags | Two useful annotated historical tags | Keep and verify their remote publication |

**Commit practice in more detail.** `eaf9afe` is a workflow lapse, but it is not evidence of unverified scientific code entering the trunk. Its content is documentation.

Since 8 October, first-parent histories contain 61 non-merge commits on C and 32 on F; none changes the merge gate’s code paths. Those counts do not prove every commit was made directly on a trunk, because fast-forward integration can look the same. They do show that documentation has not consistently used explicit topic merge records.

One avoidable source of history noise is the use of documentation-only commits to obtain separate verification worktrees. The [refit log](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/docs/cc/2026-11-01_refit_runs_log.md:9) explicitly describes this arrangement. It follows from [the verifier’s SHA-only directory naming](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/tools/verify_change.R:81), rather than a Git restriction: multiple detached worktrees can use the same commit. After the queue, consider a small reviewed change that distinguishes concurrent runs by run identity as well as code SHA. Do not change the executing verifier now.

**The 224 untracked files, reconciled by content.**

| Category | Count |
|---|---:|
| Byte-identical committed copies on F | 202 |
| Byte-identical CV specs/reports on `cv-design` | 18 |
| Byte-identical MOD44W provenance files on C | 2 |
| `2026-10-15_anchor-guard.R`, opening comment differs only | 1 |
| `data/mod44w/paleo_rf_area_shapefile.zip`, no identical tracked copy found | 1 |

The 202 on F comprise 199 verification files and three input/provenance files. The two on C are `paleo_rf_area.geojson` and `paleo_rf_area_check.png`.

Do not blanket-add, blanket-ignore or remove this collection. The checkout’s old branch makes committed files appear untracked. Reconcile the comment later. Preserve the 2,165-byte shapefile ZIP as provenance if it was the submitted request input; otherwise document how it is regenerated before ignoring it.

**Large and generated files.** At F’s tip there are 627 tracked files, about **438 MB of ordinary Git blob payload**, and 43 files above 1 MB. Across locally referenced history, ordinary blobs total about **489 MB uncompressed**; none exceeds 100 MB. The largest is a roughly 51 MB frozen prediction-summary anchor.

These figures exclude LFS payloads. The repository uses LFS for four especially large assets and excludes anchor downloads by default. Original inputs, original fitted objects and regression anchors have documented purposes. I found no evidence that the new multi-gigabyte refit folders were committed. Rewriting shared history to remove justified anchors would be a poor cleanup priority.

Only four historical forcing CSVs and historical manifests are currently tracked under `output/` and `runs/`; Chris’s per-refit small-results policy still needs implementation.

**`.gitignore` has a concrete fault.** [Lines 3 and 31](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/.gitignore:31) exclude `output/`; later exceptions attempt to include forcing CSVs. A read-only `git check-ignore` confirms that a new forcing CSV remains ignored. Git cannot re-include a file while its parent directory remains excluded. Existing tracked CSVs are unaffected. [Git ignore documentation](https://git-scm.com/docs/gitignore)

Use an explicit allowlist for small retained tables, and reconcile the blanket `runs/` exclusion with the manifest policy. Keep bulky runtime products ignored. Avoid ignoring all of `data/mod44w/`, since it includes useful small provenance files.

**The merge gate is a useful guard, not universal enforcement.** The executable hook is installed and invokes the configured R interpreter. Its exact-code comparison is valuable, but:

- It exits successfully when the checker is absent. The checker is currently absent from C.
- Direct commits and fast-forward merges do not pass through `pre-merge-commit`.
- Conflict-resolved merges committed separately do not invoke that hook; there is no active `pre-commit` hook covering the gap.
- `--no-verify` can bypass it.
- A matching PASS report does not establish adequate test coverage, a committed spec or completed independent review.
- Input-data changes are outside its listed code paths.

The relevant logic is in [the checker](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/tools/check_merge_evidence.R:26). Git documents the conflict-resolution gap explicitly. [Git hook documentation](https://git-scm.com/docs/githooks#_pre_merge_commit)

Existing tests meaningfully exercise accepted and rejected `--no-ff` merges, but do not cover all these integration paths. I inspected them without running R. Ensure the destination has the gate before final migration integration, add targeted coverage for the actual workflow, and correct the written claim that Git always refuses unverified changes.

**Tags.**

| Tag | Tag date | Target |
|---|---|---|
| `v0-legacy` | 2026-09-19 | `c9d525e` |
| `v1-both-flavours` | 2026-09-24 | `b45ead7` |

Keep both. Their remote publication could not be checked. A migration-completion tag would be useful; a tag for every already-reachable verification commit is unnecessary. Treat tags as protected references backed up elsewhere, rather than technically undeletable objects.

**The five changes to make first.**

1. **Protect executable provenance.** Give `52a6237` a published archival reference, preserve its worktree meanwhile, and pin symbolic verification specs to the full SHAs recorded in their reports. Leave active copies untouched.
2. **Reconcile the two documentation authorities.** Bring C into F through the required integration process; reconcile workflow rules and designate one current scientific-question register.
3. **Close the proven finished branches.** Once live remote checks succeed, remove the 43 local and 30 remote names above. Adopt a small routine closeout skill so this backlog does not recur.
4. **After the queue, preserve results outside worktrees.** Implement `../paleo-RF-results/`, validate copies, commit each run’s small tables/manifests, fix ignore rules, then retire the identified working copies.
5. **Repair verification workflow gaps before final migration integration.** Cover the actual merge paths, make the gate available on the destination, and remove the tooling need for artificial commits solely to allocate worktrees.

**A dedicated housekeeping skill is worthwhile.** Its benefit is straightforward: Andria gets a navigable history and retained results without Chris having to inspect dozens of stale branches.

Use one small skill owned by the implementer at task closeout. An optional read-only auditor can handle a backlog like this one. Its outline should be:

| Part | Required behaviour |
|---|---|
| Trigger | After topic integration and at session close |
| Read | Protocol, protected branches, current integration target, queue and retained-run records |
| Inventory | Local/live-remote tips, ancestry, worktree occupancy, untracked/ignored contents and spec references |
| Prove retention | Every removed branch’s commits survive through a kept published ref; every retained run’s commit remains reachable |
| Close branches | Push integration, verify remote state, remove explicit redundant names with changed-tip protection |
| Close worktrees | Check active and queued consumers; preserve and validate results first |
| Report | Removed names, kept names with reasons, result locations and unresolved issues |
| Hard limits | Never switch the execution checkout, delete protected/occupied branches, discard unmerged work or equate ignored data with disposable data |

This should make routine, already-authorized housekeeping dependable. It should not add another permanent approval layer.