# I15c script 2, the last renames, 3 November 2026, issue #18: scripts 1-2 under the current configuration with
# Andria's raster (refit run 8's settings); the native and coarse calibration tables must match run 8's.
run8 = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/b689642/.rundirs/run8-raster-fit-jan-apr-2/data'
here = '.rundirs/i15c-script2-names-raster/data'
list(
  name     = 'i15c-script2-names-raster',
  commit   = 'c3ef429',
  config   = 'config.R',
  settings = list(analysis = list(albedo = list(source = 'legacy_raster'), draws = list(seed = 1549466984))),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R'),
  checks   = list(c('tools/compare_tables.R', file.path(run8, 'calibration_modern_lct_interp_bluesky.RDS'),
                    file.path(here, 'calibration_modern_lct_interp_bluesky.RDS')),
                  c('tools/compare_tables.R', file.path(run8, 'calibration_modern_lct_interp_bluesky_coarse.RDS'),
                    file.path(here, 'calibration_modern_lct_interp_bluesky_coarse.RDS'))),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1'))
