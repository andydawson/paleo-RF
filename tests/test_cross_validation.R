# Tests for R/cross_validation.R and the small helpers of tools/cross_validate_albedo.R, on cases
# worked by hand. Run from the repository root: Rscript tests/test_cross_validation.R
suppressMessages(source("tools/cross_validate_albedo.R"))   # brings R/cross_validation.R; runs nothing when sourced

# Departure direction, worked by hand: training mixes at the three edge midpoints span the middle
# triangle (as in tests/test_training_support.R). Pure open land, at (0, 0), is nearest to the middle
# of the edge from (0.5, 0) to (0.25, sqrt(3)/4), the point (0.375, sqrt(3)/8): it lies at -150 degrees
# from there. Pure summergreen lies at -30, pure evergreen at 90; the centroid is inside (NA).
training <- data.frame(OL = c(0.5, 0, 0.5), ET = c(0.5, 0.5, 0), ST = c(0, 0.5, 0.5))
past     <- data.frame(OL = c(1, 0, 0, 1/3), ET = c(0, 0, 1, 1/3), ST = c(0, 1, 0, 1/3))
angle    <- departure_angle(past, training_hull(training))
stopifnot(isTRUE(all.equal(angle[1:3], c(-150, -30, 90))), is.na(angle[4]),
          angle_gap(-150, 170) == 40, angle_gap(10, 350) == 20)

# The group a withheld cell's error counts in, by hand, on the same training range: pure open land lies
# outside at -150 degrees, sqrt(0.375^2 + 3/64) = 0.433 away (band [0.1, Inf)); pure evergreen at 90
# degrees, the same distance; the centroid is inside (no direction, distance 0). No cells, no rows.
toward <- data.frame(direction = c("d1", "d2"), angle = c(-150, 90))
dep <- withheld_departure(past[c(1, 3, 4), ], training_hull(training), toward, "jan")
stopifnot(identical(dep$outside, c(TRUE, TRUE, FALSE)), isTRUE(all.equal(dep$distance, c(sqrt(0.1875), sqrt(0.1875), 0))),
          identical(dep$group, c("jan d1 [0.1,Inf)", "jan d2 [0.1,Inf)", "jan NA [0,0.02)")),
          nrow(suppressWarnings(withheld_departure(past[0, ], training_hull(training), toward, "jan"))) == 0)   # sf warns on no points

# Directions: whole-degree angles grouped into at most n groups, weighted; largest share first.
directions <- cv_directions(c(0, 2, 180, NA), c(1, 1, 1, 5), n = 2)
stopifnot(identical(directions$direction, c("d1", "d2")),
          isTRUE(all.equal(directions$angle, c(1, 180))), isTRUE(all.equal(directions$share, c(2/3, 1/3))),
          identical(nearest_direction(c(5, 170, NA), directions), c("d1", "d2", NA)))

# A holdout withholds the cells beyond the cut along its direction, and every withheld mix lies
# outside the training range of the rest (the guarantee of the global cut).
set.seed(2)
g <- matrix(rexp(300), 100); g <- g / rowSums(g)
cells <- data.frame(OL = g[, 1], ET = g[, 2], ST = g[, 3])
withheld <- cv_holdouts(cells, 90, 0.8)        # 90 degrees: the most evergreen fifth
stopifnot(sum(withheld) == 20, min(cells$ET[withheld]) > max(cells$ET[!withheld]),
          all(training_support(cells[withheld, ], training_hull(cells[!withheld, ]))$outside),
          identical(cv_block(c(-71.5, -70.5, -66.5), c(44.5, 44.5, 44.5)), c("-15 8", "-15 8", "-14 8")))

# The score, by hand. Two groups: g1 (weight 3) with errors 1 and 3 for model a, g2 (weight 1) with
# error 2. Score a = (3 * 2 + 1 * 2) / 4 = 2; b = (3 * 1 + 1 * 5) / 4 = 2. A group outside the target
# list stops; the represented share counts only groups with withheld cells.
errors <- data.frame(group = c("g1", "g1", "g2"), block = c("A", "B", "B"), a = c(1, 3, 2), b = c(1, 1, 5))
target <- data.frame(group = c("g1", "g2", "g3"), weight = c(3, 1, 4))
scored <- cv_score(errors, target, c("a", "b"), seed = 7, resamples = 50)
stopifnot(isTRUE(all.equal(scored$score, c(a = 2, b = 2))), scored$represented == 0.5,
          identical(dim(scored$resampled), c(50L, 2L)),
          identical(cv_score(errors, target, c("a", "b"), seed = 7, resamples = 50)$resampled, scored$resampled),
          inherits(try(cv_score(transform(errors, group = "g9"), target, "a", 1, 5), silent = TRUE), "try-error"))
