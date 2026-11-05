# Small count and coverage fixtures: no raw forest or albedo archive is read.
suppressPackageStartupMessages(library(terra))
source('R/northeast_forest_albedo.R')

cells = data.frame(x = c(-75.5, -74.5, -73.5), y = c(40.5, 44.5, 47.5), key = c('A', 'B', 'C'))
candidates = data.frame(id = c('e1', 'e2', 'e3', 'd1', 'd2'), tile = 'h11v04', pixel = 1:5,
  forest_class = c('ENF', 'ENF', 'ENF', 'DBF', 'DBF'),
  cell_key = c('A', 'A', 'B', 'B', NA_character_), in_domain = c(TRUE, TRUE, TRUE, TRUE, FALSE),
  wetland = c(FALSE, TRUE, NA, FALSE, NA))
pairs = data.frame(enf_id = c('e1', 'e2', 'e3'), dbf_id = c('d1', 'd1', 'd2'),
  cell_key = c('A', 'A', 'B'), distance_m = c(500, 1000, 2000), elevation_difference_m = c(0, 25, 50),
  wetland_stratum = c('neither', 'one', 'unknown'), reciprocal = c(TRUE, FALSE, TRUE),
  unflagged3 = c(TRUE, FALSE, NA))
losses = data.frame(bundle = 'main', forest_class = 'ENF', cell_key = c('A', 'A', 'B', NA),
  screen = 'boundary', n_before = c(4, 6, 20, 30), n_after = c(3, 5, 17, 26), n_lost = c(1, 1, 3, 4))
r = northeast_structural_coverage(list(main = candidates), list(main = pairs), cells, losses)
all = subset(r$structural_coverage, region == 'all')
south = subset(r$structural_coverage, region == '40-41N')
stopifnot(all$eligible_enf == 3, all$eligible_dbf == 1, all$matched_enf == 3,
  all$unique_dbf == 2, all$max_dbf_use == 2, all$cells_with_pairs == 2,
  all$cells_without_pairs == 1, all$eligible_enf_wetland == 1, all$eligible_enf_wetland_unknown == 1,
  subset(r$candidate_support, forest_class == 'DBF')$eligible_pixels == 1,
  south$eligible_dbf == 0, south$matched_enf == 2,
  south$unique_dbf == 1, nrow(r$cell_coverage) == 3,
  r$cell_coverage$matched_enf[r$cell_coverage$cell_key == 'C'] == 0,
  subset(r$screen_losses, region == 'all')$n_lost == 5,
  subset(r$screen_losses, region == 'outside_pipeline_support')$n_lost == 4,
  subset(r$wetland_coverage, region == 'all' & wetland_stratum == 'unknown')$pairs == 1,
  r$feasibility$review_required, r$feasibility$southern_review_required,
  identical(r$screen_losses_cell, losses))
# Partner losses close against the all-pairs cell table, including zero-pair cells.
enf = candidates[candidates$forest_class == 'ENF', ]
paired = northeast_screen(enf, list(partner_within_distance_and_elevation = enf$id %in% pairs$enf_id), 'main')
for (key in cells$key) {
  loss = paired$losses[paired$losses$cell_key == key, ]
  matched = r$cell_coverage$matched_enf[r$cell_coverage$cell_key == key]
  stopifnot(matched == sum(loss$n_after), matched + sum(loss$n_lost) == sum(loss$n_before))
}
subsets = northeast_pair_subsets(pairs, 'stricter')
stopifnot(identical(subsets$reciprocal$enf_id, c('e1', 'e3')),
  identical(subsets$unflagged3$enf_id, 'e1'), identical(subsets$reciprocal$dbf_id, c('d1', 'd2')))

# Exactly seven tenths and five days pass; zeros, missing counts and one day fewer do not.
s = northeast_count_eligibility(c(7, 7, 0, NA, 7), c(10, 11, 0, 10, 10),
  c(5, 5, 0, 5, 4), c(5, 5, 0, 5, 5), 'main', rep('A', 5))
stopifnot(identical(s$eligible, c(TRUE, FALSE, FALSE, FALSE, FALSE)))
# Three pairs survive the stricter cell-year rule; two pairs do not. Own-panel balance is separate.
s = northeast_count_eligibility(rep(20, 6), rep(25, 6), c(rep(14, 5), 8), rep(20, 6),
  'stricter', c(rep('A', 3), rep('B', 2), 'A'))
stopifnot(identical(s$before_cell, c(rep(TRUE, 5), FALSE)),
  identical(s$eligible, c(rep(TRUE, 3), rep(FALSE, 3))))
