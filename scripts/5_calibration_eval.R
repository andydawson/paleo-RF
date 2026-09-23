############################################################################################
# 5_calibration_eval.R  --  how well do the calibration models fit the modern albedo?
#
# WHERE THIS SITS IN THE PIPELINE
#   Step 5 of 9. Script 4 fitted eight candidate models per month. This script (a) declares
#   model 8 the selected model and re-saves it under a "selected" name for script 6 to
#   pick up, and (b) checks how well it reproduces the albedo it was fitted to: scatter
#   plots of modelled against observed albedo with uncertainty bars, and a small table of
#   fit statistics. A later section does the same comparison for the seven
#   "spatial experiment" models from script 4.
#
# WHAT COMES IN
#   data/calibration_modern_lct_interp_bluesky.RDS          2,860 x 18, from script 2
#   output/calibration/calibration_mod8_interp_<m>_bluesky.RDS   the 12 model-8 fits
#   output/calibration/spatial_experiment/...               see "known stop" below
#
# WHAT GOES OUT
#   output/calibration/calibration_mod_interp_selected_<m>_bluesky.RDS   12 files
#     Byte-for-byte copies of the model-8 fits. Script 6 reads these, so "which model is
#     selected" is decided by the two lines that write them, not by any statistic.
#   output/calibration/calibration_model_stats.csv          12 rows x 5 (anchored)
#     Per month: correlation of modelled and observed albedo, fraction of observations
#     inside the model's 95% interval, and the 2.5% and 97.5% quantiles of model-minus-data.
#   figures/cal_model_vs_data_gam_error_months.pdf          one page per month
#   figures/cal_model_vs_data_gam_error_facet.{pdf,png}     all months on one page
#   figures/cal_model_data_diff_histogram_facet.{pdf,png}   error histograms
#
# TWO WAYS OF ASKING A FITTED MODEL FOR A NUMBER
#   predict(model, newdata, type = "response")
#     The model's best estimate of the MEAN albedo for each row: one number per cell.
#     type = "response" asks for it on the albedo scale (0 to 1) rather than the logit
#     scale the model works on internally.
#   simulate(model, nsim = 100, data)
#     Draws 100 plausible albedo VALUES per cell from the fitted beta distribution, i.e.
#     mean plus the scatter the model expects around it. Summarising those draws gives a
#     95% interval per cell, which is what the vertical bars in the plots show and what
#     "fraction of data inside the interval" is measured against. The draws are random and
#     no seed is set, so the statistics differ slightly from one run to the next (the
#     anchored table was produced this way too; expect agreement to about two decimals).
#
# THE get(month) TRAP, IN PRACTICE
#   The saved models have the literal formula get(month) ~ ... . predict() and simulate()
#   re-evaluate that formula, so they work here only because this script's loop variable
#   is also called `month` and holds the right month name at the time of the call.
#
# KNOWN STOP
#   The spatial-experiment section reads its models from output/calibration/
#   spatial_experiment/, a directory script 4 never writes to (it writes them one level
#   up). The script therefore halts at that readRDS. Everything above it, including the
#   selected models and the stats table, is already written by then. The last section of
#   the file (a closer look at November) is never reached for the same reason. Both are
#   kept here exactly as in the original; the one-word fix is known issue 13.
#
# RUN TIME  About 4 minutes to the point where it stops.
############################################################################################

# ggplot2 for the plots; mgcv for the saved models; gratia because it is what makes
# simulate() work on a GAM: nothing below calls gratia by name, but loading it registers
# the simulate method for gam objects, and without it R falls back to simulate.lm and
# stops. reshape2 for melt(); dplyr for group_by/summarize. (brms was loaded by the
# original for a block that is not on this path.)
library(ggplot2)
library(mgcv)
library(gratia)
library(reshape2)
library(dplyr)

# Albedo product tag, as in every script.
alb_prod = "bluesky"

