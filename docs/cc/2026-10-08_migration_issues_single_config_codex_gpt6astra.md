# Migration design: the single-config work as a set of issues

**What this is.** The design for migrating the pipeline to one configuration file with
per-script manifests, written as thirteen implementation issues plus one parked
ensemble issue, with a dependency map saying which can run in parallel. It follows the
two design reviews of 2026-10-07 and Chris's decisions of 2026-10-08, which are
restated in the appended brief. The issues are meant to be adversarially reviewed and
then filed on GitHub and handed to implementation agents, one issue per agent.

**Who wrote it.** OpenAI Codex CLI 0.155.1, model `gpt-6-astra`, reasoning effort `max`,
driven by a Claude Code session on 2026-10-08. The codex sandbox cannot start on this
workstation, so the model had no shell: the repository files were supplied inline with
line numbers (AGENTS, CONTRIBUTING, README, both 2026-10-07 reviews, the scientific
questions file, `R/run_manifest.R`, `R/map_helpers.R`, scripts 1 to 9 except the
optional spatial-eval script, and the anchor READMEs), as of `chris-dev` 2697b0f. It
notes where the two files it did not see (`6_prediction_model_spatial_eval.R`,
`scripts/make_grid.R`) must be read by the implementer. 127,302 tokens used.

**Status.** Design, not yet reviewed and not yet filed. Nothing has been implemented.

**Decisions it was built on** (Chris, 2026-10-08): `config.R` with `analysis` and
`presentation` sections; scientific decisions in the config as selectors among
implemented alternatives, open questions flagged by id; one plain-text manifest per
invocation; the toned-down consistency check (whole `analysis` section compared, stop on
difference, `RUN_ALLOW_STALE=1` override recorded); output paths unchanged so the anchors
keep working; scope is steps 1 to 4 of the adversarial review's section F, with the
ensemble driver parked as a skeleton issue; one long-lived feature branch off `chris-dev`
while Andria's review continues there.

---

# Part 1. Dependency map

Use **13 implementation issues and one parked ensemble issue**. The sequence follows the second review’s first four steps; the stricter provenance machinery proposed in either review is superseded by Chris’s decisions.

| Issue | Depends on | Reason for the dependency |
|---|---|---|
| I01 — Establish migration and regression rules | — | Establish the feature branch and verification contract before changing behaviour. |
| I02 — Remove assumptions about twelve selected months | I01 | Baseline comparisons must exist before fixing indexing and dimensions. |
| I03 — Add the validated config and migrate script 9 | I02 | Shared scripts and month handling must be safe before exposing configuration. |
| I04 — Migrate the remaining implemented settings | I03 | Uses the loader/schema and extends the same config. |
| I05 — Implement manifest v2 | I03 | Uses the resolved-config representation established there. |
| I06 — Instrument every pipeline invocation | I04, I05 | Requires both the complete configuration and stable manifest API; touches every wrapper. |
| I07 — Centralise artifact paths | I06 | Replaces paths inside the newly instrumented reads/writes without changing provenance behaviour. |
| I08 — Extract preparation stages and data contracts | I07 | Establishes common function contracts and identity handling. |
| I09 — Extract calibration and evaluation stages | I10 | Reuses prediction/simulation functions, including for the optional spatial experiment. |
| I10 — Extract prediction functions | I08 | Uses explicit data, configuration, paths and optional draw identity. |
| I11 — Extract the two differencing stages | I08 | Uses the same identity contract; owns both difference implementations. |
| I12 — Extract kernel sampling and application | I08 | Uses the same identity contract and stable artifact paths. |
| I13 — Extract aggregation and verify the migration | I09, I11, I12 | Final verification must follow the completed producers; owns the downstream integration gate. |
| I14 — Park the ensemble-driver design | I13 | Records future requirements without implementing an ensemble. |

**Parallel work:** I04 and I05 may run concurrently because they own separate implementation files. After I08, I10, I11 and I12 may run concurrently; I09 follows I10. Aggregation extraction can be drafted earlier, but I13 cannot merge before its dependencies and integration checks pass.

Use separate worktrees with private writable `data/`, `output/`, `figures/` and `runs/`. Baseline filenames collide if agents share output directories. Serialise shared documentation merges, and never edit a script during its execution (`AGENTS.md:41`).

**Suggested merge order:** I01 → I02 → I03 → I04/I05 → I06 → I07 → I08 → I10 → I09 → I11 → I12 → I13. I11 and I12 can merge earlier once verified.

Every issue below uses a topic branch off **`feature/single-config`**, with atomic, why-focused commits, a `--no-ff` merge back and checkpoint/end-of-session pushes. The final feature integration must incorporate Andria’s intervening edits before merging into `chris-dev`; neither `main` nor `legacy` is touched.

# Part 2. The issues

## I01

**Title:** Establish the migration branch and regression contract

**Depends on / blocks:** None / I02 and all subsequent implementation.

**Goal:** Protect Andria’s review while establishing what constitutes an unchanged result. Separate historical-anchor limitations from regressions introduced by this migration.

**Scope:** Update `CONTRIBUTING.md:17`, `CONTRIBUTING.md:40` and `CONTRIBUTING.md:69` for the temporary branching protocol and authorised root `config.R`. Add `docs/cc/2026-10-08_single_config_regression_contract.md` and comparison tooling under `tools/`. Correct the obsolete interp-anchor inventory at `tests/anchors/README.md:16`; do not replace anchored artifacts or checksum files.

