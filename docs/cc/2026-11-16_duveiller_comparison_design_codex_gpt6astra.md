**Add one `duveiller` command to the existing contrast tool.** It should read the saved all-days fits and cases, restrict each exchange to cells with a valid original Duveiller estimate, and recompute both regional means with identical area weights. Write one comparison table, one figure page and one record. No refitting is needed.

This gives the paper a geographically matched seasonal comparison of the fitted cover response. Coverage is often sparse, so the result will describe the represented cells rather than establish a regional validation. The only decision I would return to Chris concerns how to summarize the published cell uncertainties.

I inspected the downloaded file and independently matched its coordinates to the saved cases. Its checksum matches the supplied provenance, and **all 2,429 distinct eligible cell centres across the saved all-days cases match the NetCDF grid exactly**.

**Put the command in [tools/explore_cover_contrasts.R](/home/expert/Documents/contracting/Andria/paleo-RF-wt/merge-contrasts/tools/explore_cover_contrasts.R).**

```text
Rscript tools/explore_cover_contrasts.R duveiller <saved-contrast-dir> <netcdf-file> <output-dir>
```

Keep this separate from the ordinary `report` command: it needs the large saved fits and an external input.

The existing functions suffice:

- Read the 12 `cases_all_days_<month>.rds` files and 72 all-days fit files, checking completeness against the saved fit-status tables.
- Subset each saved case’s two endpoints and areas by the same matching mask. Pass them to `freeze_exchange()`, with the appropriate held class. It already checks the endpoints and normalizes area weights.
- Rebuild the case’s reporting fields, then call `version_rows()`. This reuses `exchange_contrast()` for the mean and coefficient-covariance standard error, and `exchange_spread()` for spatial spread.
- Reuse the CSV writer, month axis and plotting styles. Extend the record writer only enough to include the NetCDF reader, comparison settings and timings.

**No change to `R/cv_separation.R` is necessary.** There is no need to reread the calibration run or reconstruct eligibility.

Do not carry the saved snow-share medians into the comparison: they describe the original eligible cells. Also, the existing published-guide plot joins guides only by exchange and repeats them across regions. The new plot must join Duveiller values by **region, month and exchange**.

Write:

| File | Contents |
|---|---|
| `cover_contrasts_duveiller.csv` | **1,512 rows:** 12 months × 7 regions × 3 exchanges × 6 versions, including empty intersections |
| `cover_contrasts_duveiller.pdf` | One page, retaining the existing seven-region, three-exchange layout |
| `record_duveiller.txt` | Sources, checksums, code/package versions, mapping, matching rule and measured timings |

The CSV should contain the model mean, SE and spread; Duveiller mean and the uncertainty summary discussed below; fit status; original eligible count; common count and area; both coverage percentages; and the minimum and maximum published sample counts. Source values and coverage repeat identically across the six versions.

**Read the file according to its actual coordinates and variables.**

The inspected file is classic NetCDF. Longitude runs from −179.5° to 179.5°, ascending; latitude from 89.5° to −89.5°, descending. Both have 1° spacing. Month coordinates are 1–12.

Its three data variables are:

- `Delta_albedo`
- `SD_Delta_albedo`
- **`N_Delta_albedo`**, rather than the earlier note’s provisional `N_albedo`.

Their on-disk dimensions are transition × month × latitude × longitude. Values are 32-bit floats; missing values are NaN, with no scale or offset attributes.

Use the already installed R package `ncdf4`. Check dimension names in the R reader and construct selections accordingly; R’s exposed dimension order must not be confused with the on-disk order. Read only the three required transitions and variables. A month at a time is sufficient.

| Project exchange | External analogue | Transition coordinate | R position in this file | Sign |
|---|---|---:|---:|---:|
| Evergreen → summergreen | Evergreen needleleaf → deciduous broadleaf forest | 23, stored in reverse | 10 | −1 |
| Evergreen → open land | Evergreen needleleaf forest → grassland | 38 | 22 | +1 |
| Summergreen → open land | Deciduous broadleaf forest → grassland | 28 | 15 | +1 |

