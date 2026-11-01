# Tests for R/training_support.R. Run from the repository root: Rscript tests/test_training_support.R
suppressMessages(source("R/training_support.R"))

# The training range is May's fit: a run without May among its months has none, and the
# figures stop with a message saying so (finding 5 of the review of 1 November 2026),
# before any file is read.
winter_run <- list(cfg = list(analysis = list(months = c("dec", "jan", "feb", "mar"))))
msg <- tryCatch({ read_training_support_inputs(winter_run); "" }, error = conditionMessage)
stopifnot(grepl("has no May", msg), grepl("dec, jan, feb, mar", msg, fixed = TRUE))

# The rule, worked by hand (Fable's review of drift-fixes): training mixes at the three edge
# midpoints span the middle triangle. Pure open land lies outside it at sqrt(3)/4 (half the
# height of the unit triangle, to the middle of the opposite edge); the centroid is inside at
# 0; an edge midpoint lies on the hull and counts as inside; a mix that does not sum to one stops.
training <- data.frame(OL = c(0.5, 0, 0.5), ET = c(0.5, 0.5, 0), ST = c(0, 0.5, 0.5))
past     <- data.frame(OL = c(1, 1/3, 0.5), ET = c(0, 1/3, 0), ST = c(0, 1/3, 0.5))
support  <- training_support(past, training_hull(training))
stopifnot(identical(support$outside, c(TRUE, FALSE, FALSE)),
          isTRUE(all.equal(support$distance_outside, c(sqrt(3) / 4, 0, 0))),
          inherits(try(cover_triangle_xy(data.frame(OL = 0.5, ET = 0.2, ST = 0.2)), silent = TRUE), "try-error"))

# The shared inputs, on a stub run: May's fit, its hull, and May's cover rows only.
path_file  <- function(paths, id, month = NULL) id
read_input <- function(run, path) switch(path,
  calibration_prediction_fit = list(model = training),
  prediction_point = data.frame(month = c("may", "jun", "may"), year = c(500, 500, 1000), OL = 1/3, ET = 1/3, ST = 1/3))
inputs <- read_training_support_inputs(list(cfg = list(analysis = list(months = c("may", "jun"))), paths = NULL))
stopifnot(identical(inputs$fit$model, training), identical(inputs$hull, training_hull(training)),
          all(inputs$cover$month == "may"), identical(inputs$cover$year, c(500, 1000)))

cat("test_training_support: all tests passed\n")
