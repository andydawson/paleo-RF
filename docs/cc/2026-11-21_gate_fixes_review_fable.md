# Review of the integration-review fixes (Fable, change-reviewer), 21 November 2026

Reviewed: commits `9f7ddfb`, `dc764cc` and `5cadb41` on branch `gate-fixes`, in `/home/expert/Documents/contracting/Andria/paleo-RF-wt/gate-fixes`, against the trunk at `9c8dea1` and the three fixes Chris approved from Astra's integration review (`docs/cc/2026-11-20_integration_review_codex_gpt6astra.md`). Read-only; nothing was run. Chris's choices on the two optional points are at the end.

**Verdict.** Mergeable as is: every deletion is dead, the comment-check fix is correct, the README sentence matches the code, and nothing beyond the three approved items crept in. No blockers. One record is to be written with the merge, and two small optional points need Chris's choice.

Paths below are in `/home/expert/Documents/contracting/Andria/paleo-RF-wt/gate-fixes` unless given in full.

## 1. Useful further deletion (one, orphaned by this change)

- **What:** the `panel` column in `scripts/9_forcing_barplot.R` is now read by nothing. It is made at lines 260, 266 and 394, and described at lines 256-257 ("and which panel").
- **Why it is orphaned:** its only reader was the deleted `forcing_panels$panel` (trunk line 270). `panel_plot()` reads `label`, `value`, `sign` and `striplab` only.
- **Effect:** no output is affected; a reader sees a column made for nothing.
- **Cost:** removes about one line and shortens three.
- **Catch:** it is a code change, so the merge check would want a new PASS report for the new code. Script 9 alone ran in 0.7 min in the tail verification.

## 2. Defects

No code defects. Three record or comment points, worst first:

| Severity | File:line | What is wrong | Consequence | Evidence | Check | Lines |
|---|---|---|---|---|---|---|
| should-fix (record, with the merge) | `docs/cc/changelog_single_config_migration.md` | No entry for these three fixes. | The change log for coauthors would lack them. | Search of the changelog finds no entry; Astra's line estimates included one. | The entry cites the two PASS reports and the FAIL with its reason. | Adds documentation lines only. |
| nit (record) | commit 9f7ddfb, last paragraph | It says script 4 was checked "against the gate run's fits". That comparison is the one that failed. What passed is the January column of the AIC table against the anchored table. | A change log built from commit history would cite evidence that does not exist. | `docs/cc/verification/2026-11-20_gate-fixes-script4_report.md` (FAIL) and `2026-11-21_gate-fixes-script4-2_report.md` (PASS). | State the real evidence in the changelog entry rather than rewriting history. | None in code. |
| nit (comment, outside the approved items) | `R/run_manifest.R:4-8` | The file header still makes the promise the README just dropped: a record "the moment it starts", so a failed or killed run "still leaves its record". | A reader of the header gets the batch-only account. The right account is in the same file at lines 33-39 and 67-69. | Lines 70 and 232 defer the record in an interactive session; lines 77-85 install the error handler for batch runs only. | Comment-only edit, provable with `tools/check_comments_only.R`. | About +1. |

### What I confirmed about the comment check (`tools/check_comments_only.R:26-31`)

- **A failed comparison stops clearly.** The message is "git could not compare with <base>", and git's own "fatal: ..." line still reaches the console because stderr is not captured. Under `Rscript` the exit status is 1, as the commit message says and as the tool's header ("1 otherwise") already promised.
- **No changes still passes without stopping.** A successful `git diff` with no differences returns an empty result with no status attribute, so the function returns no files.
- **The stop cannot fire on a normal comparison.** `git diff --name-only` exits 0 whether or not files differ (no `--exit-code` or `--quiet`), and R sets the status attribute only for a non-zero exit.
- **The warning suppression hides nothing that matters.** It hides only R's "had status N" warning, which the stop replaces. It is the same idiom as the existing call at line 37.
- **The test would fail without the fix.** On the trunk the unknown base returns TRUE, so `identical(bad_base, 'error')` is false. If the stop fired wrongly, the three earlier calls in the test would error uncaught.
- **No other caller.** Only `check_comments_only()` calls `changed_r_files()`.

