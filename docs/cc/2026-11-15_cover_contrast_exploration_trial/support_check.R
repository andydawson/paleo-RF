# Trial check, no fits: the eligible cells of every table, month, region and exchange, and a
# comparison of the northeast's counts with those Astra computed independently (in Python, from
# the same three saved calibration tables) in its check of the design on 10 November, point 4.
suppressMessages(source('tools/explore_cover_contrasts.R'))
T = '/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/contrast_trial'
V = '/home/expert/Documents/contracting/Andria/paleo-RF-verify'
runs = c(all_days = file.path(V, '1d31cfc/.rundirs/cv2-holdouts'),
         snow_free = file.path(V, '8e3f3a4/.rundirs/run2-snowfree-2'),
         snowy = file.path(V, '74b5482/.rundirs/run7-snowy'))
support = NULL
for (name in names(runs)) {
  started = Sys.time()
  run = read_run(runs[[name]])
  stopifnot(run$table == name)
  cat(sprintf('%s: calibration table matches the repository cell table; %d cells, %d without an area\n',
              name, nrow(run$cal), sum(!is.finite(run$area))))
  for (month in MONTHS)
    support = rbind(support, cbind(table = name, month = month,
                                   do.call(rbind, lapply(exchange_cases(run, month), function(case) case$support))))
  cat(sprintf('  twelve months of cases in %.1f s\n', as.numeric(difftime(Sys.time(), started, units = 'secs'))))
}
write.csv(support, file.path(T, 'support_all_tables_months.csv'), row.names = FALSE)

ne = support[support$region == 'Northeast (hemlock box)', ]
counts = function(table, months) sapply(EXCHANGES$exchange, function(e)
  paste(unique(range(ne$eligible_cells[ne$table == table & ne$month %in% months & ne$exchange == e])), collapse = '-'))
astra = list(
  list('all_days', MONTHS, c('58', '41', '22')),
  list('snow_free', MONTHS, c('45-58', '32-41', '17-22')),
  list('snowy', c('dec', 'jan', 'feb', 'mar'), c('58', '41', '22')),
  list('snowy', 'apr', c('42', '25', '13')), list('snowy', 'may', c('3', '1', '1')),
  list('snowy', 'oct', c('2', '0', '0')), list('snowy', 'nov', c('25', '16', '6')),
  list('snowy', c('jun', 'sep'), c('0', '0', '0')))
cat('\nNortheast, eligible cells (evergreen to summergreen / evergreen to open land / summergreen to open land):\n')
for (a in astra) {
  mine = unname(counts(a[[1]], a[[2]]))
  cat(sprintf('  %-9s %-16s tool %-22s Astra %-22s %s\n', a[[1]], if (length(a[[2]]) == 12) 'all months' else paste(a[[2]], collapse = ' '),
              paste(mine, collapse = ' / '), paste(a[[3]], collapse = ' / '), if (identical(mine, a[[3]])) 'same' else 'DIFFERENT'))
  stopifnot(identical(mine, a[[3]]))
}
shares = ne[ne$table == 'all_days' & ne$month == 'jul', c('exchange', 'region_cells', 'fitted_cells', 'eligible_cells', 'area_share', 'cells_10pct')]
print(shares, row.names = FALSE)
stopifnot(all(shares$region_cells == 83), all(round(100 * shares$area_share, 1) == c(69.6, 49.9, 26.7)))
cat('Astra\'s area shares for all days (69.6, 49.9 and 26.7 % of the northeast) are reproduced.\n')
cat('\nStudy area, all days, July:\n')
print(support[support$table == 'all_days' & support$month == 'jul' & support$region == 'Study area', -(1:3)], row.names = FALSE)
