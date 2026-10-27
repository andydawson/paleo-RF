# Which past land-cover mixes lie outside the range of the calibration (training) data, and
# how far outside.
#
# Why a function: the calibration model is fitted on today's cover mixes, so a prediction
# for a past mix unlike any modern one is an extrapolation. Two diagnostic figures
# (tools/plotting/plot_training_support.R and plot_forcing_vs_training_support.R) flag such
# mixes; they must flag the same cells, so the rule is defined once, here.
#
# The rule. The three cover fractions (OL open land, ET evergreen, ST summergreen) sum to
# one, so a mix is a point on the cover triangle. The training range is the convex hull of
# the training mixes on that triangle; a past mix is "outside" if it lies outside the hull
# (a mix on the edge counts as inside). The distance outside is measured to the hull's
# edge on an equilateral triangle with sides of length 1, where 0.05 is roughly a
# 5-percentage-point shift in the cover fractions. The hull is a strict test: a mix just
# over the edge is flagged although a model can be expected to step a little beyond its
# data, which is why the distance is reported too.
#
# Needs sf (planar geometry: the points carry no coordinate reference system).

library(sf)

# Positions on the cover triangle: open land bottom-left, summergreen bottom-right,
# evergreen at the top. `cover` is a data frame with columns OL, ET and ST.
cover_triangle_xy = function(cover) {
  # The position uses ST and ET only, so a mix that did not sum to one would be placed as if
  # the shortfall were open land; stop instead of judging it in the wrong place.
  off_triangle = abs(cover$OL + cover$ET + cover$ST - 1) > 1e-6
  if (any(off_triangle, na.rm = TRUE))
    stop(sum(off_triangle, na.rm = TRUE), ' cover mixes do not sum to one; they cannot be placed on the cover triangle', call. = FALSE)
  data.frame(px = cover$ST + cover$ET / 2, py = cover$ET * sqrt(3) / 2)
}

# The training range: the convex hull of the training mixes, as a closed ring of triangle
# positions (first point repeated at the end), for drawing and for training_support().
training_hull = function(training_cover) {
  xy = cover_triangle_xy(training_cover)
  corners = chull(xy$px, xy$py)
  xy[c(corners, corners[1]), ]
}

# For each mix in `cover`: outside the training range (TRUE/FALSE), and its distance
# outside (0 for a mix inside).
training_support = function(cover, hull) {
  hull_polygon = st_polygon(list(as.matrix(hull[, c('px', 'py')])))
  points = st_as_sf(cover_triangle_xy(cover), coords = c('px', 'py'))
  outside = lengths(st_intersects(points, hull_polygon)) == 0
  distance_outside = numeric(nrow(cover))
  if (any(outside))
    distance_outside[outside] = as.numeric(st_distance(points[outside, ], st_cast(st_sfc(hull_polygon), 'LINESTRING')))
  data.frame(outside = outside, distance_outside = distance_outside)
}
