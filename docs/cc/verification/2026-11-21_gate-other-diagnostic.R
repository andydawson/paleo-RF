# Final integration gate (issue #16), other settings 1 of 3, which Chris chose on 21 November 2026 to rerun on the
# final code: script 1 in diagnostic mode, from the original analysis's configuration. The diagnostics must change no
# output: both land-cover tables must match the all-months anchor byte for byte (script 1 does not make the anchor's
# other three files, which the anchor check allows), and the diagnostic files must be written. Last run in October
# (changelog, I04b). Commit 91735fb has the trunk's current code (identical to 68ca9ad, the tip).
list(
  name     = 'gate-other-diagnostic',
  commit   = '91735fb47ba3b623e1912cc74362b6777fb4cfd8',
  config   = 'configs/legacy_config.R',
  settings = list(run = list(diagnostic = TRUE)),
  scripts  = c('scripts/1_veg_lct_prep.R'),
  checks   = list(c('tools/check_anchors.R', 'tests/anchors/interp-allmonths-2026-09-20', '.rundirs/gate-other-diagnostic'),
                  c('-e', "f = list.files('.rundirs/gate-other-diagnostic/figures/diagnostics'); print(f);
                          stopifnot(c('1_absent_cell_slices.csv', '1_ice_flag_all_slices.png', '1_mean_vs_median.png',
                                      '1_mean_vs_median_difference.png') %in% f,
                                    any(grepl('^1_ice_flag_[0-9]{5}BP[.]png$', f)))")),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1', CORES = '0-3'))
