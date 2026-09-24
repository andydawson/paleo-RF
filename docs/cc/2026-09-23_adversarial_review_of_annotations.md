# Adversarial review of the annotated scripts, and what was changed

Review produced 2026-09-23 by a second model instance briefed to check every comment against the code and the anchored data and to propose replacement wording. All 32 findings were applied the same day (commit noted in git log). Four of them are defects in the ORIGINAL code rather than in the annotations and are recorded separately: known issues 37-41 in `2026-09-16_known_issues_missing_data_and_code.md` and questions C3(d), C2 and B2b in `questions_for_andria_scientific.md`. The report is kept verbatim below.

---

# Adversarial review of the annotated interp scripts, glossary and walkthrough

Branch `annotated-interp`, 2026-09-23. Scope: comments and the two companion documents only
(code lines were verified byte-identical separately). Every factual claim below was checked
against `tests/anchors/interp-allmonths-2026-09-20/`, `tests/anchors/interp-tail-2026-09-21/`,
`data/`, `output/forcing/forcing_by_period.csv`, the run manifests in `runs/`, and where
needed the installed mgcv 1.9.4 / gratia 0.11.2 source. One 32 MB fitted model
(`output/calibration/calibration_mod8_interp_dec_bluesky.RDS`) was loaded read-only to test
one claim. No pipeline script was run and no file was edited.

Categories: **CORRECTNESS** (must fix: the comment says something the code or data
contradicts, or omits a caveat that changes the reading), **CLARITY** (should fix),
**STYLE** (optional). Ordered most serious first within each category.

---

## CORRECTNESS

### 1. Script 7: the `ice_fort[,1:9]` claim is false, and the `_diff_` tables are not empty
**File** `scripts/7_plot_preds.R` lines 608-609 and 620-623; `docs/cc/2026-09-23_glossary_columns_and_variables.md` line 106.
**Quoted** (7:608) `# Keep the first nine columns of the outline table (drop `ages`, re-added via facets).`
(7:620-623) `# NB `ice_fort$ages` was dropped just above (columns 1:9), so these selections match on a column that no longer exists and return zero rows. The two saved tables are therefore empty apart from their structure. A bug in the original, preserved here`
(glossary:106) `The two `_diff_` files are empty in the current output because of a bug noted in script 7.`
**What is wrong.** `ice_fort` has exactly nine columns (`long, lat, order, hole, piece, id, group, ice_year, ages`; the empty frame at line 116 is created with `ncol=9`), so `[,1:9]` drops nothing. The anchored outputs are not empty: `ice_fort_diff_young.RDS` has 75,065 rows and `ice_fort_diff_old.RDS` 87,742. The real defect is different: `ice_fort$ages` holds the coarse ages (50, 500, 2000, ...) but is compared with `ice_years[idx]`, which holds polygon years (1000, 1000, 2000, ...). Rows match only where the coarse age equals a polygon year. Consequence in the anchor: `young` has outlines for 2-4 ka through 10-12 ka only (the 0.05-0.5 and 0.5-2 ka periods, whose young ends map to the 1,000 BP polygons, get nothing); `old` has outlines for 0.5-2 ka through 10-12 ka (0.05-0.5 ka gets nothing). MAP 8 and MAP 9 therefore draw no ice margin on the two youngest periods' young side.
**Replacement (7:608).** `# Keep the first nine columns, which is all of them: ice_fort has exactly nine, so this line changes nothing.`
**Replacement (7:620-623).** `# NB ice_fort$ages holds the COARSE age each polygon set stands for (50, 500, 2000, ...), but it is compared here with the polygon year (1000, 1000, 2000, ...). The two agree only from 2,000 BP up, so the 0.05-0.5 ka period gets no outline at either end and 0.5-2 ka gets none at the young end; in the anchored run the young table has 75,065 rows and the old table 87,742. A bug in the original, preserved here; script 8 reads the files but does not use them on this path.`
**Replacement (glossary:106).** `The two `_diff_` files are missing the outlines for the youngest one or two periods because of a bug noted in script 7 (the coarse age is compared with the polygon year); they are not empty.`

