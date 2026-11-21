# Verification gate-fixes-tail: PASS

- verdict: **PASS**
- commit: 5cadb41affefe1db093bdd6e3906b60a9217f420
- spec: `docs/cc/verification/2026-11-20_gate-fixes-tail.R`
- started 2026-11-20 17:25:53 UTC, finished 2026-11-20 20:24:20 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/5cadb41` at 5cadb41affefe1db093bdd6e3906b60a9217f420; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/gate-fixes-tail`; configuration `.rundirs/gate-fixes-tail/config_used.R` (from `configs/legacy_config.R`); 1 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=0-7

## Scripts

- scripts/7_plot_preds.R: exit status 0, 100.4 min, run record `20261120T172610.858Z_2954714.md`, 4 outputs
- scripts/7a_alb_diff_full.R: exit status 0, 75.9 min, run record `20261120T190635.121Z_3002850.md`, 1 outputs
- scripts/8_radiative.R: exit status 0, 0.5 min, run record `20261120T202231.866Z_3037877.md`, 1 outputs
- scripts/9_forcing_barplot.R: exit status 0, 0.7 min, run record `20261120T202300.482Z_3038056.md`, 4 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.3 min, run record `20261120T202343.920Z_3038554.md`, 1 outputs

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

- `tests/test_check_comments_only.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `tests/test_config.R`: exit status 0

## Failures

- none
