# Forest selection and fixed geographic pairs. No function here needs an albedo value.
# The approved design and frozen settings are dated 3 November 2026 (issue #27).

# Great-circle metres, using the MODIS sphere. The settings do not choose a sphere;
# sharing its radius avoids introducing a second Earth model for these native pixels.
northeast_distance = function(lon1, lat1, lon2, lat2) {
  rad = pi / 180
  a = sin((lat2 - lat1) * rad / 2)^2 +
    cos(lat1 * rad) * cos(lat2 * rad) * sin((lon2 - lon1) * rad / 2)^2
  2 * R_EARTH * asin(sqrt(pmin(1, pmax(0, a))))
}

# The pipeline uses half-open, whole-degree cells, including at tile joins.
northeast_cell = function(lon, lat) {
  x = floor(lon) + 0.5; y = floor(lat) + 0.5
  data.frame(cell_x = x, cell_y = y, cell_key = paste(x, y))
}

# A square sum with zero outside the supplied matrix. Two one-dimensional passes
# avoid constructing a full raster or a large array of neighbourhoods.
northeast_window_sum = function(x, width) {
  stopifnot(width %% 2 == 1, width <= min(dim(x)))
  x[is.na(x)] = 0
  h = (width - 1) / 2
  rows = seq_len(nrow(x)); cols = seq_len(ncol(x))
  vertical = horizontal = matrix(0, nrow(x), ncol(x))
  for (offset in -h:h) {
    dest = rows[rows + offset >= 1 & rows + offset <= nrow(x)]
    vertical[dest, ] = vertical[dest, , drop = FALSE] + x[dest + offset, , drop = FALSE]
  }
  for (offset in -h:h) {
    dest = cols[cols + offset >= 1 & cols + offset <= ncol(x)]
    horizontal[, dest] = horizontal[, dest, drop = FALSE] + vertical[, dest + offset, drop = FALSE]
  }
  horizontal
}

# TRUE if ever flagged, FALSE only when every observation is known and unflagged.
northeast_wetland = function(any_flag, all_known) {
  ifelse(any_flag, TRUE, ifelse(all_known, FALSE, NA))
}

# A complete geographic search must fit inside the available classification map,
# with space for the partner's neighbourhood. The bounding lon/lat rectangle of
# the spherical circle is conservative at the curved outer sinusoidal edges.
# This plain choice can exclude a few extra centres; internal tile edges are joined.
northeast_search_complete = function(lon, lat, distance_m, width, template) {
  angle = distance_m / R_EARTH
  low_lat = lat * pi / 180 - angle; high_lat = lat * pi / 180 + angle
  dlon = asin(pmin(1, sin(angle) / cos(lat * pi / 180)))
  low_lon = lon * pi / 180 - dlon; high_lon = lon * pi / 180 + dlon
  cosine = cbind(cos(low_lat), cos(high_lat), ifelse(low_lat <= 0 & high_lat >= 0, 1, cos(low_lat)))
  x = cbind(low_lon * cosine, high_lon * cosine) * R_EARTH
  margin = width / 2 * terra::res(template)[1]
  apply(x, 1, min) >= terra::xmin(template) + margin &
    apply(x, 1, max) <= terra::xmax(template) - margin &
    low_lat * R_EARTH >= terra::ymin(template) + margin &
    high_lat * R_EARTH <= terra::ymax(template) - margin
}

# Native containing-cell elevation and complete 3 x 3 relief, without shifting or
# resampling GMTED. Missing neighbours exclude a candidate; zero metres is valid.
northeast_terrain = function(dem, lon, lat) {
  centre = terra::cellFromXY(dem, cbind(lon, lat))
  rc = terra::rowColFromCell(dem, centre)
  neighbours = do.call(cbind, lapply(-1:1, function(dr) {
    do.call(cbind, lapply(-1:1, function(dc) {
      row = rc[, 1] + dr; col = rc[, 2] + dc
      valid = !is.na(row) & row >= 1 & row <= nrow(dem) & col >= 1 & col <= ncol(dem)
      cell = rep(NA_real_, length(row))
      cell[valid] = (row[valid] - 1) * ncol(dem) + col[valid]
      cell
    }))
  }))
  unique_cells = unique(as.vector(neighbours[!is.na(neighbours)]))
  heights = if (length(unique_cells)) terra::extract(dem, unique_cells)[, 1] else numeric()
  z = matrix(heights[match(as.vector(neighbours), unique_cells)], nrow = length(centre))
  complete = rowSums(is.finite(z)) == 9
  relief = rep(NA_real_, length(centre))
  relief[complete] = apply(z[complete, , drop = FALSE], 1, function(v) max(v) - min(v))
  data.frame(elevation = z[, 5], relief = relief)
}

