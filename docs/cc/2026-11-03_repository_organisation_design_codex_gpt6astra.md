*Astra (gpt-6-astra, ultra effort, web search), 3 November 2026, for Chris: how to organise the analyses and experiments in the repository. Brief: `2026-11-03_repository_organisation_design_brief.md`. Issue #28. Links relative to the repository root.*

# Design for Chris: organising analyses and experiments

- Give each experiment one stable README under `docs/cc/experiments/`.
- Keep existing code paths, numbered pipeline scripts, shared functions and verification records.
- Add an experiment index and a useful topic index for `docs/cc/`.
- Group tools by purpose in the repository README before considering file moves.
- Treat the eight refits as one study with eight scenarios and a record of its runs.
- Keep results outside the checkout, with explicit links between each result, configuration, code version and verification report.
- Introduce further folders only when a particular experiment needs them.
- This review was read-only; no files were changed.

## 1. Diagnosis

The main problem is **missing navigation around scientific questions**. Much of the code already has documentation, tests and review evidence, but Andria must reconstruct how those pieces belong together.

| Present arrangement | Consequence | Recommended response |
|---|---|---|
| `tools/` contains data preparation, scientific analyses, checking utilities and diagram generators. | Its directory listing does not explain which tools prepare inputs, answer questions or check software. | Add grouped tool tables to the existing repository README. |
| CV’s driver, functions, protocol, decisions, reviews and verification records occupy several directories on `cv-design`. | A newcomer cannot easily find the current instructions or distinguish an earlier proposal from the approved protocol. | Give CV one README that identifies its authoritative documents and links to the implementation. |
| The [README’s document index](README.md:379) lists only a few documents. | It does not expose the current collection of designs, reviews and decisions. Dates help locate known documents but do little to explain their relationship. | Add `docs/cc/README.md`, organised by topic and current work. |
| Refit decisions, operational logs, specs and results are distributed across documents, branches and external run folders. | Finding a plot does not immediately reveal its scenario, source run or accepted interpretation. | Add one refit landing page and link its existing run log and scenario records. |
| Work on another branch can appear indistinguishable from runnable work in this checkout. | Instructions may point to files that are absent. | State implementation location and status explicitly. CV is implemented on `cv-design`; `northeast-benchmark` currently contains designs, without its proposed tool. |

Several things already work and should stay:

- The numbered pipeline and README input/output tables explain execution order.
- `config.R`, `configs/legacy_config.R` and `R/` keep settings and shared routines identifiable.
- Verification specs, reports, regression anchors and run manifests provide substantial evidence.
- Stand-alone preparation scripts preserve how fixed inputs were built. Being run once does not make them disposable.
- The [diagnostic script headers](tools/plotting/plot_northeast_cover_and_location.R:1) already explain purpose, invocation, inputs, outputs and limitations.
- The [archive README](archive/README.md:3) records why scripts retired and whether they remain runnable. The old model-structure script is already there; a future sensitivity study should be described as new work.

