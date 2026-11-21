The refit code is built on `refit-modis` in the worktree `/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-refit-modis`. It is in 9 commits and every test passes. Two of the real-table checks in the brief cannot pass as written on the real data, so I changed them (decision 2 below). I did no pipeline runs, no verification runs, no pushes and no merges, and nothing in the main checkout was written. I did not add anything to the two questions-for-Andria files.

**Branch tip:** `1a041d1`, from `0c65aa7`. Commits, oldest first:
1. `ede49c5` Commit the rebuilt MODIS albedo cell table as a prepared input
2. `629aa05` Add the tested reader that attaches MODIS cell albedo to the calibration cells
3. `e338d9b` Add the calibration albedo settings: source, statistic and version
4. `1f18543` Script 2: calibrate on the MODIS cell table or the raster, as config.R chooses
5. `1089296` Script 5: count interval coverage over observed cells only
6. `9e550f1` Calibration fits: optional fitting control, and rows fitted in the convergence line
7. `551182d` Add a tool that refits model 7 at 2,000 steps beside the saved fit
8. `6de7ec0` Albedo build header: the 16-day window is not centred on the day
9. `1a041d1` Albedo build: accept the monthly files of the version before the comment fix

## Per decision item
1. **Cell table committed.** Both files are copied byte for byte (MD5 `d73c54cc…` and `7cc93a23…`). `.gitignore` does not hide them and they are plain git, not LFS, like the elevation CSV.
   - They are in `PATH_CATALOGUE` as `albedo_modis_cells` and `albedo_modis_provenance` (`R/paths.R:51-54`).
   - `tests/test_paths.R:22-26` lists them as prepared inputs, and lines 50-51 now also check there are three and that each file exists. No other count in that test changed.
   - I added two rows to `README.md`'s data tables, as was done for the elevation table.
2. **Configuration.** The settings are `analysis$albedo`, placed beside `analysis$elevation` because the other input choices sit at that level; `analysis$calibration` holds model choices.
   - `config.R:51-67` sets modis_cells / all_days / full_75; `configs/legacy_config.R:46-54` sets legacy_raster and adds a line to its header list of differences. Both have plain comments for Andria pointing to the decisions file.
   - The schema is at `R/config_schema.R:132-135`. The rule at `:194-198` refuses any non-default statistic or version under legacy_raster.
   - `config_schema.R` now sources `R/preparation.R`, so the legal values are defined once. There is no winter setting.
3. **Reader function.** `cell_albedo_by_month()` and the constants `ALBEDO_VERSIONS` / `ALBEDO_STATISTICS` are in `R/preparation.R:83-142`.
   - No new file: `R/preparation.R` already holds script 2's ice-mask helper, and its header says preparation steps for scripts 1-3 belong there.
   - It matches on `paste(x, y)`, keeps the predictor row order, and returns both unmatched lists.
   - It stops on a missing column, a duplicate cell-month, an unknown month, a non-numeric column, or a value that is NaN, Inf, below 0 or 1 and above, naming the cells. NA stays NA and exactly 0 passes.
4. **Script 2.** One if/else at `scripts/2_calibration_lct_bluesky.R:59-208`; the ice mask, zero floor and calibration-table write stay inline and shared (`:216-223`).
   - The run record `calibration_albedo` (`:210-214`) gives the source and, per month, cells with an albedo and cells floored from 0. For modis it adds statistic, version, the table's path and MD5 (also recorded by `read_input`), the provenance lines, and both unmatched lists.
   - The modis branch draws two facet maps, `albedo_maps_monthly_modis_cells` and `albedo_missing_monthly_modis_cells`, using the shared map helpers.
   - A parse-level comparison found every original statement still on the raster path, with only the record lines added.
   - No later script, tool or test reads the coarse table or the native/coarse figures, so nothing needed handling.
5. **Script 5.** The denominator is now `sum(!is.na(alb_data))` in both places (`scripts/5_calibration_eval.R:214, 219`), with a comment citing the decision. No anchor file was edited.
6. **Model 7 check.**
   - `fit_calibration_model(..., control = CALIBRATION_CONTROL)` is at `R/model_registry.R:74`; every existing call is unchanged.
   - New tool `tools/check_model7_convergence.R <run-dir> <month>...`: refits through the shared function with the saved fit's own method and `maxit = 2000`. It prints rows, steps, AIC, the largest change in a fitted value, and both convergence lines, and writes nothing.
   - The rows count went into `fit_convergence()` rather than script 4 (decision 3 below).
7. **Header wording.** The window is now described as one "in which that day is the ninth (days 1-16 for day 9; Wang et al. 2018)", in its own commit.
   - The old and new files parse to the same 78 expressions using `code_of()` from `tools/check_comments_only.R`. I called the function directly because the tool's own command line only compares `R/`, `scripts/` and the configs, not `tools/`.
   - The next commit adds `2ee39123…` to `ACCEPTED_OLDER_SHAS` with an entry saying what changed and how it was checked. The script's new SHA is that of commit 9.

