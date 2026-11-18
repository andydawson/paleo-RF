# The ice work: what was built, 17 November 2026

Branch `ice-nadi1`, from Chris's decisions (`2026-11-17_ice_work_decisions.md`) and the design
(`2026-11-16_ice_redesign_simpler_codex_gpt6astra.md`, sections 1, 2 and 4), plus his two later
decisions: compute both rules for splitting the forcing into a vegetation part and an ice part, and
label the oldest slice 11.5 ka. No pipeline script was run on full data; the forcing runs are
the six verification specs below, for the main session to run.

## What was built, one commit each

1. **NADI-1 ice fractions** (`tools/build_nadi1_fractions.R`; `data/nadi1_fractions/`, committed:
   optimal 68,055 bytes, minimum 54,726, maximum 67,752, provenance note 28,587). On the old raster's
   grid and missing cells, 25 bands `yr11500bp` ... `yr50bp`; slices 1,000 to 11,500 BP take the
   NADI-1 snapshot of the same age, 500, 200 and 50 BP the 1,000 BP fractions. A cell's fraction is
   its area under ice over its whole area. Checks passed: fractions within 0 to 1, band names, grid
   and missing cells, the same prediction cells with a value as from the old raster, young bands
   equal to 1 ka, area conserved (largest relative difference 1.8e-13). Built in 1.6 minutes, peak
   memory 353 MB; a second run wrote byte-identical files; halving the edge step changes no fraction
   by more than 2.7e-7.
   - **One departure from the design.** It asked for areas on the sphere with sf's s2 engine, as
     script 7a measures cell areas. s2 reads every polygon edge as a great circle rather than the
     straight line the file draws (NADI-1 has edges up to 12.7 degrees long), so some polygons cross
     themselves on the sphere, and it turns the 8.5 ka minimum inside out even after repair, which
     would cover the whole grid with ice. The polygons are therefore taken as drawn (GEOS) and the
     areas measured in an equal-area projection (EPSG:6931) after cutting edges every 0.01 degrees.
     In the other 65 snapshots the two conventions differ by at most 0.0008 in any fraction. The
     merged areas match the data set's own `Area_Km2` totals within 0.01% in 58 of 66 snapshots;
     in the others the polygons overlap (6 ka optimal) or the attribute does not match its polygon.
   - Repairs, all reported in the provenance note: three rings the files leave open were closed (one
     at 8.5 ka minimum, open by 0.34 degrees), and 12 polygons that cross themselves were made valid
     (`sf::st_make_valid()`, which keeps holes).
   - The order minimum <= optimal <= maximum fails in 129 cell-slices (24 cells): 125 by less than
     1e-4, the largest by 0.0099 (6 ka, 66.5 W 67.5 N, Baffin Island). Reported, not repaired.
2. **The setting** `analysis$ice$fraction_source`: `"dalton_ice"` (the default and the legacy value),
   `"nadi1_optimal"`, `"nadi1_minimum"`, `"nadi1_maximum"`. Script 7a reads the file it names and
   stops unless each prediction slice has exactly one band. No output changes: for both
   configurations 7a still reads the same file with the same checksum.
3. **Both splits of the partial-ice forcing.** Today's rule is unchanged; the second rule (vegetation
   change only on land ice-free at both slices, the rest of the total to ice) adds
   `alb_diff_veg_part_exposed` and `alb_diff_ice_part_exposed` (script 7a), six `rf_*_exposed`
   forcings (script 8) and two rows per period in script 9's variant table. Made only with the
   `endpoint` method, so the legacy configuration's outputs stay exactly as they were. On all 34,392
   cell-months of the headline run, the old and new function give identical output under
   `legacy_components` and identical existing columns under `endpoint`, equal bit for bit to the
   headline's saved table; the rules differ in the 2,844 cell-month rows where ice advances.
