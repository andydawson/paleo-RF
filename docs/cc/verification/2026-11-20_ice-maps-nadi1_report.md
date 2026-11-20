# Verification ice-maps-nadi1: PASS

- verdict: **PASS**
- commit: 4e8532c91893c496ea5d0633c169b899ceeac7b4
- spec: `docs/cc/verification/2026-11-20_ice-maps-nadi1.R`
- started 2026-11-20 11:48:20 UTC, finished 2026-11-20 13:00:53 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/4e8532c` at 4e8532c91893c496ea5d0633c169b899ceeac7b4; 0 frozen inputs linked from the main checkout
- run folder `.rundirs/ice-maps-nadi1`; configuration `.rundirs/ice-maps-nadi1/config_used.R` (from `config.R`); 1 files copied in
- runner `tools/rscript.sh` with THREADS=1 OPENBLAS_NUM_THREADS=1

## Scripts

- scripts/7_plot_preds.R: exit status 0, 72.0 min, run record `20261120T114833.467Z_2728737.md`, 4 outputs

## Anchors


## Checks

- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `-e 
run = '.rundirs/ice-maps-nadi1'; ages = c(50, 500, 2000, 4000, 6000, 8000, 10000, 11500); threshold = 0.5
d    = readRDS(file.path(run, 'data/alb_interp_preds_diffs_bluesky.RDS'))
fort = readRDS(file.path(run, 'data/ice_fort.RDS'))
r    = terra::rast('data/nadi1_fractions/nadi1_optimal.tif')
painted = function(px, py, rings) {   # even-odd count of the rings containing each point
  n = integer(length(px))
  for (g in unique(rings$group)) {
    ring = rings[rings$group == g, ]
    n = n + (sp::point.in.polygon(px, py, ring$long, ring$lat) == 1)
  }
  n %% 2 == 1
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
  cat(sprintf('%5d BP: %d cells, %d flagged ICE, %d above the threshold; flag mismatches %d; outline mismatches %d; other flag values %d\n',
              a, nrow(pts), sum(flagged), sum(expected), sum(expected != flagged), sum(drawn != flagged), bad_values))
  bad = bad + sum(expected != flagged) + sum(drawn != flagged) + bad_values
}
fy = readRDS(file.path(run, 'data/ice_fort_diff_young.RDS')); fo = readRDS(file.path(run, 'data/ice_fort_diff_old.RDS'))
cat('ages with an outline:', paste(sort(unique(fort$ages)), collapse = ' '), '\n')
cat('periods with a young / old difference outline:', length(unique(fy$facets)), '/', length(unique(fo$facets)), '\n')
stopifnot(bad == 0, setequal(unique(fort$ages), ages), length(unique(fy$facets)) == 7, length(unique(fo$facets)) == 7)
cat('all checks passed\n')
`: exit status 0

## Failures

- none
