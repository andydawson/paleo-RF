# Migration issues: single config and per-script manifests (revision 2)

**What this is.** The issue set for migrating the pipeline to one configuration file
with per-script manifests, revised after the adversarial review of 2026-10-08
(`2026-10-08_adversarial_review_migration_issues_fable.md`). Revision 1 is the codex
design (`2026-10-08_migration_issues_single_config_codex_gpt6astra.md`), kept unchanged
for comparison. This is the text to file as GitHub issues once Chris has confirmed it.

**What changed from revision 1**, following the review's section F in order:

1. The mean/median switch is in (I04a), with closure for the median only, property-based
   verification, and the note for Andria (scientific questions A1(e)).
2. Every verification recipe uses the frozen fits and predictions on disk. Script 4 is
   checked by a one-month fit of the selected model with a stated tolerance; the full
   ladder is refitted once, in I13b. Stated in I01 so every issue inherits it.
3. Reordered: paths (I07) before manifests (I05, I06); the draw-identity helper moved
   into I06; I08, I10, I11, I12 and I13a run in parallel; I04 and I13 each split in two.
4. The manifest lookup is "newest manifest of the producer, checksum must match, else
   stop or override"; no counter in the run id; figures registered by modification time.
5. The spatial-eval script is out of scope (question for Andria, general 7); SP_ELEV_LC
   means the selected model; the duplicate fits of model 8 are a question for Andria.
6. The elevation-exception language is gone; the cache and script 7 are both
   demonstrated reproducible; the two anchor READMEs are corrected in I01.
7. Thread count is run metadata, not an `analysis` key; the C7 and CACK keys are named;
   `period_breaks` is `coarse$ages`.
8. Citations fixed (7:171 tests `< 8`; 6:72 and 2:37 dropped from I02; CONTRIBUTING root
   list is at 41-42).
9. The feature branch merges `chris-dev` in at checkpoints instead of rebasing; the
   exception is recorded in CONTRIBUTING.

**Filed on GitHub 2026-10-08** with label `single-config`; the issue bodies are the
sections below, with dependency lines linked to issue numbers. Implementation proceeds
one issue at a time: plan, Chris's approval, implement, verify, merge.

