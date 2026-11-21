# Trial check: one row of the tool's table worked again by plain code, without fixed_exchange(),
# exchange_contrast() or exchange_spread(): the all-days table, July, the version with location 30
# and straight-line cover, in the northeast, for each of the three exchanges. The standard error is
# checked a different way: the spread of the contrast over 4,000 draws of the coefficients from
# their fitted covariance.
suppressMessages(source('tools/explore_cover_contrasts.R'))
suppressPackageStartupMessages(library(mgcv))
T = '/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/contrast_trial'
run = read_run('/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts')
month = 'jul'; version = 'loc30_linear'
tool = read.csv(file.path(T, 'output', 'contrasts_all_days_jul.csv'))
tool = tool[tool$version == version & tool$region == 'Northeast (hemlock box)', ]
fit = fit_calibration_retry(version, month, run$cal)$fit

cal = run$cal
rows = stats::complete.cases(cal[, c(month, 'x', 'y', 'elev', 'OL', 'ET', 'ST')])
hull = training_hull(cal[rows, ])
northeast = cal$x >= -80 & cal$x < -66 & cal$y >= 40 & cal$y < 48 & rows & is.finite(run$area)
cells = cal[northeast, ]; area = run$area[northeast]
set.seed(1)
draws = mgcv::rmvn(4000, coef(fit), fit$Vp)
for (i in 1:3) {
  from = c('ET', 'ET', 'ST')[i]; to = c('ST', 'OL', 'OL')[i]
  before = after = cells
  before[[from]] = cells[[from]] + 0.05; before[[to]] = cells[[to]] - 0.05     # 5 points more of the class that gives up cover
  after[[from]]  = cells[[from]] - 0.05; after[[to]]  = cells[[to]]  + 0.05     # 5 points more of the class that takes it
  physical = function(d) d$OL >= 0 & d$ET >= 0 & d$ST >= 0 & d$OL <= 1 & d$ET <= 1 & d$ST <= 1
  keep = physical(before) & physical(after)
  keep[keep] = !training_support(before[keep, ], hull)$outside & !training_support(after[keep, ], hull)$outside
  w = area[keep] / sum(area[keep])
  difference = as.numeric(predict(fit, after[keep, ], type = 'response') - predict(fit, before[keep, ], type = 'response'))
  contrast = sum(w * difference)
  X1 = predict(fit, after[keep, ], type = 'lpmatrix'); X0 = predict(fit, before[keep, ], type = 'lpmatrix')
  simulated = apply(draws, 1, function(b) sum(w * (plogis(X1 %*% b) - plogis(X0 %*% b))))
  cat(sprintf('%-25s cells %2d (tool %2d)  contrast %+.6f (tool %+.6f)  spread %.6f (tool %.6f)  se by simulation %.6f (tool %.6f)\n',
              tool$exchange[i], sum(keep), tool$eligible_cells[i], contrast, tool$contrast[i],
              sqrt(sum(w * (difference - contrast)^2)), tool$spread[i], sd(simulated), tool$se[i]))
  stopifnot(sum(keep) == tool$eligible_cells[i], abs(contrast - tool$contrast[i]) < 1e-9,
            abs(sqrt(sum(w * (difference - contrast)^2)) - tool$spread[i]) < 1e-9, abs(sd(simulated) / tool$se[i] - 1) < 0.05)
}
cat('The three northeast rows agree with the plain recomputation; the standard errors agree with simulation within 5 %.\n')
