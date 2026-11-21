# Environment check after adding GDAL HDF4/HDF5/netCDF drivers and ecmwfr (2026-10-15):
# script 2 under the legacy configuration must still match its regression anchors.
list(
  name    = 'env-drivers-script2',
  commit  = '79f1491b38d21c18e2bffc4fac21507a1177c301',
  config  = 'configs/legacy_config.R',
  seed    = c('lct_modern'),
  scripts = 'scripts/2_calibration_lct_bluesky.R',
  checks  = list(c('tools/check_anchors.R', 'tests/anchors/interp-allmonths-2026-09-20', '.rundirs/env-drivers-script2')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '8', CORES = '8-15'))