**Design:** Create `feature/single-config` from the current `chris-dev`. Record the starting commit, input checksums, environment/thread settings and current output inventory.

The regression contract must distinguish:

- Deterministic artifacts: compare against their filename entries in `MD5SUMS.txt`; no automatic tolerance fallback.
- Fitted models: compare formulas, predictions and numerical diagnostics, excluding call/environment identity (`tests/anchors/README.md:46`).
- Unseeded summaries: historical comparisons need agreed numerical tolerances (`tests/anchors/interp-allmonths-2026-09-20/README.md:13`).
- Script 5 statistics: stochastic despite the anchor table’s “yes”, because they use simulations (`scripts/5_calibration_eval.R:116`, `scripts/5_calibration_eval.R:185`).

For refactor-specific stochastic checks, run original and candidate computations with identical inputs, models and test-only RNG state. Do not introduce a production seed as part of this migration.

**Verification:** Run the baseline sequence 1 → 2 → 4 → 5 → 6, then separately run 7, 7a and 8 against the frozen prediction inputs; run 9 against frozen tail inputs. Record script 5’s known late failure at `scripts/5_calibration_eval.R:218`. Check all applicable interp MD5 entries, inspect LFS artifacts for pointer files, and capture script 9’s four CSVs as a comparison reference.

Compare cached elevation against the historic land-cover tables before claiming exact reproduction: the cache at `scripts/1_veg_lct_prep.R:58` postdates the live-download caveat in the anchor README.

**Acceptance criteria:**

- [ ] Regression commands, artifact mappings and exceptions are recorded.
- [ ] Original anchors remain immutable; regenerated tracked outputs are not committed.
- [ ] Feature/topic workflow is documented; both PI question files are maintained.

**Open points:** Chris must approve historical stochastic tolerances and any demonstrated elevation-related exception. The supplied READMEs contain no numerical tolerances; implementers must not invent passing thresholds after seeing candidate results.

## I02

**Title:** Remove positional month indexing and fixed dimensions

**Depends on / blocks:** I01 / I03.

**Goal:** Make month subsets and reordered selections safe before adding a configurable month vector. Preserve the twelve-month baseline exactly.

**Scope:** Change month-related constructs in `scripts/2_calibration_lct_bluesky.R:37`, `scripts/4_calibration_model.R:113`, `scripts/5_calibration_eval.R:90`, `scripts/6_prediction_model.R:72`, `scripts/7_plot_preds.R:171`, `scripts/7a_alb_diff_full.R:159` and `scripts/8_radiative.R:81`. Audit fixed February/November and seasonal sections at `scripts/7_plot_preds.R:202`, `scripts/5_calibration_eval.R:306` and `scripts/9_forcing_barplot.R:333`. No public month setting yet.

**Design:** Define the canonical calendar once in `R/calendar.R`:

```r
MONTHS <- tolower(month.abb)
month_number <- function(month) match(month, MONTHS)
```

Reject unknown, duplicated or empty selections. Preserve selected-vector order while always mapping February to band 2, May to 5, and so on.

Size AIC columns and monthly lists from the selected months. Name the satellite’s twelve source bands with the canonical calendar, then select bands; never assign four names to a twelve-band raster.

Replace both 25-age coverage constants with the expected age count, and detect duplicate/missing keys separately. Preserve the existing fact that `alb_grid_full_new` is diagnostic and is not used by the difference loop (`scripts/7a_alb_diff_full.R:167`, `scripts/7a_alb_diff_full.R:217`).

Month-specific plots must skip unavailable months explicitly. The recovered EGU comparison requires its four recipe months; do not silently calculate a partial recipe or label a subset mean “annual”.

**Verification:** Run 2, 4, 5, 6, 7, 7a, 8 and 9 at baseline using I01’s fixed-input comparisons. Exercise internal month arguments with `c("feb","may","aug","nov")`, reversed order and one month. Compare each selected kernel band and resulting numeric rows with the corresponding full-calendar rows. Test missing and duplicated age keys.

**Acceptance criteria:**

- [ ] Baseline deterministic checksums match; stochastic comparisons follow I01.
- [ ] No band selection depends on position within selected months.
- [ ] Topic merges to `feature/single-config` with `--no-ff`; question logs remain current.

**Open points:** Any apparent coverage “fix” that changes retained cells must be referred to Chris and kept outside this prerequisite.

## I03

**Title:** Add validated configuration and migrate script 9

**Depends on / blocks:** I02 / I04, I05.

**Goal:** Establish the configuration contract using script 9’s already explicit assumptions. Centralise presentation windows without changing their existing meanings.

**Scope:** Add root `config.R`, `R/config.R` and `R/config_schema.R`. Lift settings from `scripts/9_forcing_barplot.R:109`; preserve its explanatory header at `scripts/9_forcing_barplot.R:37`. Update `R/run_manifest.R:78` to embed resolved JSON. Centralise windows from `R/map_helpers.R:21`, `scripts/1_veg_lct_prep.R:169`, `scripts/7_plot_preds.R:41`, `scripts/7a_alb_diff_full.R:35` and `scripts/8_radiative.R:19`, including consumers in scripts 2 and 3.

**Design:** The file returns exactly:

