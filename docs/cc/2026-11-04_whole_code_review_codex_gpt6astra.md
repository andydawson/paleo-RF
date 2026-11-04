*Astra (gpt-6-astra, ultra effort), 4 November 2026: whole-code review after the cross-validation merge (code-review skill). Brief: `2026-11-04_whole_code_review_brief.md`. Absolute paths are this workstation's.*

**Verdict:** substantially clearer than `legacy`, but not ready for hand-over unchanged. The recent extractions, shared plotting code and archive move improve the working pipeline. Most cross-validation code serves agreed scientific requirements; it needs targeted fixes, not a wholesale rewrite.

Source has grown **1,140 lines, or 8.3%, since 1 November**. Cross-validation accounts for **885 lines including tests**, plus **25 added registry lines**. The 18 archived scripts retain **3,531 unchanged lines**: relocation is not deletion.

The most consequential new findings are that scoring can accept predictions from obsolete holdouts, and an allowed age subset can put a long forcing interval under a short period label. Existing problems remain in verification retention, conflicting instructions and unnecessarily restrictive reuse rules.

I reviewed the clean worktree at **55d8f5b**. Nothing changed; no R, tests or pipeline scripts ran. Checks below are recommendations.

| Source count | `legacy` | 1 November | Now |
|---|---:|---:|---:|
| Total, including blanks and archive | 10,305 | 13,809 | **14,949** |
| Code | 4,285 | 8,447 | **9,166** |
| Full-line comments | 4,117 | 3,430 | **3,771** |
| Active source, excluding archive | 6,774 | 10,278 | **11,418** |

The following findings concern maintained code and operating practice, ranked by consequence. Savings are estimates of physical lines. Every proposed code change should use `tools/verify_change.R`; scientific arithmetic still needs the prescribed independent reviews.

1. **Do now — bind cross-validation predictions to the holdouts that produced them.**

   [tools/cross_validate_albedo.R:179](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/tools/cross_validate_albedo.R:179) overwrites the holdout object. The check at line 62 compares only the calibration-table checksum; scoring at line 300 accepts prediction files by filename and candidate counts.

   Consequently, rebuilding holdouts after changing historical ages, the latitude window or holdout construction can combine old predictions with new targets without stopping. This can change the selected model.

   Save the holdout checksum and fitting-code identity with each prediction file, and check them before scoring. Keep a separate record for each fitted month: line 263 currently overwrites the same record across month invocations. Also include executing tools in [R/run_manifest.R:293](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/R/run_manifest.R:293), whose dirty-code check currently omits them.

   **Lines saved:** none; modest addition. **Size:** medium. **Anchor risk:** none to legacy outputs; low for valid cross-validation results. **Check:** unchanged scores for matching files; rejection after replacing holdouts while keeping calibration unchanged; separate month records survive; an edited tool is recorded as dirty.

2. **Do now — reject slice pairs crossing reporting-period boundaries.**

   [R/forcing_periods.R:29](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/R/forcing_periods.R:29) calculates both endpoints but assigns the period using only the younger endpoint. The configuration explicitly permits wider gaps and does not check their compatibility with reporting periods.

   For example, `analysis$ages = c(50, 10000, 11500)` passes the configuration checks, yet the 50-to-10,000 BP change is assigned to “0.05–0.5 ka”.

   Reject pairs that cross an internal reporting boundary. This requires validation, not a new interpolation method. Preserve the documented oldest-slice convention.

   **Lines saved:** none; approximately 5–10 added. **Size:** small. **Anchor risk:** low for a rejection-only change. **Check:** reject the crossing example; accept ordinary pairs; reproduce current and legacy forcing tables unchanged.

3. **Do now — preserve executable verification evidence before housekeeping.**

   [The script-1 “before” specification:4](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/docs/cc/verification/2026-10-15_i15c-script1-before.R:4) still names a moving branch. **Eighty specifications use 33 distinct symbolic commit values.** [The abandoned model-comparison specification:6](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/docs/cc/verification/2026-10-15_spatial-ml.R:6) names a deleted branch; its tested commit has no containing branch or tag.

   Pin specifications to the full commits recorded in their reports. Preserve the abandoned experiment through a published archival reference. Do not substitute today’s branch tips.

   Housekeeping remains unfinished: **88 local branches, 77 cached remote branches and 127 worktrees**, including 118 detached verification worktrees. Preserve required results, logs, configurations and input dependencies before retiring any worktree. The intended separate results directory remains absent.

   **Lines saved:** zero. **Size:** medium. **Anchor risk:** none to arithmetic; careless cleanup could lose evidence. **Check:** every specification resolves to its report’s tested code; retained results have verified copies; no active or queued consumer loses a dependency.

