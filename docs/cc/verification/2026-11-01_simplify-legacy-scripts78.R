# Simplifications: scripts 7, 7a and 8 under the original configuration (script 7's map theme stated once) must
# reproduce the whole tail anchor; script 7's figures are compared with the base run (simplify-script7-base).
list(name = 'simplify-legacy-scripts78', commit = '51888b4742b949ec4a26f33f56643508a7e73b69', config = 'configs/legacy_config.R',
     seed = c('prediction_summary'),
     scripts = c('scripts/7_plot_preds.R', 'scripts/7a_alb_diff_full.R', 'scripts/8_radiative.R'),
     checks  = list(c('tools/check_anchors.R', 'tests/anchors/interp-tail-2026-09-21', '.rundirs/simplify-legacy-scripts78', '--all')),
     rscript = 'tools/rscript.sh', env = c(THREADS = '8', CORES = '16-23'))
