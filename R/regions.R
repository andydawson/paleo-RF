# The regions discussed with Andria, as longitude-latitude boxes, for the diagnostic figures
# of tools/plotting/.
#
# Why here: two diagnostic scripts use the northeast box (plot_pollen_site_coverage.R counts
# pollen cells in every region; plot_northeast_cover_and_location.R looks at the northeast
# alone), and both must mean the same place. The boxes are approximate, for counting and
# for picking cells, not exact regional boundaries. The northeast box is the region of
# figure 4a of Dawson et al. (2025), Climate of the Past, where the hemlock decline shows.
#
# Each box includes its west and south edges and excludes its east and north edges; an
# open side is -Inf or Inf. The boxes do not overlap.

DIAGNOSTIC_REGIONS = data.frame(
  region  = c('Southwest (AZ, NM, W Texas)', 'Southern Plains (TX, OK, KS)',
              'Southeast (AR, LA to FL, GA, Carolinas)', 'Northeast (hemlock box)',
              'Upper Midwest / Great Lakes', 'Alaska / Yukon'),
  lon_min = c(-115, -103, -94,  -80, -97, -Inf),
  lon_max = c(-103,  -94, Inf,  -66, -80, -125),
  lat_min = c(  28,   26,  24,   40,  40,   55),
  lat_max = c(  38,   40,  37,   48,  50,  Inf))

# The region of each point, or 'elsewhere' if it is in none of the boxes.
region_of = function(lon, lat) {
  region = rep('elsewhere', length(lon))
  for (i in seq_len(nrow(DIAGNOSTIC_REGIONS))) {
    box = DIAGNOSTIC_REGIONS[i, ]
    in_box = lon >= box$lon_min & lon < box$lon_max & lat >= box$lat_min & lat < box$lat_max
    region[in_box] = box$region
  }
  region
}
