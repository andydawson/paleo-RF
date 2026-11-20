# Review of the ice-maps design (Fable, change-reviewer), 20 November 2026

Reviewed: `docs/cc/2026-11-20_ice_maps_design.md` at ba0aeb4, in the worktree `/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps`. Paths below are relative to that worktree. Read-only: nothing was run and no raster or RDS file was opened.

**Verdict.** Buildable after the should-fix points are written into the design. None of its facts is wrong; three are incomplete. Chris must first choose between the new setting (the design's alternative A) and no setting (alternative C). C is the shortest route that keeps every anchor, but it meets the goal for NADI-1 only.

## Simpler routes, deletion and reuse first

1. **No new setting (alternative C: outlines when `fraction_source = "dalton_ice"`, fractions for NADI-1).**
   - Saves about 16 lines: `config.R`, `configs/legacy_config.R`, `R/config_schema.R` (the choice and its `HISTORICAL_SETTINGS` line) and `tests/test_config.R`.
   - Adds no option, so it avoids the architectural addition that needs Chris's explicit approval.
   - Keeps all legacy anchors and today's default outputs.
   - Makes no existing product stale (finding 3).
   - Cannot hit the wrong-band case (finding 2).
   - Cost: with the old raster, the maps still show the 21 outlines, not the raster the forcing uses. One comment in `config.R` must say that `fraction_source` also chooses the map ice (+2 lines).
2. **Keep the shared helper, but smaller (about 25 lines, not 35).** Two functions: the band of one slice (the one-band check plus script 7a's reprojection), and the fraction at points.
   - The `read_input()` line stays in each script, so the read is visible when stepping through.
   - The helper is justified: `tools/compare_ice.R:135-140` is already a second copy of script 7a's lookup, with a comment saying it must read the same way.
3. **Reuse the existing `fortify()` loop for the outline columns (`scripts/7_plot_preds.R:59-64`).** Convert the dissolved cells to an sp object and pass it through that loop. The nine columns then match by construction, and line 369 (`ice_fort[,1:9]`) keeps working. No hand-built data frame.
4. **`cells_in_polygons()`: not in the pipeline, yes in the check.**
   - For the flag, `fraction > threshold` is script 7a's rule stated directly; routing it through polygons is indirect.
   - It is the right tool for the outline check in finding 4, with no new code.
5. **Tiles instead of dissolved polygons: not simpler while the outlines path stays.**
   - Eleven `geom_polygon` ice layers (lines 203, 220, 240, 259, 278, 292, 310, 431, 432, 452, 453) would each need a second form.
   - Tiles taken from prediction rows could also lose ice. The prediction summary has 839,232 rows, which is 69,936 per month and not a multiple of 25 slices, so some cell-slices have no row. I could not tell from reading whether those are the ice-covered ones.
   - Cell squares written in `ice_fort`'s columns would be exact and need no dissolve, but every cell border would be drawn.
6. **Without the helper.** Script 7 could read the band directly and script 7a stay untouched, saving about 45 lines and the 7a re-verification. But that makes a third copy of the lookup, against the no-duplication rule, and leaves agreement with 7a to a check rather than to construction (see finding 4 on rounding). Not recommended.
7. **Alternative B (no setting, always fractions).** Fewest lines, but it breaks five anchored files under the legacy configuration, not four (finding 6), and silently takes the wrong band (finding 2). It needs a change to the regression contract, which is Chris's decision in its own commit.

## Findings

| # | Severity | File:line | What is wrong | Consequence | Evidence | Check; lines the fix costs |
|---|---|---|---|---|---|---|
| 1 | should-fix | design lines 39-40, 81-82; `R/differences.R:36, 52-59` | The design says script 7's flags will equal "those above the threshold in script 7a". With the default `"endpoint"` method, 7a's threshold variants classify on the readvance-averaged fraction, not the band's own. | The verification either compares with the unadjusted fraction (true by construction, proves little) or fails in the pairs where averaging crosses 0.5. The changelog would overstate "the ice the forcing uses"; the headline variant is partial ice and uses no threshold at all. | `differences.R:52-59`; `scripts/7a_alb_diff_full.R:138-143` | Reword: maps show cells whose unadjusted fraction exceeds the threshold. Whether the averaging stays is open with Andria and must stay open. 0 code lines. |
| 2 | should-fix (A and B only) | `scripts/7_plot_preds.R:102-105, 113`; `tools/build_nadi1_fractions.R:45-46` | With `slice_alias`, script 7 relabels 11,500 as 12,000 before the ice lookup. The old raster has an unused 12,000 BP band; NADI-1 has none. | Fractions plus alias plus the old raster silently takes the 12,000 BP band, while 7a uses 11,500. With NADI-1 the run stops with the band-check message. Under B this is the legacy configuration itself. | Lines cited; alias in `configs/legacy_config.R:88` | Under C: nothing. Under A: look the band up by the data's slice age, about +2 lines. A config rule refusing the combination is a new refusal and needs Chris. |
| 3 | should-fix (A only) | `R/run_manifest.R:180-190, 198-204` | A new key under `analysis` makes every product from before the key differ from the current settings ("(absent) -> ..."). | Scripts 7 to 10 stop on the existing prediction summary until scripts 1 to 6 are rerun or `run$allow_stale = TRUE`. Switching the setting does the same. The key cannot go under `presentation`, because it changes the coarse differences. | Lines cited | State it under "Expected effect". 0 lines. None under C. |
| 4 | should-fix | design line 40-42; `scripts/7_plot_preds.R:140-149, 203`; `tools/compare_ice.R:131-134` | Nothing ties the drawn outline to the flagged cells. Three ways they can differ are listed below the table. | A map that hides non-ice cells or draws ice the flags do not have. No anchor sees it; figures are not anchored. | Lines cited | Make the outline from the band the helper returns (0 lines). In the verification, per coarse slice: tile centres inside the outline equal the tiles flagged `'ICE'`, using `cells_in_polygons()` (about +5 lines in the spec). |
| 5 | should-fix | design "Files and lines" | Files missing from the list (below the table). | The line count Chris approves is short; stale comments would mislead Andria. | Lines cited below | List them. About +5 for A's tests; comments about ±6. |
| 6 | nit | design lines 28-30; `tests/anchors/interp-forcing-2026-10-08/MD5SUMS.txt:2` | The anchored list omits script 9's slide-18 recipe table, `forcing_by_period_egu2024recipe_vs_slide.csv`. | Alternative B costs five anchored files, not four. | MD5SUMS line 2 | Add it. +1 line. |
| 7 | nit | `scripts/7_plot_preds.R:37` | The design does not say whether `glacier_shapes` is still read on the fraction path. | The run manifest would list an input the run did not use. | Line 37 | Read it only on the outlines path. +1 line. |
| 8 | nit | design "Expected effect" | Two effects are not stated: ice outside the raster's valued cells disappears from the maps, and prediction cells with no fraction can never be flagged. Today the outlines cover both. | A reader comparing old and new maps sees unexplained differences. | `build_nadi1_fractions.R:43-46`; `7a_alb_diff_full.R:89` | State both and count the second in the verification. 0 code lines. |

Finding 4, the three ways the outline and the flags can differ:
- **Enclosed ice-free cells.** `geom_polygon(group = group)` fills hole rings, so an ice-free cell surrounded by ice is painted over.
- **Different grids.** Tiles sit on the cell centres of `data/grid.RDS`; the outline sits on the fraction raster's cells. If the two grids are offset, the outline cuts through tiles.
- **Rounding.** Script 7a's reprojection rounds NADI-1's double-precision fractions to single precision (at most 3e-8). An outline made from the raw band can differ from flags made from the reprojected band for a fraction within that distance of 0.5.

Finding 5, the missing files:
- `tests/test_config.R`: about +4 lines for the setting. Its lines 318-322 fail unless `HISTORICAL_SETTINGS` in `R/config_schema.R:207-209` gains a line.
- Comments that become untrue on the fraction path ("script 7 gives the slice the 12 ka ice polygon"): `config.R:105-107`, `configs/legacy_config.R:84-85`, `scripts/7_plot_preds.R:40-44` and `99-101`.
- `README.md:118` and `236`.
- `docs/cc/questions_for_andria_general.md:197-202`: the missing young outlines stay on the outlines path only, and the entry's line reference moves.

## Right (the design's facts I confirmed)

- **Anchors.** The four script 7 files are anchored byte for byte (`tests/anchors/interp-tail-2026-09-21/MD5SUMS.txt:2-5`; contract section 2), under the legacy configuration only.
- **Script 9.** `scripts/9_forcing_barplot.R:378` sets the forcing to NA where `ice_young` or `ice_old` is not NA. Any non-NA value masks, so the new flag must be the text `'ICE'` or NA, never FALSE or an empty string. Script 7 itself tests `is.na` (line 159) and `== 'ICE'` (line 161). Nothing else in `scripts/`, `R/` or `tools/` reads these columns or the `ice_fort*` files.
- **Bands.** NADI-1 has 25 bands, `yr11500bp` to `yr50bp`, with 500, 200 and 50 BP equal to 1,000 BP (`tools/build_nadi1_fractions.R:74-77, 191, 213, 219-220`). The old raster has the same 25 plus 12,000 BP (lines 45-46, 207). All eight coarse ages of `config.R` have a band in every file.
- **50 and 500 BP get no difference outline today.** `scripts/7_plot_preds.R:376-385` matches coarse ages against 1,000 to 21,000; both map to 1,000 and no coarse age is 1,000. The youngest period has neither outline, the next no young one. This matches the open entry for Andria.
- **11,500 BP.** With `config.R` (no alias) the fraction path uses the 11,500 BP band, the same as 7a.
- **Threshold rule.** It is `>` (`7a_alb_diff_full.R:142`; `differences.R:58-59`).
- **Column shape.** `ice_fort` has 9 columns and the difference outlines 10; only `long`, `lat`, `group`, `ages` and `facets` are read.
- **Script 2's 1 ka mask** is separate (`scripts/2_calibration_lct_bluesky.R:47`); out of scope is right.
- **The design leaves the default to Chris** and treats NADI-1 as Andria's open decision. No doubt is turned into a decision.

## Line count (my estimate)

| File | Design | Mine |
|---|---|---|
| `R/ice_fractions.R` (new) | +35 | +25 |
| `scripts/7a_alb_diff_full.R` | +5 / -20 | +5 / -17 |
| `scripts/7_plot_preds.R` | +40 / -5 | +38 / -6 |
| `tests/test_ice_fractions.R` (new; helper only, the outline is checked in the verification) | +30 | +20 |
| `README.md`, changelog, questions file | +10 | +12 |
| **Without the setting** | | **+100 / -23, net +77** |
| **The setting (A only):** `config.R` +6, `configs/legacy_config.R` +4, `R/config_schema.R` +2, `tests/test_config.R` +4 | +11 | **+16** |
| Under C instead: comment in `config.R` and `configs/legacy_config.R` | | +3 |

Totals: A about +116 / -23, net +93 (design: net +105). C about +103 / -23, net +80.

## Questions for Chris

1. **Setting or no setting?** Nothing is built meanwhile.
   - C: no setting; outlines with the old raster, fractions with NADI-1. Net about +80 lines, nothing stale, defaults unchanged. The old-raster maps stay as they are.
   - A with `"outlines"` in both configurations for now: net about +93 lines, defaults unchanged, existing products stale once.
   - A with `"fraction"` in `config.R` now: as above, and the default run's script 7 tables and the slide-18 recipe table change to the old raster above 0.5.
2. **Only if the check in finding 4 finds ice-free cells enclosed by ice:** a dissolved outline that paints over them, or cell squares that are exact but show every cell border?

## Not worth doing

- Replacing the legacy `over()` loop with `cells_in_polygons()`: saves about 5 lines but risks the anchors.
- Moving `tools/compare_ice.R`'s copy of the lookup onto the helper now: saves about 3 lines, but it is a finished meeting tool whose outputs would need proving again.
- A config rule refusing fractions with `slice_alias`: a new refusal; not needed under C.
- A guard for a slice with no cell above the threshold, unless a count on the four files shows one exists.
- Script 7 reading the fractions from script 7a's output: makes 7 depend on 7a, and those fractions are the averaged ones.
- Alternative D (NADI-1's own margins): a new prepared input that still disagrees with the cells.
- Fixing the missing young outlines on the outlines path: anchored, and open with Andria.
- A toy-raster unit test of the outline code: it is inline in script 7, and the check on real data is stronger.

## Not checked

- The rasters themselves: the old raster's band names and CRS, whether its grid lines up with `data/grid.RDS`, how many cells exceed 0.5 at the young slices, whether any ice-free cell is enclosed by ice, and how many prediction cells have no fraction.
- Which cell-slices the prediction table lacks.
- How `tools/verify_change.R` treats products made before a new setting.
- Whether the installed ggplot2 still accepts `fortify()` on sp objects without complaint.
- Scripts 8 and 10 were not read. Figures are not anchored, so the new maps need a look by eye.

Key files, absolute:
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps/docs/cc/2026-11-20_ice_maps_design.md`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps/scripts/7_plot_preds.R`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps/scripts/7a_alb_diff_full.R`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps/R/differences.R`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps/R/run_manifest.R`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps/R/config_schema.R`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps/tools/compare_ice.R`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps/tools/build_nadi1_fractions.R`

Files read: 22 (9 in part). Tool calls: 37.
