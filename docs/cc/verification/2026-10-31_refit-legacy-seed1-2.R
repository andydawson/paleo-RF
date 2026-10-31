# Second attempt (31 October): the first stopped on script 5's new check, which compared names as
# well as missing values (fixed in 83415db).
# Refit on the MODIS albedo (branch refit-modis): scripts 5 and 6 under the original configuration
# with seed 1, from the frozen fits, as in 2026-10-15_i16b-merged-legacy-seed1. Expected (Chris's
# decision 4, 29 October): 25 of the 26 seed-1 anchor files MATCH and calibration_model_stats.csv
# DIFFERs only in "data in credible interval", whose new values must lie in the ranges computed
# beforehand from the anchor (old x cells / observed cells, with both roundings). This run is the
# evidence for regenerating that anchor file; its own verdict is expected to be FAIL on that file.
months = c('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec')
list(
  name    = 'refit-legacy-seed1-2',
  commit  = 'refit-modis',
  config  = 'configs/legacy_config.R',
  seed    = c('calibration_table', 'calibration_ladder', 'calibration_spatial',
              'calibration_spatial_elev_cover', 'aic_table', 'lct_paleo'),
  copy    = lapply(months, function(m) c(sprintf('output/calibration/calibration_mod8_interp_%s_bluesky.RDS', m),
                                         sprintf('output/calibration/calibration_prediction_fit_%s_bluesky.RDS', m))),
  scripts = c('scripts/5_calibration_eval.R', 'scripts/6_prediction_model.R'),
  anchors = 'tests/anchors/interp-seed1-2026-10-14',
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '8', CORES = '8-15'))