# The exact 27 annual files and all 118 monthly count files per tile are required.
# Directory listings are deliberately limited to these two input directories.
northeast_inputs = function(data_dir, tiles, years) {
  lc = list.files(file.path(data_dir, 'mcd12q1'), pattern = '^MCD12Q1.*\\.hdf$', full.names = TRUE)
  expected = expand.grid(tile = tiles, year = years, stringsAsFactors = FALSE)
  expected$file = vapply(seq_len(nrow(expected)), function(i) {
    found = lc[grepl(sprintf('^MCD12Q1\\.A%d001\\.%s\\.061\\.', expected$year[i], expected$tile[i]), basename(lc))]
    if (length(found) != 1) stop('Expected one MCD12Q1 file: ', expected$tile[i], ' ', expected$year[i])
    found
  }, '')
  acquisition = file.path(data_dir, 'mcd12q1/manifest.csv')
  approved = read.csv(acquisition, comment.char = '#')
  sizes = approved$bytes[match(basename(expected$file), approved$name)]
  if (anyNA(sizes) || any(file.info(expected$file)$size != sizes))
    stop('MCD12Q1 files differ from the approved filename/byte-count manifest')
  months = format(seq(as.Date('2000-03-01'), as.Date('2009-12-01'), by = 'month'), '%Y_%m')
  monthly = expand.grid(tile = tiles, date = months, stringsAsFactors = FALSE)
  monthly$file = file.path(data_dir, 'modis_albedo/monthly', paste0(monthly$tile, '_', monthly$date, '.tif'))
  monthly$year = as.integer(substr(monthly$date, 1, 4)); monthly$month = as.integer(substr(monthly$date, 6, 7))
  water = file.path(data_dir, 'mod44w/2015/MOD44W.061_water_mask_doy2015001000000_aid0001.tif')
  dem = file.path(data_dir, 'gmted2010/mn30_grd')
  required = c(expected$file, monthly$file, water, dem)
  if (any(!file.exists(required))) stop('Missing input: ', required[!file.exists(required)][1])
  list(land_cover = expected, acquisition = acquisition, monthly = monthly, water = water, dem = dem)
}

# Check metadata only: the stage must never inspect albedo sums, even to validate them.
northeast_check_grids = function(inputs, tiles) {
  for (tile in tiles) {
    template = tile_template(tile)
    for (file in c(inputs$land_cover$file[inputs$land_cover$tile == tile],
                   inputs$monthly$file[inputs$monthly$tile == tile])) {
      r = terra::rast(file)
      if (!terra::compareGeom(r, template, lyrs = FALSE, stopOnError = FALSE)) stop('Grid differs: ', file)
    }
  }
  mosaic = tile_template(tiles[1])
  terra::ext(mosaic) = terra::ext(terra::xmin(mosaic), terra::xmax(tile_template(tail(tiles, 1))),
                                terra::ymin(mosaic), terra::ymax(mosaic))
  terra::ncol(mosaic) = 2400 * length(tiles)
  water = terra::rast(inputs$water)
  offset = c((terra::xmin(mosaic) - terra::xmin(water)) / terra::res(water)[1],
             (terra::ymax(water) - terra::ymax(mosaic)) / terra::res(water)[2])
  if (!terra::same.crs(water, mosaic) || any(abs(terra::res(mosaic) / terra::res(water) - 2) > 1e-6) ||
      any(abs(offset - round(offset)) > 1e-4)) stop('MOD44W is not aligned at two subpixels per MODIS pixel')
  if (any(offset < 0) || offset[1] + 2 * ncol(mosaic) > ncol(water) ||
      offset[2] + 2 * nrow(mosaic) > nrow(water)) stop('MOD44W does not cover the forest tiles')
  mosaic
}

# Read just a horizontal strip, including its neighbours in the adjacent tiles.
northeast_class_strip = function(files, row, nrows) {
  layers = c('LC_Type1', 'QC', 'LC_Prop3')
  pieces = lapply(files, function(file) {
    r = terra::rast(file)[[layers]]
    terra::readStart(r); on.exit(terra::readStop(r))
    terra::readValues(r, row = row, nrows = nrows, mat = TRUE)
  })
  setNames(lapply(seq_along(layers), function(j) {
    do.call(cbind, lapply(pieces, function(v) matrix(v[, j], nrow = nrows, byrow = TRUE)))
  }), layers)
}

# All four native 250 m subpixels must explicitly say land (MOD44W code zero).
northeast_water_strip = function(water, template, row, nrows) {
  col0 = round((terra::xmin(template) - terra::xmin(water)) / terra::res(water)[1])
  row0 = round((terra::ymax(water) - terra::ymax(template)) / terra::res(water)[2])
  terra::readStart(water); on.exit(terra::readStop(water))
  v = terra::readValues(water, row = row0 + 2 * (row - 1) + 1, nrows = 2 * nrows,
                        col = col0 + 1, ncols = 2 * ncol(template), mat = FALSE)
  x = matrix(!is.na(v) & v == 0, nrow = 2 * nrows, byrow = TRUE)
  odd_r = seq(1, nrow(x), 2); odd_c = seq(1, ncol(x), 2)
  x[odd_r, odd_c] & x[odd_r + 1, odd_c] & x[odd_r, odd_c + 1] & x[odd_r + 1, odd_c + 1]
}

