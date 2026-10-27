# plot_training_support.R: which past land-cover mixes lie outside the range of the
# calibration (training) data, how often, where, and how far outside.
#
# WHY (Chris, 2026-10-20, for Andria). The calibration model is fitted on today's cover
# mixes; a past mix unlike any modern one is predicted by extrapolation. This figure shows
# how much of the hindcast that affects and where, so that regional signals resting on
# extrapolation (the northeast in particular) can be judged. A diagnostic, not a pipeline
# step: run it by hand after scripts 4 and 6, from the repository root:
#   Rscript tools/plotting/plot_training_support.R [--config <file>]
#
# WHAT COMES IN
#   output/calibration/calibration_prediction_fit_may_bluesky.RDS   script 4: the May fit;
#       its fitting data are the training mixes (May has the most cells; other months use
#       the same cells or fewer)
#   output/prediction/paleo_interp_predict_gam_bluesky.RDS          script 6: the past
#       cover of every cell at every time slice (mean of the reconstruction's draws)
#   data/map-data/geographic/pbs_ll.RDS                             map boundaries
#
# WHAT GOES OUT
#   figures/diagnostics/training_support.png
#     a. the cover triangle: training mixes, their outer range (the convex hull), and the
#        past mixes inside and outside it
#     b. the share of cells outside the range at each time slice
#     c. the number of time slices at which each cell is outside
#   The log prints the counts, the share outside by more than 0.02, 0.05 and 0.10, and the
#   share by time slice.
#
# The rule ("outside", and the distance outside) is in R/training_support.R. The 50 BP
# slice is left out: it is today's cover, the period the model was trained on.

source('R/run_manifest.R')
source('R/map_helpers.R')
source('R/training_support.R')
run   = run_begin('plot_training_support')
cfg   = run$cfg
paths = run$paths

library(ggplot2)
library(dplyr)
library(patchwork)

training = read_input(run, path_file(paths, 'calibration_prediction_fit', month = 'may'))$model[, c('x', 'y', 'OL', 'ET', 'ST')]
hull = training_hull(training)

# Cover does not depend on the month: one month's rows hold every cell and slice once.
hindcast = read_input(run, path_file(paths, 'prediction_point'))
hindcast = hindcast[hindcast$month == 'may' & hindcast$year != 50, c('year', 'x', 'y', 'OL', 'ET', 'ST')]   # 50 BP: today
hindcast = cbind(hindcast, training_support(hindcast, hull))
n_slices = n_distinct(hindcast$year)

cat(sprintf('training cells %d | past cell-slices %d (%d slices) | outside the training range %d (%.1f%%)\n',
            nrow(training), nrow(hindcast), n_slices, sum(hindcast$outside), 100 * mean(hindcast$outside)))
for (tolerance in c(0.02, 0.05, 0.10))
  cat(sprintf('outside by more than %.2f: %.1f%% of past cell-slices\n', tolerance, 100 * mean(hindcast$distance_outside > tolerance)))

# --- a. the cover triangle ---------------------------------------------------------------
frame = cover_triangle_xy(data.frame(OL = c(1, 0, 0, 1), ET = c(0, 0, 1, 0), ST = c(0, 1, 0, 0)))
# Grid lines at 0.2, 0.4, 0.6 and 0.8 of each cover type.
grid_lines = do.call(rbind, lapply(c(0.2, 0.4, 0.6, 0.8), function(v) rbind(
  cbind(cover_triangle_xy(data.frame(OL = c(v, v), ET = c(0, 1 - v), ST = c(1 - v, 0))), line = paste('OL', v)),
  cbind(cover_triangle_xy(data.frame(ET = c(v, v), OL = c(0, 1 - v), ST = c(1 - v, 0))), line = paste('ET', v)),
  cbind(cover_triangle_xy(data.frame(ST = c(v, v), OL = c(0, 1 - v), ET = c(1 - v, 0))), line = paste('ST', v)))))