### 2. Script 8: the CACK kernel is sampled one degree too far south, and the alignment was not "checked"
**File** `scripts/8_radiative.R` header lines 44-49; lines 135-136; lines 202-204. Also `docs/cc/2026-09-23_glossary_columns_and_variables.md` line 123.
**Quoted** (8:45-49) `CACK's file has no coordinate metadata at all, just a 180 x 360 array. The script therefore builds two extra coordinate columns, long360 and lat180, and samples the kernel rasters at those. The check plots ... are commented out in the original; the alignment was checked independently on 2026-09-21 (every cell returns a value).`
(8:135-136) `lat180: latitude shifted to 0..180, which is CACK's row index space (its file carries no coordinates, so row i = latitude i - 90).`
(8:202-204) `The array comes in transposed and upside down relative to the (long360, lat180) index space; flip() then t() puts it the right way round.`
**What is wrong.** Three things. (a) The file does carry coordinates: variables `Latitude[row]` (89.5, 88.5, ..., -89.5) and `Longitude[col]` (0.5, ..., 359.5). They are not NetCDF dimension variables, which is why `raster()` ignores them, but they can be read with ncdf4 and used to check alignment. (b) Checking with them shows the alignment is off by one cell in latitude: for every one of the 2,655 cells in the anchored July table, the stored `rk_cack` equals the file's value at (lat - 1, long), and never at (lat, long). Example, cell 8165 (51.5 N, 279.5 E), July: script stores 143.85, which is the file's value at 50.5 N; the value at 51.5 N is 166.26. The cause: the `t(flip())` raster has extent 0.5..360.5 x 0.5..180.5 with cells centred on integers, so every sample point (x.5, y.5) lies on a cell corner; raster resolves longitude to the correct cell and latitude to the cell below. Longitude is correct. The domain-mean effect is small (July mean kernel 181.0 as sampled vs 180.0 at the true cells, 0.6 %), so question C4's factor-of-two conclusion stands, but the per-cell values are wrong. HadGEM3 and CAM5 were checked the same way at cell 8165 and match the nearest grid point exactly (-3.015305, -3.186117). (c) "Every cell returns a value" is false in any case: `rk_cack` is NA in 5,904 rows of the anchored table (216 cells, December and January, 69.5-73.5 N: polar night, where HadGEM3 and CAM5 store 0 instead).
**Replacement (8:45-49).** `CACK's file stores its coordinates as plain variables (Latitude 89.5 to -89.5, Longitude 0.5 to 359.5) rather than as NetCDF dimensions, so raster() reads it as a bare 180 x 360 array. The script therefore builds two index columns, long360 and lat180, and samples at those. The check plots that would confirm the alignment are commented out in the original. Checked against the file's own coordinates on 2026-09-23: longitude is right, but every cell picks up the CACK value ONE DEGREE SOUTH of its true latitude (the sample points land on cell corners and raster resolves downward). The domain-mean effect is under 1 %, so the CACK/HadGEM3 comparison in C4 is not overturned, but the per-cell values are offset. CACK is also NA in December and January north of 69 N (polar night; 5,904 rows), where the other two kernels are 0. Recorded under C3(d).`
**Replacement (8:135-136).** `lat180: latitude plus 90, meant to be CACK's row index space. CACK rows are centred on half-degrees (89.5 N down to 89.5 S), so this puts every point on a row boundary; see the header for the one-degree offset that results.`
**Replacement (8:202-204).** `The array comes in transposed and upside down relative to the (long360, lat180) index space; flip() then t() reorients it, but the resulting cells are centred on whole numbers while the sample points are at half-degrees, so extract() takes the cell one degree south (header).`
**Also.** Add a line to `questions_for_andria_scientific.md` C3(d): the alignment has now been tested against the file's coordinate variables and is off by one cell in latitude.

### 3. Script 8: `band = 3` is the year 2003, not 2002
**File** `scripts/8_radiative.R` header line 21, line 93, line 196. (Also `questions_for_andria_scientific.md` C3 and the run-manifest config, out of scope here.)
**Quoted** (8:21) `band = 3 selects the year 2002 from a 16-year series, not a sky condition.`
**What is wrong.** The CACK file's `Year` dimension carries the attribute `Year: 2001 = 1` (and the global attribute `Year: Years after 2000 AD`), so index 3 is 2003.
**Replacement.** `band = 3 selects the year 2003 from the 16-year series 2001-2016 (the file says "2001 = 1"), not a sky condition.` Change `cack_band_meaning` at line 93 and the comment at line 196 to match.

