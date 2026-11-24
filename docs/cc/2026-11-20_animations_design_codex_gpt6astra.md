# Holocene animations: design and prototype rounds (Astra, 20 November 2026)

*What this is: the reports of the three design-and-build rounds of the animations Chris asked for. Who wrote
them: Astra (Codex, gpt-6-astra, reasoning effort ultra), working in the `animations` worktree, from the brief
`2026-11-20_animations_astra_brief.md`. Filed unchanged below. Chris then chose the natural vegetation colours, the
cool blue-grey albedo scale and rose for missing cells; the main session switched the albedo scale (one line).*

## Round 1: design and first prototype

Built the **[25-frame animation](animations/holocene_shared_clock.gif)**: three synchronized maps showing ice, vegetation composition and April surface albedo. It runs for **25 seconds**.

**Time resolution**

| Source | Finest available time information | File evidence |
|---|---|---|
| Vegetation | 500-year pollen bins over 11,700–700 BP, followed by bins of 350, 250 and 174 years. | `lct_paleo_reveals_interp.RDS`: `ages` contains 25 labels, 11,500…1,000, 500, 200, 50 BP. |
| Old ice raster | Stored bands every 500 years from 12,000–500 BP, then 200 and 50 BP. These are already interpolated; their construction method remains undocumented. | **26 bands**, `yr12000bp`…`yr50bp`; the analysis uses 25. I checked that 500, 200 and 50 exactly repeat 1,000 BP. |
| NADI-1 | Dated snapshots every **500 years**, 25,000–1,000 BP. No younger independent reconstructions. | 49 shapefiles each for OPTIMAL/MIN/MAX, including `11.5ka_cal_OPTIMAL_NADI-1_Dalton_etal_QSR.shp`. Prepared rasters contain 25 bands; 500/200/50 repeat 1,000 BP. |
| Older glacier outlines | **1,000-year steps**, 21,000–1,000 BP. | `glacier_shapefiles_21-1k.RDS` contains 21 unnamed elements; script 7 supplies their ages. |
| Albedo | The same 25 pollen intervals, with **12 monthly predictions per interval**. | Prediction RDS columns `year`, `month`, `alb_mean`; all twelve months are present at every slice. |

The 150-year separation between labels 200 and 50 does **not** establish 150-year observational resolution. Likewise, monthly albedo describes a modelled seasonal cycle within a reconstructed state, not monthly Holocene observations.

Every frame gives the pollen interval explicitly. The youngest is **100 to −74 BP: 1850–2024 CE**, correcting the brief’s 2020 parenthesis. The definitions follow Dawson et al. (2025), DOI **10.5194/cp-21-2031-2025**, §2.2, as recorded in the [existing local reference check](docs/cc/2026-11-16_time_bins_codex_gpt6astra.md). NADI’s snapshot spacing and carry-forward convention are documented in its [provenance](data/nadi1_fractions/nadi1_fractions_provenance.txt).

Interpolating frames would make playback smoother but add assumed intermediate states—not observations, dated margins or evidence of when events occurred within a bin. This prototype adds no between-frame interpolation.

**Design comparison**

| Design | Strengths and weaknesses | Timing |
|---|---|---|
| **Recommended: ice ‖ vegetation mixture ‖ albedo** — [still](animations/frames/frame_08_08000BP.png) | Spatial comparisons stay aligned. The triangle represents all ET/OL/ST fractions, although reading exact fractions takes practice. | One shared clock, 25 discrete states; repeated younger ice is labelled. |
| **A: separate subjects, with ET/OL/ST maps** — [still](animations/alternative_A_components.png) | Easiest quantitative reading of vegetation; needs more space and makes simultaneous comparisons harder. | Separate movies could respect their own clocks: 500-year NADI snapshots for ice, pollen bins for vegetation/albedo. |
| **B: vegetation with a white ice veil ‖ albedo** — [still](animations/alternative_B_combined.png) | Compact landscape view. Partial ice lightens vegetation colours, making composition harder to decode. | Same discrete pollen states; veil opacity changes only with available ice fractions. |

I recommend **one fixed month initially—April**—so seasonal variation does not compete with Holocene change. An annual mean would suppress seasonal structure and require an explicit weighting convention. Cycling through twelve months is possible, but introduces a second clock.

The prototype uses the **old ice raster**, matching the supplied verified run, with an additional **[old versus NADI-1 comparison still](animations/ice_sources.png)**. Surface albedo is the requested `f × 0.68 + (1 − f) × alb_mean`. It uses **unadjusted** fractions: subtracting movie frames need not reproduce the forcing differences after their readvance adjustment. The fixed 0.68 remains the project’s assumption.

