# A check with no fits (Chris's decision 1 of 26 November, docs/cc/2026-11-26_cv_spatial_folds_decisions.md):
# protocol 2's score of the saved withheld predictions, on the cells 250 km or more from the nearest
# training cell instead of those under 250 km, beside protocol 2's own (nearby) score; where each
# model's margin comes from; and how much of the past target lies at a fitted cell's own place.
#
#   Rscript tools/check_cv_far_cells.R <protocol-2 run dir> <output dir>
#
# Everything is protocol 2's machinery (R/cross_validation.R, tools/cross_validate_albedo.R): the
# frozen groups and target weights, the ten-block rule, eligibility, the block resampling with its
# seed, and the one-standard-error rule. Only the distance condition is reversed. cv_scoring_rows()
# hard-codes "under 250 km", so the far rows are selected here, by far_rows() below.

source('tools/cross_validate_albedo.R')   # sourced, its command-line block does not run

args = commandArgs(trailingOnly = TRUE)
if (length(args) != 2) stop('usage: Rscript tools/check_cv_far_cells.R <protocol-2 run dir> <output dir>')
run_dir = args[1]
out_dir = args[2]
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
paths = pipeline_paths(NULL, redirected_paths(run_dir))
holdouts = readRDS(cv_file(run_dir, 'holdouts.rds'))
check_inputs(holdouts, paths)
target = holdouts$target
hm = function(r) paste(r$holdout, r$month)

# cv_scoring_rows() with the distance condition reversed (a cell at exactly 250 km is far there too).
far_rows = function(r) is.finite(r$km) & r$km >= CV_NEARBY_KM & r$group %in% target$group[target$weight > 0]

# The ten-block rule on the far cells, per holdout (direction) and month, with protocol 2's
# training-row rule. Only holdout-months feasible in protocol 2 were fitted, so only they can be scored.
f = holdouts$feasibility
far = holdouts$validation[far_rows(holdouts$validation), ]
f$far_scored_cells = as.vector(table(factor(hm(far), hm(f))))
f$far_blocks = vapply(hm(f), function(k) length(unique(cv_block(far$x, far$y)[hm(far) == k])), 0L)
f$far_feasible = f$training_rows >= f$largest_model & f$far_blocks >= CV_MIN_BLOCKS
f$scored = f$far_feasible & f$feasible

# The saved predictions, as stage_score() reads them (stale files are refused by their holdouts MD5).
fitted = f[f$feasible, ]
predictions = read_predictions(run_dir, cv_file(run_dir, sprintf('predictions_%s_%s.rds', fitted$holdout, fitted$month)))
ok = predictions$converged & is.finite(predictions$predicted)
errors = wide_by_model(predictions, c('holdout', 'month', 'x', 'y', 'own_direction', 'group', 'km', 'distance'),
                       ifelse(ok, (predictions$predicted - predictions$observed)^2, NA), CV_MODELS)
errors$block = cv_block(errors$x, errors$y)
used = hm(f)[f$scored]
e = errors[far_rows(errors) & hm(errors) %in% used, ]
scored = cv_score(e, target, CV_MODELS, seed = SEEDS$resample)
# Eligibility as in protocol 2: every fit the score uses converged.
converged = vapply(CV_MODELS, function(m) all(ok[predictions$model == m & hm(predictions) %in% used]), TRUE)
choice = cv_choose(scored, holdouts$coefficients[CV_MODELS], eligible = converged)

nearby = utils::read.csv(cv_file(run_dir, 'scores.csv'))[, c('model', 'score', 'chosen')]
names(nearby) = c('model', 'nearby_score', 'nearby_chosen')
scores = merge(data.frame(model = choice$model, coefficients = choice$coefficients, eligible = choice$eligible,
                          far_score = choice$score, far_difference = choice$difference, far_se_difference = choice$se_difference,
                          far_comparable = choice$comparable, far_chosen = choice$chosen,
                          far_represented = scored$represented, far_resamples_missing_a_group = scored$resamples_missing_a_group),
               nearby, sort = FALSE)
leader = choice$model[choice$eligible & choice$difference %in% 0][1]

