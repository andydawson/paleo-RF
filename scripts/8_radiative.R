############################################################################################
# 8_radiative.R  --  turn albedo change into radiative forcing
#
# WHERE THIS SITS IN THE PIPELINE
#   Step 8 of 9. Script 7a produced, for every cell, month and pair of consecutive time
#   slices, the change in surface albedo, split several ways between vegetation and ice.
#   This script converts each of those albedo changes into a radiative forcing in W/m^2
#   by multiplying by a "radiative kernel", and does so with three different kernels.
#
# WHAT A RADIATIVE KERNEL IS
#   A climate model is run with surface albedo perturbed by a small fixed amount, and the
#   resulting change in the energy balance is recorded for every grid box and month. The
#   kernel is that response per unit of albedo change: "if albedo here rises by 1% in
#   March, the planet reflects this many more W/m^2". Multiplying an albedo change by the
#   kernel gives the forcing without re-running the climate model. Three published kernels
#   are used, and they are NOT interchangeable (see the questions file, C3 and C4):
#     HadGEM3   top-of-atmosphere, clear-sky, units W/m^2 per 1% albedo, stored NEGATIVE
#               (more albedo = less absorbed sunlight)
#     CAM5      the variable read (FSNSC) is a SURFACE flux, clear-sky, per 1%, negative
#     CACK      top-of-atmosphere, all-sky, per UNIT albedo (0..1), stored POSITIVE.
#               band = 3 selects the year 2002 from a 16-year series, not a sky condition.
#   The sign and scale differences are why the forcing formulas below differ by kernel.
#
# WHAT COMES IN
#   data/ALB_diffs_bluesky.RDS                    ~764,640 x 21, from script 7a
#     One row per cell x month x consecutive slice-pair: coordinates, area, the two ice
#     fractions, and ten albedo-difference columns (alb_diff_*).
#   data/radiative-kernels/HadGEM3-GA7.1_TOA_kernel_L19.nc   12 monthly layers, 1.25 x 1.875 deg
#   data/radiative-kernels/CAM5/alb.kernel.nc                12 monthly bands
#   data/radiative-kernels/CACKv1.0/CACKv1.0.nc              12 months x 16 years, 1 deg
#   data/ice_fort*.RDS      ice outlines for maps; loaded but not used on this path
#   data/map-data/geographic/pbs*.RDS   boundaries; loaded but not used on this path
#
# WHAT GOES OUT
#   output/forcing/RF_holocene_all_cases.RDS      764,640 x 56
#     The input table plus the three kernel values per row (rk_*) and thirty forcing
#     columns rf_<kernel>_<variant>: 3 kernels x 10 albedo-difference variants. Anchored.
#
# SIGN CONVENTION
#   Script 7a defines each albedo difference as young minus old. Albedo falling through
#   time (forest replacing ice, say) gives a negative difference; multiplied by a negative
#   kernel that is a POSITIVE forcing, i.e. warming. So in the output, positive = warming.
#
# HOW THE KERNELS ARE LINED UP WITH THE DATA
#   The kernel files use longitude 0..360 (not -180..180), and CACK's file has no
#   coordinate metadata at all, just a 180 x 360 array. The script therefore builds two
#   extra coordinate columns, long360 and lat180, and samples the kernel rasters at those.
#   The check plots that would confirm the alignment are commented out in the original;
#   the alignment was checked independently on 2026-09-21 (every cell returns a value).
#
# RUN TIME  About 20 seconds.
############################################################################################

# sp for SpatialPointsDataFrame, ggplot2 for the diagnostic plots, raster for reading
# the kernels and extracting at points, sf kept because sp's coordinate handling relies
# on it, dplyr for the pipe. (tidyr and ggbreak were loaded by the original and unused.)
library(sp)
library(ggplot2)
library(raster)
library(sf)
library(dplyr)

alb_prod = "bluesky"

# Month names and numbers; the kernel files are indexed by month number.
months = c('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec')
months_number = seq(1, 12)

