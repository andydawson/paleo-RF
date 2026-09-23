############################################################################################
# 2_calibration_lct_bluesky.R  --  attach modern satellite albedo to the modern land cover
#
# WHERE THIS SITS IN THE PIPELINE
#   Step 2 of 9. Script 1 produced one row per cell for "today" (50 years BP) with the land
#   cover fractions and elevation. A calibration model (script 4) needs, alongside those,
#   the thing it is meant to predict: observed albedo. This script samples a satellite
#   albedo climatology at every cell, once per month, and glues the twelve values onto the
#   land-cover table. It also draws diagnostic maps and a scatter plot.
#
# WHAT ALBEDO IS, IN ONE PARAGRAPH
#   Albedo is the fraction of incoming sunlight a surface reflects, 0 (absorbs everything)
#   to 1 (reflects everything). Fresh snow is ~0.8, dark forest ~0.1. "Blue-sky" albedo is
#   the value under real sky conditions, a weighted mix of direct-beam and diffuse-light
#   albedo. It varies strongly with month because of snow cover and sun angle, which is why
#   the whole pipeline is done month by month.
#
# WHAT COMES IN
#   data/lct_modern_reveals_interp.RDS      2,860 rows x 6:  x, y, elev, ET, OL, ST
#     From script 1. x, y are longitude and latitude in degrees.
#   data/blue_sky_monthly_2000-2009.tif     raster, 280 x 500 pixels x 12 layers
#     Monthly median blue-sky albedo for 2000-2009 at 0.25-degree resolution, covering
#     175W-50W, 10N-80N. Derived outside this repository from MODIS MCD43A3 and ERA5. The
#     twelve layers are all called "median" in the file; this script renames them by month.
#     Values run from 0.004 to 0.83; pixels with no valid observation are NA (notably the
#     high latitudes in winter, when there is no sunlight to measure).
#   data/grid.RDS                            1-degree lon/lat raster, 62 x 299 cells
#     Defines the pipeline's grid; used here as the target for resampling.
#   data/map-data/geographic/pbs_ll.RDS      political boundaries in lon/lat, for the maps.
#
# WHAT GOES OUT
#   data/calibration_modern_lct_interp_bluesky.RDS         2,860 rows x 18
#     x, y, elev, ET, OL, ST, jan, feb, ..., dec.  THE calibration table: what script 4
#     fits its models on. Albedo is in "wide" form, one column per month.
#   data/calibration_modern_lct_interp_bluesky_coarse.RDS  2,860 rows x 18, same layout
#     Same, but with albedo averaged over the whole 1-degree cell instead of read at the
#     cell centre (see the scale note below). Used only for the diagnostic scatter here.
#   figures/albedo_maps_monthly_bluesky_{native,coarse}.{pdf,png}   all months, facetted
#   figures/albedo_maps_<month>_bluesky[_coarse].{pdf,png}          one map per month (48 files)
#   figures/albedo_native_vs_coarse_scatter_interp.{pdf,png}
#
# A NOTE ON SCALE THAT MATTERS FOR THE MODELLING
#   The land-cover fractions describe a whole 1-degree cell (~100 km across). The albedo
#   that goes into the calibration table is NOT the cell average: it is the value of the
#   single 0.25-degree pixel that contains the cell's centre point (terra::extract at a
#   point returns the pixel under it). So each row pairs a cell-average predictor with a
#   centre-pixel response. The cell-average version is computed alongside (`_coarse`) but
#   is only compared in a scatter plot; the model is fitted to the centre-pixel values.
#
# RUN TIME  About 20 minutes, most of it rendering the 50-odd map files.
#
# HOW TO LAUNCH  Through the activated environment (micromamba run -n paleo-rf ...); see
#   script 1's header for why. This script tolerates a bare launch but warns about PROJ.
############################################################################################

# terra handles rasters and points; tidyterra lets ggplot2 draw terra rasters directly
# (geom_spatraster); reshape2 provides melt() for the diagnostic scatter. (The original
# also loaded rasterVis, which nothing on this path uses.)
library(terra)
library(ggplot2)
library(reshape2)
library(tidyterra)

############################################################################################
# Constants and shared inputs
############################################################################################

