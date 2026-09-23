############################################################################################
# 7_plot_preds.R  --  maps of the hindcast albedo, and the coarse slice-to-slice differences
#
# WHERE THIS SITS IN THE PIPELINE
#   Step 7 of 9, independent of 7a (both read script 6's output). Mostly a plotting
#   script: maps of modelled albedo, its uncertainty and its change through time, for a
#   coarse set of eight slices, with the ice sheet drawn on top. Two of its by-products
#   are inputs to later scripts: the ice outlines (script 8 loads them; its map code is commented out on this path) and the coarse
#   albedo differences (script 9 uses them to reproduce the talk's bar chart).
#
# WHAT COMES IN
#   output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS   839,232 x 13
#     Script 6: per cell, slice and month, mean/sd/quantiles of modelled albedo.
#   output/prediction/paleo_interp_predict_gam_bluesky.RDS   loaded, unused (27 MB)
#   data/map-data/ice/glacier_shapefiles_21-1k.RDS
#     A list of 21 polygon sets, the ice-sheet margin at 21, 20, ..., 1 ka. Binary: a
#     point is inside the ice or not. The chronology the land-cover interpolation was
#     masked with.
#   data/albedo_glacier_monthly.csv    monthly ice albedo; this script uses `ice_albedo`
#   data/grid.RDS                      the 1-degree grid, for cell ids and centres
#   data/map-data/geographic/pbs*.RDS  political boundaries for the maps
#
# WHAT GOES OUT
#   figures/alb_interp_preds_*                       about 16 map files (see the sections)
#   data/ice_fort.RDS                                ice outlines at the eight coarse slices,
#                                                    as a plotting table (long, lat, group ...)
#   data/ice_fort_diff_young.RDS, ice_fort_diff_old.RDS   the same outlines paired up per
#                                                    period, for the difference maps; script 8
#   data/alb_interp_preds_diffs_bluesky.RDS          ~233,880 x 21: albedo differences between
#                                                    consecutive COARSE slices (7 pairs), per
#                                                    cell and month; script 9 (anchored)
#
# COARSE VERSUS FINE SLICES
#   The predictions have 25 slices. Everything here uses eight of them: 50, 500, 2000,
#   4000, 6000, 8000, 10000 and 12000 BP. The last does not exist in the data; the 11,500
#   BP slice is RELABELLED 12,000 near the top of the script so that it can stand in for
#   it. (Open question C7.) The differences produced here are therefore between slices
#   450 to 2,000 years apart (nominally: the last pair is really 1,500 years, since 12,000
#   stands for 11,500), unlike script 7a's consecutive 150-to-500-year pairs.
#
# ICE, THIS SCRIPT'S WAY
#   Ice here is binary, from the polygons: a cell is ICE at a slice if its centre falls
#   inside the nearest-in-time margin. Ice cells get the fixed monthly `ice_albedo`
#   instead of the modelled vegetation albedo. Script 7a does the job with a fractional
#   ice raster instead; the two are not reconciled.
#
# A NOTE ON REPETITION
#   Seven map blocks below are almost identical: the same boundary polygons, tile layer,
#   ice overlay, colour scale, theme and fixed coordinates. The first is commented layer
#   by layer; the others say only what differs. fields::tim.colors is why `fields` is
#   loaded; sp's functions (SpatialPoints, over, spTransform ...) are available because
#   raster attaches sp.
#
# RUN TIME  About an hour (61.7 min in the manifest), almost all in the per-cell
#   difference loop (rbind in a double loop; Stage 4 of the staged plan). Memory is not
#   recorded in the manifest; observed around 12 GB.
############################################################################################

library(ggplot2)
library(fields)
library(raster)

alb_prod = "bluesky"

dir.create('figures', showWarnings = FALSE)

# Provenance manifest; see script 8's header.
source('R/run_manifest.R')
run_start('7_plot_preds',
          note   = Sys.getenv('RUN_NOTE'),
          inputs = Filter(file.exists, c(
            paste0('output/prediction/paleo_interp_predict_gam_summary_', alb_prod, '.RDS'),
            paste0('output/prediction/paleo_interp_predict_gam_', alb_prod, '.RDS'),
            'data/grid.RDS',
            'data/map-data/ice/glacier_shapefiles_21-1k.RDS',
            'data/albedo_glacier_monthly.csv',
            'data/map-data/geographic/pbs_ll.RDS',
            'data/map-data/geographic/pbs.RDS')),
          config = list(alb_prod = alb_prod))

############################################################################################
# Constants and map data
############################################################################################

# Political boundaries, lon/lat and projected.
pbs_ll = readRDS('data/map-data/geographic/pbs_ll.RDS')

pbs = readRDS('data/map-data/geographic/pbs.RDS')

