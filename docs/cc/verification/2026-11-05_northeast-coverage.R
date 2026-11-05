# Draft for issue #27. Replace TO_FILL with the full final commit before running
# tools/verify_change.R. This spec is not evidence of a completed coverage run.
# Checks run in order so the shared-input snapshot precedes the coverage driver.
# The driver is a check here; coverage_manifest() supplies the completed-record and
# output-hash gate normally supplied by verify_change.R for entries in scripts.
# Nearest partners are independently sampled, including bin and tile boundaries;
# retrieval coverage is independently reconstructed for January, July and December,
# across all nine years. The remaining months receive the driver's checks only.

coverage_context = function() {
  suppressPackageStartupMessages(library(terra))
  source('R/run_manifest.R')
  source('R/modis_albedo_helpers.R')
  source('R/northeast_forest_albedo.R')
  directory = '.rundirs/northeast-coverage'
  paths = pipeline_paths(load_config(file.path(directory, 'config_used.R')))
  cache = path_file(paths, 'elevation_cache')
  cells = unique(readRDS(cache)[, c('x', 'y')])
  cells = cells[cells$x >= -80 & cells$x < -66 & cells$y >= 40 & cells$y < 48, ]
  cells = cells[order(cells$y, cells$x), ]
  cells$key = paste(cells$x, cells$y)
  tiles = c('h11v04', 'h12v04', 'h13v04')
  inputs = northeast_inputs('/home/expert/Documents/contracting/Andria/paleo-RF/data', tiles, 2001:2009)
  list(directory = directory, output = file.path(directory, 'output/northeast_forest_albedo'),
       records = file.path(directory, 'runs/check_northeast_forest_albedo'),
       cache = cache, cells = cells, tiles = tiles, inputs = inputs)
}

coverage_inventory = function(context) {
  inputs = context$inputs
  files = c(inputs$land_cover$file, inputs$acquisition, inputs$monthly$file, inputs$water,
            list.files(inputs$dem, full.names = TRUE), context$cache)
  info = file.info(files)
  stopifnot(!anyNA(info$size), !any(info$isdir))
  data.frame(file = files, bytes = info$size, modified = as.character(info$mtime))
}

coverage_parse = function() {
  files = c('R/modis_albedo_helpers.R', 'R/northeast_forest_albedo.R',
            'tools/prepare_bluesky_albedo.R', 'tools/check_northeast_forest_albedo.R',
            'tests/test_modis_albedo_helpers.R', 'tests/test_bluesky_albedo.R',
            'tests/test_northeast_forest_albedo.R', 'tests/test_northeast_forest_coverage.R',
            'docs/cc/verification/2026-11-05_northeast-coverage.R')
  for (file in files) parse(file)
  cat('Parsed', length(files), 'files\n')
}

coverage_inputs = function() {
  context = coverage_context()
  inputs = context$inputs
  stopifnot(nrow(context$cells) == 83L, !anyDuplicated(context$cells$key),
            all(context$cells$x %% 1 == 0.5), all(context$cells$y %% 1 == 0.5),
            nrow(inputs$land_cover) == 27L, nrow(inputs$monthly) == 354L,
            all(table(inputs$land_cover$tile) == 9L), all(table(inputs$monthly$tile) == 118L))
  template = northeast_check_grids(inputs, context$tiles)
  # Each classification subdataset must agree, including the normalized HDF CRS.
  for (i in seq_len(nrow(inputs$land_cover))) {
    raster = terra::rast(inputs$land_cover$file[i])
    for (layer in c('LC_Type1', 'QC', 'LC_Prop3'))
      stopifnot(terra::compareGeom(raster[[layer]], tile_template(inputs$land_cover$tile[i]),
                                  stopOnError = FALSE))
  }
  dem = terra::rast(inputs$dem)
  # Published native 30-arc-second mean grid, including its half-arc-second offset.
  # Danielson & Gesch (2011), table 3; DOI 10.3133/ofr20111073.
  stopifnot(terra::is.lonlat(dem), nrow(dem) == 20880L, ncol(dem) == 43200L,
            max(abs(terra::res(dem) - 1 / 120)) < 1e-8,
            max(abs(as.vector(terra::ext(dem)) - c(-180, 180, -90, 84) + 1 / 7200)) < 2e-6)
  metadata = northeast_monthly_metadata(inputs$monthly$file)
  preparation = new.env()
  source('tools/prepare_bluesky_albedo.R', local = preparation)
  stopifnot(all(metadata$paleoRF_script_sha256 %in%
                  c(preparation$SCRIPT_SHA, preparation$ACCEPTED_OLDER_SHAS)))
  # Header-only check: historical files need no separate helper tag; no rebuild.
  historic = inputs$monthly$file[metadata$paleoRF_script_sha256 %in% preparation$ACCEPTED_OLDER_SHAS]
  cat('Approved historical monthly headers:', length(historic), '\n')
  snapshot = list(started = Sys.time(), files = coverage_inventory(context), monthly = metadata,
                  small_md5 = tools::md5sum(c(inputs$acquisition, context$cache)),
                  dem_extent = as.vector(terra::ext(dem)), dem_resolution = terra::res(dem))
  saveRDS(snapshot, file.path(context$directory, 'verification_inputs_before.rds'))
  cat('Verified 27 granules, 354 monthly grids, water alignment, native GMTED and 83 cells\n')
}

