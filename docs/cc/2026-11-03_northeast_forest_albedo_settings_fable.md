*Fable (science-reviewer role), 3 November 2026: the settings Chris asked Fable to set for the northeast
forest-albedo check (issue #27). Read-only; no web access. Astra checked these settings
(`2026-11-03_northeast_forest_albedo_settings_check_codex_gpt6astra.md`) and Chris froze Astra's final table
(`2026-11-03_northeast_forest_albedo_settings.md`). Recorded here as Fable gave them, condensed to the substance.*

**Verdict.** Settings can be fixed now; one change to the approved design: with full inversions (`full_75`) the winter
months have almost no pixel with five qualifying days in this region, so the winter panels must come from `any_75`,
fixed now, or there will be no winter check.

**Hand check.** May pair: DBF n_all 12, n_snow 0, n_free 12, s_free 1.68; ENF n_all 12, n_snow 2, n_free 10,
s_free 0.95, s_snow 0.60. Ratio 1.0 passes. All-days +0.0108; snow-free +0.045 (x 0.18 = +0.0081); snowy: DBF
n_snow 0 < 5, absent. Snow-share difference -0.17, reported, not filtered. Weighting: one cell with 1 pair at +0.02
and one with 50 at +0.06: 0.040 by cell, 0.059216 by pair. In the sinusoidal grid at 44 N, 73 W, pixels in the same
column are 619 m apart on the ground, so distance must be great-circle from `pixel_lonlat`.

**Data facts** (`data/albedo_modis_cells.csv`, cells at 72.5 W, 41.5-47.5 N): January `full_75` coverage 0.01-0.32,
days 0.06-2.9; `any_75` coverage 0.63-0.98, days 9.5-25. April `full_75` coverage 0.62-0.91, days 5.4-19.3. July
`full_75` coverage 0.53-0.93, days 6.4-12.9. The box holds 83 pipeline cells, 29 south of 44 N and 54 north.

**Settings (main | stricter | looser | adjustable after the coverage run).**

| Setting | Main | Stricter | Looser | Adjustable |
|---|---|---|---|---|
| Forest classes | `LC_Type1` 1 (ENF) vs 4 (DBF); 5 never | - | - | No |
| Label stability | same class all 9 years, centre | - | - | No |
| Neighbourhood | 3x3 same class every year | 5x5 every year | 3x3 same in >= 7 of 9 years | Yes, step 5 |
| Classification quality | `QC` = 0 all 9 years | - | - | No |
| Water | centre passes `is_land`; no MOD44W water under the 3x3 | 5x5 | centre's own 2x2 | No |
| Woody-wetland strata | `LC_Prop3` = 27 in any year flags a member | no 27 anywhere in either 3x3 | 27 in >= 5 of 9 years | No |
| Pair elevation difference | <= 50 m | 25 m | 100 m | Yes, step 3 |
| Local relief | 3x3 GMTED range <= 100 m | 50 m | 200 m | Yes, step 2 |
| Pair distance | nearest DBF within 5 km great-circle | 3 km | 10 km | Yes, steps 1 and 4 |
| Replacement | DBF reuse allowed | mutual nearest only | - | No |
| Albedo version | `full_75` Mar-Oct; `any_75` Nov-Feb, labelled | `full_75` only | `any_75` all months | No |
| Minimum days | 5 on the panel's own count | 8 | 3 | No |
| Count ratio | min/max of n_all >= 0.7 | 0.8, and 0.7 on own counts | 0.5 | No |
| Aggregation | pairs, cell-year, cell, equal cells; pair-weighted beside | cell-year >= 3 pairs | = main | No |
| Reporting threshold | >= 30 pairs from >= 3 cells | 50 / 5 | 10 / 2 | No |
| Precision target | +/-0.02 per unit cover exchanged | 0.01 | 0.05 | No |

**Adjustment rule proposed** (not adopted: Astra advised against it and Chris froze no automatic relaxation): triggers
>= 300 pairs and >= 30 of 83 cells with >= 3 pairs; else relax distance 5 -> 7.5 km, relief 100 -> 150 m, elevation
50 -> 75 m, distance 7.5 -> 10 km, homogeneity 9 -> 7 of 9 years, in that order; then ask Chris.

**Which settings matter for the sign:** the water screen and wetland strata, class purity, and the snow-panel count
rules (canopy-hidden snow biases both snow panels toward negative; the all-days panel is free of it); the albedo version
decides whether winter exists. Distance, elevation, relief, days, ratio and aggregation mostly affect the size.

**Not verified by Fable (no web):** MCD12Q1 code values, the footprint overlap, GMTED accuracy and the MCD43
per-retrieval error, given from memory; Astra verified the product codes against the MCD12Q1 guide.
