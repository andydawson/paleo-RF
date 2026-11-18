# build_nadi1_fractions.R: the share of each 1-degree cell under ice at every time slice, from
# the NADI-1 reconstruction of the North American ice sheets (Dalton et al. 2023), on the grid
# of the ice raster the pipeline has used so far. Run once, from the repository root:
#
#   Rscript tools/build_nadi1_fractions.R [folder holding the NADI-1 shapefiles]
#
# The folder defaults to data/nadi1/shapefiles/NADI-1 shapefiles Dalton et al. QSR, where the
# download is unpacked (not in git; data/nadi1/PROVENANCE.txt records how it was obtained). It
# writes into data/nadi1_fractions/, committed:
#   nadi1_optimal.tif, nadi1_minimum.tif, nadi1_maximum.tif   one file per reconstruction
#   nadi1_fractions_provenance.txt                            sources, settings, checks, checksums
# Script 7a reads one of the three when config.R's analysis$ice$fraction_source names it.
#
# Why (Chris, 16 November 2026): to compare the 2023 reconstruction with the old ice raster by
# one setting, with everything else in the pipeline unchanged (docs/cc/2026-11-17_ice_work_decisions.md;
# design: docs/cc/2026-11-16_ice_redesign_simpler_codex_gpt6astra.md, section 2).
#
# Source: Dalton, A. S., et al. (2023). Deglaciation of the North American Ice Sheet Complex in
# calendar years based on a comprehensive database of chronological data: NADI-1. Quaternary
# Science Reviews 321, 108345, doi:10.1016/j.quascirev.2023.108345; the data set "North American
# Deglacial Isochrones, version 1", Zenodo doi:10.5281/zenodo.8161764 (CC-BY-4.0): ice-margin
# polygons every 500 years from 25 to 1 ka, in calendar years, each as an optimal, a minimum and
# a maximum extent. The minimum and maximum bracket where the margin could have been; they are
# not confidence limits (Dalton et al. 2023, sections 2.6 and 4).
#
# What it does, for each reconstruction and slice:
#   - the slices 1,000 to 11,500 BP take the NADI-1 snapshot of the same age (22 ages, no
#     interpolation); 500, 200 and 50 BP take the 1,000 BP fractions, as the old raster does
#     (Chris, 16 November 2026), since NADI-1 stops at 1 ka;
#   - the snapshot's polygons are taken as the file draws them, with straight edges in longitude
#     and latitude; rings the file leaves open are closed (three, of which one at 8.5 ka minimum
#     with a gap of 0.34 degrees), invalid polygons are repaired (sf::st_make_valid(), which
#     keeps holes) and all are merged into one ice area, so that overlaps count once;
#   - a cell's fraction is the area of the cell under ice over the cell's whole area (sea
#     included, as the forcing uses it), both measured in one equal-area projection after every
#     edge is cut into pieces of at most EDGE_STEP degrees, so that the edges stay straight in
#     longitude and latitude. Summed over the cells, fraction x cell area is then the ice area
#     inside the grid: the fractions conserve area (Taylor 2024, Geosci. Model Dev. 17, 415-430,
#     doi:10.5194/gmd-17-415-2024, section 2), with the cell areas of this projection, on the
#     WGS84 ellipsoid. Script 7a weights cells by their area on a sphere (sf's s2 engine), so ice
#     totals made with its weights come out 0.5 to 0.8% smaller over the whole mask (checked 18
#     November 2026); conservation holds within this tool's convention, not exactly under 7a's;
#   - the grid, its extent and its missing cells are the old raster's
#     (data/Dalton_QSR_2020_Ice/dalton_interpolated_LC6k.tif: 116 x 62 one-degree cells, 2,866
#     with values), so the pipeline keeps exactly its cells; 25 bands named as there, yr11500bp
#     ... yr50bp (the old raster's unused 12,000 BP band is not made).
# Why an equal-area projection and not the sphere of sf's s2 engine, which script 7a uses for
# its cell areas (and which the design proposed): s2 takes every edge as a great circle rather
# than the straight line the file draws, so some NADI-1 polygons cross themselves on the sphere,
# and it turns one (8.5 ka minimum) inside out even after repair, which would cover the whole
# grid with ice. In the other 65 snapshots the two give fractions within 0.0008 of each other
# (checked 17 November 2026). Measured in the projection, the merged ice area is within 0.01% of
# the data set's own total (the sum of its Area_Km2 attribute) in 58 of the 66 snapshots; in the
# others the polygons overlap (6 ka optimal) or the attribute does not match its polygon. The
# provenance note lists both for every snapshot.
# Fractions are rounded to 12 decimals: a cell wholly under ice otherwise comes out a few 1e-15
# away from 1.
#
# Checks (the tool stops if one fails): every fraction within 0 to 1; the band names; the old
# raster's grid and missing cells in every band; the same prediction cells get a value as from
# the old raster; 500, 200 and 50 BP equal 1,000 BP; area conserved for every snapshot. Whether
# minimum <= optimal <= maximum in every cell is checked and the exceptions are reported in the
# provenance note, not repaired. tests/test_build_nadi1_fractions.R checks the geometry on
# small hand-made cases.