### 4. Script 5: the "fraction of data inside the interval" statistic counts polar-night cells as misses
**File** `scripts/5_calibration_eval.R` lines 275-276, 292-306; header lines 21-23; `docs/cc/2026-09-23_glossary_columns_and_variables.md` line 75.
**Quoted** (5:275-276) `# Flag whether each observation falls inside its cell's 95% interval; for a well calibrated model about 95% should.`
(glossary:75) `Fraction of cells whose observed albedo lies inside the model's 95% simulation interval.`
**What is wrong.** `frac_in = sum(in_credible, na.rm=TRUE)/n()` divides by all 2,860 cells, including those whose observed albedo is NA (1,109 in December, 694 in January, 400 in November). The anchored table shows exactly that: 0.56 (Dec), 0.70 (Jan), 0.80 (Nov) against 0.90-0.94 in every other month; dividing by the non-NA counts instead gives about 0.92 in all twelve months. As written, the comment and the table invite the reading that the winter models are badly calibrated, which the data do not support. A statistician would insist the denominator be stated.
**Replacement (5:275-276).** `# Flag whether each observation falls inside its cell's 95% interval. NB the fraction computed below divides by ALL cells, including the ones with no observed albedo (polar night: 1,109 in December, 694 in January, 400 in November), which count as misses. That is why the anchored table shows 0.56 for December and 0.70 for January against about 0.92 elsewhere; on the cells that have data, every month is near 0.92. (For a well calibrated model about 0.95 of the cells WITH data should fall inside.)`
**Replacement (glossary:75).** `Fraction of ALL 2,860 cells whose observed albedo lies inside the model's 95% simulation interval; cells with no observation (polar night) count as outside, which is why Nov-Jan are low.` Add the same caveat to header lines 21-23.

### 5. Script 5: simulate() does not return NA for cells with NA albedo
**File** `scripts/5_calibration_eval.R` line 121.
**Quoted** `# See the header. Returns a 2,860 x 100 matrix (rows with NA albedo come back NA).`
**What is wrong.** gratia's `simulate.gam` computes `mu = predict(object, newdata = data, type = "response")` and draws from the family's `rd()`; the response column is never evaluated. Tested on the December model with the anchored calibration table: 2,860 rows, 0 NA in the simulations and 0 NA in `predict()`, despite 1,109 NA observations. The NA rows only disappear later, when `alb_data` is NA in the comparisons and plots.
**Replacement.** `# See the header. Returns a 2,860 x 100 data.frame with a value for EVERY cell, including the 1,109 December cells with no observed albedo: prediction needs only the predictors. Those cells drop out later, where the observed value is compared (see the note on the fraction-inside statistic below).`

### 6. Scripts 7a and 8: ALB_diffs has 806,172 rows, not ~764,640
**File** `scripts/7a_alb_diff_full.R` header line 25; `scripts/8_radiative.R` header line 25.
**Quoted** (7a:25) `data/ALB_diffs_bluesky.RDS       ~764,640 x 21   (anchored; reproduces byte for byte)`
(8:25) `data/ALB_diffs_bluesky.RDS                    ~764,640 x 21, from script 7a`
**What is wrong.** The anchored file is 806,172 x 21 (2,866 cells). 764,640 (= 2,655 cells x 12 months x 24 pairs) is the row count AFTER script 8 trims to 27-74 N, which removes exactly the 211 cells that lack one or more slices. Script 8's output count (764,640 x 56) is right.
**Replacement (7a:25).** `data/ALB_diffs_bluesky.RDS       806,172 x 21   (anchored; reproduces byte for byte)` and on line 26 add `2,866 cells; 211 of them (all south of 27 N or north of 74 N) have fewer than 24 pairs.`
**Replacement (8:25).** `data/ALB_diffs_bluesky.RDS                    806,172 x 21, from script 7a (764,640 after the latitude trim below)`.

### 7. Script 9: "about 34x" contradicts the script's own 3.8 %
**File** `scripts/9_forcing_barplot.R` lines 74-77.
**Quoted** `overstates the Holocene signal by roughly the ratio of Earth's area to the study area (about 34x).`
**What is wrong.** Line 173 prints the study area as 3.8 % of Earth; `forcing_by_period.csv` gives area 1.922e13 m2, and 5.101e14 / 1.922e13 = 26.5 (domain mean 8.03 / global equivalent 0.303 = 26.5). The questions file (C5) says "about 27". 34x is presumably from an earlier, larger domain.
**Replacement.** `(about 27x: the study area is 1.92e13 m2, 3.8 % of Earth's surface).`