### What I confirmed about the README (`README.md:361-368`)

- **Batch runs:** `run_begin()` writes the record at once.
- **Interactive sessions:** `run$deferred` holds the record back until `write_output()` or `run_finish()` (`R/run_manifest.R:70, 119, 140, 232`), and errors are left to the session (lines 77-85).
- **Tests agree:** `tests/test_run_manifest.R:82-90` tests exactly this behaviour.

### What I confirmed about each deletion being dead

- **Script 4** (`alb_prod`, `cal_data2`, `cal_data3`, `AIC_list`):
  - No reader in `scripts/`, `R/`, `tools/`, `tests/`, `configs/` or `config.R`.
  - Script 7 defines and uses its own `alb_prod`.
  - No `ls()`, `mget`, `save()`, `save.image` or `load()` in `scripts/` or `R/`; the `get()` calls there read data columns, a device name and the random seed.
  - The saved fits cannot carry these objects: formulas are attached to the global environment (`R/model_registry.R:125`), which R saves by reference, not by content.
- **Script 7a** (eight columns and `ice_rows`):
  - No R file names any of them.
  - The output table takes nine named columns plus what `pair_albedo_differences()` returns.
  - That function reads only `ice_frac`, `alb_veg`, `ice_albedo_fixed` and `ice_albedo_sc`, plus `alb_ice_thresh` and `alb_icesc_thresh` in the legacy method (`R/differences.R:47-103, 143-157`).
  - `alb_grid_full` is never saved.
  - The reworded comment at line 130 is accurate.
- **Script 9** (`forcing_panels`):
  - No reader.
  - The new limits use the same numbers: the bound table's `value` was the two tables' values stacked.
- **`R/paths.R`** (`'boundaries'`):
  - No `path_file(..., 'boundaries')` anywhere; every caller asks for `'boundaries_ll'`.
  - `tests/test_paths.R` checks that catalogued files are in the frozen inventory, not the reverse, so it still holds.
  - Only `archive/8_plot_preds.R` reads `pbs.RDS`, by a literal path.
- **Comments around the deletions** still describe the code, except the "which panel" phrase in section 1.

### Commit messages

- dc764cc and 5cadb41 match their diffs.
- 9f7ddfb matches its diff except for the evidence sentence in the table above.

## 3. Does the verification cover each changed line

All runs used the legacy configuration at 5cadb41.

| Changed file | Executed? | Output compared? |
|---|---|---|
| `scripts/4_calibration_model.R` | Yes, the whole script for January (17 outputs, exit 0). Every deletion site is top-level or inside the month loop. | January AIC column equals the anchor for all eight models, to whole AIC units. The fits themselves were not compared. |
| `scripts/7a_alb_diff_full.R` | Yes, in full. | `ALB_diffs_bluesky.RDS` is byte-identical. |
| `scripts/9_forcing_barplot.R:293` | Yes; the line is unconditional. | Four tables byte-identical; the figure is covered by run-record md5s (below). |
| `R/paths.R` | Loaded by every script run. | `tests/test_paths.R` passed. |
| `tools/check_comments_only.R` and its test | The test passed at 5cadb41. | Not applicable. |
| `README.md` | Not executable. | Checked by reading. |