library(sf)
library(terra)

NADI_DIR        = 'data/nadi1/shapefiles/NADI-1 shapefiles Dalton et al. QSR'
TEMPLATE_FILE   = 'data/Dalton_QSR_2020_Ice/dalton_interpolated_LC6k.tif'
CENTRES_FILE    = 'data/elev_interp_cells.RDS'   # the centres of the cells the pipeline predicts for
OUT_DIR         = 'data/nadi1_fractions'
RECONSTRUCTIONS = c(optimal = 'OPTIMAL', minimum = 'MIN', maximum = 'MAX')   # as in the file names
SNAPSHOT_AGES   = seq(11500, 1000, by = -500)    # years BP: NADI-1 snapshots of the same age
CARRIED_FORWARD = c(500, 200, 50)                # younger than NADI-1: the 1,000 BP fractions
SLICES          = c(SNAPSHOT_AGES, CARRIED_FORWARD)
BANDS           = paste0('yr', SLICES, 'bp')     # oldest first, as in the old raster
EQUAL_AREA      = 'EPSG:6931'   # Lambert azimuthal equal-area on the WGS84 ellipsoid (NSIDC EASE-Grid 2.0 North)
EDGE_STEP       = 0.01          # degrees: the longest edge piece before projecting
DECIMALS        = 12
TOLERANCE       = 1e-9          # for comparing areas and fractions

# Polygons in longitude and latitude (no coordinate system: the plane in which the file draws
# them), their edges cut into pieces of at most EDGE_STEP degrees, projected to EQUAL_AREA.
to_equal_area = function(lonlat) st_transform(st_set_crs(st_segmentize(lonlat, EDGE_STEP), 4326), EQUAL_AREA)

# Rings whose last point is not their first, closed: polygon rings are closed by definition,
# and GEOS cannot read an open one. Returns the geometry with the number closed as an attribute.
close_rings = function(geometry) {
  closed = 0
  close = function(ring) {
    if (all(ring[1, ] == ring[nrow(ring), ])) return(ring)
    closed <<- closed + 1
    rbind(ring, ring[1, ])
  }
  out = st_sfc(lapply(geometry, function(p) {
    if (inherits(p, 'MULTIPOLYGON')) st_multipolygon(lapply(p, function(polygon) lapply(polygon, close)))
    else st_polygon(lapply(p, close))
  }), crs = st_crs(geometry))
  attr(out, 'rings_closed') = closed
  out
}

# The cells of the old raster that have a value, with their raster cell numbers, as polygons in
# EQUAL_AREA, and their areas (m2).
grid_cells = function(template) {
  cell = which(!is.na(values(template)[, 1]))
  centre = xyFromCell(template, cell)
  half = res(template) / 2
  polygons = lapply(seq_along(cell), function(i) {
    x = centre[i, 1] + c(-1, 1, 1, -1, -1) * half[1]
    y = centre[i, 2] + c(-1, -1, 1, 1, -1) * half[2]
    st_polygon(list(cbind(x, y)))
  })
  geometry = to_equal_area(st_sfc(polygons))
  st_sf(cell = cell, area = as.numeric(st_area(geometry)), geometry = geometry)
}

