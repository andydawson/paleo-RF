All 12 findings are fixed on branch `drift-fixes` in the worktree `scratchpad/wt-drift`: 14 commits on top of 7d65bb5, worktree clean. Nothing is pushed or merged. I made no pipeline or verification runs, and I did not touch the main checkout (apart from reading data files) or anything under paleo-RF-verify. All 20 test files pass, including the two new ones, and every changed R file parses.

**Commits, oldest first**
1. ffe089d Refuse a run directory that resolves onto the repository or its baseline folders
2. 6b02c8f compare_tables: say when no number was checked, and name unchecked columns
3. 7a6bbcb verify_change: refuse a spec that runs no script, no check and no anchor
4. bc68495 Seeded-file markers: list only real copies, and drop a file once the run writes it
5. c6d741e Forcing periods: take the slice pairs from the configuration, refuse unmatched lookups
6. f40bdf6 Pollen coverage: count a slice with no pollen in a region as zero
7. 0f5e727 Diagnostics: read the training-support inputs with one shared helper
8. 5a20947 Training-support figures: say the support is May's, and stop when May is not run
9. f6ac401 Northeast figure: require model 8, and state directions from the results
10. da443c1 Scripts 9 and 10: name the months instead of "annual", state kernel sky from settings
11. 04a1393 Script 1: drop the unsupported "for scale" claim from the mean-median diagnostic
12. c87eb35 Script 9: replace a dated debugging story and the manifest tutorial with pointers
13. 32c5cf6 Bring the README, AGENTS pointer and source headers up to date with the MODIS refit
14. 794f10b Albedo build: accept the version before the header update

**What changed, by finding**
- **1** (`R/config_schema.R` 70-101): `check_run_dir()` now turns the path into a full path (links and "." followed) before checking it. It refuses the repository itself and anything inside data, output, figures, runs, scripts, R or tests, whether written relative, absolute or through a link. The error messages are unchanged. Tests added to `tests/test_config.R`.
- **2** (`tools/compare_tables.R`):
  - `compare_tables()` now also returns which numeric columns were checked against no tolerance, and whether any were.
  - A new `comparison_verdict()` prints "NOT CHECKED numerically (report only)" when no number had a tolerance. It prints "within tolerance" only when some did, and lists any unchecked columns by name.
  - Exit status is unchanged, so the existing report-only checks (e.g. the i16c-elevation-current specs) behave as before.
  - Tests added to `tests/test_tools.R`.
- **3** (`tools/verify_change.R`, `read_spec`): a spec with no scripts, no checks and no anchors stops before anything is made. A spec with only checks or only anchors is still allowed. Tests in `tests/test_verify_change.R`.
- **4** (`R/paths.R`, `R/run_manifest.R`):
  - `seed_run_dir()` lists only files it actually copies. New small functions `seeded_files()`, `mark_seeded()` and `unmark_seeded()` hold the rules.
  - `write_output()` takes a file off the seeded list once the run writes it.
  - Tests in `tests/test_run_manifest.R`.
- **5** (`R/training_support.R`, both training-support tools): the shared helper stops with a message naming the months if May is not among them. Titles, captions and headers now say the support is relative to May's fit. No monthly support added. New `tests/test_training_support.R`.
- **6** (`tools/plotting/plot_northeast_cover_and_location.R`):
  - The tool stops unless `model_id` is mod8.
  - The titles of panels a and b take rises/falls from the correlations they already print.
  - Panel c's title and the caption's conclusion come from each model's change across today's evergreen range in the region. The caption's "most" is now a computed average.
  - The tool stops if today's range runs beyond the drawn steps.
- **7**:
  - `R/forcing_periods.R`: `assign_forcing_periods()` takes the configured slice ages as a third argument and stops on a year that is not the younger end of a configured pair.
  - Scripts 9, 10 and the forcing-support tool pass `cfg$analysis$ages`.
  - The forcing-support tool now looks up both ends of each pair separately and stops on a missing one; the `na.rm` is gone.
  - On the existing forcing table under `config.R`, the old and new functions give identical tables.
  - New `tests/test_forcing_periods.R`.
- **8**:
  - New `months_label()` in `R/calendar.R` gives "annual" only when all 12 months run, otherwise e.g. "dec/jan/feb/mar". Scripts 9 and 10 use it in figure text and printed lines.
  - The column `contribution_to_annual` keeps its name, so no table bytes change.
  - Script 9's kernel figure is now titled "Forcing by kernel", with a subtitle saying, from the settings, which reported kernels are clear-sky and which all-sky.
  - Test added to `tests/test_calendar.R`.
