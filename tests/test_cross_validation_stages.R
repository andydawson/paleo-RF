# Fit/score integration on a small frozen fixture. Fits are deterministic stand-ins; no GAM is fit.
# The fixture deliberately contains a failed candidate and far validation rows.
suppressMessages(source('tools/cross_validate_albedo.R'))
CV_RESAMPLES = 20L
run_dir = file.path(tempfile('cv2_stages_'), 'run')
dir.create(run_dir, recursive = TRUE)
invisible(file.copy('config.R', file.path(run_dir, 'config_used.R')))
paths = pipeline_paths(NULL, redirected_paths(run_dir))
cal = data.frame(x = c(-78, -77, -76, -75, -74, -73, -72, -71, -75, -73, -120, -121),
                  y = c(41, 42, 43, 44, 45, 46, 42, 43, 42, 45, 60, 61), elev = seq_len(12),
                  OL = c(.4, .5, .2, .3, .4, .1, .2, .3, .1, .05, .1, .05),
                  ET = c(.3, .1, .2, .4, .4, .5, .3, .2, .8, .85, .7, .8))
cal$ST = 1 - cal$OL - cal$ET
cal$jan = seq(.2, .31, length.out = 12)
cal$jan[3] = NA_real_
cal$feb = seq(.3, .41, length.out = 12)
for (name in c('calibration_table', 'lct_paleo', 'albedo_differences')) {
  file = path_file(paths, name)
  dir.create(dirname(file), recursive = TRUE, showWarnings = FALSE)
  saveRDS(cal, file)
}
directions = data.frame(direction = c('d1', 'd2'), angle = c(90, -30))
membership = data.frame(cal[, c('x', 'y')], d1 = seq_len(nrow(cal)) > 8, inrange = seq_len(nrow(cal)) %in% c(1, 4))
months = c('jan', 'feb')
validation = do.call(rbind, lapply(months, function(m) validation_cells(cal, membership$d1, directions, m, 'd1')))
validation$feasible = TRUE
# Geography is measured from actual monthly complete rows (January's missing row is not training).
jan = validation[validation$month == 'jan', ]
train = complete_rows(cal, 'jan') & !membership$d1
stopifnot(isTRUE(all.equal(jan$km, nearest_km(jan$x, jan$y, cal$x[train], cal$y[train]))),
          any(validation$km < 250), any(validation$km >= 250),
          jan$km[1] > validation$km[validation$month == 'feb'][1])
target = data.frame(group = c(unique(validation$group), 'jan d2 [0.05,0.1)'), weight = 1)
validation$selected = cv_scoring_rows(validation, target)
inrange_cells = do.call(rbind, lapply(months, function(m) validation_cells(cal, membership$inrange, directions, m, 'inrange')))
holdouts = list(protocol_version = 2L, models = CV_MODELS, terms = vapply(CV_MODELS, calibration_terms, ''),
                coefficients = CV_COEFFICIENTS, directions = directions, membership = membership,
                feasibility = data.frame(holdout = 'd1', month = months, feasible = TRUE), validation = validation,
                target = target, inrange = data.frame(month = months, feasible = TRUE), inrange_cells = inrange_cells,
                months = months, analysis = run_config(run_dir)$analysis, md5 = unname(input_md5(paths)))
saveRDS(holdouts, cv_file(run_dir, 'holdouts.rds'))
seen = list()
fit_and_predict = function(id, month, train, valid) {
  key = paste(month, paste(train$x, train$y, collapse = '/'))
  if (!is.null(seen[[key]])) stopifnot(identical(seen[[key]], train))
  seen[[key]] <<- train
  out = data.frame(model = id, predicted = rep(mean(train[[month]]) + .001 * match(id, CV_MODELS), nrow(valid)),
                    converged = !(id == 'loc12_tp50' && month == 'jan'), status = 'stand-in', warnings = '', retries = 0L, attempts = 'stand-in')
  attr(out, 'fit_summary') = data.frame(term = 'elevation', edf = 2, smoothing_parameter = 1)
  out
}
invisible(capture.output({ stage_fit(run_dir, paths, 'd1', months); stage_score(run_dir, paths) }))
out = function(name) utils::read.csv(cv_file(run_dir, name))
score_before = readLines(cv_file(run_dir, 'scores.csv'))
scores = out('scores.csv')
stopifnot(!scores$eligible[scores$model == 'loc12_tp50'], any(scores$chosen), all(scores$represented < 1),
          file.exists(cv_file(run_dir, 'fit_summary_d1_jan.csv')),
          !any(grepl('AIC', names(out('fit_summary_d1_jan.csv')))))
