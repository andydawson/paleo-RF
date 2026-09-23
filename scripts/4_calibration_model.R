############################################################################################
# 4_calibration_model.R  --  fit the models that turn land cover into albedo
#
# WHERE THIS SITS IN THE PIPELINE
#   Step 4 of 9 (3 is optional plots). This is the statistical heart of the method. It
#   learns, from the modern world, how albedo depends on land cover, so that script 6 can
#   apply the relationship to the Holocene land cover and hindcast albedo. One model is
#   fitted per calendar month, because the albedo/land-cover relationship changes with
#   snow and sun angle.
#
# WHAT COMES IN
#   data/calibration_modern_lct_interp_bluesky.RDS   2,860 rows x 18
#     x, y (lon/lat degrees), elev (m), ET, OL, ST (fractions summing to 1), and twelve
#     albedo columns jan ... dec (0 to 1, NA where the satellite saw nothing). Built by
#     script 2. Because the winter high latitudes are NA, the number of cells actually
#     used varies by month: 2,826-2,827 from March to October, 2,765 in February, 2,460
#     in November, 2,166 in January, 1,751 in December.
#
# WHAT GOES OUT   (all under output/calibration/; <m> = jan ... dec)
#   calibration_mod{1..8}_interp_<m>_bluesky.RDS    96 fitted models, the "ladder"
#   AIC_table.csv                                   8 models x 12 months, for choosing
#   calibration_mod_{spatial,elev,cover,spatial_elev,spatial_cover,cover_elev}_<m>.RDS
#   calibration_mod_spatial_elev_cover<m>.RDS       84 more fits, the "spatial experiment"
#     (note the missing underscore before <m> in that last name; the original has it too)
#   Each saved model is 15 to 35 MB; the whole set is 3.6 GB, which is why output/ is
#   not in git. What IS anchored is AIC_table.csv.
#
# THE MODEL, IN PLAIN TERMS
#   A GAM (generalised additive model) says: transformed albedo = a smooth function of
#   location + a smooth function of elevation + a smooth function of the three cover
#   fractions. "Smooth function" means a flexible curve or surface learnt from the data
#   rather than a straight line; mgcv builds each from a set of basis functions and
#   penalises wiggliness so it does not overfit. Three details carry most of the meaning:
#     family = betar(link = "logit")
#       Albedo is a proportion, strictly between 0 and 1. The beta distribution is the
#       natural choice for such data (it cannot produce values outside (0,1)); the logit
#       link maps (0,1) onto the whole real line so the smooths can add freely. This is
#       also why script 2 replaced exact zeros with 0.0001.
#     s(x, y, bs = "gp", k = 500)
#       A Gaussian-process smooth over longitude and latitude, allowed up to 500 basis
#       functions. It absorbs everything about albedo that varies smoothly in space and
#       is NOT explained by the other terms: climate, snow regime, soil colour, unmodelled
#       vegetation detail. Its coordinates are degrees (see script 1), so "distance" in
#       this smooth is not metres, and a degree of longitude is shorter in the north.
#     s(OL, ET, ST, bs = "tp", k = 200)
#       A thin-plate-spline surface over the three cover fractions jointly. This is the
#       term the whole paper relies on: it is what gets applied to past land cover. The
#       three fractions always sum to 1, so the three inputs lie on a plane; the smooth
#       is effectively two-dimensional. mgcv fits it but reports the model as rank
#       deficient (e.g. rank 744 of 748 for December), and any prediction row whose
#       fractions do not sum to exactly one is evaluated in the empty direction
#       (question B1). It is also why a model with three SEPARATE cover smooths
#       (model 5) is asking a partly redundant question.
#   method = "REML" chooses how wiggly each smooth is allowed to be by restricted maximum
#   likelihood, the standard robust choice. bam() is mgcv's version of gam() for larger
#   data: same models, less memory, optional threading.
#
# THE LADDER
#   Models 1 to 8 add terms one at a time (location; + elevation; + OL; + ET; + ST; then
#   a joint cover surface, three ways). Fitting them all and comparing by AIC is how the
#   final form was chosen. In the interp run, model 8 has the lowest AIC in eleven months
#   out of twelve; May prefers model 7 by 3 AIC units. Script 5 hard-codes model 8 as the
#   selected model. Two caveats belong here: AIC values of REML fits with different mean
#   structures are not strictly comparable (mgcv's documentation says to use method="ML"
#   for that), and the ladder is fitted on the centre-pixel albedo (script 2's header).
#   These are open questions with Andria (B1, B4, B5).
#
# RUN TIME
#   About 27 hours on 8 cores for the interp run. Four fifths of that is model 7: the
#   Gaussian-process cover smooth (bs="gp" on three inputs, k=200) is far more expensive
#   than the thin-plate version. Every other model takes one to five minutes per month.
#
# TWO THINGS TO KNOW BEFORE READING ON
#   1. The response is written `get(month)`, not a column name. get() looks up the
#      variable whose NAME is the current value of `month` ('jan', 'feb', ...), so one
#      formula serves all twelve months. The saved model keeps that literal formula, which
#      means any later code that calls predict() on it must have a variable called `month`
#      in scope with the right value (script 6 does).
#   2. Model 8 is fitted THREE times in this script: in the ladder, again as
#      "mod_spatial_elev_cover" in the spatial experiment, and once more in a final loop
#      that overwrites the ladder's file with an identical fit. The last of these costs
#      twelve more model-8 fits, roughly half an hour to an hour. (The "3 h of waste" in
#      the run manifest refers to a non-interp refit that this copy no longer contains.)
#      All are kept here so that this
#      copy runs exactly as the original did; removing the duplicates is Stage 4 of the
#      staged plan.
############################################################################################

