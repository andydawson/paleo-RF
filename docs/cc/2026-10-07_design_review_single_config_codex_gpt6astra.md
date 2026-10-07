# Design review: one configuration file and per-script manifests

**What this is.** An independent design review of Chris's proposal (2026-10-07) to move
every setting of the pipeline into a single configuration file, to use that to switch
between run modes (interp/point, mean/median, a 200-draw ensemble), and to have every
script write a run manifest. Requested before any migration is planned.

**Who wrote it.** OpenAI Codex CLI 0.155.1, model `gpt-6-astra`, reasoning effort `max`,
driven by a Claude Code session on 2026-10-07. Codex's own sandbox (bubblewrap) cannot
start on this workstation, so the model had no shell: the repository files it needed were
pasted into the prompt verbatim with line numbers (AGENTS, CONTRIBUTING, README,
`R/run_manifest.R`, `R/map_helpers.R`, all pipeline scripts, the anchor README and the
scientific questions file, as of `chris-dev` c8af88d). Line citations refer to those
versions. 129,285 tokens used. The brief it was given is appended at the end.

**Status.** Advice, not decision. Chris intends to have a separate agent design and plan
the migration using this review as input. Nothing here has been acted on.

**Points worth checking before relying on them.** The review flags a disagreement between
README and the script 8 manifest about which year CACK band 3 is (known issue 37 covers
the band/year ambiguity). Its compute and storage estimates for the ensemble extrapolate
the timings in README and are explicitly not benchmarks.

---

## 1. Verdict

Centralising run choices and recording every execution is a good design for this project, provided the configuration remains small and validated. Use one configuration entry point, shared rules for deriving paths, and explicit identities for runs and their outputs. The biggest risk is treating new scientific analyses as harmless configuration switches, especially presenting an ensemble with fixed calibration as complete uncertainty propagation.

## 2. Format and mechanism

**Recommend a root `config.R` returning one nested list**, loaded through a shared helper in `R/`. R has no mandatory project-configuration format; this choice fits Andria’s existing workflow: comments, vectors, `seq()`, and ordinary R editing.

Evaluate it in a private environment, extract and validate the list, and pass `cfg` explicitly to functions. Avoid sourcing loose assignments into every script’s global environment. Keep configuration deterministic: no data loading, random sampling, package attachment or scattered environment-variable reads.

