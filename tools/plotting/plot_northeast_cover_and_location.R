# plot_northeast_cover_and_location.R: in the northeast (the hemlock region), how today's
# evergreen share follows latitude, what today's albedo shows about evergreen cover, and
# how the calibration model's evergreen effect there depends on its location term.
#
# WHY (Chris, 2026-10-28, for Andria). The model predicts a darker surface where hemlock
# declined (6 to 4.5 ka), giving warming where cooling is expected. The training-support
# figures show that those past mixes have no modern counterpart, but not why the model's
# evergreen effect takes the sign it does. This figure shows the evidence for the leading
# explanation: inside the region, evergreen share and latitude move together, so the data
# there cannot separate the two, and the sign of the model's effect depends on whether it
# has a location term. Separating a covariate's effect from a flexible spatial term is a
# known problem in spatial regression (spatial confounding: Hodges and Reich 2010,
# Paciorek 2010). May only: with April, the month of the largest 6 to 4.5 ka change in the
# region (about -0.095 in each; the 20 October checks in the questions file for Andria). A
# diagnostic, not a pipeline step: run it by hand after scripts 4 and 6, from the
# repository root:
#   Rscript tools/plotting/plot_northeast_cover_and_location.R [--config <file>]
#
# WHAT COMES IN
#   output/calibration/calibration_prediction_fit_may_bluesky.RDS   script 4: the fit the
#       hindcast uses (config.R analysis$calibration$model_id, REML); its fitting data are
#       today's cover and albedo
#   output/calibration/calibration_mod_cover_elev_may.RDS          script 4: the same
#       cover and elevation terms without the location term, fitted to the same data (REML)
#   output/prediction/paleo_interp_predict_gam_bluesky.RDS          script 6: past cover
#
# WHAT GOES OUT
#   figures/diagnostics/northeast_cover_and_location.png
#     a. today's evergreen share against latitude, in the region
#     b. today's May albedo against evergreen share, coloured by latitude
#     c. the model's May albedo, averaged over the region's cells, as evergreen replaces
#        summergreen with open land held at its 6 ka level; with and without the location
#        term; today's evergreen range in the region shaded; the mixes at 6 and 4.5 ka marked
#   The log prints the numbers behind each panel, including the evergreen slope with
#   latitude held fixed, the region's 6 to 4.5 ka change under each model, and the share of
#   cells outside the training range along the lines of panel c (R/training_support.R).
#
# The region is the northeast box of R/regions.R (the region of figure 4a of Dawson et al.
# 2025). The model label in panel c comes from the configuration, as in script 5.

source('R/run_manifest.R')
source('R/model_registry.R')
source('R/regions.R')
source('R/training_support.R')
run   = run_begin('plot_northeast_cover_and_location')
cfg   = run$cfg
paths = run$paths

library(ggplot2)
library(patchwork)

REGION = 'Northeast (hemlock box)'
# The lines of panel c run a little beyond today's evergreen range in the region (0.09 to
# 0.50 in the 18 October run) on both sides, so the reader sees how each model behaves there.
EVERGREEN_STEPS = seq(0.05, 0.65, by = 0.01)

with_location    = read_input(run, path_file(paths, 'calibration_prediction_fit', month = 'may'))
without_location = read_input(run, path_file(paths, 'calibration_spatial', month = 'may', model = 'cover_elev'))
# The caption says both fits use the same cells: compare the data, not only the row count.
fitting_columns = c('may', 'elev', 'OL', 'ET', 'ST')
if (!isTRUE(all.equal(with_location$model[, fitting_columns], without_location$model[, fitting_columns], check.attributes = FALSE)))
  stop('the two May fits were not fitted to the same data', call. = FALSE)
model_label = CALIBRATION_MODELS[[cfg$analysis$calibration$model_id]]$label

today = with_location$model
today$albedo = today$may
hull = training_hull(today)
today_ne = today[region_of(today$x, today$y) == REGION, ]

# Cover does not depend on the month: one month's rows hold every cell and slice once.
hindcast = read_input(run, path_file(paths, 'prediction_point'))
hindcast = hindcast[hindcast$month == 'may' & region_of(hindcast$x, hindcast$y) == REGION,
                    c('year', 'x', 'y', 'elev', 'OL', 'ET', 'ST')]
at_6ka   = hindcast[hindcast$year == 6000, ]
at_4.5ka = hindcast[hindcast$year == 4500, ]
at_4.5ka = at_4.5ka[match(paste(at_6ka$x, at_6ka$y), paste(at_4.5ka$x, at_4.5ka$y)), ]
if (anyNA(at_4.5ka$ET)) stop('a 6 ka cell of the region has no 4.5 ka row', call. = FALSE)
# Panel c sets evergreen step by step with each cell's 6 ka open land kept; summergreen must
# not go negative, or a line would average over fewer cells at its high end.
if (max(EVERGREEN_STEPS) > 1 - max(at_6ka$OL))
  stop('the evergreen steps of panel c leave no room for summergreen in some cells', call. = FALSE)

