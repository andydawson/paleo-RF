# Comparison of the cover contrasts with Duveiller et al. (2018): Chris's decisions

*Recorded 17 November 2026.*

- **16 November, after Astra's read-only look:** "Download, all three exchanges." The file `albedo_IGBPdet.nc`
  (Figshare doi:10.6084/m9.figshare.5217709, version 1, CC0; 419,909,756 bytes, md5
  96125db41154fa176c53b51596893ad6) is in `data/duveiller2018/` of the main checkout, with `PROVENANCE.txt`; it is
  not tracked in git. Compare all three exchanges: evergreen to summergreen (needleleaf evergreen to broadleaf
  deciduous forest, transition 23 reversed), evergreen to open land (needleleaf evergreen forest to grassland,
  transition 38), summergreen to open land (broadleaf deciduous forest to grassland, transition 28).
- **16 November, on Astra's design (`2026-11-16_duveiller_comparison_design_codex_gpt6astra.md`):** build it as
  designed, with one change. Astra proposed reporting the area-weighted mean of the published cell uncertainties,
  scaled to a 10-point exchange, labelled as describing the cells and not the regional mean (a project choice with no
  field precedent). Chris: **"Leave uncertainty for now but make a record of this so that we can return to it if we
  want to."** So the comparison reports Duveiller's means and coverage only; the cell uncertainties stay in the
  source file. Open question, to return to: how, if at all, to summarise the published cell uncertainties for a
  region (the file gives no covariance between cells, so a regional interval needs an assumption).
- Standing: an exploration only, no pass or fail, no effect on the choice of model (Chris, 10 November). Astra
  designs and reviews, an Opus agent implements, then the verification tool (Chris, 16 November).
