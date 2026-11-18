# compare_ice.R: the old ice raster and the NADI-1 reconstruction side by side, for the meeting
# with Andria: where and when the two differ, when a cell's ice coverage increases and what
# script 7a's readvance averaging does to that, why the partial-ice total still holds when ice
# advances, and how the forcing changes. A diagnostic, not a pipeline step (Chris, 16 November
# 2026; design: docs/cc/2026-11-16_ice_redesign_simpler_codex_gpt6astra.md, section 4). Run it by
# hand from the repository root once the runs have finished:
#   Rscript tools/compare_ice.R <output-dir> <run-dir> [<run-dir> ...]
# Each run directory holds a finished run of scripts 7a to 10. Which ice a run used is read from
# its script 7a run record (the ice-fraction file it read, R/paths.R): one run must have read the
# old raster ("dalton_ice"), and each NADI-1 reconstruction may come once. With the old-ice run
# alone, everything about NADI-1 that needs no forcing run is still made.
#
# WHAT COMES IN (nothing is written into the run directories)
#   the four ice-fraction files of R/paths.R: dalton_ice, nadi1_optimal, nadi1_minimum, nadi1_maximum
#   from each run: its newest run records of scripts 7a and 9 (runs/), which name the ice file
#     with its MD5 sum and the settings; data/ALB_diffs_bluesky.RDS (script 7a: the ice fractions
#     after the readvance averaging); output/forcing/forcing_by_period.csv and
#     forcing_by_period_variant_sensitivity.csv (script 9)
#   from the old-ice run also output/forcing/RF_holocene_all_cases.RDS (script 8): its cells, the
#     forcing cells, are the fixed support of every table and map, with script 7a's cell areas
#   data/map-data/geographic/pbs_ll.RDS, the coastlines; config.R for the slices and periods
#
# WHAT GOES OUT, into <output-dir>
#   ice_by_slice.csv         ice area on the forcing cells, km2, by slice: the old raster and the
#                            three NADI-1 reconstructions, the pollen bin behind each slice name
#                            and the NADI-1 snapshot used for it
#   readvance_inventory.csv  every net increase in a cell's ice coverage from one slice to the next
#                            younger one, before (raw) and after script 7a's averaging (adjusted),
#                            and whether the averaging retained, removed or created it
#   forcing_comparison.csv   the runs' forcing by period (script 9's tables): the total for each
#                            kernel and the HadGEM3 vegetation and ice parts, domain mean and global
#                            equivalent (W/m2), and each run's difference from the old-ice run
#   ice_through_time.png, ice_difference_maps.png, readvances.png, split_diagram.png,
#   forcing_comparison.png   the five slides' figures
#   record.txt               the code version, the runs and their settings, every file read with
#                            its MD5 sum, and the counts
# The tables are plain CSV files; record.txt says what each column holds and its sign.
#
# WHAT IT DOES NOT DO: compute an albedo change, multiply by a kernel or sum over a period. The
# forcing is script 9's, as saved; the numbers of the split diagram come from the pipeline's own
# partial_ice_differences() (R/differences.R).
#
# WORDS. A "net increase in ice coverage" is a cell whose ice fraction is larger at the younger
# slice than at the older one, by any amount: an exact positive difference, not an established
# physical readvance. Some are tiny (the record counts those below 1e-6 of the cell, as a
# diagnostic only), yet script 7a's averaging acts on them as on any other. Fractions cannot show
# ice advancing on one side of a cell while it retreats on another, and snapshots cannot date what
# happened between them.

source('R/config.R')
source('R/paths.R')
source('R/run_manifest.R')     # read_manifest(), analysis_differences(), code_version()
source('R/differences.R')      # partial_ice_differences(), for the split diagram
source('R/map_helpers.R')      # prepare_boundaries(), boundary_layers()

library(terra)
library(dplyr)
library(ggplot2)
library(patchwork)

args = commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  cat('usage: Rscript tools/compare_ice.R <output-dir> <run-dir> [<run-dir> ...]\n')
  quit(status = 2)
}
out_dir = args[1]
run_dirs = args[-1]
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

