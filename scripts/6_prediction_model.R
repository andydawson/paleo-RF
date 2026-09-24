############################################################################################
# 6_prediction_model.R  --  hindcast albedo for every Holocene slice
#
# WHERE THIS SITS IN THE PIPELINE
#   Step 6 of 9. Scripts 4 and 5 produced, for each month, a model that maps
#   (location, elevation, land cover) to albedo, fitted on the modern world. This script
#   points those models at the PAST: it feeds them the land cover of every cell at every
#   time slice and asks what albedo that implies. This is the central assumption of the
#   whole study, that the modern relationship held throughout the Holocene.
#
# WHAT COMES IN
#   data/lct_paleo_reveals_interp.RDS      69,936 rows x 7:  ages, x, y, elev, ET, OL, ST
#     From script 1: every cell at every one of the 25 slices (50 BP included).
#   output/calibration/calibration_mod_interp_selected_<m>_bluesky.RDS   12 models
#     From script 5 (model 8 for every month).
#
# WHAT GOES OUT   (all under output/prediction/; <m> = jan ... dec)
#   paleo_interp_predict_gam_<m>_bluesky.RDS          69,936 x 8
#     The input table plus alb_mean, the model's fitted mean albedo. Deterministic.
#   paleo_interp_predict_gam_samps_<m>_bluesky.RDS    6,993,600 x 9, ~200 MB each
#     100 simulated albedo values per cell-slice, in long form (one row per draw).
#   paleo_interp_predict_gam_summary_<m>_bluesky.RDS  69,936 x 12
#     Per cell-slice: mean, sd, 2.5%, 50% and 97.5% of the 100 draws.
#   paleo_interp_predict_gam_bluesky.RDS              839,232 x 9   (12 months stacked)
#   paleo_interp_predict_gam_summary_bluesky.RDS      839,232 x 13  (12 months stacked)
#     The two stacked files are what scripts 7 and 7a read.
#
# WHAT THE UNCERTAINTY HERE IS, AND IS NOT
#   simulate(nsim = 100) draws albedo values from the fitted beta distribution around
#   each cell's mean, using the model's estimated precision. So the spread in the summary
#   file is the scatter the model expects between individual observations and the mean,
#   the same kind of interval script 5 checked against the modern data. It does NOT
#   include uncertainty in the model's coefficients (simulate() treats them as known), and
#   the uncertainty in the land cover itself was already averaged away in script 1. The
#   draws are unseeded, so these files differ slightly between runs; the deterministic
#   alb_mean does not, PROVIDED the BLAS thread count is the same: with 8 threads the
#   mean-prediction file reproduces the anchor byte for byte, with 4 threads it differs
#   in the last bits (summation order), enough to fail identical() but not all.equal(). Both points are in the questions file (section A). gratia's help
#   page calls these "posterior simulations"; do not read that as coefficient
#   uncertainty. Its code is predict() for the mean, then the family's random-deviate
#   function with the coefficients held fixed.
#
# COLUMN NAME CHANGE
#   The land-cover table calls the time slice `ages`; this script renames it `year` and
#   everything downstream uses `year`. Values are still years before present.
#
# RUN TIME  About 15 minutes. Memory peaks around the melt of 7 million rows per month.
############################################################################################

# dplyr for group_by/summarize, mgcv for predict.gam on the saved models, gratia because
# loading it is what gives simulate() a method for GAM objects (see script 5), reshape2
# for melt. (raster, tidyr, sp and ggplot2 were loaded by the original for other paths
# and are dropped here.)
library(dplyr)
library(mgcv)
library(gratia)
library(reshape2)

alb_prod = "bluesky"

dir.create('output/prediction', recursive = TRUE, showWarnings = FALSE)

months = c('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec')

############################################################################################
# The paleo land cover
############################################################################################

# All cells at all 25 slices, with elevation and the three cover fractions.
lct_interp_paleo = readRDS('data/lct_paleo_reveals_interp.RDS')
# Rename the first column, `ages`, to `year`. Positional, so it relies on `ages` being
# first, which script 1 guarantees.
colnames(lct_interp_paleo)[1] = 'year'

############################################################################################
# Predict and simulate, one month at a time
############################################################################################