# Lon/lat CRS string for the point objects below.
ll_proj = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"

# Map limits, unused on this path.
ylim = c(12, 82) 
xlim = c(-166, -50) 

# Output directory; absent on a fresh clone.
dir.create('output/forcing', recursive = TRUE, showWarnings = FALSE)

# Provenance manifest (see R/run_manifest.R): records inputs with checksums, the commit,
# thread settings and the config below, and writes runs/<timestamp>_8_radiative.md.
source('R/run_manifest.R')
run_start('8_radiative',
          note   = Sys.getenv('RUN_NOTE'),
          inputs = Filter(file.exists, c(
            paste0('data/ALB_diffs_', alb_prod, '.RDS'),
            'data/radiative-kernels/HadGEM3-GA7.1_TOA_kernel_L19.nc',
            'data/radiative-kernels/CAM5/alb.kernel.nc',
            'data/radiative-kernels/CACKv1.0/CACKv1.0.nc',
            'data/ice_fort.RDS', 'data/ice_fort_diff_young.RDS', 'data/ice_fort_diff_old.RDS',
            'data/map-data/geographic/pbs_ll.RDS',
            'data/map-data/geographic/pbs.RDS')),
          config = list(alb_prod = alb_prod, months = months,
                        cack_band = 3, cack_band_meaning = 'year 2002, see question C3'))

# Ice outlines produced by script 7, for maps. Loaded; not used further in this script.
ice_fort = readRDS('data/ice_fort.RDS')
ice_fort_diff_young = readRDS('data/ice_fort_diff_young.RDS')
ice_fort_diff_old = readRDS('data/ice_fort_diff_old.RDS')

# Period labels and slice ages; defined for plotting code that is commented out.
labels_period = c('0.05 - 0.5 ka', '0.5 - 2 ka', '2 - 4 ka', '4 - 6 ka', '6 - 8 ka', '8 - 10 ka', '10 - 12 ka')

ages = c(50, 200, seq(500, 11500, by=500))
N_times = length(ages)
ages_sub = c(50, 500, 2000, 4000, 6000, 8000, 10000, 12000)

# Colours for ice on maps; unused on this path.
ice_fill = 'gainsboro'
ice_colour = 'gray60'

ice_fill_dark = 'ivory3'
ice_colour_dark = 'gray40'

# Political boundaries; unused on this path.
pbs_ll = readRDS('data/map-data/geographic/pbs_ll.RDS')
pbs = readRDS('data/map-data/geographic/pbs.RDS')

############################################################################################
# Kernels and the albedo differences
############################################################################################

# ---- HadGEM3 ------------------------------------------------------------------------------
# brick() reads all 12 monthly layers of the clear-sky shortwave albedo kernel at once.
# level=1 picks the single vertical level; varname names the variable inside the NetCDF.
rk_hadgem = brick('data/radiative-kernels/HadGEM3-GA7.1_TOA_kernel_L19.nc', level=1, varname='albedo_sw_cs')

# The albedo-difference table from script 7a.
alb_interp_diff_full = readRDS(paste0('data/ALB_diffs_', alb_prod, '.RDS'))

alb_diff = alb_interp_diff_full

# ---- Coordinates in the kernels' conventions ---------------------------------------------
# long360: western-hemisphere longitudes (-166 to -50) become 194 to 310, i.e. 360 + long.
#          Written as 180 + 180 - |long|, which is the same thing for negative longitudes.
# lat180:  latitude shifted to 0..180, which is CACK's row index space (its file carries no
#          coordinates, so row i = latitude i - 90).
alb_diff$long360 = 180 + 180 - abs(alb_diff$long)
alb_diff$lat180 = alb_diff$lat + 90

# Point objects for sampling: one with (long360, lat) for HadGEM3 and CAM5, one with
# (long360, lat180) for CACK. Both carry the whole table as attributes.
alb_diff_spatial = SpatialPointsDataFrame(coords = alb_diff[,c('long360', 'lat')], 
                                          data = alb_diff, 
                                          proj4string = CRS(ll_proj))