# Accumulate nine years of labels without retaining nine rasters in memory.
northeast_forest_strip = function(land_cover, tiles, years, row, nrows) {
  for (year in years) {
    files = land_cover$file[match(paste(tiles, year), paste(land_cover$tile, land_cover$year))]
    v = northeast_class_strip(files, row, nrows)
    class = v$LC_Type1
    known = !is.na(v$LC_Prop3) & v$LC_Prop3 != 255
    flagged = !is.na(v$LC_Prop3) & v$LC_Prop3 == 27
    if (year == years[1]) {
      initial = class; stable = !is.na(class); qc = matrix(TRUE, nrow(class), ncol(class))
      n3 = n5 = matrix(0L, nrow(class), ncol(class))
      any_wet = any_wet3 = matrix(FALSE, nrow(class), ncol(class))
      all_known = all_known3 = matrix(TRUE, nrow(class), ncol(class))
    }
    stable = stable & !is.na(class) & class == initial
    qc = qc & !is.na(v$QC) & v$QC == 0
    same3 = same5 = matrix(FALSE, nrow(class), ncol(class))
    for (code in c(1, 4)) {
      same = !is.na(class) & class == code
      same3 = same3 | (same & northeast_window_sum(same, 3) == 9)
      same5 = same5 | (same & northeast_window_sum(same, 5) == 25)
    }
    n3 = n3 + same3; n5 = n5 + same5
    any_wet = any_wet | flagged; all_known = all_known & known
    any_wet3 = any_wet3 | northeast_window_sum(flagged, 3) > 0
    all_known3 = all_known3 & northeast_window_sum(known, 3) == 9
  }
  list(class = initial, stable = stable, qc = qc, n3 = n3, n5 = n5,
       wetland = northeast_wetland(any_wet, all_known), wetland3 = northeast_wetland(any_wet3, all_known3))
}

# Sequential losses within each own pipeline cell; NA denotes DBF search support
# outside the target cells. Missing screening information always fails the screen.
northeast_screen = function(x, screens, bundle) {
  keep = rep(TRUE, nrow(x)); losses = list()
  group = interaction(x$forest_class, ifelse(x$in_domain, x$cell_key, 'outside'), drop = TRUE)
  groups = split(seq_len(nrow(x)), group)
  for (screen in names(screens)) {
    after = keep & screens[[screen]] %in% TRUE
    losses[[screen]] = do.call(rbind, lapply(groups, function(i) {
      data.frame(bundle = bundle, forest_class = x$forest_class[i[1]],
                 cell_key = if (x$in_domain[i[1]]) x$cell_key[i[1]] else NA_character_, screen = screen,
                 n_before = sum(keep[i]), n_after = sum(after[i]), n_lost = sum(keep[i] & !after[i]))
    }))
    keep = after
  }
  list(keep = keep, losses = do.call(rbind, losses))
}

# Build structural candidates strip by strip. Only survivors are held between strips.
northeast_candidates = function(inputs, cells, bundles, tiles, years, template, block_rows = 48L) {
  water = terra::rast(inputs$water); dem = terra::rast(inputs$dem)
  candidates = setNames(lapply(bundles$bundle, function(b) list()), bundles$bundle)
  losses = list(); part = 0L
  # A bounding box for the largest search circle is enough to retain every partner.
  angle = max(bundles$distance_m) / R_EARTH
  lat_pad = angle * 180 / pi
  lon_pad = asin(sin(angle) / cos((48 + lat_pad) * pi / 180)) * 180 / pi
  for (first in seq(1L, nrow(template), by = block_rows)) {
    last = min(nrow(template), first + block_rows - 1L)
    row = max(1L, first - 2L); end = min(nrow(template), last + 2L)
    strip = terra::rast(nrows = end - row + 1L, ncols = ncol(template), crs = SIN_CRS,
                       xmin = terra::xmin(template), xmax = terra::xmax(template),
                       ymin = terra::ymax(template) - end * terra::res(template)[2],
                       ymax = terra::ymax(template) - (row - 1) * terra::res(template)[2])
    if (terra::ymin(strip) / R_EARTH * 180 / pi > 48 + lat_pad) next
    message('Forest rows ', first, '-', last, ' of ', nrow(template))
    f = northeast_forest_strip(inputs$land_cover, tiles, years, row, nrow(strip))
    ll = pixel_lonlat(strip)
    index = seq_len(terra::ncell(strip))
    global_row = (index - 1L) %/% ncol(strip) + row
    global_col = (index - 1L) %% ncol(strip) + 1L
    initial = as.vector(t(f$class))
    spatial = global_row >= first & global_row <= last &
      ll[, 1] >= -80 - lon_pad & ll[, 1] <= -66 + lon_pad &
      ll[, 2] >= 40 - lat_pad & ll[, 2] <= 48 + lat_pad
    # Record the starting class screen, including mixed forest and missing labels.
    spatial_at = which(spatial)
    all_cells = northeast_cell(ll[spatial_at, 1], ll[spatial_at, 2])
    initial_counts = data.frame(forest_class = rep('all', length(spatial_at)), all_cells,
                                in_domain = all_cells$cell_key %in% cells$key)
    for (bundle in bundles$bundle) {
      classified = northeast_screen(initial_counts, list(forest_class = initial[spatial_at] %in% c(1, 4)), bundle)
      part = part + 1L; losses[[part]] = classified$losses
    }
    at = which(spatial & initial %in% c(1, 4))
    cell = northeast_cell(ll[at, 1], ll[at, 2])
    domain = cell$cell_key %in% cells$key
    at = at[initial[at] == 4 | domain]
    if (!length(at)) next
    cell = northeast_cell(ll[at, 1], ll[at, 2])
    tile_number = (global_col[at] - 1L) %/% 2400L + 1L
    pixel = (global_row[at] - 1L) * 2400L + (global_col[at] - 1L) %% 2400L + 1L
    x = data.frame(id = sprintf('%s_%07d', tiles[tile_number], pixel), tile = tiles[tile_number], pixel = pixel,
                   lon = ll[at, 1], lat = ll[at, 2], cell,
                   forest_class = ifelse(initial[at] == 1, 'ENF', 'DBF'),
                   in_domain = cell$cell_key %in% cells$key)
    values_at = function(v) as.vector(t(v))[at]
    x$wetland = values_at(f$wetland); x$wetland3 = values_at(f$wetland3)
    terrain = northeast_terrain(dem, x$lon, x$lat)
    x$elevation = terrain$elevation; x$relief = terrain$relief
    land = northeast_water_strip(water, template, row, nrow(strip))
    water3 = values_at(northeast_window_sum(land, 3) == 9)
    water5 = values_at(northeast_window_sum(land, 5) == 25)
    for (b in seq_len(nrow(bundles))) {
      s = bundles[b, ]; half = (s$width - 1) / 2
      complete = global_row[at] > half & global_row[at] <= nrow(template) - half &
        global_col[at] > half & global_col[at] <= ncol(template) - half
      screens = list(stable_centre = values_at(f$stable), classification_qc = values_at(f$qc),
                     neighbourhood_boundary = complete,
                     same_class_neighbourhood = values_at(if (s$width == 5) f$n5 else f$n3) >= s$neighbour_years,
                     water = if (s$water_width == 5) water5 else if (s$water_width == 3) water3 else values_at(land),
                     valid_terrain = is.finite(x$elevation) & is.finite(x$relief),
                     relief = x$relief <= s$relief_m,
                     search_boundary = x$forest_class == 'DBF' | northeast_search_complete(x$lon, x$lat, s$distance_m, s$width, template))
      result = northeast_screen(x, screens, s$bundle)
      candidates[[s$bundle]][[length(candidates[[s$bundle]]) + 1L]] = x[result$keep, ]
      part = part + 1L; losses[[part]] = result$losses
    }
  }
  candidates = lapply(candidates, function(parts) {
    x = do.call(rbind, parts); x = x[order(x$id), ]; rownames(x) = NULL; x
  })
  list(candidates = candidates, losses = do.call(rbind, losses))
}

