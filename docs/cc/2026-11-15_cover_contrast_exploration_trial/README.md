# Trial of the cover-contrast exploration, 15 November 2026, repeated on 16 November

What these files are and what they showed is in sections 6 and 10 of
`../2026-11-15_cover_contrast_exploration_implementation.md`. They are a trial of the tool on two months, with
cheap versions only. They are not the exploration's results.

On 16 November, after the changes asked for by Astra's review, the same six fit jobs and the report were run
again from commit `b0d1db7`, and the files whose evidence changed were replaced: the output, the fit logs and the
test log. The new checks' logs were added. Every contrast row is identical to that of 15 November
(`compare_with_first_trial.log`). The figure, the per-job tables and the saved fits (44 MB) are not kept here.

| File | What it is |
|---|---|
| `output/` | What the report command wrote from the six fit jobs: `cover_contrasts.csv` (its first lines explain the columns), `fits.csv` with the measured time of each fit, `published_guide.csv` (the published values set beside the model, with their classes, kind of albedo and qualification), and each job's record (commit and inputs) |
| `fit_*.log` | The three fit jobs' logs, with the time and peak memory of each job (16 November) |
| `fit_two_cheapest.R` | How the all-days and snow-free tables were tried with two versions only; the tool itself always fits six |
| `report.log` | The report command on the six jobs (16 November) |
| `check_inputs.log`, `check_exchanges.log`, `check_job.log` | `tools/check_cover_contrasts.R` on real data (16 November): the three inputs; protocol 2's frozen exchanges; the snowy July and August job, its files copied alone into a folder of their own as the verification spec's job leaves them, with its report |
| `compare_with_first_trial.R`, `.log` | The table of 16 November against that of 15 November, row by row |
| `check_unchanged_exchanges.R`, `.log` | 15 November: protocol 2's own northeast exchanges, rebuilt with the new helpers, against those frozen on 6 November (now also the `exchanges` check of the tool above) |
| `support_check.R`, `.log` | 15 November: the eligible cells of every table, month, region and exchange, with no fit, against Astra's independent count for the northeast |
| `support_all_tables_months.csv` | That table: what stands behind each number the full run would give, for all three albedo tables and twelve months |
| `check_one_contrast.R`, `.log` | 15 November: three rows of the trial table recomputed by plain code, and their standard errors checked by simulation |
| `check_areas_same.R`, `.log` | 15 November: the three runs give every cell the same area, cover and elevation (now also the `inputs` check) |
| `tests.log` | The ten test files of the verification spec, run in this worktree (16 November) |

The scripts of 15 November were run from the session's scratch folder, and the paths in them are as they were
then. The checks of 16 November take their inputs as arguments; the commands are at the top of each log.
