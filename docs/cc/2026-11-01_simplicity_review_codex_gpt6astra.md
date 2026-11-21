# Simplicity and conciseness review of the whole code (Astra, GPT-6 Astra via Codex, max effort, 1 November 2026)

Chris (1 November): the code must be "as simple and concise as possible. No bloat and no overcomplicating."
Reviewed feature/single-config at 837f2d3, read-only; prompt in the session scratch folder (astra_simplicity2/prompt.md).
Excludes the drift findings being fixed (docs/cc/2026-11-01_drift_conciseness_review_codex_gpt6astra.md).
**Chris's choice (1 November):** do now items 1 (shared plot styling), 2 (script 1's diagnostics into a named helper), 7 (one catalogue expansion; the review's numbering) and 8 (simpler test setup); the five hand-over items (3, 4, 5, 6, 9) wait until the migration is finished and handed back to Andria, after the refit runs.

---

**Verdict:** the main analysis is much clearer than `legacy`, but the repository still asks readers to navigate too much supporting material. The best simplifications are repeated plotting code, optional investigations embedded in routine scripts, and development machinery that should sit outside Andria’s everyday workflow.

Since 15 October, source files have grown by **3,369 lines, or 32%**. Tools and tests account for **80% of that growth**. The MODIS builder, its tests and four diagnostic plotting tools account for **60%**. Much of this serves real purposes; the new refit helpers are proportionate.

I would make modest deletions now and separate specialist work at hand-over. Removing scientific checks or replacing small functions with dense inline expressions would make the code harder to trust and modify.

| Count | `legacy` | 15 October, `bdf8a5e` | Reviewed, `837f2d3` |
|---|---:|---:|---:|
| Source lines, including blanks | 10,305 | 10,440 | **13,809** |
| Code lines | 4,285 | 6,368 | **8,447** |
| Full-line comments | 4,117 | 2,354 | **3,430** |
| Blank lines | 1,903 | 1,718 | **1,932** |
| Other text: documentation, tables, inventories | 0 | 749 | **764** |
| Source plus other text | 10,305 | 11,189 | **14,573** |

These counts cover all requested directories. “Code” means a nonblank line that does not start with `#`; inline comments and Python docstrings consequently count as code. Binary data and the Git LFS pointer are excluded from line totals.

The numbered analysis, shared helpers, configurations and grid helper together occupy **4,977 lines**, against **6,774** originally. Their code lines have nevertheless increased from **2,365 to 2,827**: some apparent shortening comes from removing old commented-out code.

I reviewed the requested commit, the changelog and both earlier reviews. The checkout advanced to `234027f` during inspection, but only review-role documentation changed; I verified the counts against `837f2d3` explicitly. I changed nothing and ran no R. Checks below are recommendations, not reported test results. The drift findings already being fixed are excluded.

The simplifications below are ranked by usefulness to Andria. Savings are estimates of physical lines; moving code is distinguished from deleting it.

1. **Do now — share repeated plot styling and repeated plot construction.**

   In [scripts/7_plot_preds.R:187](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-feature/scripts/7_plot_preds.R:187), essentially the same map theme appears nine times. Define one small theme function, retaining the larger text size and the final plot’s different axis treatment explicitly.

   In [scripts/5_calibration_eval.R:294](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-feature/scripts/5_calibration_eval.R:294), three plots repeat the same layers and differ only in faceting. Construct the common plot once and add each facet specification.

   **Saving:** approximately **85–105 lines** combined. **Benefit:** one place to change appearance, with the plotted data and scientific choices still visible. **Anchor risk:** low; numerical products should be untouched. **Check:** compare affected figures before and after, including rendered PDF pages, and confirm unchanged numerical outputs through `verify_change.R`. Preserve existing filtering and plotting behaviour during this extraction.

2. **Do now — finish the approved extraction from script 1.**

   [scripts/1_veg_lct_prep.R:102](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-feature/scripts/1_veg_lct_prep.R:102) contains about 150 lines of optional diagnostics. Their preparatory calculations also interrupt the main flow at line 35.

   Put these in one named diagnostic helper with explicit inputs, called under the existing flag. Keep its plotting dependencies inside the diagnostic route.

   **Saving:** about **150 lines from the entry script**; **no meaningful repository-wide reduction**. **Benefit:** Andria can read the ordinary preparation from input to two output tables without passing through an investigation. **Anchor risk:** low. **Check:** compare both prepared land-cover tables and the diagnostics with the flag enabled. This is the unfinished part of the fifth approved 15 October recommendation.

3. **At hand-over — save the prediction fit once, directly from script 4.**

   [scripts/4_calibration_model.R:109](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-feature/scripts/4_calibration_model.R:109) writes `calibration_prediction_fit`. Script 5 reads it at line 53 and writes the same object as `calibration_selected` at line 56. Script 6 consumes the latter.

   Give the selected REML fit one product identity, owned by script 4. Scripts 5, 6 and the diagnostics should read that product. Retaining the existing selected-model filename would limit disruption.

   **Saving:** roughly **5–15 lines**, twelve copied model files per complete run, and one artificial dependency on running evaluation before prediction. **Benefit:** fitting produces the fitted model; evaluation evaluates it. **Anchor risk:** medium because catalogue ownership, manifests and verification specifications change. **Check:** compare saved model objects and seeded downstream predictions; verify that script 6 can consume script 4’s product directly.

   Keep the separate ML comparison fits and REML prediction fit. Identical formulas do not make those interchangeable.

4. **At hand-over — separate optional investigations from routine production.**

   The main candidates are:

   - [scripts/5_calibration_eval.R:234](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-feature/scripts/5_calibration_eval.R:234): spatial comparisons and the November-only investigation beginning at line 341.
   - [scripts/8_radiative.R:141](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-feature/scripts/8_radiative.R:141): June extreme-forcing inspection.
   - [scripts/9_forcing_barplot.R:354](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-feature/scripts/9_forcing_barplot.R:354): historical EGU comparison.
   - Script 4, line 84: fitting the spatial experiments, once their continuing scientific role is settled.

   Use separately named tools under `tools/plotting/`, reading the required products. Preserve the `cover_elev` fit while the northeast diagnostic needs it. Avoid adding another collection of pipeline switches.

   **Saving:** roughly **250 lines from routine scripts**, overlapping the plot reuse above; little or no total deletion. **Benefit:** the route to the paper’s results has fewer side investigations and dependencies. **Anchor risk:** medium. **Check:** compare both core outputs and extracted diagnostic results. In particular, preserve the EGU calculation’s current domain and complete-period filtering, and retain simulation call identifiers and seeds.

5. **At hand-over — simplify the rules for reusing upstream products.**

   [R/run_manifest.R:177](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-feature/R/run_manifest.R:177) compares the entire analysis configuration. A reporting-only change can therefore invalidate preparation and calibration products.

   Replace this policy, when agreed, with a short explicit statement of the settings affecting each product, including inherited upstream choices. Keep file hashes and provenance. Do not build automatic dependency inference.

   **Saving:** **none necessarily**; this may add a few lines. **Benefit:** a substantial reduction in reruns, configuration workarounds and explanations Andria must learn. **Anchor risk:** medium: an incomplete dependency list could permit invalid reuse. **Check:** irrelevant changes must permit reuse; changes to elevation, albedo selection, model settings and other relevant inputs must still reject it.

   This remains a hand-over policy recommendation from 15 October, not a reason to weaken the current checks during migration.

6. **At hand-over — retire the historical July pilot from the live MODIS builder.**

   [tools/prepare_bluesky_albedo.R:980](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-feature/tools/prepare_bluesky_albedo.R:980) retains the original July 2005 pilot command. It requires `need_zenith = FALSE` to pass through the production builder and treats the missing angle as zero at line 590. The live production commands use the normal zenith route.

   Preserve the pilot’s historical command and version in the build record, then remove its command branch, special plumbing and pilot-only test cases. Retain production missing-zenith tests and the scientific `full_nocut` version.

   **Saving:** approximately **40–60 lines including tests**. **Benefit:** one production interpretation of the input layers. **Anchor risk:** low for production arithmetic, but source-version acceptance needs care. **Check:** builder tests, a retained real month, the resulting cell table, and the accepted source hashes. Do not remove provenance checks to make this cleanup easier.

7. **Do now — use one catalogue expansion function.**

   [R/paths.R:226](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-feature/R/paths.R:226) expands templates over months and models. `tools/verify_change.R:129` implements substantially the same expansion again.

   Let the existing helper accept the required catalogue IDs and call it from verification. Remove `include_spatial_eval` if its unused enabled branch remains unnecessary; no caller currently enables it.

   **Saving:** about **5–10 lines**, after retaining validation. **Benefit:** adding a product cannot require updating two expansion rules. **Anchor risk:** low. **Check:** compare expanded filenames for baseline and redirected runs, all month/model combinations, unknown IDs and empty selections.

8. **Do now — simplify test construction, without broadly cutting scientific tests.**

   [tests/test_config.R:6](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-feature/tests/test_config.R:6) changes settings by substituting exact source text. Use modified configuration lists for schema tests; retain text fixtures where syntax or loading is the behaviour under test. Share the duplicated cell fixture in `test_differences.R` and `test_forcing_components.R`.

   In `tests/test_bluesky_albedo.R:14`, the “by hand” equation-of-time helper copies the production formula. Fixed independently checked expected values would be clearer. Line 40 tests literal arithmetic without calling production code and can go.

   **Saving:** approximately **0–10 lines**; the main gain is less fragile and more independent tests. **Anchor risk:** none directly, but preserve coverage. **Check:** run the affected tests through verification and confirm they still reject deliberately invalid settings and scientific counterexamples.

   The builder’s unit tests and its small raster integration tests are not redundant: the latter catch wiring, aggregation and file-handling errors that isolated arithmetic tests cannot.

9. **At hand-over — give development and historical material separate places.**

   [tools/verify_change.R:1](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-feature/tools/verify_change.R:1), the merge-evidence hook, frozen-cache management, anchor checking and machine-specific runner belong under `tools/development/`, with maintainer instructions. Input builders belong under `tools/preparation/`. The existing `tools/plotting/` separation is useful.

   Keep the merge hook required during this migration; reconsider mandatory installation for Andria at hand-over. Preserve the frozen migration inventory as historical verification evidence rather than an everyday operating procedure.

   There are also **3,531 unchanged lines** in archived or non-routine historical scripts, including the existing 2,444-line archive, plus **668 lines** in the two historical diagram generators. Give these an archival route outside the normal starting instructions. Preserve dependent relative paths and the original reproduction route.

   **Saving:** **zero through relocation**. **Benefit:** Andria encounters analysis tools before maintenance machinery. **Anchor risk:** low for arithmetic, moderate for moved paths. **Check:** all source references, documented commands, verification specifications and a normal run from the repository root. Do not leave forwarding wrappers merely to preserve every old tool location.

The decisions on the mechanisms you named are:

| Mechanism | Decision | Reason |
|---|---|---|
| Run manifest and `read_input`/`write_output` | **Leave the core; simplify reuse policy at hand-over** | The wrappers record real inputs, outputs and failures. They remove repeated provenance work. The blanket configuration comparison is the costly part. |
| Path catalogue | **Leave; merge its duplicate expansion now** | Central filenames and producer ownership prevent real inconsistencies. The small path accessors are understandable. |
| Config schema | **Leave** | Ordinary lists, named checks and cross-setting validation are proportionate. Avoid replacing them with a configuration framework. |
| Current and legacy configurations | **Leave separate explicit lists** | Making legacy inherit current defaults would make historical reproduction fragile. Comment trimming already covered by the drift work is not counted again here. |
| Model registry | **Leave** | It centralises formulas, labels and controls. The small formula and fitting functions have clear purposes, even where they have few callers. |
| `verify_change` | **Leave; move to development tools at hand-over** | Its 283 lines address actual failures of earlier ad hoc verification. It has barely grown since 15 October. |
| Merge-evidence hook | **Leave during migration; maintainer policy at hand-over** | Its cost is procedural more than numerical. It need not become part of learning to run the science. |
| `check_comments_only` | **Leave** | A 54-line tool providing a cheap, useful check. |
| Anchors and frozen-input checks | **Keep anchors; separate the frozen migration cache at hand-over** | Output regression checks and protection against overwriting cached inputs answer different questions. |
| MODIS safeguards | **Leave production safeguards; remove historical pilot later** | Delivery checks, checksums, temporary-file publication, worker-failure checks and validation before raw-file deletion protect distinct failures. |
| New refit helpers | **Leave** | Cell matching, missingness, retrieval support, available rows and convergence are real concerns introduced or exposed by the rebuilt albedo. |
| Diagnostic tools | **Leave as separate tools** | Four named plotting tools are easier to understand than a diagnostic framework. Their repeated preparation is already being addressed by the drift work. |

The MODIS builder’s 1,006 lines warrant attention, but its present size alone does not justify removing safeguards. Its source-hash acceptance list also has a concrete reproducibility purpose. I would keep the stable builder version and its provenance together rather than introduce a more elaborate mechanism for deciding which source edits “count”.

Likewise, the refit’s short functions should not be inlined merely because some have one caller. `complete_model_rows()`, `model_coefficients()` and `fit_convergence()` give names to operations a scientist needs to understand.

Before running script 1, a newcomer needs these concepts:

| Concept | Necessary? |
|---|---|
| Run from the repository root, with required R packages and prepared inputs present | Yes |
| Numbered scripts and their required order | Yes |
| `config.R` is an ordinary R list | Yes |
| `analysis`, `presentation` and `run` separate different kinds of settings | Yes |
| `run$dir` determines where products are written | Yes |
| Run records are automatic; a rejected upstream product requires attention | Yes, at an operational level |
| Catalogue internals, schema implementation, model registry, verification specifications and Git hooks | No, not to run script 1 |

Before changing an existing setting, Andria additionally needs to know its scientific meaning and allowed values, how to use the same configuration throughout a run, which downstream work must be repeated, and how the random seed affects reproducibility.

The present whole-configuration reuse rule makes the rerun question unnecessarily difficult. That is the most valuable operational simplification. Adding a genuinely new setting is different: it reasonably requires editing its consumer, validation, both configurations and relevant tests.

The 15 October “do now” recommendations stand as follows:

| Recommendation | Position at `837f2d3` |
|---|---|
| Deliver the land-mean elevation product and distinguish it from frozen historical inputs | **Implemented.** Both elevation products are tracked, with separate preparation tools. |
| Provide a portable starting route | **Addressed then.** Subsequent documentation drift is covered by the separate review and is excluded here. |
| Return structured anchor results instead of parsing printed success messages | **Implemented and retained.** |
| Remove repeated selected-model writes and unused reads | **Implemented and retained.** One remaining model copy motivates recommendation 3 above. |
| Remove script 1’s network fallback and extract its diagnostics | **Partly implemented.** Elevation acquisition is separate; the diagnostic extraction remains unfinished. |

The new work has not brought back the old repeated fitting blocks or ad hoc verification drivers. It has increased the amount of diagnosis and preparation code. The main unfinished simplicity work is separation of responsibilities, rather than another rewrite of the scientific helpers.

For completeness, the following inventory accounts for every requested file. Each count is **total lines / code lines / full-line comments**. For files absent from `legacy`, “Earlier” identifies their first addition in Git.

| Area | `legacy` | 15 October | Reviewed |
|---|---:|---:|---:|
| Top-level `scripts/` | 7,861 / 2,983 / 3,622 | 3,736 / 2,267 / 756 | 3,975 / 2,379 / 867 |
| `scripts/archive/` | 2,444 / 1,302 / 495 | 2,444 / 1,302 / 495 | 2,444 / 1,302 / 495 |
| `R/` | 0 | 1,286 / 792 / 392 | 1,679 / 975 / 575 |
| `config.R` | 0 | 182 / 43 / 123 | 219 / 46 / 156 |
| `configs/` | 0 | 172 / 43 / 113 | 191 / 45 / 129 |
| Test source | 0 | 1,054 / 779 / 169 | 2,078 / 1,551 / 369 |
| `tools/`, including plotting | 0 | 1,566 / 1,142 / 306 | 3,223 / 2,149 / 839 |

Shared helpers and configurations:

| File | Earlier | Earlier count | Reviewed count |
|---|---|---:|---:|
| `R/calendar.R` | `572b014` | 29 / 11 / 15 | 40 / 16 / 20 |
| `R/config.R` | `d8772e3` | 93 / 62 / 25 | 77 / 45 / 27 |
| `R/config_schema.R` | `d8772e3` | 71 / 47 / 18 | 203 / 145 / 41 |
| `R/differences.R` | `300270b` | 94 / 54 / 21 | 139 / 76 / 43 |
| `R/forcing_breakdown.R` | `0af8f7d` | 51 / 18 / 30 | 51 / 18 / 30 |
| `R/forcing_components.R` | `1e816ea` | 46 / 19 / 25 | 46 / 19 / 25 |
| `R/forcing_periods.R` | `ee50abc` | 41 / 18 / 20 | 41 / 18 / 20 |
| `R/kernels.R` | `7a5adb3` | 26 / 17 / 8 | 26 / 17 / 8 |
| `R/map_helpers.R` | `b3d7742` | 49 / 21 / 24 | 56 / 22 / 31 |
| `R/model_registry.R` | `7dda080` | 74 / 47 / 21 | 129 / 71 / 47 |
| `R/paths.R` | `5cdc707` | 234 / 149 / 66 | 261 / 164 / 78 |
| `R/preparation.R` | `156a537` | 49 / 30 / 17 | 176 / 102 / 63 |
| `R/random.R` | `ff36999` | 35 / 10 / 22 | 35 / 10 / 22 |
| `R/regions.R` | `d440e79` | 31 / 17 / 12 | 31 / 17 / 12 |
| `R/run_manifest.R` | `2a4a148` | 88 / 62 / 15 | 317 / 214 / 82 |
| `R/training_support.R` | `21409f4` | 46 / 18 / 24 | 51 / 21 / 26 |
| `config.R` | `d8772e3` | 57 / 17 / 36 | 219 / 46 / 156 |
| `configs/legacy_config.R` | `7a5adb3` | 160 / 40 / 105 | 191 / 45 / 129 |

Top-level scripts:

| File | Earlier | Earlier count | Reviewed count |
|---|---|---:|---:|
| `scripts/1_veg_lct_prep.R` | `legacy` | 246 / 79 / 109 | 253 / 158 / 71 |
| `scripts/2_calibration_lct_bluesky.R` | `legacy` | 420 / 207 / 119 | 279 / 170 / 53 |
| `scripts/3_plot_cal_lct_albedo.R` | `legacy` | 622 / 346 / 151 | 254 / 153 / 53 |
| `scripts/4_calibration_model.R` | `legacy` | 830 / 176 / 573 | 114 / 56 / 31 |
| `scripts/5_calibration_eval.R` | `legacy` | 1,067 / 426 / 500 | 424 / 300 / 42 |
| `scripts/6_prediction_model.R` | `legacy` | 304 / 88 / 160 | 111 / 66 / 17 |
| `scripts/6_prediction_model_spatial_eval.R` | `legacy` | 366 / 207 / 64 | 366 / 207 / 64 |
| `scripts/7_plot_preds.R` | `legacy` | 2,085 / 700 / 1,147 | 517 / 377 / 36 |
| `scripts/7a_alb_diff_full.R` | `legacy` | 853 / 214 / 470 | 210 / 118 / 28 |
| `scripts/8_radiative.R` | `legacy` | 347 / 129 / 137 | 179 / 109 / 30 |
| `scripts/9_forcing_barplot.R` | `e0ad29b` | 220 / 125 / 71 | 405 / 183 / 192 |
| `scripts/10_forcing_breakdown.R` | `df9a7e9` | 135 / 67 / 55 | 130 / 62 / 55 |
| `scripts/GCM_snow_prob.R` | `legacy` | 215 / 112 / 56 | 215 / 112 / 56 |
| `scripts/beta_veg_lct_modern.R` | `legacy` | 173 / 77 / 37 | 173 / 77 / 37 |
| `scripts/make_grid.R` | `ffb97ad` | 15 / 9 / 6 | 12 / 9 / 3 |
| `scripts/thornthwaite.R` | `legacy` | 333 / 222 / 99 | 333 / 222 / 99 |

Every archived script is unchanged from `legacy`:

| File | `legacy` count | Reviewed count |
|---|---:|---:|
| `scripts/archive/1_pollen_modern.R` | 179 / 86 / 37 | 179 / 86 / 37 |
| `scripts/archive/3_snow_probability.R` | 89 / 58 / 1 | 89 / 58 / 1 |
| `scripts/archive/4_thorn_modern.R` | 170 / 83 / 35 | 170 / 83 / 35 |
| `scripts/archive/4a_run_climateNA.R` | 177 / 112 / 40 | 177 / 112 / 40 |
| `scripts/archive/4b_thorn_modern.R` | 170 / 83 / 35 | 170 / 83 / 35 |
| `scripts/archive/4c_merge_climate.R` | 79 / 52 / 8 | 79 / 52 / 8 |
| `scripts/archive/5_plot_clim.R` | 293 / 191 / 33 | 293 / 191 / 33 |
| `scripts/archive/5_plot_thorn.R` | 133 / 80 / 20 | 133 / 80 / 20 |
| `scripts/archive/7_pollen_time.R` | 201 / 92 / 51 | 201 / 92 / 51 |
| `scripts/archive/8_plot_preds.R` | 419 / 191 / 144 | 419 / 191 / 144 |
| `scripts/archive/8_thorn_paleo.R` | 180 / 85 / 39 | 180 / 85 / 39 |
| `scripts/archive/archive_2_monthly_ABOVE.R` | 175 / 106 / 9 | 175 / 106 / 9 |
| `scripts/archive/archive_2_monthly_GLOBALB.R` | 58 / 25 / 11 | 58 / 25 / 11 |
| `scripts/archive/archive_2a_plot_albedo_product.R` | 121 / 58 / 32 | 121 / 58 / 32 |

Tests:

| File | Earlier | Earlier count | Reviewed count |
|---|---|---:|---:|
| `tests/test_bluesky_albedo.R` | `5c018bb` | 73 / 47 / 16 | 537 / 411 / 100 |
| `tests/test_calendar.R` | `572b014` | 18 / 15 / 2 | 23 / 19 / 3 |
| `tests/test_check_comments_only.R` | `99042c9` | 27 / 20 / 4 | 29 / 22 / 4 |
| `tests/test_check_merge_evidence.R` | `998e783` | 42 / 27 / 7 | 63 / 42 / 11 |
| `tests/test_check_model7_convergence.R` | `551182d` | 31 / 24 / 5 | 55 / 44 / 8 |
| `tests/test_config.R` | `d8772e3` | 91 / 73 / 12 | 206 / 175 / 25 |
| `tests/test_differences.R` | `00f8ae2` | 64 / 32 / 22 | 123 / 61 / 44 |
| `tests/test_forcing_breakdown.R` | `0af8f7d` | 54 / 37 / 13 | 54 / 37 / 13 |
| `tests/test_forcing_components.R` | `1e816ea` | 75 / 48 / 20 | 75 / 48 / 20 |
| `tests/test_model_registry.R` | `5b2536a` | 26 / 21 / 3 | 57 / 46 / 8 |
| `tests/test_paths.R` | `5cdc707` | 89 / 67 / 12 | 115 / 82 / 22 |
| `tests/test_preparation.R` | `156a537` | 61 / 39 / 18 | 69 / 44 / 20 |
| `tests/test_preparation_albedo.R` | `629aa05` | 147 / 112 / 28 | 184 / 136 / 39 |
| `tests/test_preparation_ice.R` | `43b6908` | 19 / 12 / 4 | 19 / 12 / 4 |
| `tests/test_random.R` | `ff36999` | 43 / 33 / 7 | 43 / 33 / 7 |
| `tests/test_run_manifest.R` | `6399b6e` | 219 / 181 / 16 | 276 / 229 / 20 |
| `tests/test_tools.R` | `671b6e3` | 31 / 25 / 4 | 49 / 40 / 7 |
| `tests/test_verify_change.R` | `fc87dd1` | 90 / 64 / 11 | 101 / 70 / 14 |

Tools, including every plotting tool:

| File | Earlier | Earlier count | Reviewed count |
|---|---|---:|---:|
| `tools/check_anchors.R` | `671b6e3` | 44 / 28 / 14 | 64 / 41 / 20 |
| `tools/check_calibration_month.R` | `89937f4` | 59 / 37 / 18 | 59 / 37 / 18 |
| `tools/check_comments_only.R` | `99042c9` | 49 / 31 / 14 | 54 / 32 / 17 |
| `tools/check_merge_evidence.R` | `998e783` | 73 / 48 / 20 | 91 / 55 / 30 |
| `tools/check_model7_convergence.R` | `551182d` | 63 / 36 / 23 | 89 / 52 / 31 |
| `tools/compare_tables.R` | `89937f4` | 90 / 62 / 23 | 90 / 62 / 23 |
| `tools/download_era5_radiation.R` | `e97ec44` | 60 / 28 / 26 | 60 / 28 / 26 |
| `tools/download_kernels.sh` | `a94aefb` | 47 / 26 / 15 | 47 / 26 / 15 |
| `tools/frozen.R` | `671b6e3` | 60 / 40 / 15 | 60 / 40 / 15 |
| `tools/methodology_schematic.py` | `d3c701d` | 412 / 356 / 31 | 412 / 356 / 31 |
| `tools/nointerp_pipeline.py` | `a94aefb` | 256 / 227 / 8 | 256 / 227 / 8 |
| `tools/plotting/plot_forcing_vs_training_support.R` | `21409f4` | 92 / 47 / 33 | 91 / 46 / 33 |
| `tools/plotting/plot_northeast_cover_and_location.R` | `df59853` | 151 / 93 / 43 | 193 / 124 / 54 |
| `tools/plotting/plot_pollen_site_coverage.R` | `727ae10` | 73 / 39 / 25 | 64 / 31 / 24 |
| `tools/plotting/plot_training_support.R` | `21409f4` | 118 / 70 / 34 | 117 / 69 / 34 |
| `tools/prepare_bluesky_albedo.R` | `e97ec44` | 308 / 220 / 68 | 1,006 / 649 / 302 |
| `tools/prepare_centre_elevation.R` | `17bcaab` | 23 / 8 / 13 | 25 / 10 / 13 |
| `tools/prepare_land_elevation.R` | `c839857` | 118 / 53 / 52 | 111 / 39 / 62 |
| `tools/restore_original_outputs.sh` | `c70afe8` | 27 / 19 / 6 | 27 / 19 / 6 |
| `tools/rscript.sh` | `935dd0b` | 21 / 11 / 10 | 24 / 10 / 14 |
| `tools/verify_change.R` | `fc87dd1` | 272 / 189 / 60 | 283 / 196 / 63 |

The remaining 36 files are test documentation and data, all absent from `legacy`. Code/comment classification is inapplicable to them. These 18 text files total 764 lines:

| File | First appearance | First lines | Reviewed lines |
|---|---|---:|---:|
| `tests/anchors/README.md` | `c70afe8` | 71 | 113 |
| `tests/anchors/interp-allmonths-2026-09-20/AIC_table.csv` | `2a4a148` | 9 | 9 |
| `tests/anchors/interp-allmonths-2026-09-20/MD5SUMS.txt` | `89937f4` | 5 | 5 |
| `tests/anchors/interp-allmonths-2026-09-20/README.md` | `2a4a148` | 18 | 21 |
| `tests/anchors/interp-allmonths-2026-09-20/calibration_model_stats.csv` | `2a4a148` | 13 | 13 |
| `tests/anchors/interp-forcing-2026-10-08/MD5SUMS.txt` | `0461902` | 4 | 4 |
| `tests/anchors/interp-forcing-2026-10-08/README.md` | `0461902` | 20 | 20 |
| `tests/anchors/interp-forcing-2026-10-08/forcing_by_period.csv` | `0461902` | 22 | 22 |
| `tests/anchors/interp-forcing-2026-10-08/forcing_by_period_egu2024recipe_vs_slide.csv` | `0461902` | 8 | 8 |
| `tests/anchors/interp-forcing-2026-10-08/forcing_by_period_variant_sensitivity.csv` | `0461902` | 43 | 43 |
| `tests/anchors/interp-forcing-2026-10-08/modern_ipcc_ar6_erf.csv` | `0461902` | 6 | 6 |
| `tests/anchors/interp-seed1-2026-10-14/MD5SUMS.txt` | `1e1409d` | 26 | 26 |
| `tests/anchors/interp-seed1-2026-10-14/README.md` | `1e1409d` | 30 | 40 |
| `tests/anchors/interp-seed1-2026-10-14/calibration_model_stats.csv` | `1e1409d` | 13 | 13 |
| `tests/anchors/interp-tail-2026-09-21/MD5SUMS.txt` | `dcda6fb` | 6 | 6 |
| `tests/anchors/live_paths.tsv` | `89937f4` | 18 | 42 |
| `tests/anchors/tolerances.tsv` | `723d334` | 36 | 42 |
| `tests/frozen_inputs.md5` | `935dd0b` | 331 | 331 |

These 18 data files are unchanged from their first addition. They have no meaningful source-line count:

| File | Representation |
|---|---|
| `tests/anchors/interp-allmonths-2026-09-20/calibration_modern_lct_interp_bluesky.RDS` | Binary |
| `tests/anchors/interp-allmonths-2026-09-20/lct_modern_reveals_interp.RDS` | Binary |
| `tests/anchors/interp-allmonths-2026-09-20/lct_paleo_reveals_interp.RDS` | Binary |
| `tests/anchors/interp-allmonths-2026-09-20/paleo_interp_predict_gam_bluesky.RDS` | Binary |
| `tests/anchors/interp-allmonths-2026-09-20/paleo_interp_predict_gam_summary_bluesky.RDS` | Binary |
| `tests/anchors/interp-tail-2026-09-21/ALB_diffs_bluesky.RDS` | Binary |
| `tests/anchors/interp-tail-2026-09-21/RF_holocene_all_cases.RDS` | Git LFS pointer |
| `tests/anchors/interp-tail-2026-09-21/alb_interp_preds_diffs_bluesky.RDS` | Binary |
| `tests/anchors/interp-tail-2026-09-21/ice_fort.RDS` | Binary |
| `tests/anchors/interp-tail-2026-09-21/ice_fort_diff_old.RDS` | Binary |
| `tests/anchors/interp-tail-2026-09-21/ice_fort_diff_young.RDS` | Binary |
| `tests/anchors/nointerp-mar-2026-09-16/alb_preds_diffs_bluesky.RDS` | Binary |
| `tests/anchors/nointerp-mar-2026-09-16/calibration_modern_lct_bluesky.RDS` | Binary |
| `tests/anchors/nointerp-mar-2026-09-16/paleo_predict_gam_bluesky.RDS` | Binary |
| `tests/anchors/nointerp-mar-2026-09-16/paleo_predict_gam_summary_bluesky.RDS` | Binary |
| `tests/anchors/nointerp-may-2026-09-17/alb_preds_diffs_may_bluesky.RDS` | Binary |
| `tests/anchors/nointerp-may-2026-09-17/paleo_predict_gam_may_bluesky.RDS` | Binary |
| `tests/anchors/nointerp-may-2026-09-17/paleo_predict_gam_summary_may_bluesky.RDS` | Binary |

The calendar, seed handling, central model formulas, small preparation and forcing helpers, script 6’s prediction loop and script 7a’s use of shared differencing are already as simple as they should be. Their named functions and checks make the science easier to follow. Preserve those gains.