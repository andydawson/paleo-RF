# Verification gate-fixes-script9: PASS

- verdict: **PASS**
- commit: ee42e9a445862dee9e103ed041b6e7aff4fef735
- spec: `docs/cc/verification/2026-11-21_gate-fixes-script9.R`
- started 2026-11-21 07:07:03 UTC, finished 2026-11-21 07:08:16 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/ee42e9a` at ee42e9a445862dee9e103ed041b6e7aff4fef735; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/gate-fixes-script9`; configuration `.rundirs/gate-fixes-script9/config_used.R` (from `configs/legacy_config.R`); 2 files copied in
- runner `tools/rscript.sh` with THREADS=1 CORES=0-7

## Scripts

- scripts/9_forcing_barplot.R: exit status 0, 0.7 min, run record `20261121T070719.306Z_3318049.md`, 4 outputs

## Anchors

- tests/anchors/interp-forcing-2026-10-08: every file MATCH
```
forcing_by_period.csv                            MATCH
forcing_by_period_egu2024recipe_vs_slide.csv     MATCH
forcing_by_period_variant_sensitivity.csv        MATCH
modern_ipcc_ar6_erf.csv                          MATCH
```

## Checks

- `tools/check_comments_only.R 65bb2a4da5aaec8fafb898288e9fb22603031c90`: exit status 0
- `-e 
previous = c(forcing_barplot_slide18.png = '619c4305724211bbd0bbbd3ef02d5411',
             forcing_barplot_slide18_egu2024recipe.png = '320b741cfb90638e8e4aaeaa3d24d582')
now = unname(tools::md5sum(file.path('.rundirs/gate-fixes-script9/figures', names(previous))))
print(data.frame(figure = names(previous), previous = unname(previous), now = now))
stopifnot(identical(now, unname(previous)))
cat('both PNG figures identical to the previous run
')
`: exit status 0

## Failures

- none
