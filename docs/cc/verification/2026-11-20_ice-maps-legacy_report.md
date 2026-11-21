# Verification ice-maps-legacy: PASS

- verdict: **PASS**
- commit: 4e8532c91893c496ea5d0633c169b899ceeac7b4
- spec: `docs/cc/verification/2026-11-20_ice-maps-legacy.R`
- started 2026-11-20 09:40:36 UTC, finished 2026-11-20 11:48:20 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/4e8532c` at 4e8532c91893c496ea5d0633c169b899ceeac7b4; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/ice-maps-legacy`; configuration `.rundirs/ice-maps-legacy/config_used.R` (from `configs/legacy_config.R`); 1 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=8-15

## Scripts

- scripts/7_plot_preds.R: exit status 0, 72.6 min, run record `20261120T094054.620Z_2606837.md`, 4 outputs
- scripts/7a_alb_diff_full.R: exit status 0, 53.4 min, run record `20261120T105330.472Z_2649440.md`, 1 outputs
- scripts/8_radiative.R: exit status 0, 0.4 min, run record `20261120T114655.896Z_2724924.md`, 1 outputs
- scripts/9_forcing_barplot.R: exit status 0, 0.6 min, run record `20261120T114718.676Z_2725896.md`, 4 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.3 min, run record `20261120T114752.680Z_2727106.md`, 1 outputs

## Anchors

- tests/anchors/interp-tail-2026-09-21: every file MATCH
```
ALB_diffs_bluesky.RDS                            MATCH
alb_interp_preds_diffs_bluesky.RDS               MATCH
ice_fort_diff_old.RDS                            MATCH
ice_fort_diff_young.RDS                          MATCH
ice_fort.RDS                                     MATCH
RF_holocene_all_cases.RDS                        MATCH
```
- tests/anchors/interp-forcing-2026-10-08: every file MATCH
```
forcing_by_period.csv                            MATCH
forcing_by_period_egu2024recipe_vs_slide.csv     MATCH
forcing_by_period_variant_sensitivity.csv        MATCH
modern_ipcc_ar6_erf.csv                          MATCH
```

## Checks


## Failures

- none
