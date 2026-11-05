# Small fixtures only. No shared inputs or albedo archive are needed.
library(terra)
source('R/modis_albedo_helpers.R')
source('R/northeast_forest_albedo.R')
close = function(a, b, tolerance = 1e-8) stopifnot(isTRUE(all.equal(a, b, tolerance = tolerance)))
fails = function(expr) stopifnot(inherits(tryCatch(force(expr), error = identity), 'error'))

close(northeast_distance(0, 0, 1, 0), pi * R_EARTH / 180)
close(northeast_distance(-70, 45, -70, 45), 0)
# A longitude degree has less ground distance at this latitude than on the equator.
stopifnot(northeast_distance(-70, 45, -69.95, 45) < 5000)
stopifnot(northeast_distance(-70, 0, -69.95, 0) > 5000)
stopifnot(identical(northeast_cell(c(-80, -79.000001, -79), c(40, 43.999999, 44))$cell_key,
                    c('-79.5 40.5', '-79.5 43.5', '-78.5 44.5')))

# Neighbourhoods span horizontal tile joins. One missing pixel defeats completeness.
x = cbind(matrix(1, 7, 4), matrix(1, 7, 4))
stopifnot(northeast_window_sum(x, 3)[4, 4] == 9,
          northeast_window_sum(x, 5)[4, 4] == 25,
          northeast_window_sum(x, 3)[1, 4] < 9)
x[4, 5] = NA
stopifnot(northeast_window_sum(x, 3)[4, 4] == 8)
stopifnot(identical(northeast_wetland(c(TRUE, FALSE, FALSE), c(FALSE, FALSE, TRUE)), c(TRUE, NA, FALSE)))

# Search support is checked against the joined map, including the missing side of 40 N.
joined = tile_template('h11v04')
ext(joined) = ext(xmin(joined), xmax(tile_template('h13v04')), ymin(joined), ymax(joined))
ncol(joined) = 7200
boundary = data.frame(bundle = c('main', 'stricter', 'looser'), distance = c(5000, 3000, 10000),
                      width = c(3, 5, 3), below = c(40.0510, 40.0372, 40.0960),
                      above = c(40.0516, 40.0376, 40.0964))
for (i in seq_len(nrow(boundary))) {
  stopifnot(!northeast_search_complete(-75, boundary$below[i], boundary$distance[i], boundary$width[i], joined),
            northeast_search_complete(-75, boundary$above[i], boundary$distance[i], boundary$width[i], joined))
}
join_lon = xmax(tile_template('h11v04')) / (R_EARTH * cos(45 * pi / 180)) * 180 / pi
stopifnot(northeast_search_complete(join_lon, 45, 5000, 3, joined))

# A deliberately offset DEM proves containing cells are used at native boundaries.
dem = rast(nrows = 5, ncols = 5, xmin = -1.000138889, xmax = 3.999861111,
           ymin = -1.000138889, ymax = 3.999861111, crs = 'EPSG:4326')
values(dem) = 100
values(dem)[13] = 200
z = northeast_terrain(dem, c(1.5, 1.9999, 2), c(1.5, 1.5, 1.5))
close(z$elevation, c(200, 100, 100)); close(z$relief, c(100, 100, 100))
values(dem)[7] = NA
stopifnot(is.na(northeast_terrain(dem, 1.5, 1.5)$relief))
stopifnot(is.na(northeast_terrain(dem, -0.9, 1.5)$relief))

candidate = function(id, lon, lat, elevation, type = 'DBF') {
  cell = northeast_cell(lon, lat)
  data.frame(id = id, tile = substr(id, 1, 6), pixel = seq_along(id), lon = lon, lat = lat, cell,
             forest_class = type, elevation = elevation, relief = 100, wetland = FALSE,
             wetland3 = FALSE, in_domain = TRUE)
}
enf = candidate(c('h11v04_e1', 'h11v04_e2'), c(-70, -70.001), c(45, 45), c(100, 100), 'ENF')
dbf = candidate(c('h12v04_b', 'h12v04_a', 'h12v04_close'), c(-69.99, -69.99, -69.999), c(45, 45, 45), c(150, 150, 151))
nearest = northeast_nearest(enf, dbf, 5000, 50)
stopifnot(identical(nearest$partner, c(2L, 2L))) # exact ties by ID, replacement, inclusive 50 m
stopifnot(all(is.na(northeast_nearest(enf, dbf, 5000, 49.99)$partner)))
stopifnot(all(is.na(northeast_nearest(enf, dbf[FALSE, ], 5000, 50)$partner)))
limit = northeast_distance(enf$lon[1], 45, dbf$lon[1], 45)
stopifnot(!is.na(northeast_nearest(enf[1, ], dbf[1, ], limit, 50)$partner),
          is.na(northeast_nearest(enf[1, ], dbf[1, ], limit - 0.0001, 50)$partner))

