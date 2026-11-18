# The ice work (branch ice-nadi1), 4 of 6: the forcing with the NADI-1 minimum ice (Dalton et al. 2023,
# data/nadi1_fractions/nadi1_minimum.tif, made by tools/build_nadi1_fractions.R). The same as
# ice-nadi1-optimal except analysis$ice$fraction_source = "nadi1_minimum", with the same check of the second
# split's new columns. The minimum and maximum are reconstruction outcomes, not confidence limits, and need
# not give the smallest and largest forcing. Fill in the commit before running.
headline = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main'   # d5d5df5, PASS 2026-11-02
run      = '.rundirs/ice-nadi1-minimum'
list(
  name     = 'ice-nadi1-minimum',
  commit   = 'TO_FILL',   # the full commit of ice-nadi1 to verify
  config   = 'config.R',
  settings = list(analysis = list(draws = list(seed = 1549466984), ice = list(fraction_source = 'nadi1_minimum'))),
  copy     = list(c(file.path(headline, 'output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS'), 'output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS'),
                  c(file.path(headline, 'data/alb_interp_preds_diffs_bluesky.RDS'), 'data/alb_interp_preds_diffs_bluesky.RDS')),
  scripts  = c('scripts/7a_alb_diff_full.R', 'scripts/8_radiative.R', 'scripts/9_forcing_barplot.R', 'scripts/10_forcing_breakdown.R'),
  checks   = list(c('tools/check_ice_split.R', run)),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '8', CORES = '24-31'))   # 8 threads, as the regression contract asks of comparison runs; any free 8 cores