# Output directories.
dir.create('output/calibration', recursive = TRUE, showWarnings = FALSE)
dir.create('figures', showWarnings = FALSE)

# Month names, in order.
months = c('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec')

# The calibration table: predictors and observed monthly albedo.
cal_interp_data =readRDS(paste0('data/calibration_modern_lct_interp_', alb_prod, '.RDS'))

############################################################################################
# SECTION 1: per-month model-versus-data pages, and the selected-model files
############################################################################################

# pdf() opens a multi-page PDF "device"; every plot printed until dev.off() becomes a page.
pdf(paste0('figures/cal_model_vs_data_gam_error_months.pdf'), width=10, height=10)
for (n in 1:length(months)){
  
  # This month's name. Also what get(month) inside the saved model formula will look up.
  month = months[n]
  
  print(month)
  
  # Load this month's model-8 fit. summary() prints the term-by-term table to the console.
  mod8_interp = readRDS(paste0('output/calibration/calibration_mod8_interp_', month, '_', alb_prod, '.RDS'))
  summary(mod8_interp)
  
  # ---- The selection ------------------------------------------------------------------
  # This is where "model 8 is the selected model" happens: the object is renamed and saved
  # under the name script 6 reads. No statistic is consulted; the choice was made from the
  # AIC table (script 4) by hand.
  cal_interp_model = mod8_interp
  
  saveRDS(cal_interp_model, paste0('output/calibration/calibration_mod_interp_selected_', month, '_', alb_prod, '.RDS'))
  
  # Fitted mean albedo for every cell, on the albedo scale.
  cal_interp_predict_gam = predict(cal_interp_model, 
                                   newdata = cal_interp_data,
                                   type = 'response')#,
  
  # Side by side: the predictors, the observed albedo for this month, and the fitted mean.
  cal_interp_eval_gam = data.frame(cal_interp_data[, c('x', 'y', 'elev', 'ET', 'OL', 'ST', month)], 
                                   alb_mean = cal_interp_predict_gam)  
  
  # Pearson correlation between observed and fitted, ignoring cells with NA albedo.
  cor_month = cor(cal_interp_eval_gam[,month], cal_interp_eval_gam$alb_mean, use='complete')
  
  cor_month
  
  # ---- 100 simulated albedo values per cell ------------------------------------------
  # See the header. Returns a 2,860 x 100 matrix (rows with NA albedo come back NA).
  cal_interp_sim_gam = simulate(cal_interp_model,
                                nsim = 100,
                                data = cal_interp_data[,c('x', 'y', 'elev', 'ET', 'OL', 'ST', month)])
  
  # Prefix the coordinates and the observed albedo, then melt to long form: one row per
  # cell per simulation (286,000 rows), columns x, y, <month>, variable (sim id), value.
  cal_interp_sim_gam = data.frame(cal_interp_data[,c('x', 'y', month)], 
                                  cal_interp_sim_gam)
  cal_interp_sim_gam_melt = melt(cal_interp_sim_gam, 
                                 id.vars = c('x', 'y', month))
  # Rename so the observed-albedo column is called `month` whatever month it is.
  # (Confusingly, that column now holds albedo values, not month names.)
  colnames(cal_interp_sim_gam_melt) = c('x', 'y', 'month', 'variable', 'value')
  
  # Per cell: mean, median and 2.5%/97.5% quantiles of the 100 simulated values.
  # Grouping on `month` here groups on the observed albedo value, which is unique per
  # cell in practice, so the result is still one row per cell.
  cal_interp_sim_gam_sum = cal_interp_sim_gam_melt %>% 
    group_by(x, y, month) %>%
    summarize(alb_mean = mean(value), 
              alb_lo = quantile(value, c(0.025), na.rm=TRUE), 
              alb_mid = quantile(value, c(0.5), na.rm=TRUE), 
              alb_hi = quantile(value, c(0.975), na.rm=TRUE),
              .groups = "keep")
  
  # Observed (x) against simulated mean (y) with the 95% interval as a vertical bar and a
  # 1:1 line; a perfect model puts every point on the red line with bars crossing it.
  # xlim/ylim fix both axes to 0..1 and coord_fixed() makes the aspect ratio 1:1.
  p = ggplot(data=cal_interp_sim_gam_sum) + 
    geom_point(aes(x=month, y=alb_mean), size=2, alpha=0.4) +
    geom_linerange(aes(x=month, ymin=alb_lo, ymax=alb_hi), alpha=0.5) +
    geom_abline(slope=1, intercept=0, colour="red", lwd=1, lty=2, alpha=0.4) +
    xlim(c(0,1)) + 
    ylim(c(0,1)) +
    coord_fixed() +  
    theme_bw(24) +
    theme(axis.title = element_text(size=14),
          axis.text = element_text(size=14)) +
    xlab('albedo (data)') +
    ylab('albedo (model)') +
    labs(title = paste0(month, '; cor ', round(cor_month, 2)))
  
  # print() sends the plot to the open PDF as a new page.
  print(p)
  
}
# Close the PDF device; the file is only complete once this runs.
dev.off()

