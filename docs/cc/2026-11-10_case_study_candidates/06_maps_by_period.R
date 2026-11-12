# Maps of what changes, by the pipeline's seven coarse periods: the reconstruction's cover,
# the three runs' albedo, how far the runs disagree, and the vegetation forcing.
# Exploration only: these figures are for looking, to see what "jumps out".
source('./case_study_helpers.R')
setwd(WORKTREE)                      # R/map_helpers.R and the boundary file are read from here
suppressPackageStartupMessages({ library(ggplot2); source('R/map_helpers.R') })
a = read_cache()
cells = a$cells; ages = a$ages

PERIOD_ENDS = c(50, 500, 2000, 4000, 6000, 8000, 10000, 11500)     # config.R analysis$coarse$ages
periods = data.frame(young = head(PERIOD_ENDS, -1), old = PERIOD_ENDS[-1])
periods$label = sprintf('%s to %s ka', format(periods$old / 1000), format(periods$young / 1000))

window = list(x = c(-170, -52), y = c(26, 75))
land = prepare_boundaries(readRDS('data/map-data/geographic/pbs_ll.RDS'), window)

# Ice-free share of a cell over a period: the smaller of the two ends, so that a cell under
# ice at either end is greyed out (its cover there is the interpolation's, not vegetation).
ice_free = function(p) 1 - pmax(a$ice[, slice_index(ages, periods$young[p])], a$ice[, slice_index(ages, periods$old[p])])

map_figure = function(table, value, title, file, limit, rows = 'row', low = '#2166ac', high = '#b2182b', width = 15, height = 6.5) {
  table$shown = pmax(pmin(table[[value]], limit), -limit)
  figure = ggplot(table) +
    geom_tile(aes(x, y, fill = shown)) +
    boundary_layers(land, window, colour = 'grey35', linewidth = 0.12) +
    facet_grid(reformulate('period', rows)) +
    scale_fill_gradient2(low = low, mid = 'white', high = high, midpoint = 0, limits = c(-limit, limit), name = NULL, na.value = 'grey80') +
    theme_bw(base_size = 8) + theme(axis.text = element_blank(), axis.ticks = element_blank(), legend.position = 'bottom',
                                    legend.key.width = unit(1.4, 'cm'), legend.key.height = unit(0.2, 'cm'), panel.grid = element_blank()) +
    labs(x = NULL, y = NULL, title = title)
  ggsave(file.path(OUT_DIR, 'figures', file), figure, width = width, height = height, dpi = 110)
}

period_table = function(values_for_period, row_levels) {
  out = do.call(rbind, lapply(seq_len(nrow(periods)), function(p) {
    v = values_for_period(p)                                   # a matrix: cells x rows
    free = ice_free(p)
    do.call(rbind, lapply(colnames(v), function(r)
      data.frame(cells[, c('x', 'y')], period = periods$label[p], row = r, value = ifelse(free > 0.5, v[, r], NA))))
  }))
  out$period = factor(out$period, rev(periods$label))            # oldest period on the left
  out$row = factor(out$row, row_levels)
  out
}

# 1. Cover change: younger minus older end of each period.
cover_change = period_table(function(p) a$cover[, slice_index(ages, periods$young[p]), ] - a$cover[, slice_index(ages, periods$old[p]), ], CLASSES)
levels(cover_change$row) = c('open land', 'evergreen', 'summergreen')
map_figure(cover_change, 'value', 'Change in cover fraction over each period (younger minus older end); red = gain; grey = more than half ice at an end',
           'cover_change_by_period.png', 0.2)

# 2. Albedo change, mean of the twelve months and by season, for the three runs.
season_months = list(annual = MONTHS, `Dec-Feb` = c('dec', 'jan', 'feb'), `Mar-May` = c('mar', 'apr', 'may'),
                     `Jun-Aug` = c('jun', 'jul', 'aug'), `Sep-Nov` = c('sep', 'oct', 'nov'))
albedo_change = function(run, p, months) {
  d = a$fitted_albedo[[run]][, slice_index(ages, periods$young[p]), months, drop = FALSE] -
      a$fitted_albedo[[run]][, slice_index(ages, periods$old[p]),   months, drop = FALSE]
  rowMeans(d[, 1, , drop = FALSE])
}
for (season in names(season_months)) {
  t = period_table(function(p) sapply(names(RUNS), function(run) albedo_change(run, p, season_months[[season]])), names(RUNS))
  levels(t$row) = RUN_LABELS[levels(t$row)]
  map_figure(t, 'value', sprintf('Fitted albedo change over each period, %s mean (younger minus older); orange = brighter, purple = darker', season),
             sprintf('albedo_change_%s.png', gsub('-', '_', tolower(season))), 0.08, low = '#542788', high = '#e08214')
}

# 3. Disagreement between the runs on the annual albedo change: the range of the three, and
#    whether they agree in sign.
annual = lapply(seq_len(nrow(periods)), function(p) sapply(names(RUNS), function(run) albedo_change(run, p, MONTHS)))
spread = period_table(function(p) cbind(`range of the three runs` = apply(annual[[p]], 1, max) - apply(annual[[p]], 1, min),
                                        `mean of the three runs` = rowMeans(annual[[p]]),
                                        `agree in sign (+1 brighter, -1 darker, 0 no)` = ifelse(apply(sign(annual[[p]]), 1, function(s) length(unique(s)) == 1), sign(annual[[p]][, 1]), 0) * 0.04),
                      c('mean of the three runs', 'range of the three runs', 'agree in sign (+1 brighter, -1 darker, 0 no)'))
map_figure(spread, 'value', 'Annual-mean fitted albedo change: the mean of the three runs, their range, and where they agree in sign',
           'albedo_change_agreement.png', 0.06, low = '#542788', high = '#e08214')

# 4. Vegetation forcing (HadGEM3 kernel), summed over the period's pairs, mean of the months.
pair_index = function(p) which(a$pairs >= periods$young[p] & a$pairs < periods$old[p])
forcing = period_table(function(p) sapply(names(RUNS), function(run)
  rowMeans(apply(a$forcing[[run]]$hadgem_veg_part[, pair_index(p), , drop = FALSE], c(1, 3), sum), na.rm = TRUE)), names(RUNS))
levels(forcing$row) = RUN_LABELS[levels(forcing$row)]
map_figure(forcing, 'value', 'Vegetation forcing over each period, W/m2 in the cell (HadGEM3 kernel, mean of the months); red = warming',
           'vegetation_forcing_by_period.png', 6)
cat('figures written to', file.path(OUT_DIR, 'figures'), '\n')
