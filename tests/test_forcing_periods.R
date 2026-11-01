# Tests for assign_forcing_periods() in R/forcing_periods.R (scripts 9 and 10). Run from the
# repository root: Rscript tests/test_forcing_periods.R
suppressMessages(library(dplyr))
source("R/calendar.R")
source("R/forcing_periods.R")
quietly <- function(expr) { invisible(capture.output(value <- expr)); value }

# A forcing table as script 8 writes it: one row per cell, month and pair of consecutive
# configured slices, `year` the younger end.
forcing_table <- function(slice_ages) {
  expand.grid(year = head(slice_ages, -1), cell_id = c("A", "B"), month = c("jan", "feb"),
              stringsAsFactors = FALSE)
}
coarse_ages <- c(50, 500, 2000, 4000, 6000, 8000, 10000, 12000)
# Pairs per period, and the period and older end of one pair (its first row).
pairs_per_period <- function(f) as.vector(table(unique(f[, c("year", "period")])$period))
pair_of <- function(f, year) { row <- f[f$year == year, ][1, ]; list(as.character(row$period), row$age_old) }

# The shipped slices: the older end is the next slice, 11,500 BP for the last pair, as
# before the slices were passed in.
default_ages <- c(50, 200, seq(500, 11500, by = 500))
f <- quietly(assign_forcing_periods(forcing_table(default_ages), coarse_ages, default_ages))
stopifnot(nrow(f) == 24 * 4,                                   # 24 pairs x 2 cells x 2 months, all kept
          identical(pairs_per_period(f), c(2L, 3L, 4L, 4L, 4L, 4L, 3L)),
          identical(f$age_old, default_ages[match(f$year, default_ages) + 1]),
          identical(pair_of(f, 200), list("0.05 - 0.5 ka", 500)),
          identical(pair_of(f, 11000), list("10 - 12 ka", 11500)))   # the terminal pair

# Slices that stop at 10,000 BP (finding 7 of the review of 1 November 2026): the last pair
# is 8,000 to 10,000 BP, not 8,000 to 11,500 BP as the fixed 11,500 used to make it.
short_ages <- c(50, 2000, 4000, 6000, 8000, 10000)
f <- quietly(assign_forcing_periods(forcing_table(short_ages), coarse_ages, short_ages))
stopifnot(nrow(f) == 5 * 4,                                    # 5 pairs x 2 cells x 2 months, all kept
          identical(pairs_per_period(f), c(1L, 0L, 1L, 1L, 1L, 1L, 0L)),
          identical(pair_of(f, 50), list("0.05 - 0.5 ka", 2000)),
          identical(pair_of(f, 8000), list("8 - 10 ka", 10000)),     # the terminal pair
          !anyNA(f$age_old))

# A forcing row whose year is not the younger end of a configured pair is refused.
stopifnot(inherits(try(quietly(assign_forcing_periods(forcing_table(default_ages), coarse_ages, short_ages)),
                       silent = TRUE), "try-error"))

cat("test_forcing_periods: all tests passed\n")
