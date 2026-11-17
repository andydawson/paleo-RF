# Trial check: do the three runs give every cell the same area, and the same cover and elevation?
# (Only the albedo should differ between the three calibration tables.)
suppressMessages(source('R/paths.R')); suppressMessages(source('R/cv_separation.R'))
V = '/home/expert/Documents/contracting/Andria/paleo-RF-verify'
runs = c(all_days = file.path(V, '1d31cfc/.rundirs/cv2-holdouts'), snow_free = file.path(V, '8e3f3a4/.rundirs/run2-snowfree-2'),
         snowy = file.path(V, '74b5482/.rundirs/run7-snowy'))
read = lapply(runs, function(run) {
  paths = c(redirected_paths(run), list(tag = ALBEDO_TAG))
  areas = cell_areas(readRDS(path_file(paths, 'albedo_differences')))
  list(areas = areas[order(areas$x, areas$y), ], cal = readRDS(path_file(paths, 'calibration_table')))
})
same = function(a, b) isTRUE(all.equal(a, b, check.attributes = FALSE, tolerance = 0))   # values, not row names
cover = c('x', 'y', 'elev', 'OL', 'ET', 'ST')
for (name in names(read)[-1]) {
  cat(sprintf('%s against all_days: every cell\'s area the same: %s | cells, cover and elevation the same: %s\n', name,
              same(read[[name]]$areas, read$all_days$areas), same(read[[name]]$cal[, cover], read$all_days$cal[, cover])))
  stopifnot(same(read[[name]]$areas, read$all_days$areas), same(read[[name]]$cal[, cover], read$all_days$cal[, cover]))
}
cat(sprintf('%d cells have an area; %d of the %d calibration cells are among them.\n', nrow(read$all_days$areas),
            sum(paste(read$all_days$cal$x, read$all_days$cal$y) %in% paste(read$all_days$areas$x, read$all_days$areas$y)), nrow(read$all_days$cal)))
