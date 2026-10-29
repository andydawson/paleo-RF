# Preparation of the land-cover tables (script 1) and of the calibration table (script 2).
#
# Why: script 1 reduced the 200 posterior draws of land cover to their mean, with Andria's
# note "not sure if should use median" (question A1). The summary is now a setting
# (config.R, analysis$land_cover$reduction), and the reduction a function with a stated
# contract, so the median can be run without editing the script.
# Issue I08 adds the other preparation steps of scripts 1 to 3 here.

# One value per cell, slice and land-cover class from the posterior draws, as one row per
# cell and slice with a column per class (cell_id, x, y, ages, ET, OL, ST).
#   "mean"   the mean of the draws: the original reduction, kept exactly as it was. Each
#            draw's fractions sum to 1, so their means do too; they are not rescaled,
#            which would change the last bit of sums such as 1.0000000000000002.
#   "median" the median of the draws, then rescaled so ET + OL + ST = 1 in every cell
#            and slice (the medians of the three classes need not sum to 1).
reduce_land_cover = function(posts, method = c('mean', 'median')) {
  method = match.arg(method)
  per_class = posts %>%
    dplyr::group_by(cell_id, x, y, ages, LCT)
  per_class = if (method == 'mean') {
    dplyr::summarize(per_class, value = mean(value), .groups = 'drop_last')
  } else {
    dplyr::summarize(per_class, value = stats::median(value), .groups = 'drop_last')
  }
  wide = tidyr::pivot_wider(per_class,
                            id_cols = c('cell_id', 'x', 'y', 'ages'),
                            names_from = c('LCT'),
                            values_from = c('value'))
  wide = data.frame(wide)
  if (method == 'median') wide = close_fractions(wide)
  wide
}

# Rescale the class fractions of each row to sum to 1. Stops, naming the cells and slices,
# if any fraction is missing or negative or a row's total is not positive, rather than
# making up a land cover.
close_fractions = function(wide, classes = c('ET', 'OL', 'ST')) {
  fractions = as.matrix(wide[, classes])
  total = rowSums(fractions)
  unusable_rows = !is.finite(total) | total <= 0 | apply(!is.finite(fractions) | fractions < 0, 1, any)
  if (any(unusable_rows)) {
    where = paste0('cell ', wide$cell_id[unusable_rows], ' at ', wide$ages[unusable_rows], ' BP')
    stop(sprintf('close_fractions: cannot rescale the land cover of %d cell-slice(s) to sum to 1 (a fraction missing or negative, or all zero): %s%s',
                 sum(unusable_rows), paste(head(where, 10), collapse = '; '), if (sum(unusable_rows) > 10) '; ...' else ''),
         call. = FALSE)
  }
  wide[, classes] = fractions / total
  wide
}

# Which points lie inside any of the polygons: TRUE or FALSE for each (x, y), in longitude and
# latitude (WGS84). Used by script 2 to find the modern calibration cells whose centre is
# under the 1 ka ice polygons: present-day ice caps, which the interpolation gave vegetation
# fractions (question B8). polygons is an sp or sf object, or a terra SpatVector;
# the glacier shapes carry no coordinate system, so one without is taken to be WGS84.
cells_in_polygons = function(x, y, polygons) {
  if (!inherits(polygons, 'SpatVector')) polygons = terra::vect(polygons)
  if (terra::crs(polygons) == '') terra::crs(polygons) = 'EPSG:4326'
  points = terra::vect(cbind(x, y), crs = 'EPSG:4326')
  inside = terra::relate(points, polygons, 'intersects')   # one row per point, one column per polygon
  rowSums(inside) > 0
}

# Check that the land-cover fractions are usable as compositions: finite, not negative, and
# ET + OL + ST = 1 in every cell and slice (within tolerance). Stops with the offending count
# if not; otherwise returns a summary for the run manifest. Why: the calibration smooth
# s(OL, ET, ST) is fitted on the sheet where the three sum to one and is unconstrained off
# it, so a row off the sheet would be predicted by extrapolation (question B1; Chris chose
# a check rather than a correction, 2026-10-14).
check_fractions = function(wide, tolerance = 1e-9) {
  fractions = as.matrix(wide[, c('ET', 'OL', 'ST')])
  off_sheet = abs(rowSums(fractions) - 1)
  problems = c(not_finite = sum(!is.finite(fractions)),
               negative   = sum(fractions < 0, na.rm = TRUE),
               off_sheet  = sum(off_sheet > tolerance, na.rm = TRUE))
  if (any(problems > 0)) {
    stop('check_fractions: land-cover fractions unusable (', paste(names(problems), problems, sep = ' = ', collapse = ', '),
         ' of ', nrow(fractions), ' rows; tolerance ', tolerance, ')')
  }
  list(rows = nrow(fractions), largest_departure_from_one = max(off_sheet), tolerance = tolerance)
}