cfg = load_config()                                          # this checkout's config.R
SLICES = cfg$analysis$ages                                   # years BP, youngest first
PERIODS = period_labels(cfg$analysis$coarse$ages)
SOURCES = c(dalton_ice = 'old raster', nadi1_optimal = 'NADI-1 optimal',
            nadi1_minimum = 'NADI-1 minimum', nadi1_maximum = 'NADI-1 maximum')
COLOURS = c('old raster' = '#2a78d6', 'NADI-1 optimal' = '#eb6834',     # categorical slots 1 to 4
            'NADI-1 minimum' = '#1baf7a', 'NADI-1 maximum' = '#eda100')
MAP_SLICES = c(11500, 10000, 8000, 6000, 1000)               # the difference maps of the second slide
MAP_WINDOW = list(x = c(-168, -50), y = c(38, 80))           # longitude, latitude: where the ice is
AGE_LIMITS = c(11.8, -0.1)                                   # ka, old to young, the same on every time axis
EXAMPLE = list(ice_old = 0.3, ice_young = 0.7, veg_old = 0.20, veg_young = 0.30, glacier = 0.68)   # the explainer's
# script 7a reads each ice band after reprojecting it to this spelling of WGS84
PROJ_7A = '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0'

# Every file read is noted, with its MD5 sum, for the record.
FILES_READ = character()
read_noted = function(file, reader = readRDS, ...) {
  if (!file.exists(file)) stop('missing input: ', file, call. = FALSE)
  FILES_READ <<- union(FILES_READ, file)
  reader(file, ...)
}
repository = c(baseline_paths(), list(tag = ALBEDO_TAG))     # inputs, named without making folders
in_run = function(dir) c(redirected_paths(dir), list(tag = ALBEDO_TAG))
ICE_FILES = vapply(names(SOURCES), function(id) path_file(repository, id), '')

# --- the runs ---------------------------------------------------------------------------------

# A run's newest record of one script, which must say it completed.
newest_record = function(dir, script) {
  files = sort(list.files(file.path(dir, 'runs', script), pattern = '\\.md$', full.names = TRUE))
  if (!length(files)) stop(dir, ': no run record of ', script, call. = FALSE)
  record = read_noted(files[length(files)], read_manifest)
  if (!identical(record$status, 'completed')) stop(files[length(files)], ': the run did not complete', call. = FALSE)
  record
}

# Which ice a run used: the ice-fraction file its script 7a record lists among its inputs. Its
# MD5 sum must be the file's in this checkout, so that the raw fractions read here are the run's.
open_run = function(dir) {
  inputs = newest_record(dir, '7a_alb_diff_full')$inputs
  ice = Filter(function(input) input$path %in% ICE_FILES, inputs)
  if (length(ice) != 1) stop(dir, ': script 7a did not read exactly one ice-fraction file', call. = FALSE)
  id = names(ICE_FILES)[ICE_FILES == ice[[1]]$path]
  if (!identical(ice[[1]]$md5, unname(tools::md5sum(ICE_FILES[[id]]))))
    stop(dir, ' read a different version of ', ICE_FILES[[id]], call. = FALSE)
  list(dir = dir, id = id, source = SOURCES[[id]], settings = newest_record(dir, '9_forcing_barplot')$config$analysis)
}
runs = lapply(run_dirs, open_run)
names(runs) = vapply(runs, `[[`, '', 'source')
if (anyDuplicated(names(runs))) stop('two runs used the same ice: ', paste(names(runs), collapse = ', '), call. = FALSE)
if (!'old raster' %in% names(runs)) stop('no run used the old raster (dalton_ice)', call. = FALSE)
old_run = runs[['old raster']]

# The support: the forcing cells of the old-ice run, one row each, with script 7a's area.
cells = read_noted(path_file(in_run(old_run$dir), 'forcing'))
cells = distinct(data.frame(cell_id = cells$cell_id, x = cells$x, y = cells$y, long = cells$long, lat = cells$lat,
                            area_km2 = as.numeric(cells$area) / 1e6))
if (anyDuplicated(cells$cell_id)) stop('a forcing cell with two positions or areas', call. = FALSE)

# --- the ice fractions --------------------------------------------------------------------------