############################################################################################
# SECTION 2: the same comparison for all months at once, plus the stats table
############################################################################################

# An empty table with the right column names, to be grown month by month with rbind().
cal_interp_sim_gam_all = data.frame(x = numeric(0),
                                    y = numeric(0),
                                    alb_data = numeric(0),
                                    variable = character(0),
                                    alb_model = numeric(0),
                                    month = character(0))

# One correlation per month.
cor_all = rep(NA, 12)

# This loop repeats Section 1's loading, selection, prediction and simulation (including
# re-saving the selected-model files, harmlessly) but keeps every month's simulations in
# one long table instead of plotting as it goes.
for (n in 1:length(months)){
  
  month = months[n]
  
  print(month)
  
  mod8_interp = readRDS(paste0('output/calibration/calibration_mod8_interp_', month, '_', alb_prod, '.RDS'))
  summary(mod8_interp)
  
  cal_interp_model = mod8_interp
  
  saveRDS(cal_interp_model, paste0('output/calibration/calibration_mod_interp_selected_', month, '_', alb_prod, '.RDS'))
  
  cal_interp_predict_gam = predict(cal_interp_model,
                                   newdata = cal_interp_data,
                                   type = 'response')#,
  
  cal_interp_eval_gam = data.frame(cal_interp_data[, c('x', 'y', 'elev', 'ET', 'OL', 'ST', month)],
                                   alb_mean = cal_interp_predict_gam)
  
  cor_month = cor(cal_interp_eval_gam[,month], cal_interp_eval_gam$alb_mean, use='complete')
  cor_month
  # Store this month's correlation for the facet labels below.
  cor_all[n] = cor_month
  
  cal_interp_sim_gam = simulate(cal_interp_model,
                                nsim = 100,
                                data = cal_interp_data[,c('x', 'y', 'elev', 'ET', 'OL', 'ST', month)])
  
  cal_interp_sim_gam = data.frame(cal_interp_data[,c('x', 'y', month)],
                                  cal_interp_sim_gam)
  cal_interp_sim_gam_melt = melt(cal_interp_sim_gam,
                                 id.vars = c('x', 'y', month))
  # Clearer names this time: alb_data is observed, alb_model is one simulated value.
  colnames(cal_interp_sim_gam_melt) = c('x', 'y', 'alb_data', 'variable', 'alb_model')
  
  # Tag every row with the month name, then append to the running table.
  cal_interp_sim_gam_melt$month = rep(month)
  
  cal_interp_sim_gam_all = rbind(cal_interp_sim_gam_all, cal_interp_sim_gam_melt)
  
}

# Make month an ordered factor so facets appear January to December, not alphabetically.
cal_interp_sim_gam_all$month = factor(cal_interp_sim_gam_all$month, levels = months)

