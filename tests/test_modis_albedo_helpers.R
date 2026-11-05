# Shared MODIS helper checks. Run from the repository root.
suppressPackageStartupMessages(library(terra))
source("R/modis_albedo_helpers.R")
near <- function(a, b, tol = 1e-10) isTRUE(all(abs(a - b) < tol))

# Land: more than half of the days with a class say land; blank days do not count; a tie is not
# land. With the 'land_or_shore' rule, shoreline days count with land days.
stopifnot(identical(is_land(c(10, 6, 5, 0, 0), 0, c(10, 10, 10, 3, 0)), c(TRUE, TRUE, FALSE, FALSE, FALSE)),
          identical(is_land(c(3, 3, 0), c(0, 3, 6), c(10, 10, 10)), c(FALSE, FALSE, FALSE)),
          identical(is_land(c(3, 3, 0), c(0, 3, 6), c(10, 10, 10), 'land_or_shore'), c(FALSE, TRUE, TRUE)))

stopifnot(inherits(try(is_land(1, 0, 1, "other"), silent = TRUE), "try-error"))

# Known centres on the equator test the inverse projection without a whole tile in memory.
step <- TILE_SIZE / 2400
equator <- rast(nrows = 1, ncols = 3, crs = SIN_CRS,
                extent = ext(-1.5 * step, 1.5 * step, -step / 2, step / 2))
stopifnot(near(pixel_lonlat(equator)[, "lon"], c(-1, 0, 1) / 240, 1e-11),
          near(pixel_lonlat(equator)[, "lat"], rep(0, 3)))

# Neighbouring tiles meet exactly; their edge centres remain one pixel apart, including 40 N.
west <- tile_template("h11v04"); east <- tile_template("h12v04")
south <- tile_template("h12v05")
stopifnot(nrow(west) == 2400, ncol(west) == 2400,
          near(res(west), c(step, step), 1e-8), near(xmax(west), xmin(east)),
          near(ymin(east), ymax(south)))
west_edge <- crop(west, ext(xmax(west) - step, xmax(west), ymin(west), ymin(west) + step))
east_edge <- crop(east, ext(xmin(east), xmin(east) + step, ymin(east), ymin(east) + step))
south_edge <- crop(south, ext(xmin(south), xmin(south) + step, ymax(south) - step, ymax(south)))
stopifnot(ncell(west_edge) == 1, ncell(east_edge) == 1, ncell(south_edge) == 1,
          near(xyFromCell(east_edge, 1)[, 1] - xyFromCell(west_edge, 1)[, 1], step, 1e-8),
          near(xyFromCell(east_edge, 1)[, 2] - xyFromCell(south_edge, 1)[, 2], step, 1e-8),
          pixel_lonlat(east_edge)[, "lat"] > 40, pixel_lonlat(south_edge)[, "lat"] < 40)

# PROJ supplies an independent check at northeastern tile edges, not just at the equator.
for (r in list(west_edge, east_edge, south_edge)) {
  projected <- crds(project(vect(xyFromCell(r, 1), crs = SIN_CRS), "EPSG:4326"))
  stopifnot(near(unname(pixel_lonlat(r)), unname(projected), 1e-9))
}

# Centres just either side of pipeline boundaries retain the floor(lon/lat) cell assignment.
# A zero boundary is exact in the projection, so its east/north ownership is tested too.
points <- data.frame(lon = c(-70 - 1e-6, -70 + 1e-6, -70 - 1e-6, -70 + 1e-6, 0),
                     lat = c(44 - 1e-6, 44 - 1e-6, 44 + 1e-6, 44 + 1e-6, 0))
for (i in seq_len(nrow(points))) {
  lat <- points$lat[i] * pi / 180
  x <- R_EARTH * points$lon[i] * pi / 180 * cos(lat); y <- R_EARTH * lat
  centre <- rast(nrows = 1, ncols = 1, crs = SIN_CRS, extent = ext(x - 1, x + 1, y - 1, y + 1))
  ll <- pixel_lonlat(centre)
  stopifnot(near(unname(ll), unname(as.matrix(points[i, ])), 1e-10),
            identical(unname(floor(ll) + 0.5), unname(floor(as.matrix(points[i, ])) + 0.5)))
}

cat("test_modis_albedo_helpers: all tests passed\n")
