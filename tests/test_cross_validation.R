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

# Convergence: the loop stopped before its limit and the optimiser fully converged.
ok <- list(iter = 37L, control = list(maxit = 500), outer.info = list(conv = "full convergence"))
stopifnot(fit_converged(ok), !fit_converged(modifyList(ok, list(iter = 500L))),
          !fit_converged(modifyList(ok, list(outer.info = list(conv = "step failed")))))

# Distances: one degree of longitude at 45 degrees north is about 78.6 km; a cell is (to rounding) 0 km from itself.
stopifnot(abs(nearest_km(-70, 45, c(-71, -60), c(45, 45)) - 78.6) < 0.1, nearest_km(-70, 45, -70, 45) < 0.001)
cat("test_cross_validation: all tests passed\n")
