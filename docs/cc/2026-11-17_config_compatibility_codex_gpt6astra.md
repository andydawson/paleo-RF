**Add `allow_legacy = FALSE` to `load_config()`, backed by a small table of historical values in `R/config_schema.R`.** With explicit opt-in, fill absent settings from that table, validate everything normally, and warn with the values supplied. This keeps old runs usable while requiring complete configurations for new pipeline runs.

The change needs two core files, small edits to the four saved-run tools, and targeted tests. Cross-validation also needs its saved holdout settings completed in memory before comparison.

The interface should be:

```r
load_config(path = config_path(), allow_legacy = FALSE)
```

Default failure should look like:

```text
config file results/run1-main/config_used.R:
  cfg$analysis$ice$fraction_source is missing

For an old saved configuration, use
load_config(path, allow_legacy = TRUE).
Only settings with recorded historical values can be filled.
```

List every missing setting by its full path. If an entire section is absent, list its missing settings too.

Successful opt-in should produce one warning:

```text
Using historical settings for results/run1-main/config_used.R:
  cfg$analysis$ice$fraction_source = "dalton_ice"
```

A complete configuration produces no compatibility warning, including when the caller passes `allow_legacy = TRUE`.

**Store historical values separately from today’s defaults.** Keep the existing function-based `CONFIG_SCHEMA`, and add this small, ordinary list beside it:

```r
CONFIG_LEGACY_DEFAULTS = list(
  analysis = list(
    ice = list(fraction_source = "dalton_ice")
  )
)
```

`"dalton_ice"` is established by the previous implementation: before commit `b2ed943`, script 7a read `path_file(paths, 'dalton_ice')` directly. Keep this historical value fixed even if `config.R` later selects NADI.

When another setting is introduced, its author supplies its validation rule and, where established, the value that reproduces behaviour before the setting existed. The loader needs no new special case.

A missing setting **without a recorded historical value still fails under the override**. Its message should say that no historical value is recorded. This prevents a missing established setting, such as the requested months, from being silently guessed. Neither `config.R` nor `configs/legacy_config.R` should serve as a blanket source of replacements.