# Record-wide land counts only, restricted to the union of potential candidates.
# All 118 months count, including 2000; the pairing period alone would change is_land.
northeast_land = function(candidates, monthly_files) {
  x = unique(do.call(rbind, lapply(candidates, function(x) x[, c('id', 'tile', 'pixel')])))
  x$land = rep(FALSE, nrow(x))
  for (tile in unique(x$tile)) {
    at = which(x$tile == tile)
    total = matrix(0, nrow = length(at), ncol = 3)
    for (file in monthly_files$file[monthly_files$tile == tile]) {
      r = terra::rast(file)[[c('land_days', 'shore_days', 'read_days')]]
      v = as.matrix(terra::extract(r, x$pixel[at]))
      if (any(!is.finite(v)) || any(v < 0) || any(v != round(v)) || any(v[, 1] + v[, 2] > v[, 3]))
        stop('Invalid land counts in ', file)
      total = total + v
    }
    x$land[at] = is_land(total[, 1], total[, 2], total[, 3], rule = 'land')
  }
  x[, c('id', 'land')]
}

# Record the build identity without reading any raster band. The production files
# must all have the same settings; a July test file must not enter this record.
northeast_monthly_metadata = function(files) {
  tags = c('paleoRF_build', 'paleoRF_script_sha256', 'paleoRF_modis_helpers_sha256')
  metadata = do.call(rbind, lapply(files, function(file) {
    m = terra::metags(terra::rast(file))
    values = m$value[match(tags, m$name)]
    data.frame(file = file, as.list(setNames(values, tags)), check.names = FALSE)
  }))
  build = unique(metadata$paleoRF_build)
  if (length(build) != 1 || is.na(build) || !grepl('noon zenith from the data', build, fixed = TRUE) ||
      !grepl('full_75 full 75, any_75 any 75, full_70 full 70', build, fixed = TRUE) ||
      !grepl('full inversions 0 2 4 6', build, fixed = TRUE))
    stop('Monthly files do not share the frozen production retrieval settings')
  if (anyNA(metadata$paleoRF_script_sha256) || any(!grepl('^[0-9a-f]{64}$', metadata$paleoRF_script_sha256)))
    stop('Monthly files lack their build code identity')
  metadata
}

# Nearest eligible target with replacement. Small geographic bins limit comparisons;
# elevation and exact great-circle distance, rather than bin membership, select pairs.
northeast_nearest = function(from, to, distance_m, elevation_m) {
  partner = rep(NA_integer_, nrow(from)); distance = rep(NA_real_, nrow(from))
  if (!nrow(from) || !nrow(to)) return(data.frame(partner = partner, distance_m = distance))
  bin = 0.1
  buckets = split(seq_len(nrow(to)), paste(floor(to$lon / bin), floor(to$lat / bin)))
  angle = distance_m / R_EARTH
  for (i in seq_len(nrow(from))) {
    dy = angle * 180 / pi
    dx = asin(pmin(1, sin(angle) / cos(from$lat[i] * pi / 180))) * 180 / pi
    keys = expand.grid(x = seq(floor((from$lon[i] - dx) / bin), floor((from$lon[i] + dx) / bin)),
                       y = seq(floor((from$lat[i] - dy) / bin), floor((from$lat[i] + dy) / bin)))
    possible = unlist(buckets[paste(keys$x, keys$y)], use.names = FALSE)
    possible = possible[abs(to$elevation[possible] - from$elevation[i]) <= elevation_m]
    if (!length(possible)) next
    d = northeast_distance(from$lon[i], from$lat[i], to$lon[possible], to$lat[possible])
    eligible = which(d <= distance_m)
    if (!length(eligible)) next
    best = eligible[order(d[eligible], to$id[possible[eligible]], method = 'radix')[1]]
    partner[i] = possible[best]; distance[i] = d[best]
  }
  data.frame(partner = partner, distance_m = distance)
}