**Files and execution**

The script reuses the existing boundary/window and triangle helpers. R renders every map; installed PIL packages the PNGs into a GIF using one common palette. Nothing was installed.

From this worktree:

```bash
TMPDIR="$PWD/animations" CORES=32-47 THREADS=2 \
  tools/rscript.sh tools/animate_holocene.R > animations/render.log 2>&1
```

Final measured runtime: **144.87 seconds**, including GIF assembly.

| Created file(s) | Lines | Dimensions / size |
|---|---:|---|
| [tools/animate_holocene.R](tools/animate_holocene.R) | 191 | One script |
| `animations/.gitignore` | 1 | 2 bytes |
| [animations/render.log](animations/render.log) | 201 | 10,592 bytes |
| `animations/holocene_shared_clock.gif` | N/A—binary | 1800×900; 3,416,470 bytes |
| `animations/alternative_A_components.png` | N/A—binary | 1800×1200; 430,222 bytes |
| `animations/alternative_B_combined.png` | N/A—binary | 1440×960; 261,070 bytes |
| `animations/ice_sources.png` | N/A—binary | 1440×720; 199,540 bytes |
| 25 frame PNGs, enumerated below | N/A—binary, each | Each 1800×900; 315,273–318,180 bytes; total 7,913,183 bytes |

Each entry below names `animations/frames/frame_<entry>BP.png`:

```text
01_11500  02_11000  03_10500  04_10000  05_09500
06_09000  07_08500  08_08000  09_07500  10_07000
11_06500  12_06000  13_05500  14_05000  15_04500
16_04000  17_03500  18_03000  19_02500  20_02000
21_01500  22_01000  23_00500  24_00200  25_00050
```

That is **32 files total**. Parsing, PNG integrity, frame order, GIF frame count/timing and representative visual checks passed. Two independent static reviews informed the final corrections.

Formal `verify_change.R` verification remains for the main session: it requires a committed revision and writes outside this permitted worktree. Fable review and MP4 export were not performed. Existing files were unchanged; no commits, pushes or branch changes were made. The `animations` branch awaits your design choice and the main session’s integration.

The choices for the next iteration are **shared clock, component maps or combined veil**, then **April versus another month/seasonal cycle**, and **old ice versus NADI-1**.
## Round 2: blended frames

Built **49-frame, 25-second animations for all three designs**:

- **[Shared clock prototype](animations/blended/shared_clock.gif)**
- [A: separate component maps](animations/blended/components.gif)
- [B: combined vegetation/ice view](animations/blended/combined.gif)

Each midpoint averages the **ice fraction, ET/OL/ST fractions and predicted vegetation albedo**. Surface albedo is then recalculated from those inputs, keeping the existing mixture formula consistent. Missing endpoint values propagate; there is no one-sided filling.

Original frames retain their ages and pollen bins. Blends explicitly name both slices and source bins. The clock marks all 25 source slices, with a blue source marker or orange blend marker.

Timing follows nominal age differences:

| Interval | Total transition | Each half-step |
|---|---:|---:|
| 500 years | 1,000 ms | 500 ms |
| 500→200 BP | 600 ms | 300 ms |
| 200→50 BP | 300 ms | 150 ms |

A final **2.1-second pause** brings each loop to 25 seconds.

The full-ice rule is enforced in one shared calculation: **ice fraction 1 gives 0.68 regardless of vegetation; partial ice with missing vegetation remains missing**. Checking the reported gaps showed that all 111 fully icy cells at 8,000 BP already had 0.68. The sampled Hudson Bay gaps have **missing ice fractions**, so they remain outside the input footprint rather than receiving invented ice values.

I also caught and fixed a cell-ordering error in the joins. All 24 midpoint calculations now match independent joins by coordinates. The rendered ice panel is identical throughout 1,000→50 BP, including blends.

The final build took **847.43 seconds—14 minutes 7 seconds**. An earlier 805.01-second render was replaced after that alignment check.

All outputs are under `animations/blended/`:

| Design | Dimensions | PNG frames: count; total bytes | GIF bytes |
|---|---|---:|---:|
| Shared clock | 1800×983 | 49; 15,908,046 | 6,751,900 |
| A: components | 1800×1284 | 49; 20,728,159 | 8,873,118 |
| B: combined | 1440×1044 | 49; 13,074,696 | 5,659,131 |

