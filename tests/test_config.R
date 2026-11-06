# Tests for R/config.R and R/config_schema.R. Run from the repository root: Rscript tests/test_config.R
source("R/config.R")
cfg    <- load_config()
legacy <- load_config("configs/legacy_config.R")

# Loading the file is tested on text: config.R with one substitution (or the given text).
base_text <- readLines("config.R")
load_variant <- function(from = NULL, to = NULL, text = NULL) {
  if (is.null(text)) {
    stopifnot(sum(grepl(from, base_text, fixed = TRUE)) == 1)   # the edit hits exactly one line
    text <- sub(from, to, base_text, fixed = TRUE)
  }
  f <- tempfile(fileext = ".R"); writeLines(text, f); on.exit(unlink(f))
  load_config(f)
}
# TRUE if loading fails with a message matching `pattern`.
rejects <- function(pattern, ...) {
  msg <- tryCatch({ load_variant(...); "" }, error = conditionMessage)
  grepl(pattern, msg)
}

# The schema is tested on settings lists, checked by config_errors() as load_config() checks
# a file. with_setting() gives config.R's settings (or others) with one key set, named as in
# the messages; assigning list(value) through [ ] keeps a NULL value as a setting.
with_setting <- function(key, value, settings = cfg) {
  path <- strsplit(key, "$", fixed = TRUE)[[1]]
  settings[[path[-length(path)]]][path[length(path)]] <- list(value)
  settings
}
refuses <- function(pattern, settings) grepl(pattern, paste(config_errors(settings), collapse = "\n"))
accepts <- function(settings) !length(config_errors(settings))
coarse_ages <- cfg$analysis$coarse$ages

