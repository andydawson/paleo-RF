# Adversarial review of the single-config design (second opinion)

**What this is.** A second, adversarial review of Chris's single-configuration-file
proposal and of the codex review of it
(`2026-10-07_design_review_single_config_codex_gpt6astra.md`), requested by Chris on
2026-10-07 before any migration planning. The reviewer was told to argue against both
the codex review and Chris's own position, then commit to a recommendation.

**Chris's position, as given to the reviewer.** Scientific decisions should live in the
config file: a central, human-readable, version-controlled file holding every parameter
value and data file name gives oversight of how the whole pipeline is set up. Downstream
scripts should ingest the run manifest alongside each input and check for consistency, so
parameter changes are deliberate, not silent. An ensemble mode behind a single config flag
would be nice if it is not too complicated.

**Who wrote it.** Claude (Fable 5.1), as a subagent of a Claude Code session, with shell
access to the repository at `chris-dev` 1c275c5. It checked every codex line citation
against the live code, read `data/veg_posts_interp_ice.RDS` directly, and inspected the
installed R environment. 195k tokens, 24 tool calls.

**Status.** Advice, not decision. The recommendation in section F is the hand-off for the
agent that plans the migration. The three decisions it lists for Andria have been added
to `questions_for_andria_scientific.md` (A1(d)).

---

# Adversarial review: single config, manifests and the ensemble flag

Reviewer: Claude (Fable 5.1), 2026-10-07, with shell access. Repository at `chris-dev` 1c275c5. The scripts are byte-identical to c8af88d (only `README.md` and the codex document changed since), so every codex line citation was checked against the live code. Inputs read: AGENTS, CONTRIBUTING, README, `R/run_manifest.R`, `R/map_helpers.R`, scripts 1, 2, 4, 5, 6, 7, 7a, 8, 9, the tail of `6_prediction_model_spatial_eval.R`, the anchor READMEs, the scientific questions file, the last manifest in `runs/`, and `data/veg_posts_interp_ice.RDS` itself (41,961,600 rows; `iter` 1-200 present for all 209,808 cell-slice-class combinations; ET+ST+OL sums to exactly 1 in every draw).

## A. Verdict on the central disagreement

**Chris is right about the goal and codex is right about the boundary, and they are closer than the wording suggests.** The codex "registry" is Chris's position restated: formulas live in versioned R, the config holds `calibration$model_id = "mod8"` and the exposed `k` values, and the manifest records the expanded formula. Nobody is proposing that `s(OL, ET, ST, bs='tp', k=200)` be typed into YAML. The genuine disagreement is narrower, and it is codex's section 6 sentence: *configuration must not turn unresolved assumptions into apparent facts*. That is correct, and Chris's consistency-check idea does not touch it, because a consistency check detects *change*, not *wrongness*. The two ideas are orthogonal and both are needed.

Sorting the three classes against the real scripts:

**(i) Selectors among implemented alternatives: in config.** `alb_prod` (`scripts/4_calibration_model.R:9` and five other scripts), the selected model id (`scripts/5_calibration_eval.R:28`, hard-coded as mod8 and saved three times, 5:33, 5:103, 5:329), the kernel set and forcing variant (`scripts/9_forcing_barplot.R:111-117`), the ice-albedo column (`scripts/7a_alb_diff_full.R:123-124` uses `ice_albedo_fixed` and `ice_albedo_sc`; `scripts/7_plot_preds.R:165` uses a third, `ice_albedo`), the land-cover reduction (`scripts/1_veg_lct_prep.R:40-42`, with Andria's own "not sure if should use median" at 1:39). All of these are scientific decisions, and all belong in the config, because the alternative is what exists now: the decision is invisible, duplicated, and in three cases inconsistent across scripts.

**(ii) Numeric parameters of an implemented method: in config, with care.** The slice list `ages` (7:35, 7a:27, 8:44, and implicitly 9:145), `nsim = 100` (6:37, 5:47), `ctrl = list(nthreads=8, maxit=500)` repeated at 4:14, 4:23, 4:111, 4:147, 4:227, the analysis domain trims (`x > -170` at 7a:73; `lat 27-74` at 8:122-123), the 0.5 ice threshold (7a:136-137, 7a:251-252), `EARTH_AREA` (9:112). The domain trims are a good example of something that *looks* like a plotting detail but is an analysis choice that moves the headline number. The map windows are the opposite: `xlim/ylim` at 7:41-42, 7a:35-36, 8:19-20 (-166..-50, 12..82), `MAP_XLIM` in `R/map_helpers.R:21-22` (-172..-50, 15..80) and script 1's diagnostics (-172..-50, 17..79) are three different windows. Codex says plotting details stay in code; agreed, but a value three scripts share has to be defined *once*, in `R/`, or it will keep drifting. The `months` vector is the trap in this class: it is repeated nine times, and making it a setting is on the README roadmap (README.md:71-74), but a subset such as `c('feb','may','aug','nov')` silently selects the wrong kernel band because `scripts/8_radiative.R:81` derives the month number from the *position* in the vector. Making `months` configurable requires fixing 8:81, 4:116 and 7a:159 first. Codex caught all three.

**(iii) Different analyses that need different code: not config switches, however much they look like one.** The point flavour (coordinate contract differs, `questions_for_andria_scientific.md:108-145`); the matched-calibration ensemble (refits per draw); coefficient-uncertainty draws (A2, not implemented). The rule I would adopt: **a config key may only take values the code implements today, and a key with one legal value does not exist.** Codex's own sketch breaks this twice (`coefficient_draws = 0L`, and "reject `flavour = 'point'`": a rejected value is still an advertised one). No `flavour` key until there are two flavours.

Median is the interesting border case. Codex is right that it touches calibration: the modern slice is extracted *after* the reduction (1:78), joined to albedo at 2:132 and fitted at 4:98, so a median run invalidates everything. But the *code* change is one line plus renormalisation, so it *is* a config switch, one that happens to invalidate a 27-hour artefact. That is precisely where the consistency check in section B earns its keep. Two facts from the data for whoever implements it: every draw sums to exactly 1, so the mean preserves closure and the median does not; and script 1's diagnostic (1:206-212) already measures how far the medians sum from 1.

**The concrete "apparent fact" cases in this repo.** `cack_band = 3` (`scripts/8_radiative.R:36`, 8:110). Written as `kernels$cack$band = 3  # year 2003` it reads as a decision; question C3(b) asks whether the climatological-mean layer `CACK CM` was intended. The honest key is `cack_layer = "year_2003"` with a comment pointing to C3 and the alternative `"climatology"` listed only once implemented. Same for `forcing$variant = "veg_ice_thresh"`: it is Chris's assumption A1, and the config comment must say so. Same for `ice$albedo_column`. A manifest check will faithfully carry `year_2003` through every run and never once ask whether it is right. The remedy is procedural, not technical: each config key that encodes an open question carries the question id in its comment, and the questions file lists the key. When Andria answers, the comment goes.

## B. Manifest-ingestion consistency checks

**What is compared.** Not the full config hash: a change to a plot palette must not invalidate the calibration. Each script declares the config keys it consumes (`uses = c("land_cover.reduction", "calibration.model_id", ...)`), the helper resolves those into a *lineage*: the script's own used keys and values, unioned with the lineages of every input it loaded. Lineages propagate transitively, so script 9's lineage contains script 1's reduction. A downstream script compares its current config with the lineage of each input on the *intersection* of keys. A plotting key is in no upstream lineage, so changing it invalidates nothing; `reduction` is in every lineage, so changing it stops everything. This reuses the 27-hour calibration correctly without any special casing.

**How the link from file to manifest is made.** Three options were weighed. Embedding provenance as an attribute on the RDS object fails for CSV, tif and png, and dplyr verbs drop attributes. A run directory per resolved config makes "re-run only script 9 after editing it" awkward, which is exactly what Andria does interactively. A sidecar `<output>.prov.json` written by the same helper that saves the output works for every file type, survives copies, and detects hand edits by md5. Sidecars for the baseline; run directories for the ensemble members and for experiments.

**On mismatch: stop.** A warn-only mode produces the silent drift Chris wants to prevent. Override with `RUN_ALLOW_STALE=1` in the environment, recorded in the manifest as a deliberate override with the mismatching keys listed. Missing sidecar (an output written outside the helper): stop by default, with `execution$require_provenance = FALSE` for the transition period, recorded likewise.

**Failure modes.**
- *Stale manifest / hand-edited output*: the sidecar holds the output's md5; `load_input` rehashes and stops on mismatch. This requires hashing outputs, which `R/run_manifest.R:86` currently disables.
- *Dirty tree*: allowed, flagged, and carried in the lineage, so a final number can be traced as "not reproducible from a commit". `R/run_manifest.R:39` checks only `scripts R`; it must add the config file and `R/` registries, and arguably `data/` (committed inputs such as `albedo_glacier_monthly.csv` are editable; input md5s cover that partially).
- *Two runs in the same minute*: run id = timestamp to the second plus the pid; the record is written at `run_start`, not `run_end` (`R/run_manifest.R:29` persists nothing until the end, so a crash leaves nothing).
- *RStudio without a wrapper*: there is no wrapper; the helper is inside the script, so `source()` works. Line-by-line execution reaches `run_start` and may never reach `run_end`: the record stays `started`, which is the truth. Outputs written with raw `saveRDS` have no sidecar and trip the check downstream, which is the designed behaviour.
- *Config edited between scripts*: the sidecar lineage *is* the frozen snapshot; the next script compares against the file as it now stands and stops if a shared key moved. Codex's "freeze at pipeline start" is only needed by a driver.

**Workflow tool.** `targets` does all of this (hash of code, inputs and arguments) and would delete most of the helper, but it needs functions, not scripts. Build the sidecar helper now (it is small), write the stages as functions in `R/`, and revisit `targets` once functions exist. Do not build a scheduler.

**Sketch.**

```r
cfg <- load_config("config.R", profile = Sys.getenv("RUN_PROFILE", "default"))  # validated list
run <- run_start("6_prediction_model", cfg,
                 uses = c("analysis.months", "analysis.ages", "calibration.model_id",
                          "prediction.response_draws"))                      # writes runs/<id>.json, status=started
mods  <- lapply(cfg$analysis$months, function(m) load_input(run, path_cal_model(cfg, m)))
paleo <- load_input(run, path_land_cover(cfg, "paleo"))                       # rehash, lineage check, parent link
...
save_output(run, preds, path_prediction(cfg, "summary"))                      # file + <file>.prov.json
run_end(run)                                                                  # status=completed, md5s, markdown view
```

`load_input` stops with a message naming the key, the value in the input's lineage and the value in the current config. `run_end` is also registered with `on.exit`/`tryCatch` so a failure writes `status=failed` with the error. All paths come from `path_*()` functions in one file, so a profile can redirect them (ensemble members) without touching a script.

## C. The single ensemble flag

**It is realistic as the switch of a driver, not as a mode the nine scripts obey.** Chris's doubt is right about the second and wrong about the first.

What has to change for the conditional ensemble (fixed mean calibration, repeat per land-cover draw), from the code:

- **Script 1**: 1:40-42 averages over `iter`; this is where draw identity dies. Replace with `reduce_land_cover(x, method)` where `method` is `mean`, `median`, or `draw`; in ensemble mode the paleo table keeps a `draw` column (14.3 M rows, fine) and the modern table (1:78) is still the mean. Elevation (1:58-70) is per cell and cached.
- **Scripts 2, 4, 5**: unchanged.
- **Script 6**: `predict.gam` (6:27) is seconds per month and carries any extra column through `data.frame(lct_interp_paleo, ...)` at 6:30. `simulate` (6:36) with `nsim = 100` is the 15 minutes; set `response_draws = 0` for a land-cover-only ensemble. The summary at 6:51-58 collapses response draws and would collapse land-cover draws too unless `draw` is a grouping key; name the two `lc_draw` and `resp_draw` so nobody confuses them again. All five output paths (6:33, 6:48, 6:60, 6:85-86) are fixed and would be overwritten per member. 6:46 (`substr(iter, 2, 4)`) truncates `V1000` to `100`.
- **Script 7**: figures; skip in ensemble mode. Its data products are `ice_fort*.RDS` (7:76, 7:458-459) and `alb_interp_preds_diffs` (7:412). The former are read by script 8 at 8:38-40 and **never used again in script 8** (checked every line to 8:197); the latter feeds only the recovered EGU-recipe panel at 9:325. So script 7 is not on the ensemble's critical path at all.
- **Script 7a**: the Dalton extraction (7a:51-71) is per age, draw-independent, cache once. 7a:126 takes `alb_mean`; the loop 7a:224-319 is a lag over sorted years within (cell, month) and becomes `group_by(cell_id, month, draw) %>% mutate(lag(...))`, which also removes the quadratic `rbind` the README already flags. Output 7a:323 fixed path.
- **Script 8**: kernel extraction (8:78-120) is per cell-month, draw-independent, cache once as a (cell_id, month, kernel) table; the thirty lines at 8:125-159 are a join and three multiplications. 8:195 fixed path, no `alb_prod` tag.
- **Script 9**: `aggregate_forcing` (9:167-177) gains `draw` in every `group_by`; the output becomes per-draw period totals, then quantiles across draws. 9:141 fixed path.

**Carrier**: one integer column `lc_draw` from script 1 onward plus a member directory `output/ensemble/<run-id>/draw-NNN/` from the path functions. **Lost today at** 1:42, 6:51, 7a:126 (and 8 and 9 never had it).

**Codex's cost estimate.** The arithmetic is right: 200 × (15 + 62 + 52 + 0.3 min) = 430 h. But what dominates it is script 7 (maps, skippable) and script 7a's quadratic loop (already slated for removal). After the refactor the plan calls for anyway, with `response_draws = 0`, a member is roughly a minute of `predict.gam` plus joins; 200 members is hours, not 18 days, and trivially parallel. The 140 GB storage figure assumes storing 200 land-cover draws × 100 response draws jointly; the design simply never does that. Likewise the matched-calibration estimate of 5,400 h is for the full eight-model ladder; refitting mod8 alone (README.md:130: 1-5 min per month) is at most an hour per member, about 200 h serial, under two days of wall time on this 48-core machine. That moves A1 option (iii) from "probably out of reach" (`questions_for_andria_scientific.md:31-33`) to "feasible, but a different claim". It is still a different experiment: whether modern draw k and paleo draw k are the *same* joint draw is not something the file can prove (it only shows `iter` is complete 1-200 everywhere), and it is also the question that decides whether summing forcing across cells *within* a draw is meaningful for the conditional ensemble. If `iter` were independent per cell, cross-cell sums would average the uncertainty away and the ensemble spread of the continental total would be spuriously narrow. Andria must confirm `iter` is a joint posterior draw of the spatial model before any ensemble number is quoted.

**Minimum honest design.** Stages become functions in `R/` (`reduce_land_cover`, `predict_albedo`, `difference_albedo`, `apply_kernels`, `aggregate_forcing`); scripts 1, 6, 7a, 8, 9 become thin wrappers that call them for the baseline; `scripts/run_ensemble.R` loops members, calls the same functions with `draw = k`, writes member manifests and a parent. The config block is codex's, minus the unimplemented keys:

```r
ensemble = list(members = "all",            # or an integer vector; resolved to ids in the manifest
                calibration = "fixed_mean",  # the only implemented policy
                response_draws = 0L)
```

**What the flag can promise**: "the pipeline downstream of a fixed calibration, run once per land-cover draw, and the distribution of the final forcing across those draws". **What it cannot**: calibration-covariate uncertainty, coefficient uncertainty (A2), ice-chronology uncertainty, kernel uncertainty (the CACK `Sigma_*` layers). The manifest and the paper must say "conditional on the fitted calibration".

## D. Format

Codex says `config.R`. The strongest case for YAML: it cannot execute code, diffs line by line, is readable by non-R tools, the `config` package gives profiles with inheritance for free, and the resolved values round-trip to a manifest trivially. The strongest case against it, in this repo: `ages = c(50, 200, seq(500, 11500, by = 500))` is one readable line in R and 25 numbers in YAML; `yaml` is not installed (only `jsonlite`, `digest`, `rlang`, `withr` are, verified in the env); YAML's scalar rules bite (`1e4` is a string under the 1.1 spec `yaml` implements, `no` is `FALSE`); and Andria reads R all day and YAML never. The real risk of `config.R` is that it can compute, load data and read the environment. Mitigate it in the loader: evaluate the file in a child of `baseenv()` with no `library`, require it to return one list, validate against a schema in `R/config_schema.R` (names, types, allowed values, unknown keys rejected), and dump the resolved list as JSON into every manifest. The JSON is what tools and the consistency check read; the R file is what Andria edits. For the package, functions take `cfg` as an argument and never discover a file, so the format of the source file is irrelevant to the package. **Decision: `config.R`, one file, base plus profiles of a few lines, loaded through a validating helper.**

## E. What codex missed or got wrong

Every line citation that bears on a conclusion was checked and is correct (1:18, 1:40, 1:78, 2:132, 4:98, 4:116, 4:234, 5:28, 5:116, 5:218, 6:24, 6:43, 6:46, 6:51, 7:17, 7:76, 7:85, 7:412, 7:552, 7a:126, 7a:159, 8:36, 8:38, 8:81, 8:195, 9:325, `run_manifest.R` 17/25/29/39/48/78/83/86, CONTRIBUTING 62/69, questions 38/108, anchor README 9/13). Substantive points:

1. **Script 8 does not consume script 7's ice products.** It reads them (8:38-40) and never uses them. Codex's "ice products consumed by 8" (section 4) is wrong, and it matters: script 7 leaves the ensemble critical path entirely, and 8:38-40 can go.
2. **The cost estimate names the wrong driver.** Correct arithmetic, but 7 and 7a dominate, both avoidable (see C). Presenting 430 h as the ensemble's cost will make Andria decide against an experiment that costs hours.
3. **Matched calibration is feasible** at mod8-only cost (C above). Codex itself says "benchmark fitting only the chosen model" but leaves the 225-day figure standing as the headline.
4. **The CACK 2002/2003 disagreement is resolved**: README fixed at fb03523. Not an error; the codex header already warns.
5. **The anchor comparison is path-keyed** (`tests/anchors/*/MD5SUMS.txt` by file name). Run directories or renamed outputs break it. The migration needs a `baseline` profile whose paths are today's, or anchor tooling that reads sidecars. Codex does not mention this.
6. **Scattered analysis-domain choices** (7a:73, 8:122-123, the 0.5 ice threshold) are not in codex's list of what goes in config; they move the headline and belong there.
7. **Script 9 already is the model**: 9:109-122 is a mini-config with the manifest capturing it (`runs/2026-09-23_1601_9_forcing_barplot.md`). Start the migration there.
8. Minor: `tests/anchors/README.md:16` still says there is no interp anchor; there are two.

## F. Recommendation

Build, in this order, each step anchored before the next:

1. **`R/config.R` loader plus `config.R` with the baseline values**, validating, resolved JSON in every manifest. Keys only for implemented choices; keys encoding open questions carry the question id in a comment. Start by lifting script 9's header, then `alb_prod`, `ages`, `months` (after fixing 8:81, 4:116, 7a:159), model id, kernel layers, ice-albedo column, domain trims, reduction, `nsim`, `ctrl`. Shared map window into `R/map_helpers.R`.
2. **Manifest v2**: record at start, status transitions, run id to the second, output md5s, config and `R/` in the dirty check, sidecar provenance per output, `load_input`/`save_output` with lineage checks that stop on mismatch. Wire into scripts 1-6.
3. **Path functions** in one file; a `baseline` profile that reproduces today's paths so the anchors keep working; retire the fixed names in 6, 7a, 8.
4. **Stages as functions** in `R/`: land-cover reduction, prediction, differences (vectorised, replacing the 7a and 7 loops), kernels (cached extraction), aggregation. Scripts become wrappers. Anchor 7a byte-for-byte; prediction summaries with tolerance until seeded.
5. **`scripts/run_ensemble.R`** over those functions, conditional policy only, member directories and a parent manifest. Pilot with 20 members.

Not now: point flavour, `targets`, coefficient draws.

Decisions Andria must make first:

- **Is `iter` a joint posterior draw** of the spatial interpolation (same draw across cells, slices and the modern slice)? Without a yes, per-draw continental sums are not meaningful and "matched" does not exist.
- **Which uncertainty claim does the paper make**: land-cover only, conditional on the calibration (what the flag delivers), or including coefficient uncertainty (A2, more code)?
- **The two keys that would otherwise freeze open assumptions**: CACK layer (year 2003 versus climatological mean, C3b) and the ice-albedo column (C0a). Mean versus median can stay a switch and be answered by running it.
