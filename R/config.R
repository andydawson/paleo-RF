# Load and check the project configuration, config.R at the repository root.
#
# Usage, in any script:
#   source('R/config.R')
#   cfg = load_config()          # config.R, or the file given with --config <file>
#   cfg$analysis$forcing$variant
#
# config.R is an ordinary R file whose value is one list of settings. It is run with
# source() in a fresh environment, so it cannot see or change a script's variables, and
# the list it returns is checked against the schema in R/config_schema.R: unknown or
# missing keys and illegal values stop the script with a message naming every problem.
# Each run manifest records the settings as evaluated. (Until 2026-10-14 the file was read
# by a restricted parser that allowed only list(), c(), seq() and literal values; Chris
# replaced it with plain source() for readability.)

source('R/config_schema.R')

# Check a value against a schema node; returns messages, each prefixed with the key path.
config_schema_errors = function(value, schema, path = 'cfg') {
  if (is.function(schema)) {
    if (is.list(value)) return(sprintf('%s must be a value, not a list', path))
    msg = schema(value)
    return(if (is.null(msg)) character() else sprintf('%s %s', path, msg))
  }
  if (!is.list(value) || (length(value) && (is.null(names(value)) || any(!nzchar(names(value))))))
    return(sprintf('%s must be a list with a name on every entry', path))
  errs = character()
  duplicate_keys = unique(names(value)[duplicated(names(value))])
  if (length(duplicate_keys)) errs = c(errs, sprintf('%s has %s more than once', path, paste(duplicate_keys, collapse = ', ')))
  unknown = setdiff(names(value), names(schema))
  if (length(unknown)) errs = c(errs, sprintf('%s has unknown key(s) %s', path, paste(unknown, collapse = ', ')))
  missing = setdiff(names(schema), names(value))
  if (length(missing)) errs = c(errs, sprintf('%s is missing key(s) %s', path, paste(missing, collapse = ', ')))
  for (key in intersect(names(schema), names(value)))
    errs = c(errs, config_schema_errors(value[[key]], schema[[key]], paste0(path, '$', key)))
  errs
}

# Add to saved settings those they lack by name, from `historical` (HISTORICAL_SETTINGS, or a
# group of it): what the pipeline did before each setting existed. A setting that is given, even
# as NULL or with an illegal value, is left for the checks; a missing group is made from its
# historical settings. Each addition goes after the entries the schema puts before it, so that the
# result is identical() to the same settings written out in full. Returns the settings and the
# values filled, named by their paths.
fill_missing_settings = function(settings, schema, historical, path = 'cfg') {
  filled = list()
  if (!is.list(settings)) return(list(settings = settings, filled = filled))   # malformed: the checks report it
  for (key in names(historical)) {
    where = paste0(path, '$', key)
    is_group = is.list(schema[[key]])
    if (!key %in% names(settings)) {
      value = if (is_group) list() else historical[[key]]
      earlier = names(schema)[seq_len(match(key, names(schema)) - 1)]
      settings = append(settings, setNames(list(value), key), after = max(0, which(names(settings) %in% earlier)))
      if (!is_group) filled[where] = list(value)
    }
    if (is_group) {
      inner = fill_missing_settings(settings[[key]], schema[[key]], historical[[key]], where)
      settings[key] = list(inner$settings)
      filled = c(filled, inner$filled)
    }
  }
  list(settings = settings, filled = filled)
}

# The one warning for settings filled in a saved file, none if nothing was filled; shown at once,
# as a tool's long run would otherwise print it only at its end. `file` names the file ("config
# file <path>"); `filled` is the list of values fill_missing_settings() filled.
warn_filled = function(file, filled)
  if (length(filled))
    warning(file, ' was saved before some settings existed; filled with what the pipeline did before:\n  ',
            paste(names(filled), '=', vapply(filled, deparse1, ''), collapse = '\n  '), call. = FALSE, immediate. = TRUE)

