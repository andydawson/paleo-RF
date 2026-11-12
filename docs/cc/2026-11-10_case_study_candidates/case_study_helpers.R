# Shared definitions for the case-study search (scratch analysis, read-only on the project).
#
# Why one file: every script here must mean the same cells, the same slices, the same signs
# and the same weights, or the candidates' numbers would not be comparable with each other.
#
# SIGNS used everywhere in these scripts:
#   a change is the YOUNGER slice minus the OLDER slice (change through time, forwards);
#   an albedo change is positive when the surface gets BRIGHTER;
#   a forcing is positive when it WARMS (the surface got darker), as in the pipeline.

WORKTREE = '/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2'
OUT_DIR  = '.'
CACHE    = file.path(OUT_DIR, 'cache')

# The three finished pipeline runs, by the model each used (R/model_registry.R of the
# worktree): model 8 is the original; the chosen model has a location term of 100 basis
# functions and cover as straight lines; the coarse-location model is model 8 with a
# location term of 30 basis functions.
RUNS = c(mod8            = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/f05628d/.rundirs/cv-mod8',
         loc100_linear   = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-winner',
         mod8_coarse_loc = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/e82f399/.rundirs/cv-chosen')
RUN_LABELS = c(mod8 = 'model 8 (original)', loc100_linear = 'chosen model', mod8_coarse_loc = 'coarse-location model')

MONTHS  = c('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec')
CLASSES = c('OL', 'ET', 'ST')   # open land, evergreen, summergreen
KERNELS = c('hadgem', 'cam5', 'cack')

cell_key = function(x, y) paste(x, y)

# The cached arrays of 05_build_cache.R: one list, see that script for what each holds.
read_cache = function() readRDS(file.path(CACHE, 'arrays.RDS'))

# Cells of a longitude-latitude box, by the rule of R/regions.R: the west and south edges
# belong to the box, the east and north edges do not.
in_box = function(cells, box) {
  cells$x >= box$lon_min & cells$x < box$lon_max & cells$y >= box$lat_min & cells$y < box$lat_max
}

# Area-weighted mean over cells; `weights` may be zero for cells left out.
weighted_mean = function(values, weights) {
  keep = !is.na(values) & weights > 0
  if (!any(keep)) return(NA_real_)
  sum(values[keep] * weights[keep]) / sum(weights[keep])
}

slice_index = function(ages, age) {
  index = match(age, ages)
  if (anyNA(index)) stop('not a slice of the reconstruction: ', paste(age[is.na(index)], collapse = ', '))
  index
}

# A change vector of the three cover fractions sums to zero. It is a clean exchange between
# two classes when the third hardly moves: 1 when the smallest of the three absolute changes
# is zero, 0 when two classes change by the same amount in the same direction (the third
# giving or taking all of it).
exchange_purity = function(d_ol, d_et, d_st) {
  d = cbind(abs(d_ol), abs(d_et), abs(d_st))
  largest = apply(d, 1, max)
  ifelse(largest > 0, 1 - 2 * apply(d, 1, min) / largest, NA_real_)
}

# The kind of exchange in words: which class lost most and which gained most.
exchange_label = function(d_ol, d_et, d_st) {
  d = cbind(OL = d_ol, ET = d_et, ST = d_st)
  names_long = c(OL = 'open land', ET = 'evergreen', ST = 'summergreen')
  paste(names_long[colnames(d)[apply(d, 1, which.min)]], 'to', names_long[colnames(d)[apply(d, 1, which.max)]])
}
