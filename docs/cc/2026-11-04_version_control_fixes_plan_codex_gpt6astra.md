*Astra (gpt-6-astra, ultra effort), 4 November 2026: the version-control fixes as an ordered plan. Brief: `2026-11-04_version_control_fixes_plan_brief.md`. Absolute paths are this workstation's.*

Nothing changed. This plan uses the current inspected tips: `chris-dev` at `837c940`, and `feature/single-config` at `55d8f5b`. They now have **72 and 552 unique commits**, respectively. Cached remote tips match; live publication was not checked.

The benefit is one reliable place for Andria’s questions, code and numerical results, with verification evidence that survives branch and worktree cleanup.

Do steps 1–5 in a short topic off `feature/single-config`, using another checkout, and integrate the finished work promptly. Step 6 waits for the queue. All commands below are proposed commands, not executed commands.

**1. Reconcile the branches and designate one documentation destination**

**Problem:** sessions currently receive different workflow rules and different scientific-question destinations depending on their checkout.

The direction is **`chris-dev` into `feature/single-config` now**. The recorded migration exception requires this at stage boundaries; the reverse merge waits for the whole-migration review and full-run gate. Neither history should be rebased. See [CONTRIBUTING.md](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/CONTRIBUTING.md:119).

From the feature checkout:

```bash
git worktree add ../vc-housekeeping -b vc-housekeeping feature/single-config
git -C ../vc-housekeeping merge --no-ff --no-commit chris-dev
```

Capture both full branch tips before starting. Recheck the differences if either has advanced.

Only three files have changed on **both** sides since the common ancestor:

| File | Resolution |
|---|---|
| `AGENTS.md` | Keep C’s GitHub-issue rule, readability rule and current scientific-register pointer. Keep F’s README code-map pointer, verification instructions, literature requirement and review rules. |
| `CONTRIBUTING.md` | Keep C’s issue and question-register rules, alongside F’s verification, layout and migration decisions. Add the temporary integration rule below. Correct the hook claims in step 3. |
| `.gitignore` | Preserve the shared download exclusions and F’s `.rundirs/` exclusion. Apply the results-policy correction separately in step 4. |

These are overlapping-edit candidates, **not a confirmed Git conflict list**: no merge was executed during this inspection. Git may combine some automatically.

The question files changed only on C and should come across normally:

- **Current:** `docs/cc/questions_for_andria_scientific_from_2026-10-20.md`.
- **Frozen:** `docs/cc/questions_for_andria_scientific.md`, the record sent to Andria on 20 October.
- **Current general questions:** `docs/cc/questions_for_andria_general.md`.

Keep their existing question numbers. Do not merge the two scientific files into a new list. Update the general file’s introductory link and README’s living-document index; retain historical links that identify questions in the frozen record.

Also retain C’s three dated documents, supplementary provenance updates, and:

```text
data/mod44w/paleo_rf_area.geojson
data/mod44w/paleo_rf_area_check.png
```

Add this text to `CONTRIBUTING.md`, with a shorter matching summary in `AGENTS.md`:

> Until the single-config migration finishes, create task branches from `feature/single-config` and merge finished work promptly back into it. This is the common destination for code, documentation, questions, decisions, verification records and small run results. `chris-dev` remains Andria’s pre-migration review line; merge its new work into the feature branch at stage boundaries. After the whole-migration review and full-run gate, merge the feature branch into `chris-dev` and resume the normal trunk workflow.

All new agent sessions should start in F or a topic derived from it. New questions go into the two current registers there. Do not continue maintaining separate question copies on C.

**Check:** C currently contributes no changes under `R/`, `scripts/`, `tools/`, `tests/`, `config.R` or `configs/`. After staging the reconciliation:

```bash
git diff --cached --check
git diff --cached --name-only --diff-filter=U
git diff --cached --exit-code <captured-feature-tip> -- \
  R scripts tools tests config.R configs
```

The unresolved-file list and code diff must be empty. Review the combined rules and question navigation. After integration, prove the captured C tip is an ancestor of F. No pipeline rerun is needed for this documentation-only reconciliation.

**Queue:** no wait required in the separate checkout. Leave the main execution checkout and its files untouched.

**2. Pin the verification specs and preserve the abandoned commit**

