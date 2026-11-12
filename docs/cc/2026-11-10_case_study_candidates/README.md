# Scripts and tables behind the case-study search of 10 November 2026

The report is `../2026-11-10_case_study_candidates.md`. It was written by a search agent (Fable) at Chris's
request and has not been reviewed. Everything here was read-only on the three finished pipeline runs
(`paleo-RF-verify/f05628d/.rundirs/cv-mod8`, `1d31cfc/.rundirs/cv2-winner`, `e82f399/.rundirs/cv-chosen`); paths
to them are written out in the scripts. Run from the repository root with `THREADS=1 tools/rscript.sh <script>`;
scripts `05` and `05b` rebuild a cache of about 470 MB that was not kept. The exploratory maps by period were
not kept either; `candidate_boxes.png` shows the boxes over the cells that have pollen data.

| File | What it holds |
|---|---|
| `candidates.csv`, `candidate_regions.csv` | The boxes, slices, cells, cover changes and the three runs' annual-mean albedo change |
| `candidate_monthly.csv` | The same by month |
| `candidate_expectation.csv` | The expected albedo change from straight mixing of published class albedos |
| `candidate_response_per_unit_cover.csv` | Each run's albedo response per unit of cover exchanged |
| `candidate_sensitivity.csv` | Each case with its box moved two degrees and its window one slice |
| `forcing_by_region.csv` | Vegetation forcing by region and period for the three runs |
| `candidate_judgements.csv` | The quality judgement for each case |
| `08_candidates_printed_output.txt` | The printed output of the main script |
