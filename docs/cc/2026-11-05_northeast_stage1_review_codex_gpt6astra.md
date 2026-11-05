I found no error in the nearest-partner selection or retrieval-eligibility arithmetic. I recommend the accounting fixes and reductions below before coverage. **All four tests pass. `parallel = FALSE` is valid here, and the HDF CRS does not require a workaround.**

Nothing was changed. No network access or coverage run was performed, and the requests directory was not opened. The worktree is clean; its reviewed code matches `cc65015`.

For the line references below:

- **F** = [R/northeast_forest_albedo.R](/home/expert/Documents/contracting/Andria/paleo-RF-wt/northeast/R/northeast_forest_albedo.R)
- **D** = [tools/check_northeast_forest_albedo.R](/home/expert/Documents/contracting/Andria/paleo-RF-wt/northeast/tools/check_northeast_forest_albedo.R)
- **P** = [tools/prepare_bluesky_albedo.R](/home/expert/Documents/contracting/Andria/paleo-RF-wt/northeast/tools/prepare_bluesky_albedo.R)

The previously unchecked points are now resolved:

- `git show 1e37c26:tools/prepare_bluesky_albedo.R | sha256sum` returned **`cb2920f6357010ada20c311d31cc90fc7cee00cafbee9358dc2f1735e9684638`**.
- Installed terra **1.9-50** explicitly tests `terraOptions(parallel=FALSE)` in its own [test_focal_cores.R:12](/home/expert/micromamba/envs/paleo-rf/lib/R/library/terra/tinytest/test_focal_cores.R:12).
- Read-only GDAL header checks covered `LC_Type1`, `QC` and `LC_Prop3` in all 27 HDFs: **81 subdatasets**. All normalize to the template’s identical `+R=6371007.181` sinusoidal definition; `OSRIsSame` returned 1. Maximum geotransform difference was **3.35 × 10⁻⁷ m**. Inspection of terra’s installed implementation confirmed that it uses this normalization. Thus `northeast_check_grids` will not reject these HDFs because of `+a/+b` versus `+R`. This establishes the result without running an additional R expression.
- All four permitted tests exited successfully using `THREADS=1 OPENBLAS_NUM_THREADS=1 tools/rscript.sh`: `test_modis_albedo_helpers.R`, `test_bluesky_albedo.R`, `test_northeast_forest_albedo.R`, and `test_northeast_forest_coverage.R`. All eight changed R files also parsed.

My responses to Fable’s findings are:

| Finding | Verdict and evidence |
|---|---|
| **1. Retrieval diagnostics and cell-year table** | **Agree.** Defer both outputs to stage 2. They do not determine selection: the eligible masks are already stored at **F:629**, and regional retrieval coverage uses those masks at **F:654–667**. Removing **F:549–569**, the diagnostic/cell-year construction and their return entries leaves the coverage calculation intact. |
| **2. Two hashes versus one** | **Agree with a change to the explanation.** Every currently accepted historical script contained its helpers, so its script hash already identifies them. The gap arises when a *post-extraction* script becomes an accepted older version: **P:840** then stops checking its helper hash. Use one digest over script bytes followed by helper bytes, retaining the approved historical digests unchanged. |
| **3. Changed `is_land` default** | **Disagree that the record omits it.** The [implementation report:31–34](/home/expert/Documents/contracting/Andria/paleo-RF-wt/northeast/docs/cc/2026-11-05_northeast_forest_albedo_stage1_implementation.md:31) explicitly records the literal default and the explicit `LAND_RULE` argument. “Function bodies unchanged” is also accurate: the formal argument changed. No correction is necessary. |
| **4. Duplicated footprint and tile width** | **Agree.** Derive the candidate search bounds from the selected cells’ outer edges, and tile width from the mosaic width divided by tile count. This replaces the repeated bounds at **F:216,224,233–234** and width at **F:250–251**, while allowing a small candidate-building fixture. Keep the frozen footprint selection in **D:32**. |
| **5. Loss accounting** | **Agree with a change.** Record the removal at **F:247** as an explicit scope exclusion; a comment alone does not close the counts. Keep `forest_class='all'` for the initial class screen: it includes nonforest and missing labels. Its survivors must reconcile with the combined ENF/DBF population before the two classes are followed separately. |
| **6(a). Assignment and quotation style** | **Agree as a readability nit.** Use the surrounding `=` and single-quote style when editing the retained block at **F:380–675**. It has no numerical consequence and does not warrant a separate rewrite. |
| **6(b). Variable `c`** | **Agree on renaming, with a correction.** Rename it to describe the candidate rows at **F:427,459**. It does not break `c()`: R’s function lookup skips non-function bindings. This is readability only. |
| **6(c). Monthly metadata checks** | **Disagree with deletion.** This driver reads monthly files directly at **D:39,47,75**; it does not execute preparation’s cell step. Therefore **F:307–322** supplies a check that would otherwise be absent, including rejection of July-test settings. Keep it. |
| **6(d). Pair overwrite refusal** | **Disagree with deletion.** The six lines at **F:366–372** enforce a concrete requirement: a changed selection must not silently replace an already frozen table. Keep them. |
| **6(e). Output prose** | **Agree with a change.** Shorten **D:94–104** to the coverage-only statement, pair identity and instruction to return the coverage to Chris. The implementation document already explains the detailed conventions. |
| **6(f). `parallel` option** | **Disagree.** It is supported by installed terra, as established above. Keep `parallel = FALSE`. |
| **6(g). Temporary directory** | **Disagree that this needs fixing.** **D:26–28** deliberately keeps terra scratch files inside the selected run’s output directory. No incorrect result or operational failure was identified. |
| **6(h). Elevation-cache path** | **Agree.** Use `read_input(run, path_file(paths, 'elevation_cache'))` at **D:31**, and use that catalogued path in **D:82**. Both existing copies have identical SHA-256, `368a654d…4207299`, so this changes provenance and path handling, not today’s cells. |

For Fable’s proposed verification checks:

| Check | Verdict and required interpretation |
|---|---|
| **1. Southern boundary rows** | **Agree with a change.** Check the cutoffs from **F:47–58**: approximately **40.051216°**, **40.037396°**, and **40.096182°** for main, stricter and looser. Search-boundary losses must lie in the 40.5° cell row. The saved tables currently lack rejected pixel coordinates, so they cannot directly prove the latitude of every rejected centre. Use sharp boundary fixtures and the retained cell-level losses; do not claim that an aggregate table verifies individual coordinates. Earlier screens may already have removed some boundary pixels. |
| **2. Telescoping losses** | **Agree with a change.** Reconcile the initial `all` class screen with ENF plus DBF, include the explicit scope exclusion, then telescope each class separately. Preserve cell-level loss rows first; the present output drops their cell keys at **F:490–493**. |
| **3. Pixel-ID round trip** | **Agree.** Decode tile and pixel, recover row/column and native coordinates, and compare stored lon/lat to **1e-9 degrees**. This directly checks **F:229–256**, where an indexing mistake would select the wrong monthly count pixels. Include tile and strip joins. |
| **4. Partner-screen closure** | **Agree.** For each bundle and cell, the all-pairs `matched_enf` must equal partner-screen `n_after`, and `matched_enf + n_lost = n_before`. Compare against **D:67–69**; do not substitute a stricter diagnostic subset. |
| **5. Strata and reciprocity** | **Agree.** Verify `unflagged3 ⇒ wetland_stratum == 'neither'`, and independently recompute reciprocity using the recorded eligible target-cell ENF population. Definitions are at **F:356–363**. |
| **6. Historical archive acceptance** | **Agree; confirmed.** A header-only read of `h11v04_2001_01.tif` found `2ee39123…`, the expected production settings and no helper tag. **P:190,830–841** accepts that combination; the passing historical-hash fixtures exercise that acceptance. The `cb2920f6…` hash was independently confirmed above. No real archive file was rebuilt or read for albedo values. |
| **7. HDF CRS** | **Agree with checking it; disagree with the proposed workaround here.** The installed stack normalizes all checked HDF definitions to the template CRS. Keep the existing CRS comparison; adding `crs=FALSE` and a string exception would weaken and complicate it unnecessarily. |
| **8. Sharper boundary test** | **Agree.** Add main’s 40.0510° fail / 40.0516° pass case beside [test_northeast_forest_albedo.R:29](/home/expert/Documents/contracting/Andria/paleo-RF-wt/northeast/tests/test_northeast_forest_albedo.R:29). Add corresponding brackets for stricter and looser while touching that fixture. |