```r
list(
  analysis = list(
    forcing = list(
      earth_area_m2 = 5.101e14,
      variant = "veg_ice_thresh", # C1; C5(a)
      report_kernels = c("hadgem", "cam5", "cack"),
      sensitivity_variants = c(...) # existing six, C5(a)
    ),
    period_breaks = c(50, 500, 2000, 4000, 6000, 8000, 10000, 12000)
  ),
  presentation = list(map_windows = list(...))
)
```

Add other keys only when their consumers are wired. Preserve script 9’s existing aggregation algorithms; do not add singleton switches for equal weighting or summing intervals.

Evaluate one list expression in a bare environment containing only approved deterministic constructors/constants. Reject assignments, arbitrary calls, namespace access, file/environment reads, unknown keys and unsupported combinations. A child of `baseenv()` alone does not enforce those restrictions.

Preserve three named windows: calibration `(-172,-50)/(15,80)`, tail `(-166,-50)/(12,82)`, diagnostics `(-172,-50)/(17,79)`. Pass windows explicitly through map helpers; do not make helpers discover configuration.

The resolved record contains both sections. Only `analysis` will participate in consistency checks.

**Verification:** Run 9 against frozen tail inputs; compare all four CSVs byte-for-byte with I01’s reference. Run 1 with diagnostics and scripts 2, 3, 7, 7a and 8 for unchanged window bounds and numeric artifacts. Test invalid configuration and JSON round-tripping, including named vectors and one-element vectors.

**Acceptance criteria:**

- [ ] Script 9 retains its assumptions and current numerical behaviour.
- [ ] All three windows have one definition each; existing manifests contain resolved JSON.
- [ ] Topic/merge/push protocol and both question logs are maintained.

**Open points:** C1/C5 remain scientific questions, not migration blockers. Link relevant keys from their existing question entries; do not reopen the format decision.

## I04

**Title:** Centralise the remaining implemented analysis settings

**Depends on / blocks:** I03 / I06.

**Goal:** Make implemented analysis choices visible and validated without advertising new analyses. Keep formulas versioned in R and preserve baseline behaviour.

**Scope:** Extend the config/schema and wire scripts 1–8. Add `R/model_registry.R` for `scripts/4_calibration_model.R:28` through its spatial experiments and repeated mod8 fit at `scripts/4_calibration_model.R:234`. Replace all three selected-model decisions at `scripts/5_calibration_eval.R:28`, `scripts/5_calibration_eval.R:98` and `scripts/5_calibration_eval.R:327`. Fix draw-name parsing at `scripts/6_prediction_model.R:46` before exposing draw counts.

**Design:** Add:

- Selected months, physical ages and modern age 50.
- Model ID; existing smooth dimensions; shared `nthreads=8`, `maxit=500`.
- Separate evaluation and prediction response-draw counts, both 100; require counts supported by existing summaries, without a zero-draw mode.
- Computational input paths, domain limits and ice threshold 0.5.
- Three ice-albedo roles: coarse=`ice_albedo`, fixed=`ice_albedo_fixed`, scaled=`ice_albedo_sc`, preserving `scripts/7_plot_preds.R:165` and `scripts/7a_alb_diff_full.R:123`.
- CACK year 2003 as a numeric parameter mapped to the existing annual-layer reader; no climatology selector.

Include script 7’s `long < -60` cutoff in **analysis**, because it affects saved coarse differences (`scripts/7_plot_preds.R:196`). Preserve strict `x > -170`, `lat > 27` and `lat < 74`.

Separate physical ages from the legacy coarse age used for polygon matching. Preserve the current 11,500→12,000 lookup behaviour under analysis with a C7 comment; changing only a plot label must not select different ice polygons (`scripts/7_plot_preds.R:85`, `scripts/7_plot_preds.R:130`).

Record expanded registry formulas in manifests. Keep `"bluesky"` as an implementation constant: there is no second implemented product. Likewise, no flavour or reduction selector: diagnostic medians are not a production median-with-closure implementation (`scripts/1_veg_lct_prep.R:34`, `scripts/1_veg_lct_prep.R:42`).

Use C0a/C1, C3, B1/B4, A2/A3 and B10 comments where applicable. Runtime notes, thread environment and strictly parsed `DIAGNOSTIC` remain run metadata.

**Verification:** Run 1, 2, 4, 5 and 6; apply I01’s upper-pipeline comparisons. Run 7, 7a and 8 with frozen prediction inputs and check tail MD5s. Exercise an alternative existing model, each ice-column role and a draw identifier above 999. Nonbaseline runs test functionality, not anchor equality.

**Acceptance criteria:**

- [ ] No accepted key is ignored, singleton or an unimplemented method.
- [ ] Baseline formulas, selections, domains, ice roles and artifacts are preserved.
- [ ] Topic/merge/push protocol and PI question cross-references are maintained.

**Open points:** Do not resolve C0/C2/C3, A2 or C7 scientifically. Any newly discovered unsupported combination must fail validation rather than acquire invented semantics.

## I05

**Title:** Implement one reliable manifest per invocation

**Depends on / blocks:** I03 / I06.

**Goal:** Persist honest provenance before work begins and retain it after failure. Support the agreed whole-analysis comparison without adding a workflow engine.

**Scope:** Replace the singleton context at `R/run_manifest.R:17`, deferred creation at `R/run_manifest.R:29`, minute naming at `R/run_manifest.R:48`, late input hashing at `R/run_manifest.R:83` and missing output hashes at `R/run_manifest.R:86`. No sidecars, lineage unions, per-script setting declarations or scheduler.

**Design:** Use explicit contexts:

```r
run_script(script, config_path, function(run, cfg) { ... })
read_input(run, path, reader)
write_output(run, path, writer)
```

Create `runs/<producer>/<UTC-second>-<pid>-<counter>.md` immediately. One readable Markdown file contains a labelled JSON record with resolved config, full commit, dirty flag, status, input/output paths and MD5s, overrides and errors. Retain existing useful runtime metadata.

Start the record before config validation/package loading; a configuration failure records its error and unavailable resolved config. Caught errors transition to `failed`; completion follows successful writes and device closure. Abrupt termination leaves `started`.

Hash inputs immediately before reading and outputs after successful closure, without the 2 GB exemption. Register only successful writes. Dirty detection must include root `config.R`, `scripts/` and all `R/`, including untracked files (`R/run_manifest.R:39`).

Map each derived output path to its producer; producer manifests follow the naming convention above. Select the latest invocation declaring that exact output path, verify its registered checksum, and never fall back past a newer unsuccessful write. External inputs need checksums but no producer manifest.

Compare every input manifest’s complete `analysis` section with current analysis; print dotted keys and old/new values. Stop on mismatch or unavailable provenance unless `RUN_ALLOW_STALE=1`; record the override and each discrepancy. A missing data file always fails. Do not reject merely because producer and consumer commits differ.

Successfully registered partial outputs from a failed invocation remain identifiable; consuming them must disclose the producer’s failed status.

**Verification:** Test same-second invocations, invalid config, missing inputs, errors before/after output, abrupt termination, changed inputs, stale manifests, nested config differences and presentation-only changes. Verify output hashes independently and exercise a large-file hash. No numerical pipeline algorithm changes here.

**Acceptance criteria:**

- [ ] Exactly one durable manifest exists per invocation, including failures.
- [ ] Analysis changes stop; presentation changes pass; overrides are visible.
- [ ] Feature-topic protocol is followed; no additional provenance files are introduced.

**Open points:** None requiring scientific judgement. Legacy inputs without manifests use the documented override during migration verification; never fabricate historical provenance.

## I06

**Title:** Wire manifests into every live pipeline script

**Depends on / blocks:** I04, I05 / I07.

**Goal:** Give standalone execution and `source()` the same provenance behaviour. Record exactly what each invocation reads and produces.

**Scope:** Instrument scripts 1–9, including 7a, optional script 3 and optional spatial evaluation. Replace `Filter(file.exists, ...)` at `scripts/7_plot_preds.R:17`, `scripts/7a_alb_diff_full.R:18`, `scripts/8_radiative.R:27` and `scripts/9_forcing_barplot.R:131`. Replace directory-wide output discovery at `scripts/7_plot_preds.R:552`. Remove only script 8’s unused ice-table reads/declarations (`scripts/8_radiative.R:32`, `scripts/8_radiative.R:38`).

**Design:** Place package loading, config resolution, computation and plotting inside the protected invocation. Instrument actual reads and writes, including monthly files, diagnostic CSVs, figures and implicit graphics devices.

Close PDF devices before registering hashes; preserve explicit printing when moving expressions into functions. Include the EGU PNG omitted from script 9’s current output list (`scripts/9_forcing_barplot.R:349`, `scripts/9_forcing_barplot.R:358`).

Treat the committed elevation cache as a checksummed input when present. If absent, record the existing AWS lookup and newly written cache; never silently omit it (`scripts/1_veg_lct_prep.R:58`).

Script 5’s existing late failure must produce `failed`, retaining its successfully written selected models and statistics. This issue does not fix the path mismatch.

**Verification:** Run every supplied numbered script and script 1 in diagnostic mode. Compare artifacts using I01; fixed-anchor inputs without provenance require an explicit recorded override. Trigger script 5’s late failure. Run 8 without script 7’s ice tables and require the forcing MD5 to match; script 9 must still require script 7’s coarse differences.

**Acceptance criteria:**

- [ ] Every live invocation logs status and exact artifacts; stale directory contents are excluded.
- [ ] Successful and failed `Rscript`/`source()` executions are covered.
- [ ] Feature-topic protocol and both question logs are maintained.

**Open points:** The full `6_prediction_model_spatial_eval.R` and `scripts/make_grid.R` are absent from the supplied bundle. Obtain them before claiming complete instrumentation; the optional script’s unreviewed status is explicit at `CONTRIBUTING.md:80`.

## I07

**Title:** Centralise paths while preserving baseline filenames

**Depends on / blocks:** I06 / I08.

**Goal:** Give producers and consumers one path vocabulary. Preserve every existing baseline output name and remove the calibration reader/writer disagreement.

**Scope:** Add `R/paths.R`; replace numbered-script path construction, especially all five prediction output families at `scripts/6_prediction_model.R:33`, `scripts/6_prediction_model.R:48`, `scripts/6_prediction_model.R:60`, `scripts/6_prediction_model.R:85`; differences at `scripts/7a_alb_diff_full.R:323`; forcing at `scripts/8_radiative.R:195`; its reader at `scripts/9_forcing_barplot.R:141`. Move producer lookup from manifest code into this single path catalog.

**Design:**

```r
paths <- pipeline_paths(cfg, profile = baseline_paths())
path_prediction(paths, kind, month = NULL)
path_calibration_model(paths, model_id, month)
path_forcing(paths)
```

