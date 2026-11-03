# Cross-validation that chooses the albedo model on its accuracy for land-cover mixes beyond the
# modern range: the protocol Chris approved on 2 November 2026 (docs/cc/2026-11-02_cv_protocol.md).
#
# Why: the hindcast predicts albedo for past cover mixes, some of them outside the range of the
# modern (training) mixes, the northeast's high evergreen cover most of all. Ordinary or spatial
# cross-validation tests predictions for mixes like the training ones; here each holdout withholds,
# everywhere, the far end of a direction in which past mixes leave the modern range, so the model is
# scored on mixes outside its own training range, as the hindcast is. No geographic buffer: the
# hindcast predicts at the training cells' own locations (protocol, section 3).
#
# Three steps, one function each, used by tools/cross_validate_albedo.R:
#   cv_directions() and cv_holdouts()  which cells each holdout withholds;
#   cv_score()                         the weighted error of each model, and its uncertainty;
#   cv_choose()                        the protocol's rule for choosing the model.
# Distances and the training range are those of R/training_support.R (the cover triangle).
# Needs sf (through R/training_support.R).

source('R/training_support.R')
source('R/regions.R')   # the northeast box, for the by-region report

CV_CUTS           = c(0.8, 0.7, 0.9)            # percentile of the cut: the 80th, else the 70th or 90th if infeasible
CV_DISTANCE_BANDS = c(0, 0.02, 0.05, 0.10, Inf) # distance outside the training range, cover-triangle units
CV_BLOCK_DEGREES  = 5                           # geographic blocks for the uncertainty: 5 x 5 one-degree cells
CV_MIN_BLOCKS     = 10                          # the scored withheld cells (positive target weight) must lie in at least this many blocks
CV_MAX_DIRECTIONS = 3
CV_RESAMPLES      = 1000
CV_KM_BANDS       = c(0, 100, 250, 500, Inf)    # distance to the nearest training cell (km), for the geographic report
# The candidates fitted on the in-range holdout besides the chosen one: the pairs that differ only in
# the location term (Chris, 3 November; protocol, geographic amendment).
CV_INRANGE_MODELS = c('mod8', 'cover_elev', 'mod8_coarse_loc', 'lin_cover', 'lin_cover_noloc')

# The target (protocol, section 2, as amended 3 November): the past cell-slices in the forcing's
# latitude window (script 8 keeps lat_min < latitude < lat_max), each weighted so that every slice
# and every month count equally and, within a slice, by area times the ice-free fraction. Each
# slice's area and ice fraction come from script 7a's pairs: a slice is the younger end of its own
# pair, and the oldest slice the older end of the last pair (ice does not depend on the month).
# Cell-slices without an ice fraction (script 7a leaves a few missing) get no weight; the caller
# reports how many. `slices` are the run's configured ages, youngest (modern) first; the modern
# slice is not part of the target.
cv_target_weights = function(paleo, diffs, slices, n_months, lat_min, lat_max) {
  slices = sort(slices)
  pairs = diffs[diffs$month == diffs$month[1], ]
  if (!setequal(unique(pairs$year), head(slices, -1)))
    stop('script 7a\'s pairs do not start at the configured slices (config.R analysis$ages) but the last')
  oldest = pairs[pairs$year == slices[length(slices) - 1], ]
  ice = rbind(data.frame(x = pairs$x, y = pairs$y, ages = pairs$year, area = as.numeric(pairs$area), ice = pairs$ice_frac_young),
              data.frame(x = oldest$x, y = oldest$y, ages = max(slices), area = as.numeric(oldest$area), ice = oldest$ice_frac_old))
  past = paleo[paleo$ages %in% slices[-1] & paleo$y > lat_min & paleo$y < lat_max, ]
  past = merge(past, ice[!is.na(ice$ice), ], by = c('x', 'y', 'ages'))
  if (anyDuplicated(past[, c('x', 'y', 'ages')])) stop('a past cell-slice has two ice fractions')
  ice_free_area = past$area * (1 - past$ice)
  past$weight = ice_free_area / ave(ice_free_area, past$ages, FUN = sum) / length(unique(past$ages)) / n_months
  past
}