4. **Do now — reconcile the instructions and question registers.**

   [AGENTS.md:15](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/AGENTS.md:15) still points to the scientific-question file that the trunk has superseded. The trunk and feature branch also disagree about workflow requirements.

   There are **72 trunk-only and 552 feature-only commits**. The long-lived feature branch is an authorised migration arrangement; the unresolved documentation split is the problem. Different checkouts direct contributors to different rules and question lists.

   Bring the trunk into the feature branch under the recorded integration procedure, reconcile both sets of valid instructions, and identify one current question register.

   **Lines saved:** none necessarily. **Size:** medium. **Anchor risk:** none for documentation reconciliation alone. **Check:** preserve all current questions, answers and requirements; verify every pointer.

5. **Do now, before final integration — make the verification and retention promises accurate.**

   [CONTRIBUTING.md:41](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/CONTRIBUTING.md:41) overstates the merge gate. [tools/check_merge_evidence.R:68](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/tools/check_merge_evidence.R:68) allows integration when the checker is absent, as it still is on the trunk. The hook also does not cover every integration route.

   Keep its useful comparison of verified and merged code. Document its actual coverage and check the routes used for final integration.

   Separately, [.gitignore:31](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/.gitignore:31) excludes `output/`, defeating the later exceptions intended to retain small forcing tables. Correct that allowlist.

   **Lines saved:** approximately 1–3 in ignore rules; none guaranteed elsewhere. **Size:** medium. **Anchor risk:** none directly. **Check:** targeted Git integration cases and representative retained-table versus ignored-bulk-output paths.

6. **Do now — finish protecting interactive plotting.**

   [R/paths.R:118](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/R/paths.R:118) replaces the default graphics device whenever a separate run directory is used. `run_begin()` calls this before its interactive-session guard.

   Thus an isolated RStudio run can send plots to PDF despite the promise that the screen device remains unchanged. This is particularly relevant to Andria stepping through scripts.

   Move graphics redirection into the batch-only part of `run_begin()`.

   **Lines saved:** approximately 0–3. **Size:** small. **Anchor risk:** low. **Check:** interactive redirected runs preserve the graphics option; batch runs still write their own `Rplots.pdf`; numerical products remain unchanged.

7. **Do now — complete the cross-validation method record and state what remains unfinished.**

   [The geographic-sensitivity design:181](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/docs/cc/2026-11-03_cv_geographic_sensitivity_design_codex_gpt6astra.md:181) records an unpassed reference audit. Its instruction to carry references and adaptations into the protocol and changelog remains unfinished: [the changelog entry:1638](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/docs/cc/changelog_single_config_migration.md:1638) supplies neither full references nor DOIs.

   The designs contain supporting passages and distinguish project judgements. This is an incomplete required record, not evidence that the method has no precedent.

   Also mark the downstream selected-model comparison as unfinished. [The northeast plotting tool:63](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/tools/plotting/plot_northeast_cover_and_location.R:63) correctly requires model 8 for its particular location-term comparison. Removing that guard would invalidate its interpretation; it does not yet implement the protocol’s selected-model comparison.

   **Lines saved:** none. **Size:** small documentation work; subsequent comparison work is medium. **Anchor risk:** none. **Check:** complete the recorded reference audit and trace each claimed supported method and implemented stage.

8. **At hand-over — simplify valid reuse of upstream products.**

   [R/run_manifest.R:160](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/R/run_manifest.R:160) consults only the latest producer record and compares the entire analysis configuration.

   Changing reporting latitude bands can therefore invalidate preparation and models. A later partial producer run can also obscure an otherwise valid earlier product. This is the largest unnecessary operating burden.

   When the policy change is agreed, use short explicit lists of relevant settings, including upstream choices, and identify the record that actually produced the file. Keep checksums. Avoid automatic dependency inference.

   **Lines saved:** none necessarily. **Size:** medium to large. **Anchor risk:** medium: incomplete dependencies would allow invalid reuse. **Check:** reporting-only changes permit reuse; changes to albedo, elevation, model settings and other relevant inputs reject it.

