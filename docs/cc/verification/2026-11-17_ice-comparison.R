# The ice work (branch ice-nadi1), 6 of 6: the meeting's tables and figures (tools/compare_ice.R) from the
# four runs of specs 1 and 3 to 5, which must have finished first: the old ice (ice-old-replay, which has
# both splits of the partial-ice forcing) and NADI-1 optimal, minimum and maximum. No pipeline script runs;
# the tool writes into this spec's own run folder only (.rundirs/ice-comparison/meeting). Use the same
# commit as those runs, so that their four run folders are in this worktree. Fill in the commit before running.
runs = file.path('.rundirs', c('ice-old-replay', 'ice-nadi1-optimal', 'ice-nadi1-minimum', 'ice-nadi1-maximum'))
out  = '.rundirs/ice-comparison/meeting'
list(
  name    = 'ice-comparison',
  commit  = 'TO_FILL',   # the commit of specs 1 and 3 to 5
  config  = 'config.R',
  scripts = character(),
  checks  = list(c('tools/compare_ice.R', out, runs),
                 c('tools/check_compare_ice.R', out, runs[1])),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '8', CORES = '40-47'))   # 8 threads, as the regression contract asks of comparison runs; any free 8 cores
