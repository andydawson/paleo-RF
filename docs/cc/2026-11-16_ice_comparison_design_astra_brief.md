# Brief for Astra (ultra effort): design the ice comparison, the readvance check and the forcing with the 2023 ice

*Chris McWilliams, 16 November 2026. Design only, read-only. Chris's arrangement from today: Astra designs and
reviews, an Opus agent implements, then the verification tool for any change to `R/`, `scripts/`, `tools/` or
`tests/`.*

## Why
Andria (the PI) and Chris meet soon. In her written answers Andria favoured the newer ice reconstruction
(Dalton et al. 2023, "NADI-1") if its time steps fit our slices, and asked to see how the new ice fractions differ
from the original ones and how much that changes the forcing. In their call she also worried that the
partial-ice albedo formula may not work when ice readvances. The result tells her whether to switch the ice
reconstruction, and whether the formula or the readvance rule needs to change.

## Chris's request (16 November, his words, lightly trimmed)
"...look at getting some new shapefiles for the glacier, because she doesn't remember exactly how those ones were
obtained, but also there's a Dalton [2023] paper ... which has new versions ... of the ice files which we can use,
which are presumably better. What I said I would do is look into it and see what the difference is between those
and our original ones. What time points they're recorded at, and if that causes us any problems. What she did say
is that she did a linear interpolation originally to produce ice shapefiles at the time points we needed, so we can
do that again if we need to. And then once we've got the new ice shapefiles, we need to look at the ice
re-advancing issue. ... her memory was that ice re-advance never happens. And she was concerned that when it does
happen, the fractional scaling of albedo, so the method where we ... weight the cell albedo by the area that's
non-ice ... might not work when we have ice re-advancing. She described how she had originally drawn out lots of
diagrams on paper of the different types of change that were possible in terms of ice retreating and
re-advancing, and she wanted us to double check the formula against that ... I want ... at least to be able to tell
her with the old shapefiles and the new shapefiles when ice re-advances happen, and then if that does break our
formula."

## Chris's decisions (16 November)
1. **Download NADI-1:** yes; done (below).
2. **Scope: "Plus forcing with new ice".** (a) Compare the old ice inputs with NADI-1: time steps, ice area by
   slice, maps of where they differ. (b) List every readvance in each: where, when, how large, and whether it lies
   within NADI-1's minimum-to-maximum range. (c) Check the partial-ice formula and the readvance averaging against
   every kind of change, with worked cases Andria can compare with her diagrams. (d) The ice, vegetation and total
   forcing by period recomputed from the saved hindcasts with the NADI-1 ice, with readvances kept and with them
   averaged away, so the meeting has the size of each effect in W/m². A stand-alone calculation: **no pipeline
   change.**
3. **Young slices** (50, 200 and 500 BP; NADI-1 ends at 1 ka): "Carry the 1,000-year ice forward to the young
   slices, as the old raster does, so old and new are compared like for like. List the alternatives for Andria to
   choose from: no ice, or today's glaciers from a published inventory, with a short read-only note on present-day
   sources. No new data."
4. **Format:** "A few slides" for the meeting, made afterwards from the analysis's figures and tables.

## Rules
- Change no file; do not commit. R may not start in your sandbox; Python is available (you read the project's
  RDS files in Python on 15 November). Check facts your own way from the files where you can.
- Plain words, no private ids. Summary first.
- **Simplicity is a requirement** (Chris): as simple, clear, readable and parsimonious as possible; readability
  before elegance; no overengineering; no duplicated code (reuse the shared functions in `R/`).
- For every choice of method, give published precedent from this field (ice-sheet reconstructions and their use
  in climate models or forcing, albedo and land cover, palaeo-vegetation) with DOI and passage, or say it is a
  project choice.
- The repository is public. Never open `data/modis_albedo/requests/`.

## Facts and where to find them
**Worktree:** `/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice`, branch `ice-nadi1`, off the trunk
`feature/single-config` at c86e4b5.

