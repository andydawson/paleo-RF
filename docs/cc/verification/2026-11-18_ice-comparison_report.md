# Verification ice-comparison: PASS

- verdict: **PASS**
- commit: c0b6eda3573f0c8c4d8770d2b2494888cc433af7
- spec: `/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/ice_specs/2026-11-17_ice-comparison.R`
- started 2026-11-18 15:43:13 UTC, finished 2026-11-18 15:44:13 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/c0b6eda` at c0b6eda3573f0c8c4d8770d2b2494888cc433af7; 0 frozen inputs linked from the main checkout
- run folder `.rundirs/ice-comparison`; configuration `.rundirs/ice-comparison/config_used.R` (from `config.R`); 0 files copied in
- runner `tools/rscript.sh` with THREADS=8 CORES=40-47

## Scripts


## Anchors


## Checks

- `tools/compare_ice.R .rundirs/ice-comparison/meeting .rundirs/ice-old-replay .rundirs/ice-nadi1-optimal .rundirs/ice-nadi1-minimum .rundirs/ice-nadi1-maximum`: exit status 0 (log `check_01.log`)
- `tools/check_compare_ice.R .rundirs/ice-comparison/meeting .rundirs/ice-old-replay`: exit status 0 (log `check_02.log`)

## Failures

- none