**Look up the transition coordinate, not its numeric position.** Likewise, select calendar months by their coordinates. Reverse only the difference; retain positive uncertainty and unchanged sample counts. Transition encoding and reversal are documented in the dataset descriptor, p. 11. [Duveiller, Hooker & Cescatti, 2018](https://www.nature.com/articles/sdata201814.pdf).

A consequential finding from the file: **SD and sample counts sometimes remain present where `Delta_albedo` is missing.** Therefore, finite `Delta_albedo` defines available source coverage. For these three transitions, every finite estimate also has a finite, nonnegative SD and a sample count of at least 20. Check that consistency; do not infer availability from SD or count alone, or impose another sample-count filter. Retain legitimate zero estimates.

**Match cell centres directly, then average the same population.**

Check unique coordinate matches, 1° spacing, coordinate ranges and exact agreement with saved endpoint centres. A mismatch should stop with an explanation. This comparison needs no interpolation, nearest-neighbour matching or regridding.

For each existing region, month and exchange:

1. Start with its **saved eligible case**.
2. Intersect those cells with finite Duveiller estimates for that month and transition.
3. Subset both model endpoints identically.
4. Normalize the saved areas over that intersection.
5. Compute both means there, using the same weights for every model version.

For common cells \(C\), define \(w_i=A_i/\sum_{j\in C}A_j\). Then

\[
\overline{\Delta\alpha}_{D}
=\sum_{i\in C}w_i(0.10\,s\,\Delta\alpha_{D,i}),
\qquad
\overline{\Delta\alpha}_{M}
=\sum_{i\in C}w_i
\left[\widehat\alpha_i(\text{second})-\widehat\alpha_i(\text{first})\right].
\]

The model endpoints already represent the ten-percentage-point exchange: **do not scale the model result again**. The source scaling is a linear mixing reference, not an assertion that the fitted model responds linearly to complete conversion.

Keep the existing cell areas. Do not replace them with sample-count or inverse-uncertainty weights. Fraction-times-transition scaling follows Lejeune et al., equation 11; area weighting follows their §2.1.1. Restricting both estimates to common geographic coverage follows Duveiller et al., §2.3. [Lejeune et al., 2020](https://esd.copernicus.org/articles/11/1209/2020/), [Duveiller et al., 2018](https://essd.copernicus.org/articles/10/1265/2018/).

Show two distinct coverage measures:

- **Common area / original eligible area:** how much of the existing contrast remains.
- **Common area / regional calibration-cell area:** how much of the region’s calibration support is represented.

The second needs no new input:

```text
original regional area_share × common area / original eligible area
```

For an empty intersection, retain the row with zero common cells and area, and missing estimates. A fraction with an empty denominator is missing. Do not discard sparse cases or fill gaps.

The observed coverage makes this essential:

| Northeast exchange | January: common / eligible cells | July: common / eligible cells |
|---|---:|---:|
| Evergreen → summergreen | 20 / 58 | 40 / 58 |
| Evergreen → open land | 1 / 41 | 5 / 41 |
| Summergreen → open land | 11 / 22 | 12 / 22 |

In Alaska/Yukon, summergreen → open land has **zero to two common cells** across the year. All three Alaska/Yukon exchanges have no common cells in January and December. These are inspection results from the supplied files, not implementation verification results.

**Keep cell uncertainty separate from regional uncertainty.**

Multiply each published `SD_Delta_albedo` by **0.10**. The file supplies no covariance between one-degree cells, so it does not support a regional SE or confidence interval without an additional assumption. Neither division by \(\sqrt n\) nor an independence-based variance sum is warranted. The published method accounts for overlapping fine-pixel windows when constructing coarse estimates; that does not establish independence between coarse cells. [Duveiller, Hooker & Cescatti, 2018, equations 12–19](https://doi.org/10.1038/s41467-017-02810-8).

My proposed minimal summary is:

\[
\text{mean cell SD}=\sum_{i\in C}w_i(0.10\,SD_i).
\]

Put this in the table as **“area-weighted mean cell SD, scaled to a 10-point exchange”**. It describes the supplied cell uncertainties; it is not uncertainty in the regional mean. Do not draw it as a ribbon or error bar around that mean. I found no field precedent for this precise reporting convention; it is a proposed project choice.

Retain the model’s existing conditional SE calculation, which preserves covariance induced by the fitted coefficients between endpoints and cells.

**Present the page as a comparison of seasonal responses.**

Use the six existing model styles, with their conditional ±2 SE bars, and distinct black points for the matched Duveiller means. Under each panel, show monthly common-cell count and the two area percentages. Preserve gaps at empty months.

The caption and CSV explanation should state:

- Project albedo is the 2000–2009 monthly blue-sky climatology; Duveiller uses the mean of black- and white-sky albedo and calendar-month medians over 2008–2012, based on retrieval periods near mid-month.
- Forest-class matching is approximate. The project’s summergreen class includes larch and shrubs; grassland is the selected open-land analogue.
- Duveiller’s coarse values summarize local transitions, rather than conversion of an entire one-degree cell.
- Both estimates use MODIS information, and the cells represented can change between months. [Dataset descriptor, pp. 2–4 and Usage Notes](https://www.nature.com/articles/sdata201814.pdf).

Agreement in sign, seasonal timing and broad magnitude would show consistency on the represented cells. Disagreement would identify a response to examine, without identifying which estimate is wrong. Neither establishes performance under Holocene climates or ice-sheet conditions. This interpretation follows the comparison framework’s explicit treatment of neither estimate as an absolute reference. [Duveiller et al., §2.4](https://essd.copernicus.org/articles/10/1265/2018/).

There should be no scientific score, pass/fail label or model-selection consequence.

**Verify implementation correctness with a small spec and the complete saved run.**

Add focused tests for:

- An asymmetric miniature NetCDF: latitude orientation, month and transition lookup, NaN versus zero, sign reversal, and scaling both difference and SD.
- Unequal cell areas with some eligible cells removed: identical endpoint selection, normalized common weights, both means and coverage denominators.
- Empty intersections and a shifted grid.
- A small fitted example whose matched mean agrees with direct weighted response predictions and differs from its unrestricted mean.

Extend `tools/check_cover_contrasts.R` with a comparison check. On the real files, require 1,512 unique rows, identical source values and coverage across versions, appropriate missing results, one PDF page and a complete record. Independently reproduce selected winter and summer means from raw source values and direct model predictions. Also reproduce an unrestricted saved model result against the existing contrast CSV.

Useful fixed checks include the northeast counts above and this source value: at **75.5°W, 45.5°N, January**, transition 23 contains approximately **−0.0444744043**, SD **0.0143031348**, and **39** samples. After reversal and scaling, the difference is approximately **+0.00444744043**, with scaled SD **0.00143031348**.

The new verification spec should use:

- The full implementation commit and `scripts = character()`.
- Existing contrast tests plus the new focused tests.
- The full twelve-month `duveiller` command, followed by its output checker.
- Existing inputs read-only and a fresh verification output directory.
- Single-thread settings and the existing `tools/verify_change.R` workflow.

Software checks may pass or fail; the signs or agreement of scientific results must never determine that verdict.

Record elapsed time for input hashing/reading, model recomputation, output writing and the complete command. Load one fit at a time. No verification-tool extension is needed.

For context, my read-only Python inspection measured approximately **0.57 s** for the source checksum, **0.011 s** to read the three requested transitions across all variables and months, **0.15 s** to decode the twelve saved case files, and **0.044 s** for matching and source summaries. These are single inspection measurements; **the new R command’s runtime remains unmeasured**.

**The implementation order for Opus should be:**

1. Once the contrast merge is pushed, create the issue and a topic branch off current `chris-dev`. Record this design, Chris’s existing decisions and the uncertainty-display decision.
2. Recheck reference identities. Implement the reader and matching, then their focused tests.
3. Add saved-fit recomputation through the existing functions, followed by the table, figure and record.
4. Add the real-data checker and verification spec; update the README script map, dated implementation note and changelog with the method precedents.
5. Obtain the required independent Fable and Astra reviews of the same code and requirements, then reconcile substantive findings.
6. Run exact-commit verification, inspect the page, record actual timings, and complete the normal commit, push and merge protocol. Update the existing scientific question about class correspondence without duplicating it.

The full references to carry into the plan and changelog are:

- Duveiller, G., Hooker, J. & Cescatti, A. (2018). *A dataset mapping the potential biophysical effects of vegetation cover change.* **Scientific Data 5**, 180014. [doi:10.1038/sdata.2018.14](https://doi.org/10.1038/sdata.2018.14).
- Duveiller, G., Hooker, J. & Cescatti, A. (2018). *The mark of vegetation change on Earth’s surface energy balance.* **Nature Communications 9**, 679. [doi:10.1038/s41467-017-02810-8](https://doi.org/10.1038/s41467-017-02810-8).
- Lejeune, Q., Davin, E. L., Duveiller, G., Crezee, B., Meier, R., Cescatti, A. & Seneviratne, S. I. (2020). *Biases in the albedo sensitivity to deforestation in CMIP5 models and their impacts on the associated historical radiative forcing.* **Earth System Dynamics 11**, 1209–1232. [doi:10.5194/esd-11-1209-2020](https://doi.org/10.5194/esd-11-1209-2020).
- Duveiller, G., Forzieri, G., Robertson, E., Li, W., Georgievski, G., Lawrence, P., Wiltshire, A., Ciais, P., Pongratz, J., Sitch, S., Arneth, A. & Cescatti, A. (2018). *Biophysics and vegetation cover change: a process-based evaluation framework for confronting land surface models with satellite observations.* **Earth System Science Data 10**, 1265–1279. [doi:10.5194/essd-10-1265-2018](https://doi.org/10.5194/essd-10-1265-2018).

The supporting passages were read. Automated reference-checker lookups could not reach Crossref, so a successful registry check remains outstanding.

No files were changed, no R jobs were started, and no additional files were downloaded. The prohibited directory was not opened. The working tree remains clean on `merge-cover-contrasts`.

**One question for Chris:** approve the separately labelled area-weighted mean of scaled cell SDs in the table, without a regional confidence interval? This precise summary is a project judgement without an established field precedent, which the repository’s method rule requires putting to you before implementation.