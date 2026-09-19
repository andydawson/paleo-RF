# Reconstruction: the original make_grid.R sourced by 3_plot_cal_lct_albedo.R
# is not in the repository. Written 2026-09-16 to match what the call sites
# need: a RasterLayer over the data extent whose values are the cell numbers.
make_grid <- function(data, coord_fun = ~ long + lat, projection = '+init=epsg:4326', resolution = 2) {
  vars <- all.vars(coord_fun)
  xy <- data[, vars]
  ext <- raster::extent(floor(min(xy[, 1], na.rm = TRUE)), ceiling(max(xy[, 1], na.rm = TRUE)),
                        floor(min(xy[, 2], na.rm = TRUE)), ceiling(max(xy[, 2], na.rm = TRUE)))
  grid <- raster::raster(ext, resolution = resolution, crs = projection)
  raster::values(grid) <- seq_len(raster::ncell(grid))
  grid
}