# One ice file's fractions at the support cells, cells x slices, read as script 7a reads them: each
# band reprojected to PROJ_7A, then taken at the cell's prediction point. For the double-precision
# NADI-1 files the reprojection rounds to single precision (at most 3e-8); reading the same way
# keeps the raw fractions exactly those 7a's readvance averaging started from.
raw_fractions = function(file) {
  bands = read_noted(file, rast)
  years = as.numeric(sub('^yr(.*)bp$', '\\1', names(bands)))
  bands = project(bands[[match(SLICES, years)]], PROJ_7A)
  points = project(vect(as.matrix(cells[, c('x', 'y')]), crs = PROJ_7A), crs(bands))
  fractions = as.matrix(terra::extract(bands, points, ID = FALSE))
  if (anyNA(fractions)) stop(file, ': no ice fraction at some forcing cells', call. = FALSE)
  dimnames(fractions) = list(cells$cell_id, SLICES)
  fractions
}
raw = lapply(ICE_FILES, raw_fractions)
names(raw) = SOURCES[names(ICE_FILES)]

# A run's fractions after script 7a's averaging, one row per cell and pair of slices (year is the
# younger slice). Its table repeats them in every month: they must agree across months.
adjusted_fractions = function(run) {
  table = read_noted(path_file(in_run(run$dir), 'albedo_differences'))
  pairs = table[table$cell_id %in% cells$cell_id, ] %>%
    group_by(cell_id, year) %>%
    summarise(adjusted_young = first(ice_frac_young), adjusted_old = first(ice_frac_old),
              months_agree = n_distinct(ice_frac_young) == 1 && n_distinct(ice_frac_old) == 1, .groups = 'drop')
  if (!all(pairs$months_agree)) stop(run$dir, ': the ice fractions differ between months', call. = FALSE)
  if (nrow(pairs) != nrow(cells) * (length(SLICES) - 1)) stop(run$dir, ': not every forcing cell has every pair of slices', call. = FALSE)
  select(pairs, -months_agree)
}

# --- table 1: ice by slice ----------------------------------------------------------------------

# The pollen bin behind each slice name, years BP (Dawson et al. 2025, Climate of the Past 21,
# 2031-2060, doi:10.5194/cp-21-2031-2025, section 2.2, p. 2035; docs/cc/2026-11-16_time_bins_codex_gpt6astra.md):
# the 500-year bins are named by their younger end plus 300 (1000 is 1200 to 700 BP); the three
# youngest bins are 700-350, 350-100 and 100 to -74 BP. The NADI-1 snapshot used is the slice's
# own age from 1,000 BP on; the younger slices carry the 1,000 BP fractions.
pollen_bin = function(age) switch(as.character(age), '500' = c(700, 350), '200' = c(350, 100), '50' = c(100, -74), c(age + 200, age - 300))
ice_area = sapply(raw, function(fractions) colSums(fractions * cells$area_km2))
ice_by_slice = data.frame(age_bp = SLICES,
                          pollen_bin_older_bp = sapply(SLICES, function(a) pollen_bin(a)[1]),
                          pollen_bin_younger_bp = sapply(SLICES, function(a) pollen_bin(a)[2]),
                          nadi1_snapshot_bp = pmax(SLICES, 1000),
                          round(ice_area, 1), check.names = FALSE)
names(ice_by_slice)[5:8] = paste0(names(ICE_FILES), '_km2')
ice_by_slice$nadi1_optimal_minus_old_km2 = round(ice_area[, 'NADI-1 optimal'] - ice_area[, 'old raster'], 1)

# --- table 2: the readvance inventory -----------------------------------------------------------