YAML with `config` is a credible alternative. Its named configurations automatically inherit `default`, can explicitly inherit other configurations, and can be selected through `R_CONFIG_ACTIVE`. That convenience is useful, but adds implicit state and another syntax here. [Official configuration documentation](https://rstudio.github.io/config/articles/introduction.html).

Given the supplied package inventory, `jsonlite` is installed; `config`, `yaml`, `RcppTOML`, `targets`, `renv` and `here` are not. This recommendation needs no new parser. Use JSON for the **resolved machine-readable record**; its lack of comments makes it less suitable for Andria’s working file. TOML offers little compensating benefit for this entirely R-based project.

## 3. Structure of the configuration

Start with **one file containing a base configuration and a few short named profiles**. Split profiles into separate files only when actual experiments make that useful. Avoid copying complete configurations or constructing an inheritance tree for every flavour–reduction combination.

Organise settings by purpose:

| Block | Contents |
|---|---|
| `inputs`, `analysis` | External dataset paths, flavour, albedo product, selected months, physical ages, modern slice |
| `land_cover`, `calibration`, `prediction` | Reduction/run mode, calibration policy, selected model, controls, separately named draw counts |
| `spatial_eval`, `forcing`, `plots` | Optional experiment settings, kernel/aggregation choices, map window and shared scales |
| `execution` | Threads, diagnostic flag, checkpoint/output-retention choices |

A profile should override only relevant fields. Define replacement rules—particularly for vectors—and reject unknown keys, invalid types and unsupported combinations before expensive work.

Keep `RUN_NOTE` and `DIAGNOSTIC`; allow a documented thread override. Resolve precedence once: **base → profile → whitelisted environment → explicit invocation arguments**. Record every effective override. Strictly parse booleans: the current `as.logical()` approach can produce `NA` (`scripts/1_veg_lct_prep.R:18`). Establish BLAS settings before launching R and budget worker count together with internal threads (`README.md:269`).

Configure external inputs and output roots; **derive intermediate filenames centrally**. For example:

```text
output/interp-mean/<run-id>/prediction/...
output/interp-ensemble/<run-id>/draw-0042/forcing/...
```

Downstream stages should consume explicit producer artifacts, checking their input/configuration identities. They must not independently reconstruct paths or fall back to an old shared filename. Today the final forcing filename does not even identify the albedo product (`scripts/8_radiative.R:195`).

Freeze the resolved configuration when a pipeline run starts. All scripts in that run consume that snapshot, even if Andria subsequently edits `config.R`. Reuse expensive fits only when their relevant settings, code and inputs match; changing plot colours should not invalidate calibration.

## 4. The three run modes

**Interp versus point.** Keep point retired unless there is a renewed scientific reason to support it. Retirement was an explicit agreement, not unfinished engineering (`CONTRIBUTING.md:62`).

A working switch requires adapters and verification, not filename substitution. In particular, point `x/y` are projected metres while interp `x/y` are longitude/latitude; that changes the spatial GAM itself (`docs/cc/questions_for_andria_scientific.md:108`). A revived implementation needs an explicit coordinate contract, canonical columns/keys, appropriate elevation lookup and plotting support. Until then, reject `flavour = "point"` rather than advertise unsupported functionality.

**Mean versus median.** This changes calibration as well as prediction. Script 1 reduces all ages, then extracts age 50; script 2 combines those modern fractions with satellite albedo; script 4 fits their cover smooth (`scripts/1_veg_lct_prep.R:40`, `scripts/1_veg_lct_prep.R:78`, `scripts/2_calibration_lct_bluesky.R:132`, `scripts/4_calibration_model.R:98`).

Consequently, a consistent median analysis rebuilds the modern calibration table, refits, and regenerates downstream results. Satellite extraction can be reused if locations are unchanged.

For medians, validate finite, nonnegative components and a positive sum before closure, `m / sum(m)`. All three component medians can be zero. The closed result is no longer the vector of marginal medians: document it as a different estimator, not an automatically superior summary.

**The posterior ensemble.** The assertion that calibration does not depend on land-cover draws is false for this implementation: its modern predictors come from that posterior. There are two distinct experiments:

| Calibration policy | Shared work | Work per land-cover draw |
|---|---|---|
| Fixed modern mean | Modern preparation, calibration and evaluation | Paleo preparation; prediction, differences, forcing and numerical aggregation |
| Matched modern draw | Static geography and satellite samples | Modern/paleo preparation, calibration-table join, refitting and downstream computation |

The first is useful **conditional propagation**: it omits uncertainty in the modern calibration covariates. The second propagates modern-cover variation too, but per-draw refitting does not automatically constitute a joint Bayesian analysis. Preserve paired modern/paleo samples where the upstream posterior supplies that dependence.

In script terms, the conditional mode repeats the numerical work in 6, 7a, 8 and 9, plus script 7’s coarse differences if retaining the recovered EGU comparison. Script 7 cannot simply be skipped today: it also creates ice products consumed by 8 and differences consumed by 9 (`scripts/7_plot_preds.R:76`, `scripts/7_plot_preds.R:412`, `scripts/8_radiative.R:38`, `scripts/9_forcing_barplot.R:325`). Separate these calculations from figures. Cache geometry, areas, ice fractions and sampled kernels for fixed grids/slices; produce representative and ensemble-summary figures.

There is another essential change: **the current downstream pipeline discards simulation identity**. Script 6 summarises simulations, and 7a uses their mean (`scripts/6_prediction_model.R:51`, `scripts/7a_alb_diff_full.R:126`). Moreover, `simulate()` generates conditional response noise, not coefficient uncertainty; this is already question A2. [Gratia’s simulation explanation](https://gavinsimpson.github.io/gratia/articles/posterior-simulation.html); `docs/cc/questions_for_andria_scientific.md:38`.

For a forcing distribution, carry sample identity through differencing, kernel multiplication and continental aggregation, then calculate intervals. Distinguish land-cover, coefficient and observation draws. Use the same monthly coefficient draw across cells and ages; independently drawing coefficients per row destroys the dependence needed for differences and totals. Confirm whether upstream `iter` identifiers represent joint spatial/temporal draws—matching numbers alone cannot establish this.

An explicitly land-cover-only specification could be:

```r
ensemble = list(
  draw_ids = "all",
  calibration = "fixed_mean",
  coefficient_draws = 0L,
  response_draws = 0L
)
```

Resolve `"all"` into recorded IDs. A driver prepares shared dependencies, calls the same functions for each member, checkpoints, verifies completeness and collects results. No copied scripts.

**Cost:** unchanged scripts 6–9, including 7a, would take roughly **430 hours, or 18 days serially**, for 200 members. Repeating the full calibration ladder adds **5,400 hours, about 225 days**. These extrapolate the reported timings, not benchmarks of an improved implementation (`README.md:128`). Benchmark fitting only the chosen model: mod7 dominates the ladder, and mod8 is redundantly fitted again (`scripts/4_calibration_model.R:234`).

At roughly 2,870 cells × 25 ages × 12 months × 200 land-cover draws × 100 response draws, there are approximately **17 billion values: 140 GB before compression and table overhead**. Existing long tables also repeat coordinates and covariates (`scripts/6_prediction_model.R:43`). Stream members, retain compact aggregate draws, and measure storage in a pilot.

Two hundred is the available sample count, not a precision guarantee. A reproducible subset of 20–50 complete draws is defensible for piloting; assess Monte Carlo error and stability of final means, spreads and tails before choosing the production count. Never subsample fractions independently.

## 5. Manifests

**Yes: one manifest per script invocation, plus a parent manifest for a pipeline/ensemble run.** Standalone scripts still need provenance.

The existing helper is a useful foundation, but has concrete gaps:

- `run_start()` persists nothing; an early failure leaves no manifest (`R/run_manifest.R:29`). Minute-resolution names collide during repeated executions (`R/run_manifest.R:48`).
- Input hashes are calculated at completion, so they need not describe the files actually read. Files above 2 GB are skipped; outputs receive no checksum (`R/run_manifest.R:25`, `R/run_manifest.R:83`, `R/run_manifest.R:86`).
- Dirty detection excludes a root configuration file, and a dirty flag cannot reconstruct edited code (`R/run_manifest.R:39`).
- Configuration capture is manually selected and flattened; 7a records only `alb_prod` (`R/run_manifest.R:78`, `scripts/7a_alb_diff_full.R:25`).
- `Filter(file.exists, ...)` hides missing declared inputs, while directory-wide output listings can claim stale files (`scripts/7_plot_preds.R:17`, `scripts/7_plot_preds.R:552`).

Persist a unique invocation record immediately, then transition through `started`, `completed`, `failed` or `interrupted`. Wrap execution in a function with error/finalisation handling; retain errors, logs and validated partial artifacts. Abrupt termination should leave an unfinished record, never implied success. Script 5’s known late failure is a real test case (`scripts/5_calibration_eval.R:218`).

Store a typed resolved configuration snapshot, its canonical hash, actual input/output hashes, producer references, code identity, package/system-library versions, RNG kind and seeds. Record notes separately. Hash settings before adding run-specific derived paths to avoid circular identity. A configuration hash alone does not identify code, data or stochastic execution.

Use unique run directories rather than appending a long hash to every filename. Write outputs atomically and register exactly what was produced. Retries get distinct attempt IDs; aggregation must detect missing members.

Keep readable Markdown, generated from structured JSON. Replace the singleton `.run` with explicit contexts before nesting pipeline and script records (`R/run_manifest.R:17`). Anchors should reference their historical configuration and provenance; manifests are evidence about execution, while anchors test behaviour.

## 6. Alternatives and pushback

**`targets` complements configuration and manifests.** It provides dependency-based rebuilding and branching, which become attractive for 200-member production ensembles. [Targets documentation](https://docs.ropensci.org/targets/); [dynamic branching](https://books.ropensci.org/targets/dynamic.html).

Do not make it a prerequisite for the initial refactor. First establish functions with explicit inputs and outputs; numbered scripts can remain wrappers Andria runs and edits. Then prefer `targets` over building an elaborate custom cache, scheduler and recovery system. Wrapping whole scripts without declaring their file dependencies will not solve the present coupling. Package development benefits from the same functions: package code should accept configuration arguments, not discover and source a repository-root file.

Reject **“no hard-coded values at all.”**

- Put genuine analysis choices in configuration: datasets, reduction, model selection, sensitivity parameters, ice policy, kernel selection, domain, aggregation and simulation settings.
- Keep model formulas in a readable, versioned R registry. Configure the model ID and deliberately exposed `k` values; record the expanded formula and effective values. Script 5 selects mod8; script 6 already consumes the selected artifact, so it needs no independent selection (`scripts/5_calibration_eval.R:28`, `scripts/6_prediction_model.R:24`).
- Keep ordinary plotting details, mathematical constants and unit-conversion implementation in shared code. Expose shared palettes/breaks only where comparison or user control warrants it.

Prefer semantic kernel settings over unexplained indices. The supplied documents disagree about CACK band 3: the manifest says 2003, README says 2002. Resolve this from dimension coordinates before attaching a year label (`scripts/8_radiative.R:36`, `README.md:180`). Configuration must not turn unresolved assumptions into apparent facts.

Also capture the micromamba environment and R dependencies; configuration plus manifests alone cannot recreate them.

## 7. Migration risks

Proceed in this order: **establish the current baseline → add configuration/validation and manifests → isolate paths and shared functions → optimise → introduce scientific modes**. Keep changes atomic on topic branches, rebasing over Andria’s review edits (`CONTRIBUTING.md:69`).

Specific checks matter:

- Month subsets currently risk wrong kernel bands because month numbers derive from positions in the selected vector (`scripts/8_radiative.R:81`). Fixed dimensions and coverage counts also assume twelve months and 25 ages (`scripts/4_calibration_model.R:116`, `scripts/7a_alb_diff_full.R:159`).
- Separate physical ages from display labels: script 7 actually changes 11,500 to 12,000 (`scripts/7_plot_preds.R:85`).
- Audit draw-name parsing before increasing counts (`scripts/6_prediction_model.R:46`), and the optional spatial script’s executable legacy tail before claiming support (`scripts/6_prediction_model_spatial_eval.R:326`).

Use byte comparisons where determinism is established, holding upstream inputs fixed. The anchor documentation explicitly excludes exact reproduction of unseeded prediction summaries and fitted model objects (`tests/anchors/interp-allmonths-2026-09-20/README.md:13`). Script 5’s simulation-derived statistics also require stochastic treatment despite the anchor table’s “yes” (`scripts/5_calibration_eval.R:116`). Check predictions and fit diagnostics, not merely rounded AIC.

Verify the elevation cache against the historical baseline; its addition postdates the anchor’s live-download caveat (`scripts/1_veg_lct_prep.R:58`, `tests/anchors/interp-allmonths-2026-09-20/README.md:9`). Introduce reproducible seeds separately from claims about historical byte identity. Preserve anchors unchanged, and record calibration-policy and draw-dependence decisions in the scientific questions document before implementing ensemble semantics.

---

# Appendix: the brief given to the reviewer

### Design review request: one configuration file for the paleo-RF pipeline

You are reviewing a design proposal for an R research pipeline. You have read-only
access to the repository in the working directory. Read what you need; cite files and
line numbers when you refer to code. Do not change anything.

### The project in one paragraph

Holocene radiative forcing from land-cover change in North America. Pollen-derived land
cover (three compositional fractions ET/ST/OL per 1-degree cell and time slice, delivered
as 200 posterior draws) is reduced to a per-cell mean (script 1), joined to modern
satellite blue-sky albedo (script 2), used to fit monthly beta-regression GAMs with
mgcv::bam (script 4, about 27 hours for the full model ladder), evaluated (script 5),
hindcast for 25 Holocene slices with 100 simulated draws (script 6), mapped (7, 7a),
multiplied by radiative kernels (8) and summarised (9). Scripts are numbered R files in
scripts/, run with Rscript in order. Read README.md, CONTRIBUTING.md and AGENTS.md first;
then R/run_manifest.R and the scripts. The PI (Andria) reviews and edits the scripts on
branch chris-dev; Chris (contractor) maintains the engineering.

### Current state of configuration

Everything is hard-coded in each script: input and output paths (every readRDS/saveRDS),
alb_prod = "bluesky" repeated in six scripts, months vector repeated, the slice list
ages = c(50, 200, seq(500, 11500, by=500)) repeated, nsim = 100 in the prediction,
N_iter = 20 in the spatial-eval script, ctrl = list(nthreads=8, maxit=500) repeated five
times in script 4, k values in the GAM formulas, the chosen model (mod8) hard-coded in
scripts 5 and 6, kernel band choices in script 8 (cack_band = 3), map window limits,
colour breaks, and so on. Two settings already come from environment variables:
DIAGNOSTIC (script 1, TRUE/FALSE) and RUN_NOTE (read by R/run_manifest.R). Scripts 7, 7a,
8 and 9 call run_start()/run_end() from R/run_manifest.R, which writes one markdown
manifest per run under runs/ with git commit, dirty-tree flag, package versions, BLAS
thread settings, input hashes and output list. Scripts 1 to 6 write no manifest.

There is a second "flavour" of the whole pipeline, the point-based (non-interpolated)
land cover, which was removed from the trunk on 2026-09-24 and preserved on tags and
branches. The two flavours differ in input files, cell counts (about 500 vs 2,870),
a few column names, and some plotting code.

Regression anchors (byte-identical expected outputs) exist under tests/anchors/ and are
used to verify that refactors do not change results.

### The proposal (Chris, 2026-10-07)

1. One configuration file for the whole project, at the repo root, holding every key
   setting and parameter value in one place: all file names and paths, the flavour
   switch (interp vs point), the posterior reduction (mean vs median of the 200 draws,
   with renormalisation for median), draw counts, model choice, GAM control settings,
   kernel choices, slice list, map window, and so on. Nothing hard-coded remains in the
   scripts. He asks what the R standard is for such a file: TOML? YAML? something else?
2. The config makes it easy to switch between interp/point and mean/median, and to run
   a third mode: the whole pipeline repeated for each of the 200 posterior land-cover
   draws, producing a distribution of final results instead of a single number.
3. Every script, every time it runs, writes a run manifest so that the outputs it
   produced can be matched to the exact settings used.

Chris intends, after this review, to ask a separate agent to design and plan the
migration. Your job now is the design review, not the plan.

### What I want from you

Work at full depth. Be direct; push back where the proposal is weak; prefer concrete
recommendations with short sketches over surveys. Structure your answer as markdown with
these sections:

1. **Verdict** in three sentences: is this a good design for this project, and what is
   the single biggest risk?
2. **Format and mechanism.** What R convention fits: a YAML file read with the `config`
   package (and its `default`/named-configuration inheritance), TOML, JSON, or a plain
   R file of assignments sourced by every script? Note which packages are installed:
   jsonlite is; config, yaml, RcppTOML, targets, renv and here are not (micromamba env,
   additions are possible). Recommend one and say why, including how Andria, an R
   user who edits scripts directly, will experience it.
3. **Structure of the configuration.** How should the config be organised so that
   (a) global settings, (b) per-script settings, (c) the flavour switches, and (d)
   per-run overrides (a note, a thread count, a diagnostic flag) coexist without a
   single 400-line file nobody can read? Address: one file vs a base file plus named
   profiles; whether environment-variable overrides should remain; and how paths
   should be derived from settings so that changing a flavour cannot leave an output
   from one flavour being read as an input by another (output naming/tagging).
4. **The three run modes.** Interp vs point: is a config switch realistic given the
   two flavours differ in code, not only in inputs, or should the point flavour stay
   retired? Mean vs median: what does this touch beyond script 1? The 200-draw ensemble:
   script 4's calibration does not depend on the land-cover draws (it uses the modern
   slice only) - or does it? - so which scripts actually have to repeat per draw, what
   is the compute and storage cost, and what is the right way to express "run the
   downstream half 200 times and collect" in config plus a driver, without copying
   scripts? Say whether 200 is the right number or whether a subsample is defensible.
5. **Manifests.** Critique the existing R/run_manifest.R against the goal "outputs
   easily matched to settings". Should every script write one; should there be one
   per pipeline run as well as per script; should the manifest embed the resolved
   config (and its hash) and name outputs with that hash or a run id; how should
   manifests, anchors and the config relate; what about runs that fail part way.
6. **Alternatives and pushback.** Is a workflow tool (`targets`) a better answer than
   config-plus-manifests, given Andria edits scripts by hand and the project is heading
   towards an R package? Is the "no hard-coded values at all" rule too strict - which
   values belong in config and which belong in code (plot colours? GAM formula? k)?
   Anything else you would do differently.
7. **Migration risks**, briefly, for the agent that will plan it: what can break, how to
   verify (the anchors), and the order to do it in.

Keep it under about 2,500 words. Cite files as path:line.
