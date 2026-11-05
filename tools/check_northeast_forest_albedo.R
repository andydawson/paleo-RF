# Coverage only: freeze forest pairs before reading retrieval counts; never read albedo sums.
# Run from the repository root with THREADS=1 OPENBLAS_NUM_THREADS=1 tools/rscript.sh
# tools/check_northeast_forest_albedo.R [--config path/to/config.R].
library(terra)
source('R/run_manifest.R')
source('R/modis_albedo_helpers.R')
source('R/northeast_forest_albedo.R')

# Frozen 3 November settings. These bundles are joint stress tests, never fallbacks.
# Raw inputs are shared read-only: the project has no shared-input-root setting.
SHARED_DATA = '/home/expert/Documents/contracting/Andria/paleo-RF/data'
TILES = c('h11v04', 'h12v04', 'h13v04')
YEARS = 2001:2009
BUNDLES = data.frame(bundle = c('main', 'stricter', 'looser'),
                     width = c(3L, 5L, 3L), neighbour_years = c(9L, 9L, 7L),
                     water_width = c(3L, 5L, 1L), elevation_m = c(50, 25, 100),
                     relief_m = c(100, 50, 200), distance_m = c(5000, 3000, 10000))

run = run_begin('check_northeast_forest_albedo')
cfg = run$cfg
paths = run$paths
out_dir = under_root(paths, 'output/northeast_forest_albedo')
run_dir = under_root(paths, 'runs/check_northeast_forest_albedo')
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(run_dir, recursive = TRUE, showWarnings = FALSE)
temp_dir = file.path(out_dir, 'temporary')
dir.create(temp_dir, showWarnings = FALSE)
terraOptions(memmax = 0.25, memfrac = 0.1, parallel = FALSE, tempdir = temp_dir, progress = 0)

# These are the pipeline's own cell centres, not a rectangular replacement grid.
cells = read_input(run, path_file(paths, 'elevation_cache'))[, c('x', 'y')]
cells = unique(cells[cells$x >= -80 & cells$x < -66 & cells$y >= 40 & cells$y < 48, ])
cells = cells[order(cells$y, cells$x), ]
cells$key = paste(cells$x, cells$y)
stopifnot(nrow(cells) == 83L, all(cells$x %% 1 == 0.5), all(cells$y %% 1 == 0.5))

inputs = northeast_inputs(SHARED_DATA, TILES, YEARS)
template = northeast_check_grids(inputs, TILES)
monthly_metadata = northeast_monthly_metadata(inputs$monthly$file)
write_output(run, monthly_metadata, file.path(run_dir, 'monthly_builds.csv'), write.csv, row.names = FALSE)
run_record(run, 'selection', list(bundles = BUNDLES, years = YEARS, tiles = TILES,
                                 land_rule = 'land', land_period = '2000-03 through 2009-12',
                                 retrieval = northeast_retrieval_settings()))
selection = northeast_candidates(inputs, cells, BUNDLES, TILES, YEARS, template)
candidates = selection$candidates
losses = selection$losses
land = northeast_land(candidates, inputs$monthly)
for (bundle in BUNDLES$bundle) {
  x = candidates[[bundle]]
  screen = northeast_screen(x, list(record_wide_land = land$land[match(x$id, land$id)]), bundle)
  candidates[[bundle]] = x[screen$keep, ]
  losses = rbind(losses, screen$losses)
}

# Geographic pairs are fixed across every month, version and snow panel.
pairs = setNames(lapply(seq_len(nrow(BUNDLES)), function(i) {
  northeast_pairs(candidates[[BUNDLES$bundle[i]]], BUNDLES[i, ])
}), BUNDLES$bundle)
pair_file = file.path(out_dir, 'fixed_pairs.rds')
write_output(run, pairs, pair_file, northeast_freeze_pairs)
pair_md5 = unname(tools::md5sum(pair_file))
run_record(run, 'fixed_pair_md5', pair_md5)
write_output(run, candidates, file.path(out_dir, 'eligible_candidates.rds'))
for (bundle in names(pairs)) {
  write_output(run, pairs[[bundle]], file.path(out_dir, paste0('pairs_', bundle, '.csv')), write.csv, row.names = FALSE)
  write_output(run, candidates[[bundle]], file.path(out_dir, paste0('candidates_', bundle, '.csv')), write.csv, row.names = FALSE)
  enf = candidates[[bundle]][candidates[[bundle]]$forest_class == 'ENF', ]
  paired = northeast_screen(enf, list(partner_within_distance_and_elevation = enf$id %in% pairs[[bundle]]$enf_id), bundle)
  losses = rbind(losses, paired$losses)
}

reports = northeast_structural_coverage(candidates, pairs, cells, losses)
northeast_write_tables(run, reports, out_dir)
# GeoTIFF count bands can be selected independently: no s_all/s_free/s_snow read.
retrieval = northeast_retrieval_coverage(pairs, candidates, cells, inputs$monthly)
northeast_write_tables(run, retrieval, out_dir)
stopifnot(identical(readRDS(pair_file), pairs), identical(unname(tools::md5sum(pair_file)), pair_md5))

# Paths, sizes and modification times identify inputs without scanning albedo payloads.
# The native GMTED component files are listed explicitly; its grid is never moved.
files = c(inputs$land_cover$file, inputs$acquisition, inputs$monthly$file, inputs$water,
          list.files(inputs$dem, full.names = TRUE), path_file(paths, 'elevation_cache'))
info = file.info(files)
write_output(run, data.frame(file = files, bytes = info$size, modified = as.character(info$mtime)),
             file.path(run_dir, 'inputs.csv'), write.csv, row.names = FALSE)
code = c('tools/check_northeast_forest_albedo.R', 'R/northeast_forest_albedo.R',
         'R/modis_albedo_helpers.R', config_path(),
         'docs/cc/2026-11-03_northeast_forest_albedo_settings.md')
write_output(run, data.frame(file = code, md5 = unname(tools::md5sum(code))),
             file.path(run_dir, 'code.csv'), write.csv, row.names = FALSE)
write_output(run, BUNDLES, file.path(run_dir, 'structural_settings.csv'), write.csv, row.names = FALSE)
write_output(run, northeast_retrieval_settings(), file.path(run_dir, 'retrieval_settings.csv'), write.csv, row.names = FALSE)
run_record(run, 'session', capture.output(sessionInfo()))
write_output(run, c('Coverage only. No albedo values or sums have been read.',
             paste('Fixed pair table MD5:', pair_md5),
             'Send feasibility.csv and the coverage tables to Chris before starting stage 2.'),
             file.path(out_dir, 'coverage_notes.txt'), writeLines)
print(reports$feasibility)
run_finish(run)
message('Coverage written to ', out_dir, '. Stop here for Chris to review before stage 2.')
