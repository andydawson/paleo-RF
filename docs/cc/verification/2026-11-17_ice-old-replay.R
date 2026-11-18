# The ice work (branch ice-nadi1), 1 of 6: the default configuration with the old ice must reproduce the
# saved headline run. Scripts 7 to 10 run from the headline's own prediction summary (copied in), with its
# recorded seed, analysis$ice$fraction_source = "dalton_ice" written out, and config.R as it stands at the
# commit: the oldest slice labelled 11.5 ka and its period 10 - 11.5 ka, and the second split of the
# partial-ice forcing. Every column and number the headline has must come out identical; the only
# differences allowed are the new columns (the two second-split parts in scripts 7a and 8, their six
# forcings in script 8, their 14 rows appended to the variant-sensitivity table) and the oldest slice's
# labels: in script 7's four outputs its age 12000 now 11500, "12 ka" now "11.5 ka" and "10 - 12 ka" now
# "10 - 11.5 ka"; in scripts 9 and 10 "10 - 12 ka" (and "10 - 12" in the EGU recipe) now "10 - 11.5 ka".
# So the oldest slice keeps its ice mask and outline from the 12 ka polygon, and the oldest difference map
# has its outline (Chris, 18 November 2026; review docs/cc/2026-11-17_ice_build_review_codex_gpt6astra.md).
# Then the new columns' values (tools/check_ice_split.R), the tests the work touches, and the three NADI-1
# files rebuilt from the shapefiles into this run's folder, which must have the committed files' checksums.
# The comparison for the meeting is made once, by ice-comparison. Design:
# docs/cc/2026-11-16_ice_redesign_simpler_codex_gpt6astra.md, section 3. Fill in the commit before running.
headline = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main'   # d5d5df5, PASS 2026-11-02
run      = '.rundirs/ice-old-replay'
nadi1    = '/home/expert/Documents/contracting/Andria/paleo-RF/data/nadi1/shapefiles/NADI-1 shapefiles Dalton et al. QSR'   # not in git

script7_check = paste0('headline = ', deparse(headline), '; run = ', deparse(run), '
# Script 7: the headline\'s four outputs with only the oldest slice\'s labels changed. The coarse differences
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
cat("ice-old-replay: script 7 as in the headline, labels aside; the oldest difference map has its outline\\n")
')

replay_check = paste0('headline = ', deparse(headline), '; run = ', deparse(run), '
# The copied input is the headline\'s.
stopifnot(unname(tools::md5sum(file.path(run, "output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS"))) == "3ea14ce0680872ce9b99a6224747ac15")
# Scripts 7a and 8: the headline\'s columns identical (values, row order, attributes), only the named columns added.
same_table = function(path, added) {
  old = readRDS(file.path(headline, path)); new = readRDS(file.path(run, path))
  stopifnot(identical(setdiff(names(new), names(old)), added), identical(new[, names(old)], old))
}
exposed = c("alb_diff_veg_part_exposed", "alb_diff_ice_part_exposed")
same_table("data/ALB_diffs_bluesky.RDS", exposed)
same_table("output/forcing/RF_holocene_all_cases.RDS",
           c(exposed, paste0("rf_", rep(c("hadgem", "cam5", "cack"), each = 2), c("_veg_part_exposed", "_ice_part_exposed"))))
# Scripts 9 and 10: the headline\'s files line for line, the oldest label renamed; the variant table may only add rows.
relabelled = function(path) gsub("\\"10 - 12 ka\\"", "\\"10 - 11.5 ka\\"", gsub("\\"10 - 12\\"", "\\"10 - 11.5\\"", readLines(file.path(headline, path)), fixed = TRUE), fixed = TRUE)
for (path in c("output/forcing/forcing_by_period.csv", "output/forcing/forcing_by_period_egu2024recipe_vs_slide.csv",
               "output/forcing/modern_ipcc_ar6_erf.csv", "output/forcing/forcing_by_month_latitude.csv"))
  stopifnot(identical(readLines(file.path(run, path)), relabelled(path)))
old = relabelled("output/forcing/forcing_by_period_variant_sensitivity.csv")
new = readLines(file.path(run, "output/forcing/forcing_by_period_variant_sensitivity.csv"))
stopifnot(identical(new[seq_along(old)], old), length(new) == length(old) + 14, all(grepl("_part_exposed\\"$", new[-seq_along(old)])))
cat("ice-old-replay: every column and number of the headline reproduced\\n")
')

rebuild_check = paste0('run = ', deparse(run), '; nadi1 = ', deparse(nadi1), '
# The three NADI-1 files rebuilt from the shapefiles into this run\'s folder have the committed files\'
# checksums, and the committed files are left untouched (the builder writes where OUT_DIR says).
builder = new.env(); sys.source("tools/build_nadi1_fractions.R", envir = builder)
builder$OUT_DIR = file.path(run, "nadi1_rebuilt")
committed = file.path("data/nadi1_fractions", paste0("nadi1_", c("optimal", "minimum", "maximum"), ".tif"))
before = list(unname(tools::md5sum(committed)), file.mtime(committed))
builder$build_nadi1_fractions(nadi1)
stopifnot(identical(unname(tools::md5sum(file.path(builder$OUT_DIR, basename(committed)))), before[[1]]),
          identical(list(unname(tools::md5sum(committed)), file.mtime(committed)), before))
cat("ice-old-replay: the three NADI-1 files rebuilt with the committed checksums\\n")
')

list(
  name     = 'ice-old-replay',
  commit   = 'TO_FILL',   # the full commit of ice-nadi1 to verify
  config   = 'config.R',
  settings = list(analysis = list(draws = list(seed = 1549466984), ice = list(fraction_source = 'dalton_ice'))),
  copy     = list(c(file.path(headline, 'output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS'), 'output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS')),
  scripts  = c('scripts/7_plot_preds.R', 'scripts/7a_alb_diff_full.R', 'scripts/8_radiative.R', 'scripts/9_forcing_barplot.R',
               'scripts/10_forcing_breakdown.R'),
  checks   = list(c('-e', script7_check), c('-e', replay_check), c('tools/check_ice_split.R', run),
                  'tests/test_config.R', 'tests/test_paths.R', 'tests/test_differences.R', 'tests/test_build_nadi1_fractions.R',
                  'tests/test_run_manifest.R', 'tests/test_calendar.R', 'tests/test_forcing_periods.R', 'tests/test_forcing_components.R',
                  'tests/test_forcing_breakdown.R', 'tests/test_hindcast_comparison.R',
                  c('-e', rebuild_check)),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '8', CORES = '0-7'))   # 8 threads, as the regression contract asks of comparison runs; any free 8 cores
