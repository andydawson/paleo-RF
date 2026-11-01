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

# The shipped slices: the older end is the next slice, 11,500 BP for the last pair, as
# before the slices were passed in.
default_ages <- c(50, 200, seq(500, 11500, by = 500))
f <- quietly(assign_forcing_periods(forcing_table(default_ages), coarse_ages, default_ages))
stopifnot(identical(f$age_old, default_ages[match(f$year, default_ages) + 1]),
          identical(max(f$age_old), 11500))

# Slices that stop at 10,000 BP (finding 7 of the review of 1 November 2026): the last pair
# is 8,000 to 10,000 BP, not 8,000 to 11,500 BP as the fixed 11,500 used to make it.
short_ages <- c(50, 2000, 4000, 6000, 8000, 10000)
f <- quietly(assign_forcing_periods(forcing_table(short_ages), coarse_ages, short_ages))
stopifnot(all(f$age_old[f$year == 8000] == 10000), !anyNA(f$age_old))

# A forcing row whose year is not the younger end of a configured pair is refused.
stopifnot(inherits(try(quietly(assign_forcing_periods(forcing_table(default_ages), coarse_ages, short_ages)),
                       silent = TRUE), "try-error"))

cat("test_forcing_periods: all tests passed\n")
