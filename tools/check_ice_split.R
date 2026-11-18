# check_ice_split.R: checks of the second split of the partial-ice forcing (Chris, 16 November 2026;
# R/differences.R) in a finished run of scripts 7a to 9 made with difference_method "endpoint", for the
# ice work's verification specs (Astra's review of 17 November 2026, change 3). Run from the repository
# root:
#   Rscript tools/check_ice_split.R <run-dir>
# Stops at the first failure. Each check rebuilds the new columns' values from columns the pipeline had
# before the second split, so a wrong or zeroed new column fails. With f_old and f_young the ice
# fractions of a pair of slices (after script 7a's readvance averaging):
#   - script 7a: the two new parts add up to the partial-ice total; the new vegetation part is the
#     vegetation change times 1 - max(f_old, f_young), that is today's vegetation part (the vegetation
#     change times 1 - f_old) rescaled; where the ice does not advance (f_young <= f_old) the two rules
#     give the same vegetation part, exactly, and so (adding up to the same total) the same ice part;
#   - script 8: for each of the three kernels, the forcings of each split's two parts add up to the
#     forcing of the total;
#   - script 9: in its period summary (the variant table, HadGEM3), each split's two parts add up to the
#     total in every period, domain mean and global equivalent.
args = commandArgs(trailingOnly = TRUE)
if (length(args) != 1) { cat('usage: Rscript tools/check_ice_split.R <run-dir>\n'); quit(status = 2) }
run = args[1]

# Equal within `tolerance`, and missing in the same rows. The tolerances allow only rounding: albedo
# changes are at most 1, forcings at most a few hundred W/m2.
close = function(a, b, tolerance) identical(is.na(a), is.na(b)) && all(abs(a - b) <= tolerance, na.rm = TRUE)

albedo = readRDS(file.path(run, 'data/ALB_diffs_bluesky.RDS'))
f_old = albedo$ice_frac_old; f_young = albedo$ice_frac_young
# Where the older slice is all ice, both vegetation parts are 0.
share_old = ifelse(f_old < 1, 1 - f_old, 1)
not_advancing = which(f_young <= f_old)
stopifnot(close(albedo$alb_diff_veg_part_exposed + albedo$alb_diff_ice_part_exposed, albedo$alb_diff_veg_ice_parts, 1e-12),
          close(albedo$alb_diff_veg_part_exposed, albedo$alb_diff_veg_part / share_old * (1 - pmax(f_old, f_young)), 1e-12),
          identical(albedo$alb_diff_veg_part_exposed[not_advancing], albedo$alb_diff_veg_part[not_advancing]))

forcing = readRDS(file.path(run, 'output/forcing/RF_holocene_all_cases.RDS'))
for (kernel in c('hadgem', 'cam5', 'cack')) {
  rf = function(variant) forcing[[paste0('rf_', kernel, '_', variant)]]
  stopifnot(close(rf('veg_part') + rf('ice_part'), rf('veg_ice_parts'), 1e-9),
            close(rf('veg_part_exposed') + rf('ice_part_exposed'), rf('veg_ice_parts'), 1e-9))
}

periods = read.csv(file.path(run, 'output/forcing/forcing_by_period_variant_sensitivity.csv'))
for (column in c('domain_mean', 'global_equiv')) {
  by_period = function(variant) { rows = periods[periods$variant == variant, ]; setNames(rows[[column]], rows$period) }
  total = by_period('veg_ice_parts')
  stopifnot(length(total) > 0,
            close(by_period('veg_part')[names(total)] + by_period('ice_part')[names(total)], total, 1e-9),
            close(by_period('veg_part_exposed')[names(total)] + by_period('ice_part_exposed')[names(total)], total, 1e-9))
}
cat(sprintf('check_ice_split: all checks passed (%d pairs of slices, %d where the ice advances)\n',
            nrow(albedo), sum(f_young > f_old, na.rm = TRUE)))