stopifnot(
  # the shipped config loads and holds today's script settings
  identical(names(cfg), c("analysis", "presentation", "run")),
  is.null(cfg$run$dir),
  "dir" %in% names(cfg$run),
  identical(cfg$analysis$coarse$ages, c(50, 500, 2000, 4000, 6000, 8000, 10000, 12000)),
  identical(cfg$analysis$forcing$earth_area_m2, 5.101e14),
  identical(cfg$analysis$forcing$latitude_band_width, 10),
  identical(cfg$presentation$map_windows$calibration, list(x = c(-172, -50), y = c(15, 80))),
  identical(cfg$presentation$map_windows$tail,        list(x = c(-166, -50), y = c(12, 82))),
  identical(cfg$presentation$map_windows$diagnostics, list(x = c(-172, -50), y = c(17, 79))),

  # the file is ordinary R (plain source() since issue I06): parse errors, a value that is
  # not a list, and anything the schema refuses are reported; the file cannot see the caller
  rejects("could not be read",            'earth_area_m2 = 5.101e14', 'earth_area_m2 = 5.101e14 +'),
  rejects("cfg must be a list",           text = c("x <- 1")),
  rejects("must be finite numbers",       'earth_area_m2 = 5.101e14', 'earth_area_m2 = "big"'),
  identical(load_variant('months = c("jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec")',
                         'months = tolower(month.abb)')$analysis$months, MONTHS),
  { secret_variable_of_the_caller <- 1
    rejects("could not be read", 'earth_area_m2 = 5.101e14', 'earth_area_m2 = secret_variable_of_the_caller') },
  # allowed constructors and arithmetic evaluate as R would
  identical(load_variant('ages = c(50, 500, 2000, 4000, 6000, 8000, 10000, 12000),',
                         'ages = c(50, seq(500, 2000, by = 1500), 2 * 2000, 6000, 8000, 10000, 12000),')$analysis$coarse$ages,
            cfg$analysis$coarse$ages),
  identical(load_variant('earth_area_m2 = 5.101e14', 'earth_area_m2 = 5.101 * 10^14')$analysis$forcing$earth_area_m2,
            5.101 * 10^14),

  # the schema: unknown, missing and duplicated keys
  refuses("analysis\\$forcing has unknown key\\(s\\) kernel", with_setting("analysis$forcing$kernel", "cam5")),
  refuses("analysis\\$forcing is missing key\\(s\\) variant", { s <- cfg; s$analysis$forcing$variant <- NULL; s }),
  refuses("has earth_area_m2 more than once", { s <- cfg; s$analysis$forcing <- c(s$analysis$forcing, list(earth_area_m2 = 1)); s }),
  refuses("analysis\\$domain must be a list", with_setting("analysis$domain", c(50, 500))),
  refuses("must be a value, not a list", with_setting("analysis$forcing$earth_area_m2", list(5.101e14))),
  # illegal values
  refuses("variant has 'veg_ice'; legal values", with_setting("analysis$forcing$variant", "veg_ice")),
  refuses("variant must be a single value", with_setting("analysis$forcing$variant", c("veg_thresh", "ice_thresh"))),
  refuses("report_kernels must not repeat", with_setting("analysis$forcing$report_kernels", c("hadgem", "cam5", "cam5"))),
  refuses("report_kernels must be text, not empty", with_setting("analysis$forcing$report_kernels", NULL)),   # c() is NULL
  refuses("ages must be strictly increasing", with_setting("analysis$coarse$ages", coarse_ages[c(1, 2, 4, 3, 5:8)])),
  refuses("ages must have at least 2 values", with_setting("analysis$coarse$ages", 50)),
  refuses("ages must be finite numbers", with_setting("analysis$coarse$ages", replace(coarse_ages, 4, NA))),
  refuses("ages must be finite numbers", with_setting("analysis$coarse$ages", replace(coarse_ages, 4, "4000"))),
  refuses("ages must not have names", with_setting("analysis$coarse$ages", setNames(coarse_ages, replace(character(8), 4, "mid")))),
  refuses("latitude_band_width must lie between 1 and 90", with_setting("analysis$forcing$latitude_band_width", 0)),
  refuses("latitude_band_width must be a whole number", with_setting("analysis$forcing$latitude_band_width", 2.5)),
  refuses("earth_area_m2 must have exactly 1 values", with_setting("analysis$forcing$earth_area_m2", c(1, 2))),
  refuses("tail\\$x must be strictly increasing", with_setting("presentation$map_windows$tail$x", c(-50, -166))),
  refuses("tail\\$y must lie between -90 and 90", with_setting("presentation$map_windows$tail$y", c(12, 95))),
  refuses("calibration\\$x must have exactly 2 values", with_setting("presentation$map_windows$calibration$x", -172)),
  # the run directory
  accepts(with_setting("run$dir", ".rundirs/median_test")),
  refuses("run\\$dir must not be inside the repository's output/", with_setting("run$dir", "output/alt")),
  refuses("run\\$dir must not contain '..'", with_setting("run$dir", "../elsewhere")),
  refuses("run\\$dir must be NULL or one directory path", with_setting("run$dir", c("a", "b"))),
  # the same places spelled absolutely or through a link are refused too (finding 1 of the
  # review of 1 November 2026): an absolute repository path once passed and wrote into the baseline
  refuses("run\\$dir must not be the repository itself", with_setting("run$dir", getwd())),
  refuses("run\\$dir must not be the repository itself", with_setting("run$dir", "./")),
  refuses("run\\$dir must not be inside the repository's output/", with_setting("run$dir", file.path(getwd(), "output/alt"))),
  refuses("run\\$dir must not be inside the repository's data/", with_setting("run$dir", "./data")),
  { link_to_repo <- file.path(tempfile(), "link_to_repo"); dir.create(dirname(link_to_repo))
    linked <- isTRUE(suppressWarnings(file.symlink(getwd(), link_to_repo)))   # FALSE where symlinks cannot be made: skipped
    ok <- !linked || refuses("run\\$dir must not be inside the repository's figures/", with_setting("run$dir", file.path(link_to_repo, "figures/alt")))
    unlink(link_to_repo); unlink(dirname(link_to_repo), recursive = TRUE); ok },   # the link first: never recurse into the repository
  accepts(with_setting("run$dir", file.path(tempdir(), "alt_run"))),
  refuses("run is missing key\\(s\\) dir", { s <- cfg; s$run$dir <- NULL; s }),
  # the model, draw and reduction settings (issue I04a)
  identical(cfg$analysis$land_cover$reduction, "mean"),
  identical(cfg$analysis$calibration$model_id, "mod8"),
  identical(cfg$analysis$draws, list(evaluation = 100, prediction = 100, seed = "random")),
  accepts(with_setting("analysis$land_cover$reduction", "median")),
  refuses("land_cover\\$reduction has 'trimmed'", with_setting("analysis$land_cover$reduction", "trimmed")),
  accepts(with_setting("analysis$calibration$model_id", "mod7")),
  accepts(with_setting("analysis$calibration$model_id", "mod8_small_cover")),
  refuses("model_id has 'spatial'", with_setting("analysis$calibration$model_id", "spatial")),
  refuses("model_id must be a single value", with_setting("analysis$calibration$model_id", c("mod7", "mod8"))),
  refuses("draws\\$evaluation must lie between 2", with_setting("analysis$draws$evaluation", 1)),
  refuses("draws\\$prediction must be a whole number", with_setting("analysis$draws$prediction", 100.5)),
  accepts(with_setting("analysis$draws$seed", 20261014)),
  accepts(with_setting("analysis$draws$seed", 0)),
  refuses("draws\\$seed must be \"random\" or one whole number", with_setting("analysis$draws$seed", "fixed")),
  refuses("draws\\$seed must be \"random\" or one whole number", with_setting("analysis$draws$seed", 1.5)),
  refuses("draws\\$seed must be \"random\" or one whole number", with_setting("analysis$draws$seed", 2^31)),
  # months, ages, slice alias, domain, ice and kernels (issue I04b)
  identical(cfg$analysis$months, MONTHS),
  identical(cfg$analysis$ages, c(50, 200, seq(500, 11500, by = 500))),
  identical(cfg$analysis$coarse$slice_alias, c(11500, 12000)),
  accepts(with_setting("analysis$months", c("feb", "may", "aug", "nov"))),
  refuses("months.*unknown month name", with_setting("analysis$months", c("jan", "January"))),
  refuses("months.*more than once", with_setting("analysis$months", c("jan", "jan"))),
  refuses("analysis\\$ages must be strictly increasing", with_setting("analysis$ages", c(200, 50))),
  accepts(with_setting("analysis$coarse$slice_alias", NULL)),
  refuses("slice_alias must have exactly 2 values", with_setting("analysis$coarse$slice_alias", 11500)),
  refuses("slice_alias: its first value must be one of analysis\\$ages", with_setting("analysis$coarse$slice_alias", c(11600, 12000))),
  refuses("slice_alias: its second value must be one of analysis\\$coarse\\$ages", with_setting("analysis$coarse$slice_alias", c(11500, 13000))),
  refuses("lat_min must be below lat_max", with_setting("analysis$domain$lat_max", 27, with_setting("analysis$domain$lat_min", 74))),
  refuses("lon_min must be west of lon_max_coarse", with_setting("analysis$domain$lon_min", -50)),
  refuses("domain\\$lat_max must lie between", with_setting("analysis$domain$lat_max", 95)),
  accepts(with_setting("analysis$ice$threshold", 0.6)),
  refuses("ice\\$threshold must lie between 0 and 1", with_setting("analysis$ice$threshold", 1.5)),
  accepts(with_setting("analysis$ice$albedo_coarse", "ice_albedo_sc")),
  refuses("albedo_fixed has 'albedo'", with_setting("analysis$ice$albedo_fixed", "albedo")),
  accepts(with_setting("analysis$kernels$cack_year", 2010)),
  refuses("cack_year must lie between 2001 and 2016", with_setting("analysis$kernels$cack_year", 2000)),
  refuses("cack_year must be a whole number", with_setting("analysis$kernels$cack_year", 2003.5)),
  # kernel variables and the difference method (issue I16); the legacy configuration loads
  identical(cfg$analysis$kernels[c("hadgem_variable", "cam5_variable", "cack_variable")],
            list(hadgem_variable = "albedo_sw", cam5_variable = "FSNT", cack_variable = "CACK CM")),
  identical(cfg$analysis$ice$difference_method, "endpoint"),
  refuses("hadgem_variable has 'FSNT'", with_setting("analysis$kernels$hadgem_variable", "FSNT")),
  refuses("cam5_variable has 'albedo_sw'", with_setting("analysis$kernels$cam5_variable", "albedo_sw")),
  refuses("difference_method has 'fancy'", with_setting("analysis$ice$difference_method", "fancy")),
  identical(legacy$analysis$kernels$cam5_variable, "FSNSC"),
  identical(legacy$analysis$draws$seed, 1),
  # the ladder's comparison method (issue I16): ML, the original REML in the legacy file
  identical(cfg$analysis$calibration$comparison_method, "ML"),
  identical(legacy$analysis$calibration$comparison_method, "REML"),
  refuses("comparison_method has 'GCV'", with_setting("analysis$calibration$comparison_method", "GCV")),
  identical(cfg$analysis$calibration$ice_mask, "centre_in_1ka_polygon"),
  identical(legacy$analysis$calibration$ice_mask, "none"),
  refuses("ice_mask has 'all'", with_setting("analysis$calibration$ice_mask", "all")),
  # the calibration albedo (Chris, 2026-10-29): the MODIS cell table in config.R, the raster
  # in the legacy file; with the raster, statistic and version must keep their defaults
  identical(cfg$analysis$albedo, list(source = "modis_cells", statistic = "all_days", version = "full_75")),
  identical(legacy$analysis$albedo, list(source = "legacy_raster", statistic = "all_days", version = "full_75")),
  accepts(with_setting("analysis$albedo$statistic", "snow_free")),
  accepts(with_setting("analysis$albedo$statistic", "snowy")),
  accepts(with_setting("analysis$albedo$version", "any_75")),
  accepts(with_setting("analysis$albedo$version", "full_70")),
  accepts(with_setting("analysis$albedo$version", "full_nocut")),
  accepts(with_setting("analysis$albedo$source", "legacy_raster")),
  refuses("albedo\\$source has 'raster'", with_setting("analysis$albedo$source", "raster")),
  refuses("albedo\\$statistic has 'snowless'", with_setting("analysis$albedo$statistic", "snowless")),
  refuses("albedo\\$statistic must be a single value", with_setting("analysis$albedo$statistic", c("all_days", "snowy"))),
  refuses("albedo\\$version has 'full_80'", with_setting("analysis$albedo$version", "full_80")),
  refuses("albedo is missing key\\(s\\) version", { s <- cfg; s$analysis$albedo$version <- NULL; s }),
  refuses('with source "legacy_raster".*statistic must be "all_days"', with_setting("analysis$albedo$statistic", "snow_free", legacy)),
  refuses('with source "legacy_raster".*version "full_75"', with_setting("analysis$albedo$version", "full_nocut", legacy)),
  refuses('with source "legacy_raster"',
          with_setting("analysis$albedo$statistic", "snowy", with_setting("analysis$albedo$source", "legacy_raster"))),
  # the stale-input override (issue I05): off by default, TRUE or FALSE only
  identical(cfg$run$allow_stale, FALSE),
  # script 1's diagnostic switch (issue I06)
  identical(cfg$run$diagnostic, FALSE),
  accepts(with_setting("run$diagnostic", TRUE)),
  refuses("run\\$diagnostic must be TRUE or FALSE", with_setting("run$diagnostic", "yes")),
  accepts(with_setting("run$allow_stale", TRUE)),
  refuses("run\\$allow_stale must be TRUE or FALSE", with_setting("run$allow_stale", 1)),
  refuses("run\\$allow_stale must be TRUE or FALSE", with_setting("run$allow_stale", c(TRUE, FALSE))),
  refuses("run\\$allow_stale must be TRUE or FALSE", with_setting("run$allow_stale", NA)),
  # the headline forcing (Chris, 2026-10-19): partial ice, the original all-or-nothing in
  # the legacy file; only the four totals are accepted, never a vegetation or ice part
  identical(cfg$analysis$forcing$variant, "veg_ice_parts"),
  identical(legacy$analysis$forcing$variant, "veg_ice_thresh"),
  accepts(with_setting("analysis$forcing$variant", "veg_icesc_thresh")),
  refuses("forcing\\$variant has 'veg_thresh'", with_setting("analysis$forcing$variant", "veg_thresh")),
  refuses("forcing\\$variant has 'ice_part'", with_setting("analysis$forcing$variant", "ice_part")),
  # unsupported combinations
  refuses("report_kernels must include hadgem", with_setting("analysis$forcing$report_kernels", c("cam5", "cack"))),
  # every problem is reported at once, not just the first
  refuses("variant has.*\n.*report_kernels must not repeat",
          with_setting("analysis$forcing$report_kernels", c("hadgem", "cam5", "cam5"), with_setting("analysis$forcing$variant", "nope")))
)