# Each source's consecutive pairs of slices on the support, raw, and adjusted where a run used it.
pairs_of = function(source) {
  fractions = raw[[source]]
  young = seq_len(length(SLICES) - 1)
  pairs = data.frame(source = source, cell_id = rep(cells$cell_id, length(young)), x = rep(cells$x, length(young)),
                     y = rep(cells$y, length(young)), area_km2 = rep(cells$area_km2, length(young)),
                     year_old = rep(SLICES[young + 1], each = nrow(cells)), year = rep(SLICES[young], each = nrow(cells)),
                     raw_old = as.vector(fractions[, young + 1]), raw_young = as.vector(fractions[, young]))
  if (source %in% names(runs)) pairs = left_join(pairs, adjusted_fractions(runs[[source]]), by = c('cell_id', 'year'))
  else pairs$adjusted_young = pairs$adjusted_old = NA_real_
  pairs %>% mutate(raw_increase = raw_young - raw_old, adjusted_increase = adjusted_young - adjusted_old,
                   raw_area_increase_km2 = raw_increase * area_km2, adjusted_area_increase_km2 = adjusted_increase * area_km2,
                   averaging = case_when(is.na(adjusted_increase) ~ 'no run',
                                         raw_increase > 0 & adjusted_increase > 0 ~ 'retained',
                                         raw_increase > 0 ~ 'removed',
                                         adjusted_increase > 0 ~ 'created',
                                         TRUE ~ 'no increase'))
}
all_pairs = bind_rows(lapply(names(raw), pairs_of))
inventory = all_pairs %>% filter(raw_increase > 0 | coalesce(adjusted_increase > 0, FALSE)) %>%
  select(source, cell_id, x, y, year_old, year_young = year, raw_old, raw_young, raw_increase, raw_area_increase_km2,
         adjusted_old, adjusted_young, adjusted_increase, adjusted_area_increase_km2, averaging)
# NA, not 0, where no run used that ice.
counts = all_pairs %>% group_by(source) %>%
  summarise(raw_increases = sum(raw_increase > 0), tiny_raw_increases = sum(raw_increase > 0 & raw_increase < 1e-6),
            adjusted_increases = sum(adjusted_increase > 0),
            retained = sum(averaging == 'retained'), removed = sum(averaging == 'removed'), created = sum(averaging == 'created'),
            cells_with_raw_increase = n_distinct(cell_id[raw_increase > 0]), .groups = 'drop') %>%
  mutate(across(c(retained, removed, created), ~ ifelse(is.na(adjusted_increases), NA, .x))) %>%
  arrange(match(source, SOURCES))

# --- table 3: the forcing ------------------------------------------------------------------------

# Runs made before 16 November 2026, and the legacy configuration, label the oldest period
# 10 - 12 ka: the same slice pairs as config.R's 10 - 11.5 ka, named so here (the saved label is kept).
same_period = function(label) sub('^10 - 12 ka$', '10 - 11.5 ka', label)
PARTS = c(veg_part = 'vegetation part', ice_part = 'ice part',
          veg_part_exposed = 'vegetation part, second rule', ice_part_exposed = 'ice part, second rule')
forcing_of = function(run) {
  folder = in_run(run$dir)
  totals = read_noted(path_file(folder, 'forcing_by_period'), read.csv) %>%
    transmute(period_saved = period, kernel, variant = run$settings$forcing$variant[[1]], quantity = 'total', domain_mean, global_equiv)
  parts = read_noted(path_file(folder, 'forcing_variant_sensitivity'), read.csv) %>% filter(variant %in% names(PARTS)) %>%
    transmute(period_saved = period, kernel = 'hadgem', variant, quantity = unname(PARTS[variant]), domain_mean, global_equiv)
  bind_rows(totals, parts) %>% mutate(source = run$source, period = same_period(period_saved), .before = 1)
}
forcing = bind_rows(lapply(runs, forcing_of))
if (!all(forcing$period %in% PERIODS)) stop('a run has periods other than those of config.R: ', paste(setdiff(forcing$period, PERIODS), collapse = ', '), call. = FALSE)
old_values = forcing %>% filter(source == 'old raster') %>% select(period, kernel, variant, old_domain = domain_mean, old_global = global_equiv)
forcing = forcing %>% left_join(old_values, by = c('period', 'kernel', 'variant')) %>%
  mutate(domain_mean_minus_old = domain_mean - old_domain, global_equiv_minus_old = global_equiv - old_global) %>%
  select(-old_domain, -old_global) %>%
  arrange(match(quantity, c('total', PARTS)), match(kernel, c('hadgem', 'cam5', 'cack')), match(period, PERIODS), match(source, SOURCES))

write.csv(ice_by_slice, file.path(out_dir, 'ice_by_slice.csv'), row.names = FALSE)
write.csv(inventory, file.path(out_dir, 'readvance_inventory.csv'), row.names = FALSE)
write.csv(forcing, file.path(out_dir, 'forcing_comparison.csv'), row.names = FALSE)

# --- the figures -----------------------------------------------------------------------------------

