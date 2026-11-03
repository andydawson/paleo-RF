# Review: what the scripts outside the pipeline hold, and what deleting them would lose

You are Astra, reviewing for Chris McWilliams, who maintains Andria Dawson's paleo-RF R code. Read-only: do not edit files. Work in plain words; no private shorthand or question ids.

## The project, briefly
paleo-RF estimates the radiative forcing from Holocene land-cover change in North America. The pipeline (scripts 1-10 in `scripts/`, run in order, settings in `config.R`) takes pollen-based land-cover fractions (open land OL, evergreen ET, summergreen ST, REVEALS reconstructions on a 1-degree grid, 50 years to 12 ka); fits GAMs (mgcv) of modern MODIS blue-sky albedo on land cover, elevation and location; predicts past albedo; differences it between time slices, accounting for ice sheets; and converts the albedo change to forcing with radiative kernels (HadGEM3, CAM5, CACK). `docs/cc/changelog_single_config_migration.md` describes the current code; `docs/cc/questions_for_andria_scientific.md` and `docs/cc/questions_for_andria_scientific_from_2026-10-20.md` give the open scientific questions (snow treatment among them: the team is considering snow-free albedo and mixing snowy and snow-free albedo using a snow-cover product such as MODIS MOD10CM).

## The scripts in question (this checkout, branch feature/single-config)
Not run by the pipeline; nothing in the pipeline reads their outputs:
- `scripts/archive/` (14 scripts: modern pollen, snow probability, Thornthwaite water budget, ClimateNA runs, climate merges and plots, pollen through time, an old prediction plot);
- `scripts/GCM_snow_prob.R` and `scripts/thornthwaite.R` (a snow and water-budget branch Andria dropped; unchanged since May 2022);
- `scripts/beta_veg_lct_modern.R` (an early modern-pollen / land-cover script, April 2022);
- `scripts/6_prediction_model_spatial_eval.R` (a model-structure sensitivity check of the prediction model; at present it cannot run: it needs SemiPar and pwiser, uses an undefined variable near line 278, and from about line 326 reads files that no longer exist).
`scripts/make_grid.R` is sourced by script 3 and is NOT in question. Use `git log` on these files for their history if useful; the `legacy` branch holds the original code.

## Chris's questions
1. Are there any methods or ideas in these scripts that might be useful to the project now: to the paper's method, to its open questions (snow above all), or as a sensitivity analysis or check? For each, say what the script does, whether the idea is sound and grounded in published practice (cite the papers; web search is allowed), what it would take to use, and how much it would add. Be concrete and sceptical: an idea is useful only if it answers a question the project has or should have.
2. Are we losing anything by deleting them, given that every version stays in git history and on the `legacy` branch? Consider data products or inputs they document (sources, URLs, processing choices) that are recorded nowhere else in the current code or docs, and anything Andria's earlier results depended on.
3. Chris's preference is to archive rather than delete. Recommend a simple way to archive (for example one `archive/` folder outside `scripts/` with a short README saying what each script was and why it is not run), and whether any script should instead stay or be rebuilt. Keep it simple: no bloat.

## Output
A markdown report for Chris:
- a summary of at most ten lines answering the three questions;
- one section per script (or per group of closely related archive scripts): what it does, inputs and outputs, ideas worth keeping (with references), what deletion would lose, and your recommendation (archive / keep / rebuild), each with file and line references;
- a list of anything that should be written into the current docs before archiving (for example a data source recorded only in an old script);
- references, with DOIs where you can find them.
