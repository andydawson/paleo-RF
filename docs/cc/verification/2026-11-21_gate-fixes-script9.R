# Fixes after the integration review (branch gate-fixes), the two tidy-ups from Fable's review that Chris chose on
# 21 November 2026. 65bb2a4 drops the 'panel' column nothing reads from scripts/9_forcing_barplot.R; ee42e9a
# rewords the header comment of R/run_manifest.R. Script 9 runs alone from the legacy configuration, seeded with
# the baseline products it reads (the per-cell forcing from script 8 and the coarse differences from script 7, both
# byte-identical to the tail anchor), and its four tables must match the forcing anchor byte for byte. Its two PNG
# figures, which draw the three changed tables, must keep the checksums of the previous run of this branch
# (gate-fixes-tail at 5cadb41; the same in the earlier legacy runs at 6c86770 and 4e8532c). The PDFs are not
# compared: they differ between every run. ee42e9a must be comments only against 65bb2a4.
list(
  name    = 'gate-fixes-script9',
  commit  = 'ee42e9a445862dee9e103ed041b6e7aff4fef735',
  config  = 'configs/legacy_config.R',
  seed    = c('forcing', 'coarse_differences'),
  scripts = c('scripts/9_forcing_barplot.R'),
  anchors = 'tests/anchors/interp-forcing-2026-10-08',
  checks  = list(c('tools/check_comments_only.R', '65bb2a4da5aaec8fafb898288e9fb22603031c90'),
                 c('-e', "
previous = c(forcing_barplot_slide18.png = '619c4305724211bbd0bbbd3ef02d5411',
             forcing_barplot_slide18_egu2024recipe.png = '320b741cfb90638e8e4aaeaa3d24d582')
now = unname(tools::md5sum(file.path('.rundirs/gate-fixes-script9/figures', names(previous))))
print(data.frame(figure = names(previous), previous = unname(previous), now = now))
stopifnot(identical(now, unname(previous)))
cat('both PNG figures identical to the previous run\n')
")),
  rscript = 'tools/rscript.sh',
  env     = c(THREADS = '1', CORES = '0-7'))
