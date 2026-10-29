# 2_calibration_lct_bluesky.R: attach modern satellite albedo to the modern land cover
# Interp (spatially complete) path only. Settings come from config.R, and every file is
# read and written through the run manifest; comments marked '# CM:' are notes on
# changes from the original analysis.


# Settings, file locations and this run's manifest: run_begin() reads config.R (or the file
# given with --config), sets up the paths of R/paths.R and starts the run's
# manifest; files are then read and written through it.
source('R/run_manifest.R')
run   = run_begin('2_calibration_lct_bluesky')
cfg   = run$cfg
paths = run$paths

# Packages, loaded after run_begin() so that a missing one is recorded as a failed run.
library(terra)
library(ggplot2)
library(reshape2)
library(tidyterra)

# All twelve months from the shared calendar (R/calendar.R). Deliberately not
# config.R's month selection: the calibration table keeps every month, so scripts 4 onward
# can run on any selection without rebuilding it.
source('R/calendar.R')
months = MONTHS

pbs_ll = read_input(run, path_file(paths, 'boundaries_ll'))

# Boundaries for the maps, prepared by the shared helper (see R/map_helpers.R for why the
# raw file cannot be drawn as-is: the "weirdness" noted on 2026-09-24). Fix added 2026-09-25.
# The map window is the calibration window in config.R.
map_window = cfg$presentation$map_windows$calibration
source('R/map_helpers.R')
pbs_land = prepare_boundaries(pbs_ll, map_window)



lct_interp_modern = read_input(run, path_file(paths, 'lct_modern'))

# Present-day ice caps out of the calibration (config.R analysis$calibration$ice_mask,
# question B8): cells whose centre lies under the 1 ka ice polygons (the first of
# the glacier shapes) carry interpolated vegetation fractions but the satellite's ice albedo.
# They stay in the prediction domain; only the calibration table loses them. The cells left
# out are recorded in the run manifest.
if (cfg$analysis$calibration$ice_mask == 'centre_in_1ka_polygon') {
  source('R/preparation.R')
  ice_1ka   = read_input(run, path_file(paths, 'glacier_shapes'))[[1]]
  under_ice = cells_in_polygons(lct_interp_modern$x, lct_interp_modern$y, ice_1ka)
  run_record(run, 'calibration_ice_mask', list(method = 'centre_in_1ka_polygon',
                                               cells_left_out = sum(under_ice),
                                               cells = lct_interp_modern[under_ice, c('x', 'y')]))
  lct_interp_modern = lct_interp_modern[!under_ice, ]
}