# Both stricter diagnostics are subsets of these fixed pairs, never another match.
northeast_pairs = function(candidates, settings) {
  enf = candidates[candidates$forest_class == 'ENF' & candidates$in_domain, ]
  dbf = candidates[candidates$forest_class == 'DBF', ]
  nearest = northeast_nearest(enf, dbf, settings$distance_m, settings$elevation_m)
  keep = !is.na(nearest$partner)
  a = enf[keep, ]; b = dbf[nearest$partner[keep], ]
  reverse = northeast_nearest(dbf, enf, settings$distance_m, settings$elevation_m)
  wet = ifelse(is.na(a$wetland) | is.na(b$wetland), 'unknown',
               c('neither', 'one', 'both')[1 + a$wetland + b$wetland])
  data.frame(enf_id = a$id, dbf_id = b$id, cell_x = a$cell_x, cell_y = a$cell_y, cell_key = a$cell_key,
             distance_m = nearest$distance_m[keep], elevation_difference_m = abs(a$elevation - b$elevation),
             enf_wetland = a$wetland, dbf_wetland = b$wetland, wetland_stratum = wet,
             reciprocal = reverse$partner[nearest$partner[keep]] == which(keep),
             unflagged3 = a$wetland3 %in% FALSE & b$wetland3 %in% FALSE)
}

# A rerun can reuse an identical table; a changed table needs a separate run directory.
northeast_freeze_pairs = function(pairs, file) {
  if (file.exists(file)) {
    if (!identical(readRDS(file), pairs)) stop('Fixed pair table differs: use a new run directory: ', file)
  } else saveRDS(pairs, file, version = 3)
  invisible(unname(tools::md5sum(file)))
}

# Publish each coverage stage through the ordinary project run manifest.
northeast_write_tables = function(run, tables, directory) {
  for (name in names(tables))
    write_output(run, tables[[name]], file.path(directory, paste0(name, '.csv')), write.csv, row.names = FALSE)
}

# Coverage of the fixed forest pairs. These functions never use albedo sums or values.

# Use cell latitude for every geographic summary, as for the later comparison.
northeast_coverage_regions <- function() {
  data.frame(region = c("all", paste0(40:47, "-", 41:48, "N"), "40-44N", "44-48N"),
             south = c(40, 40:47, 40, 44), north = c(48, 41:48, 44, 48))
}

# Separate diagnostics retain the stricter pairs; neither searches for a new partner.
northeast_pair_subsets <- function(pairs, bundle) {
  answer <- list(all = pairs)
  if (bundle == "stricter") {
    answer$reciprocal <- pairs[which(pairs$reciprocal), , drop = FALSE]
    answer$unflagged3 <- pairs[which(pairs$unflagged3), , drop = FALSE]
  }
  answer
}

# Empty strata keep explicit missing summaries, rather than suggesting zero distance.
# Quantiles use R's default type 7; these are descriptions, not uncertainty intervals.
northeast_number_summary <- function(x) {
  x <- x[is.finite(x)]
  if (!length(x)) return(c(n = 0, min = NA, q05 = NA, median = NA, mean = NA, q95 = NA, max = NA))
  c(n = length(x), min = min(x), q05 = unname(quantile(x, 0.05)),
    median = median(x), mean = mean(x), q95 = unname(quantile(x, 0.95)), max = max(x))
}