**The two old ice inputs** (both tracked; see `docs/cc/questions_for_andria_scientific.md`, sections C0, C0b, C1,
C2 and B8):
- `data/map-data/ice/glacier_shapefiles_21-1k.RDS`: a list of 21 polygon sets (SpatialPolygonsDataFrame; fields
  `SYMB` = "ICE", `Area_Km2`), one per 1,000 years from 21 to 1 ka; source not recorded (thought to be an older
  reconstruction than Dalton et al. 2020). They give the `ice` flag in Andria's land-cover product (point in the
  nearest polygon set, ties to the younger; where she did not estimate vegetation), the ice outlines on the maps
  (script 7) and the present-day ice caps left out of the calibration (cell centre inside the 1 ka set: 48 cells).
- `data/Dalton_QSR_2020_Ice/dalton_interpolated_LC6k.tif`: 26 layers (`yr12000bp` ... `yr50bp`), 1-degree grid,
  WGS 84, values 0 to 1. The ice **fraction** used for the albedo mixing and the forcing (`scripts/7a_alb_diff_full.R`,
  lines 46 to 62: layer chosen by the slice age, then projected). Andria thinks she made it from Dalton et al. 2020
  by linear interpolation to the slices; the method is not recorded and she will look for the code. It carries the
  1 ka ice unchanged to 50 BP, while the land-cover product has no ice at 50, 200 and 500 BP. At 50 BP the polygon
  test flags 48 cells as ice and the raster has 28 cells over half ice (156 with any ice).
- **Readvances in the old raster** (my read-only count over the whole raster grid at the pipeline's 25 ages,
  script `/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/old_ice_facts.R`):
  the ice fraction grows from an older slice to the next younger one in 215 cell-pairs (103 cells); by more than
  0.01 of the cell in 117 (69 cells); by more than 0.10 in 16 (10 cells); at pairs from 11,500/11,000 to
  1,500/1,000 BP. Not yet restricted to the pipeline's cells. The project's records also give 2,844 "pairs" still
  growing after the averaging (probably cell-month rows; reconcile).

**The formula and the readvance rule:** `R/differences.R` (the readvance averaging near lines 45 to 51: an increase
of ice towards the present is replaced, once, by the mean of the neighbouring slices; the vegetation part
`(a_young - a_old) * (1 - f_old)`; the ice part `(a_young - A_old) * (f_old - f_young)`; the 50 % threshold
variants and the "endpoint" method), `tests/test_differences.R` (sixteen hand-made cases, including the advance,
the double count and the youngest-pair fault), the changelog's I16a entry in
`docs/cc/changelog_single_config_migration.md` (3 advances across the threshold, 6 double counts, the youngest-pair
fault). Algebra on record (C1, 19 October): the partial-ice total equals the exact change of
`f * A + (1 - f) * a` for retreat, advance, partial and full cases; its error term is `f_young * (A_old - A_young)`,
zero because the glacier albedo depends on the month only. My own reading, for you to check: on an advance the
split puts the vegetation change on land that ends under ice, `(a_young - a_old) * (f_young - f_old)`, into the
vegetation part, and values the newly iced land's earlier albedo at `a_young` rather than `a_old`. Andria now wants
the vegetation part reported separately, so the split matters.

**Configuration and forcing code:** `config.R` (headline `veg_ice_parts`, i.e. partial ice with the fixed glacier
albedo 0.68 of `data/albedo_glacier_monthly.csv`; threshold 0.5 with the "endpoint" method as a sensitivity;
month-by-month glacier albedo a further sensitivity), `scripts/7a_alb_diff_full.R`, `scripts/8_radiative.R`,
`R/forcing_components.R`, `R/forcing_periods.R`, `R/forcing_breakdown.R`, `R/kernels.R`.

**The headline run** (read-only): `/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main`
(model 8; MODIS cell albedo, all days, `full_75`; ice caps out of the calibration; threshold 0.5; endpoint method;
headline `veg_ice_parts`; kernels HadGEM3, CAM5, CACK): `config_used.R`, `data/ALB_diffs_bluesky.RDS` (script 7a's
table per cell, month and pair of slices), `data/alb_interp_preds_diffs_bluesky.RDS`, `data/ice_fort*.RDS`,
`output/forcing/`, `output/prediction/`. Confirm it is the right run for the current headline, or say which is.

