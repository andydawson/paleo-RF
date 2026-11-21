# Verification ice-legacy: PASS

- verdict: **PASS**
- commit: c0b6eda3573f0c8c4d8770d2b2494888cc433af7
- spec: `/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/ice_specs/2026-11-17_ice-legacy.R`
- started 2026-11-18 13:17:43 UTC, finished 2026-11-18 15:35:46 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/c0b6eda` at c0b6eda3573f0c8c4d8770d2b2494888cc433af7; 0 frozen inputs linked from the main checkout
- run folder `.rundirs/ice-legacy`; configuration `.rundirs/ice-legacy/config_used.R` (from `configs/legacy_config.R`); 1 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=8-15

## Scripts

- scripts/7_plot_preds.R: exit status 0, 80.1 min, run record `20261118T131756.797Z_1420683.md`, 4 outputs
- scripts/7a_alb_diff_full.R: exit status 0, 56.3 min, run record `20261118T143804.592Z_1465734.md`, 1 outputs
- scripts/8_radiative.R: exit status 0, 0.4 min, run record `20261118T153420.563Z_1502549.md`, 1 outputs
- scripts/9_forcing_barplot.R: exit status 0, 0.6 min, run record `20261118T153443.583Z_1502745.md`, 4 outputs
- scripts/10_forcing_breakdown.R: exit status 0, 0.3 min, run record `20261118T153518.072Z_1503022.md`, 1 outputs

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