# Record eligible forest, fixed pairs, wetland strata, and every zero-pair pipeline cell.
northeast_structural_coverage <- function(candidates, pairs, cells, losses) {
  regions <- northeast_coverage_regions()
  summary_rows <- cell_rows <- balance_rows <- reuse_rows <- wetland_rows <- list()
  loss_rows <- feasibility_rows <- support_rows <- list()
  for (bundle in names(pairs)) {
    eligible <- candidates[[bundle]]
    for (forest in c("ENF", "DBF")) {
      support <- eligible[which(!eligible$in_domain & eligible$forest_class == forest), , drop = FALSE]
      support_rows[[length(support_rows) + 1L]] <- data.frame(bundle = bundle, forest_class = forest,
        region = "outside_pipeline_support", eligible_pixels = nrow(support),
        wetland_flagged = sum(support$wetland, na.rm = TRUE), wetland_unknown = sum(is.na(support$wetland)))
    }
    eligible <- eligible[which(eligible$in_domain), , drop = FALSE]
    for (subset in names(northeast_pair_subsets(pairs[[bundle]], bundle))) {
      selected <- northeast_pair_subsets(pairs[[bundle]], bundle)[[subset]]
      for (i in seq_len(nrow(regions))) {
        region <- regions[i, ]
        cell_keys <- cells$key[cells$y >= region$south & cells$y < region$north]
        p <- selected[selected$cell_key %in% cell_keys, , drop = FALSE]
        c <- eligible[eligible$cell_key %in% cell_keys, , drop = FALSE]
        cell_n <- table(factor(p$cell_key, levels = cell_keys))
        reuse <- table(p$dbf_id)
        prefix <- data.frame(bundle = bundle, subset = subset, region = region$region)
        summary_rows[[length(summary_rows) + 1L]] <- cbind(prefix, data.frame(
          eligible_enf = sum(c$forest_class == "ENF"), eligible_dbf = sum(c$forest_class == "DBF"),
          eligible_enf_wetland = sum(c$forest_class == "ENF" & c$wetland, na.rm = TRUE),
          eligible_dbf_wetland = sum(c$forest_class == "DBF" & c$wetland, na.rm = TRUE),
          eligible_enf_wetland_unknown = sum(c$forest_class == "ENF" & is.na(c$wetland)),
          eligible_dbf_wetland_unknown = sum(c$forest_class == "DBF" & is.na(c$wetland)),
          matched_enf = nrow(p), unique_dbf = length(reuse),
          reused_dbf = sum(reuse > 1), max_dbf_use = if (length(reuse)) max(reuse) else 0,
          pipeline_cells = length(cell_keys), cells_with_pairs = sum(cell_n > 0),
          cells_without_pairs = sum(cell_n == 0), cells_with_at_least_three_pairs = sum(cell_n >= 3)))
        for (variable in c("distance_m", "elevation_difference_m")) {
          balance_rows[[length(balance_rows) + 1L]] <- cbind(prefix, variable = variable,
            as.data.frame(as.list(northeast_number_summary(p[[variable]]))))
        }
        for (stratum in c("neither", "one", "both", "unknown")) {
          use <- p$wetland_stratum == stratum
          wetland_rows[[length(wetland_rows) + 1L]] <- cbind(prefix, data.frame(
            wetland_stratum = stratum, pairs = sum(use), unique_dbf = length(unique(p$dbf_id[use])),
            cells = length(unique(p$cell_key[use]))))
        }
        # A zero-use partner is not part of the pair table; an empty region has no reuse rows.
        if (length(reuse)) for (n in sort(unique(as.integer(reuse)))) {
          reuse_rows[[length(reuse_rows) + 1L]] <- cbind(prefix,
            data.frame(uses_per_dbf = n, dbf_partners = sum(reuse == n)))
        }
      }
      for (i in seq_len(nrow(cells))) {
        p <- selected[selected$cell_key == cells$key[i], , drop = FALSE]
        c <- eligible[eligible$cell_key == cells$key[i], , drop = FALSE]
        cell_rows[[length(cell_rows) + 1L]] <- data.frame(bundle = bundle, subset = subset,
          cell_key = cells$key[i], cell_x = cells$x[i], cell_y = cells$y[i],
          eligible_enf = sum(c$forest_class == "ENF"), eligible_dbf = sum(c$forest_class == "DBF"),
          matched_enf = nrow(p), unique_dbf = length(unique(p$dbf_id)))
      }
    }
    p <- pairs[[bundle]]
    cell_n <- table(factor(p$cell_key, levels = cells$key))
    # The settings do not attach a pair minimum to the southern warning: count cells
    # with any pair, and report the three-pair count alongside it.
    southern <- sum(cell_n[cells$y < 44] > 0)
    feasibility_rows[[length(feasibility_rows) + 1L]] <- data.frame(
      bundle = bundle, distinct_pairs = nrow(p), pair_target_met = nrow(p) >= 300,
      cells_with_at_least_three_pairs = sum(cell_n >= 3), cell_target_met = sum(cell_n >= 3) >= 30,
      southern_cells_with_pairs = southern, southern_cells_with_at_least_three_pairs = sum(cell_n[cells$y < 44] >= 3),
      southern_review_required = southern < 5,
      review_required = nrow(p) < 300 || sum(cell_n >= 3) < 30 || southern < 5)
  }
  # Losses describe the sequential screens, including boundary exclusions, not independent causes.
  if (nrow(losses)) for (i in seq_len(nrow(regions) + 1L)) {
    if (i <= nrow(regions)) {
      region <- regions[i, ]
      keys <- cells$key[cells$y >= region$south & cells$y < region$north]
      l <- losses[losses$cell_key %in% keys, , drop = FALSE]
      label <- region$region
    } else {
      l <- losses[is.na(losses$cell_key), , drop = FALSE]
      label <- "outside_pipeline_support"
    }
    if (nrow(l)) {
      total <- aggregate(l[c("n_before", "n_after", "n_lost")],
                         l[c("bundle", "forest_class", "screen")], sum)
      total$region <- label
      loss_rows[[length(loss_rows) + 1L]] <- total
    }
  }
  bind <- function(x) if (length(x)) do.call(rbind, x) else data.frame()
  list(structural_coverage = bind(summary_rows), cell_coverage = bind(cell_rows),
       pair_balance = bind(balance_rows),
       dbf_reuse = if (length(reuse_rows)) bind(reuse_rows) else data.frame(
         bundle = character(), subset = character(), region = character(),
         uses_per_dbf = integer(), dbf_partners = integer()),
       wetland_coverage = bind(wetland_rows), screen_losses = bind(loss_rows),
       candidate_support = bind(support_rows), feasibility = bind(feasibility_rows))
}

# Select bands before extracting: the raster's sum bands never enter R.
northeast_read_counts <- function(file, pixels, layers) {
  if (any(!grepl("^(full_75|any_75|full_70)_n_(all|free|snow)$", layers)))
    stop("The coverage reader accepts count layers only")
  raster <- terra::rast(file)
  if (!all(layers %in% names(raster))) stop("Missing retrieval count layers in ", file)
  as.data.frame(terra::extract(raster[[layers]], pixels))
}

