# Render Holocene maps with Chris's illustrative midpoint blends (20 November 2026).
# Run from the repository root, with a finished run of the pipeline (scripts 1 to 6 at least):
#   Rscript tools/animate_holocene.R <run folder>
#   python3 tools/make_holocene_gif.py figures/animations
# (On Linux, tools/rscript.sh may be used in place of Rscript.) The R step writes the PNG frames,
# frames.csv and caption.txt to figures/animations/; the Python step joins the frames into the GIF.
# Inputs are read only. No pipeline is run.
# Bins: Dawson et al. (2025), Climate of the Past 21, 2031-2060,
# doi:10.5194/cp-21-2031-2025, section 2.2; checked locally in
# docs/cc/2026-11-16_time_bins_codex_gpt6astra.md. Names are not exact centres.
# Surface mixture: the same area-weighted mixture whose slice-to-slice differences are
# partial_ice_differences() in R/differences.R, before the readvance adjustment.
# Glacier albedo: ice_albedo_fixed from data/albedo_glacier_monthly.csv, the existing assumption,
# whose numerical precedent and limits are in docs/cc/2026-11-16_glacier_albedo_codex_gpt6astra.md:
# Gandy et al. (2023), doi:10.1029/2023JF007250, Table 2 (LGM model ensemble).

library(ggplot2)
library(terra)
library(sf)
library(patchwork)
source('R/map_helpers.R')
source('R/training_support.R')   # reuse the existing cover-triangle geometry

args = commandArgs(trailingOnly = TRUE)
if (length(args) != 1) {
  cat('usage: Rscript tools/animate_holocene.R <run folder>\n')
  quit(status = 2)
}
run_dir = args[1]
out = 'figures/animations'
dir.create(file.path(out, 'frames'), recursive = TRUE, showWarnings = FALSE)
cfg = source(file.path(run_dir, 'config_used.R'))$value
ages = sort(cfg$analysis$ages, decreasing = TRUE)
window = cfg$presentation$map_windows$tail
land = prepare_boundaries(readRDS('data/map-data/geographic/pbs_ll.RDS'), window)
vegetation = readRDS(file.path(run_dir, 'data/lct_paleo_reveals_interp.RDS'))
predictions = readRDS(file.path(run_dir, 'output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS'))
april = subset(predictions, month == 'apr', c(x, y, year, alb_mean))
ice = rast('data/nadi1_fractions/nadi1_optimal.tif')
glacier = read.csv('data/albedo_glacier_monthly.csv')
ice_albedo = glacier$ice_albedo_fixed[glacier$month == 'apr']
cells = unique(vegetation[c('x', 'y')])
missing_colour = '#C29AA4'
cover_natural = c(ET = '#155747', OL = '#C18C45', ST = '#A2D572')
ice_colours = c('#194B70', '#7AB6CD', '#F5FCFF')
albedo_cool = c('#17212D', '#566C7C', '#A8BCC4', '#FAF9F2')   # Chris's choice, 20 November 2026

# Colour encodes all three fractions; no dominant-class threshold.
cover_colour = function(d) {
  colour = rep(missing_colour, nrow(d))
  available = complete.cases(d[names(cover_natural)])
  channels = as.matrix(d[available, names(cover_natural)]) %*% t(col2rgb(cover_natural)) / 255
  colour[available] = rgb(channels[, 1], channels[, 2], channels[, 3])
  colour
}

map_base = function() {
  ggplot() + boundary_layers(land, window, fill = '#EEEAE2') + theme_void(base_size = 12) +
    theme(panel.background = element_rect(fill = '#EDF4F8', colour = NA),
          plot.title = element_text(face = 'bold', size = 14), legend.position = 'bottom',
          plot.margin = margin(4, 8, 4, 8))
}

