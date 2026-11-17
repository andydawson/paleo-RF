**Verdict: ready after the relabel and saved-configuration fixes, with stronger verification checks.** The split arithmetic is correct, and the NADI geometry is defensible. I would not launch the five runs from the current build.

I reviewed `e951b2f..59a9a6f`. The checkout’s later `86a71e8` adds only the review brief. No files were changed, no R process was started, and nothing was downloaded or committed.

1. **The relabel changes the oldest mask and removes its difference-map outline.**  
   [config.R:103](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/config.R:103), [scripts/7_plot_preds.R:46](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/scripts/7_plot_preds.R:46), [line 116](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/scripts/7_plot_preds.R:116) and [line 377](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/scripts/7_plot_preds.R:377).

   Removing the alias selects the 11 ka polygon instead of the previous 12 ka polygon. The builder’s check finds **780 rather than 1,004 ice cells**: 224 fewer overall, with 228 cells changing classification. This changes the coarse differences and a freshly calculated historical EGU bar.

   There is also an unreported regression: `ice_fort` stores the requested age `11500`, but the oldest difference-map lookup asks for `11000`. It returns no outline.

   **Recommendation:** keep the requested 11.5 ka label while preserving the previous 12 ka polygon treatment for this narrowly scoped relabel. Restore the outline lookup under the requested age. Use one small local helper for the repeated polygon-selection rule; preserve legacy behavior.

   **Check:** under the default configuration, require the previous oldest mask and a nonempty oldest outline, with only labels changed. Keep the legacy outline hashes unchanged. The current replay cannot catch either problem because it copies script 7’s output and starts at 7a.

2. **Old saved configurations must remain loadable.**  
   [R/config_schema.R:178](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/R/config_schema.R:178), [R/config.R:60](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/R/config.R:60).

   The new required key breaks the existing hindcast, cover-contrast and cross-validation tools when they load earlier `config_used.R` files.

   **Recommendation:** one compatibility step in `load_config()`, before validation: when `analysis$ice` is a list and **the key is absent**, prepend `fraction_source = "dalton_ice"`. Prepending preserves the field order used by current configurations, which matters where tools compare settings with `identical()`.

   Do not replace an explicitly supplied `NULL` or invalid value. Do not rewrite saved configurations or add separate fallbacks to each tool.

   **Check:** load an actual historical configuration; preserve explicit NADI choices; continue rejecting `NULL` and invalid choices.

3. **The verification checks protect existing results better than the newly added results.**  
   [2026-11-17_ice-old-replay.R:20](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/docs/cc/verification/2026-11-17_ice-old-replay.R:20), [line 35](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/docs/cc/verification/2026-11-17_ice-old-replay.R:35) and [line 48](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/docs/cc/verification/2026-11-17_ice-old-replay.R:48).

   The replay correctly demands exact old columns and allows only the specified additions and relabel. But it does not establish the new columns’ values. The trial fake replay has zero-filled added columns and passes that check.

   Similarly, the formal specs run synthetic geometry tests but never reproduce the prepared rasters from the actual 66 snapshots. Their repeatability and conservation currently remain scratch evidence.

   **Recommendation:** add focused checks through `verify_change.R`:
   
   - Both new components sum to the existing total; the vegetation component follows the approved formula; the rules agree on nonadvancing pairs.
   - All three kernels and the saved period summaries preserve component additivity.
   - Rebuild the three rasters into the verification run’s own directory and compare their hashes with the committed inputs. The builder already exposes `OUT_DIR`; no new framework is needed.
   - Include the default-config mask/outline check from finding 1.

   **Check the checks:** a deliberately zeroed new vegetation column must fail. Regeneration must leave the tracked rasters untouched.

4. **“Ice-free at both slices” needs its spatial assumption stated.**  
   [R/differences.R:132](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/R/differences.R:132), [scripts/9_forcing_barplot.R:239](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/scripts/9_forcing_barplot.R:239).

   `1 - max(f_old, f_young)` gives the **smaller ice-free share**. It equals the actual area exposed at both dates only if the within-cell ice footprints are nested. Two disjoint half-cell ice footprints demonstrate the distinction: actual persistent exposure is zero, while this expression gives one half.

   **Recommendation:** retain Chris’s approved arithmetic and describe that assumption in the explanation and diagram. Do not add polygon-overlap calculations. This is an attribution convention, not a measured spatial intersection or a result established by fractional-mixing literature.