# All-to-all comparison for selected centres, deliberately without the production
# geographic bins, distance helper or nearest/pair functions.
coverage_nearest = function(centre, targets, radius, elevation) {
  eligible = which(abs(targets$elevation - centre$elevation) <= elevation)
  if (!length(eligible)) return(list(id = NA_character_, distance = NA_real_))
  lat1 = centre$lat * pi / 180
  lat2 = targets$lat[eligible] * pi / 180
  dlon = (targets$lon[eligible] - centre$lon) * pi / 180
  haversine = sin((lat2 - lat1) / 2)^2 + cos(lat1) * cos(lat2) * sin(dlon / 2)^2
  distance = 2 * 6371007.181 * atan2(sqrt(pmin(1, haversine)), sqrt(pmax(0, 1 - haversine)))
  keep = which(distance <= radius)
  if (!length(keep)) return(list(id = NA_character_, distance = NA_real_))
  best = keep[order(distance[keep], targets$id[eligible[keep]], method = 'radix')[1]]
  list(id = targets$id[eligible[best]], distance = distance[best])
}

coverage_pairs = function() {
  context = coverage_context()
  candidates = readRDS(file.path(context$output, 'eligible_candidates.rds'))
  pairs = readRDS(file.path(context$output, 'fixed_pairs.rds'))
  radius = c(main = 5000, stricter = 3000, looser = 10000)
  elevation = c(main = 50, stricter = 25, looser = 100)
  relief = c(main = 100, stricter = 50, looser = 200)
  stopifnot(setequal(names(pairs), names(radius)), setequal(names(candidates), names(radius)))
  for (bundle in names(pairs)) {
    candidate = candidates[[bundle]]
    pair = pairs[[bundle]]
    stopifnot(!anyDuplicated(candidate$id), !anyDuplicated(pair$enf_id),
              all(candidate$relief <= relief[bundle]),
              all(pair$distance_m <= radius[bundle]), all(pair$elevation_difference_m <= elevation[bundle]))
    # Decode every retained ID to its native centre and independently transform by PROJ.
    for (tile in unique(candidate$tile)) {
      selected = candidate[candidate$tile == tile, ]
      decoded = as.integer(sub('^h[0-9]{2}v[0-9]{2}_', '', selected$id))
      stopifnot(all(substr(selected$id, 1, 6) == tile), identical(decoded, as.integer(selected$pixel)),
                all(decoded >= 1L & decoded <= 2400L^2))
      # Bound the additional PROJ objects even when a tile has many candidates.
      for (first in seq(1L, nrow(selected), by = 50000L)) {
        at = first:min(nrow(selected), first + 49999L)
        native = terra::xyFromCell(tile_template(tile), decoded[at])
        projected = terra::crds(terra::project(terra::vect(native, crs = SIN_CRS), 'EPSG:4326'))
        stopifnot(max(abs(projected - as.matrix(selected[at, c('lon', 'lat')]))) < 1e-9)
      }
    }
    enf = candidate[candidate$forest_class == 'ENF' & candidate$in_domain, ]
    dbf = candidate[candidate$forest_class == 'DBF', ]
    a = enf[match(pair$enf_id, enf$id), ]; b = dbf[match(pair$dbf_id, dbf$id), ]
    stopifnot(!anyNA(a$id), !anyNA(b$id), all(pair$cell_key == a$cell_key),
              all(pair$elevation_difference_m == abs(a$elevation - b$elevation)))
    wetland = ifelse(is.na(a$wetland) | is.na(b$wetland), 'unknown',
                     c('neither', 'one', 'both')[1 + a$wetland + b$wetland])
    stopifnot(identical(pair$wetland_stratum, wetland),
              identical(pair$unflagged3, a$wetland3 %in% FALSE & b$wetland3 %in% FALSE),
              all(pair$wetland_stratum[pair$unflagged3] == 'neither'))
    if (!nrow(enf)) next
    # Fixed ID-order sample, plus centres nearest a 0.1-degree bin boundary and
    # each tile join. Cross-tile pairs are explicitly included when present.
    bin_gap = pmin(abs(enf$lon * 10 - round(enf$lon * 10)),
                   abs(enf$lat * 10 - round(enf$lat * 10)))
    native_x = 6371007.181 * enf$lon * pi / 180 * cos(enf$lat * pi / 180)
    joins = vapply(context$tiles[-1], function(tile) terra::xmin(tile_template(tile)), 0)
    sample = unique(c(round(seq(1, nrow(enf), length.out = min(12, nrow(enf)))),
                      head(order(bin_gap, enf$id), 8),
                      unlist(lapply(joins, function(join) head(order(abs(native_x - join), enf$id), 8))),
                      head(match(pair$enf_id[a$tile != b$tile], enf$id), 8)))
    for (i in sample) {
      nearest = coverage_nearest(enf[i, ], dbf, radius[bundle], elevation[bundle])
      at = match(enf$id[i], pair$enf_id)
      stopifnot(identical(nearest$id, if (is.na(at)) NA_character_ else pair$dbf_id[at]))
      if (is.na(at)) next
      stopifnot(abs(nearest$distance - pair$distance_m[at]) < 1e-6)
      partner = dbf[match(nearest$id, dbf$id), ]
      reverse = coverage_nearest(partner, enf, radius[bundle], elevation[bundle])
      stopifnot(identical(pair$reciprocal[at], reverse$id == enf$id[i]))
    }
    cat(bundle, ': independently checked', length(sample), 'ENFs; cross-tile pairs available:',
        sum(a$tile != b$tile), '\n')
  }
}

