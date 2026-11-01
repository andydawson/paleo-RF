# plot_forcing_vs_training_support.R: the vegetation forcing of each period, cell by cell,
# with the cells whose cover mix lies outside the range of the training data outlined.
#
# WHY (Chris, 2026-10-20, for Andria). It shows which regional forcing signals rest on
# extrapolation of the calibration model (outlined) and which lie within the range of
# today's cover mixes; a companion to plot_training_support.R, with the same rule
# (R/training_support.R). A diagnostic, not a pipeline step: run it by hand after scripts
# 4, 6 and 8, from the repository root:
#   Rscript tools/plotting/plot_forcing_vs_training_support.R [--config <file>]
#
# WHAT COMES IN
#   output/calibration/calibration_prediction_fit_may_bluesky.RDS   script 4: the training
#       mixes (as in plot_training_support.R)
#   output/prediction/paleo_interp_predict_gam_bluesky.RDS          script 6: past cover
#   output/forcing/RF_holocene_all_cases.RDS                        script 8: forcing per
#       cell, month and slice-pair
#   data/map-data/geographic/pbs_ll.RDS                             map boundaries
#
# WHAT GOES OUT
#   figures/diagnostics/forcing_vs_training_support.png   one map per period
#
# THE ARITHMETIC (script 9's, stopped before the area weighting)
#   1. Slice-pairs grouped into the periods of config.R (analysis$coarse$ages), incomplete
#      cell-months dropped: R/forcing_periods.R, as in scripts 9 and 10.
#   2. Per cell: forcing summed over the slice-pairs of a period in each month, then the
#      mean over months (script 9's A5 and A6), in W/m2.
#   3. The column is HadGEM3's vegetation part (rf_hadgem_veg_part): only the vegetation
#      part depends on the cover mix, and HadGEM3 is the headline kernel.
#   4. A cell is outlined if its mix is outside the training range at either end of any
#      slice-pair in the period.
#   Colours are clipped at the 98th percentile of the absolute values, so a few extreme
#   cells do not wash out the rest. Positive = warming (albedo fell), as in scripts 8 and 9.

source('R/run_manifest.R')
source('R/map_helpers.R')
source('R/calendar.R')
source('R/forcing_periods.R')
source('R/training_support.R')
run   = run_begin('plot_forcing_vs_training_support')
cfg   = run$cfg
paths = run$paths

library(ggplot2)
library(dplyr)

FORCING_COLUMN = 'rf_hadgem_veg_part'

support_inputs = read_training_support_inputs(run)   # R/training_support.R
cover = support_inputs$cover
cover$outside = training_support(cover, support_inputs$hull)$outside
outside_at = setNames(cover$outside, paste(cover$year, cover$x, cover$y))

forcing = assign_forcing_periods(read_input(run, path_file(paths, 'forcing')), cfg$analysis$coarse$ages, cfg$analysis$ages)
outside_young = outside_at[paste(forcing$year, forcing$x, forcing$y)]
outside_old   = outside_at[paste(forcing$age_old, forcing$x, forcing$y)]
# Both ends of every slice pair must have a cover row; a missing one would otherwise drop out
# of any() below and leave the cell unjudged (review of 1 November 2026, finding 7).
if (anyNA(outside_young) || anyNA(outside_old))
  stop(sum(is.na(outside_young) | is.na(outside_old)), ' forcing rows have no cover row at one end of their slice pair', call. = FALSE)
forcing$outside = outside_young | outside_old

forcing_by_cell = forcing %>%
  group_by(period, cell_id, x, y, month) %>%
  summarise(rf = sum(.data[[FORCING_COLUMN]]), outside = any(outside), .groups = 'drop') %>%
  group_by(period, cell_id, x, y) %>%
  summarise(rf = mean(rf, na.rm = TRUE), outside = any(outside), .groups = 'drop') %>%
  filter(!is.na(rf))
forcing_by_cell$period = factor(forcing_by_cell$period, levels = rev(period_labels(cfg$analysis$coarse$ages)))

colour_limit = unname(quantile(abs(forcing_by_cell$rf), 0.98))
cat(sprintf('cells outlined, by period (of %d cells):\n', n_distinct(forcing_by_cell$cell_id)))
print(table(forcing_by_cell$period[forcing_by_cell$outside]))

window = cfg$presentation$map_windows$diagnostics
land = prepare_boundaries(read_input(run, path_file(paths, 'boundaries_ll')), window)

figure = ggplot() +
  geom_tile(data = forcing_by_cell, aes(x, y, fill = pmax(pmin(rf, colour_limit), -colour_limit))) +
  geom_tile(data = forcing_by_cell[forcing_by_cell$outside, ], aes(x, y), fill = NA, colour = 'black', linewidth = 0.18) +
  boundary_layers(land, window, colour = 'grey60', linewidth = 0.1) +
  facet_wrap(~period, ncol = 2) +
  scale_fill_gradient2(low = '#2166ac', mid = 'grey95', high = '#b2182b', name = 'W/m2') +
  labs(title = 'Vegetation forcing per cell, by period (HadGEM3, vegetation part; red = warming, blue = cooling)',
       subtitle = sprintf(paste0('Black outline: cell whose cover mix lies outside the range of the training data at either end of a slice pair in that period.\n',
                                 'Colour clipped at the 98th percentile (%.0f W/m2).'), colour_limit),
       x = NULL, y = NULL) +
  theme_bw(base_size = 9) + theme(strip.text = element_text(face = 'bold'))

figure_file = path_figure(paths, 'diagnostics', 'forcing_vs_training_support.png')
ggsave(figure_file, figure, width = 11, height = 15, dpi = 150)

run_finish(run)