- **10** (`tools/plotting/plot_pollen_site_coverage.R`): region-by-slice counts are completed with zeros before the median. Today's data give identical medians, because every region has pollen at all 12 slices.
- **15**: new `read_training_support_inputs(run)` in `R/training_support.R`, used by all three tools; each keeps its own filtering and plotting. Its output is identical to the old inline code on the baseline prediction table.
- **20**:
  - `README.md` updated:
    - The MODIS cell albedo is the default, with the raster as the legacy setting.
    - It lists the ice mask, the ML ladder and the separate REML prediction fit.
    - `scripts/6_prediction_model_spatial_eval.R` is marked not migrated in both script tables, the run order and the provenance section.
    - The `ice_fort` files are no longer said to be read by scripts 8 and 9.
    - It now says six anchor sets, and gives a correct description of `annotated-interp`.
  - `AGENTS.md` now points to the README's script tables as the current code map.
  - Comment-only updates to `config.R:15`, `R/preparation.R:7` and `tools/prepare_bluesky_albedo.R:14`; `code_of()` gives the same code for each.
  - Commit 14 adds the previous albedo-build version (85353d3b…, commit 1af6502) to `ACCEPTED_OLDER_SHAS`, the same way as before. It has the same 78 expressions, made none of the monthly files, and `test_bluesky_albedo.R` passes.
- **21** (`scripts/1_veg_lct_prep.R`): the four printed lines with the cutoff and gradient claims are removed, with nothing in their place. Only the diagnostic-mode log changes.
- **23** (`scripts/9_forcing_barplot.R`): A2 now states the current rule and points to the 2026-10-19 changelog entry. The four-line manifest tutorial is now one line. Comments only, confirmed by `check_comments_only`.

**Checks run**
- All 20 test files pass. Two of them (`test_paths`, `test_preparation_ice`) need data that is not in git, so I copied `data/lct_modern_reveals_interp.RDS` and `output/calibration/calibration_model_stats.csv` from the main checkout into the worktree. Git ignores both; they are not committed.
- The comment-only check passed on scripts 9, `config.R`, `R/preparation.R` and the albedo builder.
- I smoke-tested the northeast tool in a scratch copy (`scratchpad/ne_check_7YuT`) on September baseline May fits, with the response column renamed to `may`. Every printed number matches the old version, and the figure draws.

**Anchored outputs that could be affected, and verification runs needed**
1. **Scripts 9 and 10** (findings 7 and 8, `R/calendar.R`): the `interp-forcing-2026-10-08` anchor. Model the spec on `2026-10-16_forcing-breakdown-3.R` (legacy config, seed `forcing` and `coarse_differences`, `check_anchors --all`), adding `test_forcing_periods.R` and `test_calendar.R` to its checks.
2. **Shared run plumbing** (findings 1 and 4): every script writes through it. Model on `2026-10-31_refit-legacy-seed1-3.R` (legacy config, seed and copy, scripts 5 and 6, the whole seed-1 anchor), adding the two new test files to its checks.
3. **Script 1** (finding 21, print lines only): the `interp-allmonths-2026-09-20` anchor. Model on `2026-10-15_i16c-elevation-legacy-4.R`. Low risk.
4. **Tools only** (findings 2 and 3): a tests-only spec like `2026-10-15_verify-tool-tests-3.R`.
5. **Diagnostics** (findings 5, 6, 10, 15): no anchors, but the tools must run to completion. Model on `2026-10-27_diagnostic-plots-2.R` and `2026-10-28_northeast-location-plot-3.R`. Both copy their inputs from paleo-RF-verify's 18 October run, so you decide whether that is acceptable while live runs read that folder, or point them at refit products.

By the review table, findings 1-4 are plumbing (one `change-reviewer`). Findings 6, 7 and 10 touch signs, endpoints and medians, so you may want the scientific review for them.

**Decisions I took myself**
- **Finding 3:** the spec is refused only when scripts, checks and anchors are all empty.
- **Finding 4, extra fix:** `verify_change`'s `copy` entries were written as "path " with a trailing space. `check_anchors` never recognised them as seeded, so a copied file could pass as MATCH. I fixed that line (`sep = ''`). It writes the line itself rather than calling `mark_seeded()`, so the tool still works on commits older than this change. As a result, a copied file that is also in an anchor and is not regenerated now shows SEEDED and fails `--all`. No existing spec copies such a file.
- **Finding 5:** the May guard is in the shared helper, so it also applies to the northeast tool.
- **Finding 6:** the "evergreen effect" direction is measured across today's evergreen range in the region (the grey band of panel c).
- **Finding 7:** the new third argument is required. The old verification check scripts in `docs/cc/verification/` (`2026-10-19_*_check.R`) call the function with two arguments; I left them alone as records.
- **Finding 8:** no "factor of two" figure is computed to replace the old title.
- **Finding 20:**
  - I did not edit the spatial-eval script itself, because CONTRIBUTING describes it as Andria's untouched original.
  - I left the README line saying a month change does not require rerunning script 2. That belongs to finding 12, which is excluded.
  - It took two commits, because the albedo-builder fingerprint has to be accepted in its own commit, as before.

**Could not do:** nothing outstanding.