theme_slides = function() theme_bw(base_size = 12) +
  theme(panel.grid.minor = element_blank(), legend.position = 'bottom', legend.box = 'vertical', legend.spacing.y = unit(0, 'pt'),
        legend.margin = margin(0, 0, 0, 0), plot.title.position = 'plot')
theme_map = function() theme_slides() + theme(axis.text = element_blank(), axis.ticks = element_blank(), legend.position = 'right')
save_png = function(plot, name, width, height) ggsave(file.path(out_dir, name), plot, width = width, height = height, dpi = 150)
ka = function(age_bp) age_bp / 1000
age_axis = function(...) scale_x_reverse(limits = AGE_LIMITS, breaks = 0:12, ...)
place = function(x, y) sprintf('%.1f W, %.1f N', -x, y)

# 1. Ice through time, and how the slices line up with the pollen bins and the NADI-1 snapshots.
area = data.frame(age_bp = rep(SLICES, ncol(ice_area)), source = rep(colnames(ice_area), each = length(SLICES)),
                  km2 = as.vector(ice_area), carried = SLICES < 1000 & rep(colnames(ice_area), each = length(SLICES)) != 'old raster')
shown = filter(area, source %in% c('old raster', 'NADI-1 optimal'))
p_area = ggplot() +
  geom_ribbon(data = data.frame(age_bp = SLICES, low = ice_area[, 'NADI-1 minimum'], high = ice_area[, 'NADI-1 maximum']),
              aes(ka(age_bp), ymin = low / 1e6, ymax = high / 1e6, fill = 'NADI-1 minimum to maximum'), alpha = 0.15) +
  geom_line(data = shown, aes(ka(age_bp), km2 / 1e6, colour = source), linewidth = 0.8) +
  geom_point(data = shown, aes(ka(age_bp), km2 / 1e6, colour = source, shape = carried), size = 2.2) +
  scale_colour_manual(values = COLOURS, breaks = c('old raster', 'NADI-1 optimal'), name = NULL) +
  scale_fill_manual(values = c('NADI-1 minimum to maximum' = COLOURS[['NADI-1 optimal']]), name = NULL) +
  scale_shape_manual(values = c(`FALSE` = 16, `TRUE` = 1), labels = c('snapshot of the slice\'s own age', '1 ka carried forward'), name = NULL) +
  guides(colour = guide_legend(order = 1), fill = guide_legend(order = 2), shape = guide_legend(order = 3)) +
  age_axis() +
  labs(x = NULL, y = 'ice on the forcing cells\n(million km2)', title = 'Ice through time: the old raster and NADI-1',
       subtitle = sprintf('Raw fractions (before script 7a\'s averaging) times cell area, %d forcing cells', nrow(cells))) +
  theme_slides()
alignment = ice_by_slice %>% mutate(slice = factor(age_bp, levels = SLICES))
p_align = ggplot(alignment) +
  geom_segment(aes(x = ka(pollen_bin_older_bp), xend = ka(pollen_bin_younger_bp), y = slice, yend = slice, colour = 'pollen bin of the slice'), linewidth = 2.5) +
  geom_point(aes(ka(age_bp), slice, shape = 'slice name'), size = 1.8) +
  geom_point(aes(ka(nadi1_snapshot_bp), slice, shape = 'NADI-1 snapshot used'), size = 2.2, colour = COLOURS[['NADI-1 optimal']]) +
  scale_colour_manual(values = c('pollen bin of the slice' = 'grey75'), name = NULL) +
  scale_shape_manual(values = c('slice name' = 16, 'NADI-1 snapshot used' = 4), breaks = c('slice name', 'NADI-1 snapshot used'), name = NULL) +
  guides(shape = guide_legend(override.aes = list(colour = c('black', COLOURS[['NADI-1 optimal']])))) +
  age_axis() +
  scale_y_discrete(breaks = as.character(c(50, 500, 2000, 4000, 6000, 8000, 10000, 11500))) +
  labs(x = 'age (thousand years before 1950)', y = 'slice (years BP)') +
  theme_slides() + theme(panel.grid.major.y = element_blank())
save_png(p_area / p_align + plot_layout(heights = c(2, 1.4)), 'ice_through_time.png', 9, 8)