A profile is an explicit path-layout argument, not a third config section or a singleton config switch. The default returns today’s paths, including the untagged forcing filename. Future callers can redirect derived data, outputs, figures and manifests while retaining external input paths.

Fix script 5’s `spatial_experiment/` reads to use script 4’s actual output paths (`scripts/4_calibration_model.R:161`, `scripts/5_calibration_eval.R:218`). Map `SP_ELEV_LC` to the full spatial/elevation/cover fit, independently of the configurable selected model. Preserve the producer’s unusual filename spelling.

**Verification:** Compare the complete baseline path inventory with I01. Run 4→5→6 and 7/7a→8→9; script 5 should now complete. Compare numerical outputs and all applicable anchors. Redirect a small fixture run and assert no baseline artifact is overwritten and producer lookup still works.

**Acceptance criteria:**

- [ ] No existing output is renamed; MD5 filename mappings remain valid.
- [ ] Producer and consumer paths agree, including spatial experiments.
- [ ] Feature-topic protocol is followed; no scheduler or ensemble is added.

**Open points:** Newly executable script 5 sections require validation, not a claim that all their artifacts were historically anchored.

## I08

**Title:** Extract preparation functions and explicit data contracts

**Depends on / blocks:** I07 / I10, I11, I12.

**Goal:** Make land-cover and calibration-table preparation callable without sourcing scripts. Establish identity and dependency conventions for later stages.

**Scope:** Extract numerical work from `scripts/1_veg_lct_prep.R:40`, `scripts/1_veg_lct_prep.R:58`, `scripts/1_veg_lct_prep.R:78`, `scripts/2_calibration_lct_bluesky.R:123` and script 3’s preparation at `scripts/3_plot_cal_lct_albedo.R:51`. Add `R/preparation.R` and `R/stage_contracts.R`. Plots remain in scripts; no median production mode.

**Design:**

```r
reduce_land_cover(posts, cfg)
attach_elevation(cover, elevation_lookup)
prepare_calibration(cover, satellite, grid, cfg)
```

Keep network/cache I/O explicit in the wrapper. Validate unique cache coordinates, finite required elevations and complete lookup coverage; never refresh a present cache implicitly.

Functions take data/config explicitly and return named results; they do not read environment variables, source scripts or discover files. Establish one shared helper for optional integer `lc_draw` identity. Preserve it when present; raw posterior `iter` retains the current mean-reduction semantics. Baseline outputs gain no columns or attributes.

Move script 3’s numerical preparation into callable helpers; obtain the missing grid-helper source before relocating its implementation.

**Verification:** Run 1 with/without diagnostics, then 2 and 3. Compare land-cover outputs against the same-cache baseline and apply the historic elevation exception only if I01 approved it. Compare script 2’s anchored native table byte-for-byte using fixed modern inputs; compare the coarse table with I01’s reference. Test cache gaps and duplicate coordinates.

**Acceptance criteria:**

- [ ] Preparation is callable without plotting or network access.
- [ ] Baseline schemas/order and cache behaviour are preserved.
- [ ] Feature-topic protocol and both question logs are maintained.

**Open points:** Missing grid-helper source; any elevation discrepancy outside I01’s approved exception.

## I09

**Title:** Extract calibration fitting and evaluation functions

**Depends on / blocks:** I10 / I13.

**Goal:** Move model fitting and numerical evaluation into reusable functions while keeping diagnostic plots in their scripts. Reuse the common prediction/simulation implementation.

**Scope:** Extract fitting and comparisons from `scripts/4_calibration_model.R:25`, `scripts/4_calibration_model.R:123`, `scripts/4_calibration_model.R:149`; evaluation from `scripts/5_calibration_eval.R:35`, `scripts/5_calibration_eval.R:168` and `scripts/5_calibration_eval.R:231`. Include the optional spatial experiment after inspecting its missing source. No changed fitting method, formula, uncertainty model or coverage denominator.

**Design:**

```r
fit_calibration(data, month, model_id, cfg)
compare_calibrations(models)
evaluate_calibration(model, data, month, cfg)
```

Use the registry and return numerical tables plus plot-ready data. Record expanded formulas. Keep existing execution/RNG order, including repeated fits or simulations where removing them could change results; deduplicate implementation through functions, not by silently deleting calls.

Keep script 5’s current missing-observation denominator during this refactor (`scripts/5_calibration_eval.R:183`); B2b is a separate scientific correction. All selected-model writes must honour the configured ID.

**Verification:** Run 4 and 5 over all months, then 6 with their selected fits. Require anchored AIC equality and I01’s stochastic checks for statistics. Compare fit predictions, convergence and effective model structure with the pre-extraction reference; do not compare entire `bam` objects. Execute the optional experiment’s supported portion once its contract is established.

**Acceptance criteria:**

- [ ] Fitting/evaluation computations live in `R/`; plots remain in scripts.
- [ ] Registry selection and numerical behaviour match the verified baseline.
- [ ] Feature-topic protocol and question logs are maintained.

**Open points:** Chris must decide the disposition of the optional spatial script’s executable legacy tail after its full source is supplied; do not silently repair or enable it based only on the review’s warning.

## I10

**Title:** Extract prediction and response-summary functions

**Depends on / blocks:** I08 / I09, I13.

**Goal:** Make prediction callable with explicit models and data. Preserve the distinction between fitted means and summaries of simulated responses.

**Scope:** Extract `scripts/6_prediction_model.R:27` through `scripts/6_prediction_model.R:86` into `R/prediction.R`; expose reusable simulation support for script 5. No coefficient draws, ensemble driver or production seed.