# mgcv provides bam(), the smooth terms and betar(). The `gam` package is ALSO loaded, as
# in the original; it is not used, and it defines functions with the same names as mgcv's
# (gam, s, ...). Because mgcv is attached second its versions win, so this is harmless in
# this order. Do not swap the two lines. (ggplot2, dplyr and tidyr were loaded by the
# original for the point-based version and are dropped here.)
library(gam)
library(mgcv)

# Tag naming which albedo product was used; it appears in every output file name.
alb_prod = "bluesky"

# Make sure the output directories exist.
dir.create('output/calibration', recursive = TRUE, showWarnings = FALSE)
dir.create('figures', showWarnings = FALSE)

# Options passed to every bam() call: use up to 8 threads for the parts of the fit that
# can be parallelised, and allow up to 500 iterations of the fitting algorithm (the
# default 200 can be too few for beta regression). NB these 8 threads are separate from
# the BLAS threads; both must be capped to the cores you give the job (see README).
ctrl <- list(nthreads=8, maxit=500)

############################################################################################
# Load the calibration table
############################################################################################

# The 2,860 x 18 table from script 2: predictors and twelve monthly albedo columns.
cal_interp_data =readRDS(paste0('data/calibration_modern_lct_interp_', alb_prod, '.RDS'))

# Two derived tables that nothing below uses: the table with a running site number, and
# just the site number with the cover fractions. Leftovers from an earlier version.
cal_data2 = data.frame(site=seq(1,nrow(cal_interp_data)), cal_interp_data)
cal_data3 = cal_data2[,c('site', 'ET', 'OL', 'ST')]

############################################################################################
# SECTION 1: the ladder, models 1 to 8, for every month
############################################################################################

# Month names; the loop variable `month` takes each in turn and get(month) picks the column.
months = c('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec')

# Same options as above, re-declared (the original re-declares them before each loop).
ctrl <- list(nthreads=8, maxit=500)

