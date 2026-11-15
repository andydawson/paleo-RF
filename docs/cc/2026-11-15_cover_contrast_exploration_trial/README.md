# Trial of the cover-contrast exploration, 15 November 2026

What these files are and what they showed is in section 6 of
`../2026-11-15_cover_contrast_exploration_implementation.md`. They are a trial of the tool on two months, with
cheap versions only. They are not the exploration's results.

| File | What it is |
|---|---|
| `output/` | What the report command wrote from the six fit jobs: `cover_contrasts.csv` (its first lines explain the columns), `fits.csv` with the measured time of each fit, `published_guide.csv`, and each job's record (commit and inputs). The figure and the per-job tables, which the stacked table repeats, are not kept |
| `fit_*.log` | The three fit jobs' logs, with the time of each job |
| `fit_two_cheapest.R` | How the all-days and snow-free tables were tried with two versions only; the tool itself always fits six |
| `check_unchanged_exchanges.R`, `.log` | Protocol 2's own northeast exchanges, rebuilt with the new helpers, against those frozen on 6 November |
| `support_check.R`, `.log` | The eligible cells of every table, month, region and exchange, with no fit, against Astra's independent count for the northeast |
| `support_all_tables_months.csv` | That table: what stands behind each number the full run would give, for all three albedo tables and twelve months |
| `check_one_contrast.R`, `.log` | Three rows of the trial table recomputed by plain code, and their standard errors checked by simulation |
| `check_areas_same.R`, `.log` | The three runs give every cell the same area, cover and elevation |
| `tests.log` | The eight test files of the verification spec, run in this worktree |

The scripts were run from the session's scratch folder, and the paths in them are as they were then.
