# Trial 2 against the committed trial of 15 November: the same rows and numbers? Arguments: the two
# cover_contrasts.csv files (first trial, this trial).
args = commandArgs(TRUE)
a = read.csv(args[1], comment.char = '#'); b = read.csv(args[2], comment.char = '#')
key = function(d) paste(d$table, d$month, d$version, d$region, d$exchange)
b = b[match(key(a), key(b)), ]
cat(sprintf('rows: first %d, this %d, same keys %s\n', nrow(a), nrow(b), identical(key(a), key(b))))
for (column in setdiff(names(a), c('contrast', 'se', 'spread'))) cat(sprintf('%-15s identical: %s\n', column, isTRUE(all.equal(a[[column]], b[[column]], check.attributes = FALSE, tolerance = 0))))
for (column in c('contrast', 'se', 'spread')) cat(sprintf('%-15s largest absolute difference: %.3g\n', column, max(abs(a[[column]] - b[[column]]), na.rm = TRUE)))