# The rebuilt MODIS albedo (data/albedo_modis_cells.csv, made by tools/prepare_bluesky_albedo.R)
# offers, for each cell and month, four versions of the build (VERSION: which retrievals and which
# noon sun angles count) and, within each, the albedo over all days and over the snow-free and the
# snowy days alone. A version names its columns VERSION (all days), VERSION_snowfree and
# VERSION_snowy. config.R chooses one version and one statistic (analysis$albedo; Chris,
# 2026-10-29); the schema takes its legal values from here.
ALBEDO_VERSIONS   = c('full_75', 'any_75', 'full_70', 'full_nocut')
ALBEDO_STATISTICS = c(all_days = '', snow_free = '_snowfree', snowy = '_snowy')   # statistic = column suffix

# The monthly albedo of each modern calibration cell from the MODIS cell table, for script 2.
#   cells       the cell table as read from the CSV: one row per cell centre (x, y) and month
#   predictors  the modern land-cover table (x, y, ...), one row per calibration cell
#   statistic   "all_days", "snow_free" or "snowy"; version: one of ALBEDO_VERSIONS
# Returns a list:
#   albedo                   a table with columns jan ... dec, one row per row of `predictors`,
#                            in their order: the selected column's value at that cell centre
#   predictors_without_cell  centres (x, y) of `predictors` that the cell table does not have
#   cells_without_predictor  centres of the cell table that `predictors` does not have
# Rows are matched on the exact cell centre, paste(x, y), as script 1 matches elevation, so a
# centre that differs in any digit is reported unmatched, never moved to a neighbour. A cell
# missing a month, or with no value in the selected column, gets NA for that month: nothing is
# filled, and the cell still counts in the other months (each month is fitted on its own rows).
# Stops, naming the offending entries, if a column is missing, a cell has a month twice, a month
# name is unknown, or a selected value is not a number in [0, 1): the beta model of script 4
# needs albedo strictly below 1, and an exact 0 is allowed because script 2 floors it to 1e-4,
# as it always has.
cell_albedo_by_month = function(cells, predictors, statistic, version) {
  if (!statistic %in% names(ALBEDO_STATISTICS)) stop('cell_albedo_by_month: unknown statistic ', statistic)
  if (!version %in% ALBEDO_VERSIONS) stop('cell_albedo_by_month: unknown version ', version)
  column = paste0(version, ALBEDO_STATISTICS[[statistic]])
  absent_columns = setdiff(c('x', 'y', 'month', column), names(cells))
  if (length(absent_columns)) stop('cell_albedo_by_month: the cell table has no column(s) ', paste(absent_columns, collapse = ', '))

  centre = paste(cells$x, cells$y)
  cell_month = paste(centre, cells$month)
  named = function(entries) paste0(paste(head(entries, 10), collapse = '; '), if (length(entries) > 10) '; ...' else '')
  repeated = unique(cell_month[duplicated(cell_month)])
  if (length(repeated)) stop(sprintf('cell_albedo_by_month: %d cell-month(s) appear more than once: %s', length(repeated), named(repeated)))
  unknown_months = setdiff(unique(cells$month), MONTHS)
  if (length(unknown_months)) stop('cell_albedo_by_month: unknown month name(s) ', named(unknown_months))
  value = cells[[column]]
  if (!is.numeric(value)) stop('cell_albedo_by_month: column ', column, ' is not numeric')
  unusable = is.nan(value) | (!is.na(value) & !(is.finite(value) & value >= 0 & value < 1))
  if (any(unusable)) stop(sprintf('cell_albedo_by_month: %d value(s) of %s are not in [0, 1): %s', sum(unusable), column,
                                  named(paste0(cell_month[unusable], ' = ', value[unusable]))))

  predictor_centre = paste(predictors$x, predictors$y)
  albedo = data.frame(matrix(NA_real_, nrow = nrow(predictors), ncol = length(MONTHS)))
  colnames(albedo) = MONTHS
  for (month in MONTHS) {
    in_month = cells$month == month
    albedo[[month]] = value[in_month][match(predictor_centre, centre[in_month])]
  }
  centres = function(rows) data.frame(x = rows$x, y = rows$y)   # plain rows, for the run manifest
  list(albedo = albedo,
       predictors_without_cell = centres(predictors[!predictor_centre %in% centre, ]),
       cells_without_predictor = centres(unique(cells[!centre %in% predictor_centre, c('x', 'y')])))
}