**Design:**

```r
predict_albedo(model, cover, month, cfg)
simulate_responses(model, data, n)
summarise_responses(samples)
```

Return deterministic predictions, response samples and summaries separately. Preserve the existing baseline `iter` column on disk; internally distinguish response identity from optional `lc_draw`. Include `lc_draw` in melt identifiers and summary grouping so it cannot be averaged away.

The wrapper handles model reads and writes through the path/manifest helpers. Functions need no output directory and must work with models passed directly.

**Verification:** Run 6 with the same selected models and land-cover input. Compare deterministic predictions against the all-months anchor, and summaries using I01’s historical tolerances plus paired RNG checks. Verify that a two-`lc_draw` fixture remains distinct and that response labels above 999 parse correctly. Keep `gratia` attached unless a full proving run supports its removal (`AGENTS.md:43`).

**Acceptance criteria:**

- [ ] Numerical predictions, summaries and baseline artifact schemas are preserved.
- [ ] Draw identities remain separate; no global/file discovery occurs in functions.
- [ ] Feature-topic protocol and both question logs are maintained.

**Open points:** A2/A3 remain unresolved; extraction must not reinterpret response draws as coefficient uncertainty.

## I11

**Title:** Extract and consolidate both albedo difference stages

**Depends on / blocks:** I08 / I13.

**Goal:** Separate numerical differences from maps and remove repeated whole-table growth. Preserve both the coarse recipe and consecutive-slice science exactly.

**Scope:** Extract script 7’s ice/coarse preparation and difference loop (`scripts/7_plot_preds.R:46`, `scripts/7_plot_preds.R:383`) and script 7a’s Dalton extraction, areas and loop (`scripts/7a_alb_diff_full.R:51`, `scripts/7a_alb_diff_full.R:110`, `scripts/7a_alb_diff_full.R:224`). Add shared helpers in `R/differences.R`; leave plotting statements in scripts.

**Design:** Provide `prepare_ice_tables()`, `difference_coarse()` and `difference_albedo()` with explicit data/config arguments. Share calendar completion and pair construction; retain separate coarse and consecutive formulas.

Prepare reusable geometry/fraction tables once and pass them into calculations; no new persistent cache system. Group by cell/month plus optional `lc_draw`, with explicit age ordering.

Preserve simultaneous one-pass ice adjustment, threshold masks formed before adjustment, missing-value behaviour and `rowSums` choices (`scripts/7a_alb_diff_full.R:245`, `scripts/7a_alb_diff_full.R:285`, `scripts/7a_alb_diff_full.R:296`). Preserve legacy polygon matching and the three albedo roles. Do not activate the unused “complete cells” table.

Return data separately from serialization, then restore baseline row/column order, factors, units and row names.

**Verification:** Run 7 and 7a against frozen all-months prediction inputs. Compare all five tail artifacts they produce using MD5; `ALB_diffs_bluesky.RDS` must remain `8039899288aaf84877b904c51e941448` (`tests/anchors/README.md:96`). Test missing ages, threshold crossings, multiple readvances and separate draw identities. Run 8 and 9 against the regenerated differences.

**Acceptance criteria:**

- [ ] Frozen-input artifacts are byte-identical; no numerical tolerance substitutes for this gate.
- [ ] Computations run without plotting; repeated implementations are shared.
- [ ] Feature-topic protocol and PI question logs are maintained.

**Open points:** C2’s first-pair failure and scientific readvance policy remain separate work; do not “clean them up” inside vectorisation.

## I12

**Title:** Extract reusable kernel sampling and forcing functions

**Depends on / blocks:** I08 / I13.

**Goal:** Separate spatial kernel sampling from multiplication so callers can reuse sampled kernels. Preserve all existing forcing variants and conversions.

**Scope:** Extract `scripts/8_radiative.R:63` through `scripts/8_radiative.R:159` into `R/kernels.R`. The wrapper retains diagnostic plotting and writes the existing forcing path. No new kernel products, sky conditions or persistent cache framework.

**Design:**

```r
sample_kernels(cells, months, sources, cfg)
apply_kernels(differences, sampled_kernels, cfg)
```

Sample once per distinct cell/month and return a reusable table. Validate join uniqueness; joining must neither multiply nor discard difference rows. Preserve optional `lc_draw`.

Use canonical month numbers and map the configured annual CACK year to its dimension coordinate: baseline 2003 maps to band 3. Preserve the current CACK transpose/flip and coordinate arithmetic (`scripts/8_radiative.R:107`, `scripts/8_radiative.R:112`).

Keep HadGEM3/CAM5 multiplication by 100 and CACK’s negative sign without that factor. Preserve all thirty forcing columns and strict latitude boundaries.

**Verification:** Run 8 against anchored `ALB_diffs_bluesky.RDS` and require the tail forcing MD5. Compare reused versus freshly sampled tables, four nonconsecutive months, reordered months and two draw identities. Run without script 7’s ice tables. Check CACK year mapping and all three conversion formulas directly.

**Acceptance criteria:**

- [ ] Frozen-input forcing is byte-identical, including schema and order.
- [ ] Sampling is reusable and independent of plotting or script 7.
- [ ] Feature-topic protocol and both question logs are maintained.

**Open points:** C3/C4 remain scientific decisions; neither CAM5 `FSNSC` nor CACK’s annual product changes here.

