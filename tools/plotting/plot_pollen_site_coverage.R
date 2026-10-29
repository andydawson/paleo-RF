# plot_pollen_site_coverage.R: where the past land cover comes from pollen, and where it is
# filled in only by the spatial interpolation.
#
# WHY (Chris, 2026-10-20, for Andria). A strong regional forcing signal in a region with few
# pollen sites may come from the interpolation rather than from the data (the 2-4 ka warming
# over Texas and Oklahoma, for example). This map shows which 1-degree cells have a
# pollen-based cover estimate, and the log gives the counts for the regions discussed. A
# diagnostic, not a pipeline step: run it by hand from the repository root:
#   Rscript tools/plotting/plot_pollen_site_coverage.R [--config <file>]
#
# WHAT COMES IN
#   data/lct_paleo_reveals.RDS          the pollen-based (REVEALS) cover, one row per 1-degree
#                                       cell and time slice with an estimate. Its slices are
#                                       2,000 years apart (50 BP to 20 ka, 12 in all), coarser
#                                       than the 500-year slices of the run: read the counts as
#                                       a guide to where the sites are, not exact figures.
#   data/elev_interp_cells.RDS          the grid cells the interpolation fills
#   data/map-data/geographic/pbs_ll.RDS map boundaries
#
# WHAT GOES OUT
#   figures/diagnostics/pollen_site_coverage.png   grid cells in grey; cells with a pollen
#       estimate coloured by the number of time slices that have one
#   The log prints, for the six regions of R/regions.R, the grid cells and the median number
#   of cells with a pollen estimate per time slice.

source('R/run_manifest.R')
source('R/map_helpers.R')
source('R/regions.R')
run   = run_begin('plot_pollen_site_coverage')
cfg   = run$cfg
paths = run$paths

library(ggplot2)
library(dplyr)

pollen = read_input(run, path_file(paths, 'lct_paleo_reveals'))
grid   = read_input(run, path_file(paths, 'elevation_cache'))[, c('x', 'y')]

grid$region   = region_of(grid$x, grid$y)
pollen$region = region_of(pollen$long, pollen$lat)

coverage = grid %>% count(region, name = 'grid_cells') %>%
  left_join(pollen %>% count(region, ages) %>% group_by(region) %>%
              summarise(median_cells_with_pollen_per_slice = median(n), .groups = 'drop'), by = 'region') %>%
  mutate(share_of_grid = round(median_cells_with_pollen_per_slice / grid_cells, 3))
print(as.data.frame(coverage), row.names = FALSE)

slices_with_pollen = pollen %>% count(long, lat, name = 'slices')
window = cfg$presentation$map_windows$diagnostics
land = prepare_boundaries(read_input(run, path_file(paths, 'boundaries_ll')), window)

figure = ggplot() +
  geom_tile(data = grid, aes(x, y), fill = 'grey88') +
  geom_tile(data = slices_with_pollen, aes(long, lat, fill = slices)) +
  boundary_layers(land, window, colour = 'grey60', linewidth = 0.15) +
  scale_fill_viridis_c(name = sprintf('time slices\nwith a pollen-\nbased estimate\n(of %d in\nthis file)', n_distinct(pollen$ages))) +
  theme_bw(base_size = 9) +
  labs(x = NULL, y = NULL, title = '1-degree cells with a pollen-based land-cover estimate before interpolation',
       subtitle = 'grey: grid cells filled only by the spatial interpolation')

figure_file = path_figure(paths, 'diagnostics', 'pollen_site_coverage.png')
ggsave(figure_file, figure, width = 9, height = 6, dpi = 150)

run_finish(run)
