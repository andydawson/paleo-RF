# Fixes after the integration review (branch gate-fixes), 1 of 2. Dead code deleted in scripts 7a and 9 and one
# unused catalogue entry in R/paths.R must leave the original analysis unchanged: scripts 7 to 10 from the frozen
# legacy prediction summary, byte for byte against the tail anchor (scripts 7, 7a and 8) and the forcing anchor
# (script 9). The comment check's new failure case and the other touched code are covered by the test files.
list(
  name    = 'gate-fixes-tail',
  commit  = '5cadb41affefe1db093bdd6e3906b60a9217f420',
  config  = 'configs/legacy_config.R',
  seed    = c('prediction_summary'),
  scripts = c('scripts/7_plot_preds.R', 'scripts/7a_alb_diff_full.R', 'scripts/8_radiative.R',
              'scripts/9_forcing_barplot.R', 'scripts/10_forcing_breakdown.R'),
  anchors = c('tests/anchors/interp-tail-2026-09-21', 'tests/anchors/interp-forcing-2026-10-08'),
  checks  = list('tests/test_check_comments_only.R', 'tests/test_paths.R', 'tests/test_config.R'),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '8', CORES = '0-7'))
