# Anchor guard: the default rule now fails when nothing was produced to compare. The negative
# case (an empty run directory fails) is in tests/test_tools.R; the positive case is a real
# partial run, script 8 under the legacy configuration (1 MATCH, the rest SEEDED or NOT
# PRODUCED), which must still pass.
list(
  name    = 'anchor-guard-2',
  commit  = '4f4245e6b1f0536f244cc446066d20a3ae4a6f4a',
  config  = 'configs/legacy_config.R',
  seed    = c('albedo_differences'),
  scripts = 'scripts/8_radiative.R',
  checks  = list('tests/test_tools.R', 'tests/test_verify_change.R',
                 c('tools/check_anchors.R', 'tests/anchors/interp-tail-2026-09-21', '.rundirs/anchor-guard-2')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '4', CORES = '16-19'))