The aim is for Andria to recover what was done and why without following the development conversation. That is the organising principle in Noble’s guidance on computational experiments. [Noble, 2009](https://doi.org/10.1371/journal.pcbi.1000424).

## 2. Recommended layout

**Organise the documentation by experiment, while retaining the established code locations.** This provides one starting point per question without paying the cost of moving already linked files.

The proposed additions fit the existing conventions:

```text
paleo-RF/
├── README.md                         # pipeline map; grouped tools; navigation
├── CONTRIBUTING.md
├── AGENTS.md
├── config.R
├── configs/
├── scripts/                          # existing numbered pipeline
├── R/                                # shared functions
├── tools/
│   ├── prepare_*.R                   # existing preparation paths
│   ├── download_*.R / *.sh
│   ├── cross_validate_albedo.R       # currently on cv-design
│   ├── verify_change.R
│   ├── check_*.R
│   ├── compare_tables.R
│   ├── frozen.R
│   ├── rscript.sh
│   ├── methodology_schematic.py
│   ├── nointerp_pipeline.py
│   ├── restore_original_outputs.sh
│   └── plotting/                     # existing diagnostic scripts
├── tests/                            # existing tests and anchors
├── data/                             # existing paths retained
├── output/                           # existing paths retained
├── runs/                             # existing manifest convention
├── docs/cc/
│   ├── README.md                     # NEW: topic index
│   ├── experiments/
│   │   ├── README.md                 # NEW: experiment index
│   │   ├── cross-validation/
│   │   │   └── README.md
│   │   ├── refit-sensitivity/
│   │   │   └── README.md
│   │   └── northeast-benchmark/
│   │       └── README.md
│   ├── verification/                 # existing specs/reports stay
│   ├── questions_for_andria_general.md
│   ├── questions_for_andria_scientific.md
│   ├── changelog_single_config_migration.md
│   ├── roles_draft/
│   └── existing dated documents and review folders
└── archive/                          # unchanged
```

New experiment-specific designs, decisions and reviews can go beside that experiment’s README, using dated descriptive names. Create those files when needed; an experiment does not require a complete set of empty document folders.

This follows the research-compendium principle of recognisable conventions and explicit relationships between data, methods and outputs. It does not require conversion into an R package. [Marwick, Boettiger and Mullen, 2018](https://doi.org/10.1080/00031305.2017.1375986).

### Why retain the split between code and documents?

| Option | Benefit | Cost here | Recommendation |
|---|---|---|---|
| Experiment README in `docs/cc/experiments/`, linking existing code | One starting point; existing commands and links survive | Readers follow links between directories | **Use now.** |
| Code and README together under `tools/analyses/<experiment>/` | Convenient when an experiment has several private scripts | Changes callers, tests and links; living README edits also trigger the current code-verification gate | Consider selectively if a study grows. |
| New top-level `analyses/` containing code and documents | Clear physical grouping | Requires convention changes, verification coverage changes and a larger migration | Leave for a demonstrated need. |

There are concrete tooling reasons for this choice. The [merge checker](tools/check_merge_evidence.R:26) compares whole directory trees, including `tools/`. Consequently, editing a README there counts as a code change. Conversely, a new `analyses/` root would fall outside its current coverage. Verification reports are also discovered specifically under `docs/cc/verification/`.

Physical colocation is therefore a tradeoff, not a prerequisite for maintainability. A short README linking the relevant components is consistent with the Turing Way’s basic-compendium guidance. [The Turing Way: Research Compendia](https://book.the-turing-way.org/reproducible-research/compendia/).

### Where each kind of work belongs

| Work | Code and records |
|---|---|
| Main pipeline | Existing `scripts/`, `config.R`, `configs/` and `R/`. |
| Fixed-input preparation | Existing `tools/prepare_*` and download scripts. Their headers and README entries identify source data, prerequisites, products and provenance. |
| Cross-validation | Existing driver in `tools/`, shared functions in `R/`, tests in `tests/`; experiment README links them. |
| Eight refits | One experiment page with an eight-row scenario table. Existing pipeline code and verification specs perform the runs. No copied pipeline scripts. |
| Northeast forest-albedo check | Its experiment page initially says “design only”. Link the eventual stand-alone tool after implementation. Distinguish it from the existing northeast diagnostic plot. |
| Diagnostic figures | Keep `tools/plotting/`. Relevant experiments link the plots they use; a shared guide in the experiment index explains running them against a particular run. |
| Possible model-structure sensitivity | List as proposed work until there is an agreed question and design. Create its folder when that work starts. |
| Checks, verification and recovery | Keep existing tool paths, tests, anchors and verification records. |

### Making `docs/cc/` navigable

Use `docs/cc/README.md` as a short topic index: current experiments; configuration migration; input preparation; scientific decisions; open questions; verification; historical work; agent-role drafts.

For each topic, link the **current authority first**, followed by supporting designs and reviews. Identify superseded proposals in the index without rewriting their historical contents. Existing review folders with a README, such as `2026-10-30_refit_code_review/`, are a useful pattern.

Keep the two question files and migration changelog at their canonical locations. Experiment pages should link relevant questions and decisions rather than maintain competing copies.

Keep old dated documents and verification records where they are. Git history does not repair links in GitHub issues, commit messages or previously shared documents. If a document eventually moves, leave a short pointer at the old path and update current navigation. Executable moves need a separate, verified change.

### Outputs and figures

An experiment is the continuing question; a run is a particular execution. Give each run or attempt a distinct identifier and retain its actual location.

Each experiment README should contain, or link to an existing log containing:

| Run ID | Scenario/source run | Code and configuration | Evidence | Result location and status |
|---|---|---|---|---|
| Stable name | Settings or comparison represented | Exact commit; config/spec | Spec and report; manifests or stage records | External location; completed, failed or superseded |

Use the existing refit log instead of creating a second competing run register.

Keep bulk outputs in their existing run folders. Shared diagnostic scripts already support:

```text
Rscript tools/plotting/plot_training_support.R --config <run-dir>/config_used.R
```

Their figures belong to that run’s `figures/diagnostics/`. CV currently writes its PDF inside `output/cross_validation/`; retain that working convention.

Commit a short interpretation and links to the selected results. Continue the existing policy for deliberately retaining official provenance records; do not start committing every generated manifest or fitted object.

A verification worktree is also a storage location: removing it can remove its `.rundirs/` results. Before cleanup, preserve required runs in durable storage and update their recorded locations.

### Worked example: cross-validation

Proposed landing page:

```text
docs/cc/experiments/cross-validation/
└── README.md
```

Its initial content should be approximately:

> **Question:** Which candidate albedo model predicts relevant withheld modern cover mixtures best, and what changes when it is used in the hindcast?  
> **Status:** Implemented on `cv-design`; holdout preparation has verification evidence. Fitted scores and conclusions must be recorded separately when available.  
> **Read first:** The current CV protocol and amendments, then the decisions document. Earlier proposals are background.  
> **Code:** Driver, shared CV functions and model registry.  
> **Inputs:** A named source run, its saved configuration and products from scripts 1, 2 and 7a.  
> **Run:** The three existing stages below, following the protocol’s review points.  
> **Outputs:** The source run’s `output/cross_validation/`; link the named attempt and important tables.  
> **Checks:** Existing unit tests and the relevant verification spec/report pairs, with their coverage stated.  
> **Result:** Pending until scoring and interpretation are complete.

The linked files already exist on `cv-design`:

```text
tools/cross_validate_albedo.R
R/cross_validation.R
R/model_registry.R
tests/test_cross_validation.R
docs/cc/2026-11-02_cv_protocol.md
docs/cc/2026-11-02_cv_design_decisions.md
docs/cc/2026-11-02_cv_code_review/
docs/cc/verification/<specific CV spec and report>
```

Until those files reach the reader’s branch, identify their branch explicitly rather than creating broken relative links. Published run records should identify exact commits.

The existing interface, run from the relevant checkout’s repository root, is:

```text
Rscript tools/cross_validate_albedo.R holdouts <run-dir>
Rscript tools/cross_validate_albedo.R fit <run-dir> <holdout> <month> [<month> ...]
Rscript tools/cross_validate_albedo.R score <run-dir>
```

These are command forms: substitute the actual directory, holdout and months. Obtain eligible combinations from the holdout outputs and protocol. Preserve the existing requirement to bring feasibility and holdout diagnostics to Chris before fitting.

The page should require a recorded `config_used.R` for a reproducible run, while explaining that the current implementation falls back to repository `config.R` when it is absent.

An abbreviated view of the existing output arrangement is:

```text
<external run directory>/
├── config_used.R
├── data/                             # products from scripts 1, 2 and 7a
├── output/cross_validation/
│   ├── holdouts.rds
│   ├── directions.csv
│   ├── feasibility.csv
│   ├── directions.pdf
│   ├── predictions_<holdout>_<month>.rds
│   ├── scores.csv
│   ├── scores_by_month.csv
│   └── record_<stage>.txt
└── runs/                             # pipeline manifests
```

CV stage records and pipeline manifests are different records; document both accurately.

Existing holdout verification invokes CV through the spec’s `checks` entries. Preserve that pattern: `verify_change.R`’s `scripts` entries expect a different invocation and pipeline-style manifests. Historical specs are evidence, not necessarily portable launch instructions: they can contain machine-specific paths and already-used run names.

One provenance limitation deserves a separate follow-up: [the current dirty-code check](R/run_manifest.R:278) watches pipeline code and configuration but excludes `tools/`; CV uses that helper. Until addressed, recorded scientific runs should come from clean, committed checkouts, and their documentation should not claim that every edited tool is detected.

## 3. Conventions a newcomer can follow

### Names and script headers

Use stable question names for experiment folders: `cross-validation`, `refit-sensitivity`, `northeast-benchmark`. Use descriptive action names for scripts, retaining the repository’s existing underscore convention. Keep dates on records, not on the continuing experiment’s identity.

Retain numbered names for the established pipeline. Number new scripts only when their order matters.

Every executable script should open with a compact header:

```r
# Purpose: The question answered or product built, and why it is needed.
# Inputs: Required files/source run and how they are obtained.
# Outputs: Files written and the directory receiving them.
# Run: Exact invocation, from the repository root.
# Status: Pipeline / maintained analysis / input preparation / diagnostic / retired.
# Details: Experiment README or authoritative design; important limitations.
```

Include unusual dependencies or network requirements where relevant. Keep changing scientific conclusions and run status in the experiment README rather than repeatedly editing code headers.

This applies Wilson et al.’s recommendations for opening explanations, explicit dependencies, meaningful names and eliminating duplicated code. [Wilson et al., 2017](https://doi.org/10.1371/journal.pcbi.1005510).

### Maintaining an experiment

A short README needs only the question, status, instructions, inputs, outputs, decisions, verification and result links. Add a separate results document or log when those sections become unwieldy.

Every scientific choice should point to its approved rationale and literature precedent. The organisation proposed here does not validate CV scoring, holdouts or sensitivity settings; their existing scientific review requirements remain.

Keep functions used by multiple scripts in `R/`. Avoid copying preparation, fitting or plotting routines into experiment folders.

### Completion, promotion and retirement

A completed experiment can remain a maintained analysis beside the pipeline indefinitely.

Promote functionality into the pipeline when it becomes an agreed part of the paper’s standard analysis, with reviewed settings, dependencies, tests and verification. Reuse the relevant functions and preserve the experiment’s evidence and decision history.

Retire code to `archive/` when it is superseded or no longer maintained and has no active callers. Record why, its replacement, its last usable version and any missing dependencies. Keep the experiment’s landing page so its scientific conclusions remain findable.

### Tests and verification

Link each experiment to its existing focused tests under `tests/` and its specs/reports under `docs/cc/verification/`. Add tests for meaningful failure modes and scientific contracts as implementation requires.

For every code change, retain verification through `tools/verify_change.R` at the exact committed code. Use anchors where they are relevant. A software PASS should state what was checked; scientific conclusions still require the agreed review.

## 4. Migration in small, verifiable branches

Use the recorded migration-branch arrangements while `feature/single-config` remains the integration branch; after integration, use topic branches from `chris-dev`. Do not silently change the integration target or switch a checkout being read by a run.

Each branch should have atomic, why-focused commits, its required checks, a merge into the appropriate development branch, and pushes at checkpoints and completion.

| Branch | Change | Verification before merge |
|---|---|---|
| `docs-repo-navigation` | Add `docs/cc/README.md`; improve root README navigation and group existing tools by purpose. | Check links and commands against tracked files. Confirm no executable, configuration, input or anchor changes. |
| `docs-cross-validation-home` | Add the experiment index and CV README, linking existing protocol, decisions, code and evidence. | Check branch-specific availability, the actual CLI and claimed verification coverage. Confirm historical files are unchanged. |
| `docs-refit-and-benchmark-homes` | Add refit and northeast pages; link the existing run log, eight scenarios, designs and diagnostics. | Trace each recorded result to its source run/spec/report. Mark absent implementations and pending results explicitly. |
| `docs-analysis-conventions` | Record the README/header conventions and responsibilities in existing contributor guidance. | Check consistency with `AGENTS.md`, version-control rules and the chosen layout. |
| `headers-analysis-tools` | Fill genuine header gaps in maintained tools, without changing their calculations or interfaces. | Use `verify_change.R` with appropriate parsing/comment-only comparisons and targeted existing checks; obtain the required change review. |

The first four branches change documentation only. They do not require running the scientific pipeline.

Make any later code move a separate branch for one experiment. Update live callers, tests, source paths and current instructions; preserve historical reports; audit merge-gate and provenance coverage; verify executable behaviour and affected outputs. Move a working analysis only when the benefit exceeds those costs.

Leave the pipeline order, data paths, model registry, configuration schema, anchors, verification-tool location, historical reports, existing plotting directory and archive alone. No new workflow engine, package conversion or general experiment framework is needed for this design.

## What Chris must decide

1. **Accept the linked layout?** I recommend experiment READMEs under `docs/cc/experiments/`, with existing code paths retained.
2. **Where should the first branches integrate?** Use the ongoing migration arrangement or wait for its integration into `chris-dev`; record that choice.
3. **Where will retained external results live after handover?** Choose storage Andria can access and a preservation rule before worktree cleanup.
4. **Who maintains experiment status and result links?** Recommend that whoever changes an analysis or accepts a run updates its page in the same task.
5. **Schedule the separate tool-provenance fix?** The existing omission of `tools/` from dirty-code detection merits a small, verified follow-up.

## References

The exact folders and migration sequence above are design judgments for this repository. The following sources support their underlying principles.

1. **Noble, W. S. (2009).** A Quick Guide to Organizing Computational Biology Projects. *PLoS Computational Biology*, **5**(7), e1000424. DOI: [10.1371/journal.pcbi.1000424](https://doi.org/10.1371/journal.pcbi.1000424). Relevant sections: “Principles”, “File and Directory Organization” and “Carrying Out a Single Experiment”—recoverable purpose, experiment records and commands.

2. **Wilson, G., Bryan, J., Cranston, K., Kitzes, J., Nederbragt, L., and Teal, T. K. (2017).** Good enough practices in scientific computing. *PLoS Computational Biology*, **13**(6), e1005510. DOI: [10.1371/journal.pcbi.1005510](https://doi.org/10.1371/journal.pcbi.1005510). Relevant sections: Software, Collaboration and Project organization—readable scripts, README guidance, consistent structure and small changes.

3. **Marwick, B., Boettiger, C., and Mullen, L. (2018).** Packaging Data Analytical Work Reproducibly Using R (and Friends). *The American Statistician*, **72**(1), 80–88. DOI: [10.1080/00031305.2017.1375986](https://doi.org/10.1080/00031305.2017.1375986). Relevant sections: §2’s three compendium principles and §4’s guidance on appropriate complexity.

4. **The Turing Way Community.** *The Turing Way: A handbook for reproducible, ethical and collaborative research*. Continuing handbook DOI: [10.5281/zenodo.3233853](https://doi.org/10.5281/zenodo.3233853). Relevant live chapter: [Research Compendia](https://book.the-turing-way.org/reproducible-research/compendia/), especially “Basic Compendium” and “Separating Methods, Data, Output”.

Publisher/full-text identities and supporting passages were checked. The installed automated reference-checker workflows write files, so they were not run in this read-only session.