# For each month: fit the eight models in turn and save each to its own file immediately,
# so a crash part-way through loses at most one fit.
for (month in months) {
  
  # ---- Model 1: location only ------------------------------------------------------------
  # The baseline. If location alone explains albedo well, land cover is not adding much.
  # Arguments, once, since every call below repeats them:
  #   get(month) ~ ...      response is this month's albedo column (see header, point 1)
  #   s(x, y, bs="gp", k=500)   Gaussian-process smooth of lon/lat, up to 500 basis fns
  #   data                  the calibration table
  #   family=betar(link="logit")   beta regression on the logit scale
  #   method="REML"         how the smoothness penalties are chosen
  #   na.action=na.omit     drop cells whose albedo is NA this month (the polar night)
  #   control=ctrl          threads and iteration limit
  print('Fitting model 1: (x,y)')
  mod1_interp = mgcv::bam(get(month) ~ s(x, y, bs="gp", k=500),
                          data=cal_interp_data, 
                          family=betar(link="logit"), 
                          method="REML", 
                          na.action=na.omit, 
                          control=ctrl)
  
  # Save the fitted object (it contains the coefficients, the smoothing parameters, the
  # basis setup and a copy of the data used, hence the file size).
  saveRDS(mod1_interp, paste0('output/calibration/calibration_mod1_interp_', month, '_', alb_prod, '.RDS'))
  
  # ---- Model 2: + elevation --------------------------------------------------------------
  # s(elev, k=50): a one-dimensional smooth curve in elevation (default basis, thin plate).
  print('Fitting model 2: (x,y) + elevation')
  mod2_interp = mgcv::bam(get(month) ~ s(x, y, bs="gp", k=500) + s(elev, k=50),
                          data=cal_interp_data, 
                          family=betar(link="logit"), 
                          method="REML", 
                          na.action=na.omit, 
                          control=ctrl)
  
  saveRDS(mod2_interp, paste0('output/calibration/calibration_mod2_interp_', month, '_', alb_prod, '.RDS'))
  
  # ---- Model 3: + open land ---------------------------------------------------------------
  # First land-cover term: a smooth curve in the open-land fraction alone.
  print('Fitting model 3: (x,y) + elevation + OL')
  mod3_interp = mgcv::bam(get(month) ~ s(x, y, bs='gp', k=500) + s(elev, k=50) + s(OL, k=50),
                          data=cal_interp_data, 
                          family=betar(link="logit"), 
                          method="REML", 
                          na.action=na.omit, 
                          control=ctrl)
  
  saveRDS(mod3_interp, paste0('output/calibration/calibration_mod3_interp_', month, '_', alb_prod, '.RDS'))
  
  # ---- Model 4: + evergreen trees ---------------------------------------------------------
  print('Fitting model 4: (x,y) + elevation + OL + ET')
  mod4_interp = mgcv::bam(get(month) ~ s(x, y, bs='gp', k=500) + s(elev, k=50) + s(OL, k=50) + s(ET, k=50),
                          data=cal_interp_data, 
                          family=betar(link="logit"), 
                          method="REML", 
                          na.action=na.omit, 
                          control=ctrl)
  
  saveRDS(mod4_interp, paste0('output/calibration/calibration_mod4_interp_', month, '_', alb_prod, '.RDS'))
  
  # ---- Model 5: + summergreen trees, three separate curves -------------------------------
  # All three fractions, each as its own curve. Since ST = 1 - OL - ET, the third curve
  # carries no new information about WHERE a cell sits in cover space, only a different
  # shape of response; the additive structure cannot represent interactions between the
  # classes. Models 6 to 8 fix that by smoothing the three jointly.
  print('Fitting model 5: (x,y) + elevation + OL + ET + ST')
  mod5_interp = mgcv::bam(get(month) ~ s(x, y, bs='gp', k=500) + s(elev, k=50) + s(OL, k=50) + s(ET, k=50) + s(ST, k=50),
                          data=cal_interp_data, 
                          family=betar(link="logit"), 
                          method="REML", 
                          na.action=na.omit, 
                          control=ctrl)
  
  saveRDS(mod5_interp, paste0('output/calibration/calibration_mod5_interp_', month, '_', alb_prod, '.RDS'))
  
  # ---- Model 6: joint cover surface, default basis, k=75 ---------------------------------
  # s(OL, ET, ST, k=75): one smooth surface over all three fractions at once, so the
  # effect of, say, open land can depend on how much of the rest is evergreen. Default
  # basis is thin plate; 75 basis functions.
  print('Fitting model 6: (x,y) + elevation + s(OL, ET, ST)')
  mod6_interp = mgcv::bam(get(month) ~ s(x, y, bs='gp', k=500) + s(elev, k=50) + s(OL, ET, ST, k=75),
                          data=cal_interp_data, 
                          family=betar(link="logit"), 
                          method="REML", 
                          na.action=na.omit, 
                          control=ctrl)
  
  saveRDS(mod6_interp, paste0('output/calibration/calibration_mod6_interp_', month, '_', alb_prod, '.RDS'))
  
  # ---- Model 7: joint cover surface, Gaussian-process basis, k=200 -----------------------
  # Same idea with a Gaussian-process basis and more freedom. This is the slow one: about
  # two hours per month, four fifths of the whole script's run time.
  print('Fitting model 7: (x,y) + elevation + gp(OL, ET, ST)')
  mod7_interp = mgcv::bam(get(month) ~ s(x, y, bs='gp', k=500) + s(elev, k=50) + s(OL, ET, ST, bs='gp', k=200),
                          data=cal_interp_data, 
                          family=betar(link="logit"), 
                          method="REML", 
                          na.action=na.omit, 
                          control=ctrl)
  
  saveRDS(mod7_interp, paste0('output/calibration/calibration_mod7_interp_', month, '_', alb_prod, '.RDS'))
  
  # ---- Model 8: joint cover surface, thin-plate basis, k=200 -------------------------------
  # The model the pipeline uses (script 5 selects it; script 6 predicts with it).
  print('Fitting model 8: (x,y) + elevation + tp(OL, ET, ST)')
  mod8_interp = mgcv::bam(get(month) ~ s(x, y, bs='gp', k=500) + s(elev, k=50) + s(OL, ET, ST, bs='tp', k=200),
                          data=cal_interp_data, 
                          family=betar(link="logit"), 
                          method="REML", 
                          na.action=na.omit, 
                          control=ctrl)
  
  saveRDS(mod8_interp, paste0('output/calibration/calibration_mod8_interp_', month, '_', alb_prod, '.RDS'))
  
}

