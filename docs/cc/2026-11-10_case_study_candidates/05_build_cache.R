# Build the arrays every later script reads, from the three finished runs (read-only).
#
# Why a cache: the candidate boxes are tried many times; reading 36 monthly prediction files
# and three 140 MB forcing tables each time would make that slow. Nothing here is a result:
# it is the runs' own numbers rearranged by cell, slice, month and run.
#
# WHAT EACH COLUMN OF THE RUN FILES WAS TAKEN TO MEAN (checked against scripts 6, 7a and 8):
#   data/lct_paleo_reveals_interp.RDS    ages = slice (years BP); x, y = cell centre (degrees);
#       OL, ET, ST = the reconstruction's cover fractions (mean of the posterior draws).
#   output/prediction/paleo_interp_predict_gam_<month>_bluesky.RDS   year = slice (years BP);
#       alb_mean = the model's FITTED albedo for that cell, slice and month (predict.gam,
#       type "response"; no simulation). Used here for the albedo change.
#   data/ALB_diffs_bluesky.RDS    one row per cell, month and pair of consecutive slices;
#       year = the YOUNGER slice of the pair; ice_frac_young / ice_frac_old = ice fraction of
#       the cell at the two ends (after script 7a's readvance adjustment);
#       alb_diff_veg_part = (younger minus older albedo) x (1 - ice fraction at the older
#       end), where the albedo is the MEAN OF 100 SIMULATED DRAWS (script 6's summary), not
#       the fitted value. This is what the forcing is made from.
#   output/forcing/RF_holocene_all_cases.RDS   the same rows inside 27-74 N with the kernels
#       (rk_<kernel>) and rf_<kernel>_<variant> = albedo change x kernel, W/m2 for that cell
#       and month, positive = warming. veg_part = vegetation part, ice_part = ice part,
#       veg_ice_parts = their sum.
source('./case_study_helpers.R')

run_file = function(run, ...) file.path(RUNS[[run]], ...)

# The study area is the cells of the forcing table (27 to 74 N, east of 170 W).
forcing_tables = lapply(names(RUNS), function(run) readRDS(run_file(run, 'output/forcing/RF_holocene_all_cases.RDS')))
names(forcing_tables) = names(RUNS)
first = forcing_tables[[1]]
cells = unique(first[, c('x', 'y')])
cells$area = as.numeric(first$area[match(cell_key(cells$x, cells$y), cell_key(first$x, first$y))])
cells = cells[order(cells$y, cells$x), ]
cells$id = cell_key(cells$x, cells$y)
rownames(cells) = NULL

cover_table = readRDS(run_file('mod8', 'data/lct_paleo_reveals_interp.RDS'))
for (run in names(RUNS)[-1]) stopifnot(identical(cover_table, readRDS(run_file(run, 'data/lct_paleo_reveals_interp.RDS'))))
ages  = sort(unique(cover_table$ages))
pairs = head(ages, -1)                                  # each pair is named by its younger slice

# One array from a table: values placed by cell, slice (or pair) and month.
place = function(x, y, age, month, value, ages_of) {
  a = array(NA_real_, c(nrow(cells), length(ages_of), length(MONTHS)), list(cells$id, ages_of, MONTHS))
  i = cbind(match(cell_key(x, y), cells$id), match(age, ages_of), match(as.character(month), MONTHS))
  keep = !is.na(i[, 1])
  a[i[keep, , drop = FALSE]] = value[keep]
  a
}

cover = array(NA_real_, c(nrow(cells), length(ages), 3), list(cells$id, ages, CLASSES))
i_cell = match(cell_key(cover_table$x, cover_table$y), cells$id)
keep = !is.na(i_cell)
for (class in CLASSES) cover[cbind(i_cell[keep], match(cover_table$ages[keep], ages), match(class, CLASSES))] = cover_table[[class]][keep]
stopifnot(!anyNA(cover), max(abs(apply(cover, 1:2, sum) - 1)) < 1e-9)

fitted_albedo = lapply(names(RUNS), function(run) {
  a = array(NA_real_, c(nrow(cells), length(ages), length(MONTHS)), list(cells$id, ages, MONTHS))
  for (month in MONTHS) {
    p = readRDS(run_file(run, 'output/prediction', sprintf('paleo_interp_predict_gam_%s_bluesky.RDS', month)))
    i = cbind(match(cell_key(p$x, p$y), cells$id), match(p$year, ages))
    k = !is.na(i[, 1])
    a[cbind(i[k, , drop = FALSE], match(month, MONTHS))] = p$alb_mean[k]
  }
  stopifnot(!anyNA(a))
  a
})
names(fitted_albedo) = names(RUNS)

# The ice fraction of each cell and slice, from the pairs' two ends (the same in every run).
ice = array(NA_real_, c(nrow(cells), length(ages)), list(cells$id, ages))
may = first[first$month == 'may', ]
ice[cbind(match(cell_key(may$x, may$y), cells$id), match(may$year, ages))] = may$ice_frac_young
oldest = may[may$year == max(pairs), ]
ice[cbind(match(cell_key(oldest$x, oldest$y), cells$id), length(ages))] = oldest$ice_frac_old

simulated_change = lapply(forcing_tables, function(f) place(f$x, f$y, f$year, f$month, f$alb_diff_veg_part, pairs))
forcing = lapply(forcing_tables, function(f) {
  parts = list()
  for (kernel in KERNELS) for (variant in c('veg_part', 'ice_part'))
    parts[[paste(kernel, variant, sep = '_')]] = place(f$x, f$y, f$year, f$month, f[[paste('rf', kernel, variant, sep = '_')]], pairs)
  parts
})
kernels = lapply(KERNELS, function(kernel) {
  k = place(first$x, first$y, first$year, first$month, first[[paste0('rk_', kernel)]], pairs)[, 1, ]
  # W/m2 per unit albedo, positive: HadGEM3 and CAM5 are stored negative per 1 % albedo.
  if (kernel == 'cack') k else -100 * k
})
names(kernels) = KERNELS

modern = readRDS(run_file('mod8', 'data/calibration_modern_lct_interp_bluesky.RDS'))
pollen = readRDS(file.path(WORKTREE, 'data/lct_paleo_reveals.RDS'))

saveRDS(list(cells = cells, ages = ages, pairs = pairs, cover = cover, ice = ice,
             fitted_albedo = fitted_albedo, simulated_change = simulated_change,
             forcing = forcing, kernels = kernels, modern = modern, pollen = pollen),
        file.path(CACHE, 'arrays.RDS'), compress = FALSE)
cat('cells:', nrow(cells), ' slices:', length(ages), ' total area (m2):', sum(cells$area), '\n')
cat('ice: cells with any ice by slice:\n'); print(colSums(ice > 0, na.rm = TRUE)); cat('NA ice:', sum(is.na(ice)), '\n')
cat('simulated change NA share:', mean(is.na(simulated_change$mod8)), '\n')
