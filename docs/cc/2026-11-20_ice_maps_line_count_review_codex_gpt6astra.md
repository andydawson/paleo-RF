**Verdict. Not mergeable yet:** there is no implementation to approve. The smallest credible route changes script 7 alone—about **30–35 net executable lines**, leaving script 7a untouched.

Fable’s “net +80” was **45 lines of pipeline code, 20 of tests and 15 of comments/documents**. Removing the extraction refactor reduces the pipeline change. Once actual geometry problems and verification are covered, the complete handwritten change may still approach 80 lines.

The benefit is straightforward: Andria’s maps show the selected NADI reconstruction without disturbing the full-slice forcing calculation.

**Smallest implementation**

1. **Choose the input representation near [script 7, line 37](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps/scripts/7_plot_preds.R:37).**

   For Dalton, retain the glacier-shape read, 21 ages and current matching functions.

   For NADI, read the selected catalogue entry through `read_input()`. Derive the ages from all its band names. For each band, retain cells with fraction strictly above the configured threshold, dissolve them into polygons, add the character attribute `SYMB = 'ICE'`, and convert to the spatial-object type the existing loops consume. Below-threshold and missing cells must be excluded before polygonisation.

   This uses the stored fractions directly. The supplied NADI files are already WGS84 and aligned with the plotting grid.

2. **Reuse both existing loops.**

   The outline loop at lines 50–66 already produces the required nine columns. The point-in-polygon loop at lines 115–132 already produces `'ICE'` or NA from `SYMB`.

   Both therefore use the **same thresholded geometry**. No second fraction-extraction routine is needed. Keep the coarse-difference arithmetic, output names and downstream code unchanged.

3. **Give NADI exact age matching.**

   Its 11,500 BP slice uses `yr11500bp`, not the Dalton 12 ka polygon. Its 50, 200 and 500 BP slices use their own stored bands, which already carry the 1 ka fractions.

   Move the existing `slice_alias` assignment before the outline construction. For NADI, invert that display alias during lookup: a displayed 12,000 BP means the underlying 11,500 BP band. Preserve `ice_year = 11500` and the displayed `ages = 12000`. The existing difference-outline selection can then remain.

   Dalton retains its current matching, including the missing young difference outlines.

4. **Preserve holes in all eleven ice layers.**

   Define one shared aesthetic mapping. Dalton retains `group = group`; NADI uses the whole-polygon `id` as `group` and the existing ring `group` as `subgroup`. Substitute that mapping into the eleven existing `geom_polygon()` calls.

   This is necessary: the supplied masks contain real holes. It adds a few setup lines; the eleven substitutions have essentially no net line cost.

5. **Handle an empty mask as an empty result.**

   Threshold 1 is allowed and, with strict `>`, produces no ice. Retain a null entry instead of converting an empty polygon to `sp`; skip it in the two existing loops. Give the three empty outline tables their proper nine-/ten-column schemas.

   This adds no refusal or validation mechanism.

6. **Filter the NADI per-age pages correctly at lines 273–278.**

   The existing `year == year` expression plots every age on every page. For NADI only, select the current page’s rows explicitly. Otherwise correctly generated outlines can still be drawn over another age’s tiles. Preserve Dalton’s existing page behaviour.

**Line budget**

These are estimates before a patch, using ordinary formatting and separating executable statements from comments. Unchanged reindentation is excluded.

| File | Executable code | Comments/documents |
|---|---:|---:|
| `scripts/7_plot_preds.R` | about **+50 / −18 = +32** | +5 / −4 = +1 |
| `scripts/7a_alb_diff_full.R` | **0** | 0 |
| `R/ice_fractions.R` | **0; do not create** | 0 |
| `R/preparation.R`, `R/paths.R`, `R/config_schema.R` | **0** | 0 |
| `config.R` | 0 | +4 / −3 = +1 |
| `configs/legacy_config.R` | 0 | 0 |
| `tests/test_preparation_ice.R` | **about +35 test lines** | included |
| `README.md` | 0 | +5 / −4 = +1 |
| `docs/cc/changelog_single_config_migration.md` | 0 | +6 |
| `docs/cc/questions_for_andria_general.md` | 0 | +2 / −1 = +1 |
| Scientific living questions file | 0 | 0 |
| **Handwritten subtotal** | **+32 pipeline; +35 tests** | **+10** |