settings = data.frame(distance_m = 5000, elevation_m = 50)
all_candidates = rbind(enf, dbf)
pairs = northeast_pairs(all_candidates, settings)
stopifnot(nrow(pairs) == 2, length(unique(pairs$dbf_id)) == 1,
          all(pairs$elevation_difference_m == 50), sum(pairs$reciprocal) == 1)
# Random outcomes cannot influence selection: the pairing function has no outcome input.
all_candidates$s_all = c(999, NA, -999, 0.2, 0)
all_candidates$albedo = rev(all_candidates$s_all)
stopifnot(identical(pairs, northeast_pairs(all_candidates, settings)))
all_candidates$wetland[3:5] = NA
stopifnot(all(northeast_pairs(all_candidates, settings)$wetland_stratum == 'unknown'))
stopifnot(nrow(northeast_pairs(enf, settings)) == 0)
empty = all_candidates[FALSE, ]
stopifnot(nrow(northeast_land(list(main = empty, stricter = empty, looser = empty), data.frame())) == 0)

# Losses are sequential and missing values fail; relief includes the exact boundary.
s = northeast_screen(enf, list(relief = c(100, 100.01) <= 100, land = c(TRUE, NA)), 'main')
stopifnot(identical(s$keep, c(TRUE, FALSE)), sum(s$losses$n_lost) == 1)

# Frozen geographic identity is enforced on rerun.
tmp = tempfile(fileext = '.rds')
northeast_freeze_pairs(pairs, tmp)
northeast_freeze_pairs(pairs, tmp)
fails(northeast_freeze_pairs(pairs[1, ], tmp))
unlink(tmp)

# Small file-backed maps exercise the actual strip reader and nine-year decisions.
directory = tempfile('forest_fixture_'); dir.create(directory)
tiles = c('west', 'east'); years = 2001:2009
files = expand.grid(tile = tiles, year = years, stringsAsFactors = FALSE)
files$file = file.path(directory, paste0(files$tile, files$year, '.tif'))
for (i in seq_len(nrow(files))) {
  r = rast(nrows = 7, ncols = 4, nlyrs = 3)
  names(r) = c('LC_Type1', 'QC', 'LC_Prop3')
  v = cbind(rep(1, 28), rep(0, 28), rep(10, 28))
  # Two years of a different neighbour leave the central label stable, but only
  # seven pure 3 x 3 years: looser passes and main fails at the internal join.
  if (files$tile[i] == 'east' && files$year[i] <= 2002) v[13, 1] = 4
  if (files$tile[i] == 'west' && files$year[i] == 2001) v[16, 3] = NA
  if (files$tile[i] == 'west' && files$year[i] == 2009) v[16, 3] = 27
  values(r) = v
  writeRaster(r, files$file[i])
}
forest = northeast_forest_strip(files, tiles, years, 1, 7)
stopifnot(forest$stable[4, 4], forest$qc[4, 4], forest$n3[4, 4] == 7,
          forest$wetland[4, 4], forest$wetland3[4, 4],
          forest$n3[2, 2] == 9, forest$n5[1, 2] == 0)

# Odd MOD44W offsets must not shift the four subpixels under a forest centre.
template = rast(nrows = 3, ncols = 3, xmin = 1, xmax = 7, ymin = 1, ymax = 7, crs = SIN_CRS)
water = rast(nrows = 8, ncols = 8, xmin = 0, xmax = 8, ymin = 0, ymax = 8, crs = SIN_CRS)
values(water) = 0
values(water)[cellFromRowCol(water, 4, 4)] = 1
water_file = file.path(directory, 'water.tif'); writeRaster(water, water_file)
mask = northeast_water_strip(rast(water_file), template, 1, 3)
stopifnot(sum(mask) == 8, !mask[2, 2])
values(water)[cellFromRowCol(water, 2, 2)] = NA
writeRaster(water, water_file, overwrite = TRUE)
stopifnot(!northeast_water_strip(rast(water_file), template, 1, 3)[1, 1])

# A small map outside the production footprint exercises bounds derived from cells,
# native pixel IDs, tile joins, strip halos and explicit outside-domain ENF losses.
degree = R_EARTH * pi / 180
template = rast(nrows = 36, ncols = 40, xmin = 0.8 * degree, xmax = 1.2 * degree,
                ymin = 0.32 * degree, ymax = 0.68 * degree, crs = SIN_CRS)