# The NADI-1 shapefile of one age and reconstruction.
snapshot_file = function(age, reconstruction, nadi_dir = NADI_DIR)
  file.path(nadi_dir, sprintf('%ska_cal_%s_NADI-1_Dalton_etal_QSR.shp', format(age / 1000), reconstruction))

# The ice of one snapshot as one geometry in EQUAL_AREA, with what was done to it: the rings
# closed, the polygons repaired, and the data set's own total area (Area_Km2), for comparison.
snapshot_ice = function(file) {
  if (!file.exists(file)) stop('missing NADI-1 file: ', file)
  polygons = st_read(file, quiet = TRUE)
  if (!identical(st_crs(polygons)$epsg, 4326L)) stop(file, ': not in WGS84 longitude and latitude')
  drawn = close_rings(st_set_crs(st_geometry(polygons), NA))
  valid = st_is_valid(drawn)
  repaired = st_make_valid(drawn)
  if (!all(st_is_valid(repaired)) || any(st_is_empty(repaired))) stop(file, ': a polygon could not be repaired')
  list(ice = to_equal_area(st_union(repaired)), rings_closed = attr(drawn, 'rings_closed'),
       polygons_repaired = sum(!valid | is.na(valid)), area_attribute_km2 = sum(polygons$Area_Km2))
}

# The fraction of each cell under the ice, and the ice area inside the grid measured directly,
# which the fractions must reproduce (the conservation check).
cell_fractions = function(cells, ice, cells_union) {
  fraction = numeric(nrow(cells))
  touched = lengths(st_intersects(cells$geometry, ice)) > 0
  if (any(touched))
    fraction[touched] = as.numeric(st_area(st_intersection(cells$geometry[touched], ice))) / cells$area[touched]
  list(fraction = round(fraction, DECIMALS),
       ice_area_in_grid = sum(as.numeric(st_area(st_intersection(cells_union, ice)))))
}

# One reconstruction's fractions as a raster on the template's grid, NA where it has no value.
as_fraction_raster = function(fraction, cells, template) {
  all_cells = matrix(NA_real_, ncell(template), ncol(fraction))
  all_cells[cells$cell, ] = fraction
  out = rast(template, nlyrs = ncol(fraction))
  values(out) = all_cells
  names(out) = colnames(fraction)
  out
}

# Cell-slices where `lower` exceeds `upper`: the order of two reconstructions, reported.
order_exceptions = function(lower, upper, test, cells, template) {
  bad = which(lower > upper + TOLERANCE, arr.ind = TRUE)
  centre = xyFromCell(template, cells$cell[bad[, 'row']])
  data.frame(test = rep(test, nrow(bad)), age_bp = SLICES[bad[, 'col']], x = centre[, 1], y = centre[, 2],
             lower = lower[bad], upper = upper[bad])
}

