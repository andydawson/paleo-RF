# Render Holocene maps with Chris's illustrative midpoint blends (20 November 2026).
# Run: CORES=32-47 THREADS=2 tools/rscript.sh tools/animate_holocene.R
# Inputs are read only; outputs go to animations/nadi_shared/. No pipeline is run.
# Bins: Dawson et al. (2025), Climate of the Past 21, 2031-2060,
# doi:10.5194/cp-21-2031-2025, section 2.2; checked locally in
# docs/cc/2026-11-16_time_bins_codex_gpt6astra.md. Names are not exact centres.
# Surface mixture: scripts/7a_alb_diff_full.R, before readvance adjustment.
# Fixed 0.68 follows the existing assumption, whose numerical precedent and limits
# are in docs/cc/2026-11-16_glacier_albedo_codex_gpt6astra.md:
# Gandy et al. (2023), doi:10.1029/2023JF007250, Table 2 (LGM model ensemble).

started = proc.time()[['elapsed']]
library(ggplot2)
library(terra)
library(sf)
library(patchwork)
source('R/map_helpers.R')
source('R/training_support.R')   # reuse the existing cover-triangle geometry

main = '/home/expert/Documents/contracting/Andria/paleo-RF'
run_dir = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main'
out = 'animations/nadi_shared'
dir.create(file.path(out, 'frames'), recursive = TRUE, showWarnings = FALSE)
terraOptions(tempdir = out)
cfg = source(file.path(run_dir, 'config_used.R'))$value
ages = sort(cfg$analysis$ages, decreasing = TRUE)
window = cfg$presentation$map_windows$tail
land = prepare_boundaries(readRDS(file.path(main, 'data/map-data/geographic/pbs_ll.RDS')), window)
vegetation = readRDS(file.path(run_dir, 'data/lct_paleo_reveals_interp.RDS'))
predictions = readRDS(file.path(run_dir, 'output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS'))
april = subset(predictions, month == 'apr', c(x, y, year, alb_mean))
ice = rast('data/nadi1_fractions/nadi1_optimal.tif')
old_ice = rast(file.path(main, 'data/Dalton_QSR_2020_Ice/dalton_interpolated_LC6k.tif'))
glacier = read.csv('data/albedo_glacier_monthly.csv')
ice_albedo = glacier$ice_albedo_fixed[glacier$month == 'apr']
cells = unique(vegetation[c('x', 'y')])
missing_colour = '#C29AA4'
cover_natural = c(ET = '#155747', OL = '#C18C45', ST = '#A2D572')
cover_separated = c(ET = '#0072B2', OL = '#E69F00', ST = '#009E73')
ice_colours = c('#194B70', '#7AB6CD', '#F5FCFF')
albedo_neutral = c('#171717', '#FAF9F2')
albedo_cool = c('#17212D', '#566C7C', '#A8BCC4', '#FAF9F2')

