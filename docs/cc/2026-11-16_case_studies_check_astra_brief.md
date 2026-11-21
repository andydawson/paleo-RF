# Brief for Astra (ultra effort): check the case-study candidates against our own data

*Chris McWilliams, 16 November 2026. Read-only.*

## Why
Chris (10 November): the northeast and the hemlock decline are one test case; there may be other times and regions
where we know what happened to the vegetation (or the climate) and so the effect it should have had on albedo. A
search agent ranked candidates (report `docs/cc/2026-11-10_case_study_candidates.md`, folder
`docs/cc/2026-11-10_case_study_candidates/` with scripts 01 to 13, CSVs, `candidate_boxes.png` and a README, in the
worktree `/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2`; unreviewed). Its top four: (1) land clearance
in the eastern US, 500 to 50 BP; (2) the spruce rise in Quebec and Labrador, 6 to 2.5 ka; (3) the hemlock decline;
(4) the prairie's advance and retreat in the Midwest.

Chris's questions, in his words: "are these really visible in our data. Also the first one is during the
calibration date range so won't work?"

## What to do
1. For each of the top four (and any other the report ranks highly), check that the vegetation change is really
   visible in the land cover the pipeline uses (the interpolated REVEALS product: the modern and past tables in a
   finished run, for example `/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main/data/`
   `lct_modern_reveals_interp.RDS` and `lct_paleo_reveals_interp.RDS`): size of the change in each class, cells and
   slices, and how it compares with the reconstruction's own uncertainty where that can be judged (200 posterior
   draws per cell, slice and class exist upstream; the pipeline keeps their mean). Also how many of the cells hold
   pollen sites, if the files show it. Recompute the report's numbers your own way.
2. Answer Chris's point on the land clearance directly: the 50 BP slice (1850 to the 2020s) is the calibration
   slice, fitted to albedo of 2000 to 2009, and eastern North America partly reforested in the 20th century. Can a
   change ending at 50 BP test the model at all, and if so what could it show?
3. Whether the expected albedo effect of each candidate has published support (sign and rough size, by season).
4. A verdict for each: a usable case study, usable with caveats, or not; and what it would show.
## Rules
- Read-only: change no file, commit nothing, download no data file (reading web pages and papers is fine). R may not start in your sandbox; Python is available.
- Plain words, no private ids. Verdict or summary first, then the details. Findings with evidence: page-located quotes or numbers for every value taken from a paper, with DOI.
- Simplicity is a requirement (Chris): as simple, clear and parsimonious as possible; no overengineering.
- Published precedent from this field (albedo and land cover, ice sheets and their albedo, vegetation albedo forcing, palaeo-vegetation) for every method choice, or say it is a project choice.
- The repository is public. Never open `data/modis_albedo/requests/`.
- End with questions for Chris, only where the choice is his or Andria's, each answerable without reading anything else.
