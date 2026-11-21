# Final integration gate (issue #16), 2 of 3: the original analysis's tail, scripts 7 to 10 from the frozen legacy
# prediction summary, byte for byte against the tail anchor (scripts 7, 7a and 8) and the forcing anchor (script 9).
# Commit 6c86770 is the merge of the last change; its code is identical to 9c8dea1 (1 of 3), so the two can run side
# by side (same-commit runs share a worktree and collide).
list(
  name    = 'gate-legacy-tail',
  commit  = '6c867703fe7f76b1ddea5a6cfc8b01b1660f7325',
  config  = 'configs/legacy_config.R',
  seed    = c('prediction_summary'),
  scripts = c('scripts/7_plot_preds.R', 'scripts/7a_alb_diff_full.R', 'scripts/8_radiative.R',
              'scripts/9_forcing_barplot.R', 'scripts/10_forcing_breakdown.R'),
  anchors = c('tests/anchors/interp-tail-2026-09-21', 'tests/anchors/interp-forcing-2026-10-08'),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '8', CORES = '16-23'))
