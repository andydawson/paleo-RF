# Tests for tools/check_merge_evidence.R. Run from the repository root:
# Rscript tests/test_check_merge_evidence.R
source('tools/check_merge_evidence.R')

repo = tempfile('merge_fixture_'); dir.create(repo)
old = setwd(repo)
git = function(...) invisible(system2('git', shQuote(c(...)), stdout = FALSE, stderr = FALSE))
commit = function(path, lines, message) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE); writeLines(lines, path)
  git('add', '-A'); git('-c', 'user.name=t', '-c', 'user.email=t@t', 'commit', '-q', '-m', message)
  system2('git', c('rev-parse', 'HEAD'), stdout = TRUE)
}
report = function(sha, verdict) c(sprintf('# Verification x: %s', verdict), '', sprintf('- verdict: **%s**', verdict), sprintf('- commit: %s', sha))
quietly = function(expr) { r = NULL; invisible(capture.output(r <- expr)); r }

git('init', '-q', '-b', 'trunk')
dir.create('tools'); invisible(file.copy(file.path(old, 'tools/check_merge_evidence.R'), 'tools/check_merge_evidence.R'))
base = commit('R/a.R', 'x = 1', 'base')

# Documentation only: no verification needed.
git('checkout', '-q', '-b', 'docs_only')
docs = commit('docs/note.md', 'text', 'docs')
stopifnot(quietly(check_merge(docs, base)))

# Code without a report: refused.
git('checkout', '-q', '-b', 'code', base)
code = commit('R/a.R', 'x = 2', 'code change')
stopifnot(!quietly(check_merge(code, base)))

# A FAIL report: refused.
failed = commit('docs/cc/verification/2026-10-15_x_report.md', report(code, 'FAIL'), 'fail report')
stopifnot(!quietly(check_merge(failed, base)))

# A PASS report for this code, committed after it: accepted.
passed = commit('docs/cc/verification/2026-10-15_x_report.md', report(code, 'PASS'), 'pass report')
stopifnot(quietly(check_merge(passed, base)))

# What the hook sees during a merge is a tree (the index), not a commit: the same answer.
tree = system2('git', c('rev-parse', paste0(passed, '^{tree}')), stdout = TRUE)
stopifnot(quietly(check_merge(tree, base)))

# Code changed again after the PASS report: refused until verified again.
changed = commit('scripts/s.R', 'y = 1', 'more code')
stopifnot(!quietly(check_merge(changed, base)))

# End to end, through git: the installed hook refuses the unverified merge and lets the
# verified one through (git runs the hook before it writes MERGE_HEAD).
invisible(quietly(install_hook()))
merge = function(branch) {
  status = system2('git', shQuote(c('-c', 'user.name=t', '-c', 'user.email=t@t', 'merge', '--no-ff', '-q', '-m', 'm', branch)),
                   stdout = FALSE, stderr = FALSE)
  if (status != 0) git('merge', '--abort')
  status == 0
}
git('checkout', '-q', '-b', 'feature/single-config', base)   # a trunk the rule protects
git('branch', 'verified', passed); git('branch', 'unverified', changed)
stopifnot(!merge('unverified'), merge('verified'))
# ... while bringing a trunk into a topic branch needs no report.
git('checkout', '-q', '-b', 'topic', base)
stopifnot(merge('unverified'))

# The same hook runs before a commit (pre-commit), which covers a merge finished by `git commit`
# after a conflict and a direct commit on a trunk: code is refused there, documentation is not,
# and a topic branch is unaffected.
try_commit = function(path, lines) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE); writeLines(lines, path); git('add', path)
  status = system2('git', shQuote(c('-c', 'user.name=t', '-c', 'user.email=t@t', 'commit', '-q', '-m', 'c')),
                   stdout = FALSE, stderr = FALSE)
  if (status != 0) git('reset', '-q', '--hard')
  status == 0
}
git('checkout', '-q', 'feature/single-config')
stopifnot(!try_commit('R/a.R', 'x = 3'), try_commit('docs/more.md', 'text'))
git('checkout', '-q', 'topic')
stopifnot(try_commit('R/a.R', 'x = 4'))

# A check by hand needs both commits: with one, the base would be HEAD, which after a merge is
# the merge itself, and the check would compare the merge with itself.
status = system2(file.path(R.home('bin'), 'Rscript'), c('tools/check_merge_evidence.R', 'check', 'HEAD'),
                 stdout = FALSE, stderr = FALSE)
stopifnot(status == 2)

setwd(old)
cat('test_check_merge_evidence: all tests passed\n')
