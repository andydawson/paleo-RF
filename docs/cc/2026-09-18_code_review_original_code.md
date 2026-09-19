# Code review: paleo-RF

**Scope.** Independent review of the original code at commit `c9d525e`
("resurrecting project"; branches `main` and `legacy`, identical). Every
`scripts/*.R` and `scripts/archive/*.R` citation below (`file:line`) refers to
that commit, read from the read-only `legacy` worktree; Chris's `[run-nointerp]`
/ `[run-may]` edits on `chris-dev` were not reviewed. Context documents used:
`CONTRIBUTING.md`, `AGENTS.md`, `docs/cc/CODE_MAP.md`, `docs/cc/KNOWN_ISSUES.md`
(cited as KI#n; not repeated here), `docs/cc/METHODOLOGY_QUESTIONS.md`.
Strategic frame from the 2026-09-17 meeting: the point / non-interp path is
dropped, the interp full-grid all-months path is the product, land-cover maps
are fixed external inputs, per-month calibration models stay for now, the
snow/water-budget branch is abandoned. Claims about R behaviour marked
*(tested)* were checked in the project's micromamba env (R 4.4, mgcv 1.9.4,
gratia 0.11.2, terra 1.9.50) against the committed data files. Review date:
2026-09-18.

---

## 1. Executive summary

