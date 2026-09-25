# 1_veg_lct_prep.R: turn the land-cover posterior into two plain tables
# Interp (spatially complete) path only: the point-based code and its guards are
# removed. Every remaining line is unchanged from the original.

library(dplyr)
library(tidyr)
library(elevatr)

# standard lat long projection
ll_proj = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"


lct_interp = readRDS('data/veg_posts_interp_ice.RDS')

#  not sure if should use median
lct_interp = lct_interp %>%
  group_by(cell_id, x, y, ages, LCT) %>%
  dplyr::summarize(value = mean(value))

lct_interp_wide = pivot_wider(lct_interp, 
                              id_cols = c('cell_id', 'x', 'y', 'ages'), 
                              names_from = c('LCT'), 
                              values_from = c('value'))

lct_interp_wide = data.frame(lct_interp_wide)

locations_interp = lct_interp_wide[,c('x', 'y')]

ele_get_interp = get_elev_point(locations_interp, 
                                prj = ll_proj, 
                                src = "aws")

lct_interp_all = data.frame(lct_interp_wide[,c('ages', 'x', 'y')],
                     elev = ele_get_interp$elevation,
                     lct_interp_wide[,c('ET', 'OL', 'ST')])



lct_interp_modern = lct_interp_all[which(lct_interp_all$ages == 50), ]

lct_interp_modern = lct_interp_modern[, which(!(colnames(lct_interp_modern) %in% c('ages')))]

saveRDS(lct_interp_modern, 'data/lct_modern_reveals_interp.RDS')

lct_interp_paleo = lct_interp_all

saveRDS(lct_interp_paleo, 'data/lct_paleo_reveals_interp.RDS')
