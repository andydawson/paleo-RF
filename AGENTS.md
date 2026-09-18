# Notes for agent sessions

Read `CONTRIBUTING.md` for the version-control protocol before making changes.
Summary: trunk is `chris-dev`; one topic branch per task off it, merged back
when done; never touch `legacy` (frozen snapshot of the original code) or
`main`; commit each atomic change with a why-focused message; push to
`origin` at checkpoints and session end; `main` changes only via a PR that
Andria approves.

`docs/cc/2026-09-16_code_map_original_scripts.md` gives a high-level description of every script and its data
inputs/outputs.

Two living documents must be kept current in every session:
`docs/cc/questions_for_andria_general.md` (simple and logistical) and
`docs/cc/questions_for_andria_scientific.md` (technical and scientific).
Whenever a question for the PI arises during the work, add it to the
relevant file at once with a one-line note of where it came from; remove
questions once answered, recording the answer in the relevant document.

File naming under `docs/cc/`: dated and descriptive, e.g.
`2026-09-18_code_review_original_code.md`, so the purpose is clear from
the name. Living documents that are updated continuously (the two question
files) carry no date.