**Problem:** branch names in historical specs can resolve to different code, or disappear entirely.

In `docs/cc/verification/`, there are currently **83 symbolic `commit` assignments**:

- **81** have a matching `<spec-stem>_report.md`.
- One has its report under the following day’s date.
- One is a documented invalid attempt.

For each report-backed spec, replace only its symbolic `commit` value with the full SHA on that report’s `- commit:` line. Include FAIL reports: preserve what was actually tested. Do not replace every occurrence of a branch name with one SHA.

For example, these specs all currently name `origin/feature/single-config`, but require different pins:

| Spec, under `docs/cc/verification/` | Recorded SHA |
|---|---|
| `2026-10-15_i15c-script1-before.R` | `f2bacb52fe973da2bbb4131956e8d3cb2f029e69` |
| `2026-10-15_i15c-script2-before.R` | `2138f8f22404dd8c04d222e1fe3ff9bc6f89e00d` |
| `2026-10-15_i15c-script3-before.R` | `9ec468c699cac25c7907e3a5beab45918d22404b` |
| `2026-10-15_i15c-script5-before.R` and `…scripts7-before.R` | `f756cd3557b8c2020b6ccea1735331419569f33b` |

Handle the two exceptions explicitly:

- Pin `2026-10-15_simplify-io-2-scripts78.R` to `4f7e8db6102d0b36f947c30a77bc332c7e2346aa`. The **16 October** report explicitly names this original spec; pin the 16 October copy consistently.
- Retire `2026-10-15_i16c-elevation-legacy-2.R` from the current runnable specs. Commit `e15faed` records that it checked a nonexistent folder and compared nothing. Explain its retirement in the verification README and point to the `-3`/`-4` records. Git history preserves the invalid attempt.

That gives **82 report-backed replacements**, not 83 invented pins. Leave reports unchanged and record the correction in the changelog.

Preserve the rejected spatial experiment with an annotated archival tag:

```bash
git tag -a archive/spatial-ml-2026-10-15 \
  52a62376a55db04e5740df61cfd0b10c46077a8b \
  -m "Preserve the rejected spatial-ml experiment and its verification evidence"
git push origin refs/tags/archive/spatial-ml-2026-10-15
git ls-remote origin 'refs/tags/archive/spatial-ml-2026-10-15^{}'
```

The published peeled target must equal that full SHA. Pin `2026-10-15_spatial-ml.R` to the SHA. Do not merge the rejected method.

Update the verification README to require full SHAs in new saved specs. Its example can use the existing legacy report’s SHA:

```r
commit = '5deabac7df11daa289698a41ec85373a7ab72ef3'
```

**Check:** search for `commit[[:space:]]*=` anywhere on a line—three assignments are inline. Check every replacement against its own report, parse the changed specs, and confirm their settings and checks otherwise remain unchanged. Every retained tested commit must remain reachable through a published keeper or the archival tag.

**Queue:** pin the development copies now. Do not edit copies beneath `/home/expert/Documents/contracting/Andria/paleo-RF` while the queue uses that checkout. Reconcile those executable copies after the queue before deleting branches they still name.

The 3 November deletion script’s expected tips are now stale. It should abort unchanged. Refresh its inventory and proofs before producing a replacement; do not merely substitute new tips into the old script.

**3. Repair the merge gate and narrow its claims**

**Problem:** the hook misses some integration paths, and the manual command accepted a comparison of a commit with itself.

The e00a8d0 result has two separate causes:

