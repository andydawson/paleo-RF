# The numbers behind each candidate case study: one box and one pair of slices each
# (candidates.csv), all computed the same way, so that the candidates can be compared with
# each other and with the hemlock decline.
#
# For each candidate: the cells and their ice; where the cover comes from pollen; the cover
# change with the reconstruction's own uncertainty (posterior draws); whether the mixes are
# inside the range of modern mixes; what published class albedos would lead one to expect;
# what the three runs give by month; and the vegetation forcing.
#
# Writes candidate_regions.csv (one row per candidate), candidate_monthly.csv (albedo change
# and forcing by month and run) and candidate_expectation.csv, and prints a report per candidate.
source('./case_study_helpers.R')
suppressPackageStartupMessages(source(file.path(WORKTREE, 'R/training_support.R')))   # the project's rule for the range of modern mixes
a = read_cache(); cells = a$cells; ages = a$ages
posterior = readRDS(file.path(CACHE, 'posterior.RDS'))
candidates = read.csv(file.path(OUT_DIR, 'candidates.csv'), stringsAsFactors = FALSE)
EARTH_AREA = 5.101e14          # m2, config.R analysis$forcing$earth_area_m2

# ---- Published class albedos, for a rough expectation by straight mixing ----------------
# Each row: a place and season with the albedo of open land, evergreen and summergreen cover
# there. Sources and locators are in the report; the temperate and extratropical rows are in
# the project's published_albedo_contrasts.csv, the Betts and Ball row was read for this search.
PUBLISHED = read.csv(text = '
set,state,source,OL,ET,ST
temperate,snow-free summer (Jun-Aug),"Hollinger 2010, Table 2: grassland, northerly evergreen needleleaf, deciduous broadleaf",0.181,0.079,0.152
temperate,snow-free spring (Apr-May),"Hollinger 2010, Table 2: grassland, northerly evergreen needleleaf, deciduous broadleaf",0.209,0.084,0.145
temperate,snow-covered winter (Dec-Mar),"Burakowski 2016, Fig. 5a: cropland and grassland, evergreen needleleaf, deciduous broadleaf (New England)",0.55,0.27,0.30
temperate,snow-free dormant season (Dec-Mar),"Burakowski 2016, Fig. 5b: the same classes without snow",0.15,0.08,0.12
temperate,snow-covered winter (Dec-Feb),"Boisier 2013, Table 2: grasses, evergreen trees, deciduous trees (northern extratropics)",0.568,0.205,0.244
boreal,snow-free summer,"Betts and Ball 1997, abstract: grass, conifer, aspen (BOREAS, central Canada)",0.20,0.083,0.15
boreal,snow-covered winter,"Betts and Ball 1997, abstract: grass, conifer, aspen with snow under the canopy",0.75,0.13,0.21
boreal,snow-free (after melt),"Euskirchen 2016, Table 1: graminoid tundra, boreal evergreen forest, boreal deciduous forest",0.24,0.09,0.15
boreal,snow-covered (six weeks before melt),"Euskirchen 2016, Table 1: graminoid tundra, boreal evergreen forest, boreal deciduous forest",0.68,0.40,0.55
boreal,snow-free (after melt); shrubs for summergreen,"Euskirchen 2016, Table 1: graminoid tundra, boreal evergreen forest, shrub tundra",0.24,0.09,0.24
boreal,snow-covered (before melt); shrubs for summergreen,"Euskirchen 2016, Table 1: graminoid tundra, boreal evergreen forest, shrub tundra",0.68,0.40,0.54
', stringsAsFactors = FALSE, strip.white = TRUE)

# ---- The range of modern mixes: the hull of the cells each month's model was fitted on ---
modern = a$modern
hull_of = function(month) training_hull(modern[!is.na(modern[[month]]), CLASSES])
hulls = lapply(setNames(MONTHS, MONTHS), hull_of)
outside_share = function(cover_matrix, weight, month) {
  support = training_support(as.data.frame(cover_matrix), hulls[[month]])
  c(share = sum(weight[support$outside]) / sum(weight), farthest = max(support$distance_outside))
}

# ---- Cells with a pollen-based estimate before interpolation ----------------------------
# The pollen table has coarser slices (50, 500, 2000, 4000 ... BP); the nearest one is used.
pollen = a$pollen
pollen_cells = function(inside, age) {
  nearest = sort(unique(pollen$ages))[which.min(abs(sort(unique(pollen$ages)) - age))]
  here = pollen[pollen$ages == nearest, ]
  c(slice = nearest, cells = sum(cell_key(here$long, here$lat) %in% cells$id[inside]))
}

one_candidate = function(candidate) {
  inside = in_box(cells, candidate)
  i_old = slice_index(ages, candidate$old); i_young = slice_index(ages, candidate$young)
  area = cells$area[inside]
  ice_old = a$ice[inside, i_old]; ice_young = a$ice[inside, i_young]
  # A cell counts by its area times its ice-free share at the icier end.
  weight = area * (1 - pmax(ice_old, ice_young))

  cover_old   = sapply(CLASSES, function(class) weighted_mean(a$cover[inside, i_old, class], weight))
  cover_young = sapply(CLASSES, function(class) weighted_mean(a$cover[inside, i_young, class], weight))
  change = cover_young - cover_old

  # The reconstruction's uncertainty of the box-mean change. A draw is a draw of the whole map
  # of one slice and the slices are independent (05b_build_posterior_cache.R), so the change of
  # draw i is taken between draw i of each slice.
  draw_mean = function(i_slice) apply(posterior[inside, i_slice, , , drop = FALSE], 3:4, function(v) weighted_mean(v, weight))
  draw_change = draw_mean(i_young) - draw_mean(i_old)                    # classes x draws
  change_sd = apply(draw_change, 1, sd)
  change_lo = apply(draw_change, 1, quantile, 0.025); change_hi = apply(draw_change, 1, quantile, 0.975)

  # How much the box mean moves between consecutive slices outside the window: a second,
  # cruder measure of what is not signal.
  series = sapply(CLASSES, function(class) sapply(seq_along(ages), function(i) weighted_mean(a$cover[inside, i, class], area * (1 - a$ice[inside, i]))))
  steps = diff(series[rev(seq_along(ages)), ])                             # older to younger
  step_young = rev(ages)[-1]
  outside_window = step_young < candidate$young | step_young >= candidate$old
  step_sd = apply(steps[outside_window & rev(colMeans(a$ice[inside, , drop = FALSE]))[-1] < 0.05, , drop = FALSE], 2, sd)

  support = sapply(c('may', 'jan'), function(month) c(old = outside_share(a$cover[inside, i_old, ], weight, month),
                                                    young = outside_share(a$cover[inside, i_young, ], weight, month)))

  # Modern observed albedo of the box by month (the calibration table), and the share of the
  # box's cells that have an observation that month: where there is none the month's model was
  # fitted without any cell there (no sunlight in the MODIS record), and it is extrapolating.
  observed = modern[match(cells$id[inside], cell_key(modern$x, modern$y)), MONTHS]
  observed_mean = sapply(MONTHS, function(month) weighted_mean(observed[[month]], area))
  observed_share = sapply(MONTHS, function(month) mean(!is.na(observed[[month]])))

  monthly = do.call(rbind, lapply(names(RUNS), function(run) {
    fitted = a$fitted_albedo[[run]][inside, , , drop = FALSE]
    pairs_in = which(a$pairs >= candidate$young & a$pairs < candidate$old)
    data.frame(key = candidate$key, run = run, month = MONTHS,
               albedo_change = sapply(MONTHS, function(month) weighted_mean(fitted[, i_young, month] - fitted[, i_old, month], weight)),
               albedo_change_simulated = sapply(MONTHS, function(month) weighted_mean(rowSums(a$simulated_change[[run]][inside, pairs_in, month, drop = FALSE]), area)),
               forcing_hadgem = sapply(MONTHS, function(month) weighted_mean(rowSums(a$forcing[[run]]$hadgem_veg_part[inside, pairs_in, month, drop = FALSE]), area)),
               forcing_cack   = sapply(MONTHS, function(month) weighted_mean(rowSums(a$forcing[[run]]$cack_veg_part[inside, pairs_in, month, drop = FALSE]), area)),
               ice_forcing_hadgem = sapply(MONTHS, function(month) weighted_mean(rowSums(a$forcing[[run]]$hadgem_ice_part[inside, pairs_in, month, drop = FALSE]), area)),
               kernel_hadgem = sapply(MONTHS, function(month) weighted_mean(a$kernels$hadgem[inside, month], area)),
               observed_albedo_today = observed_mean, cells_observed_share = observed_share, row.names = NULL)
  }))
  by_run = function(column, fun = mean) sapply(names(RUNS), function(run) fun(monthly[monthly$run == run, column], na.rm = TRUE))
  albedo_annual = by_run('albedo_change')                    # mean of the twelve months
  forcing_annual = by_run('forcing_hadgem'); forcing_annual_cack = by_run('forcing_cack')
  season = function(months) sapply(names(RUNS), function(run) mean(monthly$albedo_change[monthly$run == run & monthly$month %in% months]))

  expectation = PUBLISHED[PUBLISHED$set == candidate$albedo_set, ]
  expectation$key = candidate$key
  expectation$expected_change = as.vector(as.matrix(expectation[, CLASSES]) %*% change[CLASSES])

  pollen_old = pollen_cells(inside, candidate$old); pollen_young = pollen_cells(inside, candidate$young)
  row = data.frame(
    candidate = candidate$key, name = candidate$name, found_from = candidate$found_from,
    lon_min = candidate$lon_min, lon_max = candidate$lon_max, lat_min = candidate$lat_min, lat_max = candidate$lat_max,
    older_slice_bp = candidate$old, younger_slice_bp = candidate$young,
    cells = sum(inside), box_area_m2 = sum(area),
    cells_with_ice_at_either_end = sum(pmax(ice_old, ice_young) > 0), mean_ice_fraction_older = weighted_mean(ice_old, area), mean_ice_fraction_younger = weighted_mean(ice_young, area),
    pollen_cells_near_older = pollen_old[['cells']], pollen_slice_near_older = pollen_old[['slice']],
    pollen_cells_near_younger = pollen_young[['cells']], pollen_slice_near_younger = pollen_young[['slice']],
    OL_older = cover_old[['OL']], ET_older = cover_old[['ET']], ST_older = cover_old[['ST']],
    OL_younger = cover_young[['OL']], ET_younger = cover_young[['ET']], ST_younger = cover_young[['ST']],
    OL_change = change[['OL']], ET_change = change[['ET']], ST_change = change[['ST']],
    OL_change_sd = change_sd[['OL']], ET_change_sd = change_sd[['ET']], ST_change_sd = change_sd[['ST']],
    OL_change_lo95 = change_lo[['OL']], OL_change_hi95 = change_hi[['OL']], ET_change_lo95 = change_lo[['ET']], ET_change_hi95 = change_hi[['ET']],
    ST_change_lo95 = change_lo[['ST']], ST_change_hi95 = change_hi[['ST']],
    OL_step_sd = step_sd[['OL']], ET_step_sd = step_sd[['ET']], ST_step_sd = step_sd[['ST']],
    exchange = exchange_label(change[['OL']], change[['ET']], change[['ST']]), exchange_purity = exchange_purity(change[['OL']], change[['ET']], change[['ST']]),
    outside_modern_mixes_older = support['old.share', 'may'], outside_modern_mixes_younger = support['young.share', 'may'],
    farthest_outside_older = support['old.farthest', 'may'], farthest_outside_younger = support['young.farthest', 'may'],
    outside_january_mixes_older = support['old.share', 'jan'], outside_january_mixes_younger = support['young.share', 'jan'],
    expected_sign = candidate$expected_sign,
    albedo_change_annual_mod8 = albedo_annual[['mod8']], albedo_change_annual_loc100_linear = albedo_annual[['loc100_linear']], albedo_change_annual_mod8_coarse_loc = albedo_annual[['mod8_coarse_loc']],
    albedo_change_jja_mod8 = season(c('jun', 'jul', 'aug'))[['mod8']], albedo_change_jja_loc100_linear = season(c('jun', 'jul', 'aug'))[['loc100_linear']], albedo_change_jja_mod8_coarse_loc = season(c('jun', 'jul', 'aug'))[['mod8_coarse_loc']],
    albedo_change_mar_apr_mod8 = season(c('mar', 'apr'))[['mod8']], albedo_change_mar_apr_loc100_linear = season(c('mar', 'apr'))[['loc100_linear']], albedo_change_mar_apr_mod8_coarse_loc = season(c('mar', 'apr'))[['mod8_coarse_loc']],
    forcing_hadgem_mod8 = forcing_annual[['mod8']], forcing_hadgem_loc100_linear = forcing_annual[['loc100_linear']], forcing_hadgem_mod8_coarse_loc = forcing_annual[['mod8_coarse_loc']],
    forcing_cack_mod8 = forcing_annual_cack[['mod8']], forcing_cack_loc100_linear = forcing_annual_cack[['loc100_linear']], forcing_cack_mod8_coarse_loc = forcing_annual_cack[['mod8_coarse_loc']],
    global_equivalent_mwm2_mod8 = 1000 * forcing_annual[['mod8']] * sum(area) / EARTH_AREA,
    global_equivalent_mwm2_loc100_linear = 1000 * forcing_annual[['loc100_linear']] * sum(area) / EARTH_AREA,
    global_equivalent_mwm2_mod8_coarse_loc = 1000 * forcing_annual[['mod8_coarse_loc']] * sum(area) / EARTH_AREA,
    ice_forcing_hadgem = by_run('ice_forcing_hadgem')[['mod8']],
    largest_fitted_minus_simulated = max(abs(monthly$albedo_change - monthly$albedo_change_simulated)),
    stringsAsFactors = FALSE, row.names = NULL)
  list(row = row, monthly = monthly, expectation = expectation)
}

results = lapply(seq_len(nrow(candidates)), function(i) one_candidate(candidates[i, ]))
table = do.call(rbind, lapply(results, `[[`, 'row'))
monthly = do.call(rbind, lapply(results, `[[`, 'monthly'))
expectation = do.call(rbind, lapply(results, `[[`, 'expectation'))
write.csv(table, file.path(OUT_DIR, 'candidate_regions.csv'), row.names = FALSE)
write.csv(monthly, file.path(OUT_DIR, 'candidate_monthly.csv'), row.names = FALSE)
write.csv(expectation[, c('key', 'set', 'state', 'source', 'OL', 'ET', 'ST', 'expected_change')], file.path(OUT_DIR, 'candidate_expectation.csv'), row.names = FALSE)

# ---- Printed report ---------------------------------------------------------------------
for (r in results) {
  t = r$row; m = r$monthly
  cat(sprintf('\n================ %s [%s]\n', t$name, t$candidate))
  cat(sprintf('box %g..%g E, %g..%g N; %d BP -> %d BP; %d cells (%.2e m2); ice at either end in %d cells (mean ice fraction %.2f -> %.2f)\n',
              t$lon_min, t$lon_max, t$lat_min, t$lat_max, t$older_slice_bp, t$younger_slice_bp, t$cells, t$box_area_m2, t$cells_with_ice_at_either_end, t$mean_ice_fraction_older, t$mean_ice_fraction_younger))
  cat(sprintf('cells with a pollen-based estimate: %d near the older end (%d BP table), %d near the younger end (%d BP table)\n',
              t$pollen_cells_near_older, t$pollen_slice_near_older, t$pollen_cells_near_younger, t$pollen_slice_near_younger))
  cat(sprintf('cover   open land %.3f -> %.3f   evergreen %.3f -> %.3f   summergreen %.3f -> %.3f\n', t$OL_older, t$OL_younger, t$ET_older, t$ET_younger, t$ST_older, t$ST_younger))
  cat(sprintf('change  open land %+.3f (sd %.3f; 95%% %+.3f to %+.3f)   evergreen %+.3f (sd %.3f; %+.3f to %+.3f)   summergreen %+.3f (sd %.3f; %+.3f to %+.3f)\n',
              t$OL_change, t$OL_change_sd, t$OL_change_lo95, t$OL_change_hi95, t$ET_change, t$ET_change_sd, t$ET_change_lo95, t$ET_change_hi95, t$ST_change, t$ST_change_sd, t$ST_change_lo95, t$ST_change_hi95))
  cat(sprintf('        %s, purity %.2f; step-to-step sd outside the window: open land %.3f evergreen %.3f summergreen %.3f\n', t$exchange, t$exchange_purity, t$OL_step_sd, t$ET_step_sd, t$ST_step_sd))
  cat(sprintf('outside the range of modern mixes (share of area): older end %.2f (farthest %.3f), younger end %.2f (farthest %.3f); by the January range: %.2f and %.2f\n',
              t$outside_modern_mixes_older, t$farthest_outside_older, t$outside_modern_mixes_younger, t$farthest_outside_younger, t$outside_january_mixes_older, t$outside_january_mixes_younger))
  cat('expected albedo change by straight mixing of published class albedos:\n')
  for (i in seq_len(nrow(r$expectation))) cat(sprintf('   %+.4f  %s  [%s]\n', r$expectation$expected_change[i], r$expectation$state[i], r$expectation$source[i]))
  cat('month:                 ', sprintf('%7s', MONTHS), '   mean\n')
  cat('observed albedo today: ', sprintf('%7.3f', m$observed_albedo_today[m$run == 'mod8']), '\n')
  cat('cells observed (share):', sprintf('%7.2f', m$cells_observed_share[m$run == 'mod8']), '\n')
  cat('kernel (W/m2 per unit):', sprintf('%7.0f', m$kernel_hadgem[m$run == 'mod8']), '\n')
  for (run in names(RUNS)) cat(sprintf('albedo change %-9s', substr(run, 1, 9)), sprintf('%7.4f', m$albedo_change[m$run == run]), sprintf('%8.4f', mean(m$albedo_change[m$run == run])), '\n')
  for (run in names(RUNS)) cat(sprintf('forcing W/m2  %-9s', substr(run, 1, 9)), sprintf('%7.2f', m$forcing_hadgem[m$run == run]), sprintf('%8.2f', mean(m$forcing_hadgem[m$run == run], na.rm = TRUE)), '\n')
  cat(sprintf('vegetation forcing, HadGEM3 (CACK): model 8 %+.2f (%+.2f), chosen %+.2f (%+.2f), coarse-location %+.2f (%+.2f) W/m2 over the box; global equivalent %+.2f, %+.2f, %+.2f mW/m2; ice part of the forcing in the box %+.2f W/m2\n',
              t$forcing_hadgem_mod8, t$forcing_cack_mod8, t$forcing_hadgem_loc100_linear, t$forcing_cack_loc100_linear, t$forcing_hadgem_mod8_coarse_loc, t$forcing_cack_mod8_coarse_loc,
              t$global_equivalent_mwm2_mod8, t$global_equivalent_mwm2_loc100_linear, t$global_equivalent_mwm2_mod8_coarse_loc, t$ice_forcing_hadgem))
  cat(sprintf('largest difference between the fitted and the simulated albedo change (any month, any run): %.4f\n', t$largest_fitted_minus_simulated))
}