coverage_losses = function() {
  context = coverage_context()
  losses = read.csv(file.path(context$output, 'screen_losses_cell.csv'))
  candidates = readRDS(file.path(context$output, 'eligible_candidates.rds'))
  pairs = readRDS(file.path(context$output, 'fixed_pairs.rds'))
  stopifnot(all(losses$n_before == losses$n_after + losses$n_lost),
            all(losses$n_before >= 0), all(losses$n_after >= 0), all(losses$n_lost >= 0))
  losses$cell_key[is.na(losses$cell_key)] = 'outside'
  totals = aggregate(losses[c('n_before', 'n_after', 'n_lost')],
                      losses[c('bundle', 'cell_key', 'forest_class', 'screen')], sum)
  stages = c('enf_scope', 'stable_centre', 'classification_qc', 'neighbourhood_boundary',
             'same_class_neighbourhood', 'water', 'valid_terrain', 'relief', 'search_boundary', 'record_wide_land')
  boundary = totals[totals$screen == 'search_boundary' & totals$n_lost > 0, ]
  stopifnot(all(boundary$forest_class == 'ENF'),
            all(context$cells$y[match(boundary$cell_key, context$cells$key)] == 40.5))
  for (bundle in names(pairs)) for (key in unique(totals$cell_key[totals$bundle == bundle])) {
    rows = totals[totals$bundle == bundle & totals$cell_key == key, ]
    class_after = sum(rows$n_after[rows$forest_class == 'all' & rows$screen == 'forest_class'])
    scope_before = sum(rows$n_before[rows$forest_class %in% c('ENF', 'DBF') & rows$screen == 'enf_scope'])
    stopifnot(class_after == scope_before)
    for (forest in c('ENF', 'DBF')) {
      own = rows[rows$forest_class == forest, ]
      previous = sum(own$n_before[own$screen == 'enf_scope'])
      for (stage in stages) {
        selected = own[own$screen == stage, ]
        stopifnot(sum(selected$n_before) == previous)
        previous = sum(selected$n_after)
      }
      candidate = candidates[[bundle]]
      candidate_key = ifelse(candidate$in_domain, candidate$cell_key, 'outside')
      stopifnot(previous == sum(candidate$forest_class == forest & candidate_key == key))
      if (forest == 'ENF') {
        partner = own[own$screen == 'partner_within_distance_and_elevation', ]
        matched = sum(pairs[[bundle]]$cell_key == key)
        stopifnot(sum(partner$n_before) == previous, sum(partner$n_after) == matched,
                  matched + sum(partner$n_lost) == previous)
      }
    }
  }
  cat('Cell/class losses telescope, including all-class, scope and partner screens\n')
}

