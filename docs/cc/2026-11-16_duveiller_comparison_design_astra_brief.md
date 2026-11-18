# Brief for Astra (ultra effort): design the comparison of the cover contrasts with Duveiller et al.'s data set

*Chris McWilliams, 16 November 2026. Design only, read-only. Chris's arrangement: Astra designs and reviews, an
Opus agent implements, then the verification tool.*

## Chris's decision
After your read-only look (`/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/2026-11-16_duveiller_look_codex_gpt6astra.md`),
Chris chose: "Download, all three exchanges". The file is downloaded:
`/home/expert/Documents/contracting/Andria/paleo-RF/data/duveiller2018/albedo_IGBPdet.nc` (419,909,756 bytes, md5
96125db41154fa176c53b51596893ad6, matching Figshare; `PROVENANCE.txt` beside it; not in git). Inspect its header
and variables yourself before designing (Python is available; R may not start in your sandbox).

## What exists
- The contrast tool, verified and now being merged into the trunk: `tools/explore_cover_contrasts.R`,
  `tools/check_cover_contrasts.R`, `R/cv_separation.R` (worktree `/home/expert/Documents/contracting/Andria/paleo-RF-wt/merge-contrasts`,
  which holds the trunk plus the contrast branch; read the implementation note and your reviews in `docs/cc/`).
- Its full run, complete: `/home/expert/Documents/contracting/Andria/paleo-RF-verify/7c12534/.rundirs/cover-contrasts-full/`
  (36 jobs, 212 converged fits saved as `fit_<table>_<month>_<version>.rds`, exchange cases as
  `cases_<table>_<month>.rds`, `cover_contrasts.csv` with 4,536 rows, `cover_contrasts.pdf`). The all-days table's run
  is `paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts`.

## What the design must give
Your look already proposed the shape: all-days albedo; the original, unextended estimates; transition 23 negated
for evergreen to summergreen (needleleaf evergreen to broadleaf deciduous), 38 for evergreen to open land
(needleleaf evergreen to grassland), 28 for summergreen to open land (broadleaf deciduous to grassland); the
published complete-transition change and its uncertainty multiplied by 0.10 beside our 10-point exchange; both
averaged over the same cells (valid Duveiller cells intersected with our eligible cells), by region and month,
with the model means recomputed on that intersection from the saved fits and cases, no refit; coverage shown
beside the means; no pass or fail. Design the smallest implementation of that:
1. Where it lives: the contrast tool's report step, a small new command of it, or a stand-alone script; what it
   reuses (no duplicated arithmetic); what it writes (one table, one figure page, a record).
2. The grid check and cell matching (the pipeline's 1-degree cells against the data set's grid), the reading of
   the file (variables, transition index, month, missing values, sign), and the regional averaging with area
   weights.
3. How to show the comparison so it is not read as validation (different albedo definitions and periods, approximate
   class matching), and what the reader should take from agreement or disagreement.
4. Tests and a verification spec; measured runtimes to record.
5. An implementation plan for an Opus agent, in order, on a new branch off the trunk once the merge is pushed.
6. Questions for Chris, only where the choice is his.

## Rules
Change no file; do not commit; download nothing more. Plain words, no private ids, summary first. Simplicity is a
requirement: as simple, clear, readable and parsimonious as possible; no overengineering; no duplicated code.
Published precedent from this field for each method choice, or say it is a project choice. The repository is
public. Never open `data/modis_albedo/requests/`.