# Month names in order. Used to name raster layers and to loop.
months = c('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec')

# Political boundaries in longitude/latitude, drawn as grey outlines under every map.
pbs_ll = readRDS('data/map-data/geographic/pbs_ll.RDS')

# The 1-degree grid. It is stored as an old-style `raster` object; rast() converts it to a
# terra SpatRaster so terra's resample() can use it as a template.
grid <- rast(readRDS("data/grid.RDS"))

# Make sure the figures directory exists before ggsave() tries to write into it.
dir.create('figures', showWarnings = FALSE)

############################################################################################
# Modern land cover as a set of points
############################################################################################

# The modern (50 BP) land-cover table from script 1: one row per cell.
lct_interp_modern = readRDS('data/lct_modern_reveals_interp.RDS')

# Pull out longitude and latitude as plain vectors, then bind them side by side into a
# 2,860 x 2 matrix, which is what vect() wants for point coordinates.
longitude_interp = lct_interp_modern[,c('x')]
latitude_interp = lct_interp_modern[,c('y')]
lonlat_interp = cbind(longitude_interp, latitude_interp)

# ---- Turn the table into a spatial object ------------------------------------------------
# vect() makes a terra SpatVector of points. `crs` says the coordinates are WGS84 lon/lat
# (EPSG:4326; the "+init=" spelling is old but still understood). `atts` attaches the
# non-coordinate columns (elev, ET, OL, ST: columns 3 onward) as attributes, so each point
# carries its land cover with it. This object is what we sample the albedo raster at.
lct_interp_spat = vect(lonlat_interp, 
                crs  = crs("+init=epsg:4326"), 
                atts = lct_interp_modern[,3:ncol(lct_interp_modern)])

# Empty 2,860 x 12 tables to be filled month by month: one for albedo read at the cell
# centre ("native" 0.25-degree pixel), one for albedo averaged over the 1-degree cell.
bs_interp_df = data.frame(matrix(NA, nrow=nrow(lct_interp_spat), ncol=12))
colnames(bs_interp_df) = c('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec')

bs_interp_df_coarse = data.frame(matrix(NA, nrow=nrow(lct_interp_spat), ncol=12))
# (The first of these two lines names the columns bs01..bs12 and the second immediately
# renames them jan..dec; only the second has any effect.)
colnames(bs_interp_df_coarse) = paste0('bs', c(paste0('0', seq(1, 9)), seq(10,12)))
colnames(bs_interp_df_coarse) = c('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec')

############################################################################################
# The albedo climatology, at native resolution and averaged to the 1-degree grid
############################################################################################

# `grid` is already a SpatRaster (see above); calling rast() on it again changes nothing.
# Kept as in the original.
grid = rast(grid)

# Read the 12-layer albedo raster. Nothing is loaded into memory yet; terra reads lazily.
blue_all_months = rast('data/blue_sky_monthly_2000-2009.tif')

# ---- Resample 0.25 degree -> 1 degree ------------------------------------------------------
# resample() re-expresses one raster on another raster's grid. method="average" means each
# 1-degree cell gets the mean of the (up to) 16 quarter-degree pixels inside it, ignoring
# NA pixels. This is the "cell average" albedo of the scale note in the header.
blue_all_months_coarse = resample(blue_all_months, grid, method="average")

# The file calls every layer "median"; give them month names so we can index by name.
names(blue_all_months) = c('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec')
names(blue_all_months_coarse) = c('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec')

# Trim the 1-degree raster to the bounding box of the boundary polygons (the study region).
blue_all_months_coarse = crop(blue_all_months_coarse, ext(pbs_ll))

############################################################################################
# Diagnostic maps: all twelve months on one page, native and coarse
############################################################################################

