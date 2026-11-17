**Use one configuration setting to select the ice-fraction file, and let the existing pipeline calculate the forcing.** This gives Andria a direct comparison of the reconstructions while holding vegetation predictions and the forcing method fixed.

Build NADI-1 optimal, minimum and maximum fractions once, as small rasters matching the old input. For the meeting, rerun the forcing stages for **old ice and NADI-1 optimal**, using the saved headline predictions. The old run verifies that introducing the setting changes nothing; the NADI run measures the reconstruction’s effect.

**Keep today’s readvance averaging for this comparison.** Its consequences can be shown by comparing raw fractions with the adjusted fractions already saved by script 7a. Readvances do not break the partial-ice total, so answering that question needs diagrams and arithmetic checks, not additional forcing runs. Retain today’s vegetation/ice attribution.

This requires five small edits to existing configuration and pipeline files, one data-building script and one comparison script. No forcing arithmetic needs moving or duplicating. Each headline forcing-stage run should take approximately **68–77 minutes**, dominated by script 7a. Minimum and maximum forcing runs can follow if Chris wants that additional comparison.

**1. Add one setting that uses the existing path catalogue.**

In `analysis$ice`, add:

```r
fraction_source = "dalton_ice"
```

Accept four values:

| Setting | Input |
|---|---|
| `"dalton_ice"` | Existing Dalton raster |
| `"nadi1_optimal"` | Prepared NADI-1 optimal fractions |
| `"nadi1_minimum"` | Prepared NADI-1 minimum fractions |
| `"nadi1_maximum"` | Prepared NADI-1 maximum fractions |

Use these names directly as path-catalogue entries. Script 7a’s read becomes:

```r
ice_fractions = read_input(
  run,
  path_file(paths, cfg$analysis$ice$fraction_source),
  rast
)
```

This fits the existing manifest system: inputs must be catalogued, and the selected file’s checksum and analysis settings are recorded. An unrestricted filename would require more changes because `producer()` currently rejects uncatalogued files. See [R/paths.R](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/R/paths.R:188).

The five existing files to edit are:

- `config.R`: add the setting, initially selecting Dalton.
- `configs/legacy_config.R`: explicitly select Dalton.
- `R/config_schema.R`: validate the four choices.
- `R/paths.R`: add three prepared-input entries.
- `scripts/7a_alb_diff_full.R`: select the input, use neutral local names, and check that every prediction age has exactly one matching band.

The last check matters because [script 7a](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/scripts/7a_alb_diff_full.R:51) reads every age present in the prediction table before forming the configured pairs.

**Do not add a readvance setting for the meeting.** Raw readvance timing, averaging artefacts and formula validity can all be established without it. These runs will measure the ice-source effect under the current averaging; they will not measure the forcing effect of removing averaging.

If Chris requests that additional experiment, its smallest implementation is one Boolean, `average_readvances`, passed to `pair_albedo_differences()`, with the existing substitution inside a plain `if`. Its legacy value would remain `TRUE`. That is a separate scientific option requiring review.

**2. Build three NADI-1 rasters once.**

Add `tools/build_nadi1_fractions.R`, following the project’s stand-alone data-building practice. Keep its small geometry function inside that script; there is no second caller requiring a shared module.

Use the old raster as the spatial template. Inspection confirmed:

- 116 × 62 cells, one-degree spacing, WGS84;
- 26 existing bands, including 12,000 BP;
- the same missing-value mask in every band;
- 2,866 valid raster cells.

Write **25 bands**, one for each pipeline age, named `yr50bp`, `yr200bp`, and so forth through `yr11500bp`. The unused 12,000 BP band is unnecessary.

For each reconstruction and age, calculate

\[
f_{i,t}=\frac{\operatorname{area}(C_i\cap P_t)}
                  {\operatorname{area}(C_i)},
\]

where \(P_t\) is the union of that age’s ice polygons.

The builder should:

1. Validate the polygons, preserve holes and union overlapping features.
2. Use the existing cell boundaries and the same WGS84 `sf` area convention as script 7a. Calculate numerator and denominator with the same geometry engine.
3. Preserve the old raster’s extent, alignment and missing-value mask. A valid polygon dataset with no overlap means zero ice; a missing file or failed geometry is an error.
4. Use whole-cell area, consistent with the present forcing calculation.
5. Match the 22 NADI ages from 1,000 to 11,500 BP directly, then copy the 1,000 BP fractions into 500, 200 and 50 BP.
6. Write compressed double-precision GeoTIFFs and a provenance note.

This preserves the existing **2,655 forcing cells**, including the exclusion of the two western prediction cells outside the old raster’s support.

Check fractions, band names, mask, extraction at prediction locations, young-band equality and conservation:

\[
\sum_i f_{i,t}\operatorname{area}(C_i)
=
\operatorname{area}\!\left(P_t\cap\bigcup_i C_i\right).
\]

Check minimum–optimal–maximum ordering and report any failures; do not repair them by sorting the values.

**Track the prepared rasters and provenance in ordinary Git.** Each raster contains about **1.44 MB of values before compression**; the existing Dalton TIFF is only 56 KB. Measure the resulting sizes, but these are small prepared inputs. Keep the approximately 128.5 MB download and unpacked source collection untracked.

Tracking also solves a practical verification problem: detached verification worktrees automatically receive tracked files, whereas the verifier links untracked inputs only when they are in its frozen-input inventory.

The provenance note should identify the dataset DOI/version, source checksums, builder version, template checksum, age mapping, carry-forward rule, geometry settings and output checksums. Use public source references and repository-relative paths.

**3. Run the existing forcing stages from the saved headline products.**

For each meeting setting, use a dated `tools/verify_change.R` spec at the exact implementation commit.

Copy these two files from the saved headline run:

- `output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS`
- `data/alb_interp_preds_diffs_bluesky.RDS`

Use the verifier’s **`copy` argument**, with source paths resolved before execution. Its ordinary `seed` argument selects historical baseline products, not the saved headline predictions.

Start from the headline analysis settings, retain its recorded simulation seed, and change only `fraction_source`. The verifier already sets and records `run$allow_stale = TRUE` for copied products. No manifest or verifier redesign is needed.

Run:

```text
7a_alb_diff_full.R
8_radiative.R
9_forcing_barplot.R
10_forcing_breakdown.R
```

Script 10 is inexpensive and provides an existing consistency check against script 9.

The coarse-difference file is needed because [script 9](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/scripts/9_forcing_barplot.R:362) always produces its historical EGU-recipe comparison. That particular output retains the old polygon treatment; exclude it from the NADI comparison. The ordinary period totals and variant-sensitivity tables use the newly calculated forcing.

| Run | Purpose | Approximate cost |
|---|---|---:|
| Old ice, headline predictions | Verify unchanged results after adding the selector | 68–77 min |
| NADI-1 optimal, same predictions | Main meeting comparison | 68–77 min |
| NADI-1 minimum | Optional reconstruction sensitivity | Another 68–77 min |
| NADI-1 maximum | Optional reconstruction sensitivity | Another 68–77 min |

The saved headline measured **76.0 minutes for 7a, 0.4 for 8, 0.6 for 9 and 0.3 for 10**. These are reference timings, not promised NADI runtimes. [Verification report](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/docs/cc/verification/2026-11-02_run1-main_report.md:19)

Require the old-input replay to reproduce the saved headline differences, forcing and summary tables **byte for byte**. Check copied-input checksums and identical output keys and support.

My recommendation is **optimal first**. Build minimum and maximum fractions for the spatial comparison, but defer their forcing runs. If run later, describe them as three reconstruction outcomes: minimum and maximum ice extent need not produce minimum and maximum forcing, and their spread is not a confidence interval.

**4. Make three tables and five slide figures with one small comparison script.**

Add `tools/compare_ice.R`. It reads the fraction files, saved adjusted endpoint fractions and pipeline forcing summaries. It does not calculate albedo changes, multiply kernels or reproduce period aggregation.

| Table | Contents |
|---|---|
| Ice by slice | Source, age, raw ice area on fixed support, NADI-minus-old difference; minimum and maximum for context |
| Readvance inventory | Cell/location, older and younger ages, raw and adjusted endpoint fractions, net increase and area increase, and whether averaging retained, removed or created the increase |
| Forcing comparison | Existing period totals and HadGEM3 vegetation/ice components, old and NADI optimal, their differences, domain mean and global equivalent |

