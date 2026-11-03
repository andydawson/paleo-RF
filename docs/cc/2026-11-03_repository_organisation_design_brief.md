# Design request for Astra: how to organise the analyses and experiments in the paleo-RF repository

You are Astra, designing for Chris McWilliams, who maintains Andria Dawson's paleo-RF R code (a research pipeline for a
paper; Andria, the PI, must be able to read, run and maintain it after hand-over). Read-only: do not edit anything. Web
search allowed; ground recommendations in published guidance on organising research code and cite it with DOIs (for
example Noble 2009, PLoS Comput Biol; Wilson et al. 2017 "Good enough practices in scientific computing"; Marwick et
al. 2018 research compendia; the Turing Way; and anything better). Plain words. No time estimates.

## Chris's request
"I also want sensible ways of organising all of these scripts and experiments in the repo, so they are not just throw
away code and can be easily read, understood and maintained."

## What exists (this checkout: branch feature/single-config, the migration branch)
- `scripts/` 1-10: the pipeline, run in order, one config (`config.R`, `configs/legacy_config.R`), `R/` shared
  functions, `tests/` (unit tests and `tests/anchors/` regression anchors), `runs/` run manifests.
- `tools/`: a mix: one-off data preparation (prepare_bluesky_albedo.R, prepare_land_elevation.R,
  prepare_centre_elevation.R, download_era5_radiation.R, download_kernels.sh), verification and checking
  (verify_change.R, check_*.R, compare_tables.R, frozen.R, rscript.sh), an analysis tool (cross_validate_albedo.R on
  branch cv-design), Python helpers (methodology_schematic.py, nointerp_pipeline.py), restore_original_outputs.sh;
  `tools/plotting/` four diagnostic figure scripts.
- Coming: the cross-validation (stages holdouts, fit, score; branch cv-design), a northeast forest-albedo check (a
  stand-alone tool; branch northeast-benchmark), eight refit runs (sensitivity runs of the whole pipeline under
  different albedo settings, run through `tools/verify_change.R` specs in `docs/cc/verification/` with run folders
  outside the repository), diagnostic figures per run, possibly a model-structure sensitivity analysis later.
- `docs/cc/`: 82 files, dated and descriptive names (design briefs, reviews by Astra and Fable, decisions,
  reconciliations, logs), plus living documents (two question files for Andria, the migration changelog), a
  `verification/` folder with hundreds of specs and reports, `roles_draft/` (agent roles and skills).
- `archive/`: 18 retired scripts with a README.
- Rules already recorded: `AGENTS.md`, `CONTRIBUTING.md` (version control; topic branches; one-off data building in
  stand-alone tool scripts; no duplicated code: shared routines in `R/`; readability before elegance; simple and
  concise code; verification with tools/verify_change.R). Read them, and `README.md`.

## What to design
1. **Diagnosis**: what in the present layout makes analyses look like throw-away code or hard to follow (with
   examples), and what already works and should stay.
2. **A layout**, as simple as possible, for: the pipeline; one-off data preparation; analyses and experiments that sit
   beside the pipeline (cross-validation, the refit sensitivity runs, the northeast check, diagnostic figures); checks
   and verification tooling; and the documents (designs, reviews, decisions, logs, verification records) so that each
   experiment's question, design, decisions, code, how to run it, and results can be found together. Consider for each
   experiment a short README (question, how to run, inputs, outputs, status, links to its design and decisions) and an
   index of experiments; whether experiments get their own folders (code next to its documents) or stay split by type;
   where their outputs and figures go (the run folders are outside the repository); and how to keep `docs/cc/`
   navigable (an index; subfolders by topic; or leave dated names). Weigh each against the cost of moving files that
   many documents, specs, commit messages and GitHub issues already link to.
3. **Conventions** a newcomer can follow: naming, a standard header for every script (purpose, inputs, outputs, how to
   run, status), when something graduates from experiment into the pipeline or retires to `archive/`, and how tests
   and verification attach to an experiment.
4. **A migration plan** in small steps, each one a branch that can be verified (links updated, nothing in the pipeline
   changed), simplest first, and what to leave alone.

## Output
A markdown design for Chris: summary of at most ten lines; sections 1-4 with concrete folder trees and one worked
example (the cross-validation); what Chris must decide; references with DOIs.
