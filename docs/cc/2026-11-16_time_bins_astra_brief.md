# Brief for Astra (ultra effort): check the 25 time bins, and the modern slice against the 2000-2009 albedo

*Chris McWilliams, 16 November 2026. Read-only.*

## Why
Andria answered (12 November) that the 25 slices follow the PAGES LandCover6k specification and are described in
her Climate of the Past paper. Chris's notes from their call: "Check in the Climates of the past paper" and
"Relationships pollen to land cover would be different now. Slight mismatch with albedo product, reason through
it." The ice work now matches the 2023 ice reconstruction (NADI-1, every 500 years from 25 to 1 ka) to the slices
by their names.

## Andria's table (as she wrote it)
| Period (ka BP) | Calendar years | Temporal resolution |
|---|---|---|
| 11.7 to 0.7 | 10,250 BCE to 1250 CE | 500-year intervals |
| 0.7 to 0.35 | 1250 to 1600 CE | 350 years |
| 0.35 to 0.1 | 1600 to 1850 CE | 250 years |
| 0.1 to -0.074 | 1850 to 2020 CE | 174 years |
She added: the bin names are roughly the centres; the most recent bin is post-settlement, extends to 1850 CE, and
recent decades alone have too few pollen samples for a complete map. The pipeline's slices are named 50, 200, 500,
then 1,000 to 11,500 BP every 500 years; it pairs consecutive slices; script 7 treats 11,500 as 12,000 in figures
(question C7). The calibration fits the 50 BP slice's land cover to MODIS albedo of 2000 to 2009. Records:
`docs/cc/questions_for_andria_general.md` section 1 and `docs/cc/questions_for_andria_scientific.md` sections B10 and
C7 (worktree `/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice`).

## What to do
1. Find Andria Dawson's Climate of the Past paper on North American Holocene land cover (and the LandCover6k
   specification it follows) and check the table against it, page-located: the bin edges, what each name stands
   for (centre or not; "1000" for 0.7 to 1.2 ka has its centre at 0.95), and the last row (-0.074 ka BP is 2024 CE,
   and 174 years from 1850 also give 2024, while the table says 2020).
2. Reason through the modern slice: a land cover from pollen of 1850 to the 2020s paired with albedo of 2000 to
   2009. What it assumes, what is known to differ (for example clearance after settlement and later reforestation
   in eastern North America; pollen lag; how the bin's samples are spread in time), what published practice does
   when calibrating against satellite data, and whether it biases the calibration in a known direction. Keep it
   to what the paper's methods need to say.
3. What it means for matching ice to slices by name (snapshot at the name's age, against the bin it stands for).
## Rules
- Read-only: change no file, commit nothing, download no data file (reading web pages and papers is fine). R may not start in your sandbox; Python is available.
- Plain words, no private ids. Verdict or summary first, then the details. Findings with evidence: page-located quotes or numbers for every value taken from a paper, with DOI.
- Simplicity is a requirement (Chris): as simple, clear and parsimonious as possible; no overengineering.
- Published precedent from this field (albedo and land cover, ice sheets and their albedo, vegetation albedo forcing, palaeo-vegetation) for every method choice, or say it is a project choice.
- The repository is public. Never open `data/modis_albedo/requests/`.
- End with questions for Chris, only where the choice is his or Andria's, each answerable without reading anything else.