# Independently hand-scored from this fixture, including the unrepresented third group.
linear_score = scores[scores$model == 'lin_cover_noloc', ]
stopifnot(nrow(linear_score) == 1L,
          abs(linear_score$score - 0.002323295918367347) < 1e-15,
          abs(linear_score$represented - 2 / 3) < 1e-15)
notes = readLines(cv_file(run_dir, 'selection_notes.txt'))
stopifnot(paste('Chosen:', scores$model[scores$chosen]) %in% notes,
          any(grepl('Model 8 completed every required fit', notes, fixed = TRUE)))
# The manual score uses only the frozen positive-target nearby rows, all configurations together.
p = read_predictions(run_dir, cv_file(run_dir, paste0('predictions_d1_', months, '.rds')))
errors = wide_by_model(p, c('holdout', 'month', 'x', 'y', 'group', 'km'),
                       ifelse(p$converged, (p$predicted - p$observed)^2, NA), CV_MODELS)
errors$block = cv_block(errors$x, errors$y)
manual = cv_score(errors[cv_scoring_rows(errors, target), ], target, CV_MODELS, SEEDS$resample)
stopifnot(isTRUE(all.equal(unname(manual$score), scores$score)))
by_distance = out('by_distance.csv')
shares = unique(by_distance[by_distance$region == 'all', c('holdout', 'own_direction', 'km_band', 'cover_band', 'score_weight_share')])
stopifnot(isTRUE(all.equal(sum(shares$score_weight_share), 1)),
          all(by_distance$score_weight_share[by_distance$km_band %in% c('[250,500)', '[500,Inf)')] == 0),
          all(by_distance$difference[by_distance$model == 'mod8'] == 0, na.rm = TRUE),
          any(by_distance$missing_prediction_pairs[by_distance$model == 'loc12_tp50'] > 0),
          all(c('own_direction', 'signed_error', 'cells', 'blocks', 'positive_target_count', 'represented', 'missing') %in% names(by_distance)))
# In-range is exactly model 8 and the winner; diagnostics cannot change the selection.
invisible(capture.output({ stage_fit(run_dir, paths, 'inrange', months); stage_score(run_dir, paths) }))
stopifnot(identical(readLines(cv_file(run_dir, 'scores.csv')), score_before),
          setequal(out('inrange_scores.csv')$model, unique(c('mod8', scores$model[scores$chosen]))))
# All fits failed: preserve reports and make no choice. A missing entire candidate row is an error.
files = cv_file(run_dir, paste0('predictions_d1_', months, '.rds'))
original = lapply(files, readRDS)
for (i in seq_along(files)) {
  failed = original[[i]]
  failed$converged = FALSE
  failed$predicted = NA_real_
  saveRDS(failed, files[i])
}
invisible(capture.output(stage_score(run_dir, paths)))
stopifnot(!any(out('scores.csv')$chosen), !any(out('scores.csv')$eligible), !any(out('scores.csv')$comparison_complete))
notes = readLines(cv_file(run_dir, 'selection_notes.txt'))
stopifnot(any(startsWith(notes, 'No automatic choice:')),
          any(startsWith(notes, 'Model 8 failed a required fit:')))
for (i in seq_along(files)) saveRDS(original[[i]], files[i])
short = original[[1]][-1, ]
attr(short, 'holdouts_md5') = holdouts_md5(run_dir)
saveRDS(short, files[1])
stopifnot(grepl('every frozen validation row', tryCatch({ stage_score(run_dir, paths); '' }, error = conditionMessage)))
saveRDS(original[[1]], files[1])
# An in-range file from different holdouts is refused, as are old protocol-1 holdouts.
inrange_file = cv_file(run_dir, 'predictions_inrange_jan.rds')
r = readRDS(inrange_file)
attr(r, 'holdouts_md5') = 'older holdouts'
saveRDS(r, inrange_file)
message = tryCatch({ invisible(capture.output(stage_score(run_dir, paths))); '' }, error = conditionMessage)
stopifnot(grepl('predictions_inrange_jan.rds', message, fixed = TRUE))
holdouts$protocol_version = 1L
saveRDS(holdouts, cv_file(run_dir, 'holdouts.rds'))
stopifnot(grepl('not from protocol 2', tryCatch({ stage_score(run_dir, paths); '' }, error = conditionMessage)))
# No feasible fold is a reportable no-choice outcome, without fitting or reading predictions.
holdouts$protocol_version = 2L
holdouts$feasibility$feasible = FALSE
saveRDS(holdouts, cv_file(run_dir, 'holdouts.rds'))
invisible(capture.output(stage_score(run_dir, paths)))
stopifnot(!any(out('scores.csv')$chosen), all(out('scores.csv')$missing == 1))
unlink(dirname(run_dir), recursive = TRUE)
cat('test_cross_validation_stages: all tests passed\n')