9. **At hand-over — remove artificial dependencies from routine production.**

   [scripts/5_calibration_eval.R:53](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/scripts/5_calibration_eval.R:53) copies script 4’s prediction fit into another product that script 6 requires. Let script 4 own one prediction-fit product, so prediction need not wait for evaluation.

   [scripts/9_forcing_barplot.R:362](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/scripts/9_forcing_barplot.R:362) reads historical talk-reproduction inputs before deciding whether that comparison applies; ordinary tables are written afterwards. Missing historical inputs can block otherwise valid reporting.

   Move that reproduction and the optional investigations in script 5 and [script 8:141](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/scripts/8_radiative.R:141) into named diagnostic tools. Preserve scientific expressions, simulation identifiers and historical outputs.

   **Lines saved:** approximately 5–15 deleted; 230–250 moved out of routine scripts. **Size:** medium. **Anchor risk:** medium because product ownership and execution order change. **Check:** identical fitted objects, seeded predictions, forcing tables and extracted diagnostic results; script 6 runs directly after script 4.

10. **At hand-over — share the repeated forcing aggregation.**

    [scripts/9_forcing_barplot.R:164](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/scripts/9_forcing_barplot.R:164), [R/forcing_breakdown.R:40](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/R/forcing_breakdown.R:40) and [the forcing-support plot:65](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/tools/plotting/plot_forcing_vs_training_support.R:65) repeat the period-by-cell-by-month sum; two repeat the monthly mean.

    Put that operation in one small shared function. Keep each report’s final reduction visible and retain script 10’s reconciliation check.

    **Lines saved:** approximately 5–15. **Size:** medium. **Anchor risk:** medium because grouping, missingness and order affect results. **Check:** incomplete-period and missing-month cases, followed by unchanged anchored tables.

11. **Do now — make cross-validation reporting easier to read without compressing the science.**

    [R/cross_validation.R:203](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/R/cross_validation.R:203) nests two `lapply()` calls inside two `do.call(rbind, …)` calls. The operation is straightforward: visit each occupied distance band, then compare each model with model 8 on shared rows.

    Use two plainly named loops or a named per-band function. Keep the shared scoring function. Also replace [the duplicate complete-row predicate:42](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/tools/cross_validate_albedo.R:42) with one predicate shared with the registry.

    **Lines saved:** approximately 2–3 from duplication; clearer loops may add a few. **Size:** small. **Anchor risk:** none to legacy; low to cross-validation reports and selected rows. **Check:** existing hand-worked comparisons, missing-data cases and identical stage tables.

12. **Do now — correct the remaining operating-documentation drift.**

    Concrete examples include:

    - [config.R:23](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/config.R:23), the legacy configuration and script 2 promise that changing months needs no preparation rerun, while the manifest policy rejects that reuse.
    - [config.R:68](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/config.R:68) describes only the old model ladder, despite the newly accepted candidates.
    - [README.md:193](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/README.md:193) retains legacy kernel descriptions where the current settings differ.
    - [R/land_cover_diagnostics.R:32](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/R/land_cover_diagnostics.R:32) says present-day ice caps enter calibration without accounting for script 2’s configured mask; line 128 describes the mean as unconditional.
    - The cross-validation protocol still budgets 24 in-range fits, although its amendment requires 60–72. Its “three functions” description is also obsolete.
    - The README’s current code map retains September line numbers. Removing those numbers is simpler than maintaining them.

    Replace historical assertions with current behaviour and link to the records where history matters. Add cross-validation’s commands and products to the current navigation.

    **Lines saved:** approximately 10–25. **Size:** small. **Anchor risk:** none. **Check:** each statement against its consumer and current settings; comment-only verification for source edits.