# The seed acts on that call only: R's own random numbers continue as before.
set.seed(3); r1 <- runif(1); set.seed(3); invisible(withr_seed(99, runif(5))); stopifnot(runif(1) == r1)

# The choice, by hand. m_big scores best; m_small is 0.05 worse, within one standard error of the
# paired difference (resampled differences 0, 0.2, 0, 0.2: sd 0.115), and has fewer coefficients, so
# it is chosen. The baseline scores best of all but is never chosen; m_far is 0.5 worse: not comparable.
resampled <- cbind(base = 0.5, m_big = 1, m_small = 1 + c(0, 0.2, 0, 0.2) + 0.05 - 0.1, m_far = 1.5)
choice <- cv_choose(list(score = c(base = 0.5, m_big = 1, m_small = 1.05, m_far = 1.5), resampled = resampled),
                    coefficients = c(50, 700, 60, 10), eligible = c(FALSE, TRUE, TRUE, TRUE))
stopifnot(identical(choice$chosen, c(FALSE, FALSE, TRUE, FALSE)),
          identical(choice$comparable, c(FALSE, TRUE, TRUE, FALSE)),
          isTRUE(all.equal(choice$difference, c(-0.5, 0, 0.05, 0.5))))
# Not converged everywhere: not eligible, so the next best is chosen.
choice2 <- cv_choose(list(score = c(m_big = 1, m_far = 1.5), resampled = cbind(m_big = c(1, 1.1), m_far = c(1.5, 1.6))),
                     coefficients = c(700, 10), eligible = c(FALSE, TRUE))
stopifnot(identical(choice2$chosen, c(FALSE, TRUE)))

# The resampled uncertainty must be finite: one non-finite resample of an eligible model means no
# automatic choice; an ineligible model's missing score is harmless; no eligible model stops.
choice3 <- cv_choose(list(score = c(m_big = 1, m_small = 1.05), resampled = cbind(m_big = c(1, NaN), m_small = c(1.05, NaN))),
                     coefficients = c(700, 60), eligible = c(TRUE, TRUE))
choice4 <- cv_choose(list(score = c(base = 0.1, m_big = 1, m_fail = NA), resampled = cbind(base = c(0.1, 0.1), m_big = c(1, 1.1), m_fail = NA)),
                     coefficients = c(50, 700, 10), eligible = c(FALSE, TRUE, FALSE))
stopifnot(!any(choice3$chosen), identical(choice4$chosen, c(FALSE, TRUE, FALSE)),
          inherits(try(cv_choose(list(score = c(a = 1), resampled = cbind(a = 1)), 1, FALSE), silent = TRUE), "try-error"))

# Target weights, worked by hand (Fable's review): cells A (area 2) and B (area 1), slices 50, 500,
# 1000; script 7a's pairs give A 0 / 0.5 / 1.0 and B 0 / 0 / 0 ice. Ice-free area: A500 = 1, A1000 = 0,
# B500 = 1, B1000 = 1, so A500 = B500 = 1/2/2, A1000 = 0, B1000 = 1/2 (one month). A cell outside the
# latitude window, and a cell-slice with a missing ice fraction, get no weight; the other cell of
# that slice then carries the slice's whole share.
paleo <- data.frame(ages = rep(c(50, 500, 1000), 3), x = rep(c(-70, -71, -72), each = 3), y = rep(c(45, 45, 80), each = 3),
                    OL = 0.3, ET = 0.3, ST = 0.4)
diffs <- data.frame(month = "jan", x = c(-70, -70, -71, -71, -72, -72), y = c(45, 45, 45, 45, 80, 80), year = c(50, 500),
                    area = c(2, 2, 1, 1, 1, 1), ice_frac_young = c(0, 0.5, 0, 0, 0, 0), ice_frac_old = c(0.5, 1, 0, 0, 0, 0))
w <- cv_target_weights(paleo, diffs, c(50, 500, 1000), n_months = 1, lat_min = 27, lat_max = 74)
w <- w[order(w$ages, w$x), ]
stopifnot(identical(w$x, c(-71, -70, -71, -70)), isTRUE(all.equal(w$weight, c(0.25, 0.25, 0.5, 0))), sum(w$weight) == 1)
diffs$ice_frac_young[2] <- NA
w2 <- cv_target_weights(paleo, diffs, c(50, 500, 1000), 1, 27, 74)
stopifnot(nrow(w2) == 3, isTRUE(all.equal(w2$weight[w2$ages == 500], 0.5)),
          inherits(try(cv_target_weights(paleo, diffs, c(50, 1000), 1, 27, 74), silent = TRUE), "try-error"))

