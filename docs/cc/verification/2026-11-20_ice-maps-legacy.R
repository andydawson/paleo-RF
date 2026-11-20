# Script 7's map ice (branch ice-maps), 1 of 2: the original analysis (configs/legacy_config.R) must still
# reproduce its anchors byte for byte, as the regression contract requires
# (docs/cc/2026-10-08_single_config_regression_contract.md, section 2): all six files of the tail anchor
# (scripts 7, 7a and 8) and all four of the forcing anchor (script 9). The legacy configuration keeps the
# old raster ("dalton_ice"), so script 7 takes the unchanged path through the 21 glacier outlines; the same
# path serves config.R's default. Scripts 7 to 10 from the frozen legacy prediction summary.
list(
  name    = 'ice-maps-legacy',
  commit  = '4e8532c91893c496ea5d0633c169b899ceeac7b4',
  config  = 'configs/legacy_config.R',
  seed    = c('prediction_summary'),
  scripts = c('scripts/7_plot_preds.R', 'scripts/7a_alb_diff_full.R', 'scripts/8_radiative.R',
              'scripts/9_forcing_barplot.R', 'scripts/10_forcing_breakdown.R'),
  anchors = c('tests/anchors/interp-tail-2026-09-21', 'tests/anchors/interp-forcing-2026-10-08'),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '8', CORES = '8-15'))   # 8 threads, as the regression contract asks of comparison runs
