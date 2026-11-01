# Simplifications: script 7 at the base (ac90729, before the shared map theme), original configuration, for a
# figure-by-figure comparison with simplify-legacy-scripts78.
list(name = 'simplify-script7-base', commit = 'ac90729', config = 'configs/legacy_config.R',
     seed = c('prediction_summary'), scripts = 'scripts/7_plot_preds.R',
     rscript = 'tools/rscript.sh', env = c(THREADS = '8', CORES = '24-31'))
