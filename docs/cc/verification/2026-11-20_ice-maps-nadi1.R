# Script 7's map ice (branch ice-maps), 2 of 2: script 7 with the NADI-1 best estimate
# (analysis$ice$fraction_source = "nadi1_optimal"), from the saved headline's prediction summary with its
# recorded seed. Checks on what it writes (data/ in the run folder), at each coarse age:
#   1. every flag in the coarse differences is 'ICE' exactly where the cell's fraction in
#      data/nadi1_fractions/nadi1_optimal.tif exceeds analysis$ice$threshold (0.5), and NA elsewhere;
#   2. the saved outline (ice_fort) covers exactly the flagged cells, counting rings by the even-odd rule the
#      maps draw with (group = id, subgroup = group), so enclosed ice-free cells stay unfilled;
#   3. every coarse age has an outline, and both difference-outline tables cover all seven periods.
# The figures themselves are inspected by eye. Approved build: docs/cc/2026-11-20_ice_maps_design.md.
headline = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main'   # d5d5df5, PASS 2026-11-02
run      = '.rundirs/ice-maps-nadi1'
check = sprintf(r"(
run = '%s'; ages = c(50, 500, 2000, 4000, 6000, 8000, 10000, 11500); threshold = 0.5
d    = readRDS(file.path(run, 'data/alb_interp_preds_diffs_bluesky.RDS'))
fort = readRDS(file.path(run, 'data/ice_fort.RDS'))
r    = terra::rast('data/nadi1_fractions/nadi1_optimal.tif')
painted = function(px, py, rings) {   # even-odd count of the rings containing each point
  n = integer(length(px))
  for (g in unique(rings$group)) {
    ring = rings[rings$group == g, ]
    n = n + (sp::point.in.polygon(px, py, ring$long, ring$lat) == 1)
  }
  n %%%% 2 == 1
}
bad = 0
for (i in seq_along(ages)) {
  a = ages[i]
  young = d[d$year == a, ]
  old   = if (i > 1) d[d$year == ages[i - 1] & !is.na(d$alb_mean_ice_old), ] else d[0, ]
  pts = unique(rbind(data.frame(x = young$x, y = young$y, flag = young$ice_young),
                     data.frame(x = old$x, y = old$y, flag = old$ice_old)))
  f = terra::extract(r[[paste0('yr', a, 'bp')]], as.matrix(pts[, c('x', 'y')]))[, 1]
  expected = !is.na(f) & f > threshold
  flagged  = !is.na(pts$flag) & pts$flag == 'ICE'
  bad_values = sum(!is.na(pts$flag) & pts$flag != 'ICE')
  drawn = painted(pts$x, pts$y, fort[fort$ages == a, ])
  cat(sprintf('%%5d BP: %%d cells, %%d flagged ICE, %%d above the threshold; flag mismatches %%d; outline mismatches %%d; other flag values %%d\n',
              a, nrow(pts), sum(flagged), sum(expected), sum(expected != flagged), sum(drawn != flagged), bad_values))
  bad = bad + sum(expected != flagged) + sum(drawn != flagged) + bad_values
}
fy = readRDS(file.path(run, 'data/ice_fort_diff_young.RDS')); fo = readRDS(file.path(run, 'data/ice_fort_diff_old.RDS'))
cat('ages with an outline:', paste(sort(unique(fort$ages)), collapse = ' '), '\n')
cat('periods with a young / old difference outline:', length(unique(fy$facets)), '/', length(unique(fo$facets)), '\n')
stopifnot(bad == 0, setequal(unique(fort$ages), ages), length(unique(fy$facets)) == 7, length(unique(fo$facets)) == 7)
cat('all checks passed\n')
)", run)
list(
  name     = 'ice-maps-nadi1',
  commit   = '4e8532c91893c496ea5d0633c169b899ceeac7b4',
  config   = 'config.R',
  settings = list(analysis = list(draws = list(seed = 1549466984), ice = list(fraction_source = 'nadi1_optimal'))),
  copy     = list(c(file.path(headline, 'output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS'),
                    'output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS')),
  scripts  = c('scripts/7_plot_preds.R'),
  checks   = list('tests/test_config.R', 'tests/test_paths.R', c('-e', check)),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1'))
