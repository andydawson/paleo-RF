**Verdict: ready after named changes.** I found no error in the exchange arithmetic, area weighting, support counts, or compatibility of the changed helpers. Before verification, correct the published-reference display, show the required support information in the figure, and make verification assert results rather than successful command execution. Save the fitted objects before launching the full exploration.

This was read-only. I changed no files, made no commits, and did not run R. I inspected all four figure pages, audited the builder’s checks, and independently recomputed numbers from the saved products in Python.

The findings, worst first:

1. **Two mixed-cover comparisons are presented as complete forest-to-open contrasts.**  
   File: [explore_cover_contrasts.R:251](/home/expert/Documents/contracting/Andria/paleo-RF-wt/contrasts/tools/explore_cover_contrasts.R:251), also lines 297 and 313; published CSV lines 36–39.

   The snowy summergreen-to-open panel includes grey guides of **+0.012 and +0.015** from comparisons between deciduous forest and a **cropland/forest/grass/shrub mosaic**. Calling these “differences between whole classes” and scaling them as complete forest-to-open conversions overstates what was measured. The other two Burakowski 2015 guides, **+0.052 and +0.054**, describe midday measurements on **9 March 2013**, not a March climatology.

   The arithmetic is correct. The problem is the interpretation after the reader drops the original classes and qualifications. Burakowski’s Tables 5 and 7 give the underlying values; §4.3.2 describes the mosaic’s heterogeneous cover. [Burakowski et al. 2015, DOI 10.1016/j.rse.2014.11.023](https://www.fs.usda.gov/nrs/pubs/jrnl/2015/nrs_2015_burakowski_001.pdf).

   **Recommended change and check:** retain the two mosaic comparisons, explicitly labelled, on the separate published page; omit them from the complete-transition mixing guides. Mark all four observations as single-day cases. Preserve the original classes, albedo kind and essential qualifications in `published_guide.csv`. Inspect these four marks explicitly after regeneration.

2. **The real-data verification can succeed even if every attempted fit fails.**  
   File: [verification spec:25](/home/expert/Documents/contracting/Andria/paleo-RF-wt/contrasts/docs/cc/verification/2026-11-15_cover-contrasts.R:25); [explore_cover_contrasts.R:180](/home/expert/Documents/contracting/Andria/paleo-RF-wt/contrasts/tools/explore_cover_contrasts.R:180).

   Recording failed fits without aborting is appropriate for this exploration. But the spec currently checks only that the fit and report commands finish successfully. Both can do that while producing no usable estimates.

   **Recommended check:** assert that the snowy July–August verification produces:

   - 12 fit records: eight converged fits and four explicitly not fitted;
   - 252 uniquely identified contrast rows;
   - identical support across versions;
   - finite estimates for converged fits with eligible cells;
   - missing estimates for skipped, failed and empty cases;
   - the known support counts and several numerical results within stated tolerances.

   These are implementation checks, not scientific acceptance criteria. Include the frozen-exchange comparison in this exact-commit verification too.

   The launch location also matters. [verify_change.R:82](/home/expert/Documents/contracting/Andria/paleo-RF-wt/contrasts/tools/verify_change.R:82) derives its worktree location from the launching checkout. Run it from the canonical `paleo-RF` checkout, supplying the reviewed spec. Launching from this worktree would put verification beside the wrong directory for the spec’s relative source-run path.

3. **The figure omits support information that the design says must accompany the estimates.**  
   File: [explore_cover_contrasts.R:274](/home/expert/Documents/contracting/Andria/paleo-RF-wt/contrasts/tools/explore_cover_contrasts.R:274), especially lines 276–278 and 295–299.

   Panel titles give only the smallest and largest eligible counts. They show neither area shares nor which months have those counts. Retrieval shares are absent.

   This materially affects interpretation. Independently recomputed snowy July study-area support is:

   | Exchange | Eligible cells | Share of calibration-cell area | Median snowy retrieval share |
   |---|---:|---:|---:|
   | Evergreen → summergreen | 123 | 3.76% | 0.090% |
   | Evergreen → open | 140 | 4.02% | 0.151% |
   | Summergreen → open | 225 | 5.66% | 0.379% |

   The corresponding figure looks like an ordinary regional seasonal comparison.

   **Recommended change and check:** show month-specific counts and area percentages, shared across versions, with retrieval support visible alongside the snow-state results. State that “area share” means the area of modern calibration cells represented, not the entire geographic box.

   Also add three short qualifications: these are continental fits evaluated at regional cells; the same external references are repeated in every region; vertical scales differ between panels. The June–September snow-free rationale holds for the northeast, not universally: in Alaska/Yukon, 279 of 357 eligible evergreen-to-summergreen cells have some snowy retrievals in June. Keep the agreed guide convention, but do not call those months uniformly snow-free across all regions.

4. **The full run discards the fitted objects needed to explain its results.**  
   File: [explore_cover_contrasts.R:187](/home/expert/Documents/contracting/Andria/paleo-RF-wt/contrasts/tools/explore_cover_contrasts.R:187).

   The output retains formulas, convergence, warnings and regional summaries, but discards the actual model and its attempt records. Investigating an unexpected location effect, inspecting smoothing parameters, or comparing tables on common cells would require refitting. The trial’s independent contrast check already had to do that.

   This satisfies the design’s minimum output list, but is a poor stopping point for 212 expensive fits.

   **Recommended change and check:** save each existing fitter result before removing it, outside Git. Save the already-constructed exchange cases once per table and month. Reload one saved fit during verification and reproduce its contrasts and standard errors. No new analysis framework is needed.

5. **The published page gives annual and uncertain-period values more temporal precision than their sources support.**  
   File: [explore_cover_contrasts.R:249](/home/expert/Documents/contracting/Andria/paleo-RF-wt/contrasts/tools/explore_cover_contrasts.R:249), also lines 310–315; published CSV lines 30–35 and 83–85.

   The three annual Lutz values become twelve monthly ticks without an “annual” label. The negative evergreen-to-summergreen contrast consequently looks negative in every month. Its original note also identifies separate sites with different elevations.

   For Burakowski 2016, December–March is the stated **WRF comparison season**; the text does not unambiguously establish that averaging period for the MODIS statistics. The CSV’s own notes acknowledge this. [Burakowski et al. 2016, §2d(3), p. 5146 and Fig. 5; DOI 10.1175/JCLI-D-15-0286.1](https://www.fs.usda.gov/nrs/pubs/jrnl/2016/nrs_2016_burakowski_001.pdf).

   **Recommended change and check:** label Lutz’s values “annual means; separate sites”, preferably showing each once. Label Burakowski’s winter placement as following the comparison window, with the MODIS averaging period unspecified. Check that the published page cannot be read as twelve independent monthly observations.

6. **The 10% count is attributed too strongly to Lejeune’s method.**  
   File: [explore_cover_contrasts.R:44](/home/expert/Documents/contracting/Andria/paleo-RF-wt/contrasts/tools/explore_cover_contrasts.R:44), also lines 210–211; implementation note line 204.

   Lejeune’s printed filter couples low class fractions with a regression-error condition, alongside earlier neighbourhood filters. The precedent report already records that wording. Counting cells with both classes at least 10% is therefore an adaptation of one element, not reproduction of their condition. [Lejeune et al. 2020, §2.3.1, p. 1213; DOI 10.5194/esd-11-1209-2020](https://esd.copernicus.org/articles/11/1209/2020/).

   **Recommended change and check:** retain the count and correct its description. Do not introduce an eligibility filter. This is a wording correction, checked against that passage.

**The numerical checks support the implementation.**

I decoded the saved RDS tables and recomputed all **756 table/month/region/exchange support cases** using an independent convex-hull calculation:

- All cell counts, fitted counts and 10% counts matched exactly.
- Area shares differed by at most \(5\times10^{-16}\).
- Both snow-share medians differed by at most \(1.2\times10^{-16}\).
- All 420 saved trial rows matched their corresponding support cases.
- Their numerical availability agreed with convergence and empty-support status.

The exchange directions are correct. “Evergreen to summergreen” gains summergreen and loses evergreen; the other two gain open land. The endpoints are ±0.05 around the original mix, so their separation is **0.10 of the cell**, holding the third class, coordinates and elevation fixed.

Weights are cell area divided by eligible area. The denominator of `area_share` includes the region’s calibration cells with valid areas even when they lack that month’s albedo. That is a defensible reporting choice and explains why missing winter observations lower the share.

The conditional standard error is also correct. For endpoint predictions \(\mu_{0i},\mu_{1i}\), the code forms the area-weighted derivative \(g\) of their mean difference and calculates

\[
SE=\sqrt{g^\mathsf{T}V_\beta g}.
\]

It retains covariance between endpoints and between cells arising from shared coefficients. It does not add uncertainty from smoothing-parameter estimation, residual spatial dependence, cover data or model choice. The spread is the weighted population standard deviation of cell contrasts; no sample-size correction is needed for this descriptive quantity.

Duveiller’s equations 11–13 support the transition direction and retaining endpoint covariance. The application to a continental beta model and its nonlinear regional average is a project adaptation. [Duveiller et al. 2018, *The mark of vegetation change on Earth’s surface energy balance*, DOI 10.1038/s41467-017-02810-8](https://doi.org/10.1038/s41467-017-02810-8).

I could not independently reconstruct the real trial standard errors from saved summaries alone because the fitted coefficients and covariance matrices were not retained. The builder’s simulation check is sensible, and the existing hand-worked matrix tests check the underlying calculation independently.

Both snow-share columns correctly report **unweighted medians across eligible cells of accepted-retrieval fractions**. They are not snow-covered area fractions, measures of absolute observation count, or necessarily complements when unknown snow flags exist.

**The helper changes preserve protocol 2’s behaviour.**

The default additions and subtractions occur in the same order on the same columns. `freeze_exchange()` still holds open land by default. The area functions directly extract the previous lookup expressions.

The [frozen-exchange check:18](/home/expert/Documents/contracting/Andria/paleo-RF-wt/contrasts/docs/cc/2026-11-15_cover_contrast_exploration_trial/check_unchanged_exchanges.R:18) compares complete objects with `identical()`: endpoints, areas, weights, exclusions and support. Its four logged successes are meaningful, not rounded-summary comparisons.

Together with tests of all six ordered pairs, reversal, invalid classes and conflicting areas, this is sufficient evidence for the changed helper behaviour. It does not claim that the entire separation analysis was rerun, and that unchanged analysis need not be rerun here.

**The inputs are comparable for the stated exploration.**

All three tables contain the same 2,812 cells, with exactly identical coordinates, cover and elevation. I independently confirmed that their area lookups contain the same 2,866 cells with exactly equal areas; 2,808 calibration cells have an area.

The configurations share the relevant cover, elevation, ice-mask, domain and `full_75` settings. The snowy pipeline omitted July and August, but its preparation stage saved all twelve calibration columns. Their use here is legitimate.

The guard reproduces script 2’s exact-zero adjustment and checks all twelve calibration-albedo columns, including missingness. It establishes numerical consistency, rather than proving the provenance of every ancillary CSV column. For these inputs, the identical tracked cell-table content across the three run commits supplies that additional evidence.

What remains incomparable without further work is the **population represented by each fitted result**: snow states and months have different observations and eligible cells. The tool acknowledges this and makes no formal between-table estimate. Any later attribution of a difference to snow alone must use common cells and address the different retrieval support.

**Every one of the 56 drawn published rows was audited.** The table below groups rows only to avoid repeating identical conclusions. Line numbers refer to the [published CSV](/home/expert/Documents/contracting/Andria/paleo-RF-wt/contrasts/docs/cc/2026-11-10_published_albedo_contrasts.csv).

| CSV lines | Rows | Result |
|---|---:|---|
| 2–7 | 6 | Hollinger deciduous minus evergreen: contrast 1; seasonal months, snow-free and broadband correct. |
| 8–19 | 12 | Hollinger grass/crop minus evergreen: contrast 2; metadata correct. |
| 20–25 | 6 | Hollinger grass/crop minus deciduous: contrast 3; metadata correct. |
| 26–29 | 4 | Hollinger digitised site differences: contrast 1; May, summer, autumn and November match the row text. |
| 30–35 | 6 | Burakowski 2016: contrasts and snow/band assignments correct; winter dates require the qualification above. |
| 36–37 | 2 | Burakowski 2015 pasture minus deciduous: correct direction, March and snowy broadband; single-day qualification needed. |
| 38–39 | 2 | Burakowski 2015 mosaic minus deciduous: arithmetic correct; treating the mosaic as wholly open cover is an additional approximation. |
| 40–42 | 3 | Boisier deciduous minus evergreen: contrast 1; winter snowy/free and summer free correct. |
| 43–48 | 6 | Boisier crop/grass minus evergreen: contrast 2; metadata correct. |
| 49–54 | 6 | Boisier crop/grass minus deciduous: contrast 3; metadata correct. |
| 83–85 | 3 | Lutz: contrasts 2, 3 and 1 respectively; annual/all-conditions metadata matches the text, but the display needs correction. |

All signs are correct: CSV `class_a` is the gaining class, so `difference_a_minus_b` already has the exploration’s direction. **Do not negate it.**

Forty-three tabulated differences were checked against accessible primary tables. The ten figure-derived values were not independently redigitised, and Lutz’s three source-table values were not independently retrieved this session. Hollinger’s Table 2 and Fig. 2 support its seasonal labels; Boisier’s Table 2 explicitly distinguishes winter snowy, winter snow-free and summer snow-free white-sky albedo. [Hollinger et al. 2010, DOI 10.1111/j.1365-2486.2009.02028.x](https://research.fs.usda.gov/treesearch/download/34733.pdf), [Boisier et al. 2013, DOI 10.5194/bg-10-1501-2013](https://bg.copernicus.org/articles/10/1501/2013/).

The 56 rows expand correctly to **172 row-month entries**. Guides contain 51 all-days, 105 snow-free and 31 snowy entries. Their multiplier is exactly 0.10; year-crossing seasons are expanded correctly. Annual references stay off the model pages.

The exclusions comprise 12 spectral-band rows, 28 snow-period rows and seven rows without eligible numerical values. Those rules are implemented correctly. Jin’s two verified placeholders should now be filled. Hollinger’s larch comparisons were absent from the assembled table already; this tool did not accidentally filter them out.

I also confirmed that **none of the original fields in the 103-row CSV changed** when the five columns were added.

**The fourteen implementation choices mostly follow the design.**

| Choice | Assessment |
|---|---|
| 1. Names and direction | Already fixed by the design; correctly implemented. |
| 2. Study area and regional boxes | Correct; boxes remain distinct from the forcing window. |
| 3. Area denominator | Reasonable project choice; clarify its calibration-cell coverage. |
| 4. Both retrieval shares | Useful reporting addition. |
| 5. Count the 10% condition | Acceptable addition; correct the attribution. |
| 6. Area-weighted spread | Useful addition. Boisier supports separating spatial spread from uncertainty; this exact statistic is a project choice. |
| 7. Suppress estimates after nonconvergence | Appropriate numerical handling, consistent with the existing protocol. |
| 8. Always fit six versions | Explicitly required, not an undecided implementation choice. |
| 9. Select 56 published rows | Mechanically correct; qualifications and Jin need attention. |
| 10. Repeated grey guides | Implements the design; repetition across regions is a presentation choice. |
| 11. Figure scales and count ranges | Project choices; presently insufficient support display. |
| 12. Dirty-file scope | Covers the ordinary command’s executable code adequately. |
| 13. Input guard | Useful and proportionate. |
| 14. Shared area lookup | Correct removal of duplication. |

None of the five deliberately open scientific choices was silently implemented. There is no new co-occurrence filter, recombination, external dataset comparison or local regression. There is no scientific pass/fail classification or change to model selection.

The centred exchange, continental hull, continental model, regional boxes and six-version comparison remain **project choices**, not a reproduced published method. That distinction should remain explicit.

**The code is reasonably simple; the useful cuts are small.**

- Keep the helper changes and substantive tests. Their size is proportionate to the numerical contract.
- The six-line `write_with_header()` duplicates the five-line CSV writer on `cv-compare-tool`. Share one implementation when integrating the branches: approximately **three net lines removed**, with no reporting framework.
- The committed trial contains **1,797 lines**, mostly evidence. Its **188-line generated `published_guide.csv`** is the clearest optional cut; it can be regenerated without losing trial-fit evidence.
- Keep the 757-line all-month support table: it records something the limited fitting trial does not.
- The trial checking scripts contain personal scratch paths, and one reads an uncommitted per-job table. If promoted into verification, give them input arguments and use the retained combined table. Their present form is archival evidence, not a portable public test.
- Add the new tool to the README’s script map.

I dropped nine low-value review candidates after reconciliation, including cosmetic line-ending changes, broader dirty-file scanning, automatic biological-class parsing, forced regional matching of references, and refactoring short prediction routines. None corrected an observed defect.

The tests are otherwise substantial. Their principal publication-metadata gap is that they check starting months more thoroughly than ending months. Add assertions for every distinct start/end period; a second 56-row copy of the metadata is unnecessary.

Omitting `test_config.R` and `test_paths.R` does not invalidate the scientific checks because those modules were unchanged and the new tests exercise their relevant use. Nevertheless, include both in verification. The paths fixture exists in the canonical checkout and matches the frozen inventory; its absence here is avoidable in the proper verification environment.

**Final verdict: ready after the following named changes.**

Before verification, in order:

1. Remove the two mosaic values from complete-transition guides; retain qualified source context. Label single-day, annual and uncertain-period references.
2. Add month-specific support information to the figure and correct the 10% attribution and regional-comparison wording.
3. Save fitter results and exchange cases so their preservation is itself verified.
4. Strengthen the spec with output assertions, the frozen-exchange comparison, all-three-input checks and saved-fit reload checks. Include the two omitted tests, set the exact commit, and launch from the canonical checkout.
5. Add the README entry and enter Jin’s verified values with their source locator.

Before the full run:

1. Use a fresh output directory and retain the exact inputs, configurations, logs and records.
2. Make all-days July the first complete job; measure elapsed time, peak memory and saved-fit size, including both location-500 versions, before choosing parallelism.
3. Check completion against **36 jobs, 216 fit-status records and 4,536 contrast rows**. Exactly four fits should be deliberately skipped; 212 are eligible to be attempted. Report unexpected failures separately from missing jobs.

My answers to the note’s eight questions are:

| Question | Recommendation and precedent |
|---|---|
| **1. Scale** | **Keep the actual 10-point contrast.** Dividing by 0.10 is valid as a local secant response per unit cover, but not as a prediction of complete conversion. Boisier’s equation 2 supports normalisation; Lejeune’s equations 8 and 11 support fraction-times-transition scaling. The present scale is clearer for this curved model. |
| **2. Local eligibility rule** | **Keep counting; do not apply a new filter.** The agreed hull rule remains a project choice. A 10% threshold alone would not reproduce Lejeune’s local procedure. |
| **3. Recombined all-conditions value** | **Defer.** Boisier’s equation 1 uses an independent snow-cover fraction held fixed across cover maps. Chris has already chosen MOD10CM for that purpose. Accepted-retrieval shares should not replace it. A later comparison also needs common eligible cells. |
| **4. Duveiller dataset** | **The strongest next external comparison, as a separate task.** Its monthly transition estimates and sample counts provide a direct field precedent. Decide class mapping and original versus extended estimates first. [Data descriptor, DOI 10.1038/sdata.2018.14](https://doi.org/10.1038/sdata.2018.14). |
| **5. Local regression** | **Do not add it now.** Lejeune §2.3.1 supplies a structural precedent on climate-model output; applying it to these observations requires a separate design. |
| **6. Boreal snow-period references** | **Retain their original periods**, in a small separate table or panel. Euskirchen’s methodology uses different seasonal boundaries for boreal and tundra ecosystems; calendar allocation would be a project judgement. [DOI 10.1088/1748-9326/11/10/105003](https://doi.org/10.1088/1748-9326/11/10/105003). |
| **7. Jin values** | **Yes, enter both.** Table 1 independently confirms \(0.122-0.105=+0.017\) snow-free and \(0.294-0.213=+0.081\) snowy. Preserve the November–January period, latitude band and black-sky definition. [Jin et al. 2002, Table 1 and paragraph 9; DOI 10.1029/2001GL014132](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2001GL014132). |
| **8. Full run** | **Approve after the changes and verification above**, beginning with the timing job. The job count is independently confirmed; the current runtime estimate is not. |

One further question for Chris: **May the two published crop/forest-mosaic comparisons remain on the separate reference page but be removed from the grey guides, which assume a complete forest-to-open exchange?** My recommendation is yes.