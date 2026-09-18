# paleo-RF: staged cleanup plan while the science is still moving

Companion to `CODE_REVIEW.md` (review of commit `c9d525e`). Findings are cited
as R1-R17 (review section 3) and KI#n (`docs/cc/KNOWN_ISSUES.md`); line numbers
refer to `c9d525e` and shift by a few lines on `chris-dev`. Written 2026-09-18.

## (a) Rationale

The methodology is not settled, so the code will keep changing in exactly the
places a big refactor would freeze. The plan therefore does only what protects
scientific validity now: make every run reproducible (seed, config, output
directories), remove the things that can silently change a number (R2, R7-R12,
KI#13-18), keep one copy of each computation so a method change is made once,
and put a regression check in front of every step so cleanup is provably
neutral. Anything that changes a result (uncertainty propagation, the
compositional smooth, kernel choice) is a PI decision and is listed in (d),
not done unilaterally. Package, roxygen, testthat-as-suite, pkgdown, renv
snapshot and DOI are the release stages and are marked "after science is
settled".

**What groups in this field do.** Palaeo/land-surface groups almost never
submit analysis code to CRAN; CRAN is for general-purpose libraries and
imposes review, portability and maintenance obligations that an analysis
repository does not want. The norm is a *research compendium*: a GitHub
repository organised as an R package (`DESCRIPTION`, `R/`, `analysis/`,
`data/` with LFS or external download, `renv.lock`), archived at submission
with a Zenodo DOI that the paper cites, sometimes with a `pkgdown` site. Aim
for that. Only if a reusable piece emerges (e.g. an albedo-kernel utility)
would a separate CRAN package make sense, and that is a later, separate
decision.

## (b) Config mechanism

**Recommendation: the `{config}` package with `config.yml` profiles.** Compared
with the alternatives: a plain `yaml::read_yaml()` gives the same file but no
inheritance, so the interp/non-interp variants would duplicate every key; an R
list in `R/config.R` is the simplest but mixes code and settings and cannot be
switched from the shell. `{config}` gives a `default` profile plus named
profiles that override only what differs, selected by
`Sys.setenv(R_CONFIG_ACTIVE = "nointerp")` or an environment variable on the
`Rscript` command line, and `config::get()` returns an ordinary list. Interp
stays the default by construction. The PI can read the YAML.

```yaml
# config.yml
default:
  flavour: interp            # "interp" (default) | "nointerp"
  alb_prod: bluesky          # "bluesky" | "albclim"
  seed: 20260918
  months: [jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec]
  ages: [50, 200, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000,
         5500, 6000, 6500, 7000, 7500, 8000, 8500, 9000, 9500, 10000, 10500,
         11000, 11500]
  ages_plot: [50, 500, 2000, 4000, 6000, 8000, 10000, 12000]
  modern_age: 50
  crs:
    albers: "+proj=aea +lat_1=50 +lat_2=70 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
    lonlat: "EPSG:4326"
  domain: {lon: [-165, -50], lat: [10, 80]}
  response_scale: native     # "native" 0.25-deg pixel | "coarse" 1-deg mean (R17)
  albedo_eps: 1.0e-4         # clip for betar (R6)
  model:
    k_space: 500
    k_elev: 50
    k_cover_1d: 50
    k_cover_3d: 200
    k_cover_gp: 75
    selected: mod8
    nthreads: 8
    maxit: 500
  uncertainty:
    n_draws: 100
    method: observation      # "observation" (current) | "coefficient" | "both"  (decision D2)
    lct_draws: mean          # "mean" (current) | integer n of the 200 posterior draws (decision D1)
  ice:
    threshold: 0.5
    readvance_rule: average_neighbours   # (R8; decision D5)
    glacier_albedo: data/albedo_glacier_monthly.csv
    dalton: data/Dalton_QSR_2020_Ice/dalton_interpolated_LC6k.tif
    shapefiles: data/map-data/ice/glacier_shapefiles_21-1k.RDS
  forcing:
    lat_range: [27, 74]
    kernels: {hadgem: data/radiative-kernels/HadGEM3-GA7.1_TOA_kernel_L19.nc,
              cam5: data/radiative-kernels/CAM5/alb.kernel.nc,
              cack: data/radiative-kernels/CACKv1.0/CACKv1.0.nc}
  paths:
    data: data
    output: output
    figures: figures

nointerp:
  flavour: nointerp
  months: [mar]
  ages: [50, 500, 2000, 4000, 6000, 8000, 10000, 12000, 14000, 16000, 18000, 20000]
  model: {k_space: 350, k_cover_1d: 30, k_cover_3d: 50, k_cover_gp: 30}

test:                        # fast profile for regression checks
  months: [mar, aug]
  model: {k_space: 100, k_cover_3d: 50}
  uncertainty: {n_draws: 10}
```

**How scripts consume it without a rewrite.** Two small files sourced at the
top of every script:

```r
# R/config.R
cfg <- config::get(file = here::here("config.yml"))   # profile from R_CONFIG_ACTIVE
set.seed(cfg$seed)
for (d in c("calibration", "prediction", "forcing")) dir.create(file.path(cfg$paths$output, d), recursive = TRUE, showWarnings = FALSE)
dir.create(cfg$paths$figures, showWarnings = FALSE)

# R/paths.R  -- one place that knows the file-name grammar
tag <- function(cfg) if (cfg$flavour == "interp") "_interp" else ""
path_lct      <- function(cfg, which = c("modern", "paleo")) file.path(cfg$paths$data, sprintf("lct_%s_reveals%s.RDS", match.arg(which), tag(cfg)))
path_caldata  <- function(cfg, scale = cfg$response_scale) file.path(cfg$paths$data, sprintf("calibration_modern_lct%s_%s%s.RDS", tag(cfg), cfg$alb_prod, if (scale == "coarse") "_coarse" else ""))
path_model    <- function(cfg, month, model = cfg$model$selected) file.path(cfg$paths$output, "calibration", sprintf("calibration_%s%s_%s_%s.RDS", model, tag(cfg), month, cfg$alb_prod))
path_selected <- function(cfg, month) path_model(cfg, month, "mod_selected")
path_pred     <- function(cfg, month = NULL, kind = c("point", "samps", "summary")) ...
path_diffs    <- function(cfg) file.path(cfg$paths$output, "prediction", sprintf("ALB_diffs%s_%s.RDS", tag(cfg), cfg$alb_prod))
```

Then `readRDS(paste0('output/calibration/calibration_mod8_interp_', month, '_', alb_prod, '.RDS'))`
(`5:28`) becomes `readRDS(path_model(cfg, month, "mod8"))`, and the writer in
`4:282` uses the same helper, which ends KI#13-style mismatches by
construction. Flavour differences that are not just file names (the
`long/lat` vs `x/y` column convention, R15; the point-scale extraction in
`2:58-66`) move into one function per step that takes `cfg`, e.g.
`extract_albedo(cfg, sites)` replacing both `2:46-211` and `2:238-398`. The
numbered scripts stay as thin drivers; nothing is renamed or moved yet.

## (c) Stages

Every stage ends with the same check: `Rscript tests/regression.R`, which
re-runs the affected scripts under the `test` (fast) and then the real
profile, and compares the outputs to frozen files with
`all.equal(tolerance = 1e-8)` (seeded steps) or correlation > 0.999 plus
`nrow()` equality (steps whose anchor predates the seed). Anchors: the March
non-interp files already committed (`data/paleo_predict_gam_summary_bluesky.RDS`,
`calibration_mod8_bluesky.RDS`, `calibration_modern_lct_bluesky.RDS`) now; the
interp files after stage 1 produces them.

### Stage 0 - anchors (0.5 day, no PI decision)
Goal: nothing can change unnoticed. Tasks: tag `c9d525e` as `v0-legacy`;
copy the committed March outputs to `tests/anchors/nointerp/`; write
`tests/regression.R` (loops over anchor files, reports max abs diff, corr,
nrow, and the columns that differ); add `.gitattributes` with LFS for `*.RDS`
over 50 MB (`veg_posts_interp_ice.RDS`, 334 MB; KI#33 environment note).
Closes: nothing yet; enables everything.

### Stage 1 - first interp run and interp anchor (1 day + fit time; no PI decision)
Goal: the interp outputs exist for the first time (KI#32) and become the
second anchor. Tasks: run scripts 1-8 on `chris-dev` as they are (with the
`run_interp` edits) on `veg_posts_interp_ice.RDS`; keep the calibration
table, the 12 selected models, the prediction summary and samples,
`ALB_diffs`, `RF_holocene_all_cases` under `tests/anchors/interp/` (LFS where
large). Record `sessionInfo()` and wall times in `docs/cc/RUN_LOG.md`. Note
the run is unseeded, so this anchor is a corr-0.999 anchor until stage 2
re-freezes it. Blocked by: the Dalton raster, glacier CSV and kernel files
(KI 2.1) must be present; if not, anchor scripts 1-6 now and 7a-8 later.

### Stage 2 - config, seed, directories, paths (2 days; no PI decision)
Goal: one source of constants; deterministic runs; writer and reader agree.
Tasks: add `config.yml`, `R/config.R`, `R/paths.R` as in (b); source them at
the top of scripts 1-8; replace the 7 Albers strings, 10 month vectors, 4
`ages`/`years` sets (`7:32,34,229,782,1390`, `7a:9,11,191`, `8:31,33`), 5
`ctrl` lists (`4:11,200,303,351,441`), and every `paste0` path (41 sites) with
`cfg` values and helpers; `set.seed(cfg$seed)` plus `seed=` in every
`simulate()` (`5:59,146,355`, `6:49,130`); move results out of `data/`
(`6:127-154`, `7:87,741,848-849`, `7a:617`) into `output/`; drop
`library(SemiPar)`, `library(brms)`, `library(gam)` and add the missing
`library()` calls (KI#3,#6,#12,#21). Closes: R3, R4 (use
`reformulate(rhs, response = month)` at the 24 `get(month)` sites), KI#1,
#13, #14, #15, #28, #33 (partly). Check: March path reproduces its anchor at
corr > 0.999 (unseeded anchor); then re-freeze both anchors seeded, and from
here on require `all.equal`.

### Stage 3 - silent-result bugs (2 days; R8/R9 need a PI rule)
Goal: no number produced by an accident. Tasks and the finding each closes:
`6:60`, `6se:173` `iter` parsing -> R2; `3:18,23,28` month parsing -> R7;
`7:802-804` `ice_year` comparison and `7:48-49` list-order assumption -> R11;
`7:269` completeness threshold -> R12; `7:100,197` vs `7a:26` 11500/12000
relabel, and `7a:110` `match()` returning `NA` -> R10 (decide one age set in
config; make `match` failure an error); `7a:452-459` readvance edge cases
(index 0, index n, non-iterated) -> R8, implemented as
`adjust_ice_readvance(x, rule = cfg$ice$readvance_rule)` with the *current*
rule as the default so results do not change, and a unit test for the three
edge cases; `7a:301-302,526-527` `na.rm=TRUE` -> R9, replaced by an explicit
"both parts NA -> NA" and a count printed to the log; `7:459,1473`
`year==year` -> KI#18; `4:738` mod7_free -> KI#9/#19; explicit NA/eps
handling with a logged row count at `2:200-202` and `4:209` -> R6;
`8:99-100,202` kernel georeferencing replaced by assigning the NetCDF
CRS/extent and re-enabling the check plots at `8:176-180,210-222` -> R16(a)
only (kernel *choice* is decision D4). Check: `all.equal` against the stage-2
anchors for everything except the rows the R8/R9/R11/R12 fixes touch; for
those, a printed list of changed cells/months that Chris and the PI look at
once and then re-freeze.

### Stage 4 - deduplicate the flavour blocks into functions (4-5 days; no PI decision)
Goal: each computation exists once and takes `cfg`. Tasks, one script at a
time with the regression check after each: `extract_albedo()` replacing
`2:46-231` and `2:238-420`; `fit_calibration(data, month, formula, cfg)` and
`calibration_formulas(cfg$model)` replacing `4:202-295`, `4:353-428`,
`4:443-527` (so mod8 is fitted once; KI#22, #23); `eval_calibration()`
replacing the three copies in `5:21-104`, `5:122-160`, `5:721-805`;
`predict_paleo()` / `sample_paleo()` / `summarise_draws()` replacing `6:30-107`
and deleting `6:114-154` and `6se:322-366` (KI#14, #15); a vectorised
`difference_slices()` + `decompose_veg_ice()` replacing `7a:434-612` and
`7:694-741` (KI#25, #36; keeps 7a's definition, and script 7 reads 7a's
output); `make_ice_overlay()` replacing `7:48-87,780-849`; `apply_kernel()`
replacing `8:135-301`. Functions live in `R/` and are `source()`d by
`R/config.R`; column names replace positional indices (R14) and joins use
`cell_id/year/month` keys (R13). Check: `all.equal` per script against the
stage-3 anchors; `7a` is also timed (hours -> seconds).

### Stage 5 - dead code, naming, files (1.5 days; no PI decision)
Goal: a reader sees only the live method. Tasks: delete every commented-out
block (script 4 `:27-189,573-830`; 5 `:453-716,807-888`; 6 `:168-304`; 7 the
two posterior-sample blocks and `:1345-1830` once script 7 consumes 7a; 7a
`:31-76,628-853`); delete `beta_veg_lct_modern.R`, `thornthwaite.R`,
`GCM_snow_prob.R`, `scripts/archive/` (they stay at tag `v0-legacy`); rename
`foo/bar/k`, the `month`-named albedo column (`5:67`), `year` -> `age_bp`
across scripts (with the anchor comparison mapping old to new names); mark
legacy data files (KI#31) in `DATA.md` and remove them from `data/`;
`styler::style_dir()` for `<-` and spacing; update `CODE_MAP.md` (per
`CONTRIBUTING.md`). Closes: KI#10, #11, #20, #24, #26, #31, #34. Check:
`all.equal` unchanged, and `git diff --stat` shows only deletions and renames.

### Stage 6 - science options behind config switches (3-4 days; PI decisions D1-D5)
Goal: each open decision is a config value with both options implemented and
tested, so the PI can choose by looking at results, not code. Tasks:
`uncertainty.method = observation | coefficient | both` in `sample_paleo()`
(D2); `uncertainty.lct_draws = mean | n` in script 1's summary so `n` of the
200 `iter` are carried as an extra key through calibration/prediction (D1;
see (d) for cost); `model.cover_smooth = tp3d | ilr2d` (D3);
`forcing.kernel_variant` (D4); `ice.readvance_rule` (D5). Each option gets a
test that the default reproduces the anchor and a short comparison figure.

### Release stages - after science is settled
- **R1. Package skeleton** (2 days): `DESCRIPTION`, `NAMESPACE` via roxygen,
  `R/` as is, drivers to `analysis/`, `devtools::check()` clean.
- **R2. roxygen + testthat + pkgdown** (3 days): roxygen on every function
  (`@details` carrying the scientific rules: sign convention, readvance rule,
  eps); the stage-0 regression script becomes `tests/testthat/test-regression.R`
  on the `test` profile with small anchors; `pkgdown` site from README + man.
- **R3. Environment and data** (1 day): `renv::init(); renv::snapshot()` in the
  micromamba env; `sessionInfo()` of the paper run in `docs/`; `DATA.md`
  completed for every remaining file; download script for external inputs.
- **R4. Archive** (0.5 day): tag `v1.0-paper`, Zenodo GitHub integration mints
  the DOI, cite it in the methods. CRAN only if a reusable component is split
  out later.
- Optional: `{targets}` for the fits once the function set is stable (2 days);
  worthwhile if the PI expects repeated re-runs after publication.

## (d) Science decisions the plan depends on

| # | Decision | Options (cost) | Where in code | Default until decided |
|---|---|---|---|---|
| D1 | **Land-cover posterior**: the PI's "multiple samples from the posterior, summarise mean and sd" refers to the 200 `iter` draws in `veg_posts_interp_ice.RDS`, which `1:218-222` averages away before anything else (METHODOLOGY Q6). | (i) Keep the mean (current). (ii) Carry n draws (e.g. 20-50) through calibration and prediction: calibration is fitted once on the mean modern field (or once per draw, 12 x n fits, prohibitive) and prediction is run per draw, so the 42M-row file is reduced to n x cells x ages and script 6 loops over draws; cost ~n x prediction time (seconds each), plus memory in 7a. | `1:218-222`, `6:30-79`, `7a` | (i) |
| D2 | **Albedo-model uncertainty** (R1, distinct from D1): `simulate()` draws beta observation noise at fixed coefficients, never coefficient uncertainty. | (i) Keep observation noise and say so in the paper. (ii) Coefficient draws: `gratia::fitted_samples(mod, n, method = "gaussian")` or `mvn` from `vcov(mod)` times the `lpmatrix`; cost seconds per month, and `alb_sd` will then grow away from the calibration cloud. (iii) Both, added. | `5:59`, `6:49`, `6se:122-154` | (i) |
| D3 | **Compositional smooth** (R5): `s(OL, ET, ST)` on sum-to-one covariates is rank-deficient; paleo rows off the simplex extrapolate. | (i) Keep, but renormalise paleo rows. (ii) `s(ET, ST)` or an ilr pair, refit ladder (12 x 8 fits). | `4:255-419` | (i) with renormalisation check |
| D4 | **Kernels** (R16): HadGEM `albedo_sw_cs` (clear-sky TOA), CAM5 `FSNSC` (clear-sky surface), CACK band 3; sign and x100 conventions undocumented. | (i) Keep, document. (ii) All-sky TOA variants of each (`albedo_sw`, `FSNT`, CACK all-sky), one documented sign convention. | `8:58,163-165,197-202,256-301` | (i) |
| D5 | **Ice readvance rule** (R8/R9) and threshold 0.5; also which ice definition (Dalton fraction vs the `ice` mask in the input, R15). | (i) Current averaging, edge cases fixed. (ii) Clamp to monotone retreat, or keep real readvances. | `7a:288,452-459,513-530` | (i) |
| D6 | **Model selection**: mod8 chosen by AIC/ANOVA per month (`4:326-332`) but the selection is hard-coded (`5:28`). | (i) Fix mod8 for all months. (ii) Per-month AIC winner. | `4:315-335`, `5:28` | (i) |
| D7 | **Slices and ages**: interp ages 50, 200, 500..11500 with 11500 shown as "12 ka" (R10); manuscript describes irregular slices (METHODOLOGY Q11). | (i) 25 regular slices, label 11.5. (ii) The manuscript's slice set. | `config ages`, `7:100`, `7a:9` | (i) |
| D8 | **Calibration response scale** (R17): native 0.25-deg pixel at the cell centre vs the 1-deg mean. | (i) Native (current). (ii) Coarse (`_coarse` file already produced). | `2:190/195`, `4:17` | (i) |

## (e) This week

1. Stage 0: tag `v0-legacy`, copy the March anchors to `tests/anchors/`,
   write `tests/regression.R`, add `.gitattributes` (LFS > 50 MB). Half a day.
2. Start stage 1: launch the interp calibration fits (script 4 is the long
   pole, ~12 x 90 min at full k on 8 threads) so the interp anchor exists by
   next week; while it runs, stage 2's `config.yml`, `R/config.R`, `R/paths.R`
   on a `config-switch` topic branch off `chris-dev`, applied first to
   scripts 4-6 where the path mismatches live.
3. Send the PI table (d) with D1 and D2 flagged as the two she must
   distinguish, plus the one-line ask for D4 (which kernel variant the
   manuscript intends).
4. Confirm the missing inputs for 7a/8 (Dalton raster, glacier CSV, kernels)
   are on their way, since stage 1 cannot complete without them.
