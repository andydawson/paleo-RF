# I15c script 2, the last renames, 3 November 2026, issue #18: scripts 1-2 under the current configuration on
# the MODIS cell albedo; the calibration table must match refit run 1's (code of 837f2d3), which used these
# settings. (Andria's raster under the same settings: i15c-script2-names-raster.)
run1 = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main/data'
here = '.rundirs/i15c-script2-names-current/data'
list(
  name     = 'i15c-script2-names-current',
  commit   = 'c3ef429',
  config   = 'config.R',
  settings = list(analysis = list(draws = list(seed = 1549466984))),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R'),
  checks   = list(c('tools/compare_tables.R', file.path(run1, 'calibration_modern_lct_interp_bluesky.RDS'),
                    file.path(here, 'calibration_modern_lct_interp_bluesky.RDS'))),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1'))
