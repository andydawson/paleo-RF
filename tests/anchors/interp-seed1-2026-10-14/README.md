# Interp seeded draws anchor (seed 1), 2026-10-14

The outputs of scripts 5 and 6 that come from simulated draws, made with
`analysis$draws$seed = 1` and otherwise the default configuration (model 8,
100 draws each). Since issue I04a (#7) the draws can be seeded, so a change to the
code must reproduce these files **byte for byte** when run with seed 1. The unseeded
anchor `interp-allmonths-2026-09-20` stays the reference for the default
`seed = "random"`, within the tolerances in `../tolerances.tsv`.

Made by the I04a verification run `seed1a` on `i04a-settings` at commit e612b69 (clean
tree), with `tools/rscript.sh` (8 threads), in a run directory seeded with the frozen
calibration table, the frozen fits of script 4 and the frozen paleo land-cover table.
A second run with the same seed (`seed1b`) reproduced all 26 files byte for byte; the two
runs with `seed = "random"` differed from them in all 26. Manifests of the run:
`runs/5_calibration_eval/` and `runs/6_prediction_model/` of that run directory
(seed recorded as `{"setting":1,"base":1}`).

Only the checksums are kept (`MD5SUMS.txt`), and the small statistics table for reading:
the draws are 2.4 GB and can be remade with seed 1. Compare a run with
`Rscript tools/check_anchors.R tests/anchors/interp-seed1-2026-10-14 <run-dir>`.

| File | What |
|---|---|
| `calibration_model_stats.csv` | script 5: correlation, interval coverage and error quantiles per month |
| `paleo_interp_predict_gam_summary_bluesky.RDS` and the twelve `..._summary_<month>_...` | script 6: mean, sd and quantiles of the draws |
| the twelve `paleo_interp_predict_gam_samps_<month>_bluesky.RDS` | script 6: the draws themselves |

**Limit.** The draws are made around the model's predictions, which are bit-reproducible
only at 8 BLAS threads on this machine (regression contract, section 1). On another
machine or thread count, a seeded run reproduces these files only approximately.

**Regenerated 31 October 2026: `calibration_model_stats.csv` only** (Chris's decision 4 of
29 October, `docs/cc/2026-10-29_refit_plan_decisions.md`). Script 5's "data in credible
interval" now divides by the cells with an observation, not by every cell. The new file comes
from the verification run `docs/cc/verification/2026-10-31_refit-legacy-seed1-2` (seed 1, eight
threads, commit 83415db). Before it was accepted: the other 25 anchor files matched byte for
byte; the correlation and both error quantiles were unchanged in every month; and each month's
new coverage lay in the range computed beforehand from the old file as old x cells / observed
cells, allowing for both roundings (e.g. December 0.56 -> 0.91, range 0.902-0.928; January
0.71 -> 0.93, range 0.926-0.949). Old checksum 5e5d157561bdddbe0b6a0487d7ac16c8.