cells = data.frame(x = 0.5, y = 0.5, key = '0.5 0.5')
bundles = data.frame(bundle = c('main', 'stricter', 'looser'), width = c(3L, 5L, 3L),
                     neighbour_years = c(9L, 9L, 7L), water_width = c(3L, 5L, 1L),
                     relief_m = c(100, 50, 200), distance_m = c(5000, 3000, 10000))
classes = matrix(rep(c(1, 4), each = 18), nrow = 36, ncol = 40)
classes[2, 3] = 5; classes[3, 4] = NA
for (i in seq_len(nrow(files))) {
  tile_number = match(files$tile[i], tiles)
  r = rast(nrows = 36, ncols = 20, nlyrs = 3, crs = SIN_CRS,
           xmin = xmin(template) + (tile_number - 1) * 0.2 * degree,
           xmax = xmin(template) + tile_number * 0.2 * degree,
           ymin = ymin(template), ymax = ymax(template))
  names(r) = c('LC_Type1', 'QC', 'LC_Prop3')
  columns = seq_len(20) + (tile_number - 1) * 20
  values(r) = cbind(as.vector(t(classes[, columns])), 0, 10)
  writeRaster(r, files$file[i], overwrite = TRUE)
}
water = disagg(template, fact = 2); values(water) = 0
writeRaster(water, water_file, overwrite = TRUE)
dem = rast(nrows = 20, ncols = 20, xmin = -0.5, xmax = 1.5, ymin = -0.5, ymax = 1.5, crs = 'EPSG:4326')
values(dem) = 100
dem_file = file.path(directory, 'dem.tif'); writeRaster(dem, dem_file)
inputs = list(land_cover = files, water = water_file, dem = dem_file)
selection = northeast_candidates(inputs, cells, bundles, tiles, years, template, block_rows = 8L)
whole = northeast_candidates(inputs, cells, bundles, tiles, years, template, block_rows = nrow(template))
close(selection$candidates, whole$candidates, tolerance = 1e-12)
for (bundle in bundles$bundle) {
  selected = selection$candidates[[bundle]]
  stopifnot(identical(selected$id, whole$candidates[[bundle]]$id), !anyDuplicated(selected$id),
            all(selected$in_domain | selected$forest_class == 'DBF'),
            any(selected$forest_class == 'ENF'), any(!selected$in_domain))
  decoded = do.call(rbind, strsplit(selected$id, '_', fixed = TRUE))
  stopifnot(identical(decoded[, 1], selected$tile), all(as.integer(decoded[, 2]) == selected$pixel))
  for (tile in tiles) {
    at = which(decoded[, 1] == tile)
    r = rast(files$file[match(tile, files$tile)])
    xy = xyFromCell(r, as.integer(decoded[at, 2]))
    latitude = xy[, 2] / R_EARTH
    recovered = cbind(lon = xy[, 1] / (R_EARTH * cos(latitude)) * 180 / pi, lat = latitude * 180 / pi)
    stopifnot(max(abs(recovered - as.matrix(selected[at, c('lon', 'lat')]))) <= 1e-9)
    # These four centres straddle both the tile join and a strip join.
    edge_column = if (tile == tiles[1]) 20L else 1L
    stopifnot(all(((c(24L, 25L) - 1L) * 20L + edge_column) %in% selected$pixel[at]))
  }
  losses = selection$losses[selection$losses$bundle == bundle, ]
  losses$cell_key[is.na(losses$cell_key)] = 'outside'
  stopifnot(all(losses$n_before == losses$n_after + losses$n_lost),
            sum(losses$n_lost[losses$screen == 'enf_scope']) > 0)
  for (key in unique(losses$cell_key)) {
    cell_losses = losses[losses$cell_key == key, ]
    stopifnot(sum(cell_losses$n_after[cell_losses$screen == 'forest_class']) ==
              sum(cell_losses$n_before[cell_losses$screen == 'enf_scope']))
    for (forest in c('ENF', 'DBF')) {
      by_class = cell_losses[cell_losses$forest_class == forest, ]
      if (!nrow(by_class)) next
      totals = aggregate(by_class[c('n_before', 'n_after', 'n_lost')],
                         list(screen = by_class$screen), sum)
      totals = totals[match(unique(by_class$screen), totals$screen), ]
      retained = selected$forest_class == forest & ifelse(selected$in_domain, selected$cell_key, 'outside') == key
      stopifnot(all(head(totals$n_after, -1) == tail(totals$n_before, -1)),
                tail(totals$n_after, 1) == sum(retained),
                totals$n_before[1] - sum(totals$n_lost) == sum(retained))
    }
  }
}
unlink(directory, recursive = TRUE)
cat('test_northeast_forest_albedo: all tests passed\n')