# A fit that fails outright is recorded, with missing predictions, not dropped (the data lack the
# elevation the model needs).
failed <- suppressMessages(capture.output(r <- fit_and_predict("elev", "jan", data.frame(jan = runif(60, 0.1, 0.9)), data.frame(jan = c(0.5, 0.6)))))
stopifnot(nrow(r) == 2, !any(r$converged), all(is.na(r$predicted)), all(startsWith(r$status, "ERROR:")))

# Convergence: the loop stopped before its limit and the optimiser fully converged.
ok <- list(iter = 37L, control = list(maxit = 500), outer.info = list(conv = "full convergence"))
stopifnot(fit_converged(ok), !fit_converged(modifyList(ok, list(iter = 500L))),
          !fit_converged(modifyList(ok, list(outer.info = list(conv = "step failed")))))

# Distances: one degree of longitude at 45 degrees north is about 78.6 km; a cell is (to rounding) 0 km from itself.
stopifnot(abs(nearest_km(-70, 45, c(-71, -60), c(45, 45)) - 78.6) < 0.1, nearest_km(-70, 45, -70, 45) < 0.001)

# The by-region report, by hand: three northeast cells in three 5-degree blocks, errors 0.1, -0.1 and 0.2
# (RMSE sqrt(0.02), mean 0.2/3), one with open land at or below 0.2; one cell elsewhere, too few for a
# correlation.
p <- data.frame(x = c(-75, -69, -70, -120), y = c(41, 43, 46, 35), ET = c(0.4, 0.5, 0.6, 0.3), OL = c(0.1, 0.3, 0.3, 0.5),
                month = "jan", own_direction = "d2", model = "a", observed = 0.2, predicted = 0.2 + c(0.1, -0.1, 0.2, 0))
by_region <- cv_by_region(p, low_open_land = 0.2)
ne <- by_region[by_region$region == "Northeast (hemlock box)", ]
stopifnot(nrow(by_region) == 2, ne$cells == 3, ne$predictions == 3, ne$blocks == 3, ne$low_open_land_cells == 1,
          isTRUE(all.equal(ne$rmse, sqrt(0.02))), isTRUE(all.equal(ne$signed_error, 0.2 / 3)),
          isTRUE(all.equal(ne$cor_evergreen_latitude, cor(c(0.4, 0.5, 0.6), c(41, 43, 46)))),
          is.na(by_region$cor_evergreen_latitude[by_region$region == "elsewhere"]))
# A cell withheld by two holdouts: one more prediction, the same cells, blocks and correlation.
twice <- cv_by_region(rbind(p, p[1, ]), low_open_land = 0.2)
ne2 <- twice[twice$region == "Northeast (hemlock box)", ]
stopifnot(ne2$cells == 3, ne2$predictions == 4, ne2$blocks == 3, ne2$low_open_land_cells == 1,
          isTRUE(all.equal(ne2$cor_evergreen_latitude, ne$cor_evergreen_latitude)))
# Cells all on one latitude row: no correlation, and no warning.
flat <- transform(p[1:3, ], y = 45)
stopifnot(is.na(withCallingHandlers(cv_by_region(flat, 0.2), warning = function(w) stop("unexpected warning: ", conditionMessage(w)))$cor_evergreen_latitude))

# Distance bands: 100, 250 and 500 km open the next band.
stopifnot(identical(as.character(km_band(c(0, 99.9, 100, 250, 500))), c("[0,100)", "[0,100)", "[100,250)", "[250,500)", "[500,Inf)")))

# Paired differences by band, by hand: band "near" a = (1, 3), mod8 = (2, 2): MSE 2 and 2, difference 0;
# band "far" a = 5, mod8 = 1: difference 4 (one block, so no spread). A model identical to mod8 has
# difference 0 and standard error 0. A failed fit (NA) drops that row for that model only: "gap" is
# compared with mod8 on its one usable near row, (4 - 2) = 2; a model with no usable row has NA.
e <- data.frame(block = c("A", "B", "C"), a = c(1, 3, 5), mod8 = c(2, 2, 1), same = c(2, 2, 1), gap = c(NA, 4, NA), none = NA_real_)
pb <- cv_paired_by_band(e, data.frame(km_band = c("near", "near", "far")), c("a", "mod8", "same", "gap", "none"), "mod8", seed = 1, resamples = 50)
at <- function(b, m, col) pb[[col]][pb$km_band == b & pb$model == m]
stopifnot(isTRUE(all.equal(at("near", "a", "difference"), 0)), isTRUE(all.equal(at("far", "a", "difference"), 4)),
          all(pb$difference[pb$model == "same"] == 0), all(pb$se_difference[pb$model == "same"] == 0),
          at("near", "a", "cell_month_holdouts") == 2, at("far", "a", "cell_month_holdouts") == 1,
          isTRUE(all.equal(at("near", "gap", "difference"), 2)), at("near", "gap", "cell_month_holdouts") == 1,
          is.na(at("far", "gap", "difference")), all(is.na(pb$mse[pb$model == "none"])))