coverage_structural = function() {
  context = coverage_context()
  cells = context$cells
  pairs = readRDS(file.path(context$output, 'fixed_pairs.rds'))
  candidates = readRDS(file.path(context$output, 'eligible_candidates.rds'))
  structural = read.csv(file.path(context$output, 'structural_coverage.csv'))
  cell_rows = read.csv(file.path(context$output, 'cell_coverage.csv'))
  feasibility = read.csv(file.path(context$output, 'feasibility.csv'))
  regions = data.frame(region = c('all', paste0(40:47, '-', 41:48, 'N'), '40-44N', '44-48N'),
                        south = c(40, 40:47, 40, 44), north = c(48, 41:48, 44, 48))
  for (bundle in names(pairs)) {
    pair = pairs[[bundle]]
    candidate = candidates[[bundle]]
    subsets = list(all = pair)
    if (bundle == 'stricter') subsets = c(subsets,
      list(reciprocal = pair[pair$reciprocal, ], unflagged3 = pair[pair$unflagged3, ]))
    for (subset in names(subsets)) {
      selected = subsets[[subset]]
      counts = as.integer(table(factor(selected$cell_key, levels = cells$key)))
      cell = cell_rows[cell_rows$bundle == bundle & cell_rows$subset == subset, ]
      stopifnot(nrow(cell) == 83L, !anyDuplicated(cell$cell_key), setequal(cell$cell_key, cells$key),
                identical(as.integer(cell$matched_enf[match(cells$key, cell$cell_key)]), counts))
      for (i in seq_len(nrow(regions))) {
        keys = cells$key[cells$y >= regions$south[i] & cells$y < regions$north[i]]
        selected_region = selected[selected$cell_key %in% keys, ]
        eligible = candidate[candidate$in_domain & candidate$cell_key %in% keys, ]
        row = structural[structural$bundle == bundle & structural$subset == subset &
                           structural$region == regions$region[i], ]
        reuse = table(selected_region$dbf_id)
        n = as.integer(table(factor(selected_region$cell_key, levels = keys)))
        stopifnot(nrow(row) == 1L, row$matched_enf == nrow(selected_region),
                  row$eligible_enf == sum(eligible$forest_class == 'ENF'),
                  row$eligible_dbf == sum(eligible$forest_class == 'DBF'),
                  row$unique_dbf == length(reuse), row$reused_dbf == sum(reuse > 1),
                  row$max_dbf_use == if (length(reuse)) max(reuse) else 0,
                  row$pipeline_cells == length(keys), row$cells_with_pairs == sum(n > 0),
                  row$cells_without_pairs == sum(n == 0), row$cells_with_at_least_three_pairs == sum(n >= 3))
      }
    }
    n = as.integer(table(factor(pair$cell_key, levels = cells$key)))
    south = sum(n[cells$y < 44] > 0)
    row = feasibility[feasibility$bundle == bundle, ]
    stopifnot(nrow(row) == 1L, row$distinct_pairs == nrow(pair), row$pair_target_met == (nrow(pair) >= 300),
              row$cells_with_at_least_three_pairs == sum(n >= 3), row$cell_target_met == (sum(n >= 3) >= 30),
              row$southern_cells_with_pairs == south,
              row$southern_cells_with_at_least_three_pairs == sum(n[cells$y < 44] >= 3),
              row$southern_review_required == (south < 5),
              row$review_required == (nrow(pair) < 300 || sum(n >= 3) < 30 || south < 5))
  }
  cat('Recomputed regional coverage, zero-pair cells, DBF reuse and feasibility flags\n')
}

