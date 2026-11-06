# Brief for Astra (ultra effort, read-only): keep the deep cover band represented while scoring near training

Read-only: change nothing; read-only shell commands allowed (git log/diff/show, rg, grep, cat, sed -n, ls, wc). Never
open `data/modis_albedo/requests/`. Web search allowed. Plain words, no time estimates. **Simplicity** (as simple and
parsimonious as possible; Andria must follow it) and **domain precedent** (albedo from land cover, vegetation albedo
forcing, paleo-vegetation and transfer-function calibration; DOI and passage read; otherwise labelled judgement) as
always.

## The problem (Chris asked to rethink, 6 November)
Protocol 2 draft (`docs/cc/2026-11-06_cv_protocol_v2_draft_codex_gpt6astra.md`) scores only withheld cells within
250 km of a training cell (Chris's decision, because the hindcast predicts at places the model was trained on, and
run 1's winner gained only on cells 250 km or more away). Fable's review (`docs/cc/2026-11-06_cv_protocol_v2_review_fable.md`)
found the consequence, from run 1's `by_distance.csv`
(`/home/expert/Documents/contracting/Andria/paleo-RF-verify/f07ff68/.rundirs/cv-run1/output/cross_validation/`):
within 250 km, the beyond-0.10 cover band (where the northeast's most extreme 4.5 ka mixes sit: median 0.085, max
0.107) has 36 cell-month-holdouts in two blocks, and 96% of the nearby weight lies within 0.05 of the hull (88% under
run 1's rule). Chris: "Rethink the 250 km rule."

The tension: cells deep outside the cover range are rare and tend to cluster geographically, so withholding them
leaves them far from training; but the hindcast's real task is deep cover extrapolation at known places.

## What to do
Propose the simplest sound way to score models on both "near training" and "deep in cover", with precedent. Consider,
for example: score within cover bands (equal weight per band, or the historical target weights per band) using only
cells within a distance cut; a larger cut (for example 500 km) or a distance-matched comparison within each band
(Milà et al. 2022 and Linnenbrink et al. 2024 nearest-neighbour distance matching; Telford and Birks); withholding
smaller, scattered sets of edge cells so that deep withheld cells keep nearby training cells (and whether they then
stay outside the training hull); or reporting the deep band beside the score with an explicit statement of what it
cannot show. Use run 1's saved predictions and tables to show what each option would have given (counts of
cell-months and blocks per band, weight shares; read-only). Recommend one, say its code effect, and what Chris must
decide.

Output: a short markdown note: summary of at most eight lines, options table, recommendation, references with DOIs.