# --- the numbers -------------------------------------------------------------------------
cor_ET_lat_region = cor(today_ne$ET, today_ne$y)
cor_ET_lat_all    = cor(today$ET, today$y)
cor_albedo_ET     = cor(today_ne$albedo, today_ne$ET)
cor_albedo_lat    = cor(today_ne$albedo, today_ne$y)
# Albedo on evergreen share and latitude together: the evergreen slope at fixed latitude.
fixed_latitude = summary(lm(albedo ~ ET + y, data = today_ne))$coefficients['ET', ]
outside_6ka   = mean(training_support(at_6ka, hull)$outside)
outside_4.5ka = mean(training_support(at_4.5ka, hull)$outside)
cat(sprintf('northeast today: %d cells | evergreen share %.2f to %.2f | open land %.2f to %.2f (median %.2f)\n',
            nrow(today_ne), min(today_ne$ET), max(today_ne$ET), min(today_ne$OL), max(today_ne$OL), median(today_ne$OL)))
cat(sprintf('correlation of evergreen share with latitude: %.2f in the northeast, %.2f over all %d fitting cells\n',
            cor_ET_lat_region, cor_ET_lat_all, nrow(today)))
cat(sprintf('correlation of May albedo in the northeast with evergreen share: %.2f; with latitude: %.2f\n',
            cor_albedo_ET, cor_albedo_lat))
cat(sprintf('evergreen slope at fixed latitude: %+.3f (standard error %.3f, p = %.2f) albedo per unit share\n',
            fixed_latitude['Estimate'], fixed_latitude['Std. Error'], fixed_latitude['Pr(>|t|)']))
cat(sprintf('northeast past cover, %d cells: 6 ka evergreen %.2f, open land %.2f (%.2f to %.2f) | 4.5 ka evergreen %.2f, open land %.2f\n',
            nrow(at_6ka), mean(at_6ka$ET), mean(at_6ka$OL), min(at_6ka$OL), max(at_6ka$OL), mean(at_4.5ka$ET), mean(at_4.5ka$OL)))
cat(sprintf('outside the training range: %.0f%% of the region\'s cells at 6 ka, %.0f%% at 4.5 ka\n',
            100 * outside_6ka, 100 * outside_4.5ka))

models = list('with the location term' = with_location, 'without the location term' = without_location)
past_change = do.call(rbind, lapply(names(models), function(name) {
  m = models[[name]]
  data.frame(model = name, deviance_explained = summary(m)$dev.expl,
             ET = c(mean(at_6ka$ET), mean(at_4.5ka$ET)), age = c('6 ka', '4.5 ka'),
             albedo = c(mean(predict(m, at_6ka, type = 'response')), mean(predict(m, at_4.5ka, type = 'response'))))
}))
for (name in names(models)) {
  rows = past_change[past_change$model == name, ]
  cat(sprintf('%s: deviance explained %.0f%% | northeast May albedo 6 ka %.3f, 4.5 ka %.3f, change %+.3f\n',
              name, 100 * rows$deviance_explained[1], rows$albedo[1], rows$albedo[2], rows$albedo[2] - rows$albedo[1]))
}

# Panel c: the region's 6 ka cells with evergreen set to one value, open land as it was then
# and summergreen the rest.
cells_with_evergreen = function(evergreen) {
  cells = at_6ka
  cells$ET = evergreen
  cells$ST = 1 - cells$OL - evergreen
  cells
}
curves = NULL
for (name in names(models)) for (evergreen in EVERGREEN_STEPS) {
  cells = cells_with_evergreen(evergreen)
  curves = rbind(curves, data.frame(model = name, ET = evergreen,
                                    albedo = mean(predict(models[[name]], cells, type = 'response'))))
}
# The lines' cells, judged by the training-range rule of the other diagnostic figures. The
# same cells feed both models, so one share per evergreen step.
line_support = data.frame(ET = EVERGREEN_STEPS,
  outside = sapply(EVERGREEN_STEPS, function(evergreen) mean(training_support(cells_with_evergreen(evergreen), hull)$outside)))
cat('share of the cells on the lines of panel c outside the training range, by evergreen share:\n')
every_fifth_step = line_support[seq(1, nrow(line_support), by = 5), ]
every_fifth_step$outside = round(every_fifth_step$outside, 2)
print(every_fifth_step, row.names = FALSE)
all_outside_up_to = max(line_support$ET[cumprod(line_support$outside == 1) == 1])
outside_at_6ka_evergreen = line_support$outside[which.min(abs(line_support$ET - mean(at_6ka$ET)))]

