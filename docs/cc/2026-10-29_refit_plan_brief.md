# Refit on the rebuilt albedo: the brief given to Astra (29 October 2026)

Written by Claude Code for Chris. **Error in this brief:** it gives the snow plan as the two runs of
16 October; Chris replaced that on 19 October with snowy and snow-free calibrations mixed by snow
share. Fable's review found it; see 2026-10-29_refit_plan_decisions.md. `$S` below is the
session's scratch folder.

---

You are Astra, planning one step of a research code project for Chris McWilliams (contractor) and
Andria Dawson (the PI). Planning only: read whatever you need, change nothing. Use web search to
check that each method you propose follows published practice; cite with DOI.

# The project in brief
paleo-RF estimates the Holocene radiative forcing from North American land-cover change. Pollen-based
land-cover fractions (open land OL, evergreen ET, summer-green/deciduous ST) per 1-degree grid cell and
time slice are related to today's satellite albedo by a monthly calibration GAM fitted on the modern
cells (mgcv; prediction model "mod8", REML); the fitted model then predicts each past slice's albedo,
and albedo changes times radiative kernels give the forcing. The pipeline is R scripts 1-10 under
scripts/, helpers in R/, one configuration file config.R (configs/legacy_config.R reproduces the
original analysis), run records and manifests per run.

# The step to plan: the refit on the rebuilt satellite albedo
Until now the calibration albedo came from Andria's raster data/blue_sky_monthly_2000-2009.tif (12
monthly layers; undocumented provenance; it mixes water into coastal and lake cells; taken at the cell
centre). It has been replaced by our own build from NASA's MODIS MCD43A3/A2 v6.1 (2000-2009) with an
ERA5 diffuse fraction, land pixels only. The build is finished and merged:
- Tool: tools/prepare_bluesky_albedo.R (read its header: every processing choice and its source).
- Its cell table: the official file data/albedo_modis_cells.csv is being written right now by the
  tool's "cells" step in the main checkout (/home/expert/Documents/contracting/Andria/paleo-RF). An
  identical table from the same code is already at /tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wintergap/full_build_cells.csv: per cell (x, y
  = cell centre) and month, for each version (full_75 = main: full BRDF inversions, noon solar zenith
  <= 75 degrees; any_75 = any processed retrieval; full_70; full_nocut = no sun-angle rule) the
  all-days albedo, snowy / snow-free / unknown-snow means and shares, years with data, coverage and
  days. 2,866 cells; the calibration table has 2,860.

Decisions already made by Chris (do not reopen; plan within them):
- Main albedo: full_75, land pixels only (class land on > half the days), shoreline pixels not land,
  no minimum coverage (counts kept), mean over the cell's land pixel-days within each year then years
  weighted equally, noon blue-sky albedo.
- Sensitivities: any_75 (all processed retrievals); and (29 October) for the northern winter gap:
  keep full_75 as main and also fit November to February with full_nocut to show whether the forcing
  depends on the sun-angle rule. Numbers: /tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wintergap/full_build_winter.out.
- Snow (16 October): two runs, calibrated on the all-days albedo and on the snow-free albedo; the
  snow-shift test is parked.
- Elevation: GMTED2010 land mean (config elevation$method = "land_mean", merged). Coastal cells keep
  whole-cell weight (22 October).
- The original configuration (configs/legacy_config.R) must keep reproducing its anchors exactly
  (tests/anchors/): the new albedo is a configuration choice, the original raster stays available.
- Model 7 did not converge in 7 of 12 months in the 18-19 October runs (500-step limit); its check
  with a 2000-step limit moves to this refit, run with OPENBLAS_NUM_THREADS=1 (R's OpenBLAS otherwise
  starts 48 threads per process on this shared 48-core, 125 GB machine; keep R jobs well under 60 GB).

# Where to read
- Code: this worktree, branch feature/single-config (the migration branch; the albedo tool is merged
  here). Scripts 1-10, R/, config.R, R/config_schema.R, configs/legacy_config.R, tests/.
- Project rules: AGENTS.md, CONTRIBUTING.md, docs/cc/verification/README.md (tools/verify_change.R
  is the only verification route; tools/check_merge_evidence.R enforces a PASS report on merges).
- Change log of the migration: docs/cc/changelog_single_config_migration.md.
- Albedo design and reviews: docs/cc/2026-10-15_albedo_rebuild_* , 2026-10-15_published_albedo_methods_*,
  2026-10-15_snow_and_water_masking_codex_gpt6astra.md, 2026-10-16_snow_free_estimate_literature_fable.md.
- Open questions for Andria and recorded decisions: docs/cc/questions_for_andria_scientific_from_2026-10-20.md
  (section 3: the albedo; section 1: the northeast hemlock result; section 4: model 7) and
  docs/cc/questions_for_andria_scientific.md.
- Chris's working to-do list (long, informal, the most complete record of decisions):
  /tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/waiting_on_chris.md
- Latest full runs to compare against: /home/expert/Documents/contracting/Andria/paleo-RF-verify/4ba4d2a/.rundirs/full-current-2026-10-18
  and .../full-icecaps-kept-2026-10-19, and the headline runs .../44d6a06/.rundirs/headline-partial-ice-2.
- Diagnostic figures that must be redrawn after the refit: tools/plotting/ (e.g.
  plot_northeast_cover_and_location.R, plot_training_support.R, plot_pollen_site_coverage.R).

Context for why the refit matters: in the northeast (80-66 W, 40-48 N) the model predicts a darker
surface where hemlock collapsed 6-4.5 ka (a warming), opposite to expectation. The 6 ka cover mix lies
outside today's training range (low open land), and evergreen share and latitude are almost perfectly
correlated there today (r = 0.92), so the fit cannot separate them. Whether the land-only albedo
changes this is one of the things the refit should show.

# What to deliver
A plan Chris can approve, written for a careful reader who is not a programmer at heart. Plain words,
no private shorthand or ids without explanation, no time estimates (measured runtimes are fine).
Readability before elegance: the simplest explicit code Andria can read; no duplicated code (shared
routines go in R/); no speculative generality. Before any design, one sentence on its benefit to the
paper or to Andria's use of the code. Cover:
1. The code change: exactly which files and functions change, the new configuration options (names,
   allowed values, defaults for config.R and for configs/legacy_config.R), how script 2 builds the
   calibration table from the cell table (columns, units, joins on cell centres, the 2,866 vs 2,860
   cells, cells missing a month, the existing ice mask, the zero-albedo floor, the native/coarse
   figures that no longer apply), and what the run record and manifest must say about the albedo
   source. Point to the lines you read.
2. The snow runs (all-days vs snow-free) and the sensitivities (any_75; full_nocut for November to
   February): how each is expressed as configuration, and which scripts each must run.
3. The model 7 convergence check at 2000 steps, one thread.
4. Verification: specs for tools/verify_change.R (legacy anchors unchanged; tests for the new reading
   code; the runs themselves), and a check of every input and setting shown to Chris before launching.
5. Review: by the project's rule this touches the scientific options, so independent reviews by
   Fable (Claude science-reviewer) and Astra, then one reconciliation. Say what each reviewer gets.
6. The runs: order, parallelism (cores, threads, memory), what each produces, and the comparisons to
   report (forcing by period and month against the 18-19 October runs, the northeast, training support).
7. Every decision Chris still has to make, each with your recommendation and its reason, and the
   questions that belong to Andria instead.
8. Risks and how each is caught.
Be concrete and complete; do not pad.