# A missing or zero denominator never passes a balance rule.
northeast_count_ratio <- function(enf, dbf) {
  ratio <- pmin(enf, dbf) / pmax(enf, dbf)
  ratio[!is.finite(ratio) | enf < 0 | dbf < 0] <- NA_real_
  ratio
}

# The count and display settings are frozen too, even though no contrast is read.
northeast_retrieval_settings = function() {
  data.frame(bundle = c('main', 'stricter', 'looser'), minimum_days = c(5, 8, 3),
             all_ratio = c(0.7, 0.8, 0.5), own_panel_ratio = c(NA, 0.7, NA),
             cell_year_pairs = c(1, 3, 1), display_pairs = c(30, 50, 10), display_cells = c(3, 5, 2))
}

# Apply the frozen count rules to a panel, without touching or changing partner IDs.
northeast_count_eligibility <- function(enf_all, dbf_all, enf_panel, dbf_panel, bundle, cell_key) {
  settings <- northeast_retrieval_settings()
  setting <- settings[settings$bundle == bundle, ]
  all_ratio <- northeast_count_ratio(enf_all, dbf_all)
  panel_ratio <- northeast_count_ratio(enf_panel, dbf_panel)
  balanced <- is.finite(all_ratio) & enf_all > 0 & dbf_all > 0 & all_ratio >= setting$all_ratio
  if (!is.na(setting$own_panel_ratio)) balanced <- balanced & is.finite(panel_ratio) & panel_ratio >= setting$own_panel_ratio
  eligible <- balanced & is.finite(enf_panel) & is.finite(dbf_panel) &
    enf_panel >= setting$minimum_days & dbf_panel >= setting$minimum_days
  eligible[is.na(eligible)] <- FALSE
  before_cell <- eligible
  if (setting$cell_year_pairs > 1) {
    cell_n <- table(cell_key[eligible])
    eligible <- eligible & cell_key %in% names(cell_n)[cell_n >= setting$cell_year_pairs]
  }
  list(eligible = eligible, before_cell = before_cell, balanced = balanced,
       all_ratio = all_ratio, panel_ratio = panel_ratio)
}

# Summarize counts before and after selection. Missing retrievals stay visible in the denominator.
northeast_count_diagnostic <- function(enf, dbf, panel, selection, keep) {
  all_ratio <- selection$all_ratio[keep]
  own_ratio <- selection$panel_ratio[keep]
  summary <- function(x, prefix) setNames(northeast_number_summary(x),
                                         paste0(prefix, "_", names(northeast_number_summary(x))))
  share <- function(x, part) ifelse(x$n_all > 0, x[[part]] / x$n_all, NA_real_)
  data.frame(pairs = sum(keep), balance_failures = sum(keep & !selection$balanced),
    fraction_failing_balance = if (sum(keep)) mean(!selection$balanced[keep]) else NA_real_,
    pairs_lost_at_minimum_days = sum(keep & selection$balanced & !selection$before_cell),
    pairs_lost_at_cell_year_screen = sum(keep & selection$before_cell & !selection$eligible),
    as.list(c(summary(all_ratio, "all_ratio"), summary(own_ratio, "panel_ratio"),
      summary((dbf$n_all - enf$n_all)[keep], "dbf_minus_enf_all_days"),
      summary(enf[[panel]][keep], "enf_panel_days"), summary(dbf[[panel]][keep], "dbf_panel_days"),
      summary(share(enf, "n_snow")[keep], "enf_snow_share"),
      summary(share(dbf, "n_snow")[keep], "dbf_snow_share"),
      summary((share(dbf, "n_snow") - share(enf, "n_snow"))[keep], "dbf_minus_enf_snow_share"),
      summary((1 - share(enf, "n_snow") - share(enf, "n_free"))[keep], "enf_unknown_share"),
      summary((1 - share(dbf, "n_snow") - share(dbf, "n_free"))[keep], "dbf_unknown_share"))),
    check.names = FALSE)
}