# A non-zero paired standard error: differences 1 and 3 in two blocks resample to 1, 2 or 3.
e2 <- data.frame(block = c("A", "B"), a = c(2, 4), mod8 = c(1, 1))
pb2 <- cv_paired_by_band(e2, data.frame(km_band = c("x", "x")), c("a", "mod8"), "mod8", seed = 2, resamples = 200)
stopifnot(pb2$se_difference[pb2$model == "a"] > 0.3, pb2$se_difference[pb2$model == "a"] < 0.9)

# The in-range report, by hand: model 8 has squared errors 0.04 and 0 in January and 0.09 in February;
# months weighted equally give 0.055 (not 0.0433 pooled). A cell outside its training range (distance >
# 0) is left out. "short" misses February: incomplete, no score. "failed" never converged: reported
# incomplete, not dropped. With model 8 itself failed, the report still runs and its differences are NA.
base <- data.frame(month = c("jan", "jan", "feb", "feb"), x = c(-75, -70, -75, -100), y = c(41, 46, 41, 40),
                   km = c(50, 120, 50, 300), distance = c(0, 0, 0, 0.1), observed = 0.2, OL = 0.1, ET = 0.4,
                   own_direction = NA, status = "ok")
r <- rbind(transform(base, model = "mod8", predicted = c(0.4, 0.2, 0.5, 0.9), converged = TRUE),
           transform(base[1:2, ], model = "short", predicted = c(0.3, 0.3), converged = TRUE),
           transform(base, model = "failed", predicted = NA, converged = FALSE))
run_report <- function(r) {
  out <- file.path(tempfile(), "run")
  invisible(capture.output(inrange_report(out, r, models = c("mod8", "short", "failed"), months = c("jan", "feb"))))
  utils::read.csv(file.path(out, "output", "cross_validation", "inrange_scores.csv"))
}
ir <- run_report(r)
stopifnot(isTRUE(all.equal(ir$score[ir$model == "mod8"], 0.055)), ir$difference[ir$model == "mod8"] == 0,
          identical(ir$status, c("complete", "incomplete", "incomplete")), identical(ir$months_complete, c(2L, 1L, 0L)),
          all(is.na(ir$score[ir$model != "mod8"])))
ir8 <- run_report(transform(r, converged = ifelse(model == "mod8", FALSE, converged)))
stopifnot(ir8$status[ir8$model == "mod8"] == "incomplete", all(is.na(ir8$difference)))
# Every in-range fit failed: the report still runs, with every model incomplete and an empty region table.
irx <- run_report(transform(r, converged = FALSE, predicted = NA))
stopifnot(all(irx$status == "incomplete"), all(is.na(irx$score)))
# A month nobody predicted (no February rows at all) makes every model incomplete, not scored on January.
irj <- run_report(r[r$month == "jan", ])
stopifnot(all(irj$status == "incomplete"), all(irj$months_complete <= 1))
# A baseline that varies from row to row, with a constant paired difference: standard error 0.
e3 <- data.frame(block = c("A", "B", "C"), a = c(1.5, 2.5, 4.5), mod8 = c(1, 2, 4))
pb3 <- cv_paired_by_band(e3, data.frame(km_band = rep("x", 3)), c("a", "mod8"), "mod8", seed = 3, resamples = 100)
stopifnot(isTRUE(all.equal(pb3$difference[pb3$model == "a"], 0.5)), pb3$se_difference[pb3$model == "a"] < 1e-12)
# Weight shares, by hand (Fable): rows 1 and 2 in group g1 (weight 3), row 3 in g2 (weight 1); bands A, B, B.
# Row weights 1.5, 1.5, 1 of 4: band A 0.375, band B 0.625.
ws <- cv_weight_share(c("g1", "g1", "g2"), data.frame(group = c("g1", "g2"), weight = c(3, 1)), data.frame(km_band = c("A", "B", "B")))
stopifnot(isTRUE(all.equal(ws$score_weight_share[ws$km_band == "A"], 0.375)), isTRUE(all.equal(ws$score_weight_share[ws$km_band == "B"], 0.625)))
cat("test_cross_validation: all tests passed\n")
