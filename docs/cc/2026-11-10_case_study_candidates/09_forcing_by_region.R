# Where the vegetation forcing comes from, and where the three runs disagree: the forcing of
# each of the pipeline's seven periods split between twelve regions that together cover the
# study area, for each run.
#
# Each number is a region's contribution to the global-equivalent vegetation forcing of the
# period (mW/m2; HadGEM3 kernel; the vegetation part of the partial-ice split), so a column
# adds up to the run's own figure in forcing_by_period_variant_sensitivity.csv, which is
# checked. Writes forcing_by_region.csv.
source('./case_study_helpers.R')
a = read_cache(); cells = a$cells
EARTH_AREA = 5.101e14
PERIOD_ENDS = c(50, 500, 2000, 4000, 6000, 8000, 10000, 11500)
period_label = sprintf('%s-%s ka', format(head(PERIOD_ENDS, -1) / 1000), format(PERIOD_ENDS[-1] / 1000))
period_file  = c('0.05 - 0.5 ka', '0.5 - 2 ka', '2 - 4 ka', '4 - 6 ka', '6 - 8 ka', '8 - 10 ka', '10 - 12 ka')   # labels in the runs' tables

# Twelve regions that do not overlap and leave no cell out; the first rule that fits wins.
region_of_cell = function(lon, lat) {
  ifelse(lat >= 55 & lon < -141, 'Alaska',
  ifelse(lat >= 55 & lon < -115, 'North-west Canada',
  ifelse(lat >= 55 & lon < -80,  'Central Canada north of 55 N',
  ifelse(lat >= 50 & lon >= -80, 'Quebec-Labrador and eastern Arctic',
  ifelse(lon < -115,             'Pacific coast and western mountains',
  ifelse(lon < -100 & lat >= 40, 'Northern Rockies and northern plains',
  ifelse(lon < -103,             'South-west',
  ifelse(lon < -94 & lat < 40,   'Southern Plains',
  ifelse(lon < -88 & lat >= 40,  'Midwest prairie-forest border',
  ifelse(lon >= -80 & lat >= 40, 'North-east',
  ifelse(lat >= 37,              'Ohio valley, Great Lakes and mid-Atlantic',
                                 'South-east')))))))))))
}
cells$region = region_of_cell(cells$x, cells$y)
regions = c('Alaska', 'North-west Canada', 'Central Canada north of 55 N', 'Quebec-Labrador and eastern Arctic',
            'Pacific coast and western mountains', 'Northern Rockies and northern plains', 'Midwest prairie-forest border',
            'Ohio valley, Great Lakes and mid-Atlantic', 'North-east', 'South-east', 'Southern Plains', 'South-west')
stopifnot(all(cells$region %in% regions))

# A cell's forcing over a period: the pairs summed, then the mean of the months with a value
# (script 9's rule).
cell_forcing = function(run, p) {
  pairs_in = which(a$pairs >= PERIOD_ENDS[p] & a$pairs < PERIOD_ENDS[p + 1])
  rowMeans(apply(a$forcing[[run]]$hadgem_veg_part[, pairs_in, , drop = FALSE], c(1, 3), sum), na.rm = TRUE)
}
table = do.call(rbind, lapply(names(RUNS), function(run) do.call(rbind, lapply(seq_along(period_label), function(p) {
  f = cell_forcing(run, p)
  data.frame(run = run, period = period_label[p], region = regions,
             cells = as.vector(table(factor(cells$region, regions))),
             global_equivalent_mwm2 = sapply(regions, function(r) 1000 * sum((f * cells$area)[cells$region == r], na.rm = TRUE) / EARTH_AREA),
             mean_over_region_wm2 = sapply(regions, function(r) weighted_mean(f[cells$region == r], cells$area[cells$region == r])), row.names = NULL)
}))))
write.csv(table, file.path(OUT_DIR, 'forcing_by_region.csv'), row.names = FALSE)

# Check: the regions add up to the run's own figure for the period.
for (run in names(RUNS)) {
  own = read.csv(file.path(RUNS[[run]], 'output/forcing/forcing_by_period_variant_sensitivity.csv'))
  own = own[own$variant == 'veg_part', ]
  mine = tapply(table$global_equivalent_mwm2[table$run == run], factor(table$period[table$run == run], period_label), sum)
  cat(sprintf('%-16s largest difference from the run\'s own period figures: %.2e mW/m2\n', run, max(abs(mine - 1000 * own$global_equiv[match(period_file, own$period)]))))
}
wide = function(run) { t = table[table$run == run, ]; m = tapply(t$global_equivalent_mwm2, list(factor(t$region, regions), factor(t$period, rev(period_label))), sum); rbind(m, `ALL REGIONS` = colSums(m)) }
for (run in names(RUNS)) { cat('\n', RUN_LABELS[[run]], ': contribution to the global-equivalent vegetation forcing, mW/m2 (oldest period first)\n', sep = ''); print(round(wide(run), 1)) }
all_runs = sapply(names(RUNS), function(run) wide(run), simplify = 'array')
cat('\nRange between the three runs (largest minus smallest), mW/m2\n'); print(round(apply(all_runs, 1:2, max) - apply(all_runs, 1:2, min), 1))
cat('\nDo the three runs agree in sign? (+ all warming, - all cooling, . not agreed)\n')
print(noquote(apply(all_runs, 1:2, function(v) if (all(v > 0)) '+' else if (all(v < 0)) '-' else '.')))