s = northeast_count_eligibility(c(3, 3, 2), c(6, 7, 4), c(3, 3, 2), c(3, 3, 2),
  'looser', rep('A', 3))
stopifnot(identical(s$eligible, c(TRUE, FALSE, FALSE)))
s = northeast_count_eligibility(rep(10, 5), rep(10, 5), c(8, 8, 8, 7, NA), rep(8, 5),
  'stricter', rep('A', 5))
stopifnot(identical(s$eligible, c(TRUE, TRUE, TRUE, FALSE, FALSE)))

# Real raster selection reads only named counts; changing sums cannot affect its result.
tmp = file.path(tempdir(), 'forest_coverage_counts.tif')
raster = rast(nrows = 1, ncols = 5, nlyrs = 4)
values(raster) = cbind(1:5, 0:4, rep(1, 5), rep(9999, 5))
names(raster) = c('full_75_n_all', 'full_75_n_free', 'full_75_n_snow', 'full_75_s_all')
writeRaster(raster, tmp, overwrite = TRUE)
counts_before = northeast_read_counts(tmp, c(1, 5), names(raster)[1:3])
values(raster[[4]]) = -12345
writeRaster(raster, tmp, overwrite = TRUE)
counts_after = northeast_read_counts(tmp, c(1, 5), names(raster)[1:3])
stopifnot(identical(counts_before, counts_after), identical(counts_before[[1]], c(1, 5)),
  inherits(try(northeast_read_counts(tmp, 1, 'full_75_s_all'), silent = TRUE), 'try-error'))
unlink(tmp)

# A complete synthetic monthly catalogue tests year accounting and panel selection cheaply.
monthly = expand.grid(tile = 'h11v04', year = 2001:2009, month = 1:12, stringsAsFactors = FALSE)
monthly$file = paste(monthly$year, monthly$month, sep = '-')
read_calls = 0L
count_reader = function(file, pixels, layers) {
  stopifnot(all(grepl('_n_(all|free|snow)$', layers)))
  read_calls <<- read_calls + 1L
  out = matrix(0, length(pixels), length(layers), dimnames = list(NULL, layers))
  if (startsWith(file, '2001-')) for (version in c('full_75', 'any_75', 'full_70')) {
    enf = pixels <= 3
    out[, paste0(version, '_n_all')] = ifelse(enf, 7, 10)
    out[, paste0(version, '_n_free')] = 5
    out[, paste0(version, '_n_snow')] = ifelse(enf, 2, 5)
  }
  as.data.frame(out)
}
fixed = pairs
retrieval = northeast_retrieval_coverage(list(main = pairs), list(main = candidates), cells, monthly,
                                         read_counts = count_reader)
all = subset(retrieval$retrieval_coverage,
  region == 'all' & wetland_stratum == 'all' & month == 1 & version == 'full_75')
stopifnot(identical(names(retrieval), 'retrieval_coverage'), identical(pairs, fixed), read_calls == 108,
  all$distinct_pairs[all$panel == 'all'] == 3,
  all$distinct_pairs[all$panel == 'free'] == 3,
  all$distinct_pairs[all$panel == 'snow'] == 0,
  all$years[all$panel == 'all'] == 1, all$years_present[all$panel == 'all'] == '2001',
  all$unique_dbf[all$panel == 'all'] == 2, all$pair_years[all$panel == 'all'] == 3,
  all(all$coverage == 'thin'),
  inherits(try(northeast_retrieval_coverage(list(main = pairs), list(main = candidates), cells,
    monthly[-1, ], read_counts = count_reader), silent = TRUE), 'try-error'))

# No candidates must still yield a reviewable failed-feasibility report, with zero cells explicit.
empty_candidates = list(main = candidates[FALSE, ])
empty_pairs = list(main = pairs[FALSE, ])
empty = northeast_structural_coverage(empty_candidates, empty_pairs, cells, losses[FALSE, ])
stopifnot(empty$feasibility$distinct_pairs == 0, empty$feasibility$review_required,
          all(empty$cell_coverage$matched_enf == 0), nrow(empty$dbf_reuse) == 0)
empty = northeast_retrieval_coverage(empty_pairs, empty_candidates, cells, monthly[FALSE, ],
  read_counts = function(...) stop('An empty pair table must never read retrievals'))
stopifnot(all(empty$retrieval_coverage$distinct_pairs == 0),
          all(empty$retrieval_coverage$coverage == 'thin'))
cat('Northeast forest coverage tests passed\n')
