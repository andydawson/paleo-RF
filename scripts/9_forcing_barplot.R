# 9_forcing_barplot.R
#
# Continental Holocene radiative forcing by period, beside the modern IPCC AR6
# forcing agents. This is an attempt to reproduce the bar chart on slide 18 of
# the EGU talk from output/forcing/RF_holocene_all_cases.RDS.
#
# WRITTEN 2026-09-21. No code for this plot existed in the repository: script 8
# computes per-cell forcing, saves the table and stops. Every aggregation choice
# below is therefore an assumption by Chris/Claude, not something recovered from
# Andria's code. They are listed here so they can be checked and corrected.
#
# ASSUMPTIONS
#
# A1. Forcing variant. Uses rf_<kernel>_veg_ice_thresh: the vegetation plus ice
#     albedo change, threshold method. Chosen because it is the only family with
#     no missing values over the whole domain and it includes both the
#     vegetation and the ice contribution. The table holds nine other variants
#     (_veg_thresh, _ice_thresh, _icesc_thresh, and the _part / _parts family
#     that mixes vegetation and ice albedo by area fraction rather than by
#     threshold). A2 below reports all of them, because the choice matters.
#
# A3. Kernel. HadGEM3 is the headline, matching the talk. CAM5 and CACK are
#     carried through as a spread. They are NOT interchangeable: see C3/C4 in
#     docs/cc/questions_for_andria_scientific.md. CACK is all-sky and gives
#     roughly half the HadGEM3 answer.
#
# A4. Periods. The seven periods are script 8's own labels_period, bounded by
#     ages_sub = 50, 500, 2000, 4000, 6000, 8000, 10000, 12000 yr BP.
#     CAVEAT: the oldest age in the data is 11,500 BP, so the bar labelled
#     "10 - 12 ka" actually covers 10 to 11.5 ka.
#
# A5. Combining slices within a period. Each row of the table is the forcing of
#     one consecutive slice-pair. Within a period these are SUMMED, not averaged,
#     because forcing increments are additive: the sum telescopes to the albedo
#     difference between the period's two endpoints. A mean would answer a
#     different question ("typical step") and would not be comparable with a
#     modern 1750-to-2019 forcing.
#
# A6. Months. Averaged with equal weight to an annual mean, after the period sum.
#     Equal weighting ignores that months differ in length and in insolation.
#
# A7. Space. Cells are area-weighted using the `area` column (m^2).
#
# A8. Normalisation, and the one that matters most. Two numbers are produced:
#       - domain mean: W/m^2 averaged over the North American study area. This
#         is what the pipeline naturally produces.
#       - global equivalent: the same flux anomaly spread over the whole Earth,
#         sum(rf * area) / 5.101e14 m^2.
#     IPCC ERF values are global means. Comparing a domain-mean regional forcing
#     with a global-mean ERF overstates the Holocene signal by roughly the ratio
#     of Earth's area to the study area (about 34x). The global-equivalent column
#     is the like-for-like comparison and is what the headline figure plots.
#
# A9. Sign. Positive = warming (albedo fell). Inherited from script 8.
#
# A10. Missing cells. Cells absent from any slice within a period are dropped for
#      that period, so every period is a complete telescoping sum. The number
#      dropped is reported.
#
# IPCC data: AR6 WG1 Chapter 7, data_output/AR6_ERF_1750-2019.csv from
# github.com/IPCC-WG1/Chapter-7, 1750-2019 effective radiative forcing with
# 5-95% bounds. Downloaded 2026-09-21.

library(ggplot2)
library(dplyr)
library(tidyr)
library(patchwork)

source('R/run_manifest.R')

alb_prod   = "bluesky"
EARTH_AREA = 5.101e14          # m^2
KERNELS    = c(hadgem = "rf_hadgem_veg_ice_thresh",
               cam5   = "rf_cam5_veg_ice_thresh",
               cack   = "rf_cack_veg_ice_thresh")
VARIANTS   = c("veg_thresh", "ice_thresh", "veg_ice_thresh",
               "veg_icesc_thresh", "veg_ice_parts", "veg_icesc_parts")

ages_sub      = c(50, 500, 2000, 4000, 6000, 8000, 10000, 12000)
labels_period = c('0.05 - 0.5 ka', '0.5 - 2 ka', '2 - 4 ka', '4 - 6 ka',
                  '6 - 8 ka', '8 - 10 ka', '10 - 12 ka')

dir.create('figures',       showWarnings = FALSE)
dir.create('output/forcing', recursive = TRUE, showWarnings = FALSE)

run_start('9_forcing_barplot',
          note   = Sys.getenv('RUN_NOTE'),
          inputs = Filter(file.exists, c(
            'output/forcing/RF_holocene_all_cases.RDS',
            'data/ipcc-ar6/AR6_ERF_1750-2019.csv',
            'data/ipcc-ar6/AR6_ERF_1750-2019_pc05.csv',
            'data/ipcc-ar6/AR6_ERF_1750-2019_pc95.csv')),
          config = list(variant = 'veg_ice_thresh', kernels = names(KERNELS),
                        periods = labels_period, earth_area_m2 = EARTH_AREA))

d = readRDS('output/forcing/RF_holocene_all_cases.RDS')

# --- A4/A5: assign each slice-pair to a period -------------------------------
# A row's `year` is the YOUNGER end of the pair; the pair spans year -> next age.
ages      = sort(unique(c(d$year, 11500)))
d$age_old = ages[match(d$year, ages) + 1]
d$period  = cut(d$year, breaks = ages_sub, right = FALSE, labels = labels_period)
d         = d[!is.na(d$period), ]

cat('slice-pairs per period:\n'); print(table(unique(d[, c('year','period')])$period))

# --- A10: keep only cells complete within a period ---------------------------
n_pairs = d %>% group_by(period) %>% summarise(np = n_distinct(year), .groups='drop')
keep = d %>%
  group_by(period, cell_id, month) %>%
  summarise(np = n_distinct(year), .groups = 'drop') %>%
  left_join(n_pairs, by = 'period', suffix = c('', '_full')) %>%
  filter(np == np_full) %>%
  select(period, cell_id, month)
cat('cell-month-period combinations dropped as incomplete:',
    nrow(distinct(d[, c('period','cell_id','month')])) - nrow(keep), '\n')
d = inner_join(d, keep, by = c('period','cell_id','month'))

# --- aggregate ---------------------------------------------------------------
# A5 sum over slice-pairs -> A6 mean over months -> A7 area-weighted over cells
aggregate_forcing <- function(col) {
  d %>%
    group_by(period, cell_id, month, area) %>%
    summarise(rf = sum(.data[[col]], na.rm = FALSE), .groups = 'drop') %>%   # A5
    group_by(period, cell_id, area) %>%
    summarise(rf = mean(rf, na.rm = TRUE), .groups = 'drop') %>%             # A6
    group_by(period) %>%
    summarise(domain_mean  = weighted.mean(rf, area, na.rm = TRUE),          # A7
              global_equiv = sum(rf * area, na.rm = TRUE) / EARTH_AREA,      # A8
              area_m2      = sum(area), .groups = 'drop')
}

main = bind_rows(lapply(names(KERNELS), function(k)
  aggregate_forcing(KERNELS[[k]]) %>% mutate(kernel = k)))
main$period = factor(main$period, levels = labels_period)

cat('\nstudy area as a fraction of Earth:',
    signif(unique(main$area_m2)[1] / EARTH_AREA, 3), '\n\n')
print(as.data.frame(main %>% select(kernel, period, domain_mean, global_equiv)), digits = 3)

# --- A2: sensitivity to the forcing variant, HadGEM3 only --------------------
sens = bind_rows(lapply(VARIANTS, function(v) {
  col = paste0('rf_hadgem_', v)
  if (!col %in% names(d)) return(NULL)
  aggregate_forcing(col) %>% mutate(variant = v)
}))
sens$period = factor(sens$period, levels = labels_period)

# --- modern IPCC agents ------------------------------------------------------
read_erf <- function(p) { x = read.csv(p); x[x$year == 2019, ] }
erf    = read_erf('data/ipcc-ar6/AR6_ERF_1750-2019.csv')
erf_lo = read_erf('data/ipcc-ar6/AR6_ERF_1750-2019_pc05.csv')
erf_hi = read_erf('data/ipcc-ar6/AR6_ERF_1750-2019_pc95.csv')

# Agents and labels exactly as on slide 18: CO2, methane, water vapour,
# albedo (land use), aerosols. 'water vapour' on the slide is ~0.05 W/m2, which
# matches AR6 h2o_stratospheric. n2o and the anthropogenic total are not on the
# slide, so they are dropped from the matching figure.
agents = c(co2 = 'carbon dioxide', ch4 = 'methane', h2o_stratospheric = 'water vapour',
           land_use = 'albedo (land use)', aerosol = 'aerosols')
modern = data.frame(
  agent = unname(agents[names(agents)]),
  erf   = as.numeric(erf[names(agents)]),
  lo    = as.numeric(erf_lo[names(agents)]),
  hi    = as.numeric(erf_hi[names(agents)]))
modern$agent = factor(modern$agent, levels = modern$agent)
cat('\nIPCC AR6 ERF 1750-2019 (W/m2, global mean):\n'); print(modern, digits = 3)

# --- figures -----------------------------------------------------------------
# Layout matched to slide 18 of dawson_EGU.pptx (ppt/media/image37.png):
# horizontal bars, two stacked panels sharing one x axis, panel labels in strips
# on the right, bars coloured by sign with no legend, ggplot's default two-colour
# hue palette. The slide shows a single kernel, so the matching figure uses
# HadGEM3; the kernel spread is kept as a separate figure.

POS = '#F8766D'; NEG = '#00BFC4'   # ggplot default hue palette for two levels

hol = main %>%
  filter(kernel == 'hadgem') %>%
  transmute(panel = 'Holocene',
            label = sub(' ka$', '', as.character(period)),
            value = global_equiv)
hol$label = factor(hol$label, levels = rev(sub(' ka$', '', labels_period)))

ipcc = modern %>%
  transmute(panel = 'IPCC', label = as.character(agent), value = erf)
ipcc$label = factor(ipcc$label, levels = rev(as.character(modern$agent)))

both = bind_rows(hol, ipcc)
both$panel = factor(both$panel, levels = c('Holocene', 'IPCC'))
both$sign  = ifelse(both$value >= 0, 'pos', 'neg')

# One panel per block so each can carry its own y-axis title, as on the slide.
# Heights are set to the row counts (7 Holocene periods, 5 IPCC agents) so the
# bars are the same thickness in both, which is what facet_grid(space='free_y')
# would have given.
panel_plot <- function(dat, ytitle, striplab, keep_x) {
  ggplot(dat, aes(x = label, y = value, fill = sign)) +
    geom_col(width = 0.75) +
    geom_hline(yintercept = 0, linewidth = 0.3, colour = 'grey20') +
    coord_flip() +
    facet_grid(striplab ~ .) +
    scale_fill_manual(values = c(pos = POS, neg = NEG), guide = 'none') +
    scale_y_continuous(limits = rng, expand = expansion(mult = c(0.02, 0.02))) +
    labs(x = ytitle, y = if (keep_x) expression('radiative forcing ('*W/m^2*')') else NULL) +
    theme_bw(base_size = 13) +
    theme(panel.grid.minor = element_blank(),
          strip.background = element_rect(fill = 'grey85', colour = 'grey20'),
          strip.text.y     = element_text(size = 12),
          axis.text        = element_text(colour = 'grey20'),
          axis.text.x      = if (keep_x) element_text() else element_blank(),
          axis.ticks.x     = if (keep_x) element_line() else element_blank())
}

rng = range(c(both$value, 0)) + c(-0.12, 0.12)
hol$striplab  = 'Holocene'
ipcc$striplab = 'IPCC'
hol$sign  = ifelse(hol$value  >= 0, 'pos', 'neg')
ipcc$sign = ifelse(ipcc$value >= 0, 'pos', 'neg')

p_slide_lab = panel_plot(hol,  'time period (k years)', 'Holocene', FALSE) /
              panel_plot(ipcc, 'forcing agent',         'IPCC',     TRUE) +
              plot_layout(heights = c(nrow(hol), nrow(ipcc)))

ggsave('figures/forcing_barplot_slide18.pdf', p_slide_lab, width = 8, height = 6)
ggsave('figures/forcing_barplot_slide18.png', p_slide_lab, width = 8, height = 6, dpi = 150)

# kernel spread, same layout, Holocene panel only
hol3 = main %>%
  transmute(kernel, label = sub(' ka$', '', as.character(period)), value = global_equiv)
hol3$label = factor(hol3$label, levels = rev(sub(' ka$', '', labels_period)))
p_kern = ggplot(hol3, aes(x = label, y = value, fill = kernel)) +
  geom_col(position = position_dodge(0.8), width = 0.7) +
  geom_hline(yintercept = 0, linewidth = 0.3) +
  coord_flip() +
  scale_fill_manual(values = c(hadgem='#1b6ca8', cam5='#5fa8d3', cack='#f2a65a'),
                    labels = c(cack='CACK (all-sky)', cam5='CAM5 (clear, surface)',
                               hadgem='HadGEM3 (clear, TOA)'), name = NULL) +
  labs(title = 'Kernel choice moves the answer by about a factor of two',
       subtitle = 'see C3 and C4; CACK is the only all-sky kernel of the three',
       x = 'time period (k years)', y = expression('radiative forcing ('*W/m^2*')')) +
  theme_bw(base_size = 12) + theme(panel.grid.minor = element_blank())
ggsave('figures/forcing_barplot_kernel_spread.pdf', p_kern, width = 8, height = 5)

p_dom = ggplot(main %>% filter(kernel=='hadgem'), aes(x = period, y = domain_mean)) +
  geom_col(fill = 'grey55') + geom_hline(yintercept = 0, linewidth = 0.3) +
  labs(title = 'Domain mean over the study area',
       subtitle = 'NOT comparable with global-mean IPCC ERF; see assumption A8',
       x = NULL, y = expression('W'~m^-2)) +
  theme_bw(base_size = 11) + theme(axis.text.x = element_text(angle = 30, hjust = 1))
ggsave('figures/forcing_barplot_domain_mean.pdf', p_dom, width = 9, height = 5)

p_sens = ggplot(sens, aes(x = period, y = global_equiv, fill = variant)) +
  geom_col(position = position_dodge(0.85), width = 0.8) +
  geom_hline(yintercept = 0, linewidth = 0.3) +
  labs(title = 'Sensitivity to the forcing variant (HadGEM3 kernel)',
       subtitle = 'Assumption A1 picks veg_ice_thresh; these are the alternatives',
       x = NULL, y = expression('global-equivalent forcing ('*W~m^-2*')')) +
  theme_bw(base_size = 11) + theme(axis.text.x = element_text(angle = 30, hjust = 1))
ggsave('figures/forcing_barplot_variant_sensitivity.pdf', p_sens, width = 10, height = 5)

# --- numbers out -------------------------------------------------------------
write.csv(main, 'output/forcing/forcing_by_period.csv', row.names = FALSE)
write.csv(sens, 'output/forcing/forcing_by_period_variant_sensitivity.csv', row.names = FALSE)
write.csv(modern, 'output/forcing/modern_ipcc_ar6_erf.csv', row.names = FALSE)

run_end(outputs = Filter(file.exists, c(
  'figures/forcing_barplot_slide18.pdf',
  'figures/forcing_barplot_slide18.png',
  'figures/forcing_barplot_kernel_spread.pdf',
  'figures/forcing_barplot_domain_mean.pdf',
  'figures/forcing_barplot_variant_sensitivity.pdf',
  'output/forcing/forcing_by_period.csv',
  'output/forcing/forcing_by_period_variant_sensitivity.csv',
  'output/forcing/modern_ipcc_ar6_erf.csv')))
