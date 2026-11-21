# Second run, after the review fixes (refusal message, two argument cases, re-install note) and the pinning of
# the other 71 specs. Version-control fixes (Fable's minimal plan, approved by Chris on 4 November): the merge check also runs as
# pre-commit and needs both commits by hand; .gitignore anchored; 11 specs pinned; docs. Script 1 only because the
# tool needs one script; the evidence is the merge-check tests (three new cases) and the parse of the pinned specs.
pinned = c('env-drivers-script2', 'env-drivers-script8', 'i15c-script1-before', 'i15c-script2-before', 'i15c-script3-before',
           'i15c-script5-before', 'i15c-scripts7-before', 'i15c-script8-before', 'i15c-script9-before',
           'i16b-legacy-seed1', 'i16b-merged-legacy-seed1')
parse_pinned = sprintf("for (n in c(%s)) { f = sprintf('docs/cc/verification/2026-10-15_%%s.R', n); s = eval(parse(f)); r = readLines(sub('[.]R$', '_report.md', f)); stopifnot(identical(paste('- commit:', s$commit), grep('^- commit: ', r, value = TRUE)[1])) }; cat('pinned specs match their reports\\n')",
                       paste0("'", pinned, "'", collapse = ', '))
all_pinned = r"(for (f in list.files('docs/cc/verification', '[.]R$', full.names = TRUE)) { v = sub(".*commit *= *'([^']*)'.*", '\\1', grep("commit *= *'", readLines(f), value = TRUE)[1]); r = sub('[.]R$', '_report.md', f); if (is.na(v) || !file.exists(r)) next; tested = sub('^- commit: ', '', grep('^- commit: ', readLines(r), value = TRUE)[1]); if (!startsWith(tested, v)) stop(f, ' names ', v, ' but its report tested ', tested) }; cat('every spec with a report names the commit it tested\n'))"
list(
  name     = 'vc-fixes-2',
  commit   = 'ff31fcb5a468e60467c97ba4d77c8831c5d3e625',
  config   = 'config.R',
  settings = NULL,
  scripts  = 'scripts/1_veg_lct_prep.R',
  checks   = list('tests/test_check_merge_evidence.R', 'tests/test_config.R', 'tests/test_paths.R', c('-e', parse_pinned), c('-e', all_pinned)),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1'))