This follows a familiar software practice: Apache Avro supplies declared defaults when reading older records that lack fields, and reports an error when a required field has no default. [Official schema-resolution rules](https://avro.apache.org/docs/1.11.1/specification/#schema-resolution).

For implementation, factor list preparation into one helper in [R/config.R](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/R/config.R:56):

```r
prepare_config(value, schema, defaults,
               allow_legacy = FALSE, path = "cfg")
# Returns list(value = ..., filled = ...)
```

Its work is straightforward:

1. When opted in, fill absent entries from the historical-default list.
2. Run `config_schema_errors()` and stop with all remaining problems.
3. Put the validated setting groups into schema order.

Use small, separate recursive routines for filling and ordering. `load_config()` then runs the existing `config_combination_errors()`, emits the warning, and returns the ordinary settings list. Keep `config_errors()` strict for its existing callers and tests.

The helper accepts schema and default subtrees because CV already stores an `analysis` section separately. That is its only additional use.

The following rules matter:

- **Absence means the name is missing.** Check names, rather than `is.null(value[[key]])`. An explicitly supplied `fraction_source = NULL`, invalid choice or wrong type still fails.
- Preserve the existing legitimate `NULL` values: `run$dir` and `analysis$coarse$slice_alias`. Use list-preserving assignment, such as `[key] = list(value)`, so a future declared historical `NULL` can also be represented.
- Leave unknown keys, duplicate keys and malformed supplied sections available for validation to reject.
- An absent section can be constructed from declared historical values. Loading succeeds only if all its required settings are then present and valid. A supplied `NULL` section remains invalid.
- Run the existing rules across settings after completion.
- Return a plain configuration list. Keep the list of filled values separately; attaching it as an attribute would affect `identical()`.

**Order all successful loads by the schema, including complete configurations.** The schema currently places `fraction_source` first within `ice`; simply appending it to an older list would break comparisons with an explicitly complete configuration. Reorder setting groups only, preserving vector order, values and types. Perform ordering after validation so it cannot discard unknown or duplicate entries.

The caller policy should be explicit in code:

| Caller | Change |
|---|---|
| [compare_cv_hindcasts.R:111](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/tools/compare_cv_hindcasts.R:111) | Pass `function(path) load_config(path, allow_legacy = TRUE)` to `read_noted()`, retaining its input recording. |
| [explore_cover_contrasts.R:63](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/tools/explore_cover_contrasts.R:63) | Opt in inside `read_run()`. Its verification callers inherit this behaviour. |
| [check_cv_separation.R:38](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/tools/check_cv_separation.R:38) | Opt in for both saved configurations. |
| [cross_validate_albedo.R:42](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/tools/cross_validate_albedo.R:42) | Explicitly branch: opt in when reading an existing `config_used.R`; keep the fallback `load_config('config.R')` strict. |
| `R/run_manifest.R`, pipeline scripts | Keep strict loading. |
| `tools/verify_change.R` | Keep new-run preparation and loading strict. Checks that inspect old runs obtain compatibility through the saved-run readers above. |
| `tools/compare_ice.R` | Keep strict loading: it reads the checkout’s current configuration. |

A command-line flag would add plumbing without helping these dedicated saved-run readers. The explicit function argument is sufficient. `configs/legacy_config.R` remains a complete configuration required to pass strict loading.

**CV needs one additional correction.** Its fit and score stages compare loaded settings with raw `holdouts$analysis` from an older `holdouts.rds`, at [line 291](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/tools/cross_validate_albedo.R:291) and line 374. Fixing the file loader alone would make these comparisons fail.

Replace the duplicated comparison with one small local function. It should:

- Prepare the saved analysis using the same helper, `CONFIG_SCHEMA$analysis`, and `CONFIG_LEGACY_DEFAULTS$analysis`, with explicit opt-in.
- Compare the result with the fully validated, ordered analysis from `run_config()`.
- Report any filled settings with the holdout file identified.

Equality with the validated configuration also protects the rules across analysis settings. Explicit Dalton and NADI settings must still compare differently.

Keep this completion entirely in memory. Existing prediction files contain the MD5 of the original `holdouts.rds`; rewriting that file would invalidate their association.

**The pipeline manifest needs no format change.** [run_begin()](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/R/run_manifest.R:40) already records the configuration file’s MD5 and the full evaluated configuration. Its strict load means every successful pipeline manifest continues to contain explicitly supplied settings.

Keep historical manifests and `check_producer()` unchanged. An old producer manifest lacking a setting must still trigger the existing stale-input check; `allow_legacy` must not grant permission to reuse pipeline inputs. The existing `run$allow_stale` mechanism remains responsible for that decision and its record.

The saved-run tools retain their existing provenance records. Where they save evaluated settings, those will contain the completed values. Original configuration files, holdout files and manifests retain their original bytes.

The tests should establish the following:

| Test | Required result |
|---|---|
| Actual `results/run1-main/config_used.R` | Strict failure names the setting and override; opt-in supplies Dalton and warns once. Existing values remain unchanged. |
| Complete configurations | No compatibility warning; explicit Dalton and all NADI choices survive. |
| Multiple missing settings | Every path is reported; a missing field without a historical value still fails under opt-in. |
| Invalid input | Explicit invalid `NULL`, wrong types, unknown/duplicate keys and malformed sections remain errors. Existing legal `NULL` values survive. |
| Small synthetic schema | Several additions, an absent nested section and a legitimate historical `NULL` work through the same mechanism. Declared defaults satisfy their validators. |
| Ordering and validation | Reordered equivalent configurations become `identical()`; meaningful value/vector differences remain different; rules across settings still run. |
| Old CV fixture | Fit and score pass with old-style configuration and holdout settings; genuine setting differences fail; holdout MD5 and prediction associations remain intact. |
| Pipeline/manifests | Incomplete configuration fails startup and records failure; complete settings are fully recorded; old producer manifests still encounter stale-input checks. |
| Saved-run reader | Cover-contrast input reading succeeds with a missing new setting, leaving source files unchanged. |

Use the existing fixtures in `tests/test_config.R`, `tests/test_cross_validation_stages.R`, `tests/test_run_manifest.R` and `tests/test_explore_cover_contrasts.R`. The CV fixture already uses stand-in fits, so this requires no expensive model fitting.

For Opus, implement in this order:

1. **Record the plan and acceptance checks in a GitHub issue.** Use a separate task worktree and the branching protocol in `CONTRIBUTING.md`; integrate the change with the ice build before verifying it.
2. **Add the historical-default declaration and core helpers.** Improve missing-setting messages, implement strict-default loading, retain full validation, and add config tests.
3. **Update the four saved-run readers and the shared CV comparison.** Add the CV and saved-reader regression cases.
4. **Add the manifest regression checks and concise documentation.** Explain the argument, caller policy and fixed meaning of historical defaults in the loader comments, README and changelog. Record the pre-selector Dalton code as evidence.
5. **Obtain one independent `change-reviewer` review.** This is configuration plumbing. Keep scientific calculations unchanged.
6. **Verify the exact implementation commit through `tools/verify_change.R`.** Use a checks-only spec covering parsing, the affected tests, existing path/verifier tests, and the real cover-contrast input check where its data are available. Keep all generated evidence in the verifier’s worktree and normal report locations.
7. **Commit the evidence, integrate and push under the repository protocol.** Update and close the issue at merge; report remaining branches and occupied worktrees as required.

Two unnecessary additions were excluded during review: configuration-version registries and compatibility attributes on returned settings.

This was a read-only review of `d1a2f64`. All 32 configurations under `results/*/config_used.R` lack the new setting. No files were changed, no R tests were run, and nothing was committed or pushed.