- **Script 4's first attempt.** It stopped at its file-name filter before comparing any file (`/home/expert/Documents/contracting/Andria/paleo-RF-verify/5cadb41/.rundirs/gate-fixes-script4/checks.log`: "all(grepl("_jan_", files)) is not TRUE"). So neither report shows the statement in the second spec that saved fits differ byte for byte while equal in content.
- **Script 7a under the default method.** The default method reads a subset of the columns the legacy method reads, so the legacy run also covers the default for a missing column.
- **Script 9, paths reached.** The recipe-computed branch (its table was written and matched), the all-twelve-months branch and the legacy subtitle.
- **Script 9, paths not reached.** The two "recipe skipped" messages, the default-method subtitle and the partial-months note. None touches the changed line.
- **Script 9, the figure.** It is not in the anchors, but the run records carry its md5.
  - `forcing_barplot_slide18.png` is `619c4305724211bbd0bbbd3ef02d5411` in the gate-fixes run.
  - It is the same in two legacy runs of the code before the change: `/home/expert/Documents/contracting/Andria/paleo-RF-verify/6c86770/.rundirs/gate-legacy-tail/runs/9_forcing_barplot/20261120T192800.379Z_3011730.md` and `/home/expert/Documents/contracting/Andria/paleo-RF-verify/4e8532c/.rundirs/ice-maps-legacy/runs/9_forcing_barplot/20261120T114718.676Z_2725896.md`.
  - The recipe PNG also matches (`320b741c...`).
  - The PDFs differ between every pair of runs, including the two older ones, so that is not this change.
  - I also looked at the PNG: both panels share one axis, about -1.2 to 2.3.
- **Default `config.R`.** No run of these commits used it.

## 4. Architectural fit and line cost

- **Size:** +13 / -36 over 7 files, net -23, matching the diff statistics.
- **Additions:** the only new behaviour is the approved stop in the comment check, with one test line.
- **Nothing else added:** no new option, configuration key, file, dependency or wrapper. The tool already needed git.
- **Scripts** remain flat and steppable.
- **Atomic commits:** each of the three commits is one change.
- **Lines the change could lose:** none worth naming.

## 5. Not worth doing

- **README precision.** "Saves an output" means a file saved through `write_output()`; figures saved with `ggsave` do not start the record. A configuration file that fails to load is recorded as failed even in RStudio (`R/run_manifest.R:54-59`). Both are edge details that would lengthen a paragraph now right in the main.
- **README line 368** is not rewrapped.
- **Test noise.** The test prints git's "fatal: bad revision" line on a passing run. Silencing it would hide the cause from a real user.
- **A test for "no files changed returns nothing".** It is plainly right by reading.
- **A default-configuration rerun of script 7a** (75.9 min measured), given the subset argument above.
- **Rewriting commit 9f7ddfb.** Correct the evidence in the changelog instead.
- **Spec date in the script 4 PASS report.** It names its spec with the 20 November date; the committed copy is dated 21 November. The merge check does not read that line.
- **Before this change, not caused by it.** `panel_plot()` takes a `striplab` argument (`scripts/9_forcing_barplot.R:274`) that is never consulted, because the data column of the same name wins. Leave it for a later pass over script 9.

## Questions for Chris

1. **The unread `panel` column in script 9.** Remove it now, remove it with the next change to script 9, or leave it? Removing it now needs a new script 9 verification before the merge. Meanwhile the code makes the column and nothing reads it.
2. **The header of `R/run_manifest.R` (lines 4-8).** Reword it to match the corrected README, comment only, or leave it? Meanwhile the header gives the batch-only account and the function comment thirty lines below gives the right one.

## 6. Limits

- I ran nothing. Everything is from reading code, reports, run records and one figure.
- The two PNG matches are against the code at 6c86770 and 4e8532c, not the trunk at 9c8dea1. I could not confirm with git that script 9 is unchanged between them and the trunk.
- The commit message's claim that all earlier uses of the comment check compared real files: I confirmed only the one cited (the changelog's "two R files changed" on 20 November).
- The explanation that beta-family fits are not byte-stable is the implementer's; I did not verify it.
- I did not check the GitHub issue, or whether anything here touches a question open with Andria. I saw nothing in the diff that does.

**merge as is**

---

**Chris's choices (21 November 2026).** Remove the `panel` column now (done in `65bb2a4`) and reword the header of `R/run_manifest.R` (done in `ee42e9a`, comment only). Merge after both are checked. The main session confirmed with git that script 9, and all code under `scripts/`, `R/`, `config.R` and `configs/`, is unchanged between `6c86770` and `9c8dea1`, and script 9 between `4e8532c` and `9c8dea1`, so the two PNG matches above hold for the trunk code.
