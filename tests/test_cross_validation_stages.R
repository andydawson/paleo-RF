# The cross-validation's fit and score stages end to end on a real holdouts run, with the model fits
# replaced by a quick deterministic stand-in, so the reports' code runs on data of the real shape
# without hours of fitting (Fable's and Astra's code reviews, 3 November 2026).
# Run from the repository root after the holdouts stage: Rscript tests/test_cross_validation_stages.R <run-dir>
suppressMessages(source("tools/cross_validate_albedo.R"))
source_dir <- commandArgs(trailingOnly = TRUE)[1]
if (is.na(source_dir)) stop("usage: Rscript tests/test_cross_validation_stages.R <run-dir with a holdouts stage>")

# A copy of the run, so the stand-in predictions never sit beside real ones.
run_dir <- file.path(tempfile("cv_stages_"), "run")
dir.create(file.path(run_dir, "output", "cross_validation"), recursive = TRUE)
invisible(file.copy(file.path(source_dir, "data"), run_dir, recursive = TRUE))
invisible(file.copy(file.path(source_dir, "config_used.R"), run_dir))
invisible(file.copy(file.path(source_dir, "output", "cross_validation", c("holdouts.rds", "inrange.csv")), file.path(run_dir, "output", "cross_validation")))
paths <- pipeline_paths(NULL, redirected_paths(run_dir))

# The stand-in: the training mean plus a small offset per model, so models differ; model 7 "fails to
# converge" in January, to exercise the failure paths.
fit_and_predict <- function(id, month, train, valid)
  data.frame(model = id, predicted = pmin(0.99, mean(train[[month]]) + 0.002 * match(id, CV_MODELS)),
             converged = !(id == "mod7" && month == "jan"), status = "stand-in", warnings = "")

invisible(capture.output({
  for (h in c("d1", "d2", "d3")) stage_fit(run_dir, paths, h, MONTHS)
  stage_score(run_dir, paths)
}))
out <- function(name) utils::read.csv(cv_file(run_dir, name))
scores_before <- readLines(cv_file(run_dir, "scores.csv"))

# The selection is what the code before the geographic reports (b7a5772's stats::reshape table) gives:
# the choice did not move when the error table was rebuilt with wide_by_model().
holdouts <- readRDS(cv_file(run_dir, "holdouts.rds"))
needed <- holdouts$feasibility[holdouts$feasibility$feasible, c("holdout", "month")]
p <- do.call(rbind, lapply(cv_file(run_dir, sprintf("predictions_%s_%s.rds", needed$holdout, needed$month)), readRDS))
p$squared_error <- (p$predicted - p$observed)^2
old <- stats::reshape(p[, c("holdout", "month", "x", "y", "group", "model", "squared_error")],
                      idvar = c("holdout", "month", "x", "y", "group"), timevar = "model", direction = "wide")
names(old) <- sub("^squared_error\\.", "", names(old))
old$block <- cv_block(old$x, old$y)
target <- merge(data.frame(group = unique(old$group)), holdouts$target[, c("group", "weight")], all = TRUE)
target$weight[is.na(target$weight)] <- 0
old_scored <- cv_score(old, target, CV_MODELS, seed = SEEDS$resample)
now <- out("scores.csv")
old_choice <- cv_choose(old_scored, now$coefficients, now$eligible)
stopifnot(isTRUE(all.equal(old_choice$score, now$score)), isTRUE(all.equal(old_choice$se_difference, now$se_difference)),
          identical(old_choice$chosen, now$chosen))
# Each band's weight share is the selection score's row weights summed (a row's weight: its group's
# target weight shared among the group's rows), so the shares add to one.
by_distance <- out("by_distance.csv")
shares <- unique(by_distance[, c("km_band", "cover_band", "score_weight_share")])
stopifnot(setequal(by_distance$model, CV_MODELS), isTRUE(all.equal(sum(shares$score_weight_share), 1)),
          all(by_distance$difference[by_distance$model == "mod8"] == 0, na.rm = TRUE),
          !out("scores.csv")$eligible[out("scores.csv")$model == "mod7"],     # not converged everywhere
          any(!is.na(by_distance$mse[by_distance$model == "mod7"])))          # but kept, failed fits dropped

# The in-range holdout after the score, then the score again: the choice must not move.
invisible(capture.output({
  stage_fit(run_dir, paths, "inrange", MONTHS)
  stage_score(run_dir, paths)
}))
inrange <- out("inrange_scores.csv")
stopifnot(identical(readLines(cv_file(run_dir, "scores.csv")), scores_before),
          all(CV_INRANGE_MODELS %in% inrange$model), inrange$difference[inrange$model == "mod8"] == 0,
          file.exists(cv_file(run_dir, "inrange_by_distance.csv")), file.exists(cv_file(run_dir, "inrange_by_region.csv")),
          identical(readRDS(cv_file(run_dir, "holdouts.rds"))$inrange[, c("month", "feasible")], out("inrange.csv")[, c("month", "feasible")]))
# An in-range file made for other holdouts is refused and named, the tail files being current.
inrange_file <- cv_file(run_dir, "predictions_inrange_jan.rds")
saveRDS(structure(readRDS(inrange_file), holdouts_md5 = "an older holdouts.rds"), inrange_file)
message <- tryCatch({ invisible(capture.output(stage_score(run_dir, paths))); "" }, error = conditionMessage)
stopifnot(grepl("predictions_inrange_jan.rds", message, fixed = TRUE))
# Rebuilding the holdouts makes the old predictions unscorable: the score stage stops instead of mixing them.
saveRDS(modifyList(readRDS(cv_file(run_dir, "holdouts.rds")), list(rebuilt = TRUE)), cv_file(run_dir, "holdouts.rds"))
rebuilt <- tryCatch({ invisible(capture.output(stage_score(run_dir, paths))); "" }, error = conditionMessage)
stopifnot(grepl("other holdouts", rebuilt, fixed = TRUE),
          all(file.exists(cv_file(run_dir, sprintf("record_fit_d1_%s.txt", c("jan", "jul"))))))   # one record per month
cat("test_cross_validation_stages: all tests passed\n")