1. [`check_merge_evidence.R:85–86`](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/tools/check_merge_evidence.R:85) sets the candidate to supplied `HEAD`, while its omitted base also defaults to `HEAD`. The resulting self-comparison prints “no code changes”.
2. Completing a conflicted merge with a separate commit invokes `pre-commit`, not `pre-merge-commit`. Only the latter was installed. This behavior is documented by [Git](https://git-scm.com/docs/githooks#_pre_merge_commit).

The later [CV merge report](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/docs/cc/verification/2026-11-03_cv-merge-feature_report.md:4) verifies the actual merge SHA, `e00a8d06f116b18ce074ca66aebfd903534edab6`. Commit `55d8f5b` adds that evidence without changing code. Preserve that history.

Make these small changes:

- In `tools/check_merge_evidence.R`, retain argument-free `check` for hooks: staged tree against current `HEAD`.
- Require **both arguments** for manual use:

  ```text
  check <candidate> <base>
  ```

  Make `check HEAD`, unknown revisions, identical candidate/base objects and Git errors fail clearly. Requiring the base avoids another misleading default when the candidate is a documentation-only report commit.
- Extend `install_hook()` to install `pre-commit` as well as `pre-merge-commit`, sharing the existing code comparison.
- Initially apply the new direct-commit guard to `feature/single-config`. Preserve Andria’s recorded direct-review exception on C until it is explicitly ended.
- A missing checker must fail on a branch configured as guarded. Ordinary historical topic branches may remain outside the guard. Keep branch selection in one place and preserve unrelated hooks, including Git LFS’s `pre-push`.
- Continue normal integration with `--no-ff`.

Fast-forwards create no commit, so these hooks cannot guard them automatically. If one is exceptionally permitted, check the entire proposed update first:

```bash
Rscript tools/check_merge_evidence.R check "$candidate" "$destination_before"
git merge --ff-only "$candidate"
```

Require ancestry and an unchanged destination between those commands. State the limitation explicitly; Git documents why `--no-commit` cannot stop a fast-forward. [Git merge documentation](https://git-scm.com/docs/git-merge)

For conflicts affecting code, prepare the combined result on a topic, commit it, verify that SHA, commit its report, then integrate. If integration changes the tested code, repeat verification on the new combined result.

The correctly scoped historical audit is:

```bash
Rscript tools/check_merge_evidence.R check \
  55d8f5b1544e60b4523e08bd8051fa918726508a \
  96b820577e6b882248dc6597d850f7781425ddca
```

It is expected to find the later PASS report; it was not run here.

Replace the universal-enforcement claims in `CONTRIBUTING.md`, `docs/cc/verification/README.md` and the checker’s header with:

> Every code change requires verification at its exact commit before integration. Installed hooks check automatic merge commits and commits on configured guarded branches. Fast-forward updates, branches outside those guards, and `--no-verify` are outside that protection. Normal integration uses `--no-ff`. A matching report establishes code identity; review must still establish adequate checks and completed independent review.

**Check:** extend `tests/test_check_merge_evidence.R` using its existing temporary Git fixture:

| Case | Required result |
|---|---|
| `check HEAD`; invalid or identical revisions | Error |
| Explicit range containing unverified code, including a report-only tip | Refuse |
| PASS covering the exact candidate code | Accept |
| FAIL or stale-code report | Refuse |
| Automatic merge | Existing acceptance/refusal preserved |
| Conflict completed by `git commit` on F | Check the staged combined code |
| Direct code commit on F | Refuse without matching evidence |
| Documentation commit; ordinary topic code commit | Allow |
| Fast-forward | Demonstrate hook bypass; explicit range check still works |
| Missing checker on guarded branch | Refuse |

Verify through `tools/verify_change.R` with a pinned `2026-11-04_merge-gate.R` spec running the test file and parse checks. Obtain one independent `change-reviewer`.

**Queue:** implementation and verification can happen elsewhere now. Install only after review and integration; hooks are shared across worktrees. Do not edit the queue’s verifier.

**4. Make small run records committable**

**Problem:** `output/` excludes the parent directory, defeating later exceptions, while `runs/` still implements the superseded official-runs-only policy.

Use the existing repository homes:

```text
output/retained/<exact-attempt>/calibration/<table>
output/retained/<exact-attempt>/forcing/<table>
output/retained/<exact-attempt>/cross_validation/<table>
runs/retained/<exact-attempt>/<script>/<original-manifest-name>.md
runs/retained/<exact-attempt>/config_used.R
runs/retained/<exact-attempt>/SEEDED.txt
```

Keep `SEEDED.txt` only when present. Preserve attempt suffixes such as `-2`; do not overwrite earlier attempts or rewrite manifest contents.

Replace **both** `output/` exclusions and the old `runs/` block with the following. Remove the superseded forcing exceptions elsewhere so there is one clear block:

```gitignore
/output/**
!/output/forcing/
!/output/forcing/*.csv
!/output/retained/
!/output/retained/**/
!/output/retained/*/calibration/AIC_table.csv
!/output/retained/*/calibration/calibration_model_stats.csv
!/output/retained/*/forcing/forcing_by_month_latitude.csv
!/output/retained/*/forcing/forcing_by_period.csv
!/output/retained/*/forcing/forcing_by_period_egu2024recipe_vs_slide.csv
!/output/retained/*/forcing/forcing_by_period_variant_sensitivity.csv
!/output/retained/*/forcing/modern_ipcc_ar6_erf.csv
!/output/retained/*/cross_validation/feasibility.csv
!/output/retained/*/cross_validation/directions.csv
!/output/retained/*/cross_validation/target.csv
!/output/retained/*/cross_validation/comparison.csv
!/output/retained/*/cross_validation/inrange.csv
!/output/retained/*/cross_validation/record_holdouts.txt

/runs/**
!/runs/retained/
!/runs/retained/**/
!/runs/retained/**/*.md
!/runs/retained/*/config_used.R
!/runs/retained/*/SEEDED.txt
```

Keep `.rundirs/` ignored. Git requires excluded parent directories to be reopened before file exceptions can work. [Git ignore documentation](https://git-scm.com/docs/gitignore)

These are the exact six tables from each completed full pipeline. Sizes are **bytes**:

| Path relative to `output/` | Run 1 | Run 2 | Run 3 | Run 8 |
|---|---:|---:|---:|---:|
| `calibration/calibration_model_stats.csv` | 443 | 443 | 443 | 440 |
| `forcing/forcing_by_month_latitude.csv` | 259,662 | 259,957 | 259,386 | 259,180 |
| `forcing/forcing_by_period.csv` | 1,615 | 1,617 | 1,613 | 1,613 |
| `forcing/forcing_by_period_egu2024recipe_vs_slide.csv` | 459 | 465 | 457 | 456 |
| `forcing/forcing_by_period_variant_sensitivity.csv` | 4,563 | 4,576 | 4,556 | 4,548 |
| `forcing/modern_ipcc_ar6_erf.csv` | 345 | 345 | 345 | 345 |
| Ten manifests, total | 191,764 | 196,564 | 192,496 | 194,443 |
| `config_used.R` | 1,880 | 1,893 | 1,881 | 1,886 |
| `SEEDED.txt` | 11,112 | 11,112 | 11,112 | 11,112 |
| **Total retained pipeline records** | **471,843** | **476,972** | **472,289** | **474,023** |

The ten manifest directories are:

```text
1_veg_lct_prep
2_calibration_lct_bluesky
3_plot_cal_lct_albedo
5_calibration_eval
6_prediction_model
7_plot_preds
7a_alb_diff_full
8_radiative
9_forcing_barplot
10_forcing_breakdown
```

Their source run folders beneath `paleo-RF-verify/` are:

```text
d5d5df5/.rundirs/run1-main
8e3f3a4/.rundirs/run2-snowfree-2
7850d46/.rundirs/run3-any75
795792f/.rundirs/run8-raster
```

**Also retain the fitting parts.** The full pipeline copies their fitted models, but does not collect their AIC tables or fitting manifests. For each successful fitting attempt, commit `output/calibration/AIC_table.csv`, the three manifests for scripts 1, 2 and 4, and `config_used.R`.

| Run | Fitting attempts, in order | AIC file sizes, in the same order |
|---|---|---|
| 1 | `run1-main-fit-{jan-mar,apr-jun,jul-sep,oct-dec}` | 194, 210, 210, 194 B |
| 2 | `run2-snowfree-fit-{jan-apr,may-aug,sep-dec-2}` | 252, 272, 264 B |
| 3 | `run3-any75-fit-{jan-apr-2,may-aug-2,sep-dec}` | 256, 272, 256 B |
| 8 | `run8-raster-fit-{jan-apr-2,may-aug-2,sep-dec-2}` | 240, 271, 254 B |

Do not combine or regenerate these tables during preservation.

| Run | Fitting manifests: count / bytes | All fitting records | Pipeline plus fitting records |
|---|---:|---:|---:|
| 1 | 12 / 245,332 | 253,504 B | 725,347 B |
| 2 | 9 / 209,831 | 216,257 B | 693,229 B |
| 3 | 9 / 207,688 | 214,090 B | 686,379 B |
| 8 | 9 / 216,549 | 222,951 B | 696,974 B |

Apply the same list to runs 4–7 when they finish; their final sizes are not yet known.

For retained CV holdout construction, include the existing tables too. `cv-holdouts-11` contains `feasibility.csv` **1,547 B**, `directions.csv` **221 B**, `target.csv` **6,157 B**, `comparison.csv` **3,315 B**, `inrange.csv` **739 B**, and `record_holdouts.txt` **478 B**. With its two manifests, config and seed inventory, its small bundle is **47,859 B**. Preserve the `cv-holdouts-7` comparison baseline separately. These records do not represent a completed full CV experiment.

Specs and verification reports remain under `docs/cc/verification/`. Add one living location index, `docs/cc/results_locations.md`, recording attempt, full SHA, status, spec/report, fitting dependencies, original path and archive path.

**Check:** use `git check-ignore -v --no-index` and explicit `git add --dry-run` paths to establish that the listed files are addable, while neighbouring `.RDS` files and logs remain ignored. Compare copied files byte-for-byte with their sources. Stage named files without `-f`.

**Queue:** the ignore correction and copies of completed immutable records can be committed now. Wait for each unfinished run before collecting its records. Moving or deleting source folders waits for step 6.

**5. Add the housekeeping skill**

**Problem:** finished work accumulates because task closeout does not consistently prove publication, retention and safe removal.

Keep one tracked source at `docs/cc/skills/housekeeping/SKILL.md`. Existing `.claude/` skills are locally excluded; another local-only copy would recreate the documentation problem.

Add this instruction to `AGENTS.md`:

> At task close and session end, follow `docs/cc/skills/housekeeping/SKILL.md`.

Full proposed text:

```markdown
---
name: paleo-rf-housekeeping
description: Close finished paleo-RF work and preserve its evidence at task close and session end.
---

Read CONTRIBUTING.md and the current queue and retained-run records.
Use the integration branch named there. Respect read-only instructions:
in a read-only session, report findings without changing anything.

1. For completed tasks, finish the required review and verification,
   update the changelog, commit the evidence, then integrate with --no-ff.
   Put new questions in the current registers; preserve frozen records.
   Keep unfinished work identified rather than declaring it complete.

2. Refresh the branch, worktree and run inventory. Push finished work
   and verify the live remote tips. Cached origin refs are not proof
   of publication.

3. Remove only explicit, authorized redundant branch names. Their
   current tips must remain reachable through published keepers after
   deletion. Check worktree occupancy, verification specs and active
   or queued launchers for branch and path dependencies. Preserve every
   retained run's code through a published reference.

4. Protect remote deletions with the reviewed expected tips. If a tip
   changed or remote checks fail, skip the deletion and report why.
   Do not silently replace an old expected tip. git branch -d alone
   does not prove integration into the keeper.

5. Before removing a worktree, check active and pending consumers and
   its tracked, untracked and ignored contents. Preserve kept results,
   verify their copies, and commit the small records and location index.
   Push and verify those retention commits before removing the source.
   Use git worktree remove on explicit paths, without forced removal.

Never switch a checkout a run reads or edit its executing tools/specs.
Never delete protected or occupied branches, discard unmerged work,
or treat ignored results as disposable.

Report what was integrated, published and removed; what remains and
why; where results are retained; and any failed checks.
```

**Check:** review it against the current cases: integrated CV, `refit-runs` ahead by one commit, occupied worktrees, symbolic specs in the main checkout, and stale deletion-script tips. It must preserve dependencies and refuse stale cleanup assumptions. No new cleanup framework is needed.

**Queue:** add the skill now. Its preservation rules postpone unsafe cleanup.

**6. After the queue, preserve results, remove obsolete worktrees and simplify verifier naming**

**Problem:** retained results live inside disposable code checkouts, and SHA-only worktree naming has forced documentation-only commits merely to separate concurrent runs.

Use this copy–verify–update–remove checklist:

1. **Confirm all producers and consumers have finished**, including queued jobs and comparisons. Keep explicitly retained interrupted attempts under their original attempt names.
2. Complete `docs/cc/results_locations.md` before moving anything.
3. Copy each entire retained run folder to:

   ```text
   /home/expert/Documents/contracting/Andria/paleo-RF-results/<exact-attempt>/
   ```

   Refuse an existing destination until its identity is understood. For each fresh destination:

   ```bash
   rsync -a -- "$source/" "$destination/"
   rsync -acn --delete --itemize-changes -- "$source/" "$destination/"
   ```

   The second command is a dry run and must show no differences.
4. Compare relative file inventories, file types, sizes and checksums. Inspect symlinks separately: preserve their required targets or record the retained external input location and inventory. `du` alone is insufficient.
5. Finish committing and publishing the small records and location index from step 4. Preserve original reports, manifests and `config_used.R` contents.
6. Update current comparison readers and future rerun specs to use the archive. In particular, account for:
   - `2026-10-19_headline-partial-ice_check.R`, which reads `4ba4d2a`, `2bd4ab5` and `4672560`.
   - CV comparisons reading run 1 and `11356e0/.rundirs/cv-holdouts-7`.

   Historical reports retain their original paths; the index records the translation. Reruns needing changed paths get dated specs. Do not remove a source still needed by an unmigrated consumer.
7. Remove only the reviewed worktrees:

   ```bash
   git worktree remove <explicit-path>
   ```

   Do not use bulk `rm`, forced removal, or `worktree prune` as a substitute for preservation. Git distinguishes removal of working copies from pruning stale administrative records. [Git worktree documentation](https://git-scm.com/docs/git-worktree)

The current inventory is **127 worktrees**, including **118 detached verification worktrees**. Refresh it again after the queue.

| Worktree/group | Removal condition |
|---|---|
| `archive`, `benchmark`, `cleanups`, `organisation`, `cv` | Integrated; removable after fresh content and consumer checks. |
| `runs` | First integrate `facf73c` and any later queue records. It is currently one commit ahead of F. |
| `questions` | Keep while Andria’s separate C review checkout is needed. |
| Main checkout and `feature` | Keep. The main checkout remains the frozen-input source. |
| Refit and fitting worktrees | Remove after every retained attempt and dependency is preserved. |
| CV and historical comparison worktrees | Preserve referenced outputs and migrate consumers first. |
| `52a6237` | Preserve evidence and verify the published archival tag first. |
| The review’s 66 other verification candidates | Recheck individually; remove only after retained evidence and ignored contents are accounted for. |

The nine verification directories added since the review are:

```text
31ac4d7 58bd502 7850d46 7e6f30c 84b8689
c2ccdb1 e00a8d0 f0c2536 fce14d1
```

They need the same checks; the November 3 inventory is not a deletion list.

**Change verifier naming after the queue.** Yes: use the commit **and the existing spec name**:

```text
../paleo-RF-verify/<sha7>-<spec-name>/
```

In `tools/verify_change.R`, change `make_worktree(main, sha)` to accept `spec$name`, and include it in the directory name. Keep the full-SHA identity check, clean-worktree check and refusal to reuse an existing run folder. Do not rename old worktrees or rewrite old reports.

Update `tests/test_verify_change.R` and the verification README. Test that:

- Two different names at the same commit receive separate worktrees.
- Repeating the same attempt refuses reuse.
- A wrong-commit or dirty existing directory still fails.
- Reports contain the actual commit and new location.

Verify through a new pinned spec and one independent `change-reviewer`. No scientific calculation changes.

The updated tool can be adopted without switching the main checkout: after the queue, keep the launcher’s working directory there but invoke the reviewed verifier and spec by absolute path in the development checkout. The verifier uses its working directory for the input root. Keep that selected tool and spec unchanged for the duration of each job.

**What Chris must decide**

The integration destination, per-run small records, external results folder and deletion of proven redundant branches are already decided.

The remaining choices are:

- **Migration completion:** which remaining work belongs to the migration’s final review and full-run gate, rather than subsequent scientific experiments.
- **Andria’s direct-review exception:** when it ends, so the direct-commit guard can also apply to `chris-dev`.
- **Historical retention:** which additional old verification outputs may be discarded beyond the explicitly retained runs and comparison evidence. Keep uncertain cases meanwhile; archive the annotation branch before retiring it if its teaching material is still wanted.