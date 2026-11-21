# check_compare_ice.R: checks of tools/compare_ice.R's output, for its verification specs. Run from
# the repository root after the comparison:
#   Rscript tools/check_compare_ice.R <comparison-dir> <old-ice-run-dir>
# Stops at the first failure. What it checks, each by a route other than the tool's own:
#   - the old raster's net increases in ice coverage on the forcing cells are the established
#     audit's: 186 raw cell-pairs, 228 after script 7a's averaging, 75 of them created by it
#     (docs/cc/2026-11-16_ice_comparison_design_codex_gpt6astra.md);
#   - every inventory row is one source, cell and pair of slices, and an increase;
#   - the old-ice run's forcing is script 9's tables, number for number (the join and the labels);
#   - the old raster's ice area by slice, read straight from the raster at the cell centres
#     with script 8's cell areas in m2, is the table's, in km2 (units and support).
library(terra)
args = commandArgs(trailingOnly = TRUE)
if (length(args) != 2) { cat('usage: Rscript tools/check_compare_ice.R <comparison-dir> <old-ice-run-dir>\n'); quit(status = 2) }
comparison = args[1]; old_run = args[2]
table = function(name) read.csv(file.path(comparison, name))

inventory = table('readvance_inventory.csv')
old = inventory[inventory$source == 'old raster', ]
stopifnot(sum(old$raw_increase > 0) == 186, sum(old$adjusted_increase > 0) == 228, sum(old$averaging == 'created') == 75,
          !anyDuplicated(inventory[, c('source', 'cell_id', 'year_old')]),
          all(inventory$raw_increase > 0 | inventory$adjusted_increase > 0, na.rm = TRUE),
          all(inventory$year_old > inventory$year_young))

forcing = table('forcing_comparison.csv')
saved = read.csv(file.path(old_run, 'output/forcing/forcing_by_period.csv'))
mine = forcing[forcing$source == 'old raster' & forcing$quantity == 'total', ]
both = merge(mine, saved, by.x = c('period_saved', 'kernel'), by.y = c('period', 'kernel'), suffixes = c('', '_saved'))
stopifnot(nrow(both) == nrow(saved), nrow(mine) == nrow(saved),
          identical(both$domain_mean, both$domain_mean_saved), identical(both$global_equiv, both$global_equiv_saved),
          all(forcing$domain_mean_minus_old[forcing$source == 'old raster'] == 0, na.rm = TRUE))
parts = read.csv(file.path(old_run, 'output/forcing/forcing_by_period_variant_sensitivity.csv'))
mine = forcing[forcing$source == 'old raster' & forcing$quantity != 'total', ]
both = merge(mine, parts, by.x = c('period_saved', 'variant'), by.y = c('period', 'variant'), suffixes = c('', '_saved'))
stopifnot(nrow(both) == nrow(mine), all(c('veg_part', 'ice_part') %in% mine$variant), identical(both$global_equiv, both$global_equiv_saved))

cells = readRDS(file.path(old_run, 'output/forcing/RF_holocene_all_cases.RDS'))
cells = cells[!duplicated(cells$cell_id), c('cell_id', 'x', 'y', 'area')]
raster = rast('data/Dalton_QSR_2020_Ice/dalton_interpolated_LC6k.tif')
ice = table('ice_by_slice.csv')
direct = sapply(ice$age_bp, function(age) sum(extract(raster[[paste0('yr', age, 'bp')]], as.matrix(cells[, c('x', 'y')]))[, 1] * as.numeric(cells$area)) / 1e6)
stopifnot(nrow(ice) == 25, max(abs(direct - ice$dalton_ice_km2)) <= 0.05,
          all(ice[, grep('_km2$', names(ice))[1:4]] <= sum(as.numeric(cells$area)) / 1e6))
cat('check_compare_ice: all checks passed\n')