### 8. Script 9 A1: `veg_ice_thresh` is not "the only family with no missing values"
**File** `scripts/9_forcing_barplot.R` lines 39-42.
**Quoted** `Chosen because it is the only family with no missing values over the whole domain`
**What is wrong.** After the 27-74 N trim, `rf_hadgem_veg_ice_parts` (and the other `_parts` totals) have zero NAs too; before the trim both `veg_ice_thresh` and `veg_ice_parts` had 4,980. The stated reason does not distinguish the two families, so the choice is unjustified as written.
**Replacement.** `Chosen because it combines the vegetation and the ice contribution and, like the _parts family, has no missing values over the trimmed domain. Threshold rather than area-weighting was preferred because it is closer to the binary ice mask used elsewhere in the pipeline; the _parts alternative is reported in A2 and the choice is question C5(a).`

### 9. Script 4: the "three hours of pure waste" is attributed to the wrong loop
**File** `scripts/4_calibration_model.R` header lines 76-81; lines 402-405.
**Quoted** (4:78-79) `The last of these is the three hours of pure waste noted in the run manifest.`
(4:404-405) `It changes nothing and costs about three hours.`
**What is wrong.** The manifest (`runs/2026-09-19_1013_interp-run-1-to-6_RECONSTRUCTED.md`) says: "The last 3 h were a redundant refit of the non-interp May ladder", i.e. the point-path code that this copy removed. Section 4 refits model 8 twelve times at the manifest's "1 to 5 min" each, so under an hour. The header also says "Every other model takes one to five minutes per month", which contradicts three hours for twelve model-8 fits.
**Replacement (4:78-79).** `The last of these costs twelve more model-8 fits, roughly half an hour to an hour. (The "3 h of waste" in the run manifest refers to a non-interp refit that this copy no longer contains.)`
**Replacement (4:404-405).** `It changes nothing and costs about an hour.`

### 10. Script 7a: the "mutually exclusive" totals silently return 0 for ice readvances
**File** `scripts/7a_alb_diff_full.R` lines 447 and 453-454; `docs/cc/2026-09-23_glossary_columns_and_variables.md` line 119.
**Quoted** (7a:453-454) `# Totals: whichever of the vegetation or ice difference is present for each pair (they are mutually exclusive by construction), then NA where ice was missing.`
**What is wrong.** There is a fourth case: young end ice, old end vegetation (a readvance that survives the one-step smoothing). Then `alb_diff_veg_thresh` is NA (blanked by `is_ice_young`) and `alb_diff_ice_thresh` is NA (`alb_ice_thresh` at the old end is NA because it was vegetation), and `rowSums(na.rm = TRUE)` turns two NAs into 0. In the anchored table 2,844 pairs still have `ice_frac_young > ice_frac_old` after adjustment and 36 of them cross the 0.5 threshold; those 36 carry a confident zero that later receives a kernel. This is question C2's point and belongs beside the code.
**Replacement (7a:453-454).** `# Totals: whichever of the vegetation or ice difference is present for each pair, then NA where ice was missing. The two are exclusive in the three expected cases (veg->veg, ice->veg, ice->ice) but NOT when ice ADVANCES across the threshold (young end ice, old end vegetation): there both are NA and rowSums(na.rm = TRUE) yields 0, a silent "no change". 36 pairs in the anchored run (question C2).`
**Replacement (glossary:119).** `| `alb_diff_veg_ice_thresh`, `alb_diff_veg_icesc_thresh` | The vegetation and ice threshold terms combined (exclusive except for a readvance across the 50 % line, which gives 0 rather than NA; C2). |`

### 11. Script 7a: cell-area figures are wrong
**File** `scripts/7a_alb_diff_full.R` lines 201-202.
**Quoted** `A 1-degree cell shrinks towards the pole: 12,300 km^2 at 20 N, 3,500 at 79 N.`
**What is wrong.** The anchored `area_km2` runs from 11,792 (17.5 N) to 2,465 (78.5 N); 10,967 at 27.5 N; 7,697 at 51.5 N. 12,300 is the equatorial value.
**Replacement.** `A 1-degree cell shrinks towards the pole: about 11,800 km^2 at 17.5 N (the southern edge of the grid), 7,700 at 51.5 N, 2,500 at 78.5 N.`