# ---- How these ggplot maps are built -------------------------------------------------------
# ggplot() starts an empty plot; each "+" adds a layer or a setting:
#   geom_path(pbs_ll ...)         grey coastline/border outlines, grouped so each polygon is
#                                 drawn as its own closed line
#   geom_spatraster(...)          the albedo raster itself (from tidyterra), semi-transparent
#   scale_fill_gradientn(...)     colour ramp for albedo; NA pixels drawn transparent
#   theme_*()                     overall look; the theme() call hides axis text and ticks
#   facet_wrap(~lyr)              one panel per raster layer, i.e. per month
# ggsave() with no plot argument saves the most recently drawn plot.
ggplot() +
  geom_path(data=pbs_ll, aes(long,lat, group = group), color="grey50") +
  geom_spatraster(data=blue_all_months, alpha=0.8) +
  scale_fill_gradientn(colours=terrain.colors(10), na.value='transparent', name = "Albedo") + 
  theme_light() + 
  theme(axis.text.x= element_blank(), axis.ticks = element_blank(), axis.title = element_blank())+
  facet_wrap(~lyr)
ggsave('figures/albedo_maps_monthly_bluesky_native.pdf')
ggsave('figures/albedo_maps_monthly_bluesky_native.png')

# Same again for the 1-degree version.
ggplot() +
  geom_path(data=pbs_ll, aes(long,lat, group = group), color="grey50") +
  geom_spatraster(data=blue_all_months_coarse, alpha=0.8) +
  scale_fill_gradientn(colours=terrain.colors(10), na.value='transparent', name = "Albedo") + 
  theme_bw() + 
  theme(axis.text.x= element_blank(), axis.ticks = element_blank(), axis.title = element_blank())+
  facet_wrap(~lyr)
ggsave('figures/albedo_maps_monthly_bluesky_coarse.pdf')
ggsave('figures/albedo_maps_monthly_bluesky_coarse.png')

# Two colour scales are defined here, the second overwriting the first. Neither is used:
# the loop below spells out its own scale_fill_gradientn(). Harmless leftovers.
cols_fill = scale_fill_gradientn(colours=terrain.colors(10), 
                                 na.value='transparent', 
                                 name = "Albedo") 

cols_fill = scale_fill_brewer(palette="YlOrBr", 
                              direction = -1,
                                 na.value='transparent', 
                                 name = "Albedo") 

############################################################################################
# Month loop: one map per month, and the sampling that actually matters
############################################################################################

# Loop over the twelve months by index. Each pass draws two maps and, at the end, samples
# the raster at the 2,860 cell centres. The sampling is the real work; the maps are a
# by-product (and are what makes this script slow).
for(i in 1:length(months)) {
  
  # Month name for this pass, e.g. 'jan'.
  month = months[i]
  
  # Pick this month's layer out of the 12-layer raster by name.
  blue_month = blue_all_months[[month]]
  # A label like 'bs01' that is computed but never used afterwards. Leftover.
  vname = sprintf('bs%02d', i)
  
  # Map of this month at native resolution (same recipe as the facetted maps above).
  p <- ggplot() + 
    geom_path(data=pbs_ll, aes(long,lat, group = group), color="grey50") +
    geom_spatraster(data=blue_month, alpha=0.8) +
    scale_fill_gradientn(colours=terrain.colors(10), na.value='transparent', name = "Albedo") +
    theme_bw() + 
    theme(axis.text.x= element_blank(), axis.ticks = element_blank(), axis.title = element_blank())#+
  
  # print() renders the plot (under Rscript this goes to a file called Rplots.pdf);
  # ggsave() then writes it out properly under its own name.
  print(p)
  ggsave(paste0('figures/albedo_maps_', month, '_bluesky.pdf'))
  ggsave(paste0('figures/albedo_maps_', month, '_bluesky.png'))
  
  # The 1-degree layer for this month, and the same unused label again.
  blue_month_coarse = blue_all_months_coarse[[month]]
  vname = sprintf('bs%02d', i)
  
  # Map of this month at 1 degree.
  p_coarse <- ggplot() + 
    geom_path(data=pbs_ll, aes(long,lat, group = group), color="grey50") +
    geom_spatraster(data=blue_month_coarse, alpha=0.8) +
    scale_fill_gradientn(colours=terrain.colors(10), na.value='transparent', name = "Albedo") +
    theme_bw() + 
    theme(axis.text.x= element_blank(), axis.ticks = element_blank(), axis.title = element_blank())#+
  
  print(p_coarse)
  ggsave(paste0('figures/albedo_maps_', month, '_bluesky_coarse.pdf'))
  ggsave(paste0('figures/albedo_maps_', month, '_bluesky_coarse.png'))
  
  # ---- Sample the rasters at the cell centres --------------------------------------------
  # terra::extract(raster, points) returns a data.frame with an ID column and one column
  # per raster layer, holding the value of the pixel under each point. `[,month]` keeps
  # just the albedo column. For the coarse raster the pixel IS the 1-degree cell, so this
  # is the cell average; for the native raster it is the one 0.25-degree pixel at the cell
  # centre. Each pass fills one column (this month) of the 2,860 x 12 tables.
  bs_interp_df_coarse[,month] <- terra::extract(blue_month_coarse, lct_interp_spat)[,month]
  
  bs_interp_df[,month] <- terra::extract(blue_month, lct_interp_spat)[,month]
  
}