# 2. Where the ice differs: NADI-1 optimal minus the old raster, on the forcing cells with ice in either.
land = prepare_boundaries(read_noted(path_file(repository, 'boundaries_ll')), MAP_WINDOW)
difference_maps = bind_rows(lapply(MAP_SLICES, function(age) {
  old = raw[['old raster']][, as.character(age)]; nadi = raw[['NADI-1 optimal']][, as.character(age)]
  data.frame(long = cells$long, lat = cells$lat, slice = paste(ka(age), 'ka'), difference = nadi - old)[old > 0 | nadi > 0, ]
}))
difference_maps$slice = factor(difference_maps$slice, levels = paste(ka(MAP_SLICES), 'ka'))
p_maps = ggplot(difference_maps) +
  geom_tile(aes(long, lat, fill = difference), width = 1, height = 1) +
  boundary_layers(land, MAP_WINDOW) +
  facet_wrap(~ slice, nrow = 2) +
  scale_fill_gradient2(low = '#e34948', mid = '#f0efec', high = '#2a78d6', midpoint = 0, limits = c(-1, 1),
                       name = 'ice fraction,\nNADI-1 optimal\nminus old raster') +
  labs(x = NULL, y = NULL, title = 'Where the ice differs',
       subtitle = 'Blue: more ice in NADI-1; red: less. Forcing cells with ice in either, raw fractions') +
  theme_map()
save_png(p_maps, 'ice_difference_maps.png', 12, 6.5)

# 3. When coverage increases: counts by pair of slices, where, and one cell's chronology.
by_pair = all_pairs %>% filter(source %in% c('old raster', 'NADI-1 optimal')) %>% group_by(source, year) %>%
  summarise(raw = sum(raw_increase > 0), `after averaging` = sum(adjusted_increase > 0), .groups = 'drop') %>%
  tidyr::pivot_longer(c(raw, `after averaging`), names_to = 'fractions', values_to = 'pairs') %>% filter(!is.na(pairs)) %>%
  mutate(source = factor(source, levels = SOURCES), fractions = factor(fractions, levels = c('raw', 'after averaging')))
p_counts = ggplot(by_pair, aes(ka(year), pairs, colour = source, linetype = fractions)) +
  geom_line(linewidth = 0.8) + geom_point(size = 1.8) +
  scale_colour_manual(values = COLOURS, name = NULL) + scale_linetype_manual(values = c(raw = 'solid', `after averaging` = 'dashed'), name = NULL) +
  age_axis() +
  labs(x = 'younger slice of the pair (ka)', y = 'cells whose ice\nfraction increases', title = 'When coverage increases') +
  theme_slides()
where = all_pairs %>% filter(source %in% c('old raster', 'NADI-1 optimal'), raw_increase > 0) %>%
  group_by(source, cell_id) %>% summarise(pairs = n(), .groups = 'drop') %>% left_join(cells, by = 'cell_id') %>%
  mutate(source = factor(source, levels = SOURCES))
p_where = ggplot(where) +
  geom_tile(aes(long, lat, fill = pairs), width = 1, height = 1) +
  boundary_layers(land, MAP_WINDOW) + facet_wrap(~ source) +
  scale_fill_gradient(low = '#86b6ef', high = '#0d366b', name = 'pairs of slices\nwith a raw increase') +
  labs(x = NULL, y = NULL, subtitle = 'Where: cells with a raw increase in any pair of slices') +
  theme_map()
# The old-raster cell where script 7a's averaging creates the largest increase, slice by slice.
old_pairs = filter(all_pairs, source == 'old raster')
example = old_pairs$cell_id[which.max(ifelse(old_pairs$averaging == 'created', old_pairs$adjusted_increase, -Inf))]
cell_pairs = old_pairs[old_pairs$cell_id == example, ] %>% arrange(year)
chronology = data.frame(age_bp = rep(SLICES, 2), fractions = factor(rep(c('raw', 'after averaging'), each = length(SLICES)), levels = c('raw', 'after averaging')),
                        fraction = c(raw[['old raster']][as.character(example), ], cell_pairs$adjusted_young, tail(cell_pairs$adjusted_old, 1)))
