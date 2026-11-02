# Run 1 (main), model 7 convergence check (Chris, 29 October, decision 3): refit model 7 at 2,000 steps in the
# months where it stopped at its 500-step limit (January, February, March, April, June, October) and in July,
# where it converged in 86 steps, as the control. Scripts 1 and 2 rebuild run 1's calibration table (same
# configuration and seed); run 1's saved model 7 fits are copied in; the tool stops unless each refit has the
# saved fit's formula, family and model frame. Diagnostic only: nothing in the pipeline changes.
run1 = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main'
months = c('jan', 'feb', 'mar', 'apr', 'jun', 'oct', 'jul')
fit = function(m) file.path('output/calibration', sprintf('calibration_mod7_interp_%s_bluesky.RDS', m))
list(
  name     = 'run1-model7-check',
  commit   = 'f44881b',
  config   = 'config.R',
  settings = list(analysis = list(draws = list(seed = 1549466984))),
  copy     = lapply(months, function(m) c(file.path(run1, fit(m)), fit(m))),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R'),
  checks   = list(c('tools/check_model7_convergence.R', '.rundirs/run1-model7-check', months)),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '8', CORES = '32-39'))