coverage_counts = function() {
  context = coverage_context()
  pair_file = file.path(context$output, 'fixed_pairs.rds')
  pairs = readRDS(pair_file)
  digest = unname(tools::md5sum(pair_file))
  candidates = readRDS(file.path(context$output, 'eligible_candidates.rds'))
  reported = read.csv(file.path(context$output, 'retrieval_coverage.csv'),
                       colClasses = c(years_present = 'character', years_missing = 'character'))
  pixels = unique(do.call(rbind, lapply(candidates, function(x) x[c('id', 'tile', 'pixel')])))
  needed = unique(unlist(lapply(pairs, function(x) c(x$enf_id, x$dbf_id))))
  pixels = pixels[match(needed, pixels$id), ]
  layers = as.vector(outer(c('full_75', 'any_75', 'full_70'), c('n_all', 'n_free', 'n_snow'), paste, sep = '_'))
  years = 2001:2009
  for (month in c(1L, 7L, 12L)) {
    counts = lapply(years, function(year) {
      values = matrix(NA_real_, nrow(pixels), length(layers), dimnames = list(NULL, layers))
      for (tile in unique(pixels$tile)) {
        at = which(pixels$tile == tile)
        catalog = context$inputs$monthly
        file = catalog$file[catalog$tile == tile & catalog$year == year & catalog$month == month]
        stopifnot(length(file) == 1L)
        raster = terra::rast(file)[[layers]]
        values[at, ] = as.matrix(terra::extract(raster, pixels$pixel[at]))
      }
      values
    })
    for (bundle in names(pairs)) {
      pair = pairs[[bundle]]
      subsets = list(all = pair)
      if (bundle == 'stricter') subsets = c(subsets,
        list(reciprocal = pair[pair$reciprocal, ], unflagged3 = pair[pair$unflagged3, ]))
      minimum = c(main = 5, stricter = 8, looser = 3)[bundle]
      ratio = c(main = 0.7, stricter = 0.8, looser = 0.5)[bundle]
      for (subset in names(subsets)) for (version in if (bundle == 'stricter')
          c('full_75', 'any_75', 'full_70') else c('full_75', 'any_75')) for (panel in c('all', 'free', 'snow')) {
        selected = subsets[[subset]]
        eligible = matrix(FALSE, nrow(selected), length(years))
        for (j in seq_along(years)) {
          enf = counts[[j]][match(selected$enf_id, pixels$id), , drop = FALSE]
          dbf = counts[[j]][match(selected$dbf_id, pixels$id), , drop = FALSE]
          all_enf = enf[, paste0(version, '_n_all')]; all_dbf = dbf[, paste0(version, '_n_all')]
          own_enf = enf[, paste0(version, '_n_', panel)]; own_dbf = dbf[, paste0(version, '_n_', panel)]
          keep = is.finite(all_enf) & is.finite(all_dbf) & all_enf > 0 & all_dbf > 0 &
            pmin(all_enf, all_dbf) / pmax(all_enf, all_dbf) >= ratio &
            is.finite(own_enf) & is.finite(own_dbf) & own_enf >= minimum & own_dbf >= minimum
          if (bundle == 'stricter') keep = keep & pmin(own_enf, own_dbf) / pmax(own_enf, own_dbf) >= 0.7
          keep[is.na(keep)] = FALSE
          if (bundle == 'stricter') {
            n = table(selected$cell_key[keep])
            keep = keep & selected$cell_key %in% names(n)[n >= 3]
          }
          eligible[, j] = keep
        }
        rows = reported[reported$bundle == bundle & reported$subset == subset & reported$month == month &
                          reported$version == version & reported$panel == panel, ]
        stopifnot(nrow(rows) == 55L)
        for (i in seq_len(nrow(rows))) {
          row = rows[i, ]
          limits = if (row$region == 'all') c(40, 48) else as.numeric(strsplit(sub('N$', '', row$region), '-')[[1]])
          keys = context$cells$key[context$cells$y >= limits[1] & context$cells$y < limits[2]]
          keep = selected$cell_key %in% keys
          if (row$wetland_stratum != 'all') keep = keep & selected$wetland_stratum == row$wetland_stratum
          used = eligible[keep, , drop = FALSE]; selected_region = selected[keep, ]
          represented = rowSums(used) > 0
          n_pairs = sum(represented); n_cells = length(unique(selected_region$cell_key[represented]))
          present = years[colSums(used) > 0]
          threshold = n_pairs >= c(main = 30, stricter = 50, looser = 10)[bundle] &
            n_cells >= c(main = 3, stricter = 5, looser = 2)[bundle]
          stopifnot(row$distinct_pairs == n_pairs, row$unique_dbf == length(unique(selected_region$dbf_id[represented])),
                    row$cells_with_pairs == n_cells, row$cells_without_pairs == length(keys) - n_cells,
                    row$pair_years == sum(used), row$years == length(present),
                    row$years_present == paste(present, collapse = ';'),
                    row$years_missing == paste(setdiff(years, present), collapse = ';'),
                    row$coverage == if (threshold) 'coverage threshold met' else 'thin')
        }
      }
    }
  }
  stopifnot(identical(readRDS(pair_file), pairs), identical(unname(tools::md5sum(pair_file)), digest))
  cat('Independently checked January, July and December counts, all nine years; fixed pairs unchanged\n')
}