13. **At hand-over — make the cheap calibration checker’s target explicit.**

    [tools/check_calibration_month.R:39](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/tools/check_calibration_month.R:39) always compares against historical model 8, while its default paths can contain newer fits and calibration data. Its default fitting function reconstructs the stored model rather than exercising the current registry.

    Make it explicitly a historical reproduction check with explicit inputs, or provide a clearly named current-registry check. A passing result must say what was tested.

    **Lines saved:** approximately zero. **Size:** medium. **Anchor risk:** none to outputs. **Check:** a known historical month, a current-registry comparison and rejection of mismatched inputs.

14. **At hand-over — retire the historical pilot and trim genuine leftovers.**

    [tools/prepare_bluesky_albedo.R:984](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/tools/prepare_bluesky_albedo.R:984) retains the July pilot, including the special route that treats solar zenith as zero. Preserve its historical command and code version, then remove that branch and pilot-only plumbing. Keep production missing-zenith tests and the no-cutoff scientific version.

    Remove the unused panel bookkeeping in [script 9:262](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/scripts/9_forcing_barplot.R:262) and the unused projected-boundary catalogue entry. Share the builder’s duplicated month/version vocabulary only if its provenance continues to identify every source file affecting the product.

    **Lines saved:** approximately 40–60 for the pilot and tests; 3–6 for current-code leftovers. **Size:** medium. **Anchor risk:** low, provided production arithmetic is untouched. **Check:** builder tests, a retained real month, unchanged cell-table schema and values, and continued acceptance of legitimately retained source versions.

15. **At hand-over — put maintenance material behind a short navigation page.**

    [tools/verify_change.R:1](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/tools/verify_change.R:1), frozen-cache management, merge checks and historical diagram generators serve maintainers. Andria should encounter preparation, numbered analysis and diagnostic tools first.

    The 3 November version-control review sensibly revises the earlier suggestion to move all tools: **keep established tool paths and use an index with links**. Avoid a relocation project and forwarding wrappers. Retire repeated setup tutorials and historical narratives in maintained headers while preserving units, signs and scientific rationale.

    **Lines saved:** approximately 40–60 repeated comment lines; relocation itself saves zero. **Size:** small. **Anchor risk:** none for documentation. **Check:** follow the ordinary run instructions without needing worktree, hook or frozen-cache internals.

Andria’s original analysis needs a separate record. These are existing faults, not restyling recommendations:

| Location | Remaining fault | Treatment, risk and check |
|---|---|---|
| [R/differences.R:45](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/R/differences.R:45) | Youngest-pair ice readvance uses a nonexistent younger neighbour; it can error or average incorrect values. | **Leave pending scientific decision.** No line savings. Repair is medium, with scientific-output risk; require an agreed boundary rule, independent review and targeted examples. |
| [R/differences.R:29](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/R/differences.R:29) | The legacy component method deliberately retains documented double-counting and ice-advance faults. | **Leave in the reproduction route.** No savings or cleanup. The current alternative is already separate and tested. |
| [scripts/7_plot_preds.R:268](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/scripts/7_plot_preds.R:268) | `year` is compared with itself, so pages include all ages. | **Leave pending Andria’s answer.** Small eventual fix; no numerical-anchor change expected; compare rendered pages. |
| [scripts/7_plot_preds.R:303](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/scripts/7_plot_preds.R:303) | Coefficient-of-variation map carries standard-deviation labels. | **Leave pending answer.** Small label correction; zero savings; inspect figures. |
| [scripts/7_plot_preds.R:373](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/scripts/7_plot_preds.R:373) | Requested ages and ice-outline ages differ. | **Leave pending answer.** Small code change with intentional changes to two anchored ice tables; review those changes explicitly. |
| [scripts/2_calibration_lct_bluesky.R:266](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/scripts/2_calibration_lct_bluesky.R:266) | Native and coarse albedo axis labels are swapped. | **Leave pending answer.** Small figure correction; zero savings; numerical tables should remain identical. |

**Cross-validation is proportionate overall.** Its implementation is **638 lines: 444 code, 152 comments and 42 blanks**. The two test files add **247 lines**. Selection, feasibility, failed-fit handling, regional reporting and geographic reporting explain most of that size.

