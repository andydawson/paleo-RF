All four items are done. Each is one commit on `simplify-2026-11-01` in the worktree `.../scratchpad/wt-simplify`, on top of a14118f. Nothing was pushed or merged and no pipeline or verification run was made. The main checkout was only read (one data file, see below), and nothing under `paleo-RF-verify/` was touched. Over the branch the code is 61 lines shorter (14 files, +385 / −446).

## Commits
- **4adca2f** Scripts 5 and 7: state the map theme once, build the repeated plot once
- **9a66552** Script 1: move its optional diagnostics into one named helper
- **993f77b** One expansion of the path catalogue, used by the tests and by verify_change
- **6e3e98e** Tests: settings changed as lists, one shared cell, fixed equation-of-time values

## Item 1: shared plot styling (87 lines fewer)
- **Script 7** (`scripts/7_plot_preds.R:75-89`): the map theme is now one function, `map_theme(text_size = 12)`, used by all nine maps. Script 7 is 64 lines shorter.
  - The four-month panel calls `map_theme(text_size = 20)` (line 239), with a comment saying why.
  - The last plot, the per-slice difference pages, adds `theme(axis.line = element_blank())` (line 447), because it never had the black axis line.
  - The function stays in the script: script 3's map themes are different (panel border, legend sizes), so no other script uses it.
- **Script 5** (`scripts/5_calibration_eval.R:294-308`): the model-against-data plot is built once as `p_experiments`, and each of the three figures adds its own facet. 23 lines fewer.
- **Checks:** both scripts parse. With ggplot2 4.0.3:
  - all three new theme variants are identical, element by element, to the inline themes they replace;
  - test plots drawn with the old and new code give byte-identical PNGs, for the three themes and the three script 5 figures.

## Item 2: script 1's diagnostics (script 1 goes from 249 to 83 lines)
- The diagnostics are now `land_cover_diagnostics(lct_interp, lct_interp_wide, lct_interp_all, dom, diag_window, paths)` in the new file `R/land_cover_diagnostics.R` (170 lines).
- Script 1 sources the file and calls it at the end, under `cfg$run$diagnostic`, after both tables are written. The summaries that used to sit near the top of the script (old line 35) are now worked out inside the function from the unchanged draws.
- `library(ggplot2)` moved into the function, so the plotting package is still loaded only when diagnostics are on. No `library()` call was removed.
- The diagnostic code is unchanged apart from the two settings it now takes as arguments and three comments that said "this script" or "above".
- The README's R/ entry and its diagnostics paragraph now name the new file.
- Across the repository the size is about the same (+4 lines).
- **Check:** on a small made-up input, the old block and the new function give identical console output (61 lines) and 7 byte-identical files in `figures/diagnostics/`.

## Item 3 (review item 7): one catalogue expansion
- `R/paths.R:227` is now `catalogue_paths(paths, ids = PATH_CATALOGUE$id)`. It stops on an unknown id, and on a model template with no model ids listed (the "named no files" check verify_change used to make).
- `include_spatial_eval` is removed: nothing set it to TRUE.
- `tools/verify_change.R:126` `catalogue_files()` now calls `catalogue_paths(base, ids = ids)` instead of its own copy.
- `tests/test_paths.R` now names `pipeline_ids` itself, leaving out the sensitivity script's outputs as before. New checks:
  - the redirected list is the baseline list under the run folder, file for file;
  - every month and model id appears once;
  - all ids by default, nothing for no ids;
  - an unknown id or a template with no model ids stops.
- **Lines:** production code 7 fewer (verify_change −10, paths.R +3); test_paths +19.
- **Compared with the old code:**
  - verify_change's file list is identical for each of the 50 ids (315 files) and for all ids at once;
  - `catalogue_paths()` gives the same 278 files as the old default in both the baseline and redirected layouts, and the same 315 as the old `include_spatial_eval = TRUE`.

## Item 4 (review item 8): test setup (about 10 lines more in total)
The review expected 0–10 fewer. What this buys is tests that no longer depend on the layout of `config.R`, and an equation-of-time check that does not copy the code it checks.

