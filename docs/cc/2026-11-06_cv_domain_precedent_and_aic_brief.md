# Brief for Astra (ultra effort, read-only): precedent in this domain for the CV redesign, and where AIC fits

Read-only: change nothing; read-only shell commands allowed (git log/diff/show, rg, grep, cat, sed -n, ls, wc). Never
open `data/modis_albedo/requests/`. Web search allowed and required. Plain words, no time estimates.

## Chris's words (6 November 2026)
"The other thing we need and which an agent should have brought up given that I've stressed its importance for every
methodological decision we make, is precedent in the literature for this kind of tuning/model selection approach in
this application domain. The other thing I'm not clear on is how AIC and the other model selection criteria come
into this?"

Your redesign (`docs/cc/2026-11-06_cv_redesign_codex_gpt6astra.md`) cites general statistics only (Varma and Simon;
Yates; Roberts; Paciorek; Dupont; Morris; Brenning; Meyer and Pebesma). **Chris requires precedent from this
application domain.**

## 1. Domain precedent
Find how published studies in these fields choose and check statistical models that predict albedo (or a similar
surface property) from land cover, and that are then applied to other land-cover states (past, future or
counterfactual):
- albedo or surface radiative properties regressed on land cover or forest structure (for example Bright et al.;
  Cescatti et al. 2012; Gao et al.; Zhao and Jackson 2014; Duveiller et al. 2018 and others);
- vegetation or land-use albedo forcing from reconstructed or scenario land cover (for example Boisier et al.;
  Strandberg et al.; Gaillard et al.; LandClim; Dawson et al. 2025 and its predecessors);
- paleo-vegetation calibration and reconstruction (pollen-based cover such as REVEALS or STEPPS, and transfer
  functions), where the transfer of a modern calibration to past conditions, no-analogue situations and
  spatial autocorrelation are long-standing concerns (for example Telford and Birks on cross-validation and
  spatial autocorrelation in transfer functions);
- GAMs or spatial models in ecology or remote sensing tuned by cross-validation for extrapolation.

For each step of the redesign (the tuning grid; nested assessment; directional holdouts at the edge of the cover
range; the synthetic recovery test; grading by distance outside the training range), say what precedent exists in
these domains, with DOI and the supporting passage you read, and where none exists. Say plainly which steps would be
new to the domain. If the domain's usual practice is simpler (for example AIC, or one spatial-block CV), say so
and say what that means for our design.

## 2. AIC and the other criteria
Explain plainly, for Chris and Andria:
- What the pipeline does now: script 4 fits the model ladder by ML and compares it by AIC (`scripts/4_calibration_model.R:43-82`;
  `config.R:69-80`, decision B4), then fits the chosen model by REML for prediction; script 5 also reports AIC.
- What AIC (mgcv's conditional AIC with corrected degrees of freedom), BIC, REML/ML scores, GCV, deviance explained
  and cross-validation each estimate, and why they can disagree. In particular, whether AIC addresses prediction for
  cover mixes outside the training range or the separation of cover from location.
- How they should fit together in the redesign: for example AIC (or REML) inside each fit for smoothing, and
  cross-validation for the extrapolation question; or AIC across the grid as a first filter; or AIC reported beside.
  What the domain literature does.
- Recommend the simplest sound combination.

Output: a markdown note with a summary of at most ten lines; section 1 as a table (step, domain precedent with DOI
and passage, or "none found", what it means for the design); section 2; a recommendation (what to keep, cut or
change in the redesign); references with DOIs. Mark every source whose passage you could not read.
