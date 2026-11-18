# Tests for the geometry of tools/build_nadi1_fractions.R, on small hand-made cases (the real
# build checks itself: conservation, grid, bands). Run from the repository root:
#   Rscript tests/test_build_nadi1_fractions.R
source('tools/build_nadi1_fractions.R')   # the functions only: the build runs only as a script
same <- function(a, b) isTRUE(all.equal(a, b, tolerance = 1e-9))
box <- function(x0, x1, y0, y1) cbind(c(x0, x1, x1, x0, x0), c(y0, y0, y1, y1, y0))   # lon/lat corners
lonlat <- function(...) st_sfc(list(...))   # polygons as drawn, no coordinate system

# Three one-degree cells at 50-51 N; the middle one has no value, so it is not a cell.
template <- rast(xmin = -101, xmax = -98, ymin = 50, ymax = 51, resolution = 1, crs = 'EPSG:4326')
values(template) <- c(1, NA, 1)
cells <- grid_cells(template)
cells_union <- st_union(cells$geometry)
fractions_under <- function(...) cell_fractions(cells, to_equal_area(st_union(st_make_valid(lonlat(...)))), cells_union)

stopifnot(identical(cells$cell, c(1L, 3L)), same(cells$area[1], cells$area[2]))

# A polygon over the first cell and the western half of the other: 1 and one half (equal
# longitude, equal area); the ice in the grid is what the fractions add up to.
r <- fractions_under(st_polygon(list(box(-101.5, -98.5, 49, 52))))
stopifnot(same(r$fraction, c(1, 0.5)), same(sum(r$fraction * cells$area), r$ice_area_in_grid))

# A hole exactly over the last cell: it stays a hole.
r <- fractions_under(st_polygon(list(box(-101.5, -97.5, 49, 52), box(-99, -98, 50, 51)[5:1, ])))
stopifnot(same(r$fraction, c(1, 0)))

# Two overlapping polygons over the western half of the first cell count once.
half <- st_polygon(list(box(-101, -100.5, 49, 52)))
r <- fractions_under(half, half)
stopifnot(same(r$fraction, c(0.5, 0)))

# Ice nowhere near the grid: zero everywhere.
r <- fractions_under(st_polygon(list(box(-60, -59, 70, 71))))
stopifnot(identical(r$fraction, c(0, 0)), r$ice_area_in_grid == 0)

# A ring left open is closed, and counted.
open_ring <- st_sfc(list(structure(list(box(-101, -100.5, 49, 52)[1:4, ]), class = c('XY', 'POLYGON', 'sfg'))))
closed <- close_rings(open_ring)
stopifnot(attr(closed, 'rings_closed') == 1, identical(closed[[1]][[1]], box(-101, -100.5, 49, 52)),
          attr(close_rings(lonlat(half)), 'rings_closed') == 0)

# Through a file: a self-crossing polygon (a bow tie crossing at -99.5 E, 50.5 N) is repaired
# into its two triangles, each covering two thirds of a cell; a missing file or one not in
# longitude and latitude stops.
dir <- tempfile('nadi1_test_'); dir.create(dir)
bow_tie <- st_polygon(list(cbind(c(-101, -98, -98, -101, -101), c(50, 51, 50, 51, 50))))
st_write(st_sf(Area_Km2 = 1, geometry = st_sfc(bow_tie, crs = 4326)), snapshot_file(1000, 'OPTIMAL', dir), quiet = TRUE)
s <- snapshot_ice(snapshot_file(1000, 'OPTIMAL', dir))
r <- cell_fractions(cells, s$ice, cells_union)
stopifnot(s$polygons_repaired == 1, s$rings_closed == 0, all(abs(r$fraction - 2/3) < 1e-4), same(r$fraction[1], r$fraction[2]))
st_write(st_sf(Area_Km2 = 1, geometry = st_transform(st_sfc(half, crs = 4326), 3857)), snapshot_file(1500, 'OPTIMAL', dir), quiet = TRUE)
fails <- function(expr) inherits(try(expr, silent = TRUE), 'try-error')
stopifnot(fails(snapshot_ice(snapshot_file(2000, 'OPTIMAL', dir))), fails(snapshot_ice(snapshot_file(1500, 'OPTIMAL', dir))))
unlink(dir, recursive = TRUE)

# The file names of the data set, and the slices: 22 snapshots and three carried forward.
stopifnot(identical(basename(snapshot_file(11500, 'MIN')), '11.5ka_cal_MIN_NADI-1_Dalton_etal_QSR.shp'),
          identical(basename(snapshot_file(1000, 'OPTIMAL')), '1ka_cal_OPTIMAL_NADI-1_Dalton_etal_QSR.shp'),
          length(SNAPSHOT_AGES) == 22, identical(BANDS[23:25], c('yr500bp', 'yr200bp', 'yr50bp')))
cat('test_build_nadi1_fractions: all tests passed\n')
