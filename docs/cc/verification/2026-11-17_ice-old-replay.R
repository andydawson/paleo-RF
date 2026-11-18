# The ice work (branch ice-nadi1), 1 of 6: the default configuration with the old ice must reproduce the
# saved headline run. Scripts 7a to 10 run from the headline's own prediction summary and coarse
# differences (copied in), with its recorded seed, analysis$ice$fraction_source = "dalton_ice" written out,
# and config.R as it stands at the commit: the oldest period labelled 10 - 11.5 ka and the second split of
# the partial-ice forcing. Every column and number the headline has must come out identical; the only
# differences allowed are the new columns (the two second-split parts in scripts 7a and 8, their six
# forcings in script 8, their 14 rows appended to the variant-sensitivity table) and the oldest period's
# label, "10 - 12 ka" (and "10 - 12" in the EGU recipe) now "10 - 11.5 ka". Then the new columns' values
# (tools/check_ice_split.R) and the tests the work touches. The comparison for the meeting is made once, by
# ice-comparison. Design: docs/cc/2026-11-16_ice_redesign_simpler_codex_gpt6astra.md, section 3. Fill in
# the commit before running.
headline = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main'   # d5d5df5, PASS 2026-11-02
run      = '.rundirs/ice-old-replay'

replay_check = paste0('headline = ', deparse(headline), '; run = ', deparse(run), '
# The two copied inputs are the headline\'s.
stopifnot(unname(tools::md5sum(file.path(run, "output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS"))) == "3ea14ce0680872ce9b99a6224747ac15",
          unname(tools::md5sum(file.path(run, "data/alb_interp_preds_diffs_bluesky.RDS"))) == "73b556fd6fb63a08dcf3dde950a981e5")
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

list(
  name     = 'ice-old-replay',
  commit   = 'TO_FILL',   # the full commit of ice-nadi1 to verify
  config   = 'config.R',
  settings = list(analysis = list(draws = list(seed = 1549466984), ice = list(fraction_source = 'dalton_ice'))),
  copy     = list(c(file.path(headline, 'output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS'), 'output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS'),
                  c(file.path(headline, 'data/alb_interp_preds_diffs_bluesky.RDS'), 'data/alb_interp_preds_diffs_bluesky.RDS')),
  scripts  = c('scripts/7a_alb_diff_full.R', 'scripts/8_radiative.R', 'scripts/9_forcing_barplot.R', 'scripts/10_forcing_breakdown.R'),
  checks   = list(c('-e', replay_check), c('tools/check_ice_split.R', run),
                  'tests/test_config.R', 'tests/test_paths.R', 'tests/test_differences.R', 'tests/test_build_nadi1_fractions.R',
                  'tests/test_run_manifest.R', 'tests/test_calendar.R', 'tests/test_forcing_periods.R', 'tests/test_forcing_components.R',
                  'tests/test_forcing_breakdown.R', 'tests/test_hindcast_comparison.R'),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '8', CORES = '0-7'))   # 8 threads, as the regression contract asks of comparison runs; any free 8 cores