### 12. Script 6: the stacked summary file is a plain data.frame, converted here, not "by later scripts"
**File** `scripts/6_prediction_model.R` lines 122-126.
**Quoted** `.groups = 'keep' leaves the result grouped, which is why the saved summary is a grouped tibble rather than a plain data.frame; later scripts convert it.`
**What is wrong.** True of the twelve per-month files. The stacked file that scripts 7 and 7a read is a plain `data.frame` (anchor class: `data.frame`) because the stacking loop at line 166 wraps each month in `data.frame(...)`.
**Replacement.** `.groups = 'keep' leaves the result grouped, so each per-month summary file is a grouped tibble. The stacking loop below wraps every month in data.frame(), so the file scripts 7 and 7a read is a plain data.frame.`

### 13. Script 1: cell counts and the reason for missing cell-slices
**File** `scripts/1_veg_lct_prep.R` header lines 29-30 and 36-38.
**Quoted** (1:29-30) `(2,860 cells x 25 slices x 200 draws x 3 classes would be 42.9 million rows; a few cell-slices under ice are absent, hence 41.96 million.)`
(1:38) `69,936 = 2,860 x 25 minus the cell-slices missing under ice.`
**What is wrong.** The paleo table contains 2,870 distinct cells; 2,860 is the number present at 50 BP (ten cells appear only at older slices). 2,870 x 25 = 71,750, so 1,814 cell-slices (2.5 %) are absent, not "a few". The run manifest also says 2,870. Whether the absentees are "under ice" was not verified here, and the walkthrough shows cell 8165 HAS values while under ice, so the reason should be softened.
**Replacement (1:29-30).** `(2,870 cells appear somewhere in the 25 slices; 2,870 x 25 x 200 x 3 would be 43.05 million rows. 1,814 cell-slices, about 2.5 %, are absent, hence 41.96 million. Which ones, and why, has not been checked; ice-covered cells are NOT systematically absent, see the walkthrough's cell 8165.)`
**Replacement (1:36-38).** `69,936 rows: 2,870 cells over 25 slices minus 1,814 absent cell-slices. Only 2,860 of the cells are present at 50 BP, which is why the modern table is shorter.`

### 14. Script 4 header: "mgcv copes" hides the rank deficiency (B1)
**File** `scripts/4_calibration_model.R` lines 47-50.
**Quoted** `the smooth is effectively two-dimensional and mgcv copes, but it is why a model with three SEPARATE cover smooths (model 5) is asking a partly redundant question.`
**What is wrong.** mgcv reports every model 6-8 fit as rank deficient (the December model 8: rank 744 of 748 coefficients), and any prediction row whose fractions do not sum to one is evaluated in the direction the data never spanned. This is question B1, which the header does not cite (it cites B4 and B8 only). A statistician would want it stated where the term is defined.
**Replacement.** `the smooth is effectively two-dimensional. mgcv fits it but reports the model as rank deficient (e.g. rank 744 of 748 for December), and any prediction row whose fractions do not sum to exactly one is evaluated in the empty direction (question B1). It is also why a model with three SEPARATE cover smooths (model 5) is asking a partly redundant question.` Add B1 to the list at line 63.