# Which config file this run uses: config.R, unless the script was started with
# `--config <file>` (or `--config=<file>`), e.g.
#   Rscript scripts/6_prediction_model.R --config configs/median.R
# An alternative run is then described completely by one file (its settings and its run
# directory), which can be committed like config.R, and runs with different config files
# can go side by side from one checkout.
config_path = function(args = commandArgs(trailingOnly = TRUE)) {
  config_arg_index = which(args == '--config' | startsWith(args, '--config='))
  if (!length(config_arg_index)) return('config.R')
  if (length(config_arg_index) > 1) stop('--config given more than once', call. = FALSE)
  if (args[config_arg_index] != '--config') return(sub('^--config=', '', args[config_arg_index]))
  if (config_arg_index == length(args)) stop('--config needs a file name', call. = FALSE)
  args[config_arg_index + 1]
}

# Tools that read finished runs take --fill-missing anywhere on their command line (see
# load_config()). Returns the tool's other arguments and whether the flag was given.
tool_command_line = function(args = commandArgs(trailingOnly = TRUE))
  list(args = args[args != '--fill-missing'], fill_missing = '--fill-missing' %in% args)

# Read, check and return the configuration as a list with sections analysis,
# presentation and run. Stops with every problem found.
#
# fill_missing = TRUE is for reading a finished run: a configuration saved before a setting
# existed lacks it, and is given what the pipeline did before (HISTORICAL_SETTINGS in
# R/config_schema.R), with one warning that lists the values filled; everything is then checked
# as usual. Tools that read finished runs ask for it with --fill-missing on the command line.
# The pipeline itself always reads a complete configuration (the default, FALSE).
load_config = function(path = config_path(), fill_missing = FALSE) {
  if (!file.exists(path)) stop('config file not found: ', path, call. = FALSE)
  cfg = tryCatch(source(path, local = new.env(parent = baseenv()))$value,
                 error = function(e) stop('config file ', path, ' could not be read: ', conditionMessage(e), call. = FALSE))
  filled = list()
  if (fill_missing) {
    completed = fill_missing_settings(cfg, CONFIG_SCHEMA, HISTORICAL_SETTINGS)
    cfg = completed$settings
    filled = completed$filled
  }
  errs = config_errors(cfg)
  if (length(errs)) {
    hint = if (any(grepl('is missing key(s)', errs, fixed = TRUE))) paste0(
      '\nA pipeline run needs every setting in its configuration file: add those missing. A tool reading a',
      '\nfinished run saved before a setting existed can fill it with what the pipeline did before, if',
      '\nHISTORICAL_SETTINGS (R/config_schema.R) has it: load_config(path, fill_missing = TRUE) from R,',
      '\nor --fill-missing on the command line.') else ''
    stop('config file ', path, ':\n  ', paste(errs, collapse = '\n  '), hint, call. = FALSE)
  }
  warn_filled(paste('config file', path), filled)
  cfg
}

# Every problem with a settings list: each key against the schema, then, once those pass,
# the rules across keys. Empty if the settings are acceptable.
config_errors = function(cfg) {
  errs = config_schema_errors(cfg, CONFIG_SCHEMA)
  if (!length(errs)) errs = config_combination_errors(cfg)
  errs
}

# The configuration as one JSON string, for run manifests. Every number at full
# precision (jsonlite's default rounds to 4 significant digits); every vector, even of
# length one, as an array, so a one-element setting reads back as what it is; a named
# vector as an object, because jsonlite would otherwise drop the names without a word.
config_json = function(cfg) {
  keep_names = function(x) {
    if (is.list(x)) return(lapply(x, keep_names))
    if (is.atomic(x) && !is.null(names(x))) return(as.list(x))
    x
  }
  as.character(jsonlite::toJSON(keep_names(cfg), digits = NA, auto_unbox = FALSE, null = 'null'))
}
