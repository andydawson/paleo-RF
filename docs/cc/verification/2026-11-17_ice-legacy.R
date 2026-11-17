# The ice work (branch ice-nadi1), 2 of 6: the original analysis (configs/legacy_config.R) must still
# reproduce its anchors byte for byte, as the regression contract requires
# (docs/cc/2026-10-08_single_config_regression_contract.md, section 2): all six files of the tail anchor
# (scripts 7, 7a and 8) and all four of the forcing anchor (script 9). The work changes what scripts 7a, 8
# and 9 can produce (the ice-fraction setting, the second split of the partial-ice forcing, the oldest
# label), but none of it applies under the legacy configuration, which keeps the old raster, the
# "legacy_components" method and 12,000 BP with its alias. Scripts 7 to 10 from the frozen legacy
# prediction summary. Fill in the commit before running.
list(
  name    = 'ice-legacy',
  commit  = 'TO_FILL',   # the full commit of ice-nadi1 to verify
  config  = 'configs/legacy_config.R',
  seed    = c('prediction_summary'),
  scripts = c('scripts/7_plot_preds.R', 'scripts/7a_alb_diff_full.R', 'scripts/8_radiative.R',
              'scripts/9_forcing_barplot.R', 'scripts/10_forcing_breakdown.R'),
  anchors = c('tests/anchors/interp-tail-2026-09-21', 'tests/anchors/interp-forcing-2026-10-08'),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1', CORES = '21'))