alb_diff_spatial_cack = SpatialPointsDataFrame(coords = alb_diff[,c('long360', 'lat180')], 
                                               data = alb_diff, 
                                               proj4string = CRS(ll_proj))

# Empty kernel columns, filled month by month below.
alb_diff$rk_hadgem = NA
alb_diff$rk_cam5 = NA
alb_diff$rk_cack = NA

############################################################################################
# Sample each kernel at every cell, one month at a time
############################################################################################

for (month in months){
  
  print(month)
  # Month as a number (1..12), to pick the layer/band.
  month_number = months_number[which(months == month)]
  print(month_number)
  
  # Rows of the table belonging to this month.
  idx_month = which(alb_diff$month == month)
  
  # ---- HadGEM3: this month's layer, sampled at this month's points ------------------------
  # raster::extract(raster, points) returns the value of the raster cell under each point.
  # Kernels do not change through time, so one value per cell serves all slice-pairs.
  rk_hadgem_month = raster::extract(rk_hadgem[[month_number]], alb_diff_spatial[idx_month,])
  alb_diff$rk_hadgem[idx_month] = rk_hadgem_month 
  
  # A data.frame of the kernel layer (x, y, kernel) and a check plot of kernel with the
  # sample points overlaid. The plot is built but never printed or saved.
  rk_hadgem_df = as.data.frame(rk_hadgem[[month_number]], xy=TRUE)
  colnames(rk_hadgem_df) = c('x', 'y', 'kernel')
  
  ggplot() +
    geom_raster(data=rk_hadgem_df, aes(x=x, y=y, fill=kernel)) +
    geom_point(data=data.frame(alb_diff_spatial), aes(x=long360, y=lat), shape=1, alpha=0.1) +
    scale_fill_gradientn(colours = terrain.colors(10))
  
  # ---- CAM5: read this month's band of the surface clear-sky net solar flux --------------
  rk_cam5 = raster('data/radiative-kernels/CAM5/alb.kernel.nc', 
                   varname='FSNSC', 
                   band=month_number)
  
  rk_cam5_month = raster::extract(rk_cam5, alb_diff_spatial[idx_month,])
  alb_diff$rk_cam5[idx_month] = rk_cam5_month 
  
  rk_cam5_df = as.data.frame(rk_cam5, xy=TRUE)
  colnames(rk_cam5_df) = c('x', 'y', 'kernel')
  
  # ---- CACK: month = level, band 3 = the third year of the series (2002) -----------------
  rk_cack = raster('data/radiative-kernels/CACKv1.0/CACKv1.0.nc', 
                   varname='CACK', 
                   level=month_number, 
                   band=3)
  
  # The array comes in transposed and upside down relative to the (long360, lat180)
  # index space; flip() then t() puts it the right way round. This is the step the
  # commented-out check plots were for.
  rk_cack =  t(flip((rk_cack)))
  
  rk_cack_df = as.data.frame(rk_cack, xy=TRUE)
  colnames(rk_cack_df) = c('x', 'y', 'kernel')
  
  # Sample CACK at the (long360, lat180) points.
  rk_cack_month = raster::extract(rk_cack, alb_diff_spatial_cack[idx_month,])
  alb_diff$rk_cack[idx_month] = rk_cack_month 
  
}

############################################################################################
# Forcing = albedo difference x kernel, for every kernel and every variant
############################################################################################

# Keep only cells between 27 N and 74 N. Outside that band the land cover reconstruction
# is sparse or absent; this is the study domain used for continental totals.
alb_diff = alb_diff[which(alb_diff$lat>27),]
alb_diff = alb_diff[which(alb_diff$lat<74),]