### 15. Script 7: the `subset(year==year)` explanation has the shadowing backwards
**File** `scripts/7_plot_preds.R` lines 452-455.
**Quoted** `compares the column with itself (the loop variable shadows the column name inside subset)`
**What is wrong.** The conclusion is right (verified: `subset()` evaluates its condition with the data frame's columns first, so both `year`s are the column and every row is kept). But it is the column that shadows the loop variable, not the reverse. The `ice_sub` subset on the next line works because `ice_sub` has no `year` column.
**Replacement.** `# NB `subset(alb_grid_sub, year==year)` compares the column with itself: inside subset() the data frame's columns take precedence over variables outside it, so the loop variable never gets a look-in and every row passes. Each page therefore over-plots ALL eight slices; only the ice overlay changes (ice_sub has no `year` column, so there the loop variable IS used). A bug in the original, preserved here.`

### 16. Script 2: "the maximum is 0.83" and "breaks the fit"
**File** `scripts/2_calibration_lct_bluesky.R` lines 246-250.
**Quoted** `an exact 0 (or 1) has zero likelihood and breaks the fit. Any albedo that came out as exactly zero is therefore nudged to 0.0001. (Exact ones do not occur in this data; the maximum is 0.83.)`
**What is wrong.** 0.83 is the raster maximum (0.826); the sampled calibration table's maximum is 0.81. More importantly, mgcv's `betar` does not fail on a 0: it truncates the response to `[eps, 1-eps]` with `eps` about 2e-14, which on the logit scale is about -31 (versus -9 for 0.0001). So the replacement is a choice of where to put the zeros, not something the fit requires. The anchored table has no zeros (B6).
**Replacement.** `# The calibration model in script 4 is a beta regression, which describes a quantity strictly BETWEEN 0 and 1. mgcv would not fail on an exact 0: it silently clips the value to about 1e-14, which is logit -31 and hugely influential. Nudging zeros to 0.0001 (logit -9) first is a milder choice. In the interp table no zero occurs (question B6); the sampled maximum is 0.81.`

---

## CLARITY

### 17. Script 9: the annual mean treats the kernels unequally where CACK is NA
**File** `scripts/9_forcing_barplot.R` line 64-65 (A6) and line 161.
**Quoted** `# A6. Months. Averaged with equal weight to an annual mean, after the period sum.`
**Problem.** `mean(rf, na.rm = TRUE)` over months: for CACK the December and January rows north of 69 N are NA and are dropped, so the "annual" mean there is over ten or eleven months; for HadGEM3 and CAM5 the same cell-months are 0 and are included. Small effect, but the kernel comparison is not like for like at those cells.
**Replacement.** Add to A6: `NB months whose kernel is NA (CACK, Dec/Jan north of 69 N) drop out of the mean, whereas HadGEM3 and CAM5 store 0 there and stay in; the three kernels are therefore averaged over slightly different month sets at 216 northern cells.`

### 18. Script 9: the recovered recipe is silently restricted to script 8's trimmed domain
**File** `scripts/9_forcing_barplot.R` line 315.
**Quoted** `d7 = inner_join(d7, distinct(d, cell_id, month, rk_hadgem, area), by = c('cell_id','month'))`
**Problem.** `d` has already been cut to 27-74 N and to cells complete within their period, so the join drops any script-7 cell outside that set. The April-2024 recipe (per the comment above) did not trim; the comparison with the slide in C5 inherits this difference without saying so.
**Replacement.** `# Kernel and area per cell-month come from `d`, which has already been trimmed to 27-74 N and to period-complete cells (A4, A10); the join therefore applies the same trim to the recipe, which Andria's April-2024 code did not.`

### 19. Script 9: "A2 below" does not exist
**File** `scripts/9_forcing_barplot.R` line 45 (also 99, 178, 303).
**Quoted** `A2 below reports all of them, because the choice matters.`
**Problem.** The assumption list runs A1, A3, A4, ...; A2 is referred to four times but never stated.
**Replacement.** Insert after A1: `# A2. Variant sensitivity. All six variants with complete coverage are aggregated the same way and plotted side by side (figures/forcing_barplot_variant_sensitivity.pdf).`

### 20. Script 5: the "unique per cell in practice" reasoning is the wrong reason
**File** `scripts/5_calibration_eval.R` lines 136-138.
**Quoted** `Grouping on `month` here groups on the observed albedo value, which is unique per cell in practice, so the result is still one row per cell.`
**Problem.** The result is one row per cell because `x, y` are in the grouping; the albedo value adds nothing and is not unique (in December 1,109 rows share the value NA). An undergraduate will take away that uniqueness of the response is doing the work.
**Replacement.** `Grouping on `month` here means grouping on the observed albedo value, which is redundant: x and y already identify a cell, so the result is one row per cell whatever the albedo (including the NA cells in winter).`

### 21. Script 7a: the readvance adjustment's edge cases
**File** `scripts/7a_alb_diff_full.R` lines 372-376.
**Quoted** `the offending value is replaced by the mean of its two neighbours (in a copy, ice_frac_adj). Cases with more than one such step are counted.`
**Problem.** Two facts a reader needs: the value replaced is the YOUNGER slice's (index i, where diff[i] < 0), and if the offending step is the first pair (i = 1) the expression `ice_frac_adj[i - 1]` is empty and the assignment errors (question C2; it did not happen in the anchored run). Also the fix is applied once; 2,844 pairs still show ice growing afterwards and are only counted.
**Replacement.** `the YOUNGER slice's value is replaced by the mean of the values either side of it (in a copy, ice_frac_adj). The fix is applied once, not iterated: 2,844 pairs in the anchored run still show ice growing afterwards and are merely counted below. If the first pair were the offender the code would error (index 0); it did not occur here. Question C2.`

### 22. Script 7: "Drop cells that are not present at all eight slices" is not what the code does
**File** `scripts/7_plot_preds.R` lines 287-288.
**Quoted** `# Drop cells that are not present at all eight slices (table() counts rows per cell; with 12 months, a complete cell has 96 rows; fewer than 8 catches only near-empty cells).`
**Problem.** The first clause states an intent the second clause admits is not achieved. Lead with what happens.
**Replacement.** `# Meant to drop cells missing from some slices, but the threshold is 8 rows against 96 for a complete cell (8 slices x 12 months), so it removes only near-empty cells. As original.`

### 23. Script 1: the elevation non-reproducibility claim is unverified
**File** `scripts/1_veg_lct_prep.R` lines 123-124.
**Quoted** `the service can return slightly different values from one day to the next, so `elev` is the one column of this script's output that is NOT bit-for-bit reproducible.`
**Problem.** The anchors README says only that elevation is fetched at run time; nobody has shown the values change. State what is known.
**Replacement.** `it depends on a remote service, so `elev` is treated as not bit-for-bit reproducible (the anchors README compares it with a tolerance); whether repeated lookups actually differ has not been tested.`

### 24. Walkthrough: "+ noise" on the logit scale misdescribes a beta GLM
**File** `docs/cc/2026-09-23_walkthrough_one_cell.md` lines 213-214.
**Quoted** `logit(albedo) = smooth(lon, lat) + smooth(elev) + smooth(OL, ET, ST) + noise` / `fitted by beta regression.`
**Problem.** In a beta regression the smooths determine the logit of the MEAN and the scatter is a beta distribution around that mean on the albedo scale; there is no additive noise on the logit scale. This matters because the next sections lean on "the scatter the model expects".
**Replacement.** `logit(mean albedo) = smooth(lon, lat) + smooth(elev) + smooth(OL, ET, ST)` / `albedo ~ Beta(mean, precision)`, `i.e. the smooths set the average and a beta distribution describes the scatter around it.`

### 25. Script 8 trim: say why 27-74 N, since script 7a already found out
**File** `scripts/8_radiative.R` lines 220-221.
**Quoted** `Outside that band the land cover reconstruction is sparse or absent; this is the study domain used for continental totals.`
**Problem.** "Sparse or absent" is asserted; the checkable fact is in script 7a's coverage check: exactly the 211 cells outside the band lack one or more slices (114 south, 97 north, none inside).
**Replacement.** `Keep only cells between 27 N and 74 N. Script 7a's coverage check shows that the 211 cells with fewer than 25 slices are exactly those outside this band (114 south, 97 north), so the trim leaves a complete cell set: 2,655 cells, 764,640 rows.`

### 26. Undefined jargon: REVEALS, ka, ERF
**Files** `scripts/1_veg_lct_prep.R` line 15 (`pollen -> REVEALS -> spatial interpolation`); `scripts/7_plot_preds.R` line 148 and glossary line 132 (`ka`); `scripts/9_forcing_barplot.R` lines 74, 86 (`ERF`); glossary has none of the three.
**Problem.** The stated audience has not met any of them.
**Replacement.** Glossary "Conventions" table: `| **REVEALS** | The pollen-to-vegetation model (Sugita 2007) that converts pollen percentages into land-cover fractions before the spatial interpolation; run outside this repository. |`, `| **ka** | Thousand years before present; 8 ka = 8,000 BP. |`, `| **ERF** | Effective radiative forcing, the IPCC's global-mean forcing measure (W/m2); what the AR6 tables in script 9 hold. |`. Script 1 line 15: `pollen -> REVEALS (a pollen-to-vegetation model) -> spatial interpolation`.

### 27. Script 7 header: script 8 makes no maps on this path
**File** `scripts/7_plot_preds.R` lines 8 and 150; glossary line 153.
**Quoted** (7:8) `the ice outlines (for script 8's maps)`; (7:150) `# Saved for script 8's maps.`
**Problem.** Script 8's header says the outlines are "loaded but not used on this path"; the two headers disagree.
**Replacement.** `the ice outlines (script 8 loads them; its map code is commented out on this path)`.

### 28. Script 4 header: month counts
**File** `scripts/4_calibration_model.R` lines 15-17.
**Quoted** `2,827 from March to September, 2,166 in January, 1,751 in December.`
**Problem.** Anchored non-NA counts: Mar-Sep 2,827, Oct 2,826, Feb 2,765, Nov 2,460, Jan 2,166, Dec 1,751. The omissions (Feb, Oct, Nov) are the months a reader will look for.
**Replacement.** `2,826-2,827 from March to October, 2,765 in February, 2,460 in November, 2,166 in January, 1,751 in December.`

### 29. Script 5/6: warn that gratia's own wording says "posterior"
**File** `scripts/5_calibration_eval.R` lines 33-39; `scripts/6_prediction_model.R` lines 28-36.
**Problem.** The headers are right (verified in gratia 0.11.2 source: `mu = predict(..., type = "response")`, then the family's `rd()` with fixed coefficients). But `?simulate.gam` in gratia describes the result as "posterior simulations" and "posterior draws", which is exactly the misreading question A2 is about. One sentence would inoculate a reader who opens the help page.
**Replacement (add to 6:33).** `(gratia's help page calls these "posterior simulations"; do not read that as coefficient uncertainty. Its code is predict() for the mean, then the family's random-deviate function.)`

---

## STYLE

### 30. Header section names are not uniform
Scripts 1, 2, 5, 6 use `RUN TIME`; 4, 7, 7a use `COST`; 8 uses `RUN TIME`; 9 has `RUN TIME` but puts a dated preamble and `ASSUMPTIONS` before `WHERE THIS SITS`. Script 9's `WRITTEN 2026-09-21` block duplicates its own second paragraph. Suggest one order everywhere: WHERE THIS SITS / WHAT COMES IN / WHAT GOES OUT / (script-specific explanatory blocks) / RUN TIME / HOW TO LAUNCH, and `COST` -> `RUN TIME`.

### 31. Memory figures are unverified
`scripts/7_plot_preds.R` line 54 (`Memory to about 12 GB`) and `scripts/7a_alb_diff_full.R` line 47 (`Memory reaches about 12 GB`): the run manifests record wall time (61.7 and 51.7 min, which match the headers) but no memory. Say `(memory not recorded in the manifest; observed around 12 GB)` or drop.

### 32. Small counts
- `scripts/7_plot_preds.R` line 552: `about 2,844` cells; anchored 2,834.
- `scripts/7_plot_preds.R` line 38: pairs are `450 to 2,000 years apart` (50->500 is 450; the last is nominally 2,000 but really 1,500), and 7a's are `150-to-500-year pairs`.
- `scripts/7a_alb_diff_full.R` lines 272-273: `almost all` -> `all 211 of them (114 south of 27 N, 97 north of 74 N)`.
- glossary line 148: script 7 attaches cell ids and centres but not areas; `after cell ids (and, in 7a, areas) are attached`.
- walkthrough line 174: 80.5 W is about 70 km west of the Ontario-Quebec border at that latitude; `the James Bay lowlands near Moosonee, Ontario`.

---

## Verified and found correct (so the caller need not re-check)
- Walkthrough arithmetic, all of it: land-cover rows, the twelve albedo values, the script-6 means and the July 8,000 BP interval (0.046-0.108), ice fractions, 0.078 - 0.68 = -0.602 (exact -0.60207), x100 x -3.015 = +181.5 (exact 181.54), CAM5 +191.8, CACK +86.6, +0.7 / -11.1 rows, annual mean +93.0 with every other pair within 5.5, period sum 94.5, area 7,697 km2, 94.5 x 7.70e9 / 5.101e14 = 0.00143, domain mean 8.03 and global equivalent 0.303, and "every 0.01 of ice albedo is 3 W/m2".
- Sign conventions: `-diff()` of a young-to-old series is young minus old everywhere it is claimed; `_parts` total equals the difference of the mixed cell albedo (algebra checked); HadGEM3/CAM5 x100 and CACK sign flip as described.
- Dimensions: blue-sky raster 280 x 500 x 12, 0.25 deg, values 0.0037-0.826; grid 62 x 299; Dalton 26 layers 116 x 62; HadGEM3 144 x 192 (1.25 x 1.875); calibration table 2,860 x 18 with no zeros; AIC table (model 8 lowest in 11 of 12 months, May prefers 7 by 3); stats table 12 x 5; script-6 files 839,232 x 13 and x 9; script-7 diffs 233,880 x 21; RF table 764,640 x 56 with 2,655 cells; pairs per period 2, 3, 4, 4, 4, 4, 3.
- `x == long` and `y == lat` in every row of both difference tables (glossary line 13).
- mgcv 1.9.4 has no `simulate.gam`; `betar()` has `$rd` and no `$simulate`; gratia supplies the method (script 5 lines 57-60).
- Run times in the headers match the manifests (script 1 ~4 min, 2 ~20 min, 4 ~27 h with model 7 ~2 h/month, 5 ~4 min, 6 ~15 min, 7 62 min, 7a 52 min, 8 24 s).