# The satellite albedo of each calibration cell and month, from the source config.R chooses
# (analysis$albedo; Chris, 2026-10-29, docs/cc/2026-10-29_refit_plan_decisions.md). Either
# branch fills bs_interp_df, one row per row of lct_interp_modern and one column per month,
# and albedo_record, what the run manifest says about the albedo.
albedo_settings = cfg$analysis$albedo
if (albedo_settings$source == 'legacy_raster') {

  # The original: the 0.25-degree raster data/blue_sky_monthly_2000-2009.tif read at each
  # cell centre, with a copy coarsened to the 1-degree grid and the maps of both.
  albedo_record = list(source = 'legacy_raster')

  grid <- rast(read_input(run, path_file(paths, 'grid')))

  longitude_interp = lct_interp_modern[,c('x')]
  latitude_interp = lct_interp_modern[,c('y')]
  lonlat_interp = cbind(longitude_interp, latitude_interp)

  lct_interp_spat = vect(lonlat_interp,
                  crs  = crs("+init=epsg:4326"),
                  atts = lct_interp_modern[, setdiff(names(lct_interp_modern), c('x', 'y'))])   # every column but the coordinates

  # construct objects to hold albedo data

  # albedo native resolution
  bs_interp_df = data.frame(matrix(NA, nrow=nrow(lct_interp_spat), ncol=12))
  colnames(bs_interp_df) = MONTHS

  # albedo coarser resolution (same as grid?)
  bs_interp_df_coarse = data.frame(matrix(NA, nrow=nrow(lct_interp_spat), ncol=12))
  colnames(bs_interp_df_coarse) = MONTHS

  grid = rast(grid)

  blue_all_months = read_input(run, path_file(paths, 'bluesky_raster'), rast)

  # coarsen albedo by averaging albedo cells within a grid cell
  # CM: this cell-averaged albedo is saved but not currently used downstream
  blue_all_months_coarse = resample(blue_all_months, grid, method="average")

  names(blue_all_months) = MONTHS
  names(blue_all_months_coarse) = MONTHS

  # crop albedo (I think this removes the ocean grid cells? not sure)
  # CM: this crop is not needed (and not doing anything - cropping the raster to a box that is bigger than itself) - the extract() further down samples the raster at the modern land-cover cells only.
  blue_all_months_coarse = crop(blue_all_months_coarse, ext(pbs_ll))

  # some weirdness going on with these figures

  # CM: print() because inside this if block a plot is no longer printed automatically, as it
  # was at the top level of the script (into Rplots.pdf under Rscript); the same below.
  print(ggplot() +
    boundary_layers(pbs_land, map_window) +
    geom_spatraster(data = blue_all_months, alpha=0.8) +
    scale_fill_gradientn(colours = terrain.colors(10), na.value='transparent', name = "Albedo") +
    theme_light() +
    theme(axis.text.x = element_blank(), axis.ticks = element_blank(), axis.title = element_blank())+
    facet_wrap(~lyr))
  ggsave(path_figure(paths, 'albedo_maps_monthly_bluesky_native.pdf'))
  ggsave(path_figure(paths, 'albedo_maps_monthly_bluesky_native.png'))

  print(ggplot() +
    boundary_layers(pbs_land, map_window) +
    geom_spatraster(data = blue_all_months_coarse, alpha=0.8) +
    scale_fill_gradientn(colours = terrain.colors(10), na.value='transparent', name = "Albedo") +
    theme_bw() +
    theme(axis.text.x = element_blank(), axis.ticks = element_blank(), axis.title = element_blank())+
    facet_wrap(~lyr))
  ggsave(path_figure(paths, 'albedo_maps_monthly_bluesky_coarse.pdf'))
  ggsave(path_figure(paths, 'albedo_maps_monthly_bluesky_coarse.png'))

  for(i in 1:length(months)) {

    month = months[i]

    blue_month = blue_all_months[[month]]

    p <- ggplot() +
      boundary_layers(pbs_land, map_window) +
      geom_spatraster(data=blue_month, alpha=0.8) +
      scale_fill_gradientn(colours=terrain.colors(10), na.value='transparent', name = "Albedo") +
      theme_bw() +
      theme(axis.text.x= element_blank(), axis.ticks = element_blank(), axis.title = element_blank())#+

    print(p)
    ggsave(path_figure(paths, paste0('albedo_maps_', month, '_bluesky.pdf')))
    ggsave(path_figure(paths, paste0('albedo_maps_', month, '_bluesky.png')))

    blue_month_coarse = blue_all_months_coarse[[month]]

    p_coarse <- ggplot() +
      boundary_layers(pbs_land, map_window) +
      geom_spatraster(data=blue_month_coarse, alpha=0.8) +
      scale_fill_gradientn(colours=terrain.colors(10), na.value='transparent', name = "Albedo") +
      theme_bw() +
      theme(axis.text.x= element_blank(), axis.ticks = element_blank(), axis.title = element_blank())#+

    print(p_coarse)
    ggsave(path_figure(paths, paste0('albedo_maps_', month, '_bluesky_coarse.pdf')))
    ggsave(path_figure(paths, paste0('albedo_maps_', month, '_bluesky_coarse.png')))

    bs_interp_df_coarse[,month] <- terra::extract(blue_month_coarse, lct_interp_spat)[,month]

    bs_interp_df[,month] <- terra::extract(blue_month, lct_interp_spat)[,month]

  }

} else {

  # The rebuilt MODIS albedo over the land pixels of each cell (tools/prepare_bluesky_albedo.R),
  # in the chosen statistic and version, matched to the calibration cells on their exact centres
  # by cell_albedo_by_month() (R/preparation.R). A cell-month without a value stays missing;
  # nothing is filled. No coarse table and no native-versus-coarse figures: the table is already
  # at the cells' 1-degree resolution.
  source('R/preparation.R')
  cells_file = path_file(paths, 'albedo_modis_cells')
  albedo_cells = read_input(run, cells_file, read.csv)
  cells_provenance = read_input(run, path_file(paths, 'albedo_modis_provenance'), readLines)
  attached = cell_albedo_by_month(albedo_cells, lct_interp_modern, albedo_settings$statistic, albedo_settings$version)
  bs_interp_df = attached$albedo
  # The cell-table centres without a calibration cell include those the ice mask above left out.
  albedo_record = list(source = 'modis_cells',
                       statistic = albedo_settings$statistic,
                       version = albedo_settings$version,
                       cell_table = list(path = cells_file, md5 = unname(tools::md5sum(cells_file))),
                       cell_table_provenance = cells_provenance,
                       calibration_cells_without_albedo_cell = attached$predictors_without_cell,
                       albedo_cells_without_calibration_cell = attached$cells_without_predictor)

  # Maps of the selected monthly albedo and of where it is missing, one panel per month.
  albedo_long = melt(data.frame(lct_interp_modern[, c('x', 'y')], bs_interp_df), id.vars = c('x', 'y'),
                     variable.name = 'month', value.name = 'albedo')
  map_title = sprintf('MODIS cell albedo: %s, version %s', albedo_settings$statistic, albedo_settings$version)
  p_albedo = ggplot(data = albedo_long) +
    boundary_layers(pbs_land, map_window) +
    geom_tile(aes(x = x, y = y, fill = albedo), alpha = 0.8) +
    scale_fill_gradientn(colours = terrain.colors(10), na.value = 'transparent', name = 'Albedo') +
    theme_bw() +
    theme(axis.text.x = element_blank(), axis.ticks = element_blank(), axis.title = element_blank()) +
    labs(title = map_title) +
    facet_wrap(~month)
  print(p_albedo)
  ggsave(path_figure(paths, 'albedo_maps_monthly_modis_cells.pdf'), p_albedo, width = 12, height = 9)
  ggsave(path_figure(paths, 'albedo_maps_monthly_modis_cells.png'), p_albedo, width = 12, height = 9)

  p_missing = ggplot(data = albedo_long) +
    boundary_layers(pbs_land, map_window) +
    geom_tile(aes(x = x, y = y, fill = ifelse(is.na(albedo), 'missing', 'observed')), alpha = 0.8) +
    scale_fill_manual(values = c(missing = 'firebrick', observed = 'grey70'), name = NULL) +
    theme_bw() +
    theme(axis.text.x = element_blank(), axis.ticks = element_blank(), axis.title = element_blank()) +
    labs(title = paste(map_title, '- cells without a value')) +
    facet_wrap(~month)
  print(p_missing)
  ggsave(path_figure(paths, 'albedo_missing_monthly_modis_cells.pdf'), p_missing, width = 12, height = 9)
  ggsave(path_figure(paths, 'albedo_missing_monthly_modis_cells.png'), p_missing, width = 12, height = 9)

}

