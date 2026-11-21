# Refit run 8 (raster control: the current configuration with Andria's blue-sky raster instead of the MODIS
# cells), 1 November 2026: model fitting for sep-dec, one of three month-split parts run at once on code-identical
# commits of refit-runs (code of 837f2d3). Fixed seed 1549466984 as every refit run. Its calibration table must
# have MD5 8119f5066dc82d79571e94f7a6e791e6, the 18 October run's. The rest of the pipeline runs once from
# these fits (run8-raster).
list(
  name     = 'run8-raster-fit-sep-dec',
  commit   = 'bd174cf',
  config   = 'config.R',
  settings = list(analysis = list(months = c('sep','oct','nov','dec'), albedo = list(source = 'legacy_raster'),
                                  draws = list(seed = 1549466984))),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R', 'scripts/4_calibration_model.R'),
  checks   = list('tests/test_config.R', 'tests/test_paths.R'),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1', CORES = '24-31'))
