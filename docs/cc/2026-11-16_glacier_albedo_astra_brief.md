# Brief for Astra (ultra effort): glacier albedo values for the deglacial ice sheets, with sources

*Chris McWilliams, 16 November 2026. Literature search and recommendation; read-only.*

## Why
The glacier albedo sets the albedo of every ice-covered cell, so it dominates the forcing from 12 to 8 ka. The
values in use cannot be sourced. Andria (written answer, 12 November): revisit them; she remembers using papers for
reasonable values and a seasonal cycle but not which; she named Gandy et al. 2023 and Bradley et al. 2024
(Climate of the Past 20, 211-235, doi:10.5194/cp-20-211-2024); she wants values supported by the literature, a
seasonal cycle (perhaps from ice-sheet or palaeoclimate simulations rather than built by us), and sensitivity
analyses. Chris's note: "Solid refs and sensitivity."

## What is in the pipeline now
`data/albedo_glacier_monthly.csv` (worktree `/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice`): monthly
columns `ice_albedo` (0.6 to 0.8; maps only), `ice_albedo_fixed` (0.68 in every month; the headline), and
`ice_albedo_sc` ("scaled", 0.56 to 0.80; a sensitivity). The cell albedo is f x glacier albedo + (1 - f) x vegetation
albedo; the vegetation albedo is monthly mean blue-sky shortwave albedo from MODIS (2000-2009) predicted by the model;
forcing uses top-of-atmosphere all-sky kernels. Measured sensitivity (threshold variant, HadGEM3 all-sky, study-area
mean, W/m2): 8-10 ka 2.50 / 3.83 / 4.90 / 6.51 for glacier albedo 0.50 / 0.60 / 0.68 / 0.80. See
`docs/cc/questions_for_andria_scientific.md`, section C0a.

## What to find
1. What monthly broadband surface albedo the North American ice sheets' surface had through the year during
   deglaciation, as the literature gives it: observations of present ice sheets (for example Greenland's
   ablation and accumulation zones by month), simulations of the Laurentide and other North American ice
   (Bradley et al. 2024; Gandy et al. 2023, find the exact paper; others), and what earlier studies of
   deglacial or Holocene albedo forcing assumed for ice. Each value page-located, with the kind of albedo
   (white-, black- or blue-sky; broadband or not), the zone and the months.
2. Whether the current columns match any published source.
3. A recommendation: a seasonal cycle for the headline (or a reason to keep a fixed value), and a range for the
   sensitivity analysis, each with its sources; how the choice interacts with the ice fraction (a cell part-covered
   by ice) and with the kernels. Keep it to what the pipeline can use: twelve monthly values, perhaps two or three
   alternatives.
## Rules
- Read-only: change no file, commit nothing, download no data file (reading web pages and papers is fine). R may not start in your sandbox; Python is available.
- Plain words, no private ids. Verdict or summary first, then the details. Findings with evidence: page-located quotes or numbers for every value taken from a paper, with DOI.
- Simplicity is a requirement (Chris): as simple, clear and parsimonious as possible; no overengineering.
- Published precedent from this field (albedo and land cover, ice sheets and their albedo, vegetation albedo forcing, palaeo-vegetation) for every method choice, or say it is a project choice.
- The repository is public. Never open `data/modis_albedo/requests/`.
- End with questions for Chris, only where the choice is his or Andria's, each answerable without reading anything else.