# Per cell and month: mean, median and 95% interval of the simulated albedo.
cal_interp_sim_gam_quants = cal_interp_sim_gam_all %>%
  group_by(x, y, alb_data, month) %>%
  summarize(alb_mean = mean(alb_model),
            alb_lo = quantile(alb_model, c(0.025), na.rm=TRUE),
            alb_mid = quantile(alb_model, c(0.5), na.rm=TRUE),
            alb_hi = quantile(alb_model, c(0.975), na.rm=TRUE),
            .groups = "keep")

# Text labels (the correlations) to print in the top-left corner of each facet; -Inf/Inf
# as coordinates mean "the edge of the panel".
annotation_data = data.frame(month=months, label=round(cor_all,2), x=-Inf, y=Inf)

# Twelve-panel version of the Section 1 plot.
p = ggplot(data=cal_interp_sim_gam_quants) +
  geom_point(aes(x=alb_data, y=alb_mean), size=0.8, alpha=0.3) +
  geom_linerange(aes(x=alb_data, ymin=alb_lo, ymax=alb_hi), alpha=0.2) +
  geom_abline(slope=1, intercept=0, colour="red", lwd=0.5, lty=2, alpha=0.5) +
  xlim(c(0,1)) +
  ylim(c(0,1)) +
  coord_fixed() +
  theme_light(15) +
  xlab('albedo (data)') +
  ylab('albedo (model)') +
  facet_wrap(~factor(month, levels = months), ncol=4)
# Add the correlation label to each panel. inherit.aes = FALSE stops this layer trying to
# use the main plot's x/y mappings.
p = p + geom_text(
  data = annotation_data,
  aes(x = x, y = y, label = label),
  hjust = -0.2,    # 0 for left justification
  vjust = 1.3,    # 1 for top justification
  inherit.aes = FALSE, # Do not inherit aesthetics from the main plot
  color = "grey30",
  size = 4
)
print(p)
ggsave('figures/cal_model_vs_data_gam_error_facet.pdf', width=12, height=10)
ggsave('figures/cal_model_vs_data_gam_error_facet.png', width=12, height=10)

# Flag whether each observation falls inside its cell's 95% interval; for a well
# calibrated model about 95% should.
cal_interp_sim_gam_quants = cal_interp_sim_gam_quants %>% 
  mutate(in_credible=((alb_data>alb_lo)&(alb_data<alb_hi)))

# Model-minus-data, using the simulated median as "model".
cal_interp_sim_gam_quants$alb_diff = cal_interp_sim_gam_quants$alb_mid - cal_interp_sim_gam_quants$alb_data

# Histogram of that error per month (..density.. scales each panel to integrate to 1).
p = ggplot(data=cal_interp_sim_gam_quants) +
  geom_histogram(aes(x=alb_diff, y=..density..)) +
  theme_light(15) +
  facet_wrap(~factor(month, levels = months), ncol=4)
print(p)
ggsave('figures/cal_model_data_diff_histogram_facet.pdf', width=12, height=10)
ggsave('figures/cal_model_data_diff_histogram_facet.png', width=12, height=10)

# Fraction of observations inside the interval, per month, printed to the console.
cal_interp_sim_gam_quants %>% 
  group_by(month) %>%
  summarize(frac_in=sum(in_credible, na.rm=TRUE)/n())

# The stats table: correlation, fraction inside the interval, and the 2.5% and 97.5%
# quantiles of the error, per month, rounded to two decimals. (Note the stray double
# comma in cor(); R tolerates it as an empty argument.)
cal_diff = cal_interp_sim_gam_quants %>% 
  group_by(month) %>%
  summarize(alb_corr = round(cor(alb_mid, alb_data,, use = "pairwise.complete.obs"),2),
            frac_in=round(sum(in_credible, na.rm=TRUE)/n(),2),   
            diff_lo = round(quantile(alb_diff, c(0.025), na.rm=TRUE),2),
            diff_hi = round(quantile(alb_diff, c(0.975), na.rm=TRUE),2),
            .groups = "keep")