scalar_map = function(d, value, label, colours) {
  map_base() + geom_tile(data = d, aes(x, y, fill = .data[[value]]), width = 1, height = 1) +
    geom_sf(data = land, fill = NA, colour = '#68747D', linewidth = 0.15) +
    scale_fill_gradientn(colours = colours, limits = c(0, 1), na.value = missing_colour,
                         name = label, breaks = c(0, 0.25, 0.5, 0.75, 1))
}

vegetation_map = function(d) {
  d$colour = cover_colour(d)
  map_base() + geom_tile(data = d, aes(x, y, fill = colour), width = 1, height = 1) +
    geom_sf(data = land, fill = NA, colour = '#68747D', linewidth = 0.15) + scale_fill_identity()
}

key = expand.grid(ET = seq(0, 1, 0.025), ST = seq(0, 1, 0.025))
key = subset(key, ET + ST <= 1)
key$OL = 1 - (key$ET + key$ST)
key = cbind(key, cover_triangle_xy(key))
key$colour = cover_colour(key)
triangle = ggplot(key, aes(px, py, colour = colour)) +
  geom_point(shape = 15, size = 2.4) + scale_colour_identity() +
  annotate('text', x = c(0, 1, 0.5), y = c(-0.12, -0.12, 1.02), size = 3.3,
           hjust = c(1, 0, 0.5), label = c('OL: open land', 'ST: summergreen', 'ET: evergreen')) +
  coord_equal(xlim = c(-0.35, 1.35), ylim = c(-0.2, 1.1), clip = 'off') + theme_void()

# The mixture of partial_ice_differences() (R/differences.R); glacier albedo is selected
# independently of vegetation at full ice. Do not import its >0.5 classification threshold.
surface_albedo = function(fraction, vegetation_albedo) {
  surface = fraction * ice_albedo + (1 - fraction) * vegetation_albedo
  surface[which(fraction == 1)] = ice_albedo
  surface
}

with_clock = function(p, info) {
  blended = info$kind == 'blend'
  label = paste0(format(info$position_bp, big.mark = ',', trim = TRUE), ' BP',
                 if (blended) ' | blend' else '')
  clock = ggplot(data.frame(age = ages), aes(age, 0)) +
    geom_hline(yintercept = 0, colour = 'grey65') +
    geom_linerange(aes(ymin = -0.08, ymax = 0.08), linewidth = 0.4) +
    annotate('point', x = info$position_bp, y = 0, size = 3,
             shape = if (blended) 18 else 16, colour = if (blended) '#D66B12' else '#12618C') +
    annotate('text', x = 11500, y = 0.32, label = label, hjust = 0, size = 4.5) +
    scale_x_reverse(limits = c(11500, 50), breaks = c(11500, 10000, 8000, 6000, 4000, 2000, 1000, 50)) +
    coord_cartesian(ylim = c(-0.1, 0.5), clip = 'off') + theme_void(base_size = 10) +
    theme(axis.text.x = element_text(), plot.margin = margin(4, 30, 4, 30))
  wrap_plots(p, clock, ncol = 1, heights = c(10, 1)) + plot_annotation(
    theme = theme(plot.background = element_rect(fill = 'white', colour = NA),
                  plot.margin = margin(8, 12, 8, 12)))
}

# Odd frames are source slices, even frames the midpoint blend of the two slices around them.
# frames.csv gives the GIF step (tools/make_holocene_gif.py) the order, files and durations.
frames = data.frame(frame = seq_len(2 * length(ages) - 1))
frames$kind = ifelse(frames$frame %% 2 == 1, 'slice', 'blend')
frames$older_bp = ages[ceiling(frames$frame / 2)]
frames$younger_bp = ages[ceiling((frames$frame + 1) / 2)]
frames$position_bp = (frames$older_bp + frames$younger_bp) / 2
frames$duration_ms = c(-diff(frames$position_bp) * 2, 2100)
frames$file = ifelse(frames$kind == 'slice',
                     sprintf('frame_%02d_slice_%05dBP.png', frames$frame, frames$older_bp),
                     sprintf('frame_%02d_blend_%05d_%05dBP.png', frames$frame, frames$older_bp, frames$younger_bp))