coverage_manifest = function() {
  context = coverage_context()
  snapshot = readRDS(file.path(context$directory, 'verification_inputs_before.rds'))
  dem = terra::rast(context$inputs$dem)
  stopifnot(identical(coverage_inventory(context), snapshot$files),
            identical(tools::md5sum(names(snapshot$small_md5)), snapshot$small_md5),
            identical(northeast_monthly_metadata(context$inputs$monthly$file), snapshot$monthly),
            identical(as.vector(terra::ext(dem)), snapshot$dem_extent),
            identical(terra::res(dem), snapshot$dem_resolution))
  files = list.files(context$records, pattern = '[.]md$', full.names = TRUE)
  stopifnot(length(files) == 1L, file.mtime(files) >= snapshot$started)
  record = read_manifest(files)
  stopifnot(identical(record$status, 'completed'), identical(record$script, 'check_northeast_forest_albedo'),
            !isTRUE(record$code$dirty), length(record$outputs) > 0L,
            any(vapply(record$inputs, function(input) identical(input$path, context$cache) &&
              identical(input$md5, unname(tools::md5sum(context$cache))), TRUE)))
  for (output in record$outputs)
    stopifnot(file.exists(output$path), identical(unname(tools::md5sum(output$path)), output$md5))
  pair_file = file.path(context$output, 'fixed_pairs.rds')
  stopifnot(identical(unname(tools::md5sum(pair_file)), record$details$fixed_pair_md5),
            identical(read.csv(file.path(context$records, 'inputs.csv'),
                               colClasses = c(file = 'character', bytes = 'numeric', modified = 'character')),
                      snapshot$files),
            !file.exists(file.path(context$output, 'retrieval_diagnostics.csv')),
            !file.exists(file.path(context$output, 'retrieval_cell_year.csv')))
  cat('Completed manifest, recorded output hashes, elevation provenance and input metadata verified\n')
  cat('Input preservation uses size/mtime for large rasters, not payload hashes.\n')
  cat('Return feasibility.csv and structural/retrieval coverage to Chris before stage 2.\n')
  cat('A software PASS does not mean the scientific feasibility targets were met.\n')
}

coverage_check = function(function_name) {
  c('-e', paste0("source('docs/cc/verification/2026-11-05_northeast-coverage.R'); ", function_name, '()'))
}

list(
  name = 'northeast-coverage',
  commit = 'TO_FILL',
  config = 'config.R',
  scripts = character(),
  checks = list(
    coverage_check('coverage_parse'),
    'tests/test_modis_albedo_helpers.R',
    'tests/test_bluesky_albedo.R',
    'tests/test_northeast_forest_albedo.R',
    'tests/test_northeast_forest_coverage.R',
    coverage_check('coverage_inputs'),
    c('tools/check_northeast_forest_albedo.R', '--config', '.rundirs/northeast-coverage/config_used.R'),
    coverage_check('coverage_pairs'),
    coverage_check('coverage_losses'),
    coverage_check('coverage_structural'),
    coverage_check('coverage_counts'),
    coverage_check('coverage_manifest')),
  rscript = 'tools/rscript.sh',
  env = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1'))