# Colour encodes all three fractions; no dominant-class threshold.
cover_colour = function(d, colours) {
  colour = rep(missing_colour, nrow(d))
  available = complete.cases(d[names(colours)])
  channels = as.matrix(d[available, names(colours)]) %*% t(col2rgb(colours)) / 255
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

vegetation_map = function(d, colours) {
  d$colour = cover_colour(d, colours)
  map_base() + geom_tile(data = d, aes(x, y, fill = colour), width = 1, height = 1) +
    geom_sf(data = land, fill = NA, colour = '#68747D', linewidth = 0.15) + scale_fill_identity()
}

key = expand.grid(ET = seq(0, 1, 0.025), ST = seq(0, 1, 0.025))
key = subset(key, ET + ST <= 1)
key$OL = 1 - (key$ET + key$ST)
key = cbind(key, cover_triangle_xy(key))
cover_key = function(colours) {
  key$colour = cover_colour(key, colours)
  ggplot(key, aes(px, py, colour = colour)) +
    geom_point(shape = 15, size = 2.4) + scale_colour_identity() +
    annotate('text', x = c(0, 1, 0.5), y = c(-0.12, -0.12, 1.02), size = 3.3,
             hjust = c(1, 0, 0.5), label = c('OL: open land', 'ST: summergreen', 'ET: evergreen')) +
    coord_equal(xlim = c(-0.35, 1.35), ylim = c(-0.2, 1.1), clip = 'off') + theme_void()
}
triangle = cover_key(cover_natural)

# Older-to-younger BP bounds, including the published 2024 CE endpoint (-74 BP).
bin_bounds = function(age) {
  if (age == 50) return(c(100, -74))
  if (age == 200) return(c(350, 100))
  if (age == 500) return(c(700, 350))
  c(age + 200, age - 300)
}
bin_label = function(age) paste(bin_bounds(age), collapse = ' to ')

# Script 7a supplies the mixture; R/differences.R selects glacier albedo independently
# of vegetation at icy endpoints. Do not import its >0.5 classification threshold.
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

writeLines(c(
  'Left to right: ice fraction, vegetation composition, April surface albedo. All colour scales are fixed; scalar scales run from 0 to 1.',
  'Ice: NADI-1 best estimate (Dalton et al. 2023, doi:10.1016/j.quascirev.2023.108345), data/nadi1_fractions/nadi1_optimal.tif. Vegetation and April predictions: verified d5d5df5/run1-main; pollen bins follow Dawson et al. 2025, doi:10.5194/cp-21-2031-2025. ET and ST include shrubs.',
  'Twenty-five source slices plus 24 illustrative midpoint blends. A blend averages corresponding cells in ice fraction, ET/OL/ST and vegetation albedo, then recalculates surface albedo; it is not a new reconstruction. Missing endpoints propagate.',
  'Surface = f x 0.68 + (1-f) x vegetation albedo. Full ice is 0.68 even without vegetation; partial ice without vegetation stays missing. Ice fractions are used before any forcing readvance adjustment.',
  'Clock: black ticks are source slices, blue circles source frames, orange diamonds blends. Ages are nominal slice names; bin bounds are in frames.csv. The youngest bin is 100 to -74 BP (1850-2024 CE).',
  'Timing: 2 ms per nominal year; the 500-, 300- and 150-year gaps take 1.0, 0.6 and 0.3 seconds respectively, split equally at the midpoint. Final hold: 2.1 seconds; total: 25 seconds. Ice at 1 ka is repeated at 500, 200 and 50 BP.',
  'Evergreen is dark green, summergreen light green, open land ochre; mixtures use weighted RGB. This intuitive palette is not fully colour-blind safe. Albedo runs from dark blue-grey to ivory. Rose cells have missing inputs; background is outside the input footprint.',
  'The NADI fractions retain the old raster mask, including masked Hudson Bay waters; modern coastlines are shown. Vegetation predictions are unchanged. ice_source_changes.csv lists every changed source cell and its surface effect. Uncertainty is not shown.'
), file.path(out, 'caption.txt'))

# Explicit coordinate order is essential: merge() can order incomplete slices differently.
slices = lapply(ages, function(age) {
  d = merge(cells, subset(vegetation, ages == age, c(x, y, ET, OL, ST)), by = c('x', 'y'), all.x = TRUE)
  d = merge(d, subset(april, year == age, c(x, y, alb_mean)), by = c('x', 'y'), all.x = TRUE)
  d = d[order(d$x, d$y), ]
  d$ice_fraction = terra::extract(ice[[paste0('yr', age, 'bp')]], as.matrix(d[c('x', 'y')]))[, 1]
  d
})

# Record the requested footprint comparison without changing the vegetation predictions.
changes = lapply(seq_along(ages), function(i) {
  d = slices[[i]]
  previous = terra::extract(old_ice[[paste0('yr', ages[i], 'bp')]], as.matrix(d[c('x', 'y')]))[, 1]
  comparison = data.frame(age_bp = ages[i], d[c('x', 'y')], old_fraction = previous,
                          nadi_fraction = d$ice_fraction, vegetation_albedo = d$alb_mean,
                          old_surface = surface_albedo(previous, d$alb_mean),
                          nadi_surface = surface_albedo(d$ice_fraction, d$alb_mean))
  comparison$ice_change = comparison$nadi_fraction - comparison$old_fraction
  comparison$surface_change = comparison$nadi_surface - comparison$old_surface
  subset(comparison, ice_change != 0)
})
write.csv(do.call(rbind, changes), file.path(out, 'ice_source_changes.csv'), row.names = FALSE)

frames = data.frame(frame = seq_len(2 * length(ages) - 1), kind = rep(c('slice', 'blend'), length.out = 49))
frames$older_bp = ages[ceiling(frames$frame / 2)]
frames$younger_bp = ages[ceiling((frames$frame + 1) / 2)]
frames$position_bp = (frames$older_bp + frames$younger_bp) / 2
frames$older_bin_bp = vapply(frames$older_bp, bin_label, character(1))
frames$younger_bin_bp = vapply(frames$younger_bp, bin_label, character(1))
frames$duration_ms = c(-diff(frames$position_bp) * 2, 2100)
frames$file = ifelse(frames$kind == 'slice',
                     sprintf('frame_%02d_slice_%05dBP.png', frames$frame, frames$older_bp),
                     sprintf('frame_%02d_blend_%05d_%05dBP.png', frames$frame, frames$older_bp, frames$younger_bp))
write.csv(frames, file.path(out, 'frames.csv'), row.names = FALSE)
blend_columns = c('ET', 'OL', 'ST', 'alb_mean', 'ice_fraction')

for (frame_index in frames$frame) {
  info = frames[frame_index, ]
  source_index = ceiling(frame_index / 2)
  d = slices[[source_index]]
  if (info$kind == 'blend')
    d[blend_columns] = (d[blend_columns] + slices[[source_index + 1]][blend_columns]) / 2
  d$surface = surface_albedo(d$ice_fraction, d$alb_mean)
  p_ice = scalar_map(d, 'ice_fraction', 'Ice fraction', ice_colours)
  p_veg = vegetation_map(d, cover_natural)
  p_albedo = scalar_map(d, 'surface', 'April surface albedo', albedo_cool)   # Chris's choice, 20 November 2026
  panels = wrap_plots(p_ice, p_veg, p_albedo, plot_spacer(), triangle, plot_spacer(),
                     ncol = 3, heights = c(5, 1))
  ggsave(file.path(out, 'frames', info$file), with_clock(panels, info),
         width = 15, height = 6.4, dpi = 120, bg = 'white')

  if (info$kind == 'slice' && info$position_bp == 8000) {
    vegetation_options = wrap_plots(p_veg + labs(title = 'Natural (recommended)'),
      vegetation_map(d, cover_separated) + labs(title = 'Separated hues'),
      triangle, cover_key(cover_separated), ncol = 2, heights = c(4.5, 1))
    ggsave(file.path(out, 'vegetation_palettes_08000BP.png'), with_clock(vegetation_options, info),
           width = 12, height = 6.7, dpi = 120, bg = 'white')
    albedo_options = p_albedo + labs(title = 'Neutral brightness') +
      (scalar_map(d, 'surface', 'April surface albedo', albedo_cool) + labs(title = 'Cool blue-grey (chosen)'))
    ggsave(file.path(out, 'albedo_palettes_08000BP.png'), with_clock(albedo_options, info),
           width = 12, height = 6, dpi = 120, bg = 'white')
  }
  cat(sprintf('%s: full ice %d, full ice missing albedo %d, partial ice without vegetation %d\n', info$file,
              sum(d$ice_fraction == 1, na.rm = TRUE),
              sum(d$ice_fraction == 1 & is.na(d$surface), na.rm = TRUE),
              sum(d$ice_fraction > 0 & d$ice_fraction < 1 & is.na(d$alb_mean), na.rm = TRUE)))
}

# PIL assembles the R-rendered PNGs; no animation package or encoder is installed.
python = r"(
import csv
from pathlib import Path
from PIL import Image
base = Path('animations/nadi_shared')
rows = list(csv.DictReader((base / 'frames.csv').open()))
swatches = Image.new('RGB', (240, 105 * len(rows)), 'white')
for i, row in enumerate(rows):
    with Image.open(base / 'frames' / row['file']) as im:
        swatches.paste(im.convert('RGB').resize((240, 105)), (0, 105 * i))
palette = swatches.quantize(colors=256)
indexed = []
for row in rows:
    with Image.open(base / 'frames' / row['file']) as im:
        indexed.append(im.convert('RGB').quantize(palette=palette, dither=Image.Dither.NONE))
duration = [int(row['duration_ms']) for row in rows]
indexed[0].save(base / 'holocene_nadi_april.gif', save_all=True, append_images=indexed[1:],
                duration=duration, loop=0, disposal=2, optimize=False)
print(f'GIF: {len(indexed)} frames, {indexed[0].size}, {sum(duration)/1000:.1f} seconds')
)"
system2('python3', c('-c', shQuote(python)))
cat(sprintf('Render and GIF runtime: %.2f seconds\n', proc.time()[['elapsed']] - started))
