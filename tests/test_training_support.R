# Tests for R/training_support.R. Run from the repository root: Rscript tests/test_training_support.R
suppressMessages(source("R/training_support.R"))

# The training range is May's fit: a run without May among its months has none, and the
# figures stop with a message saying so (finding 5 of the review of 1 November 2026),
# before any file is read.
winter_run <- list(cfg = list(analysis = list(months = c("dec", "jan", "feb", "mar"))))
msg <- tryCatch({ read_training_support_inputs(winter_run); "" }, error = conditionMessage)
stopifnot(grepl("has no May", msg), grepl("dec, jan, feb, mar", msg, fixed = TRUE))

cat("test_training_support: all tests passed\n")