created = cell_pairs[cell_pairs$averaging == 'created', ]
p_cell = ggplot(chronology, aes(ka(age_bp), fraction, linetype = fractions)) +
  geom_line(colour = COLOURS[['old raster']], linewidth = 0.8) + geom_point(colour = COLOURS[['old raster']], size = 1.8) +
  annotate('rect', xmin = ka(created$year), xmax = ka(created$year_old), ymin = -Inf, ymax = Inf, fill = 'grey50', alpha = 0.15) +
  scale_linetype_manual(values = c(raw = 'solid', `after averaging` = 'dashed'), name = NULL) +
  age_axis() +
  labs(x = 'age (ka)', y = 'ice fraction', subtitle = sprintf('One cell (%s), old raster: the shaded pairs gain ice only after averaging',
                                                       place(cells$x[cells$cell_id == example], cells$y[cells$cell_id == example]))) +
  theme_slides()
save_png(p_counts / p_where / p_cell + plot_layout(heights = c(1, 1.3, 1)), 'readvances.png', 10, 12)

# 4. Why the total still works: one cell at two slices, and the land each split's vegetation part counts.
example_cell = data.frame(alb_veg = c(EXAMPLE$veg_young, EXAMPLE$veg_old), ice_albedo_fixed = EXAMPLE$glacier, ice_albedo_sc = EXAMPLE$glacier)
split_case = function(case, ice_old, ice_young) {
  parts = partial_ice_differences(example_cell, ice_young, ice_old, 'endpoint')
  rows = c('older slice', 'younger slice', 'vegetation part, today\'s rule', 'vegetation part, second rule')
  bars = data.frame(case = case, row = factor(rep(rows[1:2], each = 2), levels = rev(rows)), kind = rep(c('ice', 'ice-free land'), 2),
                    from = c(0, ice_old, 0, ice_young), to = c(ice_old, 1, ice_young, 1))
  counted = data.frame(case = case, row = factor(rows[3:4], levels = rev(rows)), kind = 'land whose vegetation change counts',
                       from = c(ice_old, max(ice_old, ice_young)), to = 1)
  label = sprintf('%s, ice %.1f to %.1f: total %+.3f\ntoday\'s rule: vegetation %+.3f, ice %+.3f\nsecond rule: vegetation %+.3f, ice %+.3f',
                  case, ice_old, ice_young, parts$alb_diff_veg_ice_parts, parts$alb_diff_veg_part, parts$alb_diff_ice_part,
                  parts$alb_diff_veg_part_exposed, parts$alb_diff_ice_part_exposed)
  rbind(bars, counted) %>% mutate(case = label)
}
split = rbind(split_case('advance', EXAMPLE$ice_old, EXAMPLE$ice_young), split_case('retreat', EXAMPLE$ice_young, EXAMPLE$ice_old))
p_split = ggplot(split) +
  geom_rect(aes(xmin = from, xmax = to, ymin = as.numeric(row) - 0.35, ymax = as.numeric(row) + 0.35, fill = kind), colour = 'white', linewidth = 0.6) +
  facet_wrap(~ case, ncol = 1) +
  scale_y_continuous(breaks = 1:4, labels = levels(split$row)) +
  scale_fill_manual(values = c('ice' = '#2a78d6', 'ice-free land' = '#1baf7a', 'land whose vegetation change counts' = '#eb6834'), name = NULL) +
  labs(x = 'share of the cell', y = NULL, title = 'Why the total still works when ice advances',
       subtitle = sprintf('Albedo change = vegetation part + ice part. Vegetation albedo %.2f to %.2f, glacier albedo %.2f;\nthe numbers come from the pipeline\'s own arithmetic (R/differences.R)',
                          EXAMPLE$veg_old, EXAMPLE$veg_young, EXAMPLE$glacier),
       caption = paste0('Drawn nested: each slice\'s ice starts at the left edge. Only for nested ice is the second rule\'s share,\n',
                        '1 - max(older, younger ice fraction), the land ice-free at both slices; fractions do not say where in a cell the ice lies.')) +
  theme_slides() + theme(panel.grid = element_blank(), strip.text = element_text(hjust = 0),
                         plot.caption = element_text(hjust = 0), plot.caption.position = 'plot')
save_png(p_split, 'split_diagram.png', 9, 7)