Andria can follow the three commands. Understanding or changing the method requires the cover triangle, training range, target weights, holdouts, feasibility, grouping, block resampling and selection rule. Those are scientific concepts required by the approved method. Collapsing 17 small helpers into the protocol’s originally promised three functions would make it harder to follow.

Keep both test files: hand-worked arithmetic and stage wiring test different failures. The historical reshape comparison at [tests/test_cross_validation_stages.R:30](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/tests/test_cross_validation_stages.R:30) can eventually become a smaller permanent contract test, saving roughly 8–12 lines. It is not a priority now.

The saved verification reports support holdout construction and stages using stand-in fits. They do **not** establish a completed real cross-validation result: the fits and scores remain pending.

**The five changes I would make first are:**

1. Bind predictions to their holdouts and retain reliable per-month fitting records.
2. Reject age combinations that cross reporting boundaries.
3. Pin verification specifications and protect otherwise unreferenced tested code.
4. Reconcile the instructions and question registers, including the outstanding cross-validation reference record.
5. Fix interactive graphics redirection and extend dirty-code detection to executing tools.

The earlier reviews stand as follows:

| Earlier review | Still open or partial | Resolved since then |
|---|---|---|
| **14 October readability** | Interactive redirected graphics; whole-configuration/latest-record reuse; provenance of copied inputs; reverse filename lookup; some implicit joins; formula construction still uses expression manipulation; residual evaluation repetition; optional investigations; ambiguous calibration checker; remaining stale comments. | Producer manifests; ordinary configuration loading; local units/sign explanations; named experiment lookup; explicit aggregation/plot inputs; indentation; separate seed calculation; copy/seed-marker faults; stronger anchor verdicts. |
| **15 October simplicity** | Optional investigations, reuse policy and maintenance-workflow separation remain. The recommendation to reorganise tools should now be fulfilled mainly through navigation, following the newer version-control review. | Elevation delivery; portable starting commands; structured anchor results; repeated writes and unused reads reduced; network acquisition removed from script 1; its diagnostic extraction now completed. |
| **1 November drift and conciseness** | Diagnostic provenance; calibration-check target; whole-analysis reuse; obligatory historical reproduction; duplicated period aggregation; duplicated prepared-product vocabulary; dead bookkeeping; inherited plotting faults. Test construction, documentation and repeated explanations are only partly finished: manifest tests still edit configuration text. | Baseline-path protection; honest comparison wording; rejection of empty verification specs; seeded-file lifecycle; May-support labels; northeast diagnostic safeguards; configured older endpoints; selected-month labels; zero-coverage slices; shared diagnostic input preparation; catalogue expansion; shared cell fixture; script-1 extraction and unsupported assertion removal. |
| **1 November simplicity** | All five explicitly deferred recommendations remain wholly or partly open: one prediction-fit product, separate investigations, reuse rules, pilot retirement and maintenance separation. | All four immediate recommendations were implemented: plot reuse, script-1 extraction, one catalogue expansion and simpler test construction. Historical-script separation is also complete. |

The **3 November version-control review’s major findings remain open**, except that cross-validation has now been integrated. Commit messages generally explain purpose and evidence well; related fixes are sometimes bundled, but rewriting history would achieve little. `main` and `legacy` remain untouched. Same-name local and cached remote tips match; live remote publication was not checked. I found no new bulky run products committed since the last review, and the existing large inputs and anchors have documented purposes.

Already as simple as they should be are the flat numbered scripts; ordinary validated configuration lists; separate explicit legacy settings; central model formulas; shared calendar and seed handling; small preparation and differencing functions; path catalogue and accessors; recorded input/output wrappers; script 6’s prediction loop; shared training-support reader; and script 10’s explicit reconciliation.

Keep the MODIS delivery, checksum, publication and worker-failure checks. They protect different demonstrated failures. Keep the verification tool and meaningful scientific tests. Short functions with one caller are justified when they name an operation Andria needs to understand.

A newcomer needs about six operating concepts: repository root and packages, script order, an ordinary R configuration list, the three configuration sections, separate run directories, and automatic producer checks. Catalogue internals, verification worktrees and Git hooks should remain maintenance knowledge.

For the complete per-file inventory below, each value is **total / code / full-line comments**. Blank lines are the difference. “Code” means nonblank lines not starting with `#`; inline comments and Python docstrings therefore count as code. The scope matches the earlier source inventory, with archive moves followed across paths. Documentation, data and verification records are excluded. A dash means absent.