build_nadi1_fractions = function(nadi_dir = NADI_DIR) {
  started = Sys.time()
  template = rast(TEMPLATE_FILE)
  cells = grid_cells(template[[1]])
  cells_union = st_union(cells$geometry)
  cat(sprintf('%d cells with a value in %s\n', nrow(cells), TEMPLATE_FILE))

  # --- the fractions ------------------------------------------------------------------
  fractions = list()
  snapshots = data.frame()
  for (name in names(RECONSTRUCTIONS)) {
    fraction = matrix(NA_real_, nrow(cells), length(SLICES), dimnames = list(NULL, BANDS))
    for (age in SNAPSHOT_AGES) {
      file = snapshot_file(age, RECONSTRUCTIONS[[name]], nadi_dir)
      snapshot = snapshot_ice(file)
      result = cell_fractions(cells, snapshot$ice, cells_union)
      fraction[, paste0('yr', age, 'bp')] = result$fraction
      snapshots = rbind(snapshots, data.frame(
        reconstruction = name, age_bp = age, file = basename(file), shp_md5 = unname(tools::md5sum(file)),
        rings_closed = snapshot$rings_closed, polygons_repaired = snapshot$polygons_repaired,
        area_attribute_km2 = snapshot$area_attribute_km2,
        ice_area_km2 = as.numeric(st_area(snapshot$ice)) / 1e6,
        ice_area_in_grid_km2 = result$ice_area_in_grid / 1e6,
        ice_area_from_fractions_km2 = sum(result$fraction * cells$area) / 1e6))
    }
    for (age in CARRIED_FORWARD) fraction[, paste0('yr', age, 'bp')] = fraction[, 'yr1000bp']
    fractions[[name]] = fraction
    cat(sprintf('%s: %d snapshots, %.1f min so far\n', name, length(SNAPSHOT_AGES), as.numeric(difftime(Sys.time(), started, units = 'mins'))))
  }
  geometry_minutes = as.numeric(difftime(Sys.time(), started, units = 'mins'))

  # --- the files ----------------------------------------------------------------------
  dir.create(OUT_DIR, showWarnings = FALSE)
  out_files = setNames(file.path(OUT_DIR, paste0('nadi1_', names(RECONSTRUCTIONS), '.tif')), names(RECONSTRUCTIONS))
  writing_started = Sys.time()
  for (name in names(RECONSTRUCTIONS))
    writeRaster(as_fraction_raster(fractions[[name]], cells, template), out_files[[name]], overwrite = TRUE,
                datatype = 'FLT8S', gdal = c('COMPRESS=DEFLATE', 'PREDICTOR=3'))
  writing_minutes = as.numeric(difftime(Sys.time(), writing_started, units = 'mins'))

  # --- checks, on the files as written --------------------------------------------------
  old_bands = template[[BANDS]]
  centres = as.matrix(readRDS(CENTRES_FILE)[, c('x', 'y')])
  old_at_centres = is.na(extract(old_bands, centres))
  for (name in names(RECONSTRUCTIONS)) {
    written = rast(out_files[[name]])
    v = values(written)
    if (!identical(names(written), BANDS)) stop(name, ': band names differ from ', paste(BANDS, collapse = ' '))
    if (!compareGeom(written, template, stopOnError = FALSE)) stop(name, ': not on the old raster\'s grid')
    if (!identical(is.na(v), is.na(values(old_bands)))) stop(name, ': missing cells differ from the old raster\'s')
    if (any(v < 0 | v > 1, na.rm = TRUE)) stop(name, ': a fraction outside 0 to 1')
    if (!identical(is.na(extract(written, centres)), old_at_centres))
      stop(name, ': the prediction cells with a value differ from the old raster\'s')
    for (age in CARRIED_FORWARD)
      if (!identical(v[, paste0('yr', age, 'bp')], v[, 'yr1000bp'])) stop(name, ': ', age, ' BP differs from 1,000 BP')
  }
  snapshots$difference_km2 = snapshots$ice_area_from_fractions_km2 - snapshots$ice_area_in_grid_km2
  if (any(abs(snapshots$difference_km2) > TOLERANCE * snapshots$ice_area_in_grid_km2))
    stop('area not conserved:\n', paste(capture.output(print(snapshots)), collapse = '\n'))
  # The carried-forward slices repeat 1,000 BP, so only the snapshot ages are compared.
  snapshot_bands = BANDS %in% paste0('yr', SNAPSHOT_AGES, 'bp')
  exceptions = rbind(order_exceptions(fractions$minimum[, snapshot_bands], fractions$optimal[, snapshot_bands], 'minimum <= optimal', cells, template),
                     order_exceptions(fractions$optimal[, snapshot_bands], fractions$maximum[, snapshot_bands], 'optimal <= maximum', cells, template))

  # --- provenance ---------------------------------------------------------------------
  md5 = function(files) unname(tools::md5sum(files))
  head_commit = tryCatch(system2('git', c('rev-parse', '--short', 'HEAD'), stdout = TRUE, stderr = FALSE), error = function(e) 'unknown')
  table_lines = function(x) { old = options(width = 200); on.exit(options(old)); capture.output(print(x, row.names = FALSE, digits = 10)) }
  total_minutes = as.numeric(difftime(Sys.time(), started, units = 'mins'))
  writeLines(c(
    'NADI-1 ice fractions on the old ice raster\'s grid: provenance',
    '',
    sprintf('Made:        %s by tools/build_nadi1_fractions.R (md5 %s), run at commit %s',
            format(Sys.time(), '%Y-%m-%d %H:%M UTC', tz = 'UTC'), md5('tools/build_nadi1_fractions.R'), head_commit),
    'Source:      Dalton, A. S., et al. (2023), Quaternary Science Reviews 321, 108345, doi:10.1016/j.quascirev.2023.108345;',
    '             data set "North American Deglacial Isochrones, version 1" (NADI-1), Zenodo doi:10.5281/zenodo.8161764',
    '             (CC-BY-4.0), file "NADI-1 shapefiles Dalton et al. QSR.zip" (md5 fde5b0c80e766183ba5ad87c611f3e56, as',
    '             Zenodo publishes it), unpacked; the 66 shapefiles used and the md5 of each .shp are listed below.',
    sprintf('Template:    %s (md5 %s): its grid, extent and missing cells', TEMPLATE_FILE, md5(TEMPLATE_FILE)),
    sprintf('Ages:        the slices %s to %s BP take the NADI-1 snapshot of the same age (calendar years);', max(SNAPSHOT_AGES), min(SNAPSHOT_AGES)),
    sprintf('             %s BP take the 1,000 BP fractions (carried forward, Chris, 16 November 2026)', paste(CARRIED_FORWARD, collapse = ', ')),
    sprintf('Bands:       %s', paste(BANDS, collapse = ' ')),
    'Geometry:    the polygons as drawn (straight edges in longitude and latitude), open rings closed,',
    sprintf('             sf::st_make_valid() and st_union() (GEOS); edges cut every %s degrees, projected to %s;', EDGE_STEP, EQUAL_AREA),
    sprintf('             fraction = area(cell under ice) / area(cell) in that projection; whole-cell area; rounded to %d decimals', DECIMALS),
    sprintf('Software:    R %s, sf %s, terra %s; GEOS %s, GDAL %s, PROJ %s', getRversion(), packageVersion('sf'), packageVersion('terra'),
            sf_extSoftVersion()[['GEOS']], sf_extSoftVersion()[['GDAL']], sf_extSoftVersion()[['PROJ']]),
    'Files:       double-precision GeoTIFF, DEFLATE compression',
    sprintf('Runtime:     %.1f min in all: %.1f min for the polygons and intersections, %.2f min writing', total_minutes, geometry_minutes, writing_minutes),
    '',
    'Outputs (md5, path, bytes):',
    sprintf('  %s  %s  %d', md5(out_files), out_files, file.size(out_files)),
    '',
    'Checks passed: fractions within 0 to 1; band names; the template\'s grid and missing cells in every band;',
    sprintf('the same prediction cells (%s) get a value as from the template; 500, 200 and 50 BP equal 1,000 BP;', CENTRES_FILE),
    sprintf('area conserved for every snapshot (largest relative difference %.1e). Per snapshot: the rings closed and', max(abs(snapshots$difference_km2) / snapshots$ice_area_in_grid_km2)),
    'polygons repaired; the data set\'s own total area (sum of Area_Km2), the merged ice area, the ice area inside the',
    'grid measured directly and from the fractions (km2):',
    table_lines(snapshots[, setdiff(names(snapshots), c('file', 'shp_md5'))]),
    '',
    sprintf('Order minimum <= optimal <= maximum, cell by cell at the 22 snapshot ages, tolerance %g: %d exceptions (reported, not repaired)%s',
            TOLERANCE, nrow(exceptions), if (nrow(exceptions)) ':' else '.'),
    if (nrow(exceptions)) table_lines(exceptions),
    '',
    'NADI-1 shapefiles used:',
    table_lines(snapshots[, c('reconstruction', 'age_bp', 'file', 'shp_md5')])),
    file.path(OUT_DIR, 'nadi1_fractions_provenance.txt'))
  cat(sprintf('wrote %s; %d order exceptions; %.1f min\n', paste(out_files, collapse = ', '), nrow(exceptions), total_minutes))
  invisible(list(fractions = fractions, snapshots = snapshots, exceptions = exceptions))
}

# Run when called as a script; tests source the functions above without building.
if (sys.nframe() == 0L) {
  args = commandArgs(trailingOnly = TRUE)
  build_nadi1_fractions(if (length(args)) args[1] else NADI_DIR)
}
