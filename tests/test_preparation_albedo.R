# Tests for cell_albedo_by_month() in R/preparation.R and for the MODIS cell table it reads
# (data/albedo_modis_cells.csv). Run from the repository root: Rscript tests/test_preparation_albedo.R
source("R/calendar.R")
source("R/preparation.R")
fails <- function(expr) inherits(try(expr, silent = TRUE), "try-error")
same <- function(a, b) isTRUE(all.equal(a, b, tolerance = 0))

# --- a toy table, expected values written by hand ------------------------------------------
# Cells A (-100.5, 40.5), B (-99.5, 40.5) and D (-97.5, 41.5); A has no January row, D is not
# a calibration cell. Two versions, each with its all-days, snow-free and snowy column; B's
# January has no snowy value in full_nocut.
toy <- data.frame(
  x     = c(-100.5, -99.5, -99.5, -97.5),
  y     = c(  40.5,  40.5,  40.5,  41.5),
  month = c( "feb",  "jan", "feb", "jan"),
  full_75             = c(0.30, 0.40, 0.35, 0.50),
  full_75_snowfree    = c(0.20, 0.25, 0.22, 0.45),
  full_75_snowy       = c(0.60, 0.70, 0.65, 0.80),
  full_nocut          = c(0.31, 0.42, 0.36, 0.51),
  full_nocut_snowfree = c(0.21, 0.26, 0.23, 0.46),
  full_nocut_snowy    = c(0.61,   NA, 0.66, 0.81))
# The calibration cells, in their own order: B, A, then C (-98.5, 40.5), which the table lacks.
predictors <- data.frame(x = c(-99.5, -100.5, -98.5), y = c(40.5, 40.5, 40.5), elev = c(100, 200, 300))

# Expected January and February columns (rows B, A, C); every other month is NA.
expected <- list(
  all_days  = list(full_75 = list(jan = c(0.40, NA, NA), feb = c(0.35, 0.30, NA)),
                   full_nocut = list(jan = c(0.42, NA, NA), feb = c(0.36, 0.31, NA))),
  snow_free = list(full_75 = list(jan = c(0.25, NA, NA), feb = c(0.22, 0.20, NA))),
  snowy     = list(full_75 = list(jan = c(0.70, NA, NA), feb = c(0.65, 0.60, NA)),
                   full_nocut = list(jan = c(NA_real_, NA, NA), feb = c(0.66, 0.61, NA))))

set.seed(20261029)
shuffled <- toy[sample(nrow(toy)), ]
stopifnot(!identical(shuffled$x, toy$x))   # the order really changed
for (statistic in names(expected)) for (version in names(expected[[statistic]])) {
  for (cells in list(toy, shuffled)) {
    got <- cell_albedo_by_month(cells, predictors, statistic, version)
    want <- expected[[statistic]][[version]]
    stopifnot(
      identical(names(got$albedo), MONTHS),
      nrow(got$albedo) == nrow(predictors),
      same(got$albedo$jan, want$jan),
      same(got$albedo$feb, want$feb),
      all(is.na(got$albedo[, setdiff(MONTHS, c("jan", "feb"))])),
      identical(got$predictors_without_cell, data.frame(x = -98.5, y = 40.5)),
      identical(got$cells_without_predictor, data.frame(x = -97.5, y = 41.5)))
  }
}

# What must stop, and what may pass.
with_value <- function(v) { t <- toy; t$full_75[2] <- v; t }
stops_with <- function(pattern, cells, statistic = "all_days", version = "full_75") {
  msg <- tryCatch({ cell_albedo_by_month(cells, predictors, statistic, version); "" }, error = conditionMessage)
  grepl(pattern, msg)
}
stopifnot(
  stops_with("appear more than once: -99.5 40.5 jan", rbind(toy, toy[2, ])),
  stops_with("not in \\[0, 1\\): -99.5 40.5 jan = 1", with_value(1)),
  stops_with("not in \\[0, 1\\)", with_value(-0.01)),
  stops_with("not in \\[0, 1\\)", with_value(Inf)),
  stops_with("not in \\[0, 1\\)", with_value(NaN)),
  stops_with("unknown month name\\(s\\) January", transform(toy, month = replace(month, 1, "January"))),
  stops_with("no column\\(s\\) full_75_snowy", toy[, setdiff(names(toy), "full_75_snowy")], statistic = "snowy"),
  stops_with("not numeric", transform(toy, full_75 = as.character(full_75))),
  stops_with("unknown statistic", toy, statistic = "snowless"),
  stops_with("unknown version", toy, version = "full_80"),
  # exactly 0 is allowed (script 2 floors it to 1e-4) and NA stays NA
  same(cell_albedo_by_month(with_value(0), predictors, "all_days", "full_75")$albedo$jan, c(0, NA, NA)),
  same(cell_albedo_by_month(with_value(NA), predictors, "all_days", "full_75")$albedo$jan, c(NA_real_, NA, NA)),
  # an invalid value in a column that is not selected does not matter
  same(cell_albedo_by_month(with_value(1), predictors, "snow_free", "full_75")$albedo$feb, c(0.22, 0.20, NA))
)