| Pipeline file | `legacy` | 1 November | Now |
|---|---:|---:|---:|
| `scripts/1_veg_lct_prep.R` | 246/79/109 | 253/158/71 | 83/37/29 |
| `scripts/2_calibration_lct_bluesky.R` | 420/207/119 | 279/170/53 | 279/170/53 |
| `scripts/3_plot_cal_lct_albedo.R` | 622/346/151 | 254/153/53 | 254/153/53 |
| `scripts/4_calibration_model.R` | 830/176/573 | 114/56/31 | 114/56/31 |
| `scripts/5_calibration_eval.R` | 1,067/426/500 | 424/300/42 | 401/277/44 |
| `scripts/6_prediction_model.R` | 304/88/160 | 111/66/17 | 111/66/17 |
| `scripts/7_plot_preds.R` | 2,085/700/1,147 | 517/377/36 | 453/310/38 |
| `scripts/7a_alb_diff_full.R` | 853/214/470 | 210/118/28 | 210/118/28 |
| `scripts/8_radiative.R` | 347/129/137 | 179/109/30 | 179/109/30 |
| `scripts/9_forcing_barplot.R` | — | 405/183/192 | 407/187/190 |
| `scripts/10_forcing_breakdown.R` | — | 130/62/55 | 135/64/58 |
| `scripts/make_grid.R` | — | 12/9/3 | 12/9/3 |

All shared-helper and configuration files below were absent from `legacy`.

| File | 1 November | Now |
|---|---:|---:|
| `R/calendar.R` | 40/16/20 | 45/17/23 |
| `R/config.R` | 77/45/27 | 84/49/29 |
| `R/config_schema.R` | 203/145/41 | 222/156/48 |
| `R/cross_validation.R` | — | 263/159/86 |
| `R/differences.R` | 139/76/43 | 139/76/43 |
| `R/forcing_breakdown.R` | 51/18/30 | 52/18/31 |
| `R/forcing_components.R` | 46/19/25 | 46/19/25 |
| `R/forcing_periods.R` | 41/18/20 | 47/21/23 |
| `R/kernels.R` | 26/17/8 | 26/17/8 |
| `R/land_cover_diagnostics.R` | — | 170/117/48 |
| `R/map_helpers.R` | 56/22/31 | 56/22/31 |
| `R/model_registry.R` | 129/71/47 | 154/83/59 |
| `R/paths.R` | 261/164/78 | 274/175/79 |
| `R/preparation.R` | 176/102/63 | 179/102/66 |
| `R/random.R` | 35/10/22 | 35/10/22 |
| `R/regions.R` | 31/17/12 | 32/17/13 |
| `R/run_manifest.R` | 317/214/82 | 320/215/84 |
| `R/training_support.R` | 51/21/26 | 70/30/35 |
| `config.R` | 219/46/156 | 218/46/155 |
| `configs/legacy_config.R` | 191/45/129 | 191/45/129 |

All test source files below were absent from `legacy`.

| File | 1 November | Now |
|---|---:|---:|
| `tests/cell_fixture.R` | — | 9/5/4 |
| `tests/test_bluesky_albedo.R` | 537/411/100 | 538/408/104 |
| `tests/test_calendar.R` | 23/19/3 | 28/23/4 |
| `tests/test_check_comments_only.R` | 29/22/4 | 29/22/4 |
| `tests/test_check_merge_evidence.R` | 63/42/11 | 63/42/11 |
| `tests/test_check_model7_convergence.R` | 55/44/8 | 55/44/8 |
| `tests/test_config.R` | 206/175/25 | 233/194/32 |
| `tests/test_cross_validation.R` | — | 181/115/51 |
| `tests/test_cross_validation_stages.R` | — | 66/49/12 |
| `tests/test_differences.R` | 123/61/44 | 117/57/42 |
| `tests/test_forcing_breakdown.R` | 54/37/13 | 54/37/13 |
| `tests/test_forcing_components.R` | 75/48/20 | 69/44/18 |
| `tests/test_forcing_periods.R` | — | 43/28/10 |
| `tests/test_model_registry.R` | 57/46/8 | 57/46/8 |
| `tests/test_paths.R` | 115/82/22 | 131/93/25 |
| `tests/test_preparation.R` | 69/44/20 | 69/44/20 |
| `tests/test_preparation_albedo.R` | 184/136/39 | 184/136/39 |
| `tests/test_preparation_ice.R` | 19/12/4 | 19/12/4 |
| `tests/test_random.R` | 43/33/7 | 43/33/7 |
| `tests/test_run_manifest.R` | 276/229/20 | 293/241/24 |
| `tests/test_tools.R` | 49/40/7 | 77/62/12 |
| `tests/test_training_support.R` | — | 31/18/9 |
| `tests/test_verify_change.R` | 101/70/14 | 109/75/16 |