That is approximately **+107 / −30 = net +77**, with uncertainty of several lines. The worthwhile reduction is the smaller implementation surface and leaving 7a’s numerical path alone.

**Verification is additional.** Fable’s total omitted its specifications and reports. Allow roughly 10–20 lines per existing-runner specification: legacy, current-Dalton comparison, three NADI cases and an empty-mask case—approximately **80–100 specification lines**, depending on available reference runs. Generated reports add further document lines, whose actual count belongs in the final diff. They must not disappear from an “all-in” estimate.

**Assessment of Fable’s proposed parts**

| Part | Needed? |
|---|---|
| New `R/ice_fractions.R` and shared extraction functions | **No.** Script 7 can reuse its polygon consumer instead of acquiring 7a’s extraction algorithm. |
| Refactor script 7a | **No.** It brings numerical regression risk without enabling anything this route needs. |
| New test file | **No.** Extend the existing ice checks to inspect real saved products. Focused checks remain necessary. |
| README changes | **Yes.** Replace the script-7 input description and unconditional claim that its outlines come from the glacier shapes. |
| Changelog | **Yes.** One short entry: behaviour, unchanged legacy/7a paths, verification evidence. |
| Questions files | **Qualify the existing general question** about missing young outlines as Dalton-only. Do not close it. No new scientific question follows from this implementation. |
| Comments | Explain the source-dependent behaviour, inverse alias and hole mapping. Avoid another history of the ice work. |

**No duplicated code:** keep the ordinary `read_input(..., terra::rast)` call visible in each script. Likewise, one conventional band-name decoding expression does not justify an extraction abstraction. I would retain the same clear expression rather than disguise similarity with different spelling. Copying 7a’s band validation, reprojection and point-extraction routine would be substantive duplication; this route copies none of that routine.

**Findings**

These concern requirements missing from the proposed build, not an unseen implementation.

| Severity | File:line | What is wrong | Consequence | Evidence | Check; line effect |
|---|---|---|---|---|---|
| blocker | [7_plot_preds.R:203](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps/scripts/7_plot_preds.R:203), and the other ice layers | Existing grouping fills hole rings independently. | An ice-free cell can be painted as ice despite an NA flag. | Actual optimal mask at 8,000 BP encloses the cell at −67.5°, 63.5°, whose fraction is 0.42177345835. Holes occur in all three reconstructions. | Inspect that rendered hole and compare polygon membership with flags. Adds mapping setup; replaces eleven mappings. |
| blocker | [Fable review:35](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps/docs/cc/2026-11-20_ice_maps_design_review_fable.md:35) | Alternative C does **not** eliminate NADI plus `slice_alias`. | A legacy-derived NADI configuration can request a nonexistent 12,000 BP band. | Schema lines 220–225 permit the combination; NADI ends at 11,500 BP. | Run NADI with the legacy alias and verify the underlying 11,500 BP mask. Adds a few lookup lines. |
| should-fix | [7_plot_preds.R:277](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps/scripts/7_plot_preds.R:277) | Per-age pages select all ages. | NADI outlines and displayed tiles can represent different slices. | `year == year` compares the column with itself. | Inspect page data by age. About two net lines, NADI-only. |
| should-fix | [Fable review:94](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps/docs/cc/2026-11-20_ice_maps_design_review_fable.md:94) | Empty masks were dismissed pending a count at today’s threshold. | The valid threshold 1 can fail conversion or leave unusable empty tables. | Schema permits 1; every fraction is at most 1. | Run threshold 1: all flags NA, all outline tables correctly shaped and empty. Adds ordinary empty-result handling. |
| should-fix | [Design:81](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps/docs/cc/2026-11-20_ice_maps_design.md:81) | “Same ice as the forcing” is too broad. | The record promises agreement that the requested change does not provide. | `R/differences.R:52–59` adjusts fractions before classification; partial-ice forcing is not binary. | Say “selected file’s unadjusted fractions above the threshold.” Replaces wording; no code. |

