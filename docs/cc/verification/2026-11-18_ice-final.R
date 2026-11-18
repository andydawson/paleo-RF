# The ice work's final code (branch ice-nadi1 after the trunk was merged in, 18 November 2026): every test file,
# and the real-data checks of the code changed since the forcing runs were verified at c0b6eda: saved
# configurations loading with --fill-missing (the cover-contrast tool's input check on three old runs) and the
# Duveiller comparison brought in from the trunk. The forcing itself is verified by the ice-old-replay,
# ice-legacy and ice-nadi1-* reports at c0b6eda, whose forcing code this commit does not change.
saved   = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/7c12534/.rundirs/cover-contrasts-full'
netcdf  = '/home/expert/Documents/contracting/Andria/paleo-RF/data/duveiller2018/albedo_IGBPdet.nc'
out     = '.rundirs/ice-final/duveiller'
tests   = as.list(sort(Sys.glob('/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/tests/test_*.R')))
tests   = lapply(tests, function(path) file.path('tests', basename(path)))
list(
  name    = 'ice-final',
  commit  = '0ffa156a6398c42a6c07d3664ce8059e0e484aa0',
  config  = 'config.R',
  scripts = character(),
  checks  = c(tests,
              list(c('tools/check_cover_contrasts.R', 'inputs', '../1d31cfc/.rundirs/cv2-holdouts', '../8e3f3a4/.rundirs/run2-snowfree-2',
                     '../74b5482/.rundirs/run7-snowy', '--fill-missing'),
                   c('tools/explore_cover_contrasts.R', 'duveiller', saved, netcdf, out),
                   c('tools/check_cover_contrasts.R', 'duveiller', out, saved, netcdf))),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1'))
