# Trial check, not a test: with the generalised helpers, are protocol 2's own exchanges (the
# northeast, April and May, frozen on 6 November at commit 1d31cfc) reproduced bit for bit?
suppressMessages(source('tools/check_cv_separation.R'))
run = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts'
frozen = readRDS(file.path(run, 'output/cross_validation_v2/separation/frozen.rds'))
paths = c(redirected_paths(run), list(tag = ALBEDO_TAG))
areas = cell_areas(readRDS(path_file(paths, 'albedo_differences')))
paleo = readRDS(path_file(paths, 'lct_paleo'))
cal = frozen$cal
past_cells = paleo[paleo$ages == 6000 & separation_northeast(paleo), c('x', 'y', 'elev')]
historical = historical_exchange(past_cells, paleo, area_of(past_cells, areas))
for (month in c('apr', 'may')) {
  rows = cal[complete_rows(cal, month), ]
  hull = training_hull(rows)
  modern = rows[separation_northeast(rows), ]
  now = list(fixed = fixed_exchange(modern, area_of(modern, areas)), historical = historical)
  for (name in names(now)) {
    now[[name]]$support = exchange_support(now[[name]], hull)
    then = frozen$months[[month]]$exchanges[[name]]
    cat(sprintf('%s %-10s identical to the frozen exchange: %s  (cells %d, inside the range %d)\n', month, name,
                identical(now[[name]], then), nrow(now[[name]]$first), sum(!now[[name]]$support$outside)))
    stopifnot(identical(now[[name]], then))
  }
}
cat('All four exchanges of protocol 2 are reproduced bit for bit.\n')