############################################################################################
# SECTION 2: compare the eight models by AIC, month by month
############################################################################################

# Re-declared, as in the original.
months = c('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec')

ctrl <- list(nthreads=8, maxit=500)

# A list with one slot per month, to hold each month's full AIC() result.
AIC_list =  vector("list", 12)
names(AIC_list) = months

# The summary table that gets written out: 8 rows (models) x 13 columns (model number
# plus one column per month), filled in below.
AIC_df = data.frame(matrix(NA, nrow=8, ncol=13))
colnames(AIC_df) = c('model', months)
AIC_df$model = seq(1,8)

# Likewise for the analysis-of-deviance results; filled in, but never saved or printed.
ANOVA_list = vector("list", 12)
names(ANOVA_list) = months

for (month in months) {
  
  # Reload the eight fits for this month from disk.
  mod1_interp = readRDS(paste0('output/calibration/calibration_mod1_interp_', month, '_', alb_prod, '.RDS'))
  mod2_interp = readRDS(paste0('output/calibration/calibration_mod2_interp_', month, '_', alb_prod, '.RDS'))
  mod3_interp = readRDS(paste0('output/calibration/calibration_mod3_interp_', month, '_', alb_prod, '.RDS'))
  mod4_interp = readRDS(paste0('output/calibration/calibration_mod4_interp_', month, '_', alb_prod, '.RDS'))
  mod5_interp = readRDS(paste0('output/calibration/calibration_mod5_interp_', month, '_', alb_prod, '.RDS'))
  mod6_interp = readRDS(paste0('output/calibration/calibration_mod6_interp_', month, '_', alb_prod, '.RDS'))
  mod7_interp = readRDS(paste0('output/calibration/calibration_mod7_interp_', month, '_', alb_prod, '.RDS'))
  mod8_interp = readRDS(paste0('output/calibration/calibration_mod8_interp_', month, '_', alb_prod, '.RDS'))
  
  # ---- AIC ----------------------------------------------------------------------------
  # Akaike's information criterion: goodness of fit penalised by the number of effective
  # parameters. Lower is better; differences of a few units are marginal, tens are
  # decisive. AIC() on several models returns a small table with a df and an AIC column.
  # (Caveat from the header: these are REML fits, so comparisons across different sets of
  # terms are approximate.)
  this_AIC = AIC(mod1_interp, mod2_interp, mod3_interp, mod4_interp, mod5_interp, mod6_interp, mod7_interp, mod8_interp)
  
  AIC_list[[month]] = this_AIC
  
  # Rounded AICs into this month's column of the summary table.
  AIC_df[,month] = round(this_AIC$AIC)
  
  # Analysis of deviance between successive models (a likelihood-ratio style test of
  # whether each added term is worth having). Computed and stored, then unused.
  ANOVA_list[[month]] = anova.gam(mod1_interp, mod2_interp, mod3_interp, mod4_interp, mod5_interp, mod6_interp, mod7_interp, mod8_interp, test = "Chisq")
}

# The 8 x 13 table of AICs. This is the anchored output of this script.
write.csv(AIC_df, 'output/calibration/AIC_table.csv', row.names = FALSE)

############################################################################################
# SECTION 3: the "spatial experiment": which terms are doing the work?
############################################################################################

# Seven more models per month, each leaving out one or two of model 8's three terms, to
# see how much each contributes. Their fits are read by 5_calibration_eval.R and
# 6_prediction_model_spatial_eval.R (note: script 5 looks for them in a sub-directory
# that this script does not write to; known issue 13).

months = c('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec')

ctrl <- list(nthreads=8, maxit=500)

