# Running the interp pipeline: changes required

Working log of the first attempt to run the interp (spatially complete,
all-months) pipeline, the path the EGU talk and draft paper are built on.
Started 2026-09-19 on branch **`run-interp`**, off `chris-dev`. Updated as
the run proceeds.

Purpose: produce the first interp outputs, which become the regression
anchor for that flavour (`tests/anchors/` has none, because the interp
path has never been run here).

## How it is being run

- Branch `run-interp`; `chris-dev`, `main` and `legacy` untouched.
- Capped at 8 of the 48 cores (`taskset -c 0-7`, `nice -n 10`) with the
  BLAS thread count pinned to match (`OPENBLAS_NUM_THREADS=8`,
  `OMP_NUM_THREADS=8`, `MKL_NUM_THREADS=8`). Without the thread cap the
  conda build of R starts 48 BLAS threads inside the 8 allotted cores and
  thrashes: on 2026-09-17 that turned an 80-minute fit into more than
  two and a half hours with nothing produced. A second job on this
  machine was using about 13 cores and 91 GB of the 125 GB when the run
  started.
- Each script is launched detached so it survives the session, logging to
  the scratchpad.

## Changes required

Each change is marked `# [run-interp]` in the code and committed
separately on this branch.

### 1. `1_veg_lct_prep.R`: guard the non-interp half

*Problem.* The script reads the raw REVEALS output
`data/veg_pred_LGM_8.0.RDS` at line 30 and the taxon table as
`taxon2LCT_translation_v2.csv` at line 32 (the repository has
`taxon2LCT_translation_v2.0.csv`). Neither is present, so the script
aborted at line 30, before reaching its interp half.

*Why it is safe.* The interp half, lines 214 onward, is self-contained:
it needs only `data/veg_posts_interp_ice.RDS` and the projection strings
defined in the shared setup above.

*Change.* Wrapped lines 30 to 212 in `if (run_nointerp) { ... }`, with
`run_nointerp` and `run_interp` set by `file.exists()` at the top, the
same pattern scripts 2 to 7 already use. The script now stops with a
clear message if the interp input is missing, and skips the non-interp
half with a note if the REVEALS source is missing.

*Status.* Committed; script 1 running.

### Script 1 output, checked 2026-09-19

Ran in about four minutes, most of it the network elevation lookup.

| | interp | non-interp, for comparison |
|---|---|---|
| modern cells | 2,860 | 505 |
| paleo rows | 69,936 (2,860 cells x 24.5 slices on average, ice-masked) | 4,453 |
| time slices | 25 | 12 |
| ET + OL + ST | exactly 1.0000 everywhere, no NAs | sums below 1 where taxa with no cover class were dropped |

Two things worth recording. The interp cover fractions sum to exactly
one, so the "paleo rows off the simplex" half of question B1 does not
apply to this flavour, though the rank deficiency of a three-dimensional
smooth on three variables that sum to one still does. And the interp
files carry **no projected coordinates**: their `x` and `y` are
longitude and latitude in degrees, where the non-interp files' `x` and
`y` are Albers metres. Since the calibration fits `s(x, y)` on whichever
columns carry those names, the two flavours fit the spatial smooth in
different geometries. That is a science question, not a bug to fix
mid-run, and it is written up as B2a in
`questions_for_andria_scientific.md`. This run reproduces the code as
written.

### Script 2 output, checked 2026-09-19

Ran in about 20 minutes, most of it the 98 monthly albedo maps. Wrote
`calibration_modern_lct_interp_bluesky.RDS` and its `_coarse` twin, both
2,860 cells x 12 months, with no change to the script. No errors.

The table exposed the polar-night gap now written up as question B2b:
December has no albedo for any cell above 60N (1,109 of 2,860 missing),
January above 62.5N, November above 66.5N, against 33 missing in the
summer months. The calibration drops those rows silently
(`na.action = na.omit`) and the prediction step then covers them by
extrapolation. Also checked: nothing in this table hits the 0.0001 zero
replacement, so that issue is confined to the non-interp flavour.

## Prerequisites and what is still blocked

| Script | Interp inputs | Status |
|---|---|---|
| 1 | `veg_posts_interp_ice.RDS` | present (LFS) |
| 2 | script 1 outputs, blue-sky GeoTIFF, grid, boundaries | present |
| 3 | script 2 output, `make_grid.R` | present (helper is a reconstruction) |
| 4, 5, 6 | chain from script 2 | fine once 1 and 2 finish |
| 7 | script 6 output, ice shapefiles, `albedo_glacier_monthly.csv` | 🟧 glacier albedo table missing |
| 7a | script 6 output, Dalton ice raster, glacier albedo table | 🟧 both missing |
| 8 | 7a output, three kernels | 🟧 needs 7a; CACK kernel pending manual download |

So this run can reach the end of script 6, giving twelve months of
calibration models and Holocene albedo hindcasts on the full grid. The
albedo differences and the radiative forcing stay blocked on the three
data items in `questions_for_andria_general.md` section 3.

## Notes on scale

The interp calibration is much larger than the non-interp one already
run: roughly 2,870 cells instead of 505, twelve months instead of one,
and larger basis sizes (`k = 500` spatial and `k = 200` cover, against
350 and 50). Script 4 as written also fits the eight-model ladder for
every month and then refits model 8 for every month again, and runs a
seven-model spatial experiment on top. Runtime is unknown; it will be
measured here rather than guessed.