All tools below were absent from `legacy`.

| File | 1 November | Now |
|---|---:|---:|
| `tools/check_anchors.R` | 64/41/20 | 64/41/20 |
| `tools/check_calibration_month.R` | 59/37/18 | 59/37/18 |
| `tools/check_comments_only.R` | 54/32/17 | 54/32/17 |
| `tools/check_merge_evidence.R` | 91/55/30 | 91/55/30 |
| `tools/check_model7_convergence.R` | 89/52/31 | 89/52/31 |
| `tools/compare_tables.R` | 90/62/23 | 109/73/30 |
| `tools/cross_validate_albedo.R` | — | 375/285/66 |
| `tools/download_era5_radiation.R` | 60/28/26 | 60/28/26 |
| `tools/download_kernels.sh` | 47/26/15 | 47/26/15 |
| `tools/frozen.R` | 60/40/15 | 60/40/15 |
| `tools/methodology_schematic.py` | 412/356/31 | 412/356/31 |
| `tools/nointerp_pipeline.py` | 256/227/8 | 256/227/8 |
| `tools/plotting/plot_forcing_vs_training_support.R` | 91/46/33 | 96/48/37 |
| `tools/plotting/plot_northeast_cover_and_location.R` | 193/124/54 | 224/146/62 |
| `tools/plotting/plot_pollen_site_coverage.R` | 64/31/24 | 70/34/27 |
| `tools/plotting/plot_training_support.R` | 117/69/34 | 118/71/34 |
| `tools/prepare_bluesky_albedo.R` | 1,006/649/302 | 1,010/650/305 |
| `tools/prepare_centre_elevation.R` | 25/10/13 | 25/10/13 |
| `tools/prepare_land_elevation.R` | 111/39/62 | 111/39/62 |
| `tools/restore_original_outputs.sh` | 27/19/6 | 27/19/6 |
| `tools/rscript.sh` | 24/10/14 | 24/10/14 |
| `tools/verify_change.R` | 283/196/63 | 278/189/65 |

The following archived files have **identical contents**, not merely identical counts, in all three snapshots. Their earlier locations were followed through the move.

| Current file | `legacy` = 1 November = now |
|---|---:|
| `archive/1_pollen_modern.R` | 179/86/37 |
| `archive/3_snow_probability.R` | 89/58/1 |
| `archive/4_thorn_modern.R` | 170/83/35 |
| `archive/4a_run_climateNA.R` | 177/112/40 |
| `archive/4b_thorn_modern.R` | 170/83/35 |
| `archive/4c_merge_climate.R` | 79/52/8 |
| `archive/5_plot_clim.R` | 293/191/33 |
| `archive/5_plot_thorn.R` | 133/80/20 |
| `archive/6_prediction_model_spatial_eval.R` | 366/207/64 |
| `archive/7_pollen_time.R` | 201/92/51 |
| `archive/8_plot_preds.R` | 419/191/144 |
| `archive/8_thorn_paleo.R` | 180/85/39 |
| `archive/GCM_snow_prob.R` | 215/112/56 |
| `archive/archive_2_monthly_ABOVE.R` | 175/106/9 |
| `archive/archive_2_monthly_GLOBALB.R` | 58/25/11 |
| `archive/archive_2a_plot_albedo_product.R` | 121/58/32 |
| `archive/beta_veg_lct_modern.R` | 173/77/37 |
| `archive/thornthwaite.R` | 333/222/99 |