# ---- HadGEM3 ----------------------------------------------------------------------------
# The kernel is per 1% of albedo; the albedo differences are fractions (0..1); so multiply
# by 100 to get percent before multiplying by the kernel. The kernel is negative, so a
# fall in albedo (negative difference) gives a positive forcing. Ten variants, one per
# alb_diff_* column from script 7a (see that script for what each means).
alb_diff$rf_hadgem_veg_thresh = alb_diff$alb_diff_veg_thresh*100 * alb_diff$rk_hadgem
alb_diff$rf_hadgem_ice_thresh = alb_diff$alb_diff_ice_thresh*100 * alb_diff$rk_hadgem
alb_diff$rf_hadgem_icesc_thresh = alb_diff$alb_diff_icesc_thresh*100 * alb_diff$rk_hadgem
alb_diff$rf_hadgem_veg_ice_thresh = alb_diff$alb_diff_veg_ice_thresh*100 * alb_diff$rk_hadgem
alb_diff$rf_hadgem_veg_icesc_thresh = alb_diff$alb_diff_veg_icesc_thresh*100 * alb_diff$rk_hadgem

alb_diff$rf_hadgem_veg_part = alb_diff$alb_diff_veg_part*100 * alb_diff$rk_hadgem
alb_diff$rf_hadgem_ice_part = alb_diff$alb_diff_ice_part*100 * alb_diff$rk_hadgem
alb_diff$rf_hadgem_icesc_part = alb_diff$alb_diff_icesc_part*100 * alb_diff$rk_hadgem
alb_diff$rf_hadgem_veg_ice_parts = alb_diff$alb_diff_veg_ice_parts*100 * alb_diff$rk_hadgem
alb_diff$rf_hadgem_veg_icesc_parts = alb_diff$alb_diff_veg_icesc_parts*100 * alb_diff$rk_hadgem

# ---- CAM5: same convention as HadGEM3 (per 1%, negative) ------------------------------
alb_diff$rf_cam5_veg_thresh = alb_diff$alb_diff_veg_thresh*100 * alb_diff$rk_cam5
alb_diff$rf_cam5_ice_thresh = alb_diff$alb_diff_ice_thresh*100 * alb_diff$rk_cam5
alb_diff$rf_cam5_icesc_thresh = alb_diff$alb_diff_icesc_thresh*100 * alb_diff$rk_cam5
alb_diff$rf_cam5_veg_ice_thresh = alb_diff$alb_diff_veg_ice_thresh*100 * alb_diff$rk_cam5
alb_diff$rf_cam5_veg_icesc_thresh = alb_diff$alb_diff_veg_icesc_thresh*100 * alb_diff$rk_cam5

alb_diff$rf_cam5_veg_part = alb_diff$alb_diff_veg_part*100 * alb_diff$rk_cam5
alb_diff$rf_cam5_ice_part = alb_diff$alb_diff_ice_part*100 * alb_diff$rk_cam5
alb_diff$rf_cam5_icesc_part = alb_diff$alb_diff_icesc_part*100 * alb_diff$rk_cam5
alb_diff$rf_cam5_veg_ice_parts = alb_diff$alb_diff_veg_ice_parts*100 * alb_diff$rk_cam5
alb_diff$rf_cam5_veg_icesc_parts = alb_diff$alb_diff_veg_icesc_parts*100 * alb_diff$rk_cam5

# ---- CACK: per UNIT albedo and stored positive ------------------------------------------
# No factor of 100, and the sign is flipped explicitly so that, as for the other two, a
# fall in albedo comes out as a positive forcing.
alb_diff$rf_cack_veg_thresh = alb_diff$alb_diff_veg_thresh* (-alb_diff$rk_cack)
alb_diff$rf_cack_ice_thresh = alb_diff$alb_diff_ice_thresh* (-alb_diff$rk_cack)
alb_diff$rf_cack_icesc_thresh = alb_diff$alb_diff_icesc_thresh* (-alb_diff$rk_cack)
alb_diff$rf_cack_veg_ice_thresh = alb_diff$alb_diff_veg_ice_thresh* (-alb_diff$rk_cack)
alb_diff$rf_cack_veg_icesc_thresh = alb_diff$alb_diff_veg_icesc_thresh* (-alb_diff$rk_cack)

