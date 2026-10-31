# Implementation brief: the refit on the rebuilt MODIS albedo (code and tests only)

You implement code for paleo-RF, an R pipeline (Chris McWilliams, contractor; Andria Dawson, PI).
Work ONLY in the worktree /tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-refit-modis (branch refit-modis, made from feature/single-config at
0c65aa7). Never touch the main checkout /home/expert/Documents/contracting/Andria/paleo-RF except to
read data files from it, never switch branches anywhere, never push, never merge. Commit each atomic
change on refit-modis with a why-focused message (imperative subject; body says what and why), ending
with the line:
Claude-Session: https://claude.ai/code/session_01UxGrk8eCToaRo9WLgzHPsd

NO pipeline runs (scripts 1-10) and no verification runs: Chris wants the code reviewed first. You may
run the test files and small R checks. R: /home/expert/micromamba/envs/paleo-rf/bin/Rscript with
PROJ_LIB=PROJ_DATA=/home/expert/micromamba/envs/paleo-rf/share/proj and OPENBLAS_NUM_THREADS=1.

## Read first
- AGENTS.md and CONTRIBUTING.md (rules: readability before elegance; no duplicated code; small
  functions with a stated purpose in R/ when shared; comment why, not what; never remove a library()).
- The decisions you implement: docs/cc/2026-10-29_refit_plan_decisions.md. Background: Astra's plan
  docs/cc/2026-10-29_refit_plan_codex_gpt6astra.md and Fable's review docs/cc/2026-10-29_refit_plan_review_fable.md.
  Where they disagree, the decisions file says which Chris chose: it is Fable's MINIMAL code shape.
  Do not add anything Chris did not decide (no winter-override setting, no new support product, no
  comparison tool, no monthly-support figures).
- The cell table and its maker: data/albedo_modis_cells.csv and data/albedo_modis_cells_provenance.txt
  in the main checkout (columns described in tools/prepare_bluesky_albedo.R, climatology() and
  cell_table(), and in Astra's plan); scripts/2_calibration_lct_bluesky.R; scripts/5_calibration_eval.R;
  R/model_registry.R; R/paths.R; R/run_manifest.R; R/config_schema.R; config.R;
  configs/legacy_config.R; tests/.

## What to build (Chris's decisions, 29 October)
1. Commit the cell table and its provenance file (copy from the main checkout into data/ of the
   worktree, byte-identical; check with md5sum) as a prepared input, as data/elev_land_mean_cells.csv
   was: add both to PATH_CATALOGUE (R/paths.R) so read_input() can read and hash them, and list them in
   tests/test_paths.R's prepared_inputs (fix whatever counts that test asserts). Check .gitignore does not
   hide them.
2. Configuration: new settings for the calibration albedo (choose the place in the config tree that
   matches the existing structure, e.g. analysis$calibration or a sibling):
   source = "modis_cells" or "legacy_raster"; statistic = "all_days", "snow_free" or "snowy" (the cell
   table's column V, V_snowfree, V_snowy); version = "full_75", "any_75", "full_70" or "full_nocut".
   config.R: modis_cells / all_days / full_75. configs/legacy_config.R: legacy_raster, and under
   legacy_raster every other albedo key must hold its default (schema refuses otherwise). Validate in
   R/config_schema.R; extend the config tests. Plain comments for Andria in both config files saying
   what each value means and where the decision is recorded.
   The winter check needs no new setting: it is a run with analysis months November-February and
   version full_nocut.
3. One tested function in R/ (a small new file is fine if no existing helper file fits; say why) that
   takes the cell table, the modern predictor cells (x, y) and the chosen statistic and version, and
   returns the monthly albedo table jan..dec in the predictor table's row order, matched on exact cell
   centres (paste(x, y), as script 1 does for elevation), plus the unmatched centres both ways. It
   checks: required columns present; unique (x, y, month); months recognised; selected values numeric,
   finite, 0 <= v < 1 (stop naming offending cells otherwise; exactly 0 is allowed and later floored as
   now). A missing cell-month stays NA; nothing is filled.
4. Script 2: one if/else. legacy_raster: the original lines unchanged (byte-identical behaviour,
   including the coarse table and the native/coarse figures). modis_cells: the function above; no
   coarse table, no native/coarse figures; instead one facet map of the selected monthly albedo and
   one of where it is missing (reuse R/map_helpers.R). The existing ice mask, the zero floor and the
   write of the calibration table stay inline, shared by both branches, and the calibration table
   keeps exactly its current columns (script 3 melts every non-identifier column as albedo). The run
   record (run_record) states the source, statistic, version, the cell table's path and hash (via
   read_input), per month the non-missing count and the count floored from 0, and both unmatched
   lists. Check whether any later script reads the coarse table or the native figures; if one does,
   report it and handle it minimally (the decisions do not cover that case: say so in your report).
5. Script 5: the share of observations inside the credible interval counts only cells with an
   observation, for both sources (Chris's decision; the denominator is currently n(), which counts
   cells with no observation). Do NOT regenerate or edit any anchor file: re-anchoring is a later,
   separate commit after a verification run. Say in your report exactly which anchor file(s) will
   change and why.
6. Model 7 check: an optional control argument on fit_calibration_model() (default the existing
   CALIBRATION_CONTROL, so every existing call is unchanged), and a small tool in tools/ that refits
   model 7 for named months at maxit = 2000 from a run folder's calibration table, using the shared
   fitting function (no copied bam call), and reports iterations, convergence and AIC beside the saved
   500-step fit. Script 4: append the number of fitted rows to its printed convergence line.
7. The build script's header comment (tools/prepare_bluesky_albedo.R, the Product paragraph) says the
   16-day window is "centred" on the day: Wang et al. 2018 say the day is the 9th of the 16 (days 1-16
   for day 9). Correct the wording only, in its own commit. Because the script's SHA-256 gates the cell
   step, add the old SHA (2ee39123d879995c219b65b1749726384d2351e9b990bf05d6d7ffa6b6ba1aa5) to
   ACCEPTED_OLDER_SHAS with an entry saying what changed and how it was checked (tools/check_comments_only.R
   on the diff; read the rule at lines 95-100 of that script).

## Tests (write them; run them; all must pass)
- Toy test of the function, expected values written by hand: two cells, two months, one cell lacking
  January, rows shuffled, each statistic and a version; a duplicate key and a value of 1 must stop.
- On the real cell table (skip with a message if the file is absent): the mixing identity
  share_snowy*snowy + share_snowfree*snowfree + share_unknown*unknown == all within 1e-6 wherever all
  parts are present (treat NA parts as 0 with share 0); where V_days are equal for full_75 and
  full_nocut the two albedos are identical; where share_snowfree == 1 the snow-free value equals the
  all-days value.
- Schema tests for the new settings (good values, bad values, legacy combinations).
- The existing tests still pass (run every tests/test_*.R that runs without the frozen fits; list
  which you ran and which you could not).
- Parse every changed R file.

## Report (your final message)
Branch tip and commit list (subject lines); per decision item what you did, with file and line; the
tests run and their results; anything you could not do or had to decide yourself; the anchor files
script 5's change will alter; open questions for Chris.
