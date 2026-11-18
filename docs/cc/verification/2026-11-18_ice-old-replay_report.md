# Verification ice-old-replay: PASS

- verdict: **PASS**
- commit: c0b6eda3573f0c8c4d8770d2b2494888cc433af7
- spec: `/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/ice_specs/2026-11-17_ice-old-replay.R`
- started 2026-11-18 13:17:23 UTC, finished 2026-11-18 15:42:59 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/c0b6eda` at c0b6eda3573f0c8c4d8770d2b2494888cc433af7; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/ice-old-replay`; configuration `.rundirs/ice-old-replay/config_used.R` (from `config.R`); 1 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=0-7

## Scripts

- scripts/7_plot_preds.R: exit status 0, 80.0 min, run record `20261118T131740.713Z_1420458.md`, 4 outputs
- scripts/7a_alb_diff_full.R: exit status 0, 61.4 min, run record `20261118T143739.053Z_1465467.md`, 1 outputs
- scripts/8_radiative.R: exit status 0, 0.4 min, run record `20261118T153902.634Z_1504595.md`, 1 outputs
- scripts/9_forcing_barplot.R: exit status 0, 0.7 min, run record `20261118T153926.362Z_1504909.md`, 4 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.3 min, run record `20261118T154010.781Z_1505239.md`, 1 outputs

## Anchors


## Checks

- `-e headline = "/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main"; run = ".rundirs/ice-old-replay"
# Script 7: the headline's four outputs with only the oldest slice's labels changed. The coarse differences
# hold its ice mask (ice_old of the oldest pair); the outlines are those of its 12 ka polygon.
new_labels = c("12 ka" = "11.5 ka", "10 - 12 ka" = "10 - 11.5 ka")
relabelled = function(table) {
  if ("ages" %in% names(table)) table$ages[table$ages == 12000] = 11500
  if ("facets" %in% names(table)) {
    renamed = levels(table$facets) %in% names(new_labels)
    levels(table$facets)[renamed] = unname(new_labels[levels(table$facets)[renamed]])
  }
  table
}
for (path in c("data/ice_fort.RDS", "data/ice_fort_diff_young.RDS", "data/ice_fort_diff_old.RDS", "data/alb_interp_preds_diffs_bluesky.RDS"))
  stopifnot(identical(readRDS(file.path(run, path)), relabelled(readRDS(file.path(headline, path)))))
stopifnot(any(readRDS(file.path(run, "data/ice_fort_diff_old.RDS"))$facets == "10 - 11.5 ka"))
cat("ice-old-replay: script 7 as in the headline, labels aside; the oldest difference map has its outline\n")
`: exit status 0 (log `check_01.log`)
- `-e headline = "/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main"; run = ".rundirs/ice-old-replay"
# The copied input is the headline's.
stopifnot(unname(tools::md5sum(file.path(run, "output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS"))) == "3ea14ce0680872ce9b99a6224747ac15")
# Scripts 7a and 8: the headline's columns identical (values, row order, attributes), only the named columns added.
same_table = function(path, added) {
  old = readRDS(file.path(headline, path)); new = readRDS(file.path(run, path))
  stopifnot(identical(setdiff(names(new), names(old)), added), identical(new[, names(old)], old))
}
exposed = c("alb_diff_veg_part_exposed", "alb_diff_ice_part_exposed")
same_table("data/ALB_diffs_bluesky.RDS", exposed)
same_table("output/forcing/RF_holocene_all_cases.RDS",
           c(exposed, paste0("rf_", rep(c("hadgem", "cam5", "cack"), each = 2), c("_veg_part_exposed", "_ice_part_exposed"))))
# Scripts 9 and 10: the headline's files line for line, the oldest label renamed; the variant table may only add rows.
relabelled = function(path) gsub("\"10 - 12 ka\"", "\"10 - 11.5 ka\"", gsub("\"10 - 12\"", "\"10 - 11.5\"", readLines(file.path(headline, path)), fixed = TRUE), fixed = TRUE)
for (path in c("output/forcing/forcing_by_period.csv", "output/forcing/forcing_by_period_egu2024recipe_vs_slide.csv",
               "output/forcing/modern_ipcc_ar6_erf.csv", "output/forcing/forcing_by_month_latitude.csv"))
  stopifnot(identical(readLines(file.path(run, path)), relabelled(path)))
old = relabelled("output/forcing/forcing_by_period_variant_sensitivity.csv")
new = readLines(file.path(run, "output/forcing/forcing_by_period_variant_sensitivity.csv"))
stopifnot(identical(new[seq_along(old)], old), length(new) == length(old) + 14, all(grepl("_part_exposed\"$", new[-seq_along(old)])))
cat("ice-old-replay: every column and number of the headline reproduced\n")
`: exit status 0 (log `check_02.log`)
- `tools/check_ice_split.R .rundirs/ice-old-replay`: exit status 0 (log `check_03.log`)
- `tests/test_config.R`: exit status 0 (log `check_04.log`)
- `tests/test_paths.R`: exit status 0 (log `check_05.log`)
- `tests/test_differences.R`: exit status 0 (log `check_06.log`)
- `tests/test_build_nadi1_fractions.R`: exit status 0 (log `check_07.log`)
- `tests/test_run_manifest.R`: exit status 0 (log `check_08.log`)
- `tests/test_calendar.R`: exit status 0 (log `check_09.log`)
- `tests/test_forcing_periods.R`: exit status 0 (log `check_10.log`)
- `tests/test_forcing_components.R`: exit status 0 (log `check_11.log`)
- `tests/test_forcing_breakdown.R`: exit status 0 (log `check_12.log`)
- `tests/test_hindcast_comparison.R`: exit status 0 (log `check_13.log`)
- `-e run = ".rundirs/ice-old-replay"; nadi1 = "/home/expert/Documents/contracting/Andria/paleo-RF/data/nadi1/shapefiles/NADI-1 shapefiles Dalton et al. QSR"
# The three NADI-1 files rebuilt from the shapefiles into this run's folder have the committed files'
# checksums, and the committed files are left untouched (the builder writes where OUT_DIR says).
builder = new.env(); sys.source("tools/build_nadi1_fractions.R", envir = builder)
builder$OUT_DIR = file.path(run, "nadi1_rebuilt")
committed = file.path("data/nadi1_fractions", paste0("nadi1_", c("optimal", "minimum", "maximum"), ".tif"))
before = list(unname(tools::md5sum(committed)), file.mtime(committed))
builder$build_nadi1_fractions(nadi1)
stopifnot(identical(unname(tools::md5sum(file.path(builder$OUT_DIR, basename(committed)))), before[[1]]),
          identical(list(unname(tools::md5sum(committed)), file.mtime(committed)), before))
cat("ice-old-replay: the three NADI-1 files rebuilt with the committed checksums\n")
`: exit status 0 (log `check_14.log`)

## Failures

- none
