# Northeast forest-albedo pair check: dropped at coverage (5 November 2026)

**Decision (Chris, 5 November 2026).** Drop the satellite pair check and close issue #27 at the coverage stage.
In his words: "I'm inclined to drop this as overcomplicating the methodology, it is way outside of anything Andria
knows about or has approved and even I'm not fully convinced by it. I think there are much simpler ways for us to
tell if evergreen or conifer forest is brighter at different times of year, and similarly much easier ways to tell
if our model is getting the albedo sign right." He then chose "Drop it" after Astra's assessment and Fable's review.

**Why the check could not work.** The coverage run (verification `northeast-coverage`, commit b215344, PASS) found
0 pairs (main, stricter) and 1 (looser) against a target of 300. MODIS IGBP labels 0.6% of the box evergreen
needleleaf and 25% mixed forest; 56 conifer pixels survived the screens, all one New Brunswick patch at least 23 km
from any eligible hardwood. Nothing was loosened after seeing coverage.

**Instead (Chris, 5 November).** Chris chose the option "Table in the CV comparison", whose text read: "Part of
the comparison of the chosen model and model 8 that's already planned. A 12-month by 2-model table, plus the figure
for April and May. Uses today's open land and each month's own training data." He added: "please make sure we have
proper designs from Astra for those things it just recommended, but do brief for simplicity as always." For which
forest is brighter: the published comparisons (Astra's note `2026-11-05_northeast_simpler_routes_codex_gpt6astra.md`;
numbers to be reference-checked before they enter the paper).

**What stays.** This branch (stage-1 code, tests, reviews, coverage records) and the 27 MCD12Q1 files in
`data/mcd12q1/`. The shared MODIS helpers moved to `R/modis_albedo_helpers.R` are general; whether to merge them
without the check is for Chris.
