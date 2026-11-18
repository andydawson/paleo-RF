# The ice work (branch ice-nadi1), 3 of 6: the forcing with the NADI-1 optimal ice (Dalton et al. 2023,
# data/nadi1_fractions/nadi1_optimal.tif, made by tools/build_nadi1_fractions.R). The same as
# ice-old-replay except analysis$ice$fraction_source = "nadi1_optimal": scripts 7a to 10 from the saved
# headline's prediction summary and coarse differences (copied in) with its recorded seed, so that only the
# ice differs from the headline (the vegetation predictions are the headline's, as the design says; the
# EGU 2024 recipe table of script 9 keeps the old polygons and is not part of the comparison). Then the
# values of the second split's new columns (tools/check_ice_split.R), and the comparison tool on this run
# beside the headline (the old ice), whose old-raster numbers must be the established ones
# (tools/check_compare_ice.R). Design: docs/cc/2026-11-16_ice_redesign_simpler_codex_gpt6astra.md,
# section 3. Fill in the commit before running.
headline = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main'   # d5d5df5, PASS 2026-11-02
run      = '.rundirs/ice-nadi1-optimal'
list(
  name     = 'ice-nadi1-optimal',
  commit   = 'TO_FILL',   # the full commit of ice-nadi1 to verify
  config   = 'config.R',
  settings = list(analysis = list(draws = list(seed = 1549466984), ice = list(fraction_source = 'nadi1_optimal'))),
  copy     = list(c(file.path(headline, 'output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS'), 'output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS'),
                  c(file.path(headline, 'data/alb_interp_preds_diffs_bluesky.RDS'), 'data/alb_interp_preds_diffs_bluesky.RDS')),
  scripts  = c('scripts/7a_alb_diff_full.R', 'scripts/8_radiative.R', 'scripts/9_forcing_barplot.R', 'scripts/10_forcing_breakdown.R'),
  checks   = list(c('tools/check_ice_split.R', run),
                  c('tools/compare_ice.R', file.path(run, 'ice_comparison'), headline, run),
                  c('tools/check_compare_ice.R', file.path(run, 'ice_comparison'), headline)),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '8', CORES = '16-23'))   # 8 threads, as the regression contract asks of comparison runs; any free 8 cores
