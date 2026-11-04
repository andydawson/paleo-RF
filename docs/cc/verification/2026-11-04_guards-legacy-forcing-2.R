# The two guards of 4 November (commit 8b8e432): scripts 9 and 10 under the original configuration from the seeded forcing
# and coarse differences must still reproduce the whole interp-forcing anchor (the period guard changes no output),
# with the forcing tests.
list(
  name    = 'guards-legacy-forcing-2',
  commit  = '8b8e432',
  config  = 'configs/legacy_config.R',
  seed    = c('forcing', 'coarse_differences'),
  scripts = c('scripts/9_forcing_barplot.R', 'scripts/10_forcing_breakdown.R'),
  checks  = list(c('tools/check_anchors.R', 'tests/anchors/interp-forcing-2026-10-08', '.rundirs/guards-legacy-forcing-2', '--all'),
                 'tests/test_calendar.R', 'tests/test_check_merge_evidence.R', 'tests/test_check_model7_convergence.R', 'tests/test_config.R', 'tests/test_differences.R', 'tests/test_model_registry.R', 'tests/test_preparation.R', 'tests/test_preparation_albedo.R', 'tests/test_random.R', 'tests/test_run_manifest.R', 'tests/test_tools.R', 'tests/test_verify_change.R', 'tests/test_bluesky_albedo.R', 'tests/test_forcing_periods.R', 'tests/test_training_support.R', 'tests/test_forcing_breakdown.R', 'tests/test_forcing_components.R'),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1'))