## Tests
- **All 18 `tests/test_*.R` files pass.** Three of them need pipeline products that are not in a fresh worktree: `test_paths` (the stats CSV), `test_preparation_ice` and the modern-cell part of `test_preparation_albedo` (`data/lct_modern_reveals_interp.RDS`). I ran those with copies from the main checkout placed in ignored paths, then deleted the copies; the worktree is clean.
- **New tests:**
  - `tests/test_preparation_albedo.R`: the hand-worked toy (all three statistics, two versions, a cell lacking January, a centre unmatched each way, shuffled rows) and every stop case. On the real table: the mixing identity for all four versions, snow-free equal to all-days where the snow-free share is 1, full_75 identical to full_nocut wherever the sun rule cannot act, the 4 and 10 unmatched centres, and agreement with an independent `merge()`.
  - `tests/test_check_model7_convergence.R`.
  - Additions to `test_config.R` (good values, bad values, legacy combinations) and `test_model_registry.R`.
- **All 15 changed R files parse.**
- **MODIS branch of script 2 exercised with stub I/O (not a pipeline run).**
  - Counts:
    - 2,812 cells.
    - 4 calibration centres have no table cell.
    - 58 table centres have no calibration cell: the 10 at 17.5 N plus the 48 ice-masked cells.
  - Per-month counts equal Astra's table: all days January 1,726 … December 1,416; snow-free January 1,227 … December 1,272. There are no zeros, and both maps draw correctly.

## Decisions I had to make
1. **Mixing-identity tolerance.** The identity holds to 1.1e-6, not 1e-6 (about 38 rows per version are over 1e-6). `cell_table()` rounds values and shares to 6 decimals, so I used the rounding bound of 2.5e-6. The snow-free equals all-days check needed the same bound: 7 rows differ by 1e-6 where a tiny snowy share rounds to 0.
2. **Version-column check replaced.** "Equal V_days ⇒ identical albedo" is false on the real table: 322 cell-months differ, by up to 0.083, because days are rounded to 0.01 per pixel. Instead the test asserts full_75 and full_nocut are identical in every column wherever the 75° rule cannot remove a day (May–August, and cells wholly south of 50 N). That holds exactly on 20,632 cell-months.
3. **Rows count in `fit_convergence()`, not script 4.** Script 4's printed convergence lines now end "fitted on N rows" through the function, so the code is written once and the tool reports it too. Script 4 itself is unchanged; if you want the edit literally in script 4, it is two print lines.
4. **Script 2 has one if/else plus a second `if (legacy_raster)` after the shared write,** for the coarse floor, coarse write and scatter. This keeps the raster path's statements in their original order: the scatter needs the floored native table.
5. **Grid read moved into the raster branch.** A MODIS run would otherwise list the grid as an unused input. The only effect on raster runs is the order of the manifest's input list.
6. **Three raster plots wrapped in `print()`.** Inside an if block they are no longer printed automatically, so `Rplots.pdf` would have lost them.

## Anchor files script 5's change will alter
- **Will change:** `tests/anchors/interp-seed1-2026-10-14/calibration_model_stats.csv`, compared byte for byte for seed 1. The "data in credible interval" column changes in essentially every month, because the raster leaves at least 33 cells missing every month (NA per month in the legacy table: 694, 95, then 33 or 34 from March to October, 400, 1,109). Estimates: January 0.71→about 0.94, November 0.8→about 0.93, December 0.56→about 0.92, the others about +0.01.
- **Will fail its tolerance:** `tests/anchors/interp-allmonths-2026-09-20/calibration_model_stats.csv`. Its 0.02 limit on that column will be exceeded in January, February, November and December. The decision speaks of "the one saved reference file", but there are two; re-anchoring the seeded one and the tolerance treatment of the unseeded one are Chris's call.

## Open questions for Chris
1. Do you accept the two test reformulations (decisions 1 and 2)?
2. How should the unseeded anchor be handled — re-anchor it, add a recorded tolerance exception for that column, or compare only the seeded anchor?
3. `config.R` now defaults to modis_cells. A bare script-2 run at the baseline locations would replace the raster-based baseline calibration table (Fable's nit 13), which belongs on the end-of-migration list.
4. The new `analysis.albedo` key will make the manifest consistency check report a settings difference against products made before this change. That is the same effect earlier key additions had, but verification specs that seed old products will need stale inputs allowed (the verification tool already does this in seed/copy mode).
5. The questions-for-Andria files were not updated here. Fable's questions (a snow-free winter albedo under a conifer canopy, minimum snow-free share or weights, cell mean versus centre pixel) are for the main session to file.