# Shared MODIS geometry and record-wide land selection. Source after library(terra).
# Both the albedo preparation and the northeast check use these definitions.

# --- the sinusoidal grid ------------------------------------------------------------------
# MODIS tiles: 36 x 18 tiles of 2,400 x 2,400 pixels on a sphere of radius 6,371,007.181 m.
SIN_CRS   = '+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +R=6371007.181 +units=m +no_defs'
TILE_SIZE = 1111950.5196666666
X0 = -20015109.354; Y0 = 10007554.677

# Longitude and latitude of every pixel centre of a tile, from the sinusoidal formulas
# (y = R lat, x = R lon cos lat).
R_EARTH = 6371007.181
tile_template = function(tile) {
  h = as.integer(substr(tile, 2, 3)); v = as.integer(substr(tile, 5, 6))
  rast(nrows = 2400, ncols = 2400, crs = SIN_CRS,
       extent = ext(X0 + h * TILE_SIZE, X0 + (h + 1) * TILE_SIZE, Y0 - (v + 1) * TILE_SIZE, Y0 - v * TILE_SIZE))
}
pixel_lonlat = function(template) {
  xy = xyFromCell(template, seq_len(ncell(template)))
  lat = xy[, 2] / R_EARTH
  cbind(lon = xy[, 1] / (R_EARTH * cos(lat)) * 180 / pi, lat = lat * 180 / pi)
}

# Land: a pixel whose land/water class says land (1) on more than half of the days it has one,
# over the whole record (Chris, 2026-10-20); with rule 'land_or_shore', land or shoreline (2)
# together. A blank class means no retrieval that day (checked on the July 2005 download: blank
# class and no albedo coincide on every pixel-day), so blank days are not counted. A tie (exactly
# half) is not land.
is_land = function(land_days, shore_days, read_days, rule = 'land') {
  yes = switch(rule, land = land_days, land_or_shore = land_days + shore_days, stop('unknown land rule ', rule))
  read_days > 0 & yes > read_days / 2
}