## I13

**Title:** Extract aggregation and verify the complete migration

**Depends on / blocks:** I09, I11, I12 / I14 and final feature integration.

**Goal:** Make all final numerical summaries callable independently of charts. Verify that the assembled migration preserves the pipeline and survives Andria’s intervening edits.

**Scope:** Extract period preparation and aggregation at `scripts/9_forcing_barplot.R:145`, `scripts/9_forcing_barplot.R:167`, IPCC preparation at `scripts/9_forcing_barplot.R:198` and recovered-recipe calculations at `scripts/9_forcing_barplot.R:325` into `R/aggregation.R`. Update README configuration, run-order and provenance documentation (`README.md:118`, `README.md:282`). Preserve script 9’s assumption header.

**Design:**

```r
aggregate_forcing(data, column, cfg)
aggregate_egu_recipe(coarse_differences, kernel_table, cfg)
prepare_modern_erf(best, lower, upper)
```

Remove closure over global `d` and `EARTH_AREA`. Carry optional `lc_draw` through completeness checks, grouping and joins; never compute ensemble intervals here.

Preserve period sums → monthly means → area weighting, including current NA behaviour and both normalisations. Keep the recovered EGU recipe separate, with its four-month requirements. Plots consume returned tables.

Audit every numbered script: numerical stages must be callable from `R/`; wrappers retain invocation, I/O and plots. Rebase the feature work onto Andria’s edits before final integration, retaining granular history.

**Verification:** Run 9 against frozen tail inputs and byte-compare all four CSVs with I01. Test incomplete periods, missing kernel months and two draw identities.

Then run the complete baseline sequence, optional supported scripts and diagnostics. Apply upper-pipeline stochastic/cache qualifications; independently rerun the deterministic tail against frozen predictions. Exercise one month-subset run, one analysis mismatch/override and one presentation-only edit. Repeat affected checks after rebase; do not treat a conflict resolution as verified by earlier runs.

**Acceptance criteria:**

- [ ] Numerical aggregation is independent of plots and global state.
- [ ] End-to-end and frozen-input anchor checks pass with documented limits.
- [ ] Feature is reconciled with Andria’s edits; `main`/`legacy` and anchors remain untouched.

**Open points:** Escalate rebase conflicts that change scientific behaviour. Final merge timing must preserve Andria’s ongoing review on `chris-dev`.

# Part 3. The parked ensemble skeleton issue

## I14

**Title:** Reserve the ensemble driver for a separate design

**Depends on / blocks:** I13 / future ensemble implementation only.

**Goal:** Record the interface requirements without committing to ensemble semantics or implementation. Mark this issue **placeholder — design later**, with no implementation agent assigned.

**Scope:** Future driver over the extracted stage functions, informed by `docs/cc/2026-10-07_adversarial_review_single_config_fable.md:84` and the uncertainty distinctions in `docs/cc/2026-10-07_design_review_single_config_codex_gpt6astra.md:80`. No config flag, driver, member execution, coefficient uncertainty, point flavour or `targets` work now.

Requirements on the step 4 functions:

- An integer `lc_draw` can pass through prediction, differences, kernels and aggregation without being dropped or collapsed.
- Response-draw identity remains separate.
- Paths can be redirected by an explicit profile while baseline filenames remain unchanged.
- Static geography, ice fractions and sampled kernels can be prepared once and passed to repeated calls.
- No script is the sole implementation of a numerical computation; plotting is optional for callers.

**Design:** to be designed

**Verification:** to be designed

**Acceptance criteria:**

- [ ] Issue remains visibly parked and introduces no advertised ensemble functionality.
- [ ] Function-interface requirements are recorded for future design.
- [ ] Future work follows the applicable branch protocol and maintains PI question logs.

**Open points:** Confirm whether `iter` denotes joint spatial/temporal draws and agree the uncertainty claim before quoting ensemble results (`docs/cc/questions_for_andria_scientific.md:40`). Calibration policy and retention/checkpoint design remain future decisions.

# Part 4. Risks the adversarial reviewer should probe

- **Configuration promises:** singleton switches, diagnostic-only alternatives or accepted settings that some scripts ignore.
- **Calendar correctness:** source-band numbers, selected-vector order, missing months, fixed February/November sections and partial EGU comparisons.
- **Hidden numerical settings:** script 7’s longitude cutoff and polygon-age alias being misclassified as presentation.
- **Baseline preservation:** three ice-albedo roles or three map windows being collapsed into one preferred convention.
- **Provenance lookup:** older manifests being accepted after newer failed writes, unchecked artifact changes, or stale outputs being claimed by directory scans.
- **Failure honesty:** invalid config, graphics-device failures, script 5’s partial outputs and optional scripts omitted from “every invocation”.
- **Refactor arithmetic:** changed row order, factor levels, units, NA masks, one-pass ice adjustments or simulation call order concealed by loose comparisons.
- **Verification limits:** cached elevation, unseeded statistics, absent model anchors and LFS pointers being treated as successful byte comparisons.
- **Integration discipline:** parallel agents sharing output paths, scientific changes hidden in rebase resolutions, or regenerated results replacing historical anchors.

---

# Appendix: the brief given to the design agent

## Design task: turn the single-config migration into a set of GitHub issues

You are the design agent for an R research pipeline. You have NO shell and no file
access: do not run commands. Every repository file you need is reproduced in full below,
with line numbers, after this request. Cite them as path:line. Work at full depth.

