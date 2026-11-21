# The cover-contrast summaries at the four case-study boxes: the case-studies command of
# tools/explore_cover_contrasts.R, the comparison with Duveiller et al. (2018) on its cases, their
# tests (tests/test_explore_cover_contrasts.R) and their real-data checks
# (tools/check_cover_contrasts.R case-studies and duveiller-case-studies). Design:
# docs/cc/2026-11-18_case_study_contrasts_design_codex_gpt6astra.md, approved by Chris on 18 November
# 2026 without its checks at run time; the inputs are checked here once instead.
#
# The tests, and the three runs' inputs as traced. Then one case-studies job per albedo table
# (twelve months each: the saved fits of the full run of 16 November evaluated at the boxes, not
# refitted) into one new folder inside this verification's run folder; the report; its check; the
# comparison with Duveiller et al. on the new cases; its check against the comparison verified on
# 17 November; and the existing duveiller check, rerun on that comparison, since two of its lines
# became helpers shared with the new checks. The saved run, the three runs, the earlier comparison
# and the published file are read only. The runs' saved configurations predate the ice setting,
# hence --fill-missing.
base       = '/home/expert/Documents/contracting/Andria/paleo-RF-verify'
saved      = file.path(base, '7c12534/.rundirs/cover-contrasts-full')
runs       = file.path(base, c('1d31cfc/.rundirs/cv2-holdouts',      # all days
                               '8e3f3a4/.rundirs/run2-snowfree-2',   # snow-free
                               '74b5482/.rundirs/run7-snowy'))       # snowy
earlier    = file.path(base, 'fa9e465/.rundirs/duveiller-comparison/comparison')
netcdf     = '/home/expert/Documents/contracting/Andria/paleo-RF/data/duveiller2018/albedo_IGBPdet.nc'   # MD5 96125db41154fa176c53b51596893ad6
out        = '.rundirs/case-study-cover-contrasts/summaries'
comparison = '.rundirs/case-study-cover-contrasts/duveiller'
tool       = 'tools/explore_cover_contrasts.R'
check      = 'tools/check_cover_contrasts.R'
jobs = lapply(runs, function(run) c(tool, 'case-studies', run, saved, out, '--fill-missing'))
list(
  name    = 'case-study-cover-contrasts-2',
  commit  = '295b31277829ea127dbdfd6f596701df586cf270',
  config  = 'config.R',
  scripts = character(),
  checks  = c(list('tests/test_cv_separation.R',
                   'tests/test_training_support.R',
                   'tests/test_explore_cover_contrasts.R',
                   'tests/test_config.R',
                   'tests/test_paths.R',
                   c(check, 'inputs', runs, '--fill-missing')),
              jobs,
              list(c(tool, 'report', out),
                   c(check, 'case-studies', out, saved, runs[1], '--fill-missing'),
                   c(tool, 'duveiller', saved, netcdf, comparison, out),
                   c(check, 'duveiller-case-studies', comparison, file.path(earlier, 'cover_contrasts_duveiller.csv')),
                   c(check, 'duveiller', earlier, saved, netcdf))),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1'))