# Albedo bin edges as fractions, and bin numbers 1..9.
breaks = c(0, 4, 8, 12, 16, 20, 40, 60, 80, 100)/100

labels = seq(1, length(breaks)-1)

# All 25 slice ages, their count, and the eight coarse ages used for the maps.
ages = c(50, 200, seq(500, 11500, by=500))
N_times = length(ages)
ages_sub = c(50, 500, 2000, 4000, 6000, 8000, 10000, 12000)

months = c('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec')

# Map extent in degrees.
ylim = c(12, 82) 
xlim = c(-166, -50) 

# Lon/lat CRS as a proj string.
proj_WGS84 <- '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0'

############################################################################################
# Ice outlines at the eight coarse slices, as a table ggplot can draw
############################################################################################

# The 21 polygon sets and the ages they represent (21,000 ... 1,000 BP).
ice = readRDS('data/map-data/ice/glacier_shapefiles_21-1k.RDS')
ice_years = seq(1, 21)*1000

# Empty table to collect the outlines.
ice_fort = data.frame(matrix(NA, nrow=0, ncol=9))

for (i in 1:length(ages_sub)){
  
  print(i)
  
  # The polygon set nearest in time to this coarse age (50 -> 1,000; 12,000 -> 12,000).
  idx_ice_match = which.min(abs(ages_sub[i] - ice_years)) 
  
  # Declare the polygons' CRS as lon/lat, then "transform" to the same CRS (a no-op that
  # normalises the object). The original emits a warning here about reassigning a CRS.
  proj4string(ice[[idx_ice_match]]) = proj_WGS84
  ice[[idx_ice_match]] = spTransform(ice[[idx_ice_match]], CRS(proj_WGS84))
  
  # fortify() flattens a polygon object into a data.frame of vertices (long, lat, order,
  # hole, piece, id, group) that geom_polygon can draw. Deprecated in ggplot2 but works.
  ice_fort_age = fortify(ice[[idx_ice_match]])
  
  # Tag with the polygon set's year and the coarse age it stands for, and append.
  ice_fort = rbind(ice_fort, 
                   data.frame(ice_fort_age, 
                              ice_year = rep(ice_years[idx_ice_match], nrow(ice_fort_age)), 
                              ages = rep(ages_sub[i], nrow(ice_fort_age))))
  
}

# The outlines for the coarse ages (all of them, in fact), with a facet label per age.
ice_sub = ice_fort[which(ice_fort$ages %in% ages_sub),]

ice_sub$facets = as.character(ice_sub$ages/1000)
ice_sub$facets = factor(ice_sub$facets, 
                        levels = c('0.05', '0.5', '2', '4', '6', '8', '10', '12'),
                        labels = c('0.05 ka', '0.5 ka', '2 ka', '4 ka', '6 ka', '8 ka', '10 ka', '12 ka'))

# Saved for script 8, which loads it; its map code is commented out on this path.
saveRDS(ice_fort, 'data/ice_fort.RDS')

# Colours for the ice overlays: a light pair and a darker pair (used for the "old" and
# "young" margins on the difference maps).
ice_fill = 'gainsboro'
ice_colour = 'gray60'

ice_fill_dark = 'ivory3'
ice_colour_dark = 'gray40'

############################################################################################
# The predictions, with 11,500 BP relabelled as 12,000
############################################################################################

alb_interp_preds = readRDS(paste0('output/prediction/paleo_interp_predict_gam_summary_', alb_prod, '.RDS'))
# See the header: the oldest slice is made to stand in for 12 ka.
alb_interp_preds$year[which(alb_interp_preds$year == 11500)] = 12000

# Boundaries loaded a second time; bins and labels defined a second time. As original.
pbs_ll = readRDS('data/map-data/geographic/pbs_ll.RDS')
pbs = readRDS('data/map-data/geographic/pbs.RDS')

breaks = c(0, 4, 8, 12, 16, 20, 40, 60, 80, 100)/100

labels = seq(1, length(breaks)-1)

# Four colour scales for binned values. Only sc_fill_seq's palette family is echoed by
# the maps below, which spell out their own scale_fill_brewer(); none of these four
# objects is used. tim.colors() is fields' rainbow-like palette.
sc_colour <- scale_colour_manual(values = c(tim.colors(length(breaks)), "grey"), labels = labels,
                                 na.value="white", name="Percent", drop=FALSE)

sc_fill <- scale_fill_manual(values = c(tim.colors(length(breaks)), "grey"), labels = labels,
                             na.value="white", name="Percent", drop=FALSE)

sc_fill_seq <- scale_fill_brewer(type = "seq",
                                 palette = "Greens",#"BrBG",#"YlGnBu",#
                                 labels = labels,
                                 na.value="grey", 
                                 direction=-1,
                                 name="Albedo")