# Count-only coverage over 2001–2009, retaining just nine Boolean masks per pair at a time.
northeast_retrieval_coverage <- function(pairs, candidates, cells, monthly_files,
                                         read_counts = northeast_read_counts) {
  regions <- northeast_coverage_regions()
  years <- 2001:2009
  layers <- as.vector(outer(c("full_75", "any_75", "full_70"),
                            c("n_all", "n_free", "n_snow"), paste, sep = "_"))
  pixels <- do.call(rbind, lapply(candidates, function(x) x[c("id", "tile", "pixel")]))
  pixels <- pixels[!duplicated(pixels$id), , drop = FALSE]
  needed <- unique(unlist(lapply(pairs, function(x) c(x$enf_id, x$dbf_id)), use.names = FALSE))
  pixels <- pixels[match(needed, pixels$id), , drop = FALSE]
  if (anyNA(pixels$id)) stop("A fixed pair refers to a missing candidate")
  files <- monthly_files[monthly_files$tile %in% unique(pixels$tile) & monthly_files$year %in% years, ]
  file_key <- paste(files$tile, files$year, files$month)
  expected <- expand.grid(tile = unique(pixels$tile), year = years, month = 1:12)
  if (anyDuplicated(file_key) || !setequal(file_key, paste(expected$tile, expected$year, expected$month)))
    stop("Retrieval coverage needs exactly 108 monthly files for each paired tile")
  configurations <- list()
  for (bundle in names(pairs)) {
    versions <- c("full_75", "any_75")
    if (bundle == "stricter") versions <- c(versions, "full_70")
    subsets <- northeast_pair_subsets(pairs[[bundle]], bundle)
    for (subset in names(subsets)) for (version in versions) for (panel in c("all", "free", "snow")) {
      configurations[[length(configurations) + 1L]] <- list(bundle = bundle, subset = subset,
        version = version, panel = panel, pairs = subsets[[subset]],
        enf = match(subsets[[subset]]$enf_id, pixels$id), dbf = match(subsets[[subset]]$dbf_id, pixels$id))
    }
  }
  coverage_rows <- diagnostic_rows <- cell_year_rows <- list()
  for (month in 1:12) {
    selected <- lapply(configurations, function(x) matrix(FALSE, nrow(x$pairs), length(years)))
    for (year_index in seq_along(years)) {
      year <- years[year_index]
      counts <- matrix(NA_real_, nrow(pixels), length(layers), dimnames = list(NULL, layers))
      for (tile in unique(pixels$tile)) {
        i <- which(pixels$tile == tile)
        file <- files$file[match(paste(tile, year, month), file_key)]
        v <- read_counts(file, pixels$pixel[i], layers)
        if (!identical(names(v), layers) || nrow(v) != length(i)) stop("Unexpected count-reader result")
        counts[i, ] <- as.matrix(v)
      }
      if (any(is.finite(counts) & (counts < 0 | counts != round(counts)))) stop("Invalid retrieval count")
      for (version in c("full_75", "any_75", "full_70")) {
        total <- counts[, paste0(version, "_n_all")]
        parts <- counts[, paste0(version, "_n_free")] + counts[, paste0(version, "_n_snow")]
        if (any(parts > total, na.rm = TRUE)) stop("Snow counts exceed all-days counts")
      }
      for (j in seq_along(configurations)) {
        cfg <- configurations[[j]]
        columns <- paste0(cfg$version, "_", c("n_all", "n_free", "n_snow"))
        enf <- as.data.frame(counts[cfg$enf, columns, drop = FALSE])
        dbf <- as.data.frame(counts[cfg$dbf, columns, drop = FALSE])
        names(enf) <- names(dbf) <- c("n_all", "n_free", "n_snow")
        panel <- paste0("n_", cfg$panel)
        # The stricter cell-year gate is applied within each diagnostic subset;
        # wetland rows below then describe that eligible sample without rematching.
        selection <- northeast_count_eligibility(enf$n_all, dbf$n_all, enf[[panel]], dbf[[panel]],
                                                 cfg$bundle, cfg$pairs$cell_key)
        selected[[j]][, year_index] <- selection$eligible
        prefix <- data.frame(bundle = cfg$bundle, subset = cfg$subset, version = cfg$version,
                             panel = cfg$panel, month = month, year = year)
        for (stage in c("before", "after")) {
          keep <- if (stage == "before") rep(TRUE, nrow(cfg$pairs)) else selection$eligible
          diagnostic_rows[[length(diagnostic_rows) + 1L]] <- cbind(prefix, stage = stage,
            northeast_count_diagnostic(enf, dbf, panel, selection, keep))
        }
        # Include zero-pair cells so a missing cell-year cannot be mistaken for absence from the domain.
        cell_n <- table(factor(cfg$pairs$cell_key[selection$eligible], levels = cells$key))
        cell_year_rows[[length(cell_year_rows) + 1L]] <- cbind(prefix,
          data.frame(cell_key = cells$key, cell_x = cells$x, cell_y = cells$y,
                     eligible_pairs = as.integer(cell_n)))
      }
    }
    for (j in seq_along(configurations)) {
      cfg <- configurations[[j]]
      settings <- northeast_retrieval_settings()
      thresholds <- settings[settings$bundle == cfg$bundle, c('display_pairs', 'display_cells')]
      for (i in seq_len(nrow(regions))) {
        region <- regions[i, ]
        keys <- cells$key[cells$y >= region$south & cells$y < region$north]
        for (wetland in c("all", "neither", "one", "both", "unknown")) {
          keep <- cfg$pairs$cell_key %in% keys
          if (wetland != "all") keep <- keep & cfg$pairs$wetland_stratum == wetland
          eligible <- selected[[j]][keep, , drop = FALSE]
          p <- cfg$pairs[keep, , drop = FALSE]
          represented <- rowSums(eligible) > 0
          n_pairs <- sum(represented)
          n_cells <- length(unique(p$cell_key[represented]))
          years_used <- years[colSums(eligible) > 0]
          coverage_rows[[length(coverage_rows) + 1L]] <- data.frame(bundle = cfg$bundle,
            subset = cfg$subset, version = cfg$version, panel = cfg$panel, month = month,
            region = region$region, wetland_stratum = wetland, distinct_pairs = n_pairs,
            unique_dbf = length(unique(p$dbf_id[represented])), cells_with_pairs = n_cells,
            cells_without_pairs = length(keys) - n_cells, pair_years = sum(eligible),
            years = length(years_used), years_present = paste(years_used, collapse = ";"),
            years_missing = paste(setdiff(years, years_used), collapse = ";"),
            coverage = if (n_pairs >= thresholds$display_pairs && n_cells >= thresholds$display_cells) "coverage threshold met" else "thin")
        }
      }
    }
  }
  list(retrieval_coverage = do.call(rbind, coverage_rows),
       retrieval_diagnostics = do.call(rbind, diagnostic_rows),
       retrieval_cell_year = do.call(rbind, cell_year_rows))
}