# --- the real cell table ---------------------------------------------------------------------
cells_file <- "data/albedo_modis_cells.csv"
if (!file.exists(cells_file)) {
  cat("test_preparation_albedo: ", cells_file, " absent; checks on the real table skipped\n", sep = "")
} else {
  cells <- read.csv(cells_file)
  # cell_table() in tools/prepare_bluesky_albedo.R stores albedos and shares rounded to 6
  # decimals, so identities between columns hold only to that rounding: at most 5e-7 on each of
  # the (up to) three albedos, three shares and the all-days value, i.e. below 2.5e-6.
  rounding <- 2.5e-6
  for (version in ALBEDO_VERSIONS) {
    col <- function(suffix) cells[[paste0(version, suffix)]]
    part <- function(p) list(value = col(paste0("_", p)), share = col(paste0("_share_", p)))
    all_days <- col("")
    present <- !is.na(all_days)
    # The mixing identity of climatology(): share_snowy x snowy + share_snowfree x snowfree +
    # share_unknown x unknown = all. A part with no days has no value (NA) and share 0.
    mixed <- 0
    for (p in c("snowy", "snowfree", "unknown")) {
      pt <- part(p)
      stopifnot(!anyNA(pt$share[present]), all(pt$share[present & is.na(pt$value)] == 0))
      mixed <- mixed + ifelse(is.na(pt$value), 0, pt$share * pt$value)
    }
    worst <- max(abs(mixed - all_days)[present])
    cat(sprintf("%s: mixing identity on %d cell-months, largest departure %.2g\n", version, sum(present), worst))
    stopifnot(worst < rounding)
    # Where every day was snow-free, the snow-free albedo is the all-days albedo.
    all_free <- present & col("_share_snowfree") == 1
    stopifnot(sum(all_free) > 1000, max(abs(col("_snowfree") - all_days)[all_free]) < rounding)
  }
  # The version columns are the versions they claim to be: wherever the 75-degree rule cannot
  # remove a day (May to August, when the noon sun is within 64 degrees of the zenith at 79 N;
  # and in any month in cells wholly south of 50 N, where even the December noon sun is within
  # 74 degrees), full_75 and full_nocut are the same in every column. (Equal day counts are not
  # enough: they are rounded to 0.01 days per land pixel, which can hide a few pixel-days.)
  sun_rule_inactive <- cells$month %in% c("may", "jun", "jul", "aug") | cells$y + 0.5 < 50
  for (suffix in c("", "_snowfree", "_snowy", "_unknown", "_share_snowfree", "_share_snowy",
                   "_share_unknown", "_years", "_coverage", "_days"))
    stopifnot(identical(cells[[paste0("full_75", suffix)]][sun_rule_inactive],
                        cells[[paste0("full_nocut", suffix)]][sun_rule_inactive]))
  stopifnot(sum(sun_rule_inactive) > 20000)

  # The whole table passes the function's checks for every choice.
  for (version in ALBEDO_VERSIONS) for (statistic in names(ALBEDO_STATISTICS))
    stopifnot(!fails(cell_albedo_by_month(cells, cells[cells$month == "jul", c("x", "y")], statistic, version)))

  # Against the modern calibration cells (script 1's table, a pipeline product, so only where
  # it has been made): the four centres the build has no land for and the ten 17.5 N centres
  # outside the modern table (Astra's plan and Fable's review, 29 October), and the join
  # against an independent merge().
  modern_file <- "data/lct_modern_reveals_interp.RDS"
  if (!file.exists(modern_file)) {
    cat("test_preparation_albedo: ", modern_file, " absent; the join with the modern cells skipped\n", sep = "")
  } else {
    modern <- readRDS(modern_file)
    got <- cell_albedo_by_month(cells, modern, "all_days", "full_75")
    no_cell <- got$predictors_without_cell
    stopifnot(
      nrow(modern) == 2860,
      setequal(paste(no_cell$x, no_cell$y), c("-114.5 61.5", "-112.5 62.5", "-112.5 63.5", "-132.5 69.5")),
      nrow(got$cells_without_predictor) == 10, all(got$cells_without_predictor$y == 17.5))
    for (statistic in c("all_days", "snow_free")) {
      got <- cell_albedo_by_month(cells, modern, statistic, "full_75")
      column <- paste0("full_75", ALBEDO_STATISTICS[[statistic]])
      for (month in MONTHS) {
        merged <- merge(data.frame(row = seq_len(nrow(modern)), x = modern$x, y = modern$y),
                        cells[cells$month == month, c("x", "y", column)], all.x = TRUE)
        stopifnot(same(got$albedo[[month]], merged[[column]][order(merged$row)]))
      }
    }
  }
}
cat("test_preparation_albedo: all tests passed\n")
