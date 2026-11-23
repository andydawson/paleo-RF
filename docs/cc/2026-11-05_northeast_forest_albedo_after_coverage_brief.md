# Brief for Astra (ultra effort, read-only): after the empty coverage run, what is the simplest sound way forward?

Read-only: change nothing; read-only shell commands are allowed (git log/diff/show, rg, grep, cat, sed -n, ls, wc).
Never open `data/modis_albedo/requests/`. Web search allowed; cite with DOIs. Plain words, no time estimates.

## What happened (5 November 2026)
The stage-1 coverage run of the northeast forest-albedo check (issue #27; design
`docs/cc/2026-11-03_northeast_forest_albedo_design_v2_codex_gpt6astra.md`, frozen settings
`docs/cc/2026-11-03_northeast_forest_albedo_settings.md`) passed all its checks and found **0 pairs (main), 0
(stricter), 1 (looser)** against a target of 300. Cause: MODIS IGBP (`LC_Type1`) labels only 0.6% of the box
evergreen needleleaf, 21.6% deciduous broadleaf, 25.1% mixed forest (2005). Of 34,818 ENF pixels in the 83 cells,
10,110 keep the label all nine years, 125 have a stable same-class 3x3 block, 56 survive water, relief and land; all
56 are one patch in New Brunswick (about 66.7 W, 47 N), at least 23 km from the nearest eligible DBF. The plant-type
layer `LC_Type5` (no mixed class) labels 8.3% needleleaf evergreen trees and 58.3% broadleaf deciduous trees.
Outputs: `/home/expert/Documents/contracting/Andria/paleo-RF-verify/b215344/.rundirs/northeast-coverage/output/northeast_forest_albedo/`.

## Chris's view (his words)
"I'm inclined to drop this as overcomplicating the methodology, it is way outside of anything Andria knows about or
has approved and even I'm not fully convinced by it. I think there are much simpler ways for us to tell if evergreen
or conifer forest is brighter at different times of year, and similarly much easier ways to tell if our model is
getting the albedo sign right."

## The two questions behind the check
A. Is evergreen-needleleaf forest brighter or darker than deciduous forest, month by month, with and without snow?
B. Does our calibration model (model 8 and the cross-validation winner, mod8_coarse_loc) get the sign of the
   evergreen-for-summergreen swap right in the northeast, where evergreen share follows latitude (correlation 0.92)?

## What to do
1. Assess, simplest first, ways to answer A and B, including: published values (Jin et al. 2002; Hollinger et al.
   2010; Zhao and Jackson 2014; others you find, especially studies that already did paired MODIS or tower
   comparisons in northeastern North America); what the model itself implies where evergreen share is not tied to
   latitude (for example the model's evergreen effect at fixed location, or in regions with low confounding), read
   from fits that already exist; and the plant-type layer, MOD44B, NLCD and flux towers. For each: what it answers,
   what it adds to the paper, how much new code and data it needs, whether Andria could follow it, and its published
   grounding.
2. Say plainly whether the satellite pair check should be dropped. If a simpler route answers A and B well enough
   for the paper, recommend it and say what to write in the paper.
3. Keep it small: output a markdown note with a summary of at most ten lines, then the assessment, a recommendation,
   and references with DOIs.