My recommendations on the five questions for Chris are:

1. **Elevation caliper:** keep eligibility-before-nearest. That implements “nearest eligible DBF”; nearest-then-drop can change pair identities, coverage and eventual contrasts.
2. **Stage-1 retrieval outputs:** defer the diagnostics and cell-year table, retaining retrieval coverage. This changes the outputs produced, not pair selection or the retained coverage numbers.
3. **Helper identity:** use one combined code digest and retain approved historical hashes. This changes provenance checks, not current numerical results.
4. **Southern warning:** retain “at least one pair”, with the three-pair count alongside it, as already documented at **F:468–476**. Choosing three pairs for the warning can change the review flag, but not the selected pairs or reported counts.
5. **Strips or whole mosaic:** keep strips. They satisfy the small-memory brief; switching to a whole mosaic should not change results and offers insufficient benefit to justify the memory increase.

On the additional code review, I rechecked strip halos, tile joins, native GMTED indexing, water alignment, matching, reuse, wetland missingness, regional counts and retrieval gates. A separate audit reached the same conclusion: **no further confirmed wrong-pair or retrieval-count defect**.

There is one additional omission in the saved evidence: **cell-level screen losses exist in memory but are not written**. **F:490–503** publishes only regional aggregates. Retaining the existing rows through the existing table writer would enable checks 2 and 4 without adding another calculation.

Also, recomputing pairs solely by calling `northeast_pairs()` again is insufficient verification. Independently compare a fixed sample of ENFs against **all** eligible DBFs, applying the elevation limit, great-circle distance and ID tie rule. Include bin boundaries and a tile join.

I discarded two possible objections because they were not defects: repeated candidate counts in stricter diagnostic rows describe the unchanged candidate population, and the reciprocal diagnostic deliberately uses target-cell ENFs. Neither needs extra code.

The changes I recommend before the coverage run are below. Line counts are approximate net changes, since this review makes no patch.

| Recommended change | Lines saved or added |
|---|---:|
| Defer retrieval diagnostics and the cell-year output; remove their unused construction and obsolete assertion | **About 36 code lines and 1 test line saved** |
| Replace the two code hashes with one combined digest; update compatibility tests | **About 25–30 lines saved overall** |
| Derive candidate bounds and tile width from existing inputs | **About 3–5 code lines added** |
| Record the outside-domain ENF scope exclusion | **About 4–8 code lines added** |
| Export the existing cell-level loss rows, documenting their strip-level repetition | **1–2 code lines added** |
| Read and record the catalogued elevation cache | **No net lines added** |
| Shorten coverage notes | **About 6 lines saved** |
| Rename `c`; align style within edited code | **No net lines added** |
| Add focused boundary, pixel-ID, candidate-strip and accounting checks | **About 25–45 test lines added** |

The final verification checks should be:

1. Run **`tools/verify_change.R` at the final committed revision**, in its separate worktree and a fresh run directory, with one thread. Parse the changed files and run all four tests.
2. Verify the 27 approved granules, 354 monthly inputs, native grids, water alignment, native GMTED georeferencing and the catalogued 83-cell domain.
3. Check sharp boundary cases, pixel-ID round trips and strip/tile joins; independently verify sampled nearest partners. Confirm thresholds, unique ENF IDs, DBF reuse, reciprocity and wetland subsets.
4. Reconcile losses by bundle, cell and class, including scope exclusions and partner closure. Recompute regional coverage and feasibility flags, retaining all zero-pair cells.
5. Independently check count eligibility, stricter cell-year gates, distinct pairs, unique DBFs and represented years. Confirm that reading counts leaves the frozen pair object and its digest unchanged.
6. Verify combined-hash sensitivity to either code file, continued acceptance of approved historical files without helper tags, and rejection of unapproved identities. No archive rebuild is needed.
7. Confirm completed manifests and unchanged inputs. Return the coverage and feasibility tables to Chris before stage 2; a software PASS does not imply that the scientific feasibility targets were met.