write.csv(frames, file.path(out, 'frames.csv'), row.names = FALSE)

writeLines(c(
  'Left to right: ice fraction, vegetation composition, April surface albedo. All colour scales are fixed; scalar scales run from 0 to 1.',
  sprintf('Ice: NADI-1 best estimate (Dalton et al. 2023, doi:10.1016/j.quascirev.2023.108345), data/nadi1_fractions/nadi1_optimal.tif. Vegetation and April predictions: run %s; pollen bins follow Dawson et al. 2025, doi:10.5194/cp-21-2031-2025. ET and ST include shrubs.', run_dir),
  sprintf('%d source slices plus %d illustrative midpoint blends. A blend averages corresponding cells in ice fraction, ET/OL/ST and vegetation albedo, then recalculates surface albedo; it is not a new reconstruction. Missing endpoints propagate.',
          sum(frames$kind == 'slice'), sum(frames$kind == 'blend')),
  sprintf('Surface = f x %.2f + (1-f) x vegetation albedo. Full ice is %.2f even without vegetation; partial ice without vegetation stays missing. Ice fractions are used before any forcing readvance adjustment.',
          ice_albedo, ice_albedo),
  'Clock: black ticks are source slices, blue circles source frames, orange diamonds blends. Ages are nominal slice names, not bin centres. The youngest bin is 100 to -74 BP (1850-2024 CE).',
  sprintf('Timing: 2 ms per nominal year; the 500-, 300- and 150-year gaps take 1.0, 0.6 and 0.3 seconds respectively, split equally at the midpoint. Final hold: 2.1 seconds; total: %.1f seconds. Ice at 1 ka is repeated at 500, 200 and 50 BP.',
          sum(frames$duration_ms) / 1000),
  'Evergreen is dark green, summergreen light green, open land ochre; mixtures use weighted RGB. This intuitive palette is not fully colour-blind safe. Albedo runs from dark blue-grey to ivory. Rose cells have missing inputs; background is outside the input footprint. The GIF uses one shared 256-colour palette for all frames.',
  'The NADI fractions retain the old raster mask, including masked Hudson Bay waters; modern coastlines are shown. Vegetation predictions are unchanged. Uncertainty is not shown.'
), file.path(out, 'caption.txt'))

# Explicit coordinate order is essential: merge() can order incomplete slices differently.
slices = lapply(ages, function(age) {
  d = merge(cells, subset(vegetation, ages == age, c(x, y, ET, OL, ST)), by = c('x', 'y'), all.x = TRUE)
  d = merge(d, subset(april, year == age, c(x, y, alb_mean)), by = c('x', 'y'), all.x = TRUE)
  d = d[order(d$x, d$y), ]
  d$ice_fraction = terra::extract(ice[[paste0('yr', age, 'bp')]], as.matrix(d[c('x', 'y')]))[, 1]
  d
})

blend_columns = c('ET', 'OL', 'ST', 'alb_mean', 'ice_fraction')
for (frame_index in frames$frame) {
  info = frames[frame_index, ]
  source_index = ceiling(frame_index / 2)
  d = slices[[source_index]]
  if (info$kind == 'blend')
    d[blend_columns] = (d[blend_columns] + slices[[source_index + 1]][blend_columns]) / 2
  d$surface = surface_albedo(d$ice_fraction, d$alb_mean)
  panels = wrap_plots(scalar_map(d, 'ice_fraction', 'Ice fraction', ice_colours), vegetation_map(d),
                      scalar_map(d, 'surface', 'April surface albedo', albedo_cool),
                      plot_spacer(), triangle, plot_spacer(), ncol = 3, heights = c(5, 1))
  ggsave(file.path(out, 'frames', info$file), with_clock(panels, info),
         width = 15, height = 6.4, dpi = 120, bg = 'white')
}
