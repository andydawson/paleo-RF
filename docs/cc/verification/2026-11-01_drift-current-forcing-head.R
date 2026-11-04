# Drift fixes: scripts 9 and 10 under the current configuration on the 18 October run's forcing table and coarse
# differences, at the head commit (drift-fixes); the two runs' tables are compared byte for byte afterwards (labels only differ).
run18 = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/4ba4d2a/.rundirs/full-current-2026-10-18'
list(
  name    = 'drift-current-forcing-head',
  commit  = 'ac90729527f5965184c6e7abcaefab80129b86e5',
  config  = 'config.R',
  copy    = list(c(file.path(run18, 'output/forcing/RF_holocene_all_cases.RDS'), 'output/forcing/RF_holocene_all_cases.RDS'),
                 c(file.path(run18, 'data/alb_interp_preds_diffs_bluesky.RDS'), 'data/alb_interp_preds_diffs_bluesky.RDS')),
  scripts = c('scripts/9_forcing_barplot.R', 'scripts/10_forcing_breakdown.R'),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '8', CORES = '16-23'))
