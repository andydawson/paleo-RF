# Inspect the structure of the run products before using them (read-only).
runs = c(mod8 = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/f05628d/.rundirs/cv-mod8',
         loc100_linear = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-winner',
         mod8_coarse_loc = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/e82f399/.rundirs/cv-chosen')
r = runs[1]
show = function(path) { cat('\n==== ', path, '\n'); x = readRDS(path); cat('class:', class(x), '\n'); str(x, max.level = 2, list.len = 60, vec.len = 4); invisible(x) }
paleo = show(file.path(r, 'data/lct_paleo_reveals_interp.RDS'))
cat('ages: '); print(sort(unique(paleo$ages)))
cat('rows per age:\n'); print(table(paleo$ages))
print(summary(paleo[, intersect(c('x','y','OL','ET','ST','elev'), names(paleo))]))
modern = show(file.path(r, 'data/lct_modern_reveals_interp.RDS'))
cal = show(file.path(r, 'data/calibration_modern_lct_interp_bluesky.RDS'))
print(summary(as.data.frame(cal)))
ice = show(file.path(r, 'data/ice_fort.RDS'))
print(head(as.data.frame(ice), 10))
pm = show(file.path(r, 'output/prediction/paleo_interp_predict_gam_may_bluesky.RDS'))
print(head(as.data.frame(pm), 5))
ps = show(file.path(r, 'output/prediction/paleo_interp_predict_gam_summary_may_bluesky.RDS'))
print(head(as.data.frame(ps), 5))