### What has already been decided (do not reopen these)

Two design reviews of the proposal were done on 2026-10-07 and are included below in
full: a codex review (docs/cc/2026-10-07_design_review_single_config_codex_gpt6astra.md)
and an adversarial second opinion (docs/cc/2026-10-07_adversarial_review_single_config_fable.md).
Read both. Chris (the contractor who owns the engineering) has then decided:

1. **Format: `config.R`**, one R file at the repo root returning one nested list, loaded
   by a validating helper in `R/`, evaluated in a bare environment, resolved values dumped
   as JSON into every manifest. Not YAML, not TOML.
2. **Scientific decisions live in the config**, as selectors among alternatives the code
   implements today, plus numeric parameters of implemented methods. Rule from the second
   review: a config key may only take values the code implements today; a key with one
   legal value does not exist; a key that encodes an open question carries the question
   id (from docs/cc/questions_for_andria_scientific.md) in a comment. Model formulas stay
   in a versioned R registry selected by id. Plot details stay in code, but any value
   shared by more than one script (the map window, the months vector) is defined once.
3. **The config has two top-level sections**: `analysis` (anything that changes a
   number) and `presentation` (plots only).
4. **Manifests, kept simple and human readable.** Every script, every run, writes one
   small plain-text manifest: resolved config values, git commit and dirty flag, inputs
   and outputs with checksums, status (started/completed/failed), run id unique to the
   second. The existing R/run_manifest.R is the starting point; its known gaps are listed
   in both reviews.
5. **Consistency check, toned down** (Chris's explicit decision; do not elaborate it): a
   downstream script compares the `analysis` section recorded in its inputs' manifests
   with the current config. Any difference prints a readable list of what changed and
   stops. `RUN_ALLOW_STALE=1` in the environment lets it through and is recorded in the
   manifest. No per-script key declarations, no lineage unions, no sidecar files. The
   manifest for an input is found from the output path by a naming convention. The cost,
   that any analysis change invalidates everything downstream, is accepted.
6. **Output paths stay as they are today**, so the regression anchors under
   tests/anchors/ (keyed by file name, MD5SUMS.txt) keep working unchanged.
7. **Scope is the first four steps** of the second review's section F: (1) config
   loader and config.R with the baseline values; (2) manifest v2 wired into every script;
   (3) path functions in one file; (4) stages as functions in R/ with the numbered
   scripts as thin wrappers (plots stay in scripts). **The ensemble driver (step 5) is
   parked**: produce one skeleton issue for it, marked as a placeholder to be designed
   later, that records what the functions from step 4 must make possible. The point
   flavour, `targets`, and coefficient-uncertainty draws are out of scope.
8. **Version control.** One long-lived feature branch off `chris-dev` for this
   migration, because Andria is reviewing the scripts as they are on `chris-dev` and
   that review must not be disturbed. Topic branches per issue off the feature branch,
   merged back with --no-ff; rebased onto Andria's edits before the feature branch is
   finally merged. Every issue must leave the pipeline runnable and verified against the
   anchors (byte comparison where deterministic, tolerance where the anchor README says
   not). Rules in CONTRIBUTING.md and AGENTS.md apply.
9. The issues will be **adversarially reviewed** and then handed to implementation
   agents, one issue per agent, possibly several in parallel. So each issue must be
   self-contained enough for an agent that has read CONTRIBUTING.md, AGENTS.md and the
   issue alone.

### What I want from you

A markdown document with these parts:

**Part 1. Dependency map.** A list of the issues with their dependencies, and an explicit
statement of which can be worked in parallel and which must be sequential, with the
reason for each sequential edge (shared file, shared function, anchor order). Include a
suggested order of merges. Keep the number of issues small enough to be real (aim for
8 to 14) and large enough that each is one reviewable pull request.

**Part 2. The issues.** For each issue, in this exact structure so they can be filed
as-is later:

- Title (imperative, under 70 characters)
- Depends on / blocks
- Goal (two or three sentences: what and why)
- Scope: files touched, with the specific lines or constructs to change, citing the
  code below (path:line). Say what is explicitly out of scope.
- Design: the concrete shape of the change, with a short R sketch where it helps
  (function signatures, config block shape, manifest format). Reuse the sketches from
  the reviews where they fit; correct them where they conflict with the decisions above.
- Verification: exactly how the implementer proves nothing changed: which scripts to
  run, which anchors to compare and how, what is allowed to differ and why.
- Acceptance criteria: a checklist.
- Open points: anything the implementer must ask about rather than decide.

Pay particular attention to: the months-vector trap (scripts/8_radiative.R:81,
4_calibration_model.R:116, 7a_alb_diff_full.R:159) which must be fixed before months is
configurable; the three ice-albedo columns and three map windows; the fixed output paths
in scripts 6, 7a, 8; the fact that script 8 loads script 7's ice tables and never uses
them; script 9's header, which already works the intended way; the elevation cache and
the anchor README's caveats; and the dirty-tree check needing to cover config.R and R/.

**Part 3. The parked ensemble skeleton issue**, in the same structure but with Design
and Verification left as "to be designed", and a short list of the requirements it
places on the step 4 functions (a draw id column must be able to pass through; paths
must be redirectable by profile; no script may be the only place a computation lives).

**Part 4. Risks the adversarial reviewer should probe**, five to ten bullets.

Under about 6,000 words in total. Be concrete; cite lines; no surveys.
