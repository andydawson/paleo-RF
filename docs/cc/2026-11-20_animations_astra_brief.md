# Brief for Astra (ultra effort): animations of the Holocene ice, vegetation and albedo changes

*Chris McWilliams, 20 November 2026. Design, then a prototype build; iterative: Chris will choose from what you show.*

## Access (read this first)
Your working directory is the worktree `/home/expert/Documents/contracting/Andria/paleo-RF-wt/animations` (branch
`animations`, made from `feature/single-config` at 9c8dea1). You may create and edit files **only inside this
worktree**, and only new files: one script under `tools/` and outputs under `animations/` (create it; it stays out of
git). Do not edit anything under `R/`, `scripts/`, `tests/`, `config.R` or `configs/`: the pipeline is under its final
verification. Read anything you need with read-only shell commands, including the two folders named under Data.
Run R only as `CORES=32-47 THREADS=2 tools/rscript.sh <file.R>` (or `-e`), from the worktree: the machine is running
three long verification runs on cores 8 to 31; never use those cores and never write in
`/home/expert/Documents/contracting/Andria/paleo-RF-verify/`. No git commits, pushes or branch changes (the main
session commits). No web search: everything you need is local.

Tools: R 4.5.3 with ggplot2, terra, sf, patchwork, dplyr and tidyr. **Not installed:** gganimate, gifski, av, magick,
animation, ffmpeg and ImageMagick. The system `python3` has PIL, which can write an animated GIF from PNG frames.
Installing anything is an addition only Chris can approve: if your design needs it, say so and build what you can
without it. The pipeline is R only; the repository already has one Python figure tool (`tools/methodology_schematic.py`)
for presentation, so assembling R-rendered frames into a GIF with PIL is acceptable if you say why.

## The task
Chris wants to watch how the ice, the vegetation and, if it can be shown clearly, the albedo change through the
Holocene, as an animation: two or three separate animations, maps side by side in one animation, or, if you can find
an elegant way, everything in one picture. He expects a little iterative design. He also asks: what is the finest
time resolution we can show for each of the three?

## Data
- **Time slices of the analysis:** 25, at 50, 200 and then every 500 years from 500 to 11,500 BP
  (`config.R`, `analysis$ages`). Each slice name stands for a pollen time bin (Dawson et al., Climate of the Past
  2025): 500-year bins from 11.7 to 0.7 ka, then 0.7-0.35, 0.35-0.1 and 0.1 to -0.074 ka (1850-2020 CE); the names are
  roughly the bins' centres. The grid is 1 degree (2,870 cells).
- **Vegetation:** the fractions of evergreen trees and shrubs (ET), open land (OL) and summergreen trees and shrubs
  (ST) in each cell at each slice: `data/lct_paleo_reveals_interp.RDS` in the run folder below.
- **Ice:** the fraction of each cell under ice at each slice.
  - The old raster, still the default: `data/Dalton_QSR_2020_Ice/dalton_interpolated_LC6k.tif` in the main checkout
    `/home/expert/Documents/contracting/Andria/paleo-RF` (one band per slice, interpolated from Dalton et al. 2020).
  - NADI-1 (Dalton et al. 2023): `data/nadi1_fractions/nadi1_optimal.tif` (and `_minimum`, `_maximum`), tracked in
    this worktree, one band per slice, the 1 ka ice carried forward to 500, 200 and 50 BP. The raw NADI-1 margins
    are snapshots every 500 years from 25 to 1 ka: `data/nadi1/shapefiles/` in the main checkout (49 snapshots, each
    as best estimate, minimum and maximum). `tools/build_nadi1_fractions.R` shows how they became the fractions.
  - The 21 glacier outlines script 7 draws, every 1,000 years from 21 to 1 ka:
    `data/map-data/ice/glacier_shapefiles_21-1k.RDS` in the main checkout.
- **Albedo:** the predicted vegetation albedo of each cell, slice and month (12 months):
  `output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS` (column `alb_mean`) in the run folder. The surface
  albedo with ice is the partial-ice mixture used in the forcing: ice fraction x glacier albedo (0.68, the
  `ice_albedo_fixed` column of `data/albedo_glacier_monthly.csv`) + (1 - ice fraction) x vegetation albedo
  (`R/differences.R`, script 7a). Script 7a's consecutive differences are in `data/ALB_diffs_bluesky.RDS`.
- **Run folder (read only):** `/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main`,
  a verified full run of the final configuration (`config_used.R` there). Its ice is the old raster.
- **Map conventions:** `scripts/7_plot_preds.R` and `R/map_helpers.R` (projection, land boundaries, theme). Call the
  existing helpers rather than copying their code.

