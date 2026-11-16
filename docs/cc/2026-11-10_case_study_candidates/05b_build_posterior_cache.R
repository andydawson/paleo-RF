# The reconstruction's own uncertainty: the 200 posterior draws of land cover that the
# pipeline's script 1 reduces to their mean (data/veg_posts_interp_ice.RDS in the worktree),
# rearranged as an array by cell, slice, class and draw for the study-area cells.
#
# Also checks two things the later use depends on:
#   1. the mean of the draws is the cover the runs used;
#   2. whether a draw is a draw of the whole map (its departures from the mean are then
#      correlated between neighbouring cells), or cell-by-cell noise. A box mean taken draw by
#      draw has the right spread only in the first case.
source('./case_study_helpers.R')
a = read_cache(); cells = a$cells; ages = a$ages
posts = readRDS(file.path(WORKTREE, 'data/veg_posts_interp_ice.RDS'))
draws = sort(unique(posts$iter))
i_cell = match(cell_key(posts$x, posts$y), cells$id)
keep = !is.na(i_cell)
posterior = array(NA_real_, c(nrow(cells), length(ages), 3, length(draws)), list(cells$id, ages, CLASSES, draws))
posterior[cbind(i_cell[keep], match(posts$ages[keep], ages), match(posts$LCT[keep], CLASSES), match(posts$iter[keep], draws))] = posts$value[keep]
stopifnot(!anyNA(posterior))
cat('draws:', length(draws), '\n')
cat('1. largest difference between the mean of the draws and the cover the runs used:', max(abs(apply(posterior, 1:3, mean) - a$cover)), '\n')
cat('   each draw sums to one: largest departure', max(abs(apply(posterior, c(1, 2, 4), sum) - 1)), '\n')

# The "ice" flag of the posterior file by cell and slice, beside the runs' ice fraction.
flag = unique(posts[keep, c('x', 'y', 'ages', 'ice')])
iced = array(FALSE, dim(a$ice), dimnames(a$ice))
iced[cbind(match(cell_key(flag$x, flag$y), cells$id), match(flag$ages, ages))] = !is.na(flag$ice)
cat('   cells flagged ICE in the posterior file, by slice:\n'); print(colSums(iced))
cat('   of those, share with the runs\' ice fraction above 0.5:', round(mean(a$ice[iced] > 0.5), 3), '; unflagged cells with ice fraction above 0.5:', sum(a$ice[!iced] > 0.5), '\n')

# 2. Correlation of the draws' departures between a cell and its eastern neighbour, at 6000 BP.
slice = slice_index(ages, 6000)
east = match(cell_key(cells$x + 1, cells$y), cells$id)
pairs = which(!is.na(east))
for (class in CLASSES) {
  departure = posterior[, slice, class, ] - rowMeans(posterior[, slice, class, ])
  r = sapply(pairs, function(i) cor(departure[i, ], departure[east[i], ]))
  cat(sprintf('2. %s at 6000 BP: correlation of the draws between neighbouring cells: median %.2f (5th to 95th percentile %.2f to %.2f)\n', class, median(r), quantile(r, 0.05), quantile(r, 0.95)))
}
# Are the draws of two different slices related (the same draw number in both)?
departure_a = posterior[, slice_index(ages, 6000), 'ET', ] - rowMeans(posterior[, slice_index(ages, 6000), 'ET', ])
departure_b = posterior[, slice_index(ages, 5500), 'ET', ] - rowMeans(posterior[, slice_index(ages, 5500), 'ET', ])
r = sapply(seq_len(nrow(cells)), function(i) cor(departure_a[i, ], departure_b[i, ]))
cat(sprintf('   ET, the same draw number at 6000 and 5500 BP: correlation median %.2f (5th to 95th percentile %.2f to %.2f)\n', median(r), quantile(r, 0.05), quantile(r, 0.95)))
cat('   posterior standard deviation of a cell\'s cover at 6000 BP, median over cells: ', paste(CLASSES, round(apply(apply(posterior[, slice, , ], 1:2, sd), 2, median), 3), collapse = '  '), '\n')
saveRDS(posterior, file.path(CACHE, 'posterior.RDS'), compress = FALSE)
