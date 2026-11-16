# In which direction do a candidate's past mixes leave the range of modern mixes? For each
# candidate end: the box's range of each class beside the modern range of that class over all
# calibration cells, and the share of cells below the modern minimum of open land.
source('./case_study_helpers.R')
a = read_cache(); cells = a$cells; ages = a$ages
modern = a$modern[!is.na(a$modern$may), ]
cat('modern calibration cells (May):', nrow(modern), '\n')
for (class in CLASSES) cat(sprintf('  modern %s: %.3f to %.3f (1st to 99th percentile %.3f to %.3f)\n', class, min(modern[[class]]), max(modern[[class]]), quantile(modern[[class]], 0.01), quantile(modern[[class]], 0.99)))
candidates = read.csv(file.path(OUT_DIR, 'candidates.csv'), stringsAsFactors = FALSE)
for (key in c('hemlock_decline', 'clearance_east', 'quebec_spruce', 'nw_canada_spruce', 'prairie_advance', 'alaska_greening', 'great_lakes_spruce_decline')) {
  candidate = candidates[candidates$key == key, ]; inside = in_box(cells, candidate)
  for (end in c('old', 'young')) {
    cover = a$cover[inside, slice_index(ages, candidate[[end]]), ]
    cat(sprintf('%-28s %5d BP: open land %.3f-%.3f, evergreen %.3f-%.3f, summergreen %.3f-%.3f; cells with less open land than any modern cell: %2.0f%%; with more summergreen than any modern cell: %2.0f%%\n',
                key, candidate[[end]], min(cover[, 'OL']), max(cover[, 'OL']), min(cover[, 'ET']), max(cover[, 'ET']), min(cover[, 'ST']), max(cover[, 'ST']),
                100 * mean(cover[, 'OL'] < min(modern$OL)), 100 * mean(cover[, 'ST'] > max(modern$ST))))
  }
}
