# [run-nointerp] Reconstruction of the missing helper sourced by 3_plot_cal_lct_albedo.R.
# The original make_grid.R is not in the repository. This version reproduces what
# the call sites need: a RasterLayer covering the extent of the data at the given
# resolution, whose cell values are the cell numbers, so that
#   raster::extract(grid, coords)  returns a cell id per site, and
#   raster::xyFromCell(grid, id)   returns the cell centre.
make_grid <- function(data, coord_fun = ~ long + lat, projection = '+init=epsg:4326', resolution = 2) {
  vars <- all.vars(coord_fun)
  xy <- data[, vars]
  ext <- raster::extent(floor(min(xy[, 1], na.rm = TRUE)), ceiling(max(xy[, 1], na.rm = TRUE)),
                        floor(min(xy[, 2], na.rm = TRUE)), ceiling(max(xy[, 2], na.rm = TRUE)))
  grid <- raster::raster(ext, resolution = resolution, crs = projection)
  raster::values(grid) <- seq_len(raster::ncell(grid))
  grid
}