# The direction (degrees on the cover triangle, 0 = towards more summergreen at fixed evergreen,
# 90 = towards more evergreen) in which each mix lies outside the hull, from the nearest point of
# the hull's edge. NA for a mix inside.
departure_angle = function(cover, hull) {
  angle = rep(NA_real_, nrow(cover))
  out = training_support(cover, hull)$outside
  if (!any(out)) return(angle)
  points = sf::st_as_sf(cover_triangle_xy(cover[out, ]), coords = c('px', 'py'))
  edge = sf::st_cast(sf::st_sfc(sf::st_polygon(list(as.matrix(hull[, c('px', 'py')])))), 'LINESTRING')
  # Each nearest-point line runs from the mix to the edge, so the departure is its start minus its end.
  ends = lapply(sf::st_nearest_points(points, edge), function(l) unclass(l)[c(1, 2), ])
  angle[out] = sapply(ends, function(e) atan2(e[1, 2] - e[2, 2], e[1, 1] - e[2, 1]) * 180 / pi)
  angle
}

angle_gap = function(a, b) { d = abs(a - b) %% 360; pmin(d, 360 - d) }

# The broad directions in which the past leaves the modern range: the departure angles of the
# outside hindcast mixes (any month), weighted by their target weights, grouped by hierarchical
# clustering of whole-degree angles into at most three groups. Returns one row per direction:
# its mean angle and its cluster's share of the outside target weight, largest first. (The
# holdouts stage then assigns each mix to its nearest direction and reports those shares, the ones
# the score uses; the names d1, d2, d3 keep the cluster order.)
cv_directions = function(angle, weight, n = CV_MAX_DIRECTIONS) {
  keep = !is.na(angle) & weight > 0
  bins = tapply(weight[keep], round(angle[keep]) %% 360, sum)
  degrees = as.numeric(names(bins))
  # `members` gives each whole-degree bin its target weight, so the linkage weighs bins by it.
  groups = if (length(bins) <= n) seq_along(bins) else
    cutree(hclust(as.dist(outer(degrees, degrees, angle_gap)), method = 'average', members = as.numeric(bins)), k = n)
  out = do.call(rbind, lapply(split(seq_along(bins), groups), function(i)
    data.frame(angle = atan2(sum(bins[i] * sinpi(degrees[i] / 180)), sum(bins[i] * cospi(degrees[i] / 180))) * 180 / pi,
               share = sum(bins[i]) / sum(bins))))
  out = out[order(-out$share), ]
  out$direction = paste0('d', seq_len(nrow(out)))
  rownames(out) = NULL
  out
}

# The nearest of the directions to each departure angle (NA stays NA).
nearest_direction = function(angle, directions) {
  nearest = rep(NA_character_, length(angle))
  known = !is.na(angle)
  nearest[known] = directions$direction[apply(outer(angle[known], directions$angle, angle_gap), 1, which.min)]
  nearest
}

# Where each withheld cell lies outside its own fold's training range (`hull`), and the group its
# error counts in: month, the nearest of the directions to its own departure, and its distance band;
# the rule for the past mixes too (protocol, section 6, amended 3 November). One function, so that the
# holdouts stage (which withheld cells the score uses) and the fit and score stages group alike.
withheld_departure = function(valid, hull, directions, month) {
  support = training_support(valid, hull)
  angle = departure_angle(valid, hull)
  own_direction = nearest_direction(angle, directions)
  data.frame(outside = support$outside, distance = support$distance_outside, angle = angle, own_direction = own_direction,
             group = paste(rep(month, nrow(valid)), own_direction, distance_band(support$distance_outside)))
}

# Which cells a direction's holdout withholds: those beyond the `cut` percentile of the modern
# cells' positions along that direction on the cover triangle. Withheld from training in every
# month, so a withheld mix can never be supplied by a training cell elsewhere.
cv_holdouts = function(cover, angle, cut) {
  xy = cover_triangle_xy(cover)
  along = xy$px * cospi(angle / 180) + xy$py * sinpi(angle / 180)
  along > stats::quantile(along, cut, names = FALSE)
}

# The geographic block of each cell (x = longitude, y = latitude of the one-degree cell centres).
cv_block = function(x, y, size = CV_BLOCK_DEGREES) paste(floor(x / size), floor(y / size))

distance_band = function(distance) cut(distance, CV_DISTANCE_BANDS, right = FALSE)
km_band = function(km) cut(km, CV_KM_BANDS, right = FALSE)