PNG and GIF line counts are **N/A—binary**. The **[complete file inventory](animations/blended/file_inventory.tsv)** lists every filename individually, with its line count, exact byte size and dimensions: the updated script and **153 generated files**.

| Text file | Lines |
|---|---:|
| [tools/animate_holocene.R](tools/animate_holocene.R) | 231 |
| [frames.csv — frame order and timing](animations/blended/frames.csv) | 50 |
| [render.log](animations/blended/render.log) | 753 |
| `file_inventory.tsv` | 155 |

Run from the worktree:

```bash
mkdir -p animations/blended
TMPDIR="$PWD/animations" CORES=32-47 THREADS=2 \
  tools/rscript.sh tools/animate_holocene.R > animations/blended/render.log 2>&1
```

All 147 PNGs passed integrity checks. Each GIF contains 49 frames with the exact intended timings and a common palette. No packages were installed or git changes committed. Formal `verify_change.R` verification remains with the main session.

Chris’s choices remain open: **layout, month, ice source**, and whether the faster young-end playback needs slowing. April and the old ice raster remain the provisional settings.
## Round 3: Chris's choices

Built the revised [shared-clock GIF](animations/nadi_shared/holocene_nadi_april.gif): **49 frames, 25 seconds, April albedo and NADI-1 best-estimate ice**. Titles and footnotes are removed; explanations are in the [caption](animations/nadi_shared/caption.txt).

The palette comparisons show identical 8,000 BP data:

- [Vegetation options](animations/nadi_shared/vegetation_palettes_08000BP.png): recommended dark evergreen, light summergreen and ochre open land; alternative blue, green and orange. The natural colours are more intuitive, but neither three-way mixture is fully colour-blind safe.
- [Albedo options](animations/nadi_shared/albedo_palettes_08000BP.png): recommended charcoal–ivory; alternative cool blue-grey–ivory. Both brighten with increasing albedo. The neutral scale avoids dependence on hue.

The GIF uses both recommendations, with fixed scales and rose-coloured missing cells.

NADI-1 changes **355 cells at 8,000 BP**: 248 have more ice and 107 less. For example, at 65.5°W, 56.5°N, surface albedo rises from 0.535 to 0.680. At 67.5°W, 64.5°N, adding ice lowers it from 0.820 to 0.680 because the April vegetation prediction is brighter than the assumed ice. The [cell comparison CSV](animations/nadi_shared/ice_source_changes.csv) records every changed cell at every source slice.

The raster mask is unchanged, including masked Hudson Bay waters. Full ice remains 0.68 without vegetation predictions; partial ice without predictions remains missing. Consequently, some cells become missing when NADI changes them from full to partial ice.

Blends still average ice, cover fractions and **vegetation** albedo, then recalculate surface albedo to preserve the mixture formula. The clock marks real slices and labels blends. Timing remains proportional: 500-, 300- and 150-year gaps take 1.0, 0.6 and 0.3 seconds, followed by a 2.1-second final hold. The young end is quick for inspecting individual vegetation changes; ice itself is unchanged after 1,000 BP.

| Image output | Dimensions | Size |
|---|---:|---:|
| GIF | 1800 × 768 | 6,324,396 bytes |
| 49 frame PNGs | 1800 × 768 each | 14,758,657 bytes total |
| Vegetation comparison | 1440 × 804 | 252,182 bytes |
| Albedo comparison | 1440 × 720 | 239,150 bytes |

Individual frames range from **299,629–303,628 bytes**. Images have no meaningful line count.

| Text/code file | Lines |
|---|---:|
| [tools/animate_holocene.R](tools/animate_holocene.R) | 223 |
| `caption.txt` | 8 |
| `frames.csv` | 50 |
| `ice_source_changes.csv` | 6,892 |
| `render.log` | 363 |
| `file_inventory.tsv` | 59 |

The [inventory](animations/nadi_shared/file_inventory.tsv) lists **all 58 files individually**, with line counts, dimensions and exact byte sizes.

Successful rendering, including comparisons and GIF assembly, took **232.24 seconds**. Coordinate alignment, all midpoint calculations, missingness rules, PNGs and GIF timings passed checks. PIL assembled the R-rendered frames; nothing was installed.

Run from the worktree:

```bash
TMPDIR="$PWD/animations" CORES=32-47 THREADS=2 \
  tools/rscript.sh tools/animate_holocene.R
```

No tracked pipeline files changed and no commits were made. Formal separate-worktree verification remains for the main session. The only open choice is whether Chris prefers either alternative palette.