############################################################################################
# Tidy up the sampled values and build the calibration tables
############################################################################################

# ---- Why zeros are replaced ------------------------------------------------------------------
# The calibration model in script 4 is a beta regression, which describes a quantity that
# lies strictly BETWEEN 0 and 1; an exact 0 (or 1) has zero likelihood and breaks the fit.
# Any albedo that came out as exactly zero is therefore nudged to 0.0001. (Exact ones do
# not occur in this data; the maximum is 0.83.)
bs_interp_df[bs_interp_df==0] = 1e-4
bs_interp_df_coarse[bs_interp_df_coarse==0] = 1e-4

# Glue the twelve albedo columns onto the land-cover table, column-wise. Rows line up
# because the points were built from this same table in the same order.
# Result: 2,860 x 18 (x, y, elev, ET, OL, ST, jan ... dec).
lct_interp_bs = data.frame(lct_interp_modern, bs_interp_df)
lct_interp_bs_coarse = data.frame(lct_interp_modern, bs_interp_df_coarse)

# Save both. The first is the calibration table used by scripts 3, 4 and 5.
saveRDS(lct_interp_bs, 'data/calibration_modern_lct_interp_bluesky.RDS')
saveRDS(lct_interp_bs_coarse, 'data/calibration_modern_lct_interp_bluesky_coarse.RDS')

############################################################################################
# Diagnostic: centre-pixel albedo against cell-average albedo
############################################################################################

# melt() turns the wide tables long: the columns NOT listed in id.vars (the twelve months)
# are stacked into two columns, `variable` (the month name) and `value` (the albedo).
# 2,860 x 18  ->  34,320 x 8.
lct_interp_bs_melt = melt(lct_interp_bs, id.vars = c('x', 'y', 'elev', 'ET', 'OL', 'ST'))
lct_interp_bs_coarse_melt = melt(lct_interp_bs_coarse, id.vars = c('x', 'y', 'elev', 'ET', 'OL', 'ST'))

# Join the two long tables on everything except the albedo, so each row has both versions:
# value.x (native, centre pixel) and value.y (coarse, cell average).
lct_interp_bs_merged = merge(lct_interp_bs_melt, lct_interp_bs_coarse_melt, by = c('x', 'y', 'elev', 'ET', 'OL', 'ST', 'variable'))

# Scatter of one against the other with a 1:1 line. Points off the line are cells whose
# centre pixel is not representative of the cell as a whole (mixed terrain, coastlines,
# lakes). Note the axis labels are the wrong way round relative to value.x/value.y.
ggplot(data = lct_interp_bs_merged) +
  geom_point(aes(x=value.x, y=value.y), alpha=0.6) +
  geom_abline(intercept=0, slope=1, colour='red', lwd=1, alpha=0.5) +
  xlab('albedo resampled coarse') +
  ylab('albedo native') +
  theme_bw(18) +
  coord_fixed() +
  xlim(c(0,0.8)) +
  ylim(c(0,0.8))
ggsave('figures/albedo_native_vs_coarse_scatter_interp.pdf')
ggsave('figures/albedo_native_vs_coarse_scatter_interp.png')

# Correlation between the two versions, printed to the console (NA pairs skipped).
cor(lct_interp_bs_merged$value.x, lct_interp_bs_merged$value.y, use = 'complete.obs')
