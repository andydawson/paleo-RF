# Northeast forest-albedo check: the frozen settings (3 November 2026)

*Issue #27. Chris did not know how to choose the numerical settings of the approved design
(`2026-11-03_northeast_forest_albedo_design_v2_codex_gpt6astra.md`) and asked Fable to set them; then asked Astra to
check Fable's settings; then froze Astra's final table (below), before any data are read. Fable's settings and
Astra's check are filed beside this file (`..._settings_fable.md`, `..._settings_check_codex_gpt6astra.md`).*

**Decisions (Chris, 3 November).**
- **Albedo version:** `full_75` (full inversions, noon sun within 75 degrees) is the result in every month in which it
  qualifies, as for the rebuilt albedo (Chris, 20-22 October), following NASA's guidance and the validation literature
  (Cescatti et al. 2012 used full inversions only). `any_75` (magnitude inversions included) is shown beside it all
  year, labelled lower quality, and supplies the winter interpretation only as supplementary evidence: at 500 m, most
  northeastern pixels have under three full-inversion days a year in January. What Andria's raster used is asked of her.
- **Elevation matching:** 50 m with the 1 km GMTED2010 on disk; a finer elevation model later only if needed.
- **No automatic relaxation:** if the coverage-only run (forest map, elevation, water and retrieval counts; no albedo
  value read) misses the feasibility targets, it comes back to Chris before any contrast is read.

## The frozen settings (Astra's final table)

| Setting | Main value | Stricter check | Looser check |
|---|---|---|---|
| Contrast | DBF minus ENF; albedo on 0–1 scale | Fixed | Fixed |
| Period and footprint | 2001–2009; ENF centres in the 83 pipeline cells within 80–66°W, 40–48°N | Fixed | Fixed |
| Forest classes | `LC_Type1` 1 versus 4; mixed forest excluded | Fixed | Fixed |
| Centre stability | Same class in all nine years, both members | Fixed | Fixed |
| Neighbourhood | Entire 3×3 same class in every year | 5×5 every year | Entire 3×3 same class in ≥7 years; centre still stable all nine |
| Classification QC | Centre `QC=0` in all nine years, both members | Fixed | Fixed |
| Land/water | Both centres pass record-wide `is_land`; all 36 aligned MOD44W-2015 subpixels beneath each 3×3 explicitly land | All 100 beneath 5×5 land | Centre’s own four subpixels land |
| Wetland strata | Centre `LC_Prop3=27` in any year flags member; neither/one/both reported; missing flags never silently called unflagged | Separate unflagged subset with no flag anywhere in either 3×3 | No alternative flag definition |
| Elevation source | Native GMTED2010 30-arc-second mean cell containing each centre; retain native georeferencing | Fixed | Fixed |
| Pair elevation difference | **≤50 m** | ≤25 m | ≤100 m, diagnostic only |
| Local relief | Each centre’s containing GMTED cell and eight neighbours: range ≤100 m; complete valid neighbourhood required | ≤50 m | ≤200 m |
| Pair distance | Nearest eligible DBF within **5 km great-circle distance**; exact ties by fixed pixel ID | 3 km | 10 km |
| Boundary handling | Complete search and neighbourhood coverage; count excluded boundary centres. No silently truncated searches at 40°N | Apply same rule to chosen radius | Apply same rule to chosen radius |
| Replacement | DBF reuse allowed; report unique partners and reuse distribution | Reciprocal nearest-pair subset as a **separate diagnostic** | Same as main |
| Albedo versions | `full_75` and `any_75` reported separately throughout; `any_75` supplies supplementary Nov–Feb interpretation | Existing `full_70`, separately | No additional version |
| Minimum days | Both members ≥5 days on that panel’s own count | 8 | 3 |
| Count ratio | `min(n_all)/max(n_all) ≥0.7`, within pair/year/month/version | ≥0.8 all-days and ≥0.7 own-panel | ≥0.5 all-days |
| Snow panels | Corresponding `s_all/n_all`, `s_free/n_free`, `s_snow/n_snow`; unknown share and DBF−ENF snow-share difference reported, never filtered | Fixed | Fixed |
| Aggregation | Pair mean → cell-year mean → equal-year cell mean → equal-cell mean; alongside mean of all eligible pair-year contrasts | Cell-year requires ≥3 pairs | Same as main |
| Coverage display | ≥30 distinct pairs across ≥3 cells: “coverage threshold met”; otherwise “thin”; always show unique DBFs and years | 50/5, display only | 10/2, display only |
| Latitude | Eight one-degree bands and 40–44°N/44–48°N halves, assigned by ENF cell | Fixed | Fixed |
| Sign agreement | Nonzero equal-cell and pair-weighted means agree; ≥⅔ contributing cell means share sign; assess represented strata separately | Fixed | Fixed |
| Precision target | ±0.02 as a practical target, **not a claimed uncertainty interval** | No alternative | No alternative |
| Feasibility targets | ≥300 distinct structural pairs; ≥30 cells with ≥3 pairs; separately report southern cells, with <5 raised to Chris | Fixed | Fixed |
| Adjustment after coverage | **None automatically.** Failure prompts review before contrasts are read | — | — |

The all-stricter and all-looser bundles can remain **joint stress tests** using neighbourhood, water, elevation, relief, distance, days, ratio and cell-year eligibility. An unchanged bundled sign does not prove insensitivity to each component: opposing changes can cancel. Any subsequent one-at-a-time runs must be labelled diagnostic and cannot redefine the headline result.