For the inventory, read raw fractions from the rasters and adjusted fractions from script 7a’s saved `ice_frac_young` and `ice_frac_old`. Count each cell–age pair once after checking agreement across months. Restrict the principal inventory to the forcing cells.

This should reproduce the established old-input result: **186 raw advancing pairs, 228 after averaging, including 75 newly created pairs**. It avoids copying the averaging algorithm.

Call these **net increases in cell ice coverage**. Fractions cannot reveal an advancing edge offset by retreat elsewhere within the same cell, and snapshots cannot date intervening events precisely.

Five figures suffice:

| Slide | Figure and message |
|---|---|
| Ice through time | Age alignment and ice-area curves; distinguish NADI snapshots from vegetation-bin labels |
| Where the ice differs | Fraction-difference maps at 11.5, 10, 8, 6 and 1 ka |
| When coverage increases | Readvance timing/location, raw versus adjusted counts, and one cell chronology showing an averaging artefact |
| Why the total still works | Retreat and advance cell diagrams explaining the current component attribution |
| How forcing changes | Old versus optimal period forcing, with vegetation, ice and total shown separately |

For the fourth slide, show the current calculation as **vegetation changes on the older ice-free area, followed by the ice-area change**. With monthly ice albedo \(A\),

\[
\Delta\alpha
=(1-f_o)(a_y-a_o)+(f_o-f_y)(a_y-A).
\]

This equals the difference between the two mixed endpoint albedos, including during advance.

A useful advance example is \(f:0.3\to0.7\), vegetation albedo \(0.20\to0.25\), and ice albedo \(0.68\). The current components are \(0.035+0.172=0.207\), exactly the endpoint change \(0.551-0.344\). The diagram should expose why the vegetation term includes change on land subsequently covered by ice, leaving its interpretation open.

Use HadGEM3 for the main forcing figure and retain the other kernels in the table. Label the oldest interval **10–11.5 ka** for the slides, while preserving saved labels when joining tables.

Describe the result as **changing ice while retaining the saved vegetation reconstruction**. Numerical vegetation coverage is established; scientific confidence in predictions beneath reconstructed ice remains a qualification. The young-slice alternatives remain a short note: carry-forward is used; no ice or a dated modern inventory would require a later choice.

**5. Switch the default only after accepting the comparison.**

Later, change `config.R` to `"nadi1_optimal"` and leave the explicit legacy configuration on `"dalton_ice"`.

Keep historical anchors unchanged. Establish separate NADI anchors for the accepted deterministic differences, forcing and summary tables, with the exact prediction-input provenance. Reproduce them in a fresh verification run. Checksums can anchor the large RDS outputs without committing duplicate copies.

Prove both paths:

- **Legacy configuration + historical frozen predictions:** reproduce the old anchors.
- **New default + accepted headline predictions:** reproduce the new NADI anchors.

The six-file historical tail anchor includes script-7 outputs, so a run beginning at 7a cannot claim to reproduce it all. Use the existing partial-anchor checker for the regenerated difference and forcing files, explicitly requiring both to match; use the complete forcing-summary anchor for script 9. Do not count copied products as reproduced.

This default changes **forcing ice fractions**. Calibration exclusion and script 7’s coarse maps still use their existing polygons. Replacing those would change additional parts of the analysis and should be scoped separately. The later full-pipeline integration gate still applies.

**6. Opus should implement in this order.**

| Step | Files/work | Required evidence |
|---|---|---|
| 1 | Record this design and Chris’s choices in the required issue; continue the ice topic branch under `CONTRIBUTING.md` | Agreed scope and project assumptions |
| 2 | Add `tools/build_nadi1_fractions.R`, three prepared TIFFs and provenance | Geometry cases, conservation, mask/alignment, ages, young-band equality and measured sizes |
| 3 | Make the five configuration/pipeline edits listed above | Parse; extend existing configuration/path tests; check selected inputs and manifest checksums |
| 4 | Commit and run verification at that exact commit | Old-headline replay, separate legacy regression, then NADI optimal |
| 5 | Add `tools/compare_ice.R` and a focused check file | Known old readvance counts, unique inventory keys, unchanged forcing-table values, correct joins and units |
| 6 | Produce tables and figures; review the scientific implementation | Independent Fable and Astra reviews, then one reconciliation pass; unresolved scientific questions remain questions |
| 7 | Update README script tables, dated design/changelog, verification records and relevant living questions | PASS evidence for final code; merge and push under the repository protocol |