inside_xy  = cover_triangle_xy(hindcast[!hindcast$outside, ])
outside    = hindcast[hindcast$outside, ]
outside_xy = cbind(cover_triangle_xy(outside), age_ka = outside$year / 1000)
outside_xy = outside_xy[order(-outside_xy$age_ka), ]   # youngest drawn last, on top

panel_triangle = ggplot() +
  geom_line(data = grid_lines, aes(px, py, group = line), colour = 'grey90', linewidth = 0.3) +
  geom_polygon(data = frame, aes(px, py), fill = NA, colour = 'grey40', linewidth = 0.4) +
  geom_point(data = inside_xy, aes(px, py), colour = '#9ecae1', size = 0.25, alpha = 0.25) +
  geom_point(data = cover_triangle_xy(training), aes(px, py), colour = 'grey25', size = 0.35) +
  geom_point(data = outside_xy, aes(px, py, colour = age_ka), size = 0.5) +
  geom_path(data = hull, aes(px, py), colour = 'black', linewidth = 0.5) +
  scale_colour_viridis_c(name = 'outside the\ntraining range:\nage (ka)', option = 'plasma', end = 0.9) +
  annotate('text', x = c(-0.02, 1.02, 0.5), y = c(-0.04, -0.04, 0.905), size = 3.2,
           label = c('open land', 'summergreen', 'evergreen')) +
  coord_equal(clip = 'off') + theme_void(base_size = 9) +
  labs(title = 'a. Cover mixes',
       subtitle = sprintf(paste0('dark grey: training data (today, %s cells); black line: their outer range\n',
                                 'light blue: hindcast mixes inside that range; coloured: hindcast mixes outside it'),
                          format(nrow(training), big.mark = ',')))

# --- b. share of cells outside, by time slice ---------------------------------------------
share_by_slice = hindcast %>% group_by(year) %>% summarise(share_outside = mean(outside), .groups = 'drop')
cat('share of cells outside the training range, by time slice (years BP):\n')
print(as.data.frame(share_by_slice %>% mutate(share_outside = round(share_outside, 3))), row.names = FALSE)

panel_share = ggplot(share_by_slice, aes(year / 1000, share_outside)) + geom_col(fill = '#d95f02', width = 0.4) +
  scale_x_reverse(breaks = 0:12) + scale_y_continuous(labels = scales::percent, limits = c(0, NA)) +
  labs(x = 'time slice (ka)', y = 'cells outside the training range',
       title = 'b. Share of cells outside the training range, by time slice') +
  theme_bw(base_size = 9)

# --- c. where: the number of time slices at which each cell is outside ---------------------
window = cfg$presentation$map_windows$diagnostics
land = prepare_boundaries(read_input(run, path_file(paths, 'boundaries_ll')), window)
slices_outside = hindcast %>% group_by(x, y) %>% summarise(n = sum(outside), .groups = 'drop')

panel_map = ggplot() +
  geom_tile(data = slices_outside[slices_outside$n > 0, ], aes(x, y, fill = n)) +
  boundary_layers(land, window, colour = 'grey60', linewidth = 0.15) +
  scale_fill_viridis_c(name = sprintf('time slices\noutside (of %d)', n_slices), option = 'rocket', direction = -1, end = 0.9) +
  theme_bw(base_size = 9) +
  labs(x = NULL, y = NULL, title = 'c. Where: time slices at which each cell is outside the training range')

figure = panel_triangle + (panel_share / panel_map + plot_layout(heights = c(1, 1.6))) + plot_layout(widths = c(1.15, 1)) +
  plot_annotation(
    title = 'Past land-cover mixes that lie outside the range of the calibration (training) data',
    caption = paste0('Land cover: interpolated pollen-based reconstruction (mean of draws). Training range: convex hull of the modern mixes of the cells used to fit the calibration model.\n',
                     '"Outside" means no modern cell has a comparable mix of the three cover types; predictions there are extrapolations.'),
    theme = theme(plot.title = element_text(size = 12, face = 'bold'), plot.caption = element_text(size = 7, hjust = 0)))

figure_file = path_figure(paths, 'diagnostics', 'training_support.png')
ggsave(figure_file, figure, width = 13, height = 7.5, dpi = 170)

run_finish(run)