sc_colour_seq <- scale_colour_brewer(type = "seq",
                                     palette = "YlGnBu",#"BrBG",
                                     labels = labels,
                                     direction=-1,
                                     na.value="grey", 
                                     name="Albedo")

############################################################################################
# Which cells are under ice at each slice (binary, from the polygons)
############################################################################################

# Binned mean albedo (unused later; the maps re-bin with breaks_alb).
alb_interp_preds$alb_bin = cut(alb_interp_preds$alb_mean, breaks, labels=FALSE)

# New column for the ice flag.
alb_interp_preds$ice = NA

# The same 11,500 -> 12,000 relabel applied to the age vector, so the two agree.
ages[which(ages == 11500)] = 12000

# The slices present (25 values, with 12,000 in place of 11,500).
alb_preds_ages = unique(alb_interp_preds$year)

for (i in 1:length(alb_preds_ages)){
  
  print(i)
  # Rows for this slice, and their coordinates as lon/lat points.
  idx_age = which(alb_interp_preds$year == alb_preds_ages[i])
  
  coords_veg  = SpatialPoints(alb_interp_preds[idx_age,c('x', 'y')], 
                              proj4string=CRS(proj_WGS84))
  
  # Nearest polygon set in time (as above), normalised to lon/lat.
  idx_ice_match = which.min(abs(alb_preds_ages[i] - ice_years)) 
  
  proj4string(ice[[idx_ice_match]]) = proj_WGS84
  ice[[idx_ice_match]] = spTransform(ice[[idx_ice_match]], CRS(proj_WGS84))
  
  # ---- Point-in-polygon ----------------------------------------------------------------
  # over(points, polygons) returns, for each point, the attributes of the polygon it falls
  # in (NA if none). The polygons carry a column whose name starts with "SYMB" holding the
  # value "ICE"; that is what is kept. So `ice` is "ICE" under the sheet and NA elsewhere.
  ice_status_veg = over(coords_veg, ice[[idx_ice_match]])
  
  alb_interp_preds[idx_age, 'ice'] = ice_status_veg[,which(substr(colnames(ice_status_veg), 1,4)=='SYMB')]
  
}

# Another lon/lat proj string (unused here) and the coarse ages under a second name.
ll_proj = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"

years = c(50, 500, 2000, 4000, 6000, 8000, 10000, 12000)

# Bin edges and labels for the albedo maps.
breaks_alb = c(0, 5, 10, 20, 30, 40, 60, 80, 100)/100
labels_alb = c("0 - 5", "5 - 10", "10 - 20", "20 - 30", "30 - 40", "40 - 60", "60 - 80", "80 - 100")

############################################################################################
# Grid cells, the coarse subset, and ice albedo
############################################################################################

# The 1-degree grid.
grid_NA <- readRDS("data/grid.RDS")

# The stacked mean-prediction file; read, never used.
paleo_interp_sim_gam = readRDS('output/prediction/paleo_interp_predict_gam_bluesky.RDS')

# Cell id for each row, then the cell CENTRE coordinates from the grid, as long/lat.
cell_id <- raster::extract(grid_NA, alb_interp_preds[,c('x', 'y')])

alb_grid <- data.frame(cell_id, alb_interp_preds)
coords   = xyFromCell(grid_NA, alb_grid$cell_id)
colnames(coords) = c('long', 'lat')

alb_grid = cbind(coords, 
                 alb_grid[,c('x', 'y', 'cell_id', 'year', 'ice', 'alb_mean', 'alb_sd', 'month')])

# Keep only the eight coarse slices: 839,232 -> about 274,000 rows.
alb_grid_sub = subset(alb_grid, year %in% years) 

# Monthly ice albedo (the `ice_albedo` column: 0.6 to 0.8 by season).
alb_glacier = read.csv('data/albedo_glacier_monthly.csv', header=TRUE)

# ---- Albedo with ice ---------------------------------------------------------------------
# alb_mean_ice starts as the month's ice albedo for every row, is overwritten with the
# modelled albedo wherever the cell is NOT ice, and finally alb_mean itself is blanked
# where the cell IS ice. So: alb_mean = vegetation only (NA under ice); alb_mean_ice =
# vegetation or ice, whichever applies.
alb_grid_sub$alb_mean_ice = alb_glacier[match(alb_grid_sub$month, alb_glacier$month), 'ice_albedo']

alb_grid_sub$alb_mean_ice[which(is.na(alb_grid_sub$ice))] = alb_grid_sub$alb_mean[which(is.na(alb_grid_sub$ice))]

