# The non-interp flavour: scripts and data

Companion to the main `README.md`, which describes the interp flavour
only. The non-interp (point-based) flavour uses only the ~505 one-degree
cells that contain pollen sites and, in the code as received, fits March
only. By agreement with Andria (2026-09-17) it is not developed further;
this page records what it needs and produces so it can be revived without
reconstruction. It ran end to end on 2026-09-16 (March) and 2026-09-17
(May) on branch `chris-dev` with the changes listed at the end.

Legend: 🟧 **missing** = required and not in the repository;
<mark>unknown</mark> = provenance not confirmed. Line numbers (`script:line`)
refer to the scripts on `chris-dev`; commented-out loads are marked.

## Scripts

| Script | Does | Reads | Writes |
|---|---|---|---|
| `1_veg_lct_prep.R` (first half) | REVEALS taxon fractions -> ET/ST/OL per cell and slice, aggregated to cells with pollen sites; elevation via `elevatr` | `data/veg_pred_LGM_8.0.RDS`, `data/taxon2LCT_translation_v2.csv`, `data/grid.RDS` | `data/lct_modern_reveals.RDS`, `data/lct_paleo_reveals.RDS` |
| `2_calibration_lct_bluesky.R` (first half) | monthly albedo at the modern cells: native pixel, 1-degree mean, and point scale | `data/blue_sky_monthly_2000-2009.tif`, `data/grid.RDS`, `data/lct_modern_reveals.RDS`, `data/lct_modern_reveals_point.RDS`, `pbs*.RDS` | `data/calibration_modern_lct_bluesky.RDS`, `..._coarse.RDS`, `..._point.RDS` |
| `3_plot_cal_lct_albedo.R` (first half) | diagnostic plots | the three calibration tables, `scripts/make_grid.R` | figures |
| `4_calibration_model.R` (commented-out March ladder, lines 573-785 as received) | mod1-mod8 and mod7_free for March | `data/calibration_modern_lct_bluesky.RDS` | `data/calibration_mod{1..8,7_free}_bluesky.RDS` |
| `5_calibration_eval.R` (lines 890-985 as received) | AIC/ANOVA comparison; saves model 8 as selected; model-vs-data figures | the model files above | `data/calibration_model_selected_bluesky.RDS`, figures |
| `6_prediction_model.R` (`## XXX OLD` block) | hindcast March albedo per slice with 100 draws | `data/calibration_model_selected_bluesky.RDS`, `data/lct_paleo_reveals.RDS` | `data/paleo_predict_gam_bluesky.RDS`, `..._samps_bluesky.RDS`, `..._summary_bluesky.RDS` |
| `7_plot_preds.R` (second half) | albedo, uncertainty and difference maps | `data/paleo_predict_gam[_summary]_bluesky.RDS`, `data/grid.RDS`, ice shapefiles, `pbs*.RDS` | figures, `data/alb_preds_diffs_bluesky.RDS` |
| 7a and 8 | no non-interp version exists | | |

## External inputs

| File | Role | What | Provenance | Status |
|---|---|---|---|---|
| `data/veg_pred_LGM_8.0.RDS` | input to 1 (`1:30`) | REVEALS output: taxon fractions per cell and slice with simulation draws (`mediansim`) | Andria's group, REVEALS run; <mark>unknown</mark> version | 🟧 **missing** (script 1's outputs are committed, so 2-7 can run without it) |
| `data/taxon2LCT_translation_v2.csv` | input to 1 (`1:32`) | pollen taxon -> ET/ST/OL/NA | <mark>unknown</mark> | 🟧 **missing** under that name; `taxon2LCT_translation_v2.0.csv` is present and is probably the same file |
| `data/lct_modern_reveals_point.RDS` | input to 2 (`2:74`, commented out on `chris-dev`) | modern land cover at site (point) scale | no script writes it; <mark>unknown</mark> | 🟧 **missing** |
| `data/blue_sky_monthly_2000-2009.tif`, `data/grid.RDS`, `pbs*.RDS`, ice shapefiles | as in the main README (`2:95`, `2:39`, `2:36-37`, `7:57`) | | | present |
| `data/calibration_brms_m{1..8}_bluesky.RDS` | input to 5 (`5:1003`, guarded on `chris-dev`) | Bayesian (brms) versions of the calibration models | no script writes them; <mark>unknown</mark> | 🟧 **missing** |

## Derived files and results

| File | Written by | Read by | Status in repo |
|---|---|---|---|
| `data/lct_modern_reveals.RDS` | 1 | 2 (`2:50`) | present but stale: 1,029 site-level rows with cover in percent, committed 2023-03-02; inconsistent with everything below (known issue #29). On `chris-dev` script 2 falls back to the age-50 slice of the paleo file, which equals the committed calibration sites exactly |
| `data/lct_paleo_reveals.RDS` | 1 | 6 (`6:124`), and 2 (`2:58`, the age-50 fallback on `chris-dev`) | present (505 cells x 12 slices, committed 2023-05-16) |
| `data/calibration_modern_lct_bluesky.RDS` | 2 | 3 (`3:19`), 4 (`4:588`), 5 (`5:22`) | present (505 cells x 12 months); regenerated identically on 2026-09-16 |
| `data/calibration_modern_lct_bluesky_coarse.RDS`, `_point.RDS` | 2 | 3 (`3:24`; point `3:29`, commented out) | coarse regenerated (untracked); point cannot be produced (input missing) |
| `data/calibration_mod{1..7}_bluesky.RDS` | 4 (the saveRDS lines are commented out as received) | 5 (`5:905` onward) | present; committed versions are from two generations (mod1-4 fitted to a `bs03` response on 1,028 rows, mod5-7 to `mar` on 496) |
| `data/calibration_mod8_bluesky.RDS`, `calibration_mod7_free_bluesky.RDS` | 4 | 5 (`5:905` onward) | not committed; regenerated 2026-09-16 (March) and 2026-09-17 (May, `_may_` tag) |
| `data/calibration_model_selected_bluesky.RDS` | 5 | 6 (`6:129`) | not committed; regenerated |
| `data/paleo_predict_gam_bluesky.RDS`, `..._summary_bluesky.RDS` | 6 | 7 (`7:22`, `7:1378`) | present (4,453 cell-slices, March); regenerated version matches (corr 0.999) |
| `data/paleo_predict_gam_samps_bluesky.RDS` | 6 | | not committed (10 MB); regenerated |
| `data/alb_preds_diffs_bluesky.RDS` | 7 | | not committed; regenerated |
| `data/preds_alb_diffs_sub_bluesky.RDS` | archive/8_plot_preds.R | | present; legacy |

## Changes needed to run it (branch `chris-dev`, commits of 2026-09-16/17)

All marked `# [run-nointerp]` or `# [run-may]` in the scripts:
`run_interp` guards around the interp blocks; the March ladder in script
4 uncommented, its `mod7_free` save fixed and the unused `mod9` disabled;
`scripts/make_grid.R` reconstructed; `rgeos`, `rgdal` and `SemiPar`
dropped; the point-scale extraction commented out; an empty ice overlay
when the shapefiles were absent; the age-50 fallback for the modern table;
`CAL_MONTH` (default `may`) selecting the month, with outputs tagged
`<month>_bluesky`. Results and comparison with the EGU talk:
`docs/cc/2026-09-17_nointerp_run_report_for_meeting.docx`.
