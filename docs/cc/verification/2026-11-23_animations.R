# Animations (branch animations): tools/animate_holocene.R after Chris's fixes of 23 November must run from a
# given finished run folder, with no home-folder paths, and write its 49 PNG frames, frames.csv and caption.txt
# to figures/animations/ in this worktree. Input: the main run of 1 November (d5d5df5, run1-main), the run the
# prototype used, read only. No pipeline script runs. The GIF step (tools/make_holocene_gif.py, Python) is not
# an R check; it is run by hand on this run's frames afterwards and reported beside this report.
list(
  name    = 'animations',
  commit  = '574ba6a',
  config  = 'config.R',
  scripts = character(),
  checks  = list(c('tools/animate_holocene.R',
                   '/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main')),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '2', CORES = '32-47'))