alb_grid_sub$alb_mean[which(alb_grid_sub$ice == 'ICE')] = NA

# Meant to drop cells missing from some slices, but the threshold is 8 rows against 96
# for a complete cell (8 slices x 12 months), so it removes only near-empty cells. As
# original.
cell_id_drop = as.numeric(names(which(table(alb_grid_sub$cell_id)<8)))
alb_grid_sub = alb_grid_sub[which(!(alb_grid_sub$cell_id %in% cell_id_drop)),]

# Binned albedo, sd and coefficient of variation, with labels, for the maps.
alb_grid_sub$alb_bin = cut(alb_grid_sub$alb_mean, breaks_alb, labels=FALSE)

breaks_sd = c(0, 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07)
labels_sd = c("0 - 0.01", "0.01 - 0.02", "0.02 - 0.03", "0.03 - 0.04", "0.04 - 0.05", "0.05 - 0.06", "0.06 - 0.07")
alb_grid_sub$alb_sd_bin = cut(alb_grid_sub$alb_sd, breaks_sd, labels=FALSE, include.lowest=TRUE)
alb_grid_sub$alb_sd_bin = factor(alb_grid_sub$alb_sd_bin, 
                                 levels=seq(1, length(labels_sd)),
                                 labels = labels_sd)

alb_grid_sub$alb_cv = alb_grid_sub$alb_sd / alb_grid_sub$alb_mean
breaks_cv = c(0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 10)
labels_cv = c("0 - 0.05", "0.05 - 0.1", "0.1 - 0.15", "0.15 - 0.2", "0.2 - 0.25", "0.25 - 0.3", "0.3 - 10")
alb_grid_sub$alb_cv_bin = cut(alb_grid_sub$alb_cv, breaks_cv, labels=FALSE, include.lowest=TRUE)
alb_grid_sub$alb_cv_bin = factor(alb_grid_sub$alb_cv_bin, 
                                 levels=seq(1, length(labels_cv)),
                                 labels = labels_cv)

# Facet label per row (the coarse age in ka), as an ordered factor.
labels_year = c('0.05 ka', '0.5 ka', '2 ka', '4 ka', '6 ka', '8 ka', '10 ka', '12 ka')

alb_grid_sub$facets = labels_year[match(alb_grid_sub$year, years)]
alb_grid_sub$facets = factor(alb_grid_sub$facets, levels = labels_year)

# Drop everything east of 60 W (Greenland and the Atlantic).
alb_grid_sub = alb_grid_sub[which(alb_grid_sub$long < (-60)),]

# Months in calendar order for facets.
alb_grid_sub$month = factor(alb_grid_sub$month, levels = months)

############################################################################################
# MAP 1: February albedo at the eight slices, stacked vertically
############################################################################################