The pipeline is scientifically coherent and the core numerical steps (beta GAM
calibration, hindcast, ice/vegetation decomposition, kernel multiplication) are
recoverable, but the code is a lab notebook, not software: 10,300 lines of
which ~45% are commented-out earlier versions, no functions, no configuration,
no seed, no tests, and results that depend on script order and the global
environment. The three biggest structural problems are: **(1) duplication** —
every script carries the non-interp path and the interp path as two near-copies
(scripts 2, 5, 6, 7 each contain the same 100-500 line block twice), and the
March-only non-interp code still runs and overwrites committed data;
**(2) hidden state** — projections, month vectors, age vectors, breaks, `k`,
`nthreads`, and the `alb_prod` switch are re-declared in 7-10 places and
outputs are addressed by `paste0` strings that disagree between writer and
reader (KI#13); **(3) uncertainty is misrepresented** — `simulate()` on the GAMs
(via gratia) draws beta observation noise around the point prediction and never
samples the coefficients, so the "posterior" sd/quantiles carried to the
figures are residual scatter at calibration dispersion, not model uncertainty,
and the sample index column is all `NA` in the committed file. The recommended
shape of the refactor is an `R/` folder of small documented functions, one
config list, a `{targets}` pipeline for the multi-hour fits with cached
intermediates, `renv` for the environment, regression tests against the
committed March predictions and the first interp run, and deletion of the
non-interp and archive code into a git tag.

---

## 2. Design problems

**Duplicated code between interp and non-interp halves and across scripts.**
`2_calibration_lct_bluesky.R:46-231` and `:238-420` are the same extraction
block twice (the second even re-reads the GeoTIFF and re-saves the same
`figures/albedo_maps_*` files with a different palette, `:273-301`);
`5_calibration_eval.R:21-104` and `:122-160` load and re-save the selected model
twice, and `:721-805` is a third live copy for `nov`; `6_prediction_model.R:114-154`
is the non-interp copy of `:30-79` (KI#15); `7_plot_preds.R:1345-1830` is a
near-verbatim repeat of `:99-1089`; `7_plot_preds.R:694-741` and
`7a_alb_diff_full.R:434-612` are two definitions of the same differences
(KI#36); `4_calibration_model.R:358` (`mod_spatial_elev_cover`) is the mod8
formula at `:275` and `:518`, so mod8 is fitted three times per month. The
eight `bam()` calls in `4_calibration_model.R:205-282` differ only in the
formula: one function and a list of formulas would replace 90 lines.

**Global state and hard-coded constants.** The Albers string is declared in 7
scripts (`1:19`, `2:29`, `6:20`, `6se:20`, `8:17`, `GCM:26`, `beta_veg:14`); the
month vector 10 times (`4:197,301,349,439` alone has four); `ages` in `7:32`,
`7a:9`, `8:31` plus `years`/`ages_sub` variants at `7:34,229,782,1390`,
`7a:11,191`, `8:33`, `6se:284`; `breaks_alb` twice inside one script (`7a:18`
then `:198`); `ctrl <- list(nthreads=8, ...)` five times (`4:11,200,303,351,441`;
KI#28); `k=500/50/200` in 24 formulas. Domain filters are literals with no
name: `x > -170` (`7a:140`, "not sure about this"), `long < -60` (`7:305`),
`lat > 27 & lat < 74` (`8:253-254`), ice threshold `0.5` (`7a:288,469-470`),
`cell_count < 25` (`7a:332`), buffer `350000` (`GCM:131`).

**Reliance on script order and the global environment.** Formulas are
`get(month) ~ ...` (`4:205` and 23 more), so the response is resolved from the
loop variable in `.GlobalEnv` at fit time. Scripts use `ggplot2`, `sp`,
`units`, `loo` without loading them (KI#12). `5:13` reads the non-interp
calibration table only so the legacy tail at `:894-1065` can use it. The
"selected" model is whatever script 5 last saved (`5:33,133,746`), not a
recorded decision.

**File-name-string coupling.** Every hand-off is a `paste0()` path: 41
`readRDS`/`saveRDS` pairs across scripts 4-8. Writer and reader disagree at
`4:365` (`'..._cover', month` with no underscore) vs nothing reading it,
`4:375-426` (`output/calibration/`) vs `5:342-349` (`output/calibration/spatial_experiment/`)
vs `6se:65-100` (`output/calibration/`), and `5:342` expects a
`calibration_mod_interp_selected_*` file inside `spatial_experiment/` that is
never written. Results are written into `data/` next to inputs (`6:127,141,154`,
`7:87,741,848-849`, `7a:617`), which is why the working tree now shows 10
modified tracked data files.

**Dead and commented-out code.** Comment lines / total: script 1 44%, 2 28%,
3 24%, 4 **69%** (573 of 830), 5 46%, 6 52%, 7 **55%** (1,147 of 2,085), 7a
55%, 8 39%. Live-but-dead: `1:36-38` (`foo`, `cell_id` unused), `4:20-21`,
`2:131,160,321,349` (`vname`), `2:306-313` (`cols_fill` assigned twice, never
used in that loop), `7:859-860,873-887,889-904` (each scale assigned twice),
`7a:317-346` (cell-count analysis whose result `cell_id_missing` filters
`alb_grid_full_new`, which is never used), `8:25-27,304-343` (KI#26),
`beta_veg_lct_modern.R` whole file, `thornthwaite.R`, `GCM_snow_prob.R`, all
of `archive/`.

**Mixed spatial stacks.** `sp` (`SpatialPoints`, `over`, `spTransform`,
`proj4string<-`: `1:68-73`, `7:64-65,206-214`, `7a:101-102`, `8:103-110`),
`raster` (`brick`, `extract`, `xyFromCell`, `projectRaster`: `7a:204-207`,
`8:58,148-226`, `GCM:122-123`), `terra` (`rast`, `vect`, `project`, `extract`:
`2:39-54`, `7a:84-116`) and `sf` (`st_as_sf`, `st_area`: `7a:217-218`) are all
used, sometimes in one function chain (`7a:101-116` builds an `sp` object,
converts to `terra`, reprojects, extracts). `+init=epsg:4326` (`2:53,65,245`,
`3:54,341`) is PROJ-deprecated. Target `terra` + `sf` only.

**Loops that grow data frames with `rbind`.** `5:158,366`, `6:98,102`,
`6se:211`, `7:71,727,819,826,1641`, `7a:585`, `GCM:142-202`. `7a:434-612` is
the worst: for each of ~3,000 cells x 12 months it scans the full ~900k-row
frame with `which()` (`7a:442`), calls `merge()` (`7a:450`) and `rbind`s 24
rows; quadratic in cells. A `group_by(cell_id, month) %>% arrange(year) %>%
mutate(across(..., ~ -diff))` (after `tidyr::complete(year = ages)`) does the
whole thing in one vectorised pass.

**Reprojection inside loops.** `7a:111` reprojects the Dalton ice layer once
per age (25 times); `GCM_snow_prob.R:122-123,145-146,165-166,185-186` re-opens
and reprojects the NetCDF brick 12 x 24 x 4 times (KI#24).

**Non-deterministic steps.** `elevatr::get_elev_point(src="aws")` at `1:96,230`
(KI#27); `simulate()` at `5:59,146,355`, `6:49,130`, `6se:122-154` with no
`set.seed()` anywhere live (only commented at `6:184,254`). This is why the
March predictions reproduce to corr 0.999 rather than bit-identically.

**Output directories.** `output/calibration`, `output/prediction`,
`output/forcing`, `figures/` are never created (KI#1) and there is no single
place that names them.

**No separation of configuration, functions and execution.** Zero function
definitions in the numbered scripts (`thornthwaite.R` is the only function in
the repo); every script is a linear transcript with `print()`, `summary()`
(`5:29,129,740` — result discarded), `hist()` (`7a:118`) and interactive
`ggplot()` calls whose output goes to `Rplots.pdf`.

---

## 3. Potential bugs and correctness risks

Numbered R1..R18; each has file:line, what happens, how to test.

**R1. `simulate()` gives observation noise, not model uncertainty**
(`5:59-61,146-148,355-357`, `6:49-51,130-132`, `6se:122-154`). With `gratia`
attached, `simulate(bam_object, nsim, data)` dispatches to
`gratia:::simulate.gam`, which computes `mu <- predict(object, newdata=data,
type="response")` at the coefficient point estimate and returns
`rbeta(Theta*mu, Theta*(1-mu))` draws *(tested; the commented-out
`fix.family.rd(betar())$rd` at `6:156-166` shows the author saw this)*. So
`alb_sd`, `alb_lo`, `alb_hi` in every summary file are the beta residual
spread at the calibration dispersion `phi`, identical for a calibration cell
and a 11.5 ka cell with covariates far outside the calibration cloud; the
coefficient covariance `vcov(mod)` never enters. The "fraction of data in the
credible interval" statistic (`5:206-244`) is therefore a check of the
dispersion estimate, not of predictive coverage, and the sd/CV maps in script 7
are not uncertainty maps. *Test:* for one month, compute
`sqrt(mu*(1-mu)/(1+phi))` with `phi <- mod$family$getTheta(TRUE)` and
correlate with `alb_sd` from the summary; expect ~1. *Remedy:* draw
coefficients (`gratia::fitted_samples(..., method="gaussian")` or the `rmvn`
block already sketched at `6:172-199`), optionally add observation noise on
top, and state which is which.

**R2. Sample index is `NA` in every committed sample file** (`6:60`,
`6se:173`, `6:139`). `substr(iter, 2, 4)` assumed column names `X1..X100`;
gratia names them `sim_1..sim_100`, giving `"im_"` -> `NA` *(tested)*. The
committed `data/paleo_predict_gam_samps_bluesky.RDS` has 445,300 rows with
`iter` all `NA` *(checked)*. Harmless for the summaries (they group without
`iter`) but any per-draw propagation (e.g. differencing draws) is impossible.
*Test:* `sum(is.na(readRDS(...)$iter))`.

**R3. No seed** (see section 2). *Test:* run script 6 twice, `all.equal()` the
summaries. *Remedy:* `set.seed()` once from config, and pass `seed=` to
`simulate()`.

**R4. `get(month)` formulas** (`4:205-518`, 24 sites). `predict()` and
`simulate()` work because `predict.gam` drops the response *(tested: predict is
identical after `rm(month)` and with `month <- "may"`)*. The risks are
provenance and refitting: `formula(mod)` prints `get(month) ~ ...`, the model
frame column is literally `"get(month)"`, so a saved model carries no record
of its response; `update(mod)` or `gam.check()`-driven refits would silently
use whatever `month` is in the global environment. *Remedy:*
`reformulate(rhs, response = month)` or `as.formula(paste(month, "~", rhs))`.

**R5. `s(OL, ET, ST)` is rank-deficient because OL + ET + ST = 1**
(`4:255,265,275,358,398,409,419`). The three covariates lie on a plane, so the
3-D thin-plate null space (1, OL, ET, ST) is collinear with the intercept.
mgcv pivots the deficiency away: committed `calibration_mod8_bluesky.RDS` has
`rank 444` for `448` coefficients; a toy `s(OL,ET,ST,k=30)` on sum-to-one data
gives rank 26/30 *(tested)*. Fitted values are fine, but any paleo row whose
fractions do not sum to 1 (METHODOLOGY Q4: taxa with `LCT = NA` are dropped
*after* renormalisation at `1:54-59`; the committed non-interp files happen to
sum to exactly 1) is evaluated off the plane, in a direction the basis was
never constrained in. *Test:* `range(rowSums(paleo[,c("ET","OL","ST")]))` on
the interp paleo table; predict with and without renormalising rows and
compare. *Remedy:* smooth two coordinates (`s(ET, ST)` with OL implied, or an
isometric log-ratio pair) so the model is identifiable by construction.

**R6. Zero replacement and bounds** (`2:200-202,388-389`). `bs_df[bs_df==0] = 1e-4`
never triggers on this product (minimum blue-sky value 0.0037 *(checked)*) but
if it did, `logit(1e-4) = -9.2` versus a typical `-1`, an extreme leverage
point. Nothing guards `>= 1`. NA albedo (243 of 6,060 cell-months in the
committed table, water/no-data) is dropped silently by `na.action=na.omit`
(`4:209`) and the number of rows actually fitted is never reported. Note
`[<-.data.frame` with a logical matrix containing NA works only because the
RHS is scalar *(tested)*. *Remedy:* explicit filter with a logged count; clip
to `[eps, 1-eps]` in one named helper.

**R7. Script 3 month parsing yields `NA`** (`3:18,23,28`).
`as.numeric(substr(month, 4, 5))` expects `bs03`-style names (KI#30, the
older `mod1-4` fits); the committed calibration table and script 2's output
use `jan..dec`, so `month` is `NA` for every row and every `facet_wrap(~month)`
in `3:200-270` collapses to one panel. *Test:* `table(cal_long$month, useNA="always")`.

**R8. `ice_frac_adj` averaging** (`7a:452-459`). `idx <- which(diff(ice_frac) < 0)`
flags pairs where the *younger* slice has more ice (readvance, or Dalton
noise); the code then overwrites the younger slice's fraction with the mean of
its two neighbours. (i) If `idx == 1`, `adj[0]` is length-0 and the assignment
throws `replacement has length zero` *(tested)*; (ii) if `idx == n-1`,
`adj[n]` is fine but `idx == n` cannot occur, while a readvance at the oldest
pair pulls in an `NA` neighbour if `merge(years_df, ...)` filled it (`7a:450`);
(iii) the adjustment is not iterated, so consecutive readvances survive
(the `tally_increase` print at `7a:485-493` counts them but nothing acts);
(iv) genuine readvances (e.g. the ~8.2 ka Cochrane surge) are smoothed away.
The rule (modify the younger, not the older; average rather than clamp) is
undocumented. *Test:* count cells/months where `1 %in% idx` and where
`any(diff(idx)==1)`; compare RF with and without the adjustment.

**R9. `rowSums(..., na.rm=TRUE)` converts "unknown" into zero** (`7a:301-302`,
`7a:526-527`). In the threshold representation a pair with young ice > 0.5 and
old ice <= 0.5 has `alb_diff_veg_thresh = NA` (`7a:513`) and
`alb_diff_ice_thresh = NA` (`alb_ice_thresh[old]` is `NA` at `7a:295`), and
`rowSums(na.rm=TRUE)` returns **0**, a confident "no change" that then gets a
kernel applied in script 8. `7a:529-530` only re-NA's rows where an ice
fraction is missing. *Test:* rows with both parts `NA` and `alb_diff_veg_ice_thresh == 0`.

**R10. Age labels drift between scripts.** `7:100,197` relabel 11500 -> 12000
(and the figure period labels at `7:778,838` and `8:29` say "10 - 12 ka"),
`7a:26` leaves the same relabel commented out, so `ALB_diffs_bluesky.RDS` has
`year == 11500` while the overlays and captions say 12 ka. `7a:110`
`match(age, ice_dalton_years)` returns `NA` for any prediction age absent from
the Dalton layer names (parsed by `strsplit(x, 'yr|bp')` at `7a:85`), and
`ice_dalton_interp[[NA]]` errors. *Test:* `setdiff(unique(preds$year), ice_dalton_years)`.

**R11. Empty young-ice overlays for the two youngest periods** (`7:802-804`).
`ice_fort[which(ice_fort$ages == ice_years[idx])]` compares the `ages` column
(holding 50, 500, 2000, ...) with `ice_years` (1000, 2000, ...); for
`ages_sub[1:2]` the nearest ice year is 1000 and no row matches, so
`ice_fort_diff_young` has no polygons for "0.05 - 0.5 ka" and "0.5 - 2 ka".
Should compare `ice_fort$ice_year`. Cosmetic but it also feeds
`data/ice_fort_diff_young.RDS`. *Test:* `table(ice_fort_diff_young$facets)`.
Related: `7:48-49` assumes the unnamed 21-element list (`names()` are empty
*(checked)*) is ordered 1 ka..21 ka, and `7:64` overwrites the CRS rather
than checking it.

**R12. Cell-completeness filter no longer filters** (`7:269-270`).
`table(cell_id) < 8` was written for one row per cell-year; with 12 months
there are up to 96 rows, so a cell present in a single slice (12 rows) passes.
The later diff loop copes via `merge(all.x=TRUE)`, but the stated intent
("drop cells not included for all time periods") is not met.

**R13. Merges/joins on floating-point keys.** `2:216,406` merge on eight
numeric columns (`long, lat, x, y, elev, ET, OL, ST`); `7a:222` inner-joins
on `cell_id, lat, long` where `lat/long` come from `xyFromCell()` on both sides
(equal today, fragile); `6:65-73` and `6se:180` group by covariate values
rather than a cell key. Any upstream rounding (e.g. saving to CSV) silently
drops or duplicates rows. *Test:* `nrow()` before and after each merge; use
`cell_id` (+ `year`, `month`) as the only key.

**R14. Column-position selections.** `1:54` (`[,5:ncol]`: everything after
`cell_id,x,y,ages` is a taxon), `2:54,66,246` (`[,5:ncol]`, `[,3:ncol]`),
`3:16,21,26` (`[,1:20]` = 8 ids + 12 months, correct for the committed file
*(checked)*), `6:24,115`, `6se:24,327` (`colnames()[1] = 'year'`),
`8:148,170,226` (`[,2]`). Each breaks silently if a column is added.
*Remedy:* select by name; `dplyr::rename(year = ages)`.

**R15. Interp prep silently discards the ice mask and posterior** (`1:218-222`).
`group_by(cell_id, x, y, ages, LCT) %>% summarize(value = mean(value))` drops
the `ice` and `cell_area` columns of `veg_posts_interp_ice.RDS` and collapses
the 200 draws to a mean (METHODOLOGY Q6). The pipeline then re-derives ice
from Dalton in 7a, so there are two ice definitions with no reconciliation.
Also `1:230` passes `x, y` to `get_elev_point(prj = ll_proj)`: correct only
because the interp file's `x, y` are lon/lat, unlike the non-interp files
where `x, y` are Albers metres (`1:73-78`); the same names mean different
things in the two flavours (`7a:101` and `2:240-246` rely on the interp
meaning).

**R16. Kernel handling in `8_radiative.R`.** (a) Georeferencing by arithmetic:
`long360 = 360 - |long|` (`8:99`), `lat180 = lat + 90` (`8:100`), and
`t(flip(rk_cack))` (`8:202`) instead of assigning the NetCDF's CRS/extent; the
check plots that would validate this are commented out (`8:176-180,210-222`).
(b) The three kernels are not like-for-like: HadGEM `albedo_sw_cs` (`8:58`) is
clear-sky TOA; CAM5 `FSNSC` (`8:164`) is clear-sky *surface* net SW (the TOA
variable in that file is `FSNTC`); CACK `band=3` (`8:200`) selects one of
CACK's kernel variants without saying which. All-sky TOA is the usual choice
for forcing. (c) Units/sign: HadGEM and CAM5 are multiplied by `*100` (per
0.01 albedo) and CACK by `-1` (`8:256-301`); nothing records the convention
`Δα = α_young - α_old`, so the sign of "RF" relative to present is only in the
author's head (the `bar` block `8:330-339` is the sanity check that
`-K_hadgem*100 ≈ K_cack`). *Test:* for one cell/month print the three
`rf_*_veg_part` values; they should agree in sign and be within ~30%.
(d) Per-cell RF only; `area_km2` (a `units` column, `7a:219`) is carried but no
area-weighted aggregate is computed.

**R17. Scale mismatch is a silent config choice** (`2:190/195`, `2:378/383`).
The calibration response is the *native 0.25° pixel at the 1° cell centre*
(`bs_df`/`bs_interp_df`, saved as `calibration_modern_lct*_bluesky.RDS`), while
the 1° area-average (`_coarse`, `resample(method="average")` at `2:81/275`) is
computed, plotted and only used for the scatter at `2:218-230`. Script 4 reads
the native version (`4:17`). Given 1° land-cover fractions, the coarse file is
the physically matched response; either way it should be a config switch, not
an accident of which file name script 4 reads. Also `grid.RDS` spans
-172..+127° E (299 columns *(checked)*), so the resample and `cell_id` space
extend into Asia; harmless but undocumented.

**R18. Minor.** `5:233` `cor(alb_mid, alb_data,, use=...)` has a stray empty
argument (works by positional accident *(tested)*); `5:67` renames the albedo
data column to `month` and then groups/plots by it (`5:78,86-87`);
`5:353` `eval(as.name(paste0('model_', model)))` where `get()` would do;
`7a:500-507` computes `alb_diff_veg_ice_parts` twice; `3:412` and `3:415`
add two fill scales (the second wins, with a warning); `1:58` matches
`veg_grid$variable` (a factor from `melt`) to `tolower(taxon)` — works via
`as.character`, but any taxon absent from the 43-row table becomes `NA` and is
dropped without a message.

---

## 4. Bad practice / maintainability

- **Naming:** `foo`, `foo2`, `bar`, `k`, `spdf_2`, `alb_cell_filled`,
  `paleo_interp_sim_gam_sum` (`1:36`, `7a:619`, `8:304`, `beta_veg:29`,
  `7a:215`); the albedo column called `month` (`5:67`); `year` for what is an
  age BP (`6:24`); `cal_data` meaning different tables in scripts 3, 4, 5.
- **Magic numbers** as listed in section 2, plus `nsim = 100` (`5:60`, `6:50`)
  vs `N_iter = 20` (`6se:27`), `pie_scale=0.42/0.4` (`3:105,399`).
- **Comment quality:** section banners with empty titles (`1:1-3,47-49,85-87`),
  comments that are old code rather than intent, one useful comment per ~200
  lines ("not sure about this, leave for now", `7a:139`; "here", `7a:510`).
- **`library()` placement:** mid-file loads at `2:89`, `3:42,329`, `6se:223,251`,
  `GCM:79`; `library(brms)` (`5:3`) and `library(SemiPar)` (`6:8`) for nothing.
- **`=` vs `<-`:** 1,950 `=` assignments vs 72 `<-` in the numbered scripts
  (note only; pick one — `<-` — and let `styler` enforce it).
- **Attach-order dependence:** `library(gam)` before `library(mgcv)` (`4:1-2`;
  KI#21) masks `gam`, `s`, `predict.gam` variants; `raster` after `terra` masks
  `extract`, hence the defensive `terra::extract`/`raster::extract` sprinkled
  through (`2:190`, `7a:204`).
- **Working directory:** every path is relative (`'data/...'`, `'output/...'`,
  `'figures/...'`), so scripts only run from the repo root; no `here::here()`
  and no `dir.create()`.
- **Plot side effects:** `print(p)` then two `ggsave()` calls with no `plot=`
  argument (`2:154-156`, `5:101`) rely on "last plot"; bare `ggplot()` at top
  level (`1:104-106`, `7a:622-626`, `8:154-157`) writes to `Rplots.pdf` when
  run with `Rscript`; 151 `ggsave` calls, every figure saved twice (pdf+png)
  with default 7x7 in size unless overridden.
- **Results in `data/`:** `6:127-154`, `7:87,741,848-849`, `7a:617`, `GCM:212-215`.
- **Grouped tibbles saved to disk** (`6:73,77`, `6se:186`): `.groups = 'keep'`
  leaves the summary grouped by seven columns; downstream `n()` and joins
  behave differently and `readRDS` restores the grouping.

---

## 5. Recommended project structure

**Options.**
(a) *Scripts + `R/` functions* (`source("R/*.R")` or `devtools::load_all()`):
lowest ceremony, easy for a PI who reads R; no dependency tracking, so the
multi-hour fits still rerun by hand.
(b) *Package skeleton* (`DESCRIPTION`, `R/`, roxygen `man/`, `tests/testthat`,
scripts in `analysis/`): gives `R CMD check`, documented functions and tests;
overhead is `DESCRIPTION` maintenance and the package mindset, which is
unfamiliar to a newcomer but exactly what a coauthor reviewing methods wants.
(c) *`{targets}` pipeline*: declares each step as a target with inputs and
outputs, caches results, skips what has not changed, runs months in parallel
(`tar_map` / `crew`), and gives a dependency graph (`tar_visnetwork()`) that
replaces the pipeline diagram in the README. It requires the code to already
be functions, i.e. (a) or (b) first.

**Recommendation:** (a) + (c) now, growing into (b). Concretely: an `R/`
directory of pure functions loaded with `devtools::load_all()` (works with or
without a `DESCRIPTION`), a `_targets.R` that strings them together, `renv` for
the environment, and `testthat` tests from the start (they run with
`testthat::test_dir("tests")` without a package). Add `DESCRIPTION` + roxygen
in stage 5 once the function set is stable; at that point (b) costs an
afternoon. Why: the dominant practical pain is 12 months x 8 models x hours
being refit by accident (KI#22, KI#23), and `{targets}` removes it; a package
alone does not. For Chris, `{targets}` also makes "what depends on what" a
picture instead of 41 `paste0` strings; for the PI, the functions remain
ordinary R she can call at the console.

Proposed layout:

```
paleo-RF/
  _targets.R              # pipeline definition (stage 4)
  config/pipeline.yml     # projections, months, ages, k, threads, paths, switches
  R/
    config.R              # load_config(), paths()
    lct.R                 # summarise_posterior_lct(), add_elevation(), split_modern_paleo()
    albedo_extract.R      # extract_monthly_albedo()
    calibrate.R           # calibration_formulas(), fit_calibration(), select_model()
    evaluate.R            # eval_calibration(), coverage_stats()
    predict.R             # predict_paleo(), sample_paleo() [coef draws], summarise_draws()
    ice.R                 # extract_ice_fraction(), adjust_ice_readvance()
    difference.R          # difference_slices(), decompose_veg_ice()
    forcing.R             # read_kernel(), apply_kernel()
    plots.R               # map_albedo(), map_diff(), theme_paleo()
  analysis/               # thin driver scripts / Quarto reports (replace scripts/1..8)
  tests/testthat/         # unit + regression tests (stage 2)
  data/                   # inputs only (LFS > 50 MB); DATA.md
  output/                 # targets store + derived products (gitignored except final results)
  docs/                   # cc/, DATASHEET.md, CHANGELOG.md
```

**Functions to factor out** (name — inputs -> outputs — where the logic lives today):

| Function | Inputs -> outputs | Today |
|---|---|---|
| `summarise_posterior_lct(veg_posts, fun = mean)` | 42M-row posterior -> cell x age x {ET,ST,OL,ice,cell_area} | `1:218-225` |
| `add_elevation(df, cache)` | lon/lat -> `elev`, cached to `data/elev_by_cell.RDS` | `1:96-101,230-234` |
| `split_modern_paleo(df, modern_age = 50)` | -> two tables | `1:236-246` |
| `extract_monthly_albedo(points, tif, grid, method = c("native","coarse"))` | -> 12 month columns, NA policy, eps clip | `2:79-211,271-398` |
| `calibration_formulas(k_space, k_elev, k_cover)` | -> named list of 8 formulas built with `reformulate()` | `4:205-282` |
| `fit_calibration(data, month, formula, ctrl)` | -> `bam` object with `month` stored in `$paleo_meta` | `4:202-295,443-527` |
| `select_model(fits, rule = "aic")` | -> chosen fit + AIC table | `4:315-335`, `5:28-33` |
| `eval_calibration(fit, data, month, n_draw)` | -> predicted/observed, coverage, correlation | `5:35-104,206-244` |
| `predict_paleo(fit, paleo)` | -> point predictions | `6:37-46` |
| `sample_paleo(fit, paleo, n, seed, what = c("coef","coef+obs"))` | -> long draws with a real `iter` | `6:49-62` (+ R1 fix) |
| `summarise_draws(draws, by = c("cell_id","year","month"))` | -> mean/sd/quantiles, ungrouped | `6:65-77` |
| `extract_ice_fraction(preds, dalton_tif)` | -> `ice_frac` per cell x year, one reprojection | `7a:84-142` |
| `adjust_ice_readvance(x, rule)` | -> adjusted series with edge cases handled | `7a:452-459` |
| `difference_slices(df, ages)` | -> young-minus-old per cell x month, vectorised | `7a:434-612`, `7:694-741` |
| `decompose_veg_ice(df, glacier_albedo, threshold = 0.5)` | -> parts and thresh columns | `7a:264-302,495-530` |
| `read_kernel(name, month)` | -> georeferenced SpatRaster in W m-2 per unit albedo, TOA all-sky | `8:58,163-165,197-202` |
| `apply_kernel(diffs, kernel, lat_range)` | -> RF columns with one documented sign convention | `8:99-110,135-301` |
| `make_ice_overlay(shapefiles, ages)` | -> fortified polygons keyed by `ice_year` | `7:48-87,780-849` |
| `map_albedo()`, `map_diff()`, `theme_paleo()` | -> ggplot objects; `save_figure()` does the pdf+png | `7:315-1089` |
| `ensure_dirs(paths)` | creates `output/*`, `figures/` | nowhere |

**Config approach.** One `config/pipeline.yml` read by `load_config()` into a
named list (`cfg$crs$albers`, `cfg$months`, `cfg$ages`, `cfg$k`, `cfg$nthreads`,
`cfg$alb_prod`, `cfg$response_scale = "coarse"|"native"`, `cfg$ice_threshold`,
`cfg$lat_range`, `cfg$seed`, `cfg$paths$data/output/figures`). Every function
takes what it needs as arguments; `_targets.R` reads the config once. A
`DEPRECATED` switch for `interp` is not needed: the non-interp path is deleted.

---

## 6. Documentation protocol

**Functions:** roxygen2 headers on every `R/` function (`@param`, `@return`,
`@details` with the scientific rule, e.g. the readvance adjustment and the
`Δα` sign convention, `@examples` on small fixtures). `devtools::document()`
builds `man/`; `pkgdown` later if wanted.

**README structure:** purpose (three sentences); pipeline diagram
(`tar_visnetwork()` export, replacing the ASCII one); how to run
(`renv::restore()`; `targets::tar_make()`; which targets are expensive);
runtimes per stage (script 4 ~90 min/month on 8 threads; script 2 ~3 min; 7a
minutes after vectorising); environment (the `paleo-rf` micromamba env for R
itself, `renv.lock` for packages, `sessionInfo()` of the paper run pinned in
`docs/`); how to get the large data (LFS pointers, external URLs, contact for
REVEALS outputs); pointer to `DATA.md`, `CHANGELOG.md`, `2026-09-16_known_issues_missing_data_and_code.md`.

**CHANGELOG:** generate from `git log --format='- %ad %s (%h)' --date=short`
grouped by tag; keep the human summary at the top ("v0.1 legacy snapshot,
v0.2 config+seed, ...") and paste the generated list under each tag. Chris will
be asked for this by the coauthors; a `tools/make_changelog.sh` keeps
it honest.

**Data documentation standard: `docs/DATASHEET.md`.** Modelled on Gebru et al.
(2021, *Datasheets for Datasets*, CACM 64(12)) reduced to the questions that
matter for a pipeline: motivation/what it is, composition (shape, units, CRS,
keys), collection/provenance (who, from what, with what code and version,
when), preprocessing, uses (which scripts read/write), distribution (size, LFS,
licence), maintenance, known issues, and **role** (input / intermediate /
result / legacy). Files > 50 MB go to Git LFS (`veg_posts_interp_ice.RDS` is
334 MB, above GitHub's 100 MB hard limit); `.gitattributes` does not exist yet.

Template (one block per file):

```
### <path>
- Role: input | intermediate | result | legacy
- Format / shape / size: 
- What it is: 
- Provenance: who / from what / code+commit / date   (write "unknown" rather than guess)
- Written by / read by: 
- Units and CRS: 
- Keys: 
- Known issues: 
- LFS: yes/no
```

Inventory (66 entries in `data/`, 703 MB): inputs — `veg_posts_interp_ice.RDS`,
`blue_sky_monthly_2000-2009.tif`, `grid.RDS`, `taxon2LCT_translation_v2.0.csv`,
`map-data/geographic/{pbs.RDS,pbs_ll.RDS,PoliticalBoundaries/*}`,
`map-data/ice/glacier_shapefiles_21-1k.RDS`; intermediates of the March
non-interp path (to be retired) — `lct_modern_reveals.RDS`,
`lct_paleo_reveals.RDS`, `calibration_modern_lct_bluesky{,_coarse}.RDS`,
`calibration_mod{1..8,7_free}_bluesky.RDS`, `calibration_model_selected_bluesky.RDS`,
`paleo_predict_gam{,_samps,_summary}_bluesky.RDS`, `alb_preds_diffs_bluesky.RDS`,
`ice_fort.RDS`, plus the `_may_` twins generated on `chris-dev`; legacy
(archive scripts only; KI#31) — `cal_data.RDS`, `calibration-albedo-climate*.RDS`,
`calibration_mod{1..6}_albclim.RDS`, `calibration_model{,1..5}.RDS`,
`lct_albedo_snow_modern_{bluesky,glob}.RDS`, `lct_paleo.RDS`,
`pollen-modern-slice_v2.0.RDS`, `preds_alb_diffs_sub_bluesky.RDS`,
`{tmax,tmin,tmean,ppt}_CRU.csv`, `climate_CRU.csv`, `{tmax,tmin,ppt}_GCM.csv`.

Five filled entries:

```
### data/veg_posts_interp_ice.RDS
- Role: input (root of the interp path)
- Format / shape / size: RDS data.frame, ~42M rows x 9 cols
  (cell_id, x, y, ages, iter, LCT, value, cell_area, ice); 334 MB
- What it is: REVEALS land-cover posteriors (200 draws) spatially interpolated
  over the full 1-degree grid with ice-covered cells masked, per time slice
- Provenance: unknown code and commit (Bayesian interpolation by a coauthor;
  METHODOLOGY Q8). Not in git history at c9d525e; supplied 2026-09 by Andria
- Written by / read by: external / 1_veg_lct_prep.R:218
- Units and CRS: value = fraction 0-1 (per LCT); x, y = lon/lat WGS84 cell centres
  (inferred from 2_calibration:245 and 7a:101); ages = cal yr BP; cell_area units unknown
- Keys: cell_id x ages x iter x LCT
- Known issues: ice and cell_area are dropped at 1:220-222; draws collapsed to mean (R15)
- LFS: yes (required, > 100 MB)

### data/blue_sky_monthly_2000-2009.tif
- Role: input (calibration response)
- Format / shape / size: GeoTIFF, 12 layers (all named "median"), 280 x 500,
  0.25 deg, extent -175.125..-50.125 E, 10.125..80.125 N; 3.3 MB
- What it is: monthly median blue-sky (all-sky) shortwave albedo climatology 2000-2009
- Provenance: source satellite product, band, and the median/regrid script are
  unknown (KI Missing code #5); committed 2023-03-02 by Andria Dawson ("moving blue sky from scratch")
- Written by / read by: external / 2_calibration_lct_bluesky.R:79,273
- Units and CRS: dimensionless albedo 0-1 (observed 0.0037-0.83); OGC:CRS84
- Keys: layer index = month 1..12 (names assigned at 2:84)
- Known issues: no zeros, so the 1e-4 rule (R6) is inert; water is NA
- LFS: no

### data/grid.RDS
- Role: input
- Format / shape / size: RasterLayer (raster pkg), 62 x 299, 1 deg,
  extent -172..127 E, 17..79 N, values 1..18538 = cell_id; 1 KB
- What it is: the 1-degree lon/lat analysis grid; defines cell_id everywhere
- Provenance: generating code unknown (scripts/make_grid.R is not in the repo);
  committed 2023-05-16 by Andria Dawson ("adding grid")
- Written by / read by: external / 1:34, 2:39, 7:239,1361, 7a:201
- Units and CRS: +proj=longlat +datum=WGS84
- Keys: cell_id
- Known issues: extends to +127 E (R17); stored as a raster-package object,
  needs raster/sp to load; should be regenerated as terra and saved as GeoTIFF
- LFS: no

### data/calibration_modern_lct_bluesky.RDS
- Role: intermediate (non-interp; to be retired) - the March-path calibration table
- Format / shape / size: RDS data.frame 505 x 20 (long, lat, x, y, elev, ET, OL, ST, jan..dec); 48 KB
- What it is: modern (age-50) LCT fractions per 1-deg cell with the native
  0.25-deg blue-sky albedo extracted at the cell centre
- Provenance: 2_calibration_lct_bluesky.R at c9d525e from an lct_modern_reveals
  table that is NOT the committed one (KI#29); committed 2023-05-12 by Andria Dawson;
  regenerated identically on run-nointerp from the age-50 slice of lct_paleo_reveals.RDS
- Written by / read by: script 2 / 3:15, 5:13
- Units and CRS: fractions 0-1; albedo 0-1; x, y Albers (aea, lat_1=50, lat_2=70, lon_0=-96, GRS80) m; elev m (elevatr, AWS tiles)
- Keys: (long, lat) - no cell_id column
- Known issues: 243 NA albedo cell-months; elevation non-reproducible (KI#27)
- LFS: no

### data/lct_paleo_reveals.RDS
- Role: intermediate (non-interp; to be retired)
- Format / shape / size: RDS data.frame 4453 x 9 (ages, long, lat, x, y, elev, ET, OL, ST); 133 KB
- What it is: REVEALS LCT fractions per pollen-bearing 1-deg cell and slice;
  ages 50, 500, 2000, 4000, ..., 20000 (12 slices, 505 down to 54 cells)
- Provenance: 1_veg_lct_prep.R from veg_pred_LGM_8.0.RDS (not in repo) and
  taxon2LCT_translation_v2.csv; committed 2023-05-16 by Andria Dawson
- Written by / read by: script 1:208 / 6:114, GCM_snow_prob.R:31
- Units and CRS: as above; rows sum to exactly 1
- Keys: (ages, long, lat)
- Known issues: slice set differs from the interp ages (50, 200, 500..11500)
  used in 7a/8; age-50 slice is the calibration site set
- LFS: no
```

---

## 7. Refactor plan in stages

Regression anchor throughout: the committed March predictions
`data/paleo_predict_gam_summary_bluesky.RDS` (reproduced at corr 0.999 by the
run-nointerp branch) until the non-interp path is deleted, then the first
complete interp run (`output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS`,
`data/ALB_diffs_bluesky.RDS`, `output/forcing/RF_holocene_all_cases.RDS`)
frozen as `tests/fixtures/` and compared with `all.equal(tolerance = 1e-6)`
(seeded) or correlation > 0.999 (unseeded legacy).

| Stage | What | Unblocks | Effort |
|---|---|---|---|
| 0 | Tag `c9d525e` as `v0-legacy`; freeze `legacy` branch (done). Run the interp path once end-to-end on the current code with the new inputs and archive its outputs as the second regression anchor. | Everything below has something to compare to. | 1 day + fit time |
| 1 | `config/pipeline.yml` + `R/config.R`; `ensure_dirs()`; `set.seed(cfg$seed)` and `seed=` in `simulate()`; replace `get(month)` with `reformulate()`; fix R2 (`iter`), R7 (month parse), R11 (ice_year), path mismatch KI#13; `.gitattributes` with LFS for >50 MB; move results out of `data/` into `output/`. Re-run March path: corr 0.999 -> expect identical with seed. | Deterministic runs; single source of constants. | 2 days |
| 2 | Extract the functions in section 5 into `R/`, one script at a time, keeping each driver script calling the function and asserting `all.equal()` against the stage-0 outputs (tests in `tests/testthat/`). Vectorise `difference_slices()` and `extract_ice_fraction()`; fix R8/R9 edge cases with explicit tests (readvance at first/last pair; both parts NA). Add `sample_paleo(what="coef")` alongside the existing behaviour so R1 can be evaluated, not silently swapped. | Code that can be reviewed by a coauthor; 7a from hours to seconds. | 5-7 days |
| 3 | Delete the non-interp/point code, `archive/`, `thornthwaite.R`, `GCM_snow_prob.R`, `beta_veg_lct_modern.R`, all `# XXX OLD` blocks and every commented-out block; drop the legacy data files (KI#31) after the datasheet records them; tag `v0.3-interp-only`. | Half the line count gone; one flavour; `2026-09-16_code_map_original_scripts.md` shrinks to a page. | 1 day |
| 4 | `_targets.R`: targets per month for fit/select/predict (`tar_map` over `cfg$months`), `crew` workers for parallel months, `tar_read()` in the analysis scripts; `renv::init()`/`snapshot()`; CI job (GitHub Actions) that runs the fast targets and the tests on a 2-month, low-k config. | No accidental refits; dependency graph; reproducible env. | 3 days |
| 5 | `DESCRIPTION`, roxygen on all functions, `devtools::check()` clean; decide R1 (coefficient draws vs observation noise) and R5 (compositional smooth) with the PI and implement as config options with tests; kernel reader with georeferencing (R16). | Methods section can cite functions; reviewers can run `?predict_paleo`. | 3-4 days |
| 6 | `docs/DATASHEET.md` for every remaining file; README as in section 6; `CHANGELOG.md` generated from tags; `sessionInfo()` of the paper run committed. | Coauthor hand-off; submission-ready repo. | 2 days |

Total ~17-20 working days excluding fit time. Stages 1-3 are low risk because
every step is checked against a frozen output; stage 5's scientific changes
(R1, R5, R16) are deliberately last so that the refactor itself is proven
neutral first.