The arithmetic itself passes independent review. A Python reconstruction from the headline predictions and saved adjusted fractions covered **806,172 rows in 34,392 cell-month groups**:

| Check | Independent result |
|---|---:|
| Existing ten albedo-difference columns | Exact matches throughout |
| Rows where the two rules differ | 2,844, all advancing |
| Largest error in new vegetation + ice versus existing total | \(6.94\times10^{-18}\) |
| Largest error versus directly mixed endpoint albedos | \(2.22\times10^{-16}\) |

This independently verifies the arithmetic using the saved adjusted fractions; it does not independently regenerate those old fractions. Static review confirms their adjustment code and the twelve existing output columns remain unchanged.

[Script 8:145](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/scripts/8_radiative.R:145) correctly applies the factor of 100 for HadGEM3 and CAM5 and the negative CACK kernel. Script 9’s existing aggregation carries the new components through correctly. Legacy mode retains its original columns and excludes the new variants. Script 10 needs no arithmetic change.

**I accept the equal-area geometry departure, with a clearer statement of what is conserved.** Independent GDAL/geometry checks confirmed:

- All three rasters are **116 × 62 × 25**, with the old alignment and identical masks: **2,866 valid cells** per band.
- Fractions lie within `[0,1]`; 500, 200 and 50 BP equal 1,000 BP.
- There are **three open rings and twelve invalid features**, as reported. The longest source edge is **12.6648°**.
- Independent repair, union and projection reproduce the problematic 8.5 ka minimum area, **1,071,443.46366 km²**, and 6 ka optimal area, **374,563.553763 km²**.
- The ordering check reproduces **129 exceptions in 24 cells**, including **125 below `1e-4`** and the largest **0.00994732096** at 6 ka, 66.5°W, 67.5°N.
- The saved successful s2 comparisons support the claimed bound: maximum fraction difference **0.000721**, excluding the inverted 8.5 ka minimum.

Closing the rings, retaining holes, repairing invalid geometry and unioning overlaps are reasonable here. The convergence and area comparisons support the result. **Do not sort the three reconstructions to enforce ordering.**

There is a separate convention difference at [builder line 75](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/tools/build_nadi1_fractions.R:75) and [script 7a line 109](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/scripts/7a_alb_diff_full.R:109): the builder measures on the WGS84 ellipsoid, while the pipeline weights cells on the s2 sphere. Independent calculations give whole-mask ice totals **0.52–0.78% smaller** with the spherical weights. This is not the `0.0008` fraction discrepancy. Conservation is proved **within the builder’s convention**, not exactly under the later spherical weighting. Keep the pipeline’s existing weights for a clean replay and document the distinction.

The relevant precedent is:

- **Taylor, K. E. (2024), “Truly conserving with conservative remapping methods,” Geoscientific Model Development 17, 415–430, DOI 10.5194/gmd-17-415-2024.** Section 2 supports overlap-area weights and explicitly requires consistent areas; Appendix A discusses edge conventions and subdivision. It supports the calculation and checks, not this precise NADI repair policy. [Paper](https://gmd.copernicus.org/articles/17/415/2024/)
- **Brodzik, M. J., Billingsley, B., Haran, T., Raup, B. and Savoie, M. H. (2012), “EASE-Grid 2.0: Incremental but Significant Improvements for Earth-Gridded Data Sets,” ISPRS International Journal of Geo-Information 1, 32–45, DOI 10.3390/ijgi1010032.** It supports the equal-area projection family; NSIDC identifies its northern WGS84 projection as EPSG:6931. Include the **2014 correction, DOI 10.3390/ijgi3031154**. [Paper](https://www.mdpi.com/2220-9964/1/1/32/htm), [correction](https://www.mdpi.com/2220-9964/3/3/1154), [NSIDC](https://nsidc.org/data/user-resources/help-center/guide-ease-grids)

The 0.01° step, repair choices, young carry-forward and component attribution remain documented project choices. I invoked the installed reference checker, but registry access failed; the primary publication pages and supporting passages were inspected. A completed registry audit cannot be claimed.

**The comparison tool is sound, but its readvance counts need qualification.** It reads saved forcing and adjusted fractions; it does not copy pipeline forcing arithmetic. Independent CSV checks reproduced all 21 old total rows and 14 component rows exactly, and found unique inventory keys. The old counts are **186 raw, 228 adjusted, 75 created**; NADI raw counts are **142 optimal, 35 minimum and 231 maximum**.

At [tools/compare_ice.R:187](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/tools/compare_ice.R:187), every strictly positive change counts. Of the NADI counts, **38, 5 and 20**, respectively, are below `1e-6`. That threshold is merely a diagnostic here, not a proposed new method.

These tiny changes can trigger large adjustments under [R/differences.R:47](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/R/differences.R:47). For maximum at 86.5°W, 46.5°N:

| Age | Raw fraction |
|---|---:|
| 11 ka | 0.5724659562 |
| 10.5 ka | 0.5724661946 |
| 10 ka | 0 |

The tiny increase makes averaging replace the middle fraction with **0.2862329781**. Independent source-polygon clipping confirms the tiny change exists in the source coordinates; it is not simply a rasterization error.

For complete periods, changes at internal slices cancel from total endpoint forcing, although attribution can change. The material coarse-boundary cases identified here reduce ice area by about **41.84 km²** at **10 ka in minimum** and **8 ka in maximum**.

**Keep the averaging Chris chose.** Report these cases and describe the counts as exact positive coverage differences, not counts of established physical readvances. Do not introduce a tolerance or reopen the deferred no-averaging experiment through this implementation.

I inspected all five figures. Their structure and units are useful. One small correction at [tools/compare_ice.R:247](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/tools/compare_ice.R:247): the old raster’s young carried-forward values are currently shown as “snapshot of the slice’s own age.” Correct that legend treatment. The trial forcing figure contains only old ice; the final comparison must use the replay with both splits and all three NADI runs.

Every implementation commit is accounted for:

| Commit | Assessment against the agreed scope |
|---|---|
| `2389503` | Builder and tracked inputs supplied; projection departure acceptable with the qualification above |
| `b2ed943` | Selector and path plumbing correct; saved-config compatibility missing |
| `4daacbc` | Both splits implemented correctly; legacy arithmetic preserved |
| `f00e0b8` | Correct forcing relabel; unintended script-7 mask and outline changes need fixing |
| `8d819f5` | Required comparison tables and figures supplied without copied forcing arithmetic |
| `c99cafd` | Six appropriate specs; strengthen new-output and real-builder checks |
| `460d9eb` | README and implementation account supplied; qualify conservation and readvance interpretation |
| `795fcd4` | Eight-thread settings follow the regression contract |
| `59a9a6f` | Wording corrections only |

No unnecessary readvance switch or premature NADI default was added. The GitHub issue and independent Fable/change-reviewer evidence remain outstanding according to the builder’s account; this review does not replace those.

**The five forcing runs can run side by side after the changes.** The legacy spec is correct: it regenerates script 7 onward and checks all six tail files and four forcing-summary anchors. The replay is appropriately strict about existing outputs, but should be described as proving the forcing-stage replay, not an unchanged fresh default pipeline.

Launch the verifier from the data-bearing checkout, `/home/expert/Documents/contracting/Andria/paleo-RF`, using absolute spec paths, or pass that checkout explicitly as `main`. This ice worktree lacks most frozen inputs. The data-bearing checkout has all 331 inventoried paths, and the headline and legacy prediction hashes checked correctly.

Fill every `TO_FILL` with the same final code commit. Let the first verification enter its first pipeline script before starting the other four, so shared worktree creation and input linking are finished. Keep distinct run names and disjoint eight-core allocations. Run the meeting comparison after its four input runs pass.

For simplicity, **cut the repeated comparison/figure generation from the three NADI specs** and perform it once in the final comparison. Keep focused numerical checks in each run. No geometry abstraction, configuration-migration framework or ordering repair is needed. Two speculative suggestions for extra geometry validation/provenance machinery were dropped because they did not correct an observed defect.

**Final verdict: ready after these named changes, in order:**

1. Preserve the previous oldest polygon treatment under the 11.5 ka label and restore its difference-map outline.
2. Add the single missing-key compatibility fallback in `load_config()`.
3. Strengthen verification for the new components, default script-7 behavior and actual raster regeneration.
4. Clarify the nested-footprint assumption, the two area conventions and tiny-increase behavior; correct the young-slice legend.
5. Complete the required issue/reviews, fill the final commit, then launch from the data-bearing checkout.

Two decisions for Chris, answerable directly:

- **Keep the previous 12 ka polygon on the map now labelled 11.5 ka, so this remains a label-only change?** I recommend **yes**; choosing a different polygon should be a separate scientific change.
- **Accept EPSG:6931 fractions while retaining existing spherical forcing weights, with the approximately 0.5–0.8% area-convention difference documented?** I recommend **yes**.