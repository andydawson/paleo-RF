# Environment check after adding GDAL HDF4/HDF5/netCDF drivers and ecmwfr (2026-10-15):
# script 8 under the legacy configuration must still match its regression anchors.
list(
  name    = 'env-drivers-script8',
  commit  = '79f1491b38d21c18e2bffc4fac21507a1177c301',
  config  = 'configs/legacy_config.R',
  seed    = c('albedo_differences'),
  scripts = 'scripts/8_radiative.R',
  checks  = list(c('tools/check_anchors.R', 'tests/anchors/interp-tail-2026-09-21', '.rundirs/env-drivers-script8')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '8', CORES = '16-23'))
