# Verification gate-legacy-tail: PASS

- verdict: **PASS**
- commit: 6c867703fe7f76b1ddea5a6cfc8b01b1660f7325
- spec: `docs/cc/verification/2026-11-20_gate-legacy-tail.R`
- started 2026-11-20 17:11:12 UTC, finished 2026-11-20 19:29:08 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/6c86770` at 6c867703fe7f76b1ddea5a6cfc8b01b1660f7325; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/gate-legacy-tail`; configuration `.rundirs/gate-legacy-tail/config_used.R` (from `configs/legacy_config.R`); 1 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=16-23

## Scripts

- scripts/7_plot_preds.R: exit status 0, 77.2 min, run record `20261120T171128.967Z_2941792.md`, 4 outputs
- scripts/7a_alb_diff_full.R: exit status 0, 58.9 min, run record `20261120T182838.652Z_2986513.md`, 1 outputs
- scripts/8_radiative.R: exit status 0, 0.4 min, run record `20261120T192735.105Z_3011549.md`, 1 outputs
- scripts/9_forcing_barplot.R: exit status 0, 0.6 min, run record `20261120T192800.379Z_3011730.md`, 4 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.3 min, run record `20261120T192838.349Z_3012060.md`, 1 outputs

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