**Right**

- Existing catalogue entries, configuration validation and manifest functions suffice. No new setting, path, schema rule or stale-input exception is needed.
- Script 9 masks **every non-NA flag** at line 378. Reusing `SYMB = 'ICE'` preserves the required character/NA contract.
- Script 8 consumes 7a’s differences; it does not consume script 7’s map products.
- Local read-only data inspection confirmed aligned one-degree grids and half-degree prediction-centre coordinates. Four centres lie outside NADI’s extent; their missing fractions must not become ice.
- The young NADI bands equal the 1,000 BP band, including missingness. At threshold 0.5 they contain 20, 19 and 110 ice cells for optimal, minimum and maximum respectively.
- No file was changed, and no R process or pipeline was started.

**Checks required before merge**

Use `tools/verify_change.R` at the implementation commit.

- **Legacy:** require all six files in `interp-tail-2026-09-21` and all four CSVs in `interp-forcing-2026-10-08` to match byte-for-byte. This includes script 9’s recovered slide-recipe table.
- **Current Dalton:** compare against unchanged-code outputs with today’s unaliased 11,500 BP configuration.
- **NADI:** compare saved coarse flags against direct raster values and saved outline membership, including holes. Exercise all three sources; include 200 BP in one verification configuration because the default coarse ages omit it. Include the legacy display alias and threshold 1.
- **Figures:** inspect the actual hole rendering and per-age pages. Table checks alone cannot prove rendering.
- **7a:** leave its source and inputs unchanged. The legacy run still checks its anchored output; no extraction-refactor comparison is needed.

The existing NADI verification specs skipped script 7 and copied old coarse differences. They cannot establish this feature.

**Risks of the smaller route**

Polygon conversion and point membership become the bridge between the raster rule and the existing code. The supplied grid alignment supports that approach, but the actual R conversion, fortification and rendering still need execution.

Native NADI fractions also retain double precision. Script 7a’s reprojection rounds them, as `tools/compare_ice.R:131–134` records. Casting the supplied values to single precision changed no classifications at 0.5, but another threshold extremely close to a fraction could differ. The proposed route follows the brief’s stored-fraction rule; it does not promise equality with every rounded or readvance-adjusted 7a classification.

**Questions for Chris**

None is needed to specify the behaviour requested here. This review recommends a reduced implementation; it does not authorize additions or settle Andria’s outstanding scientific choices.

**Not worth doing**

- Extracting 7a’s numerical input path or refactoring the completed comparison tool.
- Adding a map-source setting, configuration refusal or another band-validation framework.
- Replacing the plots with a new geometry system.
- Drawing every cell border merely to avoid handling holes.
- Changing Dalton’s anchored quirks or script 2’s calibration mask.
- Testing a pasted copy of the proposed algorithm instead of its actual outputs.

Three proposed additions were dropped from the build: extraction helpers, the 7a refactor and a separate helper-test file. Existing code provides the required route.

**Not checked**

No executable proof of byte identity, empty-table behaviour, polygon conversion or rendering was obtained. The ordinary prediction-summary file is absent from this checkout; coordinate inspection used the existing centre table.

The ten anchors cover scientific tables, not every figure or run manifest. Manifests contain changing run metadata; literal byte identity of every emitted file is therefore broader than the anchor contract.

No implementation diff or implementation commits exist to assess. Line counts remain estimates until a patch exists.

Files inspected: **55 across the review team, 30 by me**, some in excerpts; tool calls: **62 across the team**, including **57 read-only shell calls**.