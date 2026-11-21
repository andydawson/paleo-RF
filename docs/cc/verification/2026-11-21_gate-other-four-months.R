# Final integration gate (issue #16), other settings 3 of 3, which Chris chose on 21 November 2026 to rerun on the
# final code: four months (feb, may, aug, nov) through scripts 5 to 10 with seed 1, from the original analysis's
# configuration, starting from the baseline fits of script 4 (its code ran in full at the gate). Each of the four
# months' draw and summary files must equal the twelve-month seed-1 anchor's byte for byte, and the per-cell forcing
# must hold exactly those months. Last run in October (changelog, I04b); script 10 did not exist then. Commit 68ca9ad
# is the trunk's tip. 8 threads, as in gate run 1, which matched the seed-1 anchor.
months = c('feb', 'may', 'aug', 'nov')
list(
  name     = 'gate-other-four-months',
  commit   = '68ca9ad9662f13fb3f515d128ea4d20cfd41808a',
  config   = 'configs/legacy_config.R',
  settings = list(analysis = list(months = months)),
  seed     = c('calibration_table', 'calibration_ladder', 'calibration_spatial', 'calibration_spatial_elev_cover',
               'aic_table', 'lct_paleo'),
  copy     = lapply(months, function(m) c(sprintf('output/calibration/calibration_mod8_interp_%s_bluesky.RDS', m),
                                          sprintf('output/calibration/calibration_prediction_fit_%s_bluesky.RDS', m))),
  scripts  = c('scripts/5_calibration_eval.R', 'scripts/6_prediction_model.R', 'scripts/7_plot_preds.R',
               'scripts/7a_alb_diff_full.R', 'scripts/8_radiative.R', 'scripts/9_forcing_barplot.R',
               'scripts/10_forcing_breakdown.R'),
  checks   = list(c('-e', "source('tools/check_anchors.R')
                          r = check_anchors('tests/anchors/interp-seed1-2026-10-14', '.rundirs/gate-other-four-months')
                          r = r[grepl('_(feb|may|aug|nov)_bluesky[.]RDS$', r$file), ]; print(r, row.names = FALSE)
                          stopifnot(nrow(r) == 8, all(r$result == 'MATCH'))"),
                  c('-e', "f = readRDS('.rundirs/gate-other-four-months/output/forcing/RF_holocene_all_cases.RDS')
                          print(table(as.character(f$month)))
                          stopifnot(setequal(as.character(f$month), c('feb', 'may', 'aug', 'nov')))")),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '8', CORES = '8-15'))
