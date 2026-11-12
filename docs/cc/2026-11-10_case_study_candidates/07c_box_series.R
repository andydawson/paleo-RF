# Time series of the reconstruction's cover in trial boxes, to see when a change happens
# before fixing a candidate's box and slices. Exploration.
# Usage: Rscript 07c_box_series.R "name,lon_min,lon_max,lat_min,lat_max" ...
source('./case_study_helpers.R')
a = read_cache(); cells = a$cells; ages = a$ages
for (spec in commandArgs(trailingOnly = TRUE)) {
  p = strsplit(spec, ',')[[1]]
  box = data.frame(lon_min = as.numeric(p[2]), lon_max = as.numeric(p[3]), lat_min = as.numeric(p[4]), lat_max = as.numeric(p[5]))
  inside = in_box(cells, box)
  cat(sprintf('\n%s: %g..%g E, %g..%g N; %d cells\n', p[1], box$lon_min, box$lon_max, box$lat_min, box$lat_max, sum(inside)))
  cat('  age   ice-free   OL    ET    ST  | step: dOL   dET   dST\n')
  previous = NULL
  for (i in rev(seq_along(ages))) {
    weight = cells$area[inside] * (1 - a$ice[inside, i])
    now = sapply(CLASSES, function(class) weighted_mean(a$cover[inside, i, class], weight))
    step = if (is.null(previous)) rep(NA, 3) else now - previous
    cat(sprintf('%6d   %5.2f   %5.3f %5.3f %5.3f |      %6.3f %6.3f %6.3f\n', ages[i], sum(weight) / sum(cells$area[inside]), now[1], now[2], now[3], step[1], step[2], step[3]))
    previous = now
  }
}