for (month in months){
  
  print(month)
  
  # This month's selected model. Because its formula says get(month), the loop variable
  # being called `month` is what makes predict() and simulate() below find the right
  # response name (not that they need the response for prediction, but the formula is
  # still evaluated).
  cal_interp_model = readRDS(paste0('output/calibration/calibration_mod_interp_selected_', month, '_', alb_prod, '.RDS'))
  
  # ---- The hindcast ----------------------------------------------------------------
  # predict.gam with newdata = the paleo table evaluates the fitted smooths at every
  # cell-slice's (x, y), elev and (OL, ET, ST) and returns the mean albedo on the
  # response scale. The location smooth is evaluated at the same coordinates as today;
  # only the land cover (and hence the cover smooth's contribution) changes through time.
  print(">>Predict")
  paleo_interp_predict_gam_vec = predict.gam(cal_interp_model, 
                                             newdata = lct_interp_paleo , 
                                             type    = 'response')
  # Attach as a column and save: 69,936 x 8.
  paleo_interp_predict_gam = data.frame(lct_interp_paleo,
                                        alb_mean = paleo_interp_predict_gam_vec)
  
  saveRDS(paleo_interp_predict_gam, paste0('output/prediction/paleo_interp_predict_gam_', month, '_', alb_prod, '.RDS'))
  
  # ---- 100 draws per cell-slice ---------------------------------------------------------
  # See the header for what these draws represent. Result: a 69,936 x 100 matrix with
  # columns named X1 ... X100 once it is put into a data.frame.
  print(">>Simulate")
  paleo_interp_sim_gam = simulate(cal_interp_model,
                                  nsim = 100,
                                  data = lct_interp_paleo)
  
  # Predictors alongside the 100 draw columns: 69,936 x 107.
  paleo_interp_sim_gam_df = data.frame(lct_interp_paleo,  
                                       paleo_interp_sim_gam)  
  
  # Long form: one row per cell-slice per draw, 6,993,600 rows. `variable` holds the
  # draw column name (X1 ...), `value` the simulated albedo.
  paleo_interp_sim_gam_melt = melt(paleo_interp_sim_gam_df, id.vars = c('year', 'x', 'y', 'elev', 'ET', 'OL', 'ST'))
  colnames(paleo_interp_sim_gam_melt) = c('year', 'x', 'y', 'elev', 'ET', 'OL', 'ST', 'iter', 'value')#c('cell_idx', 'iter', 'value')
  
  # Turn "X1" ... "X100" into the numbers 1 ... 100 by dropping the leading X.
  paleo_interp_sim_gam_melt$iter = as.numeric(substr(paleo_interp_sim_gam_melt$iter, 2, 4))
  
  # Save the full set of draws (~200 MB per month).
  saveRDS(paleo_interp_sim_gam_melt, paste0('output/prediction/paleo_interp_predict_gam_samps_', month, '_', alb_prod, '.RDS'))
  
  # ---- Summarise the draws per cell-slice ---------------------------------------------
  # Grouping on the predictors as well as year/x/y is harmless (they are constant within
  # a cell-slice) and keeps them in the output. .groups = 'keep' leaves the result
  # grouped, so each per-month summary file is a grouped tibble. The stacking loop
  # below wraps every month in data.frame(), so the file scripts 7 and 7a read is a
  # plain data.frame.
  print(">>Summarize")
  paleo_interp_sim_gam_sum = paleo_interp_sim_gam_melt %>% 
    group_by(year, x, y, elev, ET, OL, ST) %>%
    summarize(alb_mean = mean(value), 
              alb_sd = sd(value),
              alb_lo = quantile(value, c(0.025)), 
              alb_mid = quantile(value, c(0.5)), 
              alb_hi = quantile(value, c(0.975)), 
              .groups = 'keep')
  
  saveRDS(paleo_interp_sim_gam_sum, paste0('output/prediction/paleo_interp_predict_gam_summary_', month, '_', alb_prod, '.RDS'))
  
}

############################################################################################
# Stack the twelve months into two files
############################################################################################

# Empty tables with the final column layout, grown month by month with rbind().
alb_preds_summary_months = data.frame(matrix(NA, nrow=0, ncol=13))
colnames(alb_preds_summary_months) = c("year", "x", "y", "elev",  "ET", "OL", "ST", 
               "alb_mean", "alb_sd",  "alb_lo", "alb_mid",  "alb_hi", "month")

alb_preds_months = data.frame(matrix(NA, nrow=0, ncol=9))
colnames(alb_preds_months) = c("year", "x", "y", "elev",  "ET", "OL", "ST", 
                                       "alb_mean", "month")

for (month in months) {
  
  print(month)
  
  # Read this month's mean-prediction file, add a `month` column, append.
  alb_preds_month = readRDS(paste0('output/prediction/paleo_interp_predict_gam_', month, '_', alb_prod, '.RDS'))
  alb_preds_months = rbind(alb_preds_months, 
                           data.frame(alb_preds_month, month = rep(month)))
  
  # Same for the summary file.
  alb_preds_summary_month = readRDS(paste0('output/prediction/paleo_interp_predict_gam_summary_', month, '_', alb_prod, '.RDS'))
  alb_preds_summary_months = rbind(alb_preds_summary_months, 
                                   data.frame(alb_preds_summary_month, month = rep(month)))
}

# The two files scripts 7 and 7a read: 839,232 rows each (69,936 x 12).
saveRDS(alb_preds_months, paste0('output/prediction/paleo_interp_predict_gam_', alb_prod, '.RDS'))
saveRDS(alb_preds_summary_months, paste0('output/prediction/paleo_interp_predict_gam_summary_', alb_prod, '.RDS'))