| Id | Issue | Title |
|---|---|---|
| I01 | [#2](https://github.com/andydawson/paleo-RF/issues/2) | Establish the migration branch and regression contract |
| I02 | [#3](https://github.com/andydawson/paleo-RF/issues/3) | Remove positional month indexing and fixed dimensions |
| I03 | [#4](https://github.com/andydawson/paleo-RF/issues/4) | Add validated configuration and migrate script 9 |
| I07 | [#5](https://github.com/andydawson/paleo-RF/issues/5) | Centralise paths while preserving baseline file names |
| I05 | [#6](https://github.com/andydawson/paleo-RF/issues/6) | Implement one reliable manifest per invocation |
| I04a | [#7](https://github.com/andydawson/paleo-RF/issues/7) | Centralise model, draw and reduction settings (scripts 1, 4, 5, 6) |
| I04b | [#8](https://github.com/andydawson/paleo-RF/issues/8) | Centralise months, ages, domain, ice and kernel settings (scripts 7, 7a, 8) |
| I06 | [#9](https://github.com/andydawson/paleo-RF/issues/9) | Wire manifests into every live pipeline script; add the draw-identity helper |
| I08 | [#10](https://github.com/andydawson/paleo-RF/issues/10) | Extract preparation functions (scripts 1, 2, 3) |
| I10 | [#11](https://github.com/andydawson/paleo-RF/issues/11) | Extract prediction and response-summary functions (script 6) |
| I11 | [#12](https://github.com/andydawson/paleo-RF/issues/12) | Extract and consolidate both albedo-difference stages (scripts 7, 7a) |
| I12 | [#13](https://github.com/andydawson/paleo-RF/issues/13) | Extract kernel sampling and forcing functions (script 8) |
| I13a | [#14](https://github.com/andydawson/paleo-RF/issues/14) | Extract aggregation functions (script 9) |
| I09 | [#15](https://github.com/andydawson/paleo-RF/issues/15) | Extract calibration fitting and evaluation functions (scripts 4, 5) |
| I13b | [#16](https://github.com/andydawson/paleo-RF/issues/16) | Integration gate: full baseline run and reconciliation with chris-dev |
| I14 | [#17](https://github.com/andydawson/paleo-RF/issues/17) | Reserve the ensemble driver for a separate design |

Decisions this design is built on are in CONTRIBUTING, "Decisions on record",
2026-10-08. Line citations refer to `chris-dev` f2cdaa7; the scripts are unchanged since
the codex base commit.

---

# Part 1. Dependency map

Thirteen implementation issues (two of them split in halves) and one parked ensemble
issue. Stages, with the number of agents that can usefully work at once in brackets:

| Stage | Issues | Agents | Why this stage waits for the one before |
|---|---|---|---|
| 1 | I01 regression contract and feature branch | 1 | Everything else verifies against what I01 records. |
| 2 | I02 month indexing | 1 | Months must be safe before a month setting exists. |
| 3 | I03 config loader; script 9 | 1 | Establishes the loader and schema the rest extend. |
| 4 | I07 paths ∥ I05 manifest v2 | 2 | Manifest lookup needs the path catalogue; I05 is `R/run_manifest.R` only, unit-tested, and imports the catalogue at merge. |
| 5 | I04a (scripts 1, 4, 5, 6; registry; reduction) ∥ I04b (scripts 7, 7a, 8) | 2 | Disjoint files. Both need I07's redirected profile for alternative-setting runs. |
| 6 | I06 wiring manifests into every script, plus the draw-identity helper | 1 | Touches every wrapper; needs the full config and the manifest API. |
| 7 | I08 ∥ I10 ∥ I11 ∥ I12 ∥ I13a | 5 (3 or 4 in practice; I11 is the hard one and its agent should hold nothing else) | All need only the identity helper from I06, not each other. |
| 8 | I09 calibration and evaluation functions | 1 | Reuses the simulation wrapper from I10. |
| 9 | I13b integration gate | 1 | The one full refit; merge of Andria's edits; README. |
| 10 | I14 parked | 0 | Recorded, not implemented. |

**Merge order:** I01 → I02 → I03 → I07 → I05 → I04a → I04b → I06 → I10 → I11 → I12 →
I08 → I13a → I09 → I13b.

**What may be verified without the 27-hour refit:** everything except the ladder itself.
Scripts 5 to 9 run from the frozen fits and predictions on disk (inventory in I01), with
`RUN_ALLOW_STALE=1` recorded once manifests are live. Script 4 is covered at every
stage by parse plus the one-month check of the selected model in I01, and by one full
refit in I13b.

**Worktrees.** Until I07 merges, paths are hard-coded, so a parallel agent needs its own
copy or symlink of the inputs (617 MB), the fits (4.0 GB) and the predictions (2.6 GB)
under a private `data/`, `output/`, `figures/` and `runs/`. After I07, one checkout with
a per-agent path profile suffices. Never edit a script while `Rscript` is running it.

**Branches.** Feature branch `feature/single-config` off `chris-dev`; one topic branch
per issue off the feature branch, merged back with `--no-ff`, pushed at checkpoints.
`chris-dev` is merged into the feature branch at each stage boundary and once before the
final merge, so that Andria's review edits are reconciled early and the granular history
is kept (exception to CONTRIBUTING's rebase rule, recorded 2026-10-08). `main` and
`legacy` are never touched.

---

# Part 2. The issues

## I01

**Title:** Establish the migration branch and regression contract

**Depends on / blocks:** none / everything.

**Goal:** Protect Andria's review on `chris-dev` and write down what "unchanged result"
means for every artefact, so that no later issue invents its own standard after seeing
its results.

**Scope:** `CONTRIBUTING.md` (branch protocol for this migration at :17, :40, :69; the
stale root-directory list at :41-42, adding `config.R`, `R/`, `tests/`, `runs/`,
`output/`, `figures/`, `writing/`). New `docs/cc/2026-10-XX_single_config_regression_contract.md`.
Comparison tooling under `tools/`. Corrections to `tests/anchors/README.md:16` (there are
two interp anchors, not none) and `:91-96` (script 7 is demonstrated reproducible, not
only 7a), and to `tests/anchors/interp-allmonths-2026-09-20/README.md:9` (the elevation
cache reproduces the anchor). Anchored artefacts and checksum files are not replaced.

**Design:**

Create `feature/single-config` from `chris-dev`. Record the starting commit, input
checksums, thread settings and the current output inventory.

The contract classifies every artefact:

- *Deterministic*: compared against its `MD5SUMS.txt` entry by file name; no tolerance.
  This includes everything scripts 1, 2, 7, 7a, 8 and 9 write (the land-cover tables on
  disk carry the anchor checksums 992a9ebb and 4c9bf612, regenerated from the elevation
  cache on 2026-09-25; script 7's four outputs carry theirs, see
  `annotated-interp:runs/2026-09-23_2314_7_plot_preds.md`).
- *Fitted models*: compared by formula, predictions on the calibration table and the
  numerical diagnostics, never by whole-object identity
  (`tests/anchors/README.md:46`).
- *Unseeded summaries* (script 5's statistics, script 6's simulation summaries):
  tolerances are **measured, not chosen**. Run script 6 twice on the frozen selected
  models (15 min each) and script 5 twice (4 min each) at the current code; record the
  between-run spread per column, doubled, as the tolerance. The existing pair
  `tests/anchors/interp-allmonths-2026-09-20/calibration_model_stats.csv` versus
  `output/calibration/calibration_model_stats.csv` already shows 0.01 flips in four rows
  (`scripts/5_calibration_eval.R:116`, `:185`).
- *The median path* (I04a): no anchor exists; verified by the properties in I04a, never
  by comparison with the mean anchors.

The frozen-input inventory, with checksums, that later issues verify from: the
calibration table (289c0f8a), the 192 fits in `output/calibration/` (4.0 GB) including
the 12 selected models, `paleo_interp_predict_gam_summary_bluesky.RDS` (6bd0a8e5),
`ALB_diffs_bluesky.RDS` (80398992), and script 9's four CSVs.

The one cheap calibration check every later issue uses: fit the selected model (mod8)
for one month with the candidate code (1-5 min), compare its predictions on the
calibration table with the stored selected model to 1e-6, and require the integer AIC to
match `AIC_table.csv`. Byte identity is not required: `bam` with `nthreads = 8` is not
established as bit-reproducible. The full ladder is refitted once, in I13b.

**Verification:** Run 1 and 2 (byte-identical). Run 5 and 6 from the frozen fits, twice,
to measure the tolerances. Run 7, 7a, 8 from the frozen predictions and 9 from the
frozen tail inputs; check every MD5 entry; inspect LFS artefacts for pointer files.
Record script 5's late failure at `scripts/5_calibration_eval.R:218`.

**Acceptance criteria:**

- [ ] Regression commands, artefact classes, measured tolerances and the frozen-input
      inventory are recorded.
- [ ] Original anchors untouched; regenerated outputs not committed.
- [ ] Branch protocol (feature branch, topic branches, merge-in at checkpoints) documented;
      both PI question files maintained.
- [ ] The three README corrections made.

**Open points:** Chris approves the measured tolerances before any candidate result is
seen.

## I02

**Title:** Remove positional month indexing and fixed dimensions

**Depends on / blocks:** I01 / I03.

**Goal:** Make month subsets and reordered selections safe before a month vector becomes
configurable, preserving the twelve-month baseline exactly.

**Scope:** `scripts/4_calibration_model.R:113-116` (AIC columns and monthly lists sized
to twelve), `scripts/5_calibration_eval.R:90`, `scripts/7_plot_preds.R:171` (the
coverage constant `< 8`, the eight coarse ages), `scripts/7a_alb_diff_full.R:159` (the
coverage constant `< 25`), `scripts/8_radiative.R:81` (month number from position in
the selected vector). Audit the fixed February/November and seasonal sections at
`scripts/7_plot_preds.R:202`, `scripts/5_calibration_eval.R:306`,
`scripts/9_forcing_barplot.R:333`. **No public month setting yet**: this issue fixes the
derivations; I04b only changes where the vector comes from, and must not re-fix them.

Script 2 is out of scope: it extracts all twelve months and names bands canonically
(`scripts/2_calibration_lct_bluesky.R:52-53`); the month selection applies from script 4
onward, so the calibration table and its anchor are unaffected by any subset. Script 6
has no positional month dependence.

**Design:** Define the calendar once in `R/calendar.R`:

```r
MONTHS <- tolower(month.abb)
month_number <- function(month) match(month, MONTHS)
```

Reject unknown, duplicated or empty selections; preserve the selected order while always
mapping February to band 2, May to 5, and so on. The two coverage constants become the
length of the respective age vector. Detect duplicate and missing age keys separately.
Keep `alb_grid_full_new` diagnostic and unused by the difference loop
(`scripts/7a_alb_diff_full.R:167`, `:217`). Month-specific plots skip unavailable months
explicitly. The recovered EGU recipe needs its four months; never compute a partial
recipe or label a subset mean "annual".

**Verification:** Run 5, 6, 7, 7a, 8, 9 from the frozen fits and predictions; verify 4 by
parse plus the one-month check (I01). Exercise internal month arguments with
`c("feb","may","aug","nov")`, reversed order and one month; compare each selected kernel
band and the resulting rows with the corresponding full-calendar rows. Test missing and
duplicated age keys.

**Acceptance criteria:**

- [ ] Baseline deterministic checksums match; stochastic comparisons per I01.
- [ ] No band selection depends on position within the selected months.
- [ ] No config key added.

**Open points:** Any apparent coverage "fix" that changes retained cells is referred to
Chris and kept out of this issue.

## I03

**Title:** Add validated configuration and migrate script 9

**Depends on / blocks:** I02 / I07, I05.

**Goal:** Establish the configuration contract using script 9's already explicit
assumptions, and define the shared map windows once without changing their meanings.

**Scope:** New root `config.R`, `R/config.R` (loader), `R/config_schema.R`. Lift settings
from `scripts/9_forcing_barplot.R:109-122`, keeping its explanatory header at `:37`.
Pass `jsonlite::toJSON(cfg)` as a single config string to the existing `run_start()`
(the manifest itself is rewritten in I05). Define the three windows once: from
`R/map_helpers.R:21`, `scripts/1_veg_lct_prep.R:169`, `scripts/7_plot_preds.R:41`,
`scripts/7a_alb_diff_full.R:35`, `scripts/8_radiative.R:19`, with their consumers in
scripts 2 and 3.

**Design:** `config.R` returns exactly one list:

```r
list(
  analysis = list(
    coarse = list(ages = c(50, 500, 2000, 4000, 6000, 8000, 10000, 12000)),  # 7:37, 7a:29, 8:44, 9 periods
    forcing = list(
      earth_area_m2 = 5.101e14,
      variant = "veg_ice_thresh",            # C1; C5(a): Chris's assumption A1
      report_kernels = c("hadgem", "cam5", "cack"),
      sensitivity_variants = c(...)          # legal values: the ten rf_* suffixes of 8:125-159
    )
  ),
  presentation = list(
    map_windows = list(calibration = list(x = c(-172, -50), y = c(15, 80)),
                       tail        = list(x = c(-166, -50), y = c(12, 82)),
                       diagnostics = list(x = c(-172, -50), y = c(17, 79)))
  )
)
```

Keys are added only when their consumers are wired. Script 9's aggregation algorithms
are preserved; no singleton switches for equal weighting or summed intervals.

The loader evaluates one list expression in a bare environment containing only approved
deterministic constructors and constants (`list`, `c`, `seq`, arithmetic, literals);
rejects assignments, arbitrary calls, namespace access, file or environment reads,
unknown keys and unsupported combinations. The resolved record contains both sections;
only `analysis` takes part in the consistency check.

The three windows stay three, defined once and passed explicitly to the map helpers
(helpers do not discover configuration). They have no question id because they are
presentation; the oddity is on record in `questions_for_andria_general.md` 7.

**Verification:** Run 9 from the frozen tail inputs; compare all four CSVs byte for byte.
Run 1 in diagnostic mode and scripts 2, 3, 7, 7a, 8 from frozen inputs for unchanged
window bounds and numeric artefacts. Test invalid configuration and JSON round-tripping,
including named vectors and one-element vectors.

**Acceptance criteria:**

- [ ] Script 9 keeps its assumptions and numerical behaviour.
- [ ] The three windows each have one definition.
- [ ] The loader rejects everything the design says it rejects.

**Open points:** C1 and C5 remain scientific questions; link the keys to their entries.

## I07

**Title:** Centralise paths while preserving baseline file names

**Depends on / blocks:** I03 / I05, I04a, I04b.

**Goal:** One path vocabulary for producers and consumers, every baseline file name
preserved, and the calibration reader/writer disagreement removed. Pure refactor with
byte-identical outputs; the cheapest verification in the set, which is why it comes
before the manifests that depend on it.

**Scope:** New `R/paths.R`. Replace path construction in the numbered scripts: the five
prediction output families (`scripts/6_prediction_model.R:33`, `:48`, `:60`, `:85-86`),
differences (`scripts/7a_alb_diff_full.R:323`), forcing (`scripts/8_radiative.R:195`)
and its reader (`scripts/9_forcing_barplot.R:141`), the calibration files, the
spatial-experiment files. Include the spatial-eval script's output paths
(`6_prediction_model_spatial_eval.R:117`, `:175`, `:190`, `:217`) in the catalogue even
though that script is out of scope, so the inventory is complete.

**Design:**

```r
paths <- pipeline_paths(cfg, profile = baseline_paths())
path_prediction(paths, kind, month = NULL)
path_calibration_model(paths, model_id, month)
path_forcing(paths)
producer(paths, path)          # which script writes this path; used by I05
```

A profile is an explicit path-layout argument, not a config section. The default returns
today's paths, including the untagged forcing file name. A redirected profile moves
derived data, outputs, figures and manifests while leaving external inputs where they
are; this is what alternative-setting runs in I04 use so the baseline is never
overwritten.

Fix script 5's `spatial_experiment/` reads (`scripts/5_calibration_eval.R:218`) to the
directory script 4 writes to (`scripts/4_calibration_model.R:161`). **SP_ELEV_LC means
the selected model**, read from where script 5 wrote it, in both script 5 and (when it
is ever touched) `6_prediction_model_spatial_eval.R:59`; not the separate fit at
`4:154`. Today `4:98`, `4:154` and `4:234` are the same formula, so the numbers agree;
the choice matters once `model_id` can change. Whether the duplicate fits at `4:154`
and `4:234` can go is a question for Andria (general 7); until answered the three files
are still written.

**Verification:** Compare the complete baseline path inventory with I01. Run 5 and 6
from the frozen fits (script 5 should now complete); run 7, 7a, 8, 9 from frozen
inputs; every MD5 matches. Redirect a small fixture run and assert no baseline artefact
is overwritten and `producer()` still resolves.

**Acceptance criteria:**

- [ ] No existing output renamed; MD5 file-name mappings valid.
- [ ] Producer and consumer paths agree, including the spatial experiments.
- [ ] A redirected profile leaves the baseline untouched.

**Open points:** Newly runnable script 5 sections need validation, not a claim of
historical anchoring.

## I05

**Title:** Implement one reliable manifest per invocation

**Depends on / blocks:** I03, I07 / I06.

**Goal:** Persist provenance before work begins and keep it after failure, and implement
the agreed whole-`analysis` comparison, with nothing more elaborate.

**Scope:** `R/run_manifest.R` only. Replace the singleton context (`:17`), deferred
creation (`:29`), minute naming (`:48`), late input hashing (`:83`), missing output
hashes (`:86`), the 2 GB exemption (`:25`), and the dirty check that ignores `config.R`
and untracked files (`:39`). No sidecars, no lineage, no per-script key declarations, no
scheduler.

**Design:**

```r
run_script(script, config_path, function(run, cfg) { ... })
read_input(run, path, reader)
write_output(run, path, writer)
```

One readable Markdown file per invocation, `runs/<producer>/<UTC-second>_<pid>.md`,
containing a labelled JSON record: resolved config (both sections), full commit, dirty
flag, status, inputs and outputs with MD5s, overrides, errors, and the existing runtime
metadata. Created immediately at start, before config validation; a configuration
failure records its error. Caught errors set `failed`; `completed` follows successful
writes and device closure; abrupt termination leaves `started`.

Inputs are hashed immediately before reading, outputs after closure; only successful
writes are registered. Figures are registered as the files under `figures/` whose
modification time is after run start (stale files excluded without wrapping forty
`ggsave` calls); data outputs go through `write_output()`.

Dirty detection covers root `config.R`, `scripts/` and all of `R/`, including untracked
files.

**Lookup and consistency check**, exactly as decided: `producer(path)` from the path
catalogue → the newest file in `runs/<producer>/` (names sort by time) → it must
register `path` with an MD5 equal to the file on disk; otherwise stop, printing the
run's status and the mismatch. Then compare that manifest's whole `analysis` section
with the current config; on any difference print the dotted keys with old and new values
and stop. `RUN_ALLOW_STALE=1` lets either case through and is recorded with every
discrepancy. No search backwards through older manifests; an older output is used only
by explicit override. External inputs need a checksum but no producer manifest. A missing
data file always fails. Differing producer and consumer commits are not by themselves a
mismatch.

**Verification:** Unit tests for: same-second invocations from two processes, invalid
config, missing inputs, errors before and after an output, abrupt termination, changed
inputs, a stale manifest, a nested `analysis` difference, a presentation-only change
(must pass), the override. Verify output hashes independently; hash one file over 2 GB.
**Flip test:** after running script 1, change `land_cover.reduction` and confirm script 2
stops naming that key (I04a). No pipeline algorithm changes here.

**Acceptance criteria:**

- [ ] Exactly one durable manifest per invocation, including failures.
- [ ] Analysis changes stop; presentation changes pass; overrides are visible in the
      manifest.
- [ ] No additional provenance files are introduced.

**Open points:** None scientific. Legacy inputs without manifests use the recorded
override during migration verification; historical provenance is never fabricated.

## I04a

**Title:** Centralise model, draw and reduction settings (scripts 1, 4, 5, 6)

**Depends on / blocks:** I07 / I06.

**Goal:** Make the implemented analysis choices of the upper pipeline visible and
validated, with formulas versioned in R, and add the mean/median reduction switch.

**Scope:** Extend config and schema. New `R/model_registry.R` for the ladder at
`scripts/4_calibration_model.R:28-105`, the spatial experiments at `:149-221` and the
repeated mod8 fit at `:234`. Replace the three selected-model decisions
(`scripts/5_calibration_eval.R:28`, `:98`, `:327`). Fix draw-name parsing at
`scripts/6_prediction_model.R:46` (`substr(iter, 2, 4)` truncates `V1000`) before
exposing draw counts. New `R/preparation.R` with `reduce_land_cover()`, replacing
`scripts/1_veg_lct_prep.R:40-49`.

**Design:** Keys added:

```r
analysis = list(
  land_cover = list(reduction = "mean"),   # "mean" | "median"; A1: Andria's note at 1:39;
                                            # median is renormalised per cell-slice (closure)
  calibration = list(model_id = "mod8",     # B4; registry in R/model_registry.R
                     maxit = 500,
                     k = list(space = 500, elev = 50, cover = 200)),
  draws = list(evaluation_response = 100L,  # A2/A3; 5:47
               prediction_response = 100L)  # A2/A3; 6:37
)
```

`reduce_land_cover(posts, method = c("mean", "median"))` summarises `value` per
(cell_id, x, y, ages, LCT) with the chosen statistic, pivots wide, and for `"median"`
only applies `close_fractions()`: stop if any of ET, OL, ST is non-finite or negative or
if their sum is not positive, naming the offending cell-slices; otherwise divide each by
the sum. **The mean path is left bit-identical and is not renormalised**: every draw
sums to exactly 1, and rescaling a sum of 1.0000000000000002 would change the baseline
in the last bit. Script 1 calls the function; elevation join (`1:69`), modern split
(`1:78`) and the writes (`1:82`, `1:86`) are unchanged. I08 adds the other preparation
functions to the same file without touching the reduction.

Thread count (`nthreads`) is **not** an `analysis` key: it changes no number beyond the
last bit, and a run on sixteen cores must not invalidate every downstream artefact. It
comes from the environment (`RUN_CORES`) and is recorded as run metadata.

Draw counts must be values the existing summaries support; no zero-draw mode. `alb_prod`
stays an implementation constant (one product exists). The registry records the expanded
formula of the selected model in the manifest. Question ids in comments: A1, A2/A3, B1/B4.

**Verification:** Run 1 (`reduction = "mean"` reproduces both tables byte for byte) and
2 (byte-identical). Run 5 and 6 from the frozen fits; the one-month check for 4.
Alternatives under a redirected profile (I07): another `model_id`, a draw label above
999, and the median:

- same schema, column order and row count as the mean output; ET + OL + ST within 1e-12
  of 1 in every row;
- the pre-closure medians equal `draw_stats$median` from the diagnostic (`1:34-36`),
  which groups independently;
- a synthetic fixture of three classes by 200 skewed draws with hand-computed medians,
  and a fixture with an all-zero median row that must stop;
- script 2 on the median tables as a schema smoke test (20 min). No fit.

**Acceptance criteria:**

- [ ] No key is ignored, singleton or unimplemented; the median switch works as
      specified and the mean path is byte-identical.
- [ ] Baseline formulas, selections and artefacts preserved; expanded formula in the
      manifest.
- [ ] Question ids present on every key that encodes an open question.

**Open points:** Do not resolve A1, A2, B4 scientifically. Andria has been told what a
median run costs and means (scientific A1(e)).

## I04b

**Title:** Centralise months, ages, domain, ice and kernel settings (scripts 7, 7a, 8)

**Depends on / blocks:** I07 / I06. Parallel with I04a (disjoint files).

**Goal:** Make the implemented analysis choices of the tail visible and validated,
exposing the inherited oddities honestly with their question ids.

**Scope:** Extend config and schema; wire scripts 7, 7a, 8 (and the month vector in 4
and 5, whose derivations I02 already made safe).

**Design:** Keys added:

```r
analysis = list(
  months = tolower(month.abb),                       # subsets allowed after I02
  ages = c(50, 200, seq(500, 11500, by = 500)),      # C7
  coarse = list(ages = ...,                          # from I03
                slice_alias = c("11500" = 12000)),   # C7: 7:85, 7:118 match polygons for
                                                     # 12 ka using the 11.5 ka slice. The
                                                     # empty mapping is also legal and
                                                     # drops the oldest period at 7:396.
  domain = list(lon_min = -170, lat_min = 27, lat_max = 74,   # 7a:73, 8:122-123; strict
                lon_max_coarse = -60),                        # 7:196, affects saved coarse diffs
  ice = list(threshold = 0.5,                        # 7a:136-137, 7a:251-252
             albedo_column = list(coarse = "ice_albedo",       # C0a; 7:165
                                  fixed  = "ice_albedo_fixed", # C0a; 7a:123
                                  scaled = "ice_albedo_sc")),  # C0a; 7a:124
  kernels = list(cack_year = 2003)                   # C3(b); legal 2001-2016; band = year - 2000
)
```

Physical ages are separated from the coarse polygon-matching alias; changing a plot
label must never select different ice polygons. The three ice-albedo roles stay three.
The month vector is the only key whose consumers include scripts 4 and 5.

**Verification:** Run 7, 7a, 8 from the frozen predictions; tail MD5s match. Under a
redirected profile: a four-month subset, each ice role, the empty slice alias, a
different CACK year (band mapping checked directly against the file's Year dimension).

**Acceptance criteria:**

- [ ] Tail artefacts byte-identical at baseline settings.
- [ ] Every oddity exposed carries its question id; the alias comment says the empty
      mapping is implemented behaviour, not a sensible one.
- [ ] No key is ignored or singleton.

**Open points:** C0, C2, C3, C7 are not resolved here.

## I06

**Title:** Wire manifests into every live pipeline script; add the draw-identity helper

**Depends on / blocks:** I04a, I04b, I05 / I08, I10, I11, I12, I13a.

**Goal:** Give standalone `Rscript` and `source()` execution the same provenance
behaviour, record exactly what each invocation reads and writes, and establish the one
shared convention the extraction issues all need.

**Scope:** Instrument scripts 1, 2, 3, 4, 5, 6, 7, 7a, 8, 9. Replace
`Filter(file.exists, ...)` at `scripts/7_plot_preds.R:17`, `scripts/7a_alb_diff_full.R:18`,
`scripts/8_radiative.R:27`, `scripts/9_forcing_barplot.R:131`; replace the
directory-wide output discovery at `scripts/7_plot_preds.R:552`; add the EGU PNG missing
from script 9's output list (`:349`, `:358`). Remove script 8's unused reads of script
7's ice tables (`scripts/8_radiative.R:32`, `:38-40`): loaded and never used. New
`R/stage_contracts.R` with the optional integer `lc_draw` identity helper (preserved
when present; absent in every baseline output; raw posterior `iter` keeps its meaning).

**Out of scope:** `6_prediction_model_spatial_eval.R`. It cannot run (`SemiPar` and
`pwiser` not installed; `values` used at `:278` before definition at `:280`; tail from
`:326` reads point-flavour files); it has never run here; CONTRIBUTING 2026-09-30 records
it as Andria's untouched original; whether the analysis is still wanted is asked in
general 7. If yes, it is a separate issue after I13b, built on the registry and
`R/prediction.R`, not patched.

**Design:** Package loading, config resolution, computation and plotting all inside the
protected invocation. Close PDF devices before registering hashes; keep explicit `print()`
where expressions move into functions. The elevation cache is a checksummed input when
present; if absent, the AWS lookup and the new cache are recorded, never silently
omitted (`scripts/1_veg_lct_prep.R:58`).

**Verification:** Every numbered script from frozen inputs per I01, plus script 1 in
diagnostic mode; the one-month check for 4. Inject an error after the first output of
script 5 and require `failed` with the earlier outputs registered. Run 8 without script
7's ice tables and require the forcing MD5 to match; script 9 must still require script
7's coarse differences.

**Acceptance criteria:**

- [ ] Every live invocation logs status and exact artefacts; stale directory contents
      excluded.
- [ ] `Rscript` and `source()`, success and failure, all covered.
- [ ] The `analysis` key set is **closed** at this point: I08 to I13 add no keys, so
      earlier manifests stay comparable (review risk E1).

**Open points:** None.

## I08

**Title:** Extract preparation functions (scripts 1, 2, 3)

**Depends on / blocks:** I06 / I13b. Parallel with I10, I11, I12, I13a.

**Goal:** Make land-cover and calibration-table preparation callable without sourcing
scripts.

**Scope:** `scripts/1_veg_lct_prep.R:58-70` (elevation), `:78` (modern split),
`scripts/2_calibration_lct_bluesky.R:123-136` (sampling and the zero nudge), script 3's
preparation at `scripts/3_plot_cal_lct_albedo.R:51-67`. Extend `R/preparation.R`
(created in I04a with `reduce_land_cover()`, which this issue does not touch). Move
`make_grid()` from `scripts/make_grid.R` (12 lines, used only by script 3) into
`R/preparation.R`. Plots stay in scripts.

**Design:**

```r
attach_elevation(cover, elevation_lookup)
prepare_calibration(cover, satellite, grid, cfg)
make_grid(data, coord_fun, projection, resolution)
```

Network and cache I/O stay in the wrapper. Validate unique cache coordinates, finite
elevations and complete lookup coverage; never refresh a present cache implicitly.
Functions take data and config explicitly; they do not read environment variables,
source scripts or discover files. Baseline outputs gain no columns or attributes.

**Verification:** Run 1 with and without diagnostics, then 2 and 3; both land-cover
tables and the calibration table byte-identical to the anchors (the cache reproduces
them). Test cache gaps and duplicate coordinates.

**Acceptance criteria:**

- [ ] Preparation callable without plotting or network access.
- [ ] Baseline schemas, order and cache behaviour preserved.

**Open points:** None.

## I10

**Title:** Extract prediction and response-summary functions (script 6)

**Depends on / blocks:** I06 / I09, I13b. Parallel with I08, I11, I12, I13a.

**Goal:** Make prediction callable with explicit models and data, keeping fitted means
and summaries of simulated responses distinct.

**Scope:** `scripts/6_prediction_model.R:27-86` into `R/prediction.R`; expose the
simulation wrapper for script 5 (I09). No coefficient draws, no ensemble driver, no
production seed.

**Design:**

```r
predict_albedo(model, cover, month, cfg)
simulate_responses(model, data, n)
summarise_responses(samples)
```

Deterministic predictions, response samples and summaries returned separately. The
baseline `iter` column on disk is preserved; internally the response identity is named
`resp_draw` and the optional land-cover identity `lc_draw`, and `lc_draw` is in every
melt id and summary grouping so it cannot be averaged away (`6:51-58`). The wrapper
handles reads and writes through the path and manifest helpers; the functions need no
output directory.

**Verification:** Run 6 from the frozen selected models and the frozen land-cover table.
Deterministic predictions byte-identical to the anchor; summaries within I01's measured
tolerances plus a paired-RNG check (same seed, old code versus new, identical). A
two-`lc_draw` fixture stays distinct; a response label above 999 parses. Keep `gratia`
attached unless a full run proves otherwise (`AGENTS.md:43`).

**Acceptance criteria:**

- [ ] Predictions, summaries and artefact schemas preserved.
- [ ] Draw identities separate; no global or file discovery in functions.

**Open points:** A2/A3 unresolved; extraction must not reinterpret response draws as
coefficient uncertainty.

## I11

**Title:** Extract and consolidate both albedo-difference stages (scripts 7, 7a)

**Depends on / blocks:** I06 / I13b. Parallel with I08, I10, I12, I13a. The hardest
issue in the set; its agent should hold nothing else.

**Goal:** Separate the numerical differences from the maps and remove the quadratic
`rbind` growth, preserving the coarse recipe and the consecutive-slice science exactly.

**Scope:** Script 7's ice and coarse preparation and difference loop
(`scripts/7_plot_preds.R:46-130`, `:383-459`); script 7a's Dalton extraction, areas and
loop (`scripts/7a_alb_diff_full.R:51-71`, `:110-140`, `:224-319`). New `R/differences.R`.
Plot statements stay in scripts.

**Design:** `prepare_ice_tables()`, `difference_coarse()`, `difference_albedo()` with
explicit data and config arguments; shared calendar completion and pair construction;
separate coarse and consecutive formulas. Geometry and fraction tables are prepared once
and passed in; no persistent cache system. Group by cell and month plus optional
`lc_draw`, with explicit age ordering. Preserve the one-pass ice adjustment, threshold
masks formed before adjustment, missing-value behaviour and `rowSums` choices
(`7a:245`, `:285`, `:296`), legacy polygon matching, and the three albedo roles. Do not
activate the unused "complete cells" table. Return data separately from serialisation,
then **restore baseline row order and row names before `saveRDS`**: the MD5 gate sees
them.

**Verification:** Run 7 and 7a from the frozen all-months predictions
(`paleo_interp_predict_gam_summary_bluesky.RDS`, 6bd0a8e5). All five tail artefacts
(four from 7, one from 7a) byte-identical: `ALB_diffs_bluesky.RDS` must remain
8039899288aaf84877b904c51e941448 (`tests/anchors/README.md:96`); script 7's four are
demonstrated reproducible (I01). Test missing ages, threshold crossings, multiple
readvances and two draw identities. Run 8 and 9 on the regenerated differences.

**Acceptance criteria:**

- [ ] Five frozen-input artefacts byte-identical; no tolerance substitutes for this gate.
- [ ] Row order and row names restored before writing.
- [ ] Computations run without plotting; repeated implementations shared.

**Open points:** C2's first-pair failure and the readvance policy are separate work; not
"cleaned up" inside vectorisation.

## I12

**Title:** Extract kernel sampling and forcing functions (script 8)

**Depends on / blocks:** I06 / I13b. Parallel with I08, I10, I11, I13a.

**Goal:** Separate spatial kernel sampling from multiplication so sampled kernels can be
reused; preserve every forcing variant and conversion.

**Scope:** `scripts/8_radiative.R:63-159` into `R/kernels.R`. The wrapper keeps the
diagnostic plots and the existing forcing path. No new kernel products or sky
conditions.

**Design:**

```r
sample_kernels(cells, months, sources, cfg)
apply_kernels(differences, sampled_kernels, cfg)
```

Sample once per distinct cell and month and return a reusable table; validate join
uniqueness so no difference row is multiplied or dropped; preserve optional `lc_draw`.
Canonical month numbers; the configured CACK year maps to its dimension coordinate
(2003 → band 3). Preserve the CACK transpose/flip and coordinate arithmetic (`8:107`,
`8:112`), the factor of 100 for HadGEM3 and CAM5, CACK's sign without that factor, all
thirty forcing columns and the strict latitude bounds.

**Verification:** Run 8 from the anchored `ALB_diffs_bluesky.RDS`; forcing MD5 matches.
Compare reused versus freshly sampled tables; four non-consecutive months; reordered
months; two draw identities; run without script 7's ice tables; check the CACK year
mapping and all three conversions directly.

**Acceptance criteria:**

- [ ] Frozen-input forcing byte-identical, schema and order included.
- [ ] Sampling reusable and independent of plotting and of script 7.

**Open points:** C3/C4 are scientific decisions; nothing changes here.

## I13a

**Title:** Extract aggregation functions (script 9)

**Depends on / blocks:** I06 / I13b. Parallel with I08, I10, I11, I12.

**Goal:** Make the final numerical summaries callable independently of the charts.

**Scope:** Period preparation and aggregation at `scripts/9_forcing_barplot.R:145-177`,
IPCC preparation at `:198`, the recovered recipe at `:325`, into `R/aggregation.R`.
Keep the assumption header.

**Design:**

```r
aggregate_forcing(data, column, cfg)
aggregate_egu_recipe(coarse_differences, kernel_table, cfg)
prepare_modern_erf(best, lower, upper)
```

Remove the closure over global `d` and `EARTH_AREA`. Carry optional `lc_draw` through
completeness checks, grouping and joins; never compute ensemble intervals here. Preserve
period sums → monthly means → area weighting, the NA behaviour and both normalisations.
Keep the EGU recipe separate with its four-month requirement. Plots consume the returned
tables.

**Verification:** Run 9 from the frozen tail inputs; all four CSVs byte-identical to I01.
Test incomplete periods, missing kernel months, two draw identities.

**Acceptance criteria:**

- [ ] Aggregation independent of plots and global state.
- [ ] Four CSVs byte-identical.

**Open points:** None.

## I09

**Title:** Extract calibration fitting and evaluation functions (scripts 4, 5)

**Depends on / blocks:** I10 / I13b.

**Goal:** Move fitting and numerical evaluation into reusable functions, reusing the
simulation wrapper from I10; diagnostic plots stay in the scripts.

**Scope:** `scripts/4_calibration_model.R:25-105`, `:123-140`, `:149-221`;
`scripts/5_calibration_eval.R:35-60`, `:168-190`, `:231-260`. No change to fitting
method, formula, uncertainty model or coverage denominator (`5:183`; B2b is a separate
correction). The spatial-eval script is out of scope (I06).

**Design:**

```r
fit_calibration(data, month, model_id, cfg)
compare_calibrations(models)
evaluate_calibration(model, data, month, cfg)
```

Registry-driven; return numerical tables plus plot-ready data; record expanded formulas.
Keep the existing execution and RNG order, including repeated fits or simulations where
removing them could change results: the registry may implement the three mod8 fits
through one function, but the three files are still written until Andria answers
(general 7). All selected-model writes honour the configured id.

**Verification:** Old code versus new function: fit mod8 for one month, predictions on
the calibration table to 1e-6, integer AIC equal. Script 5 from the frozen fits with the
paired-RNG check and I01's tolerances. Script 6 from the resulting selected fits. The
full ladder is refitted once, in I13b, not here.

**Acceptance criteria:**

- [ ] Fitting and evaluation live in `R/`; plots in scripts.
- [ ] Registry selection and numerical behaviour match the baseline per I01.

**Open points:** The duplicate mod8 fits (Andria, general 7).

## I13b

**Title:** Integration gate: full baseline run and reconciliation with chris-dev

**Depends on / blocks:** I08, I09, I11, I12, I13a / I14, final merge.

**Goal:** Prove the assembled migration preserves the pipeline end to end, including the
one full refit, and reconcile it with Andria's intervening edits. This is a gate, not a
feature PR.

**Scope:** The full baseline sequence; README configuration, run-order and provenance
sections (`README.md:118`, `:282`); audit that every numerical stage is callable from
`R/` and every wrapper keeps invocation, I/O and plots; final merge of `chris-dev` into
`feature/single-config`.

**Design:** Merge `chris-dev` into the feature branch (not rebase: the branch is built
from `--no-ff` merges and CONTRIBUTING's history rule forbids flattening; exception
recorded 2026-10-08). Resolve conflicts, then re-run every check affected by a conflict;
a conflict resolution is not verified by earlier runs. Escalate any resolution that
changes scientific behaviour.

**Verification:** Run 1 to 9 from scratch, including the 27-hour ladder, plus script 1
in diagnostic mode and script 3. Deterministic artefacts byte-identical; stochastic
artefacts within I01's measured tolerances; fitted models by formula, predictions and
diagnostics. Then the alternative-setting runs under redirected profiles: one
four-month subset through 4 to 9, one `reduction = "median"` run of scripts 1 and 2, one
`analysis` mismatch stopped and overridden, one presentation-only change passing.

**Acceptance criteria:**

- [ ] End-to-end and frozen-input checks pass with documented limits.
- [ ] Feature reconciled with Andria's edits by merge; granular history intact;
      `main`, `legacy` and the anchors untouched.
- [ ] README updated.

**Open points:** Final merge timing must respect Andria's ongoing review on `chris-dev`.

---

# Part 3. The parked ensemble issue

## I14

**Title:** Reserve the ensemble driver for a separate design

**Depends on / blocks:** I13b / future ensemble work only. **Placeholder: design later;
no implementation agent assigned.**

**Goal:** Record the interface requirements the step 4 functions must satisfy, without
committing to ensemble semantics.

**Requirements on the extracted functions:**

- An integer `lc_draw` passes through prediction, differences, kernels and aggregation
  without being dropped or collapsed; response-draw identity (`resp_draw`) stays
  separate.
- `reduce_land_cover()` can later accept `method = "draw"` (per-draw passthrough) without
  changing the mean or median semantics.
- Paths are redirectable by an explicit profile while baseline file names stay unchanged.
- Static geography, ice fractions and sampled kernels can be prepared once and passed to
  repeated calls.
- No script is the sole implementation of a numerical computation; plotting is optional
  for callers.

**Design / Verification:** to be designed. Inputs: the fable review of 2026-10-07
section C, and the codex review section 4 (two distinct experiments: conditional on a
fixed calibration, or matched calibration per draw).

**Open points:** Before any ensemble number is quoted, Andria must confirm whether
`iter` is a joint posterior draw across cells and slices, and which uncertainty claim the
paper makes (scientific A1(d)).

---

# Part 4. Risks for implementers and reviewers

From revision 1:

- Singleton switches, diagnostic-only alternatives, or accepted settings some scripts
  ignore.
- Calendar: source-band numbers, selected-vector order, missing months, fixed
  February/November sections, partial EGU recipes.
- Hidden numerical settings misclassified as presentation (script 7's longitude cutoff,
  the polygon-age alias).
- Collapsing the three ice-albedo roles or three map windows into one convention.
- Provenance: older manifests accepted after newer failed writes; stale outputs claimed
  by directory scans.
- Failure honesty: invalid config, graphics-device failures, partial outputs.
- Refactor arithmetic hidden by loose comparisons: row order, factor levels, units, NA
  masks, one-pass ice adjustment, simulation call order.
- Verification limits: unseeded statistics, absent model anchors, LFS pointer files
  mistaken for data.
- Integration: parallel agents sharing output paths; scientific changes hidden in merge
  resolutions; regenerated results replacing anchors.

Added by the adversarial review:

- **Key-set churn.** The check compares the whole `analysis` section, so any key added
  after I06 invalidates every earlier manifest and implementers reach for the override
  by habit. The key set closes at I06.
- **Andria's edits landing on lines being extracted.** Tell her which scripts are being
  extracted when (general questions); keep stages 7 and 8 short; merge `chris-dev` in at
  each stage boundary.
- **Thread count as a scientific setting** would make core count invalidate artefacts.
- **`bam` bit-reproducibility at `nthreads = 8`** is not established; the one-month check
  uses a tolerance, stated in I01 before anyone sees candidate results.
- **The spatial-eval script** carries a third copy of the draw-count and draw-parsing
  defects; if revived it goes through the registry and `R/prediction.R`.
- **Figures as outputs**: wrapping every `ggsave` doubles I06; the mtime rule avoids it.
- **Rebasing a merge-built branch** would rewrite the history CONTRIBUTING says to keep.