# Each model's margin over the far leader is a sum over rows: a row's weight is its group's target
# weight shared among the group's rows (as in cv_score), times the difference of squared errors.
w = target$weight[match(e$group, target$group)] / ave(rep(1, nrow(e)), e$group, FUN = length)
contribution = (as.matrix(e[, CV_MODELS]) - e[[leader]]) * w / sum(w)
margin_share = function(part) {
  s = rowsum(contribution, part)
  out = data.frame(part = rownames(s), model = rep(colnames(s), each = nrow(s)), margin_part = c(s),
                   share_of_margin = c(sweep(s, 2, colSums(s), '/')))
  out = out[out$model != leader, ]
  out[order(out$model, -abs(out$share_of_margin)), ]
}
block_name = function(x, y) sprintf('lon %d to %d, lat %d to %d (%s)', 5 * floor(x / 5), 5 * floor(x / 5) + 5,
                                    5 * floor(y / 5), 5 * floor(y / 5) + 5, region_of(5 * floor(x / 5) + 2.5, 5 * floor(y / 5) + 2.5))
by_direction = margin_share(e$own_direction)
by_block = margin_share(block_name(e$x, e$y))

# The past target as protocol 2 builds it (stage_holdouts()), per cell: outside-hull mixes, each with
# its target weight, and whether its cell is a full-data calibration cell of that month (0 km).
a = holdouts$analysis
cal = readRDS(path_file(paths, 'calibration_table'))
past = cv_target_weights(readRDS(path_file(paths, 'lct_paleo')), readRDS(path_file(paths, 'albedo_differences')),
                         a$ages, length(a$months), a$domain$lat_min, a$domain$lat_max)
hindcast = do.call(rbind, lapply(a$months, function(m) {
  fitted_cells = cal[complete_rows(cal, m), ]
  hull = training_hull(fitted_cells)
  data.frame(month = m, weight = past$weight, angle = departure_angle(past, hull),
             distance = training_support(past, hull)$distance_outside,
             at_place = paste(past$x, past$y) %in% paste(fitted_cells$x, fitted_cells$y))
}))
hindcast = hindcast[!is.na(hindcast$angle), ]
hindcast$direction = nearest_direction(hindcast$angle, holdouts$directions)
# The rebuilt target must be protocol 2's frozen one, or the share below would describe another target.
rebuilt = aggregate(weight ~ paste(month, direction, distance_band(distance)), hindcast, sum)
if (!setequal(rebuilt[[1]], target$group) || !isTRUE(all.equal(rebuilt$weight, target$weight[match(rebuilt[[1]], target$group)])))
  stop('the rebuilt past target differs from holdouts.rds')
share_at_place = function(month, direction) {
  s = aggregate(cbind(target_weight = weight, at_fitted_place = weight * at_place) ~ month + direction,
                data.frame(hindcast[c('weight', 'at_place')], month = month, direction = direction), sum)
  transform(s, share = at_fitted_place / target_weight)
}
n = nrow(hindcast)
at_place = rbind(share_at_place(hindcast$month, hindcast$direction), share_at_place(hindcast$month, rep('all', n)),
                 share_at_place(rep('all', n), hindcast$direction), share_at_place(rep('all', n), rep('all', n)))

for (name in c('scores', 'by_direction', 'by_block', 'at_place'))
  utils::write.csv(get(name), file.path(out_dir, paste0('far_', name, '.csv')), row.names = FALSE)
utils::write.csv(f, file.path(out_dir, 'far_feasibility.csv'), row.names = FALSE)

cat(sprintf('Holdout-months scored on far cells: %d of %d fitted (%d far-feasible but not fitted).\n',
            sum(f$scored), sum(f$feasible), sum(f$far_feasible & !f$feasible)))
cat(sprintf('Represented target weight: far %.3f; resamples missing a group: %d of %d.\n',
            scored$represented, scored$resamples_missing_a_group, CV_RESAMPLES))
print(scores[, c('model', 'coefficients', 'eligible', 'far_score', 'far_difference', 'far_se_difference',
                 'far_chosen', 'nearby_score', 'nearby_chosen')], row.names = FALSE, digits = 3)
cat('Far choice:', choice$model[choice$chosen], '| nearby choice:', nearby$model[nearby$nearby_chosen], '| far leader:', leader, '\n')
runner_up = choice$model[choice$eligible][order(choice$score[choice$eligible])][2]
cat('\nWhere the far leader\'s margin over the runner-up (', runner_up, ') comes from, by direction and largest blocks:\n', sep = '')
print(by_direction[by_direction$model == runner_up, ], row.names = FALSE, digits = 3)
print(head(by_block[by_block$model == runner_up, ], 5), row.names = FALSE, digits = 3)
cat('\nShare of the past (outside-range) target at a fitted cell\'s own place, by month:\n')
print(at_place[at_place$direction == 'all', ], row.names = FALSE, digits = 3)