for (month in months) {
  
  print(paste0('Fitting calibration models for ', month, ' albedo'))
  
  # All three terms: identical to model 8 in the ladder (second of its three fits).
  # Saved under a name with no underscore before the month, e.g. ..._elev_covermay.RDS.
  print('Fitting model: (x,y) + elev + tp(OL, ET, ST)')
  mod_spatial_elev_cover = mgcv::bam(get(month) ~ s(x, y, bs="gp", k=500) + s(elev, k=50) + s(OL, ET, ST, bs='tp', k=200),
                          data=cal_interp_data,
                          family=betar(link="logit"),
                          method="REML",
                          na.action=na.omit,
                          control=ctrl)
  
  saveRDS(mod_spatial_elev_cover, paste0('output/calibration/calibration_mod_spatial_elev_cover', month, '.RDS'))
  
  # Location only: identical to model 1.
  print('Fitting model: (x,y)')
  mod_spatial = mgcv::bam(get(month) ~ s(x, y, bs="gp", k=500),
                          data=cal_interp_data,
                          family=betar(link="logit"),
                          method="REML",
                          na.action=na.omit,
                          control=ctrl)
  
  saveRDS(mod_spatial, paste0('output/calibration/calibration_mod_spatial_', month, '.RDS'))
  
  # Elevation only: no location term at all.
  print('Fitting model: elevation')
  mod_elev = mgcv::bam(get(month) ~s(elev, k=50),
                          data=cal_interp_data, 
                          family=betar(link="logit"), 
                          method="REML", 
                          na.action=na.omit, 
                          control=ctrl)
  
  saveRDS(mod_elev, paste0('output/calibration/calibration_mod_elev_', month, '.RDS'))
  
  # Location + elevation: identical to model 2.
  print('Fitting model: (x,y) + elevation')
  mod_spatial_elev = mgcv::bam(get(month) ~ s(x, y, bs="gp", k=500) + s(elev, k=50),
                          data=cal_interp_data,
                          family=betar(link="logit"),
                          method="REML",
                          na.action=na.omit,
                          control=ctrl)
  
  saveRDS(mod_spatial_elev, paste0('output/calibration/calibration_mod_spatial_elev_', month, '.RDS'))
  
  # Location + cover, no elevation.
  print('Fitting model: (x,y) + tp(OL, ET, ST)')
  mod_spatial_cover = mgcv::bam(get(month) ~ s(x, y, bs="gp", k=500) +  s(OL, ET, ST, bs='tp', k=200),
                               data=cal_interp_data,
                               family=betar(link="logit"),
                               method="REML",
                               na.action=na.omit,
                               control=ctrl)
  
  saveRDS(mod_spatial_cover, paste0('output/calibration/calibration_mod_spatial_cover_', month, '.RDS'))
  
  # Cover only: the pure land-cover -> albedo relationship with nothing else to lean on.
  # The most interesting of the seven for the paper's question.
  print('Fitting model: tp(OL, ET, ST)')
  mod_cover = mgcv::bam(get(month) ~ s(OL, ET, ST, bs='tp', k=200),
                          data=cal_interp_data,
                          family=betar(link="logit"),
                          method="REML",
                          na.action=na.omit,
                          control=ctrl)
  
  saveRDS(mod_cover, paste0('output/calibration/calibration_mod_cover_', month, '.RDS'))
  
  # Cover + elevation, no location.
  print('Fitting model: tp(OL, ET, ST) + elev')
  mod_cover_elev = mgcv::bam(get(month) ~ s(elev, k=50) + s(OL, ET, ST, bs='tp', k=200),
                          data=cal_interp_data,
                          family=betar(link="logit"),
                          method="REML",
                          na.action=na.omit,
                          control=ctrl)
  
  saveRDS(mod_cover_elev, paste0('output/calibration/calibration_mod_cover_elev_', month, '.RDS'))
  
}

############################################################################################
# SECTION 4: refit model 8 and overwrite the ladder's copy
############################################################################################

# In the original this loop once fitted all eight models again with the other seven
# since commented out. What is left refits model 8 with exactly the formula used in
# Section 1 and saves it to exactly the same file. It changes nothing and costs about
# an hour. Kept so this copy behaves as the original; removed in Stage 4.

months = c('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec')

ctrl <- list(nthreads=8, maxit=500)

for (month in months) {
  
  print(paste0('Fitting calibration model for: ', month))
  
  print('Fitting model 8: (x,y) + elevation + tp(OL, ET, ST)')
  mod8_interp = mgcv::bam(get(month) ~ s(x, y, bs='gp', k=500) + s(elev, k=50) + s(OL, ET, ST, bs='tp', k=200),
                          data=cal_interp_data, 
                          family=betar(link="logit"), 
                          method="REML", 
                          na.action=na.omit, 
                          control=ctrl)
  
  saveRDS(mod8_interp, paste0('output/calibration/calibration_mod8_interp_', month, '_', alb_prod, '.RDS'))
  
}