# ---- Anatomy of these maps -------------------------------------------------------------
#   geom_polygon(pbs_ll ...)         land filled grey, as the background
#   geom_tile(alb_grid_sub ...)      one square per cell at its centre, coloured by the
#                                    binned albedo (factor() makes the bins discrete)
#   geom_polygon(ice_sub ...)        the ice sheet drawn on top, light grey
#   scale_fill_brewer(YlOrBr)        yellow-to-brown palette; NA (ice cells) drawn white
#   facet_grid(facets~.)             one row of panels per slice
#   theme_bw + theme(...)            white background, no axes, no grid
#   coord_fixed(xlim, ylim)          1:1 aspect and the map extent
ggplot()+
  geom_polygon(data=pbs_ll, aes(long,lat, group = group), color="grey", fill="grey") +
  geom_tile(data=subset(alb_grid_sub, month=='feb'), aes(x=long,y=lat, fill=factor(alb_bin))) +
  geom_polygon(data=ice_sub, aes(x=long, y=lat, group=group),  colour=ice_colour, fill=ice_fill) +
  scale_fill_brewer(type='seq', 
                    palette='YlOrBr', 
                    name = "Albedo", 
                    direction=1, 
                    na.value = "white",
                    labels = labels_alb) +
  facet_grid(facets~.)+
  theme_bw(12)+
  theme(axis.line = element_line(colour = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        legend.text = element_text(size=12),
        legend.title = element_text(size=12)) +
  coord_fixed(xlim = xlim, ylim = ylim)
ggsave(paste0('figures/alb_interp_preds_binned_tile_grid_', alb_prod, '.pdf'))#, width=12, height=14)
ggsave(paste0('figures/alb_interp_preds_binned_tile_grid_', alb_prod, '.png'))#, width=12, height=14)

############################################################################################
# MAP 2: all months x all eight slices (12 columns x 8 rows of panels)
############################################################################################

ggplot()+
  geom_polygon(data=pbs_ll, aes(long,lat, group = group), color="grey", fill="grey") +
  geom_tile(data=alb_grid_sub, aes(x=long,y=lat, fill=factor(alb_bin))) +
  geom_polygon(data=ice_sub, aes(x=long, y=lat, group=group),  colour=ice_colour, fill=ice_fill) +
  scale_fill_brewer(type='seq', 
                    palette='YlOrBr', 
                    name = "Albedo", 
                    direction=1, 
                    na.value = "white",
                    labels = labels_alb) +
  facet_grid(facets~month)+
  theme_bw(12)+
  theme(axis.line = element_line(colour = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        legend.text = element_text(size=12),
        legend.title = element_text(size=12)) +
  coord_fixed(xlim = xlim, ylim = ylim)
ggsave(paste0('figures/alb_interp_preds_month_binned_tile_grid_', alb_prod, '.pdf'), width=14, height=12)
ggsave(paste0('figures/alb_interp_preds_month_binned_tile_grid_', alb_prod, '.png'), width=14, height=12)

############################################################################################
# MAP 3: four representative months (the talk's choice) x eight slices
############################################################################################

months_sub = c('feb', 'may', 'aug', 'nov')

ggplot()+
  geom_polygon(data=pbs_ll, aes(long,lat, group = group), color="grey", fill="grey") +
  geom_tile(data=subset(alb_grid_sub, month %in% months_sub), aes(x=long,y=lat, fill=factor(alb_bin))) +
  geom_polygon(data=ice_sub, aes(x=long, y=lat, group=group),  colour=ice_colour, fill=ice_fill) +
  scale_fill_brewer(type='seq', 
                    palette='YlOrBr', 
                    name = "Albedo", 
                    direction=1, 
                    na.value = "white",
                    labels = labels_alb) +
  facet_grid(facets~month)+
  theme_bw(20)+
  theme(axis.line = element_line(colour = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        legend.text = element_text(size=12),
        legend.title = element_text(size=12)) +
  coord_fixed(xlim = xlim, ylim = ylim)
ggsave(paste0('figures/alb_interp_preds_month_sub_binned_tile_grid_', alb_prod, '.pdf'), width=14, height=12)
ggsave(paste0('figures/alb_interp_preds_month_sub_binned_tile_grid_', alb_prod, '.png'), width=14, height=12)

############################################################################################
# MAP 4: February again, panels wrapped into a grid instead of a column
############################################################################################

ggplot() +
  geom_polygon(data=pbs_ll, aes(long,lat, group = group), color="grey", fill="grey") +
  geom_tile(data=subset(alb_grid_sub, month=='feb'), aes(x=long,y=lat, fill=factor(alb_bin))) +
  geom_polygon(data=ice_sub, aes(x=long, y=lat, group=group),  colour=ice_colour, fill=ice_fill) +
  scale_fill_brewer(type='seq', palette='YlOrBr', 
                    na.value='transparent', name = "Albedo", direction=1, labels = labels_alb) +
  facet_wrap(facets~.) +
  theme_bw(12)+
  theme(axis.line = element_line(colour = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        legend.text = element_text(size=12),
        legend.title = element_text(size=12)) +
  coord_fixed(xlim = xlim, ylim = ylim)
ggsave(paste0('figures/alb_interp_preds_binned_tile_wrap_', alb_prod, '.pdf'), width=14, height=12)
ggsave(paste0('figures/alb_interp_preds_binned_tile_wrap_', alb_prod, '.png'), width=14, height=12)

############################################################################################
# MAP 5: one PDF page per slice, twelve months per page
############################################################################################

pdf(paste0('figures/alb_interp_preds_month_binned_tile_pages_', alb_prod, '.pdf'))
for (year in ages_sub){
  
  # NB `subset(alb_grid_sub, year==year)` compares the column with itself: inside
  # subset() the data frame's columns take precedence over variables outside it, so the
  # loop variable never gets a look-in and every row passes. Each page therefore
  # over-plots ALL eight slices; only the ice overlay changes (ice_sub has no `year`
  # column, so there the loop variable IS used). A bug in the original, preserved here.
  p = ggplot()+
    geom_polygon(data=pbs_ll, aes(long,lat, group = group), color="grey", fill="grey") +
    geom_tile(data=subset(alb_grid_sub, year==year), aes(x=long,y=lat, fill=factor(alb_bin))) +
    geom_polygon(data=subset(ice_sub, ages == year), aes(x=long, y=lat, group=group),  colour=ice_colour, fill=ice_fill) +
    scale_fill_brewer(type='seq', palette='YlOrBr', 
                      na.value='transparent', name = "Albedo", direction=1, labels = labels_alb) +
    facet_wrap(~month, nrow=4, ncol=4)+
    theme_bw(12)+
    theme(axis.line = element_line(colour = "black"),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.title = element_blank(),
          axis.ticks = element_blank(),
          axis.text = element_blank(),
          legend.text = element_text(size=12),
          legend.title = element_text(size=12)) +
    coord_fixed(xlim = xlim, ylim = ylim)
  print(p)
}
dev.off()

# Range of the sd, for a scale that is commented out.
lims = c(0, round(max(alb_grid_sub$alb_sd),2))

############################################################################################
# MAP 6: standard deviation of the 100 draws, months x slices
############################################################################################

ggplot()+
  geom_polygon(data=pbs_ll, aes(long,lat, group = group), color="grey", fill="grey") +
  geom_tile(data=alb_grid_sub, aes(x=long,y=lat, fill=alb_sd_bin)) +
  geom_polygon(data=ice_sub, aes(x=long, y=lat, group=group),  colour=ice_colour, fill=ice_fill) +
  scale_fill_brewer(type='seq', 
                    palette='YlOrBr', 
                    na.value='transparent', 
                    name = "Standard \ndeviation", 
                    direction=1, 
                    labels = labels_sd) +
  facet_grid(facets~month)+
  theme_bw(12)+
  theme(axis.line = element_line(colour = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        legend.text = element_text(size=12),
        legend.title = element_text(size=12)) +
  coord_fixed(xlim = xlim, ylim = ylim)
ggsave(paste0('figures/alb_interp_preds_month_sd_binned_tile_grid_', alb_prod, '.pdf'), width=14, height=12)
ggsave(paste0('figures/alb_interp_preds_month_sd_binned_tile_grid_', alb_prod, '.png'), width=14, height=12)

############################################################################################
# MAP 7: coefficient of variation (sd / mean), months x slices
############################################################################################

# Note the legend labels are the sd labels, not the cv ones. As original.
ggplot()+
  geom_polygon(data=pbs_ll, aes(long,lat, group = group), color="grey", fill="grey") +
  geom_tile(data=alb_grid_sub, aes(x=long,y=lat, fill=alb_cv_bin)) +
  geom_polygon(data=ice_sub, aes(x=long, y=lat, group=group),  colour=ice_colour, fill=ice_fill) +
  scale_fill_brewer(type='seq', palette='YlOrBr', 
                    na.value='transparent', name = "CV", direction=1, labels = labels_sd) +
  facet_grid(facets~month)+
  theme_bw(12)+
  theme(axis.line = element_line(colour = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        legend.text = element_text(size=12),
        legend.title = element_text(size=12)) +
  coord_fixed(xlim = xlim, ylim = ylim)
ggsave(paste0('figures/alb_interp_preds_month_cv_binned_tile_grid_', alb_prod, '.pdf'), width=14, height=12)
ggsave(paste0('figures/alb_interp_preds_month_cv_binned_tile_grid_', alb_prod, '.png'), width=14, height=12)

############################################################################################
# Differences between consecutive COARSE slices, per cell and month
############################################################################################

# The eight coarse ages, for padding each cell's series.
years_df = data.frame(year = ages_sub)

# Empty output table: the columns of alb_grid_sub minus `ice`, plus six new ones.
alb_diff_df = data.frame(matrix(NA, nrow=0, ncol=ncol(alb_grid_sub)+5))

alb_diff_colnames = colnames(alb_grid_sub)[which(!(colnames(alb_grid_sub) %in% 'ice'))]

colnames(alb_diff_df) = c(alb_diff_colnames, 'alb_mean_ice_old', 'alb_mean_ice_young', 
                          'ice_young', 'ice_old', 
                          'alb_diff', 'alb_diff_ice')#c('cell_id', 'long', 'lat', 'x', 'y', 'year', 'alb_pred', 'alb_bin', 'alb_diff')

# Loop over cells (2,834 in the anchored run) and months; same shape as script 7a's loop.
cell_ids = unique(alb_grid_sub$cell_id)
N_cells  = length(cell_ids)
for (i in 1:N_cells){
  
  print(paste0('Cell ', i, ' of ', N_cells))
  
  for (month in months){
    
    # This cell-month's rows, young to old.
    alb_cell = alb_grid_sub[which((alb_grid_sub$cell_id == cell_ids[i])&(alb_grid_sub$month == month)),] 
    alb_cell = alb_cell[order(alb_cell$year),]
    
    # No pairs possible from one row.
    if (nrow(alb_cell) == 1){
      next
    } 
    
    # Pad to all eight ages so pairs are always consecutive coarse slices.
    alb_cell_filled = merge(years_df, alb_cell, all.x=TRUE)
    
    # ---- The seven differences ---------------------------------------------------------
    # For each pair (rows 1..7 young, 2..8 old): the identifiers from the young row; the
    # with-ice albedo at each end; the ice flags at each end; and two differences, both
    # young minus old: alb_diff on the vegetation-only albedo (NA if either end is ice)
    # and alb_diff_ice on the vegetation-or-ice albedo.
    alb_diff_df = rbind(alb_diff_df, 
                        data.frame(subset(alb_cell_filled[1:(nrow(alb_cell_filled)-1), ], 
                                          select=-c(ice)), 
                                   alb_mean_ice_old = alb_cell_filled[2:nrow(alb_cell_filled), 'alb_mean_ice'],
                                   alb_mean_ice_young = alb_cell_filled[1:(nrow(alb_cell_filled)-1), 'alb_mean_ice'],
                                   ice_young = alb_cell_filled$ice[1:(nrow(alb_cell_filled)-1)],
                                   ice_old = alb_cell_filled$ice[2:nrow(alb_cell_filled)],
                                   alb_diff = -diff(alb_cell_filled$alb_mean),
                                   alb_diff_ice = -diff(alb_cell_filled$alb_mean_ice)))
  }
}

# Drop padded rows with no data.
alb_diff_df =  alb_diff_df[which(!is.na(alb_diff_df$lat)),]

# Saved: script 9 reads this to rerun the talk's recipe. Anchored.
saveRDS(alb_diff_df, paste0('data/alb_interp_preds_diffs_', alb_prod, '.RDS'))

############################################################################################
# Ice outlines paired per period, for the difference maps and for script 8
############################################################################################

# Period labels for the seven coarse pairs.
labels = c('0.05 - 0.5 ka', '0.5 - 2 ka', '2 - 4 ka', '4 - 6 ka', '6 - 8 ka', '8 - 10 ka', '10 - 12 ka')

# Empty tables for the young-end and old-end outlines of each period.
ice_fort_diff_young = data.frame(matrix(NA, nrow=0, ncol=10))
ice_fort_diff_old = data.frame(matrix(NA, nrow=0, ncol=10))
ages_sub = years

# Keep the first nine columns, which is all of them: ice_fort has exactly nine, so this
# line changes nothing.
ice_fort = ice_fort[,1:9]

for (i in 1:(length(ages_sub)-1)){
  print(ages_sub[i])
  
  age_now = ages_sub[i]
  
  # Nearest polygon set for the young and the old end of this period.
  idx_ice_match_young = which.min(abs(ages_sub[i] - ice_years))
  idx_ice_match_old = which.min(abs(ages_sub[i+1] - ice_years))
  
  # NB ice_fort$ages holds the COARSE age each polygon set stands for (50, 500, 2000, ...)
  # but is compared here with the polygon YEAR (1000, 1000, 2000, ...). The two agree only
  # from 2,000 BP up, so the 0.05-0.5 ka period gets no outline at either end and 0.5-2 ka
  # gets none at the young end; in the anchored run the young table has 75,065 rows and
  # the old table 87,742. A bug in the original, preserved here; script 8 loads the files
  # but does not use them on the current path.
  ice_fort_age_young = ice_fort[which(ice_fort$ages == ice_years[idx_ice_match_young]),]
  
  ice_fort_age_old = ice_fort[which(ice_fort$ages == ice_years[idx_ice_match_old]),]
  
  print(labels[i])
  
  ice_fort_diff_young = rbind(ice_fort_diff_young,
                              data.frame(ice_fort_age_young,
                                         facets = rep(labels[i],  nrow(ice_fort_age_young))
                              ))
  
  ice_fort_diff_old = rbind(ice_fort_diff_old,
                            data.frame(ice_fort_age_old,
                                       facets = rep(labels[i],  nrow(ice_fort_age_old))
                            ))
  
}

# Ordered period factor on both tables, then save for script 8.
labels_period = c('0.05 - 0.5 ka', '0.5 - 2 ka', '2 - 4 ka', '4 - 6 ka', '6 - 8 ka', '8 - 10 ka', '10 - 12 ka')

ice_fort_diff_old$facets = factor(ice_fort_diff_old$facets,
                                  levels = labels_period,
                                  labels = labels_period)

ice_fort_diff_young$facets = factor(ice_fort_diff_young$facets,
                                    levels = labels_period,
                                    labels = labels_period)

saveRDS(ice_fort_diff_young, 'data/ice_fort_diff_young.RDS')
saveRDS(ice_fort_diff_old, 'data/ice_fort_diff_old.RDS')

# Period label for each difference row, from its young age.
diff_years = years[-length(years)]
alb_diff_df$facets = labels[match(alb_diff_df$year, diff_years)]
alb_diff_df$facets = factor(alb_diff_df$facets, levels =  labels)

############################################################################################
# Diverging colour scales for the difference maps
############################################################################################

# Symmetric limits at the largest absolute difference, rounded up to 0.01.
max_diff = max(abs(alb_diff_df$alb_diff), na.rm=TRUE)
thresh = ceiling(max_diff*100)/100

# Positions along the palette; the second definition wins. Pinches the colour change
# around zero so small differences show.
values = c(0, 0.4, 0.45, 0.5, 0.55, 0.6, 1)
values = c(0, 0.45, 0.48, 0.5, 0.52, 0.55, 1)

# Fill and colour scales, each defined twice (BrBG then RdYlBu for fill; RdYlBu then BrBG
# for colour); the second definition of each is what is used.
sc_fill_diverge <- scale_fill_distiller(type = "div",
                                        palette = "BrBG",
                                        na.value="grey",
                                        name="Albedo change",
                                        limits = c(-thresh,thresh),
                                        values = values)

sc_fill_diverge <- scale_fill_distiller(type = "div",
                                        palette = "RdYlBu",#"BrBG",
                                        na.value="grey",
                                        name="Albedo change",
                                        limits = c(-thresh,thresh),
                                        values = values)

sc_colour_diverge <- scale_colour_distiller(type = "div",
                                            palette = "RdYlBu",#"BrBG",
                                            direction=1,
                                            na.value="transparent",#grey", 
                                            name="Albedo change",
                                            limits = c(-thresh,thresh), 
                                            values = values)

sc_colour_diverge <- scale_colour_distiller(type = "div",
                                            palette = "BrBG",
                                            na.value="transparent",#grey",
                                            name="Albedo change",
                                            limits = c(-thresh,thresh),
                                            values = values)

############################################################################################
# MAP 8: albedo change, months x periods, with old and young ice margins
############################################################################################

ggplot()+
  geom_polygon(data=pbs_ll, aes(long,lat, group = group), color="grey", fill="grey") +
  geom_tile(data=alb_diff_df, aes(x=long, y=lat, fill = alb_diff)) +
  geom_polygon(data=ice_fort_diff_old, aes(x=long, y=lat, group=group),  colour=ice_colour, fill=ice_fill) +
  geom_polygon(data=ice_fort_diff_young, aes(x=long, y=lat, group=group),  colour=ice_colour_dark, fill=ice_fill_dark) +
  sc_fill_diverge + 
  facet_grid(month~facets)+
  theme_bw(12)+
  theme(axis.line = element_line(colour = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        legend.text = element_text(size=12),
        legend.title = element_text(size=12)) +
  coord_fixed(xlim = xlim, ylim = ylim)
ggsave(paste0('figures/alb_interp_preds_month_diff_tile_grid_', alb_prod, '.png'), width=12, height=14)
ggsave(paste0('figures/alb_interp_preds_month_diff_tile_grid_', alb_prod, '.pdf'), width=12, height=14)

############################################################################################
# MAP 9: one PDF page per period, twelve months per page
############################################################################################

facets = as.vector(unique(alb_diff_df$facets))

pdf(paste0('figures/alb_interp_preds_month_diff_tile_pages_', alb_prod, '.pdf'))
for (i in 1:length(facets)){
  
  facet = facets[i]
  
  diff_sub = alb_diff_df[which(alb_diff_df$facets == facet),]
  
  p<-ggplot()+
    geom_polygon(data=pbs_ll, aes(long,lat, group = group), color="grey", fill="grey") +
    geom_tile(data=diff_sub, aes(x=long, y=lat, fill = alb_diff)) +
    geom_polygon(data=subset(ice_fort_diff_old, facets==facet), aes(x=long, y=lat, group=group),  colour=ice_colour, fill=ice_fill) +
    geom_polygon(data=subset(ice_fort_diff_young, facets==facet), aes(x=long, y=lat, group=group),  colour=ice_colour_dark, fill=ice_fill_dark) +
    facet_wrap(~month, nrow=3, ncol=4) +
    sc_fill_diverge + 
    theme_bw(12)+
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.background = element_blank(),
          axis.title = element_blank(),
          axis.ticks = element_blank(),
          axis.text = element_blank(),
          legend.text = element_text(size=12),
          legend.title = element_text(size=12)) +
    coord_fixed(xlim = xlim, ylim = ylim)
  print(p)
}
dev.off()

# Close the provenance manifest, listing the figures and data files written.
run_end(outputs = Filter(file.exists, c(
  list.files('figures', pattern = 'alb_interp', full.names = TRUE),
  'data/ice_fort.RDS', 'data/ice_fort_diff_young.RDS', 'data/ice_fort_diff_old.RDS',
  paste0('data/alb_interp_preds_diffs_', alb_prod, '.RDS'))))