# JSON for the manifests: full precision, one-element vectors kept as arrays, names kept,
# and stable: reading the JSON back and writing it again gives the same text.
j <- config_json(cfg)
back <- jsonlite::fromJSON(j, simplifyVector = TRUE, simplifyDataFrame = FALSE, simplifyMatrix = FALSE)
named <- list(a = c(`11500` = 12000), b = "hadgem", c = 0.123456789012345, d = c(-172, -50))
jn <- config_json(named)
stopifnot(
  grepl('"earth_area_m2":[510100000000000]', j, fixed = TRUE),
  grepl('"variant":["veg_ice_parts"]', j, fixed = TRUE),
  identical(config_json(back), j),
  isTRUE(all.equal(back, cfg)),
  identical(jn, '{"a":{"11500":[12000]},"b":["hadgem"],"c":[0.123456789012345],"d":[-172,-50]}'),
  identical(config_json(jsonlite::fromJSON(jn, simplifyVector = TRUE)), jn)
)
# Which config file: config.R by default, or the one named with --config.
fails <- function(expr) inherits(try(expr, silent = TRUE), "try-error")
stopifnot(
  identical(config_path(character()), "config.R"),
  identical(config_path(c("--config", "configs/median.R")), "configs/median.R"),
  identical(config_path(c("--config=configs/median.R")), "configs/median.R"),
  identical(config_path(c("other", "--config", "a.R", "x")), "a.R"),
  fails(config_path(c("--config"))),
  fails(config_path(c("--config", "a.R", "--config=b.R")))
)
# A repository whose output/ is a link elsewhere: the run directory is refused in either
# spelling, at the link or at its target, and an unrelated folder is accepted.
local({
  repo <- file.path(tempfile("linked_repo_"), "repo"); storage <- file.path(dirname(repo), "storage")
  dir.create(repo, recursive = TRUE); dir.create(storage)
  if (!isTRUE(suppressWarnings(file.symlink(storage, file.path(repo, "output"))))) return(cat("linked output/: skipped (no symlinks here)\n"))
  old <- setwd(repo); on.exit({ setwd(old); unlink(dirname(repo), recursive = TRUE) })
  refused <- function(v) isTRUE(grepl("inside the repository's output/", check_run_dir(v)))
  stopifnot(refused("output/alt"), refused(file.path(storage, "alt")), is.null(check_run_dir("elsewhere")))
})

for (id in CV_MODELS) stopifnot(accepts(with_setting("analysis$calibration$model_id", id)))
cat("test_config: all tests passed\n")
