# Compare two versions of a tabular artefact column by column, for artefacts that are not
# expected to be byte-identical (simulation summaries, script 5's statistics).
#
# Why: scripts 5 and 6 summarise unseeded simulate() draws, so two runs of the same code
# differ slightly. Byte comparison is meaningless there; what matters is whether the
# difference is within the run-to-run spread recorded in the regression contract. A single
# maximum is a weak test for per-cell Monte Carlo summaries (the largest of 839,232 noisy
# differences is large even when nothing is wrong), so four statistics are computed for
# every numeric column:
#   max_abs    largest absolute difference          (catches a few rows going badly wrong)
#   p999_abs   99.9th percentile of |difference|     (catches errors in more than 0.1% of rows)
#   mean_abs   mean |difference|                     (catches widespread extra noise)
#   abs_bias   |mean signed difference|              (catches a systematic shift)
# Identifier columns (anything not double) must match exactly and in the same order.
#
# Usage:
#   Rscript tools/compare_tables.R <reference> <candidate> [tolerances.tsv] [artefact]
#     reference, candidate: .csv or .RDS (a data frame)
#     tolerances.tsv: columns artefact, column, statistic, tolerance; rows for <artefact>
#                     apply (artefact defaults to the reference file's base name)
#   Without a tolerance file it only reports. Exit status 1 if the structure differs, NA
#   patterns differ, or any statistic exceeds its tolerance.

STATS <- c("max_abs", "p999_abs", "mean_abs", "abs_bias")

read_table <- function(path) {
  if (grepl("\\.csv$", path, ignore.case = TRUE)) utils::read.csv(path, check.names = FALSE)
  else readRDS(path)
}

difference_stats <- function(a, b) {
  d <- a - b
  d <- d[!is.na(d)]
  if (!length(d)) return(stats::setNames(rep(0, 4), STATS))
  c(max_abs = max(abs(d)), p999_abs = unname(stats::quantile(abs(d), 0.999)),
    mean_abs = mean(abs(d)), abs_bias = abs(mean(d)))
}

# tol: data frame with columns column, statistic, tolerance (may be NULL)
compare_tables <- function(ref, cand, tol = NULL) {
  stopifnot(is.data.frame(ref), is.data.frame(cand))
  problems <- character()
  if (!identical(dim(ref), dim(cand))) problems <- c(problems, sprintf("dimensions differ: %s vs %s",
      paste(dim(ref), collapse = "x"), paste(dim(cand), collapse = "x")))
  if (!identical(names(ref), names(cand))) problems <- c(problems, "column names or order differ")
  if (length(problems)) return(list(ok = FALSE, problems = problems, columns = NULL))
  rows <- lapply(names(ref), function(col) {
    a <- unname(ref[[col]]); b <- unname(cand[[col]])
    if (is.double(a) && is.double(b)) {
      na_same <- identical(is.na(a), is.na(b))
      st <- difference_stats(a, b)
      out <- data.frame(column = col, kind = "numeric", statistic = STATS, value = unname(st),
                        tolerance = NA_real_, ok = na_same)
      if (!is.null(tol)) for (i in seq_len(nrow(tol))) if (tol$column[i] == col) {
        k <- match(tol$statistic[i], STATS)
        if (is.na(k)) stop("unknown statistic in tolerance file: ", tol$statistic[i])
        out$tolerance[k] <- tol$tolerance[i]
        out$ok[k] <- na_same && out$value[k] <= tol$tolerance[i]
      }
      out
    } else {
      same <- identical(a, b)
      data.frame(column = col, kind = "identifier", statistic = "identical", value = as.numeric(!same),
                 tolerance = NA_real_, ok = same)
    }
  })
  columns <- do.call(rbind, rows)
  list(ok = all(columns$ok), problems = character(), columns = columns)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) < 2) stop("usage: Rscript tools/compare_tables.R <reference> <candidate> [tolerances.tsv] [artefact]")
  artefact <- if (length(args) >= 4) args[4] else basename(args[1])
  tol <- NULL
  if (length(args) >= 3 && nzchar(args[3])) {
    t <- utils::read.delim(args[3], comment.char = "#")
    tol <- t[t$artefact == artefact, c("column", "statistic", "tolerance")]
    if (!nrow(tol)) stop("no tolerances for artefact ", artefact, " in ", args[3])
  }
  res <- compare_tables(read_table(args[1]), read_table(args[2]), tol)
  if (length(res$problems)) cat(paste("STRUCTURE:", res$problems), sep = "\n")
  else {
    show <- res$columns
    if (!is.null(tol)) show <- show[show$kind == "identifier" | !is.na(show$tolerance) | !show$ok, ]
    print(show, row.names = FALSE, digits = 3)
  }
  cat(if (res$ok) "RESULT: within tolerance\n" else "RESULT: OUTSIDE tolerance or structure differs\n")
  quit(status = if (res$ok) 0 else 1)
}
