# Checks run for the review of 10 November 2026

Scripts and outputs behind `../2026-11-10_cv_protocol_v2_results_review_fable.md`. All are read-only on the
verification folders (`paleo-RF-verify/`); none changes a run folder or the repository's code. Run from the
repository root with `THREADS=1 tools/rscript.sh <script>`; paths to the run folders are written out in each.

| Script | What it does | New fits |
|---|---|---|
| `recompute_selection.R` | Recomputes the selection score from the saved predictions with separate code; by month, distance, direction; sensitivity of the choice | none |
| `bootstrap_check.R` | Independent block bootstrap of the paired differences; each block's share; contrast helper against plain `predict()` | none |
| `alaska_check.R` | The score without the dominant Alaskan blocks | none |
| `final_checks.R` | Share of each past slice outside the modern range; paired differences among the location-500 versions | none |
| `northeast_by_month.R` | The protocol's two northeast exchanges for all twelve months from the three pipelines' saved fits | none |
| `northeast_snow_states.R` | The same from model 8's saved snow-free (run 2) and snowy (run 7) fits | none |
| `winner_by_snow_state.R` | **Exploratory:** the chosen model's formula fitted to the all-days, snow-free and snowy tables | 34 |
| `rival_by_snow_state.R` | **Exploratory:** location 500 with straight-line cover fitted to the all-days and snow-free tables, one month per process | 24 |

The exploratory fits are outside protocol 2 and were not saved; only the tables were. Results that are to be used
must be redone through the usual route (Astra writes, reviews, `tools/verify_change.R`).
