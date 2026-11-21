# Reading saved configurations that lack newer settings: `fill_missing`

*18 November 2026, branch `ice-nadi1`, commits `92e6864` (the loader) and `6a95e8d` (the tools).*

## Why

The ice build made `analysis$ice$fraction_source` a required setting. Every configuration saved by a
run before it existed (all 32 `results/*/config_used.R`) lacks it, so `load_config()` refused them and
the tools that reload finished runs stopped. Chris (17 November): "We shouldn't have to bodge this every
time we add a new config setting. Find an elegant fix - like fail with a warning, and then pass an
argument (or a legacy flag) to override missing config errors." Built to Astra's design
(`2026-11-17_config_compatibility_codex_gpt6astra.md`) with Fable's trims and Chris's decisions of
18 November: the argument is `fill_missing`; it works from R and on the command line ("it should work
in the command line and the API"); it is explained concisely where users look.

## How it is used

- **From R:** `load_config(path, fill_missing = TRUE)`.
- **On the command line:** the tools that read finished runs take `--fill-missing` anywhere among
  their arguments: `tools/cross_validate_albedo.R`, `tools/check_cv_separation.R`,
  `tools/explore_cover_contrasts.R`, `tools/compare_cv_hindcasts.R`, and
  `tools/check_cover_contrasts.R`, which reads its runs through the exploration's `read_run()`.
- **Without it**, a missing setting stops the load with the usual message, followed by a hint: a
  pipeline run adds the setting to its configuration file; a tool reading a finished run passes the
  flag. The pipeline (`run_begin()`, the scripts), `tools/verify_change.R` and `tools/compare_ice.R`
  always load strictly.
- **With it**, each setting the file lacks *by name* takes the value in `HISTORICAL_SETTINGS`
  (`R/config_schema.R`): what the pipeline did before that setting existed. Today there is one entry,
  `analysis$ice$fraction_source = "dalton_ice"`: before commit `b2ed943` script 7a read
  `path_file(paths, 'dalton_ice')` directly (that commit's diff shows it). One warning, shown at once,
  lists the values filled. Everything is then checked as usual: a setting written as `NULL` or with an
  illegal value is still refused; the legal `NULL`s (`run$dir`, `analysis$coarse$slice_alias`) are
  kept; a missing setting with no historical value still fails.
- **Adding a setting from now on:** give it its line in `HISTORICAL_SETTINGS`. No other code changes.
  `tests/test_config.R` loads every `results/*/config_used.R` with `fill_missing`, so a setting added
  without its line fails there at once.

## What was built

- `R/config_schema.R`: `HISTORICAL_SETTINGS`.
- `R/config.R`: `fill_missing_settings()`, one small recursive routine. It adds the absent settings,
  each at its place in the schema, so that a filled configuration is `identical()` to the same one
  written out in full (the tools compare configurations with `identical()`). A configuration that is
  already complete is not reordered. `load_config(path, fill_missing = FALSE)` calls it only when asked,
  then runs the existing checks unchanged. `tool_command_line()` separates the flag from a tool's own
  arguments.
- `tools/cross_validate_albedo.R`: the fit and score stages compared the run's settings with those saved
  in `holdouts.rds`, in two places. That comparison is now one function, `check_holdout_settings()`.
  With the flag, it completes the saved holdout settings by the same routine, in memory only.
  `holdouts.rds` is never rewritten, because each predictions file carries its MD5. The holdouts stage
  saves the configuration it loaded itself, so the filled values are loaded and announced once.
- The README, under the table of these tools, says what the flag does; each tool's header and usage
  message mention it.
- After the review: `check_holdout_settings()` names `holdouts.rds` and each value it fills, in one warning
  (`warn_filled()`, shared with `load_config()`); the stage test covers a complete configuration with
  old holdouts.

## Evidence

- Tests at `6a95e8d`, clean tree, each exit status checked, one log: `test_config`,
  `test_cross_validation_stages`, `test_paths`, `test_run_manifest`, `test_tools`,
  `test_cross_validation`, `test_cv_separation`, `test_explore_cover_contrasts` and `test_verify_change`
  all pass. `test_paths` needs the untracked baseline file
  `output/calibration/calibration_model_stats.csv`. This worktree lacked it, so `test_paths` also fails
  at `c0b6eda`. It was linked from the main checkout for the run, then removed. No existing test was
  changed; new tests were only added.
- Mutation checks, each in a scratch copy, confirm that the new tests catch each of these: the table
  entry removed; filled settings appended at the end; `NULL` counted as absent; filling regardless of
  the argument; no warning; holdout settings not completed; the comparison loading strictly; and a new
  setting added to the schema and `config.R` without its table line. With its line added, and with
  `config.R`'s ice choice changed, the new tests pass unedited (the ice build's own check that
  `config.R` chooses `"dalton_ice"` would then need its update, as it does today).
- On the command line, each of the five tools stops at loading without the flag. With it, each gets
  past loading on a copy of `results/run1-main/config_used.R`; there, `compare_cv_hindcasts.R` and
  `check_cv_separation.R prepare` also pass their `identical()` comparisons of two filled
  configurations. `check_cover_contrasts.R inputs` passes in full on the three real runs it checks,
  with their configuration files' MD5 sums as recorded, which shows nothing rewrote them.
- Verification specs: none changed. Every spec that calls these tools is pinned to a commit before
  `b2ed943`, so it runs the old loader, which would read the flag as an unknown argument. The trunk
  has no specs. The six ice specs do not call these tools.

## Still to do before merging

Per `AGENTS.md`: one independent `change-reviewer` review (configuration plumbing, tools and tests), and
a `tools/verify_change.R` spec for the exact commit (checks only: the tests above). The ice work has
no GitHub issue yet (`CONTRIBUTING.md` asks for one per plan).
