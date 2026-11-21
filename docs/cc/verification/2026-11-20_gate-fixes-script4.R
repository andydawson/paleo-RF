# Fixes after the integration review (branch gate-fixes), 2 of 2. Script 4 lost four values it never read; its
# fits must not change. The original analysis (configs/legacy_config.R) for January only: scripts 1, 2 and 4, then
# every January fit this run writes is compared, file by file, with the same file from the gate's full run of the
# code before the deletion (2026-11-20_gate-legacy-full, commit 9c8dea1): the MD5 sums must all be equal.
list(
  name     = 'gate-fixes-script4',
  commit   = '5cadb41affefe1db093bdd6e3906b60a9217f420',
  config   = 'configs/legacy_config.R',
  settings = list(analysis = list(months = 'jan')),
  scripts  = c('scripts/1_veg_lct_prep.R', 'scripts/2_calibration_lct_bluesky.R', 'scripts/4_calibration_model.R'),
  checks   = list(c('-e', "
gate  = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/9c8dea1/.rundirs/gate-legacy-full/output/calibration'
mine  = '.rundirs/gate-fixes-script4/output/calibration'
files = list.files(mine)
stopifnot(length(files) > 0, all(grepl('_jan_', files)))
same  = unname(tools::md5sum(file.path(mine, files))) == unname(tools::md5sum(file.path(gate, files)))
cat(sprintf('%d January fit files; %d byte-identical to the gate run at 9c8dea1\n', length(files), sum(same, na.rm = TRUE)))
stopifnot(!anyNA(same), all(same))
cat('all January fits identical\n')
")),
  rscript  = 'tools/rscript.sh',
  env      = c(THREADS = '8', CORES = '0-7'))
