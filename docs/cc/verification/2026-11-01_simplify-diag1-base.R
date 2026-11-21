# Simplifications: script 1 with its diagnostics on, original configuration, at the base commit (ac90729); the files in
# figures/diagnostics/ and the log are compared between base and head afterwards.
list(name = 'simplify-diag1-base', commit = 'ac90729', config = 'configs/legacy_config.R',
     settings = list(run = list(diagnostic = TRUE)),
     scripts = 'scripts/1_veg_lct_prep.R', rscript = 'tools/rscript.sh', env = c(THREADS = '8', CORES = '16-23'))
