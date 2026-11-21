# Trial only: the fit command with the two cheapest versions (straight-line cover with location 30
# and 100), so that a month of the large all-days and snow-free tables can be tried without the
# long fits. The tool itself always fits the six versions; nothing else differs.
#   Rscript fit_two_cheapest.R <run-dir> <output-dir> <month> [<month> ...]
suppressMessages(source('tools/explore_cover_contrasts.R'))
suppressPackageStartupMessages(library(mgcv))
CONTRAST_VERSIONS = c('loc30_linear', 'loc100_linear')
args = commandArgs(trailingOnly = TRUE)
fit_months(read_run(args[1]), args[2], check_months(args[-(1:2)]))