**NADI-1** (downloaded today with Chris's approval; not in git):
`/home/expert/Documents/contracting/Andria/paleo-RF/data/nadi1/` with `PROVENANCE.txt`; the shapefiles are in
`shapefiles/NADI-1 shapefiles Dalton et al. QSR/`, named `<age>ka_cal_{OPTIMAL,MIN,MAX}_NADI-1_Dalton_etal_QSR.shp`,
ages 1 to 25 ka every 0.5 ka, WGS 84 geographic. Paper: Dalton et al. 2023, Quaternary Science Reviews 321, 108345,
doi:10.1016/j.quascirev.2023.108345. Find out what you can from the files and the paper: what the polygons
represent (which ice sheets; marine margins, ice shelves, glacial lakes), the time convention, what MIN and MAX
mean, and any readvances the paper discusses.

**Time slices** (Andria, 12 November): 25 slices following the PAGES LandCover6k specification. "50" is 1850 CE to
the 2020s, "200" is 1600 to 1850 CE, "500" is 1250 to 1600 CE, then 500-year bins from 0.7 to 11.7 ka named 1,000
to 11,500 (each name roughly its bin's centre). NADI-1's steps coincide with the names from 1,000 to 11,500.

**Work in flight, not to be edited:** branch `cv-compare-tool` (`R/hindcast_comparison.R` splits forcing into
vegetation, ice and total and reproduces scripts 9 and 10's study-area means from saved runs); it has just been
changed and awaits your review.

## What the design must give
1. **Ice fraction per cell from polygons:** how to compute it for NADI-1 (optimal, minimum, maximum) on the
   pipeline's 1-degree cells at the 22 slice ages from 1,000 to 11,500 BP, and the young slices carried forward;
   whether to compute the old 21 polygon sets the same way, so that differences of chronology can be told from
   differences of method.
2. **The comparison, old against new:** which few tables and maps; how to show the minimum-to-maximum range; the
   modern-slice disagreement already on record.
3. **The readvance inventory:** a definition and size thresholds; where and when; in the old raster, the old
   polygon sets and NADI-1; whether each lies within NADI-1's minimum-to-maximum range; how to tell artefacts of
   interpolation or rasterising from readvances in the reconstruction; any named readvances the NADI-1 paper
   discusses, cited.
4. **The formula check:** every kind of change Andria could have drawn (no ice, partial, full ice, at both ends;
   retreat, advance, no change; with and without vegetation change), each with the exact albedo change, what the
   partial-ice headline and the 50 % sensitivity compute, the split into vegetation and ice parts, and what the
   readvance averaging does to the input; the known edge cases (the youngest pair, the double count, the
   vegetation albedo under ice); worked numbers. Say plainly whether any case breaks the formula, and if one does,
   the smallest fix, as a proposal for Chris, not a change. Reuse `tests/test_differences.R` where you can.
5. **The forcing with the new ice:** how to recompute the ice, vegetation and total forcing by period from the
   saved hindcasts with the NADI-1 fractions, with readvances kept and with them averaged away, reusing the shared
   functions (no copy of script 7a's or 8's arithmetic), with a check that the same code fed the old raster
   reproduces the run's saved forcing exactly. Which kernels (at least the headline HadGEM3 all-sky), periods, and
   study-area mean or global equivalent, as the run reports them. Whether a vegetation albedo exists wherever NADI-1
   and the old ice disagree, for example cells the land-cover product leaves without vegetation because the old
   polygons put ice there.
6. **The young slices:** the carried-forward treatment, and the short read-only note on present-day sources (for
   example the Randolph Glacier Inventory, GLIMS, and the MODIS land-cover class "permanent snow and ice", already
   on disk in `data/mcd12q1/` in the main checkout), with what each would change. No new data.
7. **The slides:** an outline of a few slides for Andria, each with a title, its one message, and its figure or
   table, in plain words; and the list of figures to make.
8. **An implementation plan for an Opus agent:** the base branch (this worktree unless you advise otherwise);
   the files to add, as few as possible (stand-alone scripts where possible); the shared functions to reuse;
   outputs and where they go (committed: scripts, small tables, figures; not committed: large intermediate files);
   the checks and tests; runtimes to measure; whether the verification tool is needed.
9. **Questions for Chris**, only where the choice is genuinely his or Andria's, each written so that he can answer
   it without reading anything else.

End with a summary of the design in plain words of no more than half a page, placed first, then the details.