# The withheld cells' errors by diagnostic region (R/regions.R), month and own direction, for each
# model: how many withheld cells and blocks support each (a cell withheld by two holdouts counts once
# in the cell counts and the correlation, twice in the errors, one prediction each), how many have
# low open land, the RMSE and mean signed error, and how closely evergreen share follows latitude
# among them. Shows what the pooled score hides for the northeast (Astra, 3 November; protocol,
# amendment of 3 November). Reported only, never used for the choice. `predictions`: the fit stage's
# rows with a prediction (x, y, ET, OL, month, own_direction, model, predicted, observed). A cell with
# no own direction (inside its training range: the in-range holdout's cells) is labelled "inside".
cv_by_region = function(predictions, low_open_land) {
  predictions$region = region_of(predictions$x, predictions$y)
  predictions$own_direction[is.na(predictions$own_direction)] = 'inside'
  if (!nrow(predictions))
    return(data.frame(model = character(), region = character(), month = character(), own_direction = character(),
                      cells = integer(), predictions = integer(), blocks = integer(), low_open_land_cells = integer(),
                      rmse = numeric(), signed_error = numeric(), cor_evergreen_latitude = numeric()))
  parts = split(predictions, predictions[, c('model', 'region', 'month', 'own_direction')], drop = TRUE)
  out = do.call(rbind, lapply(parts, function(r) {
    cells = r[!duplicated(r[, c('x', 'y')]), ]
    data.frame(model = r$model[1], region = r$region[1], month = r$month[1], own_direction = r$own_direction[1],
               cells = nrow(cells), predictions = nrow(r), blocks = length(unique(cv_block(cells$x, cells$y))),
               low_open_land_cells = sum(cells$OL <= low_open_land),
               rmse = sqrt(mean((r$predicted - r$observed)^2)), signed_error = mean(r$predicted - r$observed),
               cor_evergreen_latitude = if (nrow(cells) > 2 && stats::sd(cells$ET) > 0 && stats::sd(cells$y) > 0)
                 stats::cor(cells$ET, cells$y) else NA_real_)
  }))
  out = out[order(out$region, out$month, out$own_direction, out$model), ]
  rownames(out) = NULL
  out
}

# The score of each model: the mean squared error of predicted albedo on the withheld cells,
# averaged within each group (month, direction, distance band) and combined across groups by the
# hindcast's target weight in that group (protocol, section 6). Groups with no withheld cell are
# not represented; their share is reported. Its uncertainty: the scores again on CV_RESAMPLES
# resamples of the geographic blocks (a block keeps all its months and holdouts together).
#   errors   one row per withheld cell, month and holdout: group, block and one column of
#            squared error per model (named by model id);
#   target   the target weight of each group: columns group and weight (all outside groups).
# Returns the scores, the represented share of the target, and the resampled scores (a matrix,
# one row per resample, one column per model).
cv_score = function(errors, target, models, seed, resamples = CV_RESAMPLES) {
  weight = target$weight[match(errors$group, target$group)]
  if (anyNA(weight)) stop('cv_score: withheld cells in groups with no target weight')
  score_of = function(multiplicity) {
    sums = rowsum(as.matrix(errors[, models, drop = FALSE]) * multiplicity, errors$group)
    counts = rowsum(multiplicity, errors$group)[, 1]
    w = target$weight[match(rownames(sums), target$group)] * (counts > 0)
    colSums(sums / pmax(counts, 1) * w) / sum(w)
  }
  blocks = unique(errors$block)
  weighted_groups = intersect(errors$group, target$group[target$weight > 0])
  draws = withr_seed(seed, replicate(resamples, {
    picked = table(factor(sample(blocks, replace = TRUE), levels = blocks))
    multiplicity = as.numeric(picked[errors$block])
    c(score_of(multiplicity), missed = !all(weighted_groups %in% errors$group[multiplicity > 0]))
  }))
  # A resample that misses a group renormalises over the groups it has (a block resample of the
  # whole score); how many did so is reported.
  list(score = score_of(rep(1, nrow(errors))),
       represented = sum(target$weight[target$group %in% errors$group]) / sum(target$weight),
       resampled = t(matrix(draws[models, , drop = FALSE], nrow = length(models), dimnames = list(models, NULL))),
       resamples_missing_a_group = sum(draws['missed', ]))
}