## What to deliver
1. **Time resolution.** For ice, vegetation and albedo: the finest time step in the data, over what span, with the
   file evidence (band names, snapshot names). Say plainly what interpolating between slices would and would not mean.
2. **Two or three display designs:** for example separate animations; panels side by side sharing one clock; one
   combined picture (for instance vegetation as a three-way colour mix, ice as a white veil whose opacity is the ice
   fraction, albedo as a further panel or a line). For each: a sketch in words or ASCII, its strengths and weaknesses,
   and how it honours each source's own time step. Recommend one, and say which albedo to show (annual mean, one
   month, or the seasonal cycle within a slice) and which ice (old raster, NADI-1, or both).
3. **A prototype of the recommended design:** one short, readable script under `tools/` that renders the frames from
   the files above into `animations/`, and an animated file if the available tools allow; plus one still for each
   alternative design, so Chris can compare. Fixed colour scales across frames; every frame labelled with its age and
   time bin; nothing that suggests finer time resolution than the data have.
4. **Your final message:** the design note (points 1 and 2), what you built and how to run it, every file created with
   its line count, the frames and their sizes, the measured runtime, the open choices for Chris, and anything you
   could not do.
## Also given to Astra (not reproduced here)

Chris's rules on simplicity and architecture, which every design or review brief must include.

## Later rounds (sent by resuming the same session)

### Round 2

Chris has asked for one change, and it takes precedence over the brief's line "nothing that suggests finer time
resolution than the data have": he wants interpolation that blends between frames, so the animation has about twice
as many frames, one blended frame between each pair of consecutive slices. In his words, that "will look good".

Please build it into the prototype of your recommended design:
- Between each pair of consecutive slices, one in-between frame, so the 25 slices give 49 frames. My suggestion is to
  blend the data rather than the pictures: at the midpoint, the ice fraction, the three cover fractions and the
  albedo are the averages of the two slices. Choose otherwise if you have a reason, and say which you chose and why.
- Keep it honest at a glance: each slice frame labelled with its age and time bin as before; each blended frame
  labelled as a blend of the two slices (for example "between 6,500 and 6,000 BP, blended"); and the clock or time
  axis marking where the real slices are.
- The young end is unevenly spaced (1,000, 500, 200 and 50 BP): say how you handle the timing (for example frame
  durations proportional to the time between slices) and why.
- Everything else in the brief still applies: R on cores 32 to 47 only, new files only under tools/ and
  animations/, no new packages, no git commits.

Report as before: what changed, every file with its line count, the frames and the animated file with their sizes,
the measured runtime, and the open choices for Chris.

One correction from looking at your frames: in the albedo panel the cells under the ice sheet are blank (for
example around Hudson Bay and Quebec-Labrador at 8,000 BP), apparently because those cells have no vegetation
prediction at that slice. Where the ice fraction is 1, the surface albedo is the glacier albedo whatever the
vegetation, so such cells should show 0.68. Check how the pipeline treats them (R/differences.R and script 7a) and
follow it; where a cell has partial ice and no vegetation prediction, leave it missing and say so in your note.

Chris has not yet chosen between the shared clock and your alternatives A and B, nor the month or the ice source: keep
the shared clock as the prototype for now, and make the blending work the same way for all three designs.

### Round 3

Chris has chosen, after seeing your first round:
- **Layout: the shared clock** (ice | vegetation | surface albedo). Render only this design from now on.
- **Remove the title and the footnotes** from the frames. Keep only what an animation over time needs: a compact
  clock (the timeline with its slice markers and the current age; a blended frame still marked as a blend, in a
  word or by its marker). Put the explanatory notes (sources, the mixture formula, what a blend is, the timing rule)
  in a short caption text file beside the GIF instead.
- **Reconsider the colour maps of the second and third plots** (the vegetation mix and the surface albedo). Propose
  two options for each, rendered as stills of one frame side by side, and use your recommendation in the GIF. Think
  about what reads intuitively (for example familiar land-cover colours for evergreen, summergreen and open land;
  an albedo scale that runs from dark to bright, so that high albedo looks bright, as snow and ice do), colour-blind
  safety, and that both scales stay fixed across frames.
- **Albedo: April**, as you recommended.
- **Ice: NADI-1 best estimate** (`data/nadi1_fractions/nadi1_optimal.tif`) instead of the old raster, for the ice map
  and for the ice part of the surface albedo. Say what changes in the picture, and in which cells, with its footprint.
- Keep the blending and the timing rule of your second round. The faster playback at the young end stays unless you
  think it hides something; say so if it does.

Everything else in the brief still applies: R on cores 32 to 47 only, new files only under tools/ and animations/,
no new packages, no git commits. Report as before: what changed, the files with their line counts, the GIF and stills
with their sizes, the measured runtime, and any open choices for Chris.
