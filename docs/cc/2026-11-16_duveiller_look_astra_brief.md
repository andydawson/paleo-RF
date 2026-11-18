# Brief for Astra (ultra effort): a read-only look at Duveiller et al. 2018's data set, as a comparison for the cover contrasts

*Chris McWilliams, 16 November 2026. Read-only: no data download.*

## Why
The cover-contrast exploration (branch `cover-contrasts`, worktree `/home/expert/Documents/contracting/Andria/paleo-RF-wt/contrasts`;
design `docs/cc/2026-11-10_cover_contrast_test_design_fable.md`, note
`docs/cc/2026-11-15_cover_contrast_exploration_implementation.md`, your reviews beside them) reports, for six
versions of the albedo model, the albedo change for a 10-point exchange between our three cover classes (evergreen
ET, summergreen ST, open land OL), by month, region and albedo table (all days, snow-free, snowy). You called
Duveiller et al.'s published data set the strongest next external comparison. Chris: "Read-only look first."

## The data set
Duveiller, G., Hooker, J., Cescatti, A. (2018). A dataset mapping the potential biophysical effects of vegetation
cover change. Scientific Data 5, 180014, doi:10.1038/sdata.2018.14; data on figshare (collection
doi:10.6084/m9.figshare.c.3829333) and a later version on the JRC's server. Method paper: Duveiller et al. 2018,
Nature Communications 9, 679, doi:10.1038/s41467-017-02810-8.

## What to find
1. The files: names, sizes, formats, versions, licence; which file holds what (albedo change per transition, by
   month; resolution; uncertainty or sample counts; masks).
2. The quantity: which albedo (white-, black-, blue-sky; snow handling), period, sign convention, and how a
   transition is defined (complete conversion between two classes).
3. Its classes and a proposed mapping onto ET, ST and OL (for example evergreen forest, deciduous forest, savanna,
   shrubland, grassland, cropland), with what does not map cleanly.
4. The smallest comparison with our contrast output (which of our three exchanges, the scaling by 0.10 already used
   for published values, region and month aggregation, what not to compare), and the exact files to download, with
   sizes, for Chris to approve.
## Rules
- Read-only: change no file, commit nothing, download no data file (reading web pages and papers is fine). R may not start in your sandbox; Python is available.
- Plain words, no private ids. Verdict or summary first, then the details. Findings with evidence: page-located quotes or numbers for every value taken from a paper, with DOI.
- Simplicity is a requirement (Chris): as simple, clear and parsimonious as possible; no overengineering.
- Published precedent from this field (albedo and land cover, ice sheets and their albedo, vegetation albedo forcing, palaeo-vegetation) for every method choice, or say it is a project choice.
- The repository is public. Never open `data/modis_albedo/requests/`.
- End with questions for Chris, only where the choice is his or Andria's, each answerable without reading anything else.