- **`tests/test_config.R`:** schema tests now take the loaded settings and change one key with `with_setting("analysis$forcing$variant", "veg_ice")`, then check with `refuses()` / `accepts()`. Removed or duplicated keys are written out inline. Text edits stay only where loading the file is what's tested. The legacy configuration is loaded once instead of six times.
- **`R/config.R:67`:** the two-step check `load_config()` did inline is now `config_errors()`, so the tests use the same check rather than a copy. `load_config()` behaves as before.
- **`tests/cell_fixture.R`:** the hand-made cell that `test_differences.R` and `test_forcing_components.R` each defined is now shared (6 lines fewer in each).
- **`tests/test_bluesky_albedo.R`:** the copied equation-of-time formula is replaced by fixed values: −2.454694 min for 31 Dec 2004 and −2.453458 for 31 Dec 2005.
  - I worked them out in Python from the same Spencer series. NOAA's longer algorithm gives −3.19 and −3.07, within the series' known error.
  - A 365-day leap year would give −2.904169, and I confirmed the check now fails for it.
  - The literal-arithmetic line is removed.
- **Coverage did not drop:** still 127 checks, in the same order.
  - For 88 of the 90 converted schema checks, the settings list is identical to what the old text edit produced.
  - The other two (unknown key, repeated key) have the same keys in a different order and give identical messages.
  - No refusal pattern matches `config.R` or the legacy file unchanged.

## Tests run
- All 20 test files in `tests/` pass in the worktree except `test_preparation_ice.R`. It needs `data/lct_modern_reveals_interp.RDS`, a pipeline product that is not in a worktree, so the failure has nothing to do with these changes.
- `test_paths.R` needed `output/calibration/calibration_model_stats.csv`. I symlinked it from the main checkout (read only), ran the test, and removed the link.
- The PROJ environment variables are required: without them `test_bluesky_albedo` fails a projection check.

## What could be affected, and the verification runs needed
Run these one at a time; same-commit verifications collide.
1. **Script 7 figures (item 1):** no numerical anchor should change. Model on `2026-10-16_simplify-io-2-scripts78.R`: scripts 7, 7a, 8 under the legacy config, seeded with `prediction_summary`, against the `interp-tail-2026-09-21` anchor. The figures are not anchored, so also compare script 7's figures with the same run at a14118f (PNG MD5, or PDFs with the creation date stripped).
2. **Script 5 (item 1):** model on `2026-10-31_refit-legacy-seed1-3.R`: scripts 5 and 6, legacy, seed 1, against the `interp-seed1-2026-10-14` anchor. Its `seed` ids also exercise the new expansion in a real run (item 3).
3. **Script 1 (item 2):** model on `2026-10-30_refit-legacy-prep.R`: scripts 1 and 2, legacy, with the `interp-allmonths-2026-09-20` anchor check. Also run script 1 once with `settings = list(run = list(diagnostic = TRUE))` and compare `figures/diagnostics/` and the console log with the same run at a14118f. There is no existing spec with diagnostics on.
4. **Tools and tests (items 3, 4):** model on `2026-10-15_verify-tool-tests-3.R`, with every test as a check, adding `test_paths.R`, `test_forcing_components.R` and `test_bluesky_albedo.R`. Items 3 and 4 are plumbing-class changes, so a change-reviewer pass applies to them.

Because verify_change uses the R/paths.R of the commit it verifies, a spec with `seed` ids run against a commit older than 993f77b will now stop with "unused argument" rather than expand the wrong files.

## Decisions I took myself
- I removed the unused `months` argument of `catalogue_paths()`, which no caller passed, in addition to `include_spatial_eval`.
- I kept the "template with no model ids" check inside `catalogue_paths()`, to keep the guard verify_change had.
- I put the diagnostics helper in `R/` although only script 1 uses it, as `R/differences.R` and `R/forcing_breakdown.R` each serve one script.
- I added `config_errors()` to `R/config.R` so the tests check settings lists with the production check rather than a copy.
- I kept the "big" earth-area check as a text test, because it shows `load_config()` reports schema refusals.
- I named the new fixture `tests/cell_fixture.R`. Every verification spec lists its tests by name, so this file never runs as a test on its own.

No new questions for Andria came up.