# --- a. evergreen share against latitude --------------------------------------------------
panel_latitude = ggplot(today_ne, aes(y, ET)) + geom_point(colour = 'darkgreen', size = 1.2) +
  labs(x = 'latitude (°N)', y = 'evergreen share today',
       title = 'a. Today, evergreen share rises northwards',
       subtitle = sprintf('%d cells in the region; correlation %.2f\n(over all %s fitting cells across North America: %.2f)',
                          nrow(today_ne), cor_ET_lat_region, format(nrow(today), big.mark = ','), cor_ET_lat_all)) +
  theme_bw(base_size = 9)

# --- b. today's albedo against evergreen share --------------------------------------------
panel_albedo = ggplot(today_ne, aes(ET, albedo, colour = y)) + geom_point(size = 1.2) +
  scale_colour_viridis_c(name = 'latitude\n(°N)', option = 'viridis') +
  labs(x = 'evergreen share today', y = 'May albedo today (calibration data)',
       title = 'b. Albedo falls with evergreen share, and with latitude',
       subtitle = sprintf(paste0('correlation with evergreen share %.2f, with latitude %.2f. With latitude held fixed,\n',
                                 'the evergreen slope is %+.3f per 0.1 of evergreen share (standard error %.3f, p = %.2f)'),
                          cor_albedo_ET, cor_albedo_lat, fixed_latitude['Estimate'] / 10, fixed_latitude['Std. Error'] / 10,
                          fixed_latitude['Pr(>|t|)'])) +
  theme_bw(base_size = 9)

# --- c. the model's evergreen effect, with and without the location term -----------------
model_colours = c('with the location term' = '#d95f02', 'without the location term' = '#1b9e77')
panel_model = ggplot() +
  annotate('rect', xmin = min(today_ne$ET), xmax = max(today_ne$ET), ymin = -Inf, ymax = Inf, fill = 'grey90') +
  geom_line(data = curves, aes(ET, albedo, colour = model), linewidth = 0.8) +
  geom_point(data = past_change, aes(ET, albedo, colour = model, shape = age), size = 2.4) +
  scale_colour_manual(values = model_colours, name = NULL) +
  scale_shape_manual(values = c('6 ka' = 16, '4.5 ka' = 17), name = 'past cover\n(region mean)') +
  labs(x = 'evergreen share (open land as at 6 ka; summergreen the rest)', y = 'model May albedo (region mean)',
       title = 'c. The sign of the model\'s evergreen effect depends on the location term',
       subtitle = sprintf(paste0('with: %s, the fit the hindcast uses (%.0f%% of deviance explained)\n',
                                 'without: the same cover and elevation terms only (%.0f%%); grey: today\'s evergreen range in the region'),
                          model_label, 100 * summary(with_location)$dev.expl, 100 * summary(without_location)$dev.expl)) +
  theme_bw(base_size = 9) + theme(legend.position = 'right')

figure = (panel_latitude + panel_albedo) / panel_model + plot_layout(heights = c(1, 1.1)) +
  plot_annotation(
    title = 'Northeast (80-66°W, 40-48°N): why the model\'s evergreen effect there is uncertain (May)',
    caption = paste0('Calibration data: today\'s cover (interpolated pollen-based reconstruction, 50 BP) and satellite blue-sky albedo. ',
                     'Past cover: the reconstruction at 6 and 4.5 ka, the hemlock decline.\n',
                     'Both fits are by REML on the same cells. Points in c are the models\' predictions at the actual past mixes; ',
                     'the lines hold open land fixed, so they show the evergreen-summergreen swap alone.\n',
                     sprintf(paste0('Most of the lines rest on cover mixes outside the training range (the rule of the other diagnostic figures): ',
                                    'every cell at evergreen shares up to %.2f, %.0f%% at %.2f; and %.0f%% of cells at 6 ka, %.0f%% at 4.5 ka.\n',
                                    'So the lines show that the data do not fix the sign of the evergreen effect, not what the true effect is.'),
                             all_outside_up_to, 100 * outside_at_6ka_evergreen, mean(at_6ka$ET), 100 * outside_6ka, 100 * outside_4.5ka)),
    theme = theme(plot.title = element_text(size = 12, face = 'bold'), plot.caption = element_text(size = 7, hjust = 0)))

figure_file = path_figure(paths, 'diagnostics', 'northeast_cover_and_location.png')
ggsave(figure_file, figure, width = 11, height = 9, dpi = 160)

run_finish(run)
