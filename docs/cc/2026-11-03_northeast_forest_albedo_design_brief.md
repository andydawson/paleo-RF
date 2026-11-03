# Design request for Astra: an independent local check of conifer versus deciduous albedo in the northeast

You are Astra, designing for Chris McWilliams, who maintains Andria Dawson's paleo-RF R code. Read-only: do not edit
files and do not download anything. Web search is allowed; ground every method in published practice and cite it
(with DOIs); say plainly where a step is our own adaptation. Plain words. Do not open or print anything under
`data/modis_albedo/requests/` (it holds account request files).

## Why
Your review of today (`docs/cc/2026-11-03_cv_northeast_question_codex_gpt6astra.md` in this checkout) found that the
cross-validation can choose a better modern-transfer model but cannot establish the sign of the albedo effect of the
hemlock decline at fixed northeastern locations (evergreen 0.40 to 0.22, summergreen 0.54 to 0.73, open land about
0.05, 6 to 4.5 ka; box 80-66 W, 40-48 N), because in today's 1-degree data evergreen share follows latitude
(r = 0.92). You ranked first "an independent local forest-albedo contrast ... matched by month and snow". Chris
approved planning it (design only, for his approval). Benefit to the paper: direct evidence on the sign and size of the
evergreen-to-summergreen albedo effect in the region the paper highlights, independent of the 1-degree model.

## What exists
- The rebuilt MODIS albedo: monthly blue-sky albedo 2000-2009 at the native 500 m sinusoidal grid,
  `data/modis_albedo/monthly/` (180 GB), made by `tools/prepare_bluesky_albedo.R` (its header gives every choice:
  MCD43A3/A2 collection 6.1, noon solar zenith cut-off, land rule, the snow flag; all-days, snow-free and snowy day
  totals are kept). Inspect the folder's structure and one file's layers (read-only) to say what is usable.
- The pollen-based cover: three classes (open land OL, evergreen ET, summergreen ST) on the 1-degree grid
  (`data/lct_paleo_reveals_interp.RDS` in `/home/expert/Documents/contracting/Andria/paleo-RF`), Dawson et al. (2025).
- The water mask (MOD44W, `data/mod44w/`), elevation (GMTED2010, `data/gmted2010/`).
- No fine-resolution forest-type map is on disk yet as far as we know; check.

## What to design
1. **The comparison**: the quantity to estimate (albedo difference, evergreen-needleleaf versus deciduous-broadleaf
   forest, per month, with snow state separated), and how to make it local so that latitude and climate cannot stand in
   for cover: for example within-window contrasts (moving windows; the "space-for-time" local-contrast approach of
   Duveiller et al. 2018, Nature Communications, and similar work such as Lejeune et al. 2020, Bright et al. 2017 -
   check each), matching on elevation, latitude, snow, and canopy closure.
2. **Data**: which forest-type map to use for the forest class of each 500 m pixel (for example MCD12Q1, NLCD and its
   tree-canopy layer, the Canadian national forest-type products, USFS forest-type groups), with resolution, years,
   accuracy for hemlock and for mixed stands, licence, size and how to obtain it; and whether the existing 500 m
   albedo suffices or something more is needed. Prefer what is already on disk; anything to download needs Chris's yes,
   so list it with its size.
3. **How it maps onto the model**: how a local evergreen-versus-deciduous albedo difference would be compared with the
   fitted model's evergreen-to-summergreen effect (the pollen classes are not satellite classes: say how "evergreen"
   and "summergreen" in the reconstruction relate to the map's classes, and what the mismatch does), and how the result
   would be used: as a check reported beside the forcing, not as a constraint on the model (unless Chris later decides
   otherwise).
4. **Pitfalls**: mixed pixels at 500 m, edge effects, topography, snow masking by canopy, the solar-zenith cut-off in
   winter, the years 2000-2009 against the map's year, forest age and disturbance, wetlands and water.
5. **Effort**: the steps, in order, each with its main risk; keep it simple, one stand-alone tool script in
   `tools/` (the project's rule for one-off data work), small enough for Andria to read.

## Output
A markdown design for Chris: a summary of at most ten lines (what it would show, what it needs, what it costs, your
recommendation); then sections 1-5 above; then what Chris must decide (for example the map and any download);
references with DOIs.