Use `tools/verify_change.R` for executable verification throughout. Stand-alone builder/comparison checks can run through its `checks` mechanism; they do not need to become pipeline stages. Preserve the existing deterministic regression contract.

Record elapsed time for polygon loading/intersections, raster writing, each pipeline stage, comparison/plotting and total verification. Also record geometry package settings, peak memory where available, and output sizes. Builder and comparison runtimes are currently unmeasured.

Independent review identified the input-availability, coarse-table and default-scope constraints incorporated above. Two unnecessary expansions were dropped: a generic source registry and a readvance forcing control for the initial meeting.

**The scientific precedents support these operations, with explicit limits.**

| Reference | Passage inspected and what it supports |
|---|---|
| **Dalton, A. S., et al. (2023).** *Deglaciation of the North American Ice Sheet Complex in calendar years based on a comprehensive database of chronological data: NADI-1.* **Quaternary Science Reviews 321**, 108345. DOI **10.1016/j.quascirev.2023.108345**. | §1 describes calendar-age maps at 500-year spacing; §4 explains the minimum/maximum extent alternatives and snapshot limitations. [Publication record](https://dspace.library.uvic.ca/items/fa82de09-6298-46e4-9a9d-f0d45083a54a/full). The accompanying *North American Deglacial Isochrones, version 1* dataset, DOI **10.5281/zenodo.8161764**, documents the three alternatives at 49 dates. [Dataset](https://zenodo.org/records/8161764) |
| **Taylor, K. E. (2024).** *Truly conserving with conservative remapping methods.* **Geoscientific Model Development 17**, 415–430. DOI **10.5194/gmd-17-415-2024**. | §2, equations 4–6 and accompanying discussion: overlap-area weights and consistent cell shapes/areas. Supports conservative fractions and conservation checks; does not prescribe our geometry implementation. [Paper](https://gmd.copernicus.org/articles/17/415/2024/) |
| **Ghimire, B., et al. (2014).** *Global albedo change and radiative cooling from anthropogenic land cover change, 1700 to 2005 based on MODIS, land use harmonization, radiative kernels, and reanalysis.* **Geophysical Research Letters 41**, 9087–9096. DOI **10.1002/2014GL061671**. | §2.3, equation 1 supports fractional albedo mixing; equation 2 supports kernel multiplication. Their forcing uses separate white- and black-sky contributions, so this supports the principles, not an identical implementation or our component attribution. [Full text, pp. 3–4](https://wordpress.clarku.edu/wp-content/uploads/sites/22/2015/01/Ghimire_GRL_2014_GlobalAlbedoChange_RadiativeForcing_LandCoverChange.pdf) |

The fixed-prediction comparison, label matching, young carry-forward, current averaging and attribution are **project choices**, not conclusions established by these papers. The geometry convention and numerical tolerances are implementation choices to document before checking results.

The existing reference checker was invoked, but Crossref lookups failed because the registry was unreachable. Primary records and supporting passages were inspected; a completed registry audit cannot be claimed. Repeat that check during implementation.

**7. Two questions for Chris.**

1. **For the meeting, should we compare old ice with NADI-1 optimal only, or also calculate minimum and maximum forcing?** I recommend optimal first, with all three extent reconstructions shown spatially. The two additional forcing runs cost roughly another 2¼–2½ hours.

2. **Do you also want a numerical forcing comparison with readvance averaging disabled?** I recommend deferring it: raw/adjusted inventories and diagrams answer the present readvance questions. Comparing its forcing effect for both old and optimal ice would require the small Boolean setting and two additional runs.

The component-definition question and old chronology/source questions remain open as instructed; this design does not decide them.

No files or external records were changed, no R process was started, and nothing was committed or pushed. The ice branch/worktree remains clean and awaits implementation.