# Each model's mean squared error and its paired difference from `baseline` within each band (the
# columns of `bands`, one row per row of `errors`), on the rows where both have a prediction, with
# the standard error of the difference from resampling the geographic blocks (cv_score, one group).
# A failed fit is a missing value: it drops that row for that model only. A band with no row has no
# output row; a model with no usable row in a band has missing values there. For the geographic report
# (protocol, amendment of 3 November): reported only, never used to choose. `errors` as for cv_score
# (block, one squared-error column per model, one row per cell, month and holdout).
cv_paired_by_band = function(errors, bands, models, baseline, seed, resamples = CV_RESAMPLES) {
  key = do.call(paste, c(bands, sep = ' | '))
  do.call(rbind, lapply(split(seq_len(nrow(errors)), key, drop = TRUE), function(i) do.call(rbind, lapply(models, function(m) {
    pair = unique(c(m, baseline))
    ok = i[stats::complete.cases(errors[i, pair, drop = FALSE])]
    out = data.frame(bands[i[1], , drop = FALSE], model = m, cell_month_holdouts = length(ok), blocks = length(unique(errors$block[ok])),
                     mse = NA_real_, difference = NA_real_, se_difference = NA_real_, row.names = NULL)
    if (length(ok)) {
      s = cv_score(transform(errors[ok, ], group = 'all'), data.frame(group = 'all', weight = 1), pair, seed, resamples)
      out$mse = s$score[[m]]
      out$difference = s$score[[m]] - s$score[[baseline]]
      out$se_difference = stats::sd(s$resampled[, m] - s$resampled[, baseline])
    }
    out
  }))))
}

# Each band's share of the selection score's weight: a row's weight is its group's target weight shared
# equally among the group's rows (as in cv_score), summed within the band and divided by the total.
cv_weight_share = function(group, target, bands) {
  row_weight = target$weight[match(group, target$group)] / ave(rep(1, length(group)), group, FUN = sum)
  aggregate(list(score_weight_share = row_weight / sum(row_weight)), bands, sum)
}

# One squared error (or other `value`) per row of `ids` and one column per model; a model with no row
# at all gets a column of missing values, so it is reported, never dropped.
wide_by_model = function(predictions, ids, value, models) {
  w = stats::reshape(data.frame(predictions[, c(ids, 'model')], value = value), idvar = ids, timevar = 'model', direction = 'wide')
  names(w) = sub('^value\\.', '', names(w))
  for (m in setdiff(models, names(w))) w[[m]] = NA_real_
  rownames(w) = NULL
  w
}

# Evaluate `expr` with R's random numbers seeded, then restore the previous state, so the seed
# acts on this call only (as gratia's simulate() does for the draws, R/random.R).
withr_seed = function(seed, expr) {
  old = if (exists('.Random.seed', globalenv())) get('.Random.seed', globalenv())
  on.exit(if (is.null(old)) rm('.Random.seed', envir = globalenv()) else assign('.Random.seed', old, globalenv()))
  set.seed(seed)
  expr
}

# The protocol's choice: among the eligible models (not a baseline, every required fit
# converged), the lowest score, unless a simpler eligible model's score is within one standard
# error of the paired difference (the resampled scores' standard deviation of the difference);
# simpler means fewer coefficients, then earlier in CV_MODELS. No model is chosen if none is
# eligible or the resampled scores of an eligible model are not all finite (the uncertainty is then
# unsupported). Returns one row per model with its score, the difference from the best and its
# standard error, whether it is comparable, and the choice.
cv_choose = function(scored, coefficients, eligible) {
  models = names(scored$score)
  if (!any(eligible)) stop('cv_choose: no eligible model')
  best = models[eligible][which.min(scored$score[eligible])]
  difference = scored$score - scored$score[best]
  se = apply(scored$resampled, 2, function(s) stats::sd(s - scored$resampled[, best]))
  supported = all(is.finite(scored$resampled[, eligible]))
  comparable = eligible & is.finite(se) & difference <= se
  order_simple = order(!comparable, coefficients, match(models, CV_MODELS))
  data.frame(model = models, score = scored$score, rmse = sqrt(scored$score), difference = difference,
             se_difference = se, coefficients = coefficients, eligible = eligible, comparable = comparable,
             chosen = supported & models == models[order_simple[1]], row.names = NULL)
}
