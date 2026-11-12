# One map for orientation: the candidates' boxes over the cells that have a pollen-based
# estimate (the darker a cell, the more of the pollen table's eight Holocene slices have one).
source('./case_study_helpers.R')
setwd(WORKTREE)
suppressPackageStartupMessages({ library(ggplot2); source('R/map_helpers.R') })
a = read_cache(); cells = a$cells
candidates = read.csv(file.path(OUT_DIR, 'candidates.csv'), stringsAsFactors = FALSE)
boxes = unique(candidates[, c('lon_min', 'lon_max', 'lat_min', 'lat_max')])
boxes$label = sapply(seq_len(nrow(boxes)), function(i) {
  same = candidates$lon_min == boxes$lon_min[i] & candidates$lon_max == boxes$lon_max[i] & candidates$lat_min == boxes$lat_min[i] & candidates$lat_max == boxes$lat_max[i]
  paste(sprintf('%s (%s to %s ka)', sub('_', ' ', gsub('_', ' ', candidates$key[same])), format(candidates$old[same] / 1000), format(candidates$young[same] / 1000)), collapse = '\n')
})
holocene = a$pollen[a$pollen$ages <= 12000, ]
slices = aggregate(ages ~ long + lat, holocene, length)
window = list(x = c(-170, -52), y = c(26, 75))
land = prepare_boundaries(readRDS('data/map-data/geographic/pbs_ll.RDS'), window)
figure = ggplot() +
  geom_tile(data = cells, aes(x, y), fill = 'grey93') +
  geom_tile(data = slices, aes(long, lat, fill = ages)) +
  boundary_layers(land, window, colour = 'grey45', linewidth = 0.15) +
  geom_rect(data = boxes, aes(xmin = lon_min, xmax = lon_max, ymin = lat_min, ymax = lat_max), fill = NA, colour = 'black', linewidth = 0.5) +
  geom_label(data = boxes, aes(x = (lon_min + lon_max) / 2, y = lat_max, label = label), size = 2.1, vjust = 1.05, lineheight = 0.9, fill = 'white', alpha = 0.8, label.size = 0) +
  scale_fill_gradient(low = '#c7dcef', high = '#08306b', name = 'slices with a\npollen-based\nestimate (of 8)') +
  theme_bw(base_size = 9) + labs(x = NULL, y = NULL, title = 'Candidate case-study boxes, over the one-degree cells that have a pollen-based cover estimate',
                                subtitle = 'pale grey: study-area cells filled only by the spatial interpolation')
ggsave(file.path(OUT_DIR, 'figures', 'candidate_boxes.png'), figure, width = 12, height = 6.4, dpi = 110)
