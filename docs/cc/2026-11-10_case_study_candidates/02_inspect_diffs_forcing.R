# Inspect the albedo-difference and forcing tables of one run (read-only).
r = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/f05628d/.rundirs/cv-mod8'
d = readRDS(file.path(r, 'data/ALB_diffs_bluesky.RDS'))
cat('ALB_diffs class:', class(d), ' dim:', dim(d), '\n'); str(d, vec.len = 3)
cat('years (younger slice of each pair):'); print(sort(unique(d$year)))
cat('months:'); print(table(d$month))
cat('lat range:', range(d$lat), ' long range:', range(d$long), '\n')
cat('x - long, y - lat summaries:\n'); print(summary(d$x - d$long)); print(summary(d$y - d$lat))
cat('cells:', length(unique(d$cell_id)), '\n')
cat('NA counts:\n'); print(colSums(is.na(d)))
print(head(d[d$month == 'may' & d$cell_id == d$cell_id[1], ], 26))
f = readRDS(file.path(r, 'output/forcing/RF_holocene_all_cases.RDS'))
cat('\nRF class:', class(f), ' dim:', dim(f), '\n'); print(names(f))
cat('lat range:', range(f$lat), ' long range:', range(f$long), '\n')
cat('cells:', length(unique(f$cell_id)), '\n')
cat('area class:', class(f$area), '\n'); print(summary(as.numeric(f$area)))
print(head(f[f$month == 'may', c('cell_id','lat','long','year','month','area','ice_frac_young','ice_frac_old','alb_diff_veg_part','alb_diff_ice_part','alb_diff_veg_ice_parts','rk_hadgem','rk_cam5','rk_cack','rf_hadgem_veg_part','rf_cam5_veg_part','rf_cack_veg_part')], 5))
for (n in c('forcing_by_period.csv','forcing_by_period_variant_sensitivity.csv')) { cat('\n====', n, '\n'); print(read.csv(file.path(r, 'output/forcing', n))) }
ml = read.csv(file.path(r, 'output/forcing/forcing_by_month_latitude.csv')); cat('\n==== forcing_by_month_latitude.csv\n'); str(ml); print(head(ml, 12))
for (n in names(ml)) if (is.character(ml[[n]]) || is.factor(ml[[n]])) { cat(n, ':'); print(unique(ml[[n]])) }