alb_diff$rf_cack_veg_part = alb_diff$alb_diff_veg_part* (-alb_diff$rk_cack)
alb_diff$rf_cack_ice_part = alb_diff$alb_diff_ice_part* (-alb_diff$rk_cack)
alb_diff$rf_cack_icesc_part = alb_diff$alb_diff_icesc_part* (-alb_diff$rk_cack)
alb_diff$rf_cack_veg_ice_parts = alb_diff$alb_diff_veg_ice_parts* (-alb_diff$rk_cack)
alb_diff$rf_cack_veg_icesc_parts = alb_diff$alb_diff_veg_icesc_parts* (-alb_diff$rk_cack)

############################################################################################
# Exploratory checks on the largest ice forcings (printed only; nothing saved)
############################################################################################

# June rows whose ice-threshold forcing exceeds 100 W/m^2: the extreme deglaciation cells.
bar = alb_diff[which((alb_diff$rf_hadgem_ice_thresh>100)&(alb_diff$month=='jun')),]

# Print a few columns of them, two ways.
bar[,c('cell_id', 'lat', 'long', 'ice_frac_old', 'ice_frac_young', 
       'alb_diff_ice_thresh', 'rk_hadgem', 'rf_hadgem_ice_thresh',  
       'rk_cam5', 'rf_cam5_ice_thresh')]

head(bar[,c('cell_id', 'lat', 'long', 'ice_frac_old', 'ice_frac_young', 
                   'alb_diff_ice_thresh', 'rk_hadgem', 'rf_hadgem_ice_thresh', 'rf_hadgem_ice_part')])

# A hand calculation left in the file: one albedo difference times one kernel value.
-0.3326444*-3.297408

# Threshold versus area-fraction decompositions for these cells, and how the three
# kernels compare at them. Built and (under Rscript) sent to Rplots.pdf; not saved.
ggplot(data=bar) +
  geom_point(aes(x=alb_diff_ice_thresh, y=alb_diff_ice_part)) +
  coord_fixed()

ggplot(data=bar) +
  geom_point(aes(x=ice_frac_old, y=alb_diff_ice_thresh)) +
  geom_point(aes(x=ice_frac_old, y=alb_diff_ice_part), colour='dodgerblue', alpha=0.5)

ggplot(data=bar) +
  geom_histogram(aes(x=alb_diff_ice_thresh - alb_diff_ice_part)) 

# The three kernels put on a common footing (per unit albedo, positive) against ice
# fraction: this is where the factor-of-two gap between CACK and the other two is visible.
ggplot(data=bar) +
  geom_point(aes(x=ice_frac_old, y=-rk_hadgem*100)) +
  geom_point(aes(x=ice_frac_old, y=rk_cack), colour='dodgerblue', alpha=0.5) +
  geom_point(aes(x=ice_frac_old, y=-rk_cam5*100), colour='pink', alpha=0.5)

ggplot(data=bar) +
  geom_point(aes(x=ice_frac_old, y=-rk_hadgem*100*alb_diff_ice_thresh)) +
  geom_point(aes(x=ice_frac_old, y=rk_cack*alb_diff_ice_thresh), colour='dodgerblue', alpha=0.5) +
  geom_point(aes(x=ice_frac_old, y=-rk_cam5*100*alb_diff_ice_thresh), colour='pink', alpha=0.5)

bar$alb_diff_ice_thresh

############################################################################################
# Save
############################################################################################

# The full table with kernels and all thirty forcing columns. Script 9 reads this.
saveRDS(alb_diff, paste0('output/forcing/RF_holocene_all_cases.RDS'))

# Close the provenance manifest, recording the output and its size.
run_end(outputs = Filter(file.exists, 'output/forcing/RF_holocene_all_cases.RDS'))
