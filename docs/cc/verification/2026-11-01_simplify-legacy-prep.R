# Simplifications (branch simplify-2026-11-01): scripts 1 and 2 under the original configuration must reproduce
# their anchors (script 1's diagnostics moved into R/land_cover_diagnostics.R).
list(name = 'simplify-legacy-prep', commit = 'simplify-2026-11-01', config = 'configs/legacy_config.R',
     scripts = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R'),
     checks  = list(c('tools/check_anchors.R', 'tests/anchors/interp-allmonths-2026-09-20', '.rundirs/simplify-legacy-prep')),
     rscript = 'tools/rscript.sh', env = c(THREADS = '8', CORES = '16-23'))