# Per month, the cells with an albedo and those floored from exactly 0 just below.
albedo_record$per_month = data.frame(month = MONTHS,
                                     cells_with_albedo = unname(colSums(!is.na(bs_interp_df))),
                                     floored_from_zero = unname(colSums(bs_interp_df == 0, na.rm = TRUE)))
run_record(run, 'calibration_albedo', albedo_record)

# The calibration models (script 4) use a beta distribution, defined only strictly between
# 0 and 1, so an albedo of exactly zero is set to a small positive value.
bs_interp_df[bs_interp_df==0] = 1e-4

lct_interp_bs = data.frame(lct_interp_modern, bs_interp_df)

# One row per modern cell: land cover, elevation and the twelve monthly albedos.
write_output(run, lct_interp_bs, path_file(paths, 'calibration_table'))

# The raster only: the same table at the coarser albedo resolution, and the comparison of
# the two (the MODIS cell table has one resolution, the cells').
if (albedo_settings$source == 'legacy_raster') {

  bs_interp_df_coarse[bs_interp_df_coarse==0] = 1e-4

  lct_interp_bs_coarse = data.frame(lct_interp_modern, bs_interp_df_coarse)

  write_output(run, lct_interp_bs_coarse, path_file(paths, 'calibration_table_coarse'))

  lct_interp_bs_melt = melt(lct_interp_bs, id.vars = c('x', 'y', 'elev', 'ET', 'OL', 'ST'))
  lct_interp_bs_coarse_melt = melt(lct_interp_bs_coarse, id.vars = c('x', 'y', 'elev', 'ET', 'OL', 'ST'))

  lct_interp_bs_merged = merge(lct_interp_bs_melt, lct_interp_bs_coarse_melt, by = c('x', 'y', 'elev', 'ET', 'OL', 'ST', 'variable'))

  # CM: axis labels look swapped: after the merge value.x is the native albedo and value.y
  # the coarse one, but x is labelled coarse and y native. Left as is pending Andria
  # (questions_for_andria_general.md, section 8).
  print(ggplot(data = lct_interp_bs_merged) +
    geom_point(aes(x=value.x, y=value.y), alpha=0.6) +
    geom_abline(intercept=0, slope=1, colour='red', lwd=1, alpha=0.5) +
    xlab('albedo resampled coarse') +
    ylab('albedo native') +
    theme_bw(18) +
    coord_fixed() +
    xlim(c(0,0.8)) +
    ylim(c(0,0.8)))
  ggsave(path_figure(paths, 'albedo_native_vs_coarse_scatter_interp.pdf'))
  ggsave(path_figure(paths, 'albedo_native_vs_coarse_scatter_interp.png'))

  cor(lct_interp_bs_merged$value.x, lct_interp_bs_merged$value.y, use = 'complete.obs')

}

run_finish(run)