4. **The oldest slice labelled 11.5 ka** (config.R; the legacy file keeps 12,000 BP and its alias).
   The forcing groups the same rows into the same periods. Script 7 keeps the slice's 12 ka ice
   polygon (a small helper, `ice_match()`, matches 11,500 BP as 12,000 BP), so its ice mask, coarse
   differences, outlines and the EGU 2024 recipe change in their labels only (Chris, 18 November
   2026, after Astra's review). As first built, script 7 matched 11,500 BP to the nearest polygon,
   11 ka (halfway, it takes the first): in a one-month trial (January) the oldest slice was ice in
   775 rather than 987 of the 2,730 cells of the coarse differences (216 cells changed), and the
   oldest difference map lost its ice outline (`ice_fort` keeps the age 11,500 while the outline
   lookup asked for 11,000). The same trial with the fix gives the headline's outlines and January
   coarse differences exactly, labels aside; under the legacy configuration it gives the tail
   anchor's three outline files byte for byte and its January coarse differences exactly. The
   pipeline's forcing (scripts 7a to 10) does not read the polygons.
5. **The comparison** (`tools/compare_ice.R`, checked by `tools/check_compare_ice.R`): three tables
   and five figures, no forcing arithmetic of its own. On the saved headline run it reproduces the
   established old-raster audit on the 2,655 forcing cells: 186 cell-pairs whose ice fraction
   increases, 228 after script 7a's averaging (153 kept, 33 removed, 75 created). NADI-1 has 142
   (optimal), 35 (minimum) and 231 (maximum) such increases before averaging.
6. **Six verification specs** (`docs/cc/verification/2026-11-17_ice-*.R`, commit to fill in).
   Strengthened on 18 November (Astra's change 3): the replay now runs script 7 as well and checks
   its four outputs against the headline's, labels aside (the oldest mask and outline included);
   every forcing run checks the second split's new columns (`tools/check_ice_split.R`); the replay
   rebuilds the three NADI-1 files into its own run folder and compares their checksums with the
   committed files; and the comparison is made once, by its own spec, not in every run.

## The verification runs

| Spec | Runs | Expected time |
|---|---|---|
| `ice-old-replay` | 7, 7a, 8, 9, 10 from the headline's predictions; script 7's outputs and every headline column and number, labels aside; the split check; the tests; the NADI-1 files rebuilt | about 2 h 30 min (7 was 70.2 min and 7a 76.0 min in the headline) |
| `ice-legacy` | 7, 7a, 8, 9, 10 under the legacy configuration; both anchors in full | about 2 h 10 min (7 took 70-73 min, legacy 7a 53 min) |
| `ice-nadi1-optimal`, `-minimum`, `-maximum` | 7a, 8, 9, 10 as in the replay with only the ice changed; the split check | about 80 min each |
| `ice-comparison` | no scripts: the meeting's tables and figures from the four runs, made once | about 1 min, after the four runs |

The first five can run side by side, each with eight threads on its own eight cores (the
regression contract's thread count for comparison runs; scripts 7 to 10 use one core). Start one
first and the others once its scripts are running: two verifications starting together on the
same commit can collide while the first makes the shared worktree and links its inputs.

## Worth knowing

- Every `config_used.R` written before this work lacks `analysis$ice$fraction_source`, so
  `load_config()` now refuses it. Tools that load the configuration of an existing run
  (`compare_cv_hindcasts.R`, `explore_cover_contrasts.R`, `check_cv_separation.R`,
  `cross_validate_albedo.R`) stop on runs made before this branch. `compare_ice.R` reads the
  run records instead and is not affected.
- Script 7a reprojects each ice band before reading it, which rounds the double-precision NADI-1
  fractions to single precision (at most 3e-8). Harmless; `compare_ice.R` reads them the same way.
- Not done here: the GitHub issue (design step 1), the reviews the change needs (the science of
  the split and the builder: Fable and Astra; the plumbing: the change reviewer), the runs.
