# Refuse a merge that brings code changes without a PASS verification report for that code.
#
# Why: Chris asked how the verification rules would actually be followed (2026-10-14); this
# check makes git enforce one of them (decided 2026-10-15). It runs as git's
# pre-merge-commit hook (a merge that makes a merge commit; the project merges with --no-ff)
# and as its pre-commit hook (a merge finished by `git commit` after a conflict, or a direct
# commit on a trunk). Not covered: a fast-forward merge, `--no-verify`, and a clone where the
# hook was never installed.
#
# The rule applies to merges into a trunk (TRUNKS below): if the merge changes the code (R/, scripts/, tools/, tests/, config.R or
# configs/) of the branch merged into, the merged result must contain a report
# docs/cc/verification/*_report.md, written by tools/verify_change.R with verdict PASS, for a
# commit whose code is the same as the merge result's (later commits may change only
# documentation, such as the report itself). So a branch behind the trunk's code must take
# the trunk in and be verified again. Documentation-only merges need nothing.
#
# During a merge git has not yet written MERGE_HEAD when this hook runs (git 2.43), but the
# merge result is already in the index: the hook checks that tree (git write-tree).
#
# Usage, from the repository root:
#   Rscript tools/check_merge_evidence.R install   install the git hook (once per clone)
#   Rscript tools/check_merge_evidence.R check     what the hook runs during a merge
#   Rscript tools/check_merge_evidence.R check <commit> <base>   check a commit by hand
#                                   (as if merged into <base>, e.g. the trunk before the merge)
# To merge without the check (a deliberate exception, to be recorded in the merge
# message): git merge --no-verify.

CODE_PATHS = c('R', 'scripts', 'tools', 'tests', 'config.R', 'configs')

# The branches the rule protects. Merging one of them into a topic branch (to bring it up to
# date) needs no report: its code was verified when it was merged.
TRUNKS = c('feature/single-config', 'chris-dev', 'main')

git_lines = function(...) {
  out = suppressWarnings(system2('git', shQuote(c(...)), stdout = TRUE, stderr = FALSE))   # quoted: system2 passes text to the shell
  if (!is.null(attr(out, 'status')) && attr(out, 'status') != 0) character() else out
}
same_code = function(a, b) {
  status = suppressWarnings(system2('git', shQuote(c('diff', '--quiet', a, b, '--', CODE_PATHS))))
  status == 0
}

# TRUE if the merge may go ahead; prints why not otherwise. merged and base are commits or
# trees (the merge result; the branch merged into).
check_merge = function(merged, base) {
  if (same_code(base, merged)) { cat('merge check: no code changes; no verification needed\n'); return(TRUE) }
  reports = grep('^docs/cc/verification/.*_report\\.md$',
                 git_lines('ls-tree', '-r', '--name-only', merged, 'docs/cc/verification'), value = TRUE)
  for (r in rev(sort(reports))) {
    text = git_lines('show', paste0(merged, ':', r))
    verdict = sub('^- verdict: \\*\\*(\\w+)\\*\\*$', '\\1', grep('^- verdict: ', text, value = TRUE)[1])
    commit  = sub('^- commit: ', '', grep('^- commit: [0-9a-f]{40}$', text, value = TRUE)[1])
    if (identical(verdict, 'PASS') && !is.na(commit) && same_code(commit, merged)) {
      cat('merge check: PASS report', r, 'covers this code (verified commit', substr(commit, 1, 7), ')\n')
      return(TRUE)
    }
  }
  cat('merge check: REFUSED. This changes the code (', paste(CODE_PATHS, collapse = ', '), ') of a trunk, but no\n',
      'PASS report in docs/cc/verification/ covers it. Make the change on a topic branch, verify it with\n',
      'tools/verify_change.R, commit the report and merge; or, as a recorded exception, use --no-verify.\n', sep = '')
  FALSE
}

install_hook = function() {
  hooks = git_lines('rev-parse', '--git-path', 'hooks')
  rscript = file.path(R.home('bin'), 'Rscript')
  for (file in file.path(hooks, c('pre-merge-commit', 'pre-commit'))) {
    # A branch that predates the check (e.g. the trunk before this tool is merged into it) has
    # no checker in its tree: the hook then lets the merge go ahead and says so.
    writeLines(c('#!/bin/sh', '# Installed by tools/check_merge_evidence.R install: the merge check (see that file).',
                 'if [ ! -f tools/check_merge_evidence.R ]; then echo "merge check: not in this branch yet; skipped"; exit 0; fi',
                 sprintf('exec "%s" tools/check_merge_evidence.R check', rscript)), file)
    Sys.chmod(file, '755')
    cat('installed', file, '\n')
  }
}

if (sys.nframe() == 0L) {
  a = commandArgs(TRUE)
  if (identical(a[1], 'install')) {
    install_hook()
  } else if (identical(a, 'check')) {             # the hook: the staged result against HEAD
    branch = git_lines('symbolic-ref', '--short', 'HEAD')
    if (!(length(branch) && branch %in% TRUNKS)) {
      cat('merge check:', if (length(branch)) branch else 'a detached HEAD', 'is not a trunk; no report needed\n')
      quit(status = 0)
    }
    quit(status = if (check_merge(git_lines('write-tree'), 'HEAD')) 0 else 1)
  } else if (identical(a[1], 'check') && length(a) == 3) {   # by hand: both commits, as after a merge HEAD is the merge itself
    quit(status = if (check_merge(a[2], a[3])) 0 else 1)
  } else {
    cat('usage: Rscript tools/check_merge_evidence.R install | check [<commit> <base>]\n'); quit(status = 2)
  }
}
