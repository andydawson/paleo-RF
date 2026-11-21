# I15c script 9 (after): script 9 under the legacy configuration from the frozen forcing tables.
list(
  name    = 'i15c-script9-after',
  commit  = '0e73cb5cffb8ff9cb38fe6d606d558cbaf55e145',
  config  = 'configs/legacy_config.R',
  seed    = c('forcing', 'coarse_differences'),
  scripts = 'scripts/9_forcing_barplot.R',
  anchors = 'tests/anchors/interp-forcing-2026-10-08',
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '8', CORES = '8-15'))