cal_diff 

# Human-readable column names, then write. This is the anchored output.
colnames(cal_diff) = c('month', 'correlation', 'data in credible interval', 'diff lower (model - data; 2.5%)', 'diff upper (model - data; 97.5%)')

write.csv(cal_diff, 'output/calibration/calibration_model_stats.csv', row.names = FALSE)

############################################################################################
# SECTION 3: the spatial experiment, evaluated the same way   (halts: see header)
############################################################################################

# An empty table that nothing below uses; `cal_sims` is used instead. Leftover.
cal_sim_SPE = data.frame(x = numeric(0),
                         y = numeric(0),
                         alb_data = numeric(0),
                         variable = character(0),
                         alb_pred = numeric(0),
                         month = character(0),
                         model = character(0))

# Short codes for the seven models: SP = spatial (location), ELEV = elevation,
# LC = land cover. SP_ELEV_LC is the full model (model 8 again).
models = c('SP_ELEV_LC', 'ELEV_LC', 'LC', 'SP_LC', 'SP', 'SP_ELEV', 'ELEV')

# The long table of simulations for all models and months, grown by rbind() below.
cal_sims = data.frame(matrix(nrow=0, ncol=7))
colnames(cal_sims) = c('x', 'y', 'alb_data', 'variable', 'alb_pred', 'month', 'model')

for (n in 1:length(months)){
  
  month = months[n]
  
  print(month)
  
  # ---- Where the script stops --------------------------------------------------------
  # These paths include a spatial_experiment/ sub-directory that script 4 does not create
  # (it writes the same files directly under output/calibration/). The first readRDS
  # fails with "cannot open the connection" and the script halts here. Known issue 13.
  model_SP_ELEV_LC = readRDS(paste0('output/calibration/spatial_experiment/calibration_mod_interp_selected_', month, '_', alb_prod, '.RDS'))
  
  model_ELEV_LC = readRDS(paste0('output/calibration/spatial_experiment/calibration_mod_cover_elev_', month, '.RDS'))
  model_LC = readRDS(paste0('output/calibration/spatial_experiment/calibration_mod_cover_', month, '.RDS'))
  model_SP_LC = readRDS(paste0('output/calibration/spatial_experiment/calibration_mod_spatial_cover_', month, '.RDS'))
  model_SP = readRDS(paste0('output/calibration/spatial_experiment/calibration_mod_spatial_', month, '.RDS'))
  model_SP_ELEV = readRDS(paste0('output/calibration/spatial_experiment/calibration_mod_spatial_elev_', month, '.RDS'))
  model_ELEV = readRDS(paste0('output/calibration/spatial_experiment/calibration_mod_elev_', month, '.RDS'))
  
  # For each of the seven: simulate 100 albedo values per cell, melt to long form, tag
  # with month and model, append. eval(as.name(...)) turns the string "model_SP" into
  # the object of that name.
  for (model in models){
    
    model_name = eval(as.name(paste0('model_', model)))
    
    sim = simulate(model_name,
                              nsim = 100,
                              data = cal_interp_data[,c('x', 'y', 'elev', 'ET', 'OL', 'ST', month)])
    sim_df = data.frame(cal_interp_data[,c('x', 'y', month)],
                                   sim)
    sim_melt = melt(sim_df,
                               id.vars = c('x', 'y', month))
    colnames(sim_melt) = c('x', 'y', 'alb_data', 'variable', 'alb_pred')
    sim_melt$month = rep(month)
    sim_melt$model = rep(model)
    
    cal_sims = rbind(cal_sims,
                           sim_melt)
    
  }
  
}

# Order the months, summarise per cell/month/model, and plot three ways: by month, by
# model, and month x model. Then a histogram of prediction error by model. None of these
# is saved to a file; they only print.
cal_sims$month = factor(cal_sims$month, levels = months)

cal_sims_quants = cal_sims %>%
  group_by(x, y, alb_data, month, model) %>%
  summarize(alb_mean = mean(alb_pred),
            alb_lo = quantile(alb_pred, c(0.025), na.rm=TRUE),
            alb_mid = quantile(alb_pred, c(0.5), na.rm=TRUE),
            alb_hi = quantile(alb_pred, c(0.975), na.rm=TRUE),
            .groups = "keep")

p = ggplot(data=cal_sims_quants) +
  geom_point(aes(x=alb_data, y=alb_mean), size=2, alpha=0.3) +
  geom_linerange(aes(x=alb_data, ymin=alb_lo, ymax=alb_hi), alpha=0.3) +
  geom_abline(slope=1, intercept=0, colour="red", lwd=1, lty=2, alpha=0.4) +
  xlim(c(0,1)) +
  ylim(c(0,1)) +
  coord_fixed() +
  theme_bw(18) +
  xlab('albedo (data)') +
  ylab('albedo (model)') +
  facet_wrap(~month)
print(p)

p = ggplot(data=cal_sims_quants) +
  geom_point(aes(x=alb_data, y=alb_mean), size=2, alpha=0.3) +
  geom_linerange(aes(x=alb_data, ymin=alb_lo, ymax=alb_hi), alpha=0.3) +
  geom_abline(slope=1, intercept=0, colour="red", lwd=1, lty=2, alpha=0.4) +
  xlim(c(0,1)) +
  ylim(c(0,1)) +
  coord_fixed() +
  theme_bw(18) +
  xlab('albedo (data)') +
  ylab('albedo (model)') +
  facet_wrap(~model)
print(p)

p = ggplot(data=cal_sims_quants) +
  geom_point(aes(x=alb_data, y=alb_mean), size=2, alpha=0.3) +
  geom_linerange(aes(x=alb_data, ymin=alb_lo, ymax=alb_hi), alpha=0.3) +
  geom_abline(slope=1, intercept=0, colour="red", lwd=1, lty=2, alpha=0.4) +
  xlim(c(0,1)) +
  ylim(c(0,1)) +
  coord_fixed() +
  theme_bw(18) +
  xlab('albedo (data)') +
  ylab('albedo (model)') +
  facet_grid(month~model)
print(p)

cal_sims$alb_error = cal_sims$alb_pred - cal_sims$alb_data

p = ggplot(data=cal_sims) +
  geom_histogram(aes(x=alb_error, y=..density..), size=2, alpha=0.3) +
  theme_bw(18) +
  facet_wrap(~model)
print(p)

############################################################################################
# SECTION 4: a closer look at one month (November)   (never reached: see header)
############################################################################################

# Fix the month by hand, reload all eight ladder models for it, print their AICs and
# analysis of deviance and model 8's summary, re-save model 8 as selected, and draw the
# same two model-versus-data plots as Section 1 for this month only, saved under their
# own names. Exploratory; nothing downstream depends on it.
month = "nov"

mod1_interp = readRDS(paste0('output/calibration/calibration_mod1_interp_', month, '_', alb_prod, '.RDS'))
mod2_interp = readRDS(paste0('output/calibration/calibration_mod2_interp_', month, '_', alb_prod, '.RDS'))
mod3_interp = readRDS(paste0('output/calibration/calibration_mod3_interp_', month, '_', alb_prod, '.RDS'))
mod4_interp = readRDS(paste0('output/calibration/calibration_mod4_interp_', month, '_', alb_prod, '.RDS'))
mod5_interp = readRDS(paste0('output/calibration/calibration_mod5_interp_', month, '_', alb_prod, '.RDS'))
mod6_interp = readRDS(paste0('output/calibration/calibration_mod6_interp_', month, '_', alb_prod, '.RDS'))
mod7_interp = readRDS(paste0('output/calibration/calibration_mod7_interp_', month, '_', alb_prod, '.RDS'))
mod8_interp = readRDS(paste0('output/calibration/calibration_mod8_interp_', month, '_', alb_prod, '.RDS'))

AIC(mod1_interp, mod2_interp, mod3_interp, mod4_interp, mod5_interp, 
    mod6_interp, mod7_interp, mod8_interp)

anova_gam_interp = anova.gam(mod1_interp, mod2_interp, mod3_interp, mod4_interp, 
                             mod5_interp, mod6_interp, mod7_interp, mod8_interp, 
                             test = "Chisq")
anova_gam_interp

summary(mod8_interp)

cal_interp_model = mod8_interp

saveRDS(cal_interp_model, paste0('output/calibration/calibration_mod_interp_selected_', month, '_', alb_prod, '.RDS'))

cal_interp_predict_gam = predict(cal_interp_model, 
                                 newdata = cal_interp_data,
                                 type = 'response')#,

cal_interp_eval_gam = data.frame(cal_interp_data, 
                                 alb_mean = cal_interp_predict_gam)  

cor(cal_interp_eval_gam[,month], cal_interp_eval_gam$alb_mean, use='complete')

# get(month) inside aes() works the same way as in the model formula: it fetches the
# column named by the current value of `month`.
ggplot(data=cal_interp_eval_gam) + 
  geom_point(aes(x=get(month), y=alb_mean), size=2, alpha=0.5) +
  geom_abline(slope=1, intercept=0, colour="red", lwd=1, lty=2) +
  xlim(c(0,1)) + 
  ylim(c(0,1)) +
  coord_fixed() +  
  theme_bw(18) +
  theme(axis.title = element_text(size=14),
        axis.text = element_text(size=14)) +
  xlab('albedo (data)') +
  ylab('albedo (model)')
ggsave(paste0('figures/cal_model_vs_data_gam_interp_', month, '.png'))
ggsave(paste0('figures/cal_model_vs_data_gam_interp_', month, '.pdf'))

cal_interp_sim_gam = simulate(cal_interp_model,
                              nsim = 100,
                              data = cal_interp_data)

cal_interp_sim_gam = data.frame(cal_interp_data[,c('x', 'y', month)], 
                                cal_interp_sim_gam)
cal_interp_sim_gam_melt = melt(cal_interp_sim_gam, 
                               id.vars = c('x', 'y', month))

# group_by_at() takes the grouping columns as a character vector, which lets `month`
# (a string) name the observed-albedo column.
vars_to_group = c('x', 'y', month)

cal_interp_sim_gam_sum = cal_interp_sim_gam_melt %>% 
  group_by_at(vars_to_group) %>%
  summarize(alb_mean = mean(value), 
            alb_lo = quantile(value, c(0.025)), 
            alb_mid = quantile(value, c(0.5)), 
            alb_hi = quantile(value, c(0.975)),
            .groups = "keep")

ggplot(data=cal_interp_sim_gam_sum) + 
  geom_point(aes(x=get(month), y=alb_mean), size=2, alpha=0.4) +
  geom_linerange(aes(x=get(month), ymin=alb_lo, ymax=alb_hi), alpha=0.5) +
  geom_abline(slope=1, intercept=0, colour="red", lwd=1, lty=2, alpha=0.4) +
  xlim(c(0,1)) + 
  ylim(c(0,1)) +
  coord_fixed() +  
  theme_bw(18) +
  theme(axis.title = element_text(size=14),
        axis.text = element_text(size=14)) +
  xlab('albedo (data)') +
  ylab('albedo (model)')
ggsave(paste0('figures/cal_model_vs_data_gam_error_interp_', month, '.png'))
ggsave(paste0('figures/cal_model_vs_data_gam_error_interp_', month, '.pdf'))