# 5. How the forcing changes: HadGEM3, global equivalent, by period, the total and its parts.
shown_forcing = forcing %>% filter(kernel == 'hadgem') %>%
  mutate(quantity = factor(quantity, levels = c('total', PARTS)), period = factor(period, levels = rev(PERIODS)), source = factor(source, levels = SOURCES))
p_forcing = ggplot(shown_forcing, aes(period, global_equiv, fill = source)) +
  geom_col(position = position_dodge(0.8), width = 0.75) +
  geom_hline(yintercept = 0, linewidth = 0.3) +
  facet_wrap(~ quantity, nrow = 1) +
  scale_fill_manual(values = COLOURS, name = NULL, drop = TRUE) +
  labs(x = NULL, y = 'global-equivalent forcing (W/m2)', title = 'How the forcing changes with the ice',
       subtitle = 'HadGEM3 kernel, script 9\'s tables; positive = warming; the vegetation predictions are the same in every run') +
  theme_slides() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
save_png(p_forcing, 'forcing_comparison.png', 4 + 2.2 * nlevels(droplevels(shown_forcing$quantity)), 5.5)

# --- the record -----------------------------------------------------------------------------------

code = code_version('config.R')
old_counts = counts[counts$source == 'old raster', ]
printed = function(table) { old = options(width = 200); on.exit(options(old)); capture.output(print(as.data.frame(table), row.names = FALSE)) }
record = c(
  sprintf('compare_ice.R, %s, commit %s%s', format(Sys.time(), '%Y-%m-%d %H:%M UTC', tz = 'UTC'), code$commit,
          if (isTRUE(code$dirty)) ' (with uncommitted changes)' else ''),
  '', 'RUNS', unlist(lapply(runs, function(run) c(
    sprintf('  %s: %s', run$source, run$dir),
    if (!identical(run, old_run)) paste('    settings unlike the old-ice run:', c(analysis_differences(old_run$settings, run$settings), if (!length(analysis_differences(old_run$settings, run$settings))) 'none'))))),
  '', sprintf('SUPPORT: the %d forcing cells of the old-ice run (script 8\'s table), %.0f km2', nrow(cells), sum(cells$area_km2)),
  '', 'NET INCREASES IN ICE COVERAGE, cell-pairs of consecutive slices on the forcing cells: every exact positive difference in',
  'coverage, however small, not established physical readvances (tiny_raw_increases: those below 1e-6 of the cell, a diagnostic)',
  printed(counts),
  if (nrow(old_counts) && !is.na(old_counts$adjusted_increases))
    sprintf('  old raster: %d raw, %d after averaging, of which %d created by it (the established audit: 186, 228 and 75)',
            old_counts$raw_increases, old_counts$adjusted_increases, old_counts$created),
  '', 'TABLES',
  '  ice_by_slice.csv: age_bp, the slice; pollen_bin_older_bp and _younger_bp, the pollen bin behind its name; nadi1_snapshot_bp, the',
  '    NADI-1 snapshot used (1,000 BP carried forward to the three younger slices); <source>_km2, the ice area on the forcing cells,',
  '    the raw fraction times script 7a\'s cell area; nadi1_optimal_minus_old_km2.',
  '  readvance_inventory.csv: one row per source, cell and pair of consecutive slices whose ice fraction increases from the older',
  '    (year_old) to the younger (year_young) slice, raw or after script 7a\'s averaging (adjusted; empty without a run on that ice);',
  '    *_increase = younger minus older (positive = more ice), *_area_increase_km2 = the increase times the cell area; averaging:',
  '    retained (an increase before and after), removed (before only), created (after only), no run.',
  '  forcing_comparison.csv: script 9\'s forcing by period: quantity "total" is each kernel\'s headline variant (variant column), the',
  '    parts are HadGEM3\'s (veg_part + ice_part, and the second rule veg_part_exposed + ice_part_exposed, each adding up to',
  '    veg_ice_parts); domain_mean over the study area and global_equiv over the Earth, W/m2, positive = warming; *_minus_old,',
  '    the run minus the old-ice run. period is config.R\'s label; period_saved, the run\'s own (10 - 12 ka is 10 - 11.5 ka).',
  '', 'FILES READ (md5)', sprintf('  %s  %s', unname(tools::md5sum(FILES_READ)), FILES_READ))
writeLines(record, file.path(out_dir, 'record.txt'))
cat(record, sep = '\n')
