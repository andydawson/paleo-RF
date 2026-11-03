# Revision request for Astra: the northeast forest-albedo check, with Fable's review

You are Astra. Read-only: do not edit files or download anything; do not open anything under data/modis_albedo/requests/.
Web search allowed; cite with DOIs and check that each cited passage says what you claim. Plain words. No time estimates.

Your design: `docs/cc/2026-11-03_northeast_forest_albedo_design_codex_gpt6astra.md` (this checkout, branch
northeast-benchmark). Fable's review of it is below (verbatim findings). Chris chose: revise the design with Fable's
changes; flux towers (Harvard Forest hemlock and hardwood towers, Howland, Bartlett) are scoped later, after the first
satellite results, so mention them only as a later option. Chris also asked for the scripts and experiments to be
organised in the repository so they are not throw-away code (a separate design is being made for the repository as a
whole; here just say where this check's script, tests, outputs and records would sit under the current layout, and keep
the code small and readable for Andria).

Produce the revised design as a complete document (not a diff), adopting Fable's changes unless you find one wrong, in
which case say why with evidence:
- a "what to expect from the literature" section first: month-by-month expected sign and range of deciduous minus
  evergreen-needleleaf albedo in this region, snow-free and snowy, from checked sources (Fable suggested Jin et al. 2002,
  Hollinger et al. 2010 Global Change Biology 16:696, Zhao and Jackson 2014 Ecological Monographs 84:329; verify each
  identity and passage), and the precision the check needs;
- the simpler estimator: nearest eligible deciduous pixel within 5 km for each evergreen pixel, reuse allowed; no
  latitude rule; no 25 km windows; aggregate by the pipeline's 1-degree cells and year, then cells equally, with the
  pair-weighted mean beside it;
- a retrieval-count balance rule within pairs (for example min/max of the all-days counts >= 0.7), with the asymmetry
  reported by month;
- site selection named as the main threat; results by stratum (woody wetland or not, latitude band), a sign stable
  across strata and months being the usable result;
- MCD12Q1 only in the first pass; MOD44B tree cover as a later sensitivity;
- the model side as the implied contrast per unit cover exchanged (model change / q), for model 8 and the
  cross-validation winner, reusing `tools/plotting/plot_northeast_cover_and_location.R`'s fixed-location swap;
- where pure stands exist (pair coverage by latitude band), and that the check tests spruce-fir and pine against
  hardwoods more than hemlock;
- the direction of the shared-MODIS label bias;
- the shared functions in `tools/prepare_bluesky_albedo.R` that the new script needs moved to `R/` (with their tests);
- Fable's six invariants added to the verification;
- the exact first download: MCD12Q1.061 tiles h11v04, h12v04, h13v04 for 2001-2009 (file names as published, sizes if
  you can find them, how they are obtained), for Chris's yes;
- what Chris and Andria must decide.

## Fable's review (verbatim)
Verdict: proceed with changes. Core sound: within-5 km, same-month, snow-state-separated contrast of pure ENF and DBF pixels on the existing 500 m albedo, reported beside the model.
Hand check: May, one pair, snow-free: DBF n_free 12, s_free 1.68 (0.140); ENF n_free 10, s_free 0.95 (0.095): +0.045. Crosswalk q = 0.18 gives +0.0072 brighter. Model May exchange -0.094 for q = 0.18, i.e. -0.52 per unit cover against about +0.04 observed: opposite sign, over ten times larger, so +/-0.02 precision is decisive.
Findings:
1. (should-fix) Main threat not named: pure conifer stands sit where they do for site reasons (spruce-fir on wet flats, pine on sandy outwash, plantations); matching on latitude, elevation, relief does not remove it. Sign probably robust, magnitude not. State it first; report by stratum (woody wetland yes/no, tree-cover class if used, latitude band).
2. (should-fix) No prior expectation stated or cited (Jin et al. 2002 tabulate by IGBP class; Hollinger et al. 2010; Zhao and Jackson 2014; identities to verify). Add a literature paragraph with month-by-month ranges before the method; state +/-0.02 per unit suffices.
3. (should-fix) Model side: show the model's implied contrast per unit exchanged, dAlpha_i / q_i, beside observed dAlpha, for the headline (model 8) and the CV winner; reuse plot_northeast_cover_and_location.R lines 118-139 (fixed-location swap with predict(type='response')). Drop the per-cell weighted support comparison.
4. (should-fix) Minimum of five days per pixel does not bound retrieval asymmetry within a pair (snow transitions: one pixel's retrievals before melt, the other's after). Add a pair rule, e.g. min(n)/max(n) >= 0.7 on all-days counts; report asymmetry per month; spring diagnostic where many pairs fail.
5. (nit) Drop latitude <= 0.02 deg: within 5 km the difference is at most 0.045 deg; it only forces east-west pairs.
6. (should-fix, simplification) Drop 25 x 25 km windows, no-reuse greedy matching and deterministic ordering: take for each ENF candidate the nearest eligible DBF within 5 km (reuse allowed; matching with replacement is standard, Stuart 2010); aggregate by 1-degree cell and year, then cells equally; report the pair-weighted mean beside it.
7. (question) MOD44B (about 6 GB) for a +/-10-point tolerance adds little: IGBP forest classes mean tree cover > 60% and MOD44B saturates near 80%; it is regressed from MODIS reflectance (weakly matching on the outcome). First pass without it; sensitivity later.
8. (should-fix, reporting) Modern hemlock is mostly in IGBP mixed forest (excluded); pure ENF 3x3 blocks on gentle land are mainly spruce-fir and pine north of about 45 N; the decline is strongest in the southern half of the box. Report pair coverage by latitude band and whether dAlpha varies with latitude.
9. (nit) Shared-MODIS bias has a direction: a pixel dark in winter is likelier labelled ENF; label selection can inflate dAlpha. Name it; the NLCD purity audit tests it.
10. (nit) "Twenty-seven complete tiles" are 3 tiles x 9 years.
11. (implementation) is_land, tile_template, pixel_lonlat live in tools/prepare_bluesky_albedo.R; move to R/ with tests when the new tool is written (project rule).
12. (records) Open points to the questions file (which stands stand in for hemlock; what the vegetation forcing represents; the crosswalk).
Verification invariants to add: (1) a pixel paired with itself gives 0 in every panel; (2) mixing identity share_snowy*snowy + share_free*free + share_unknown*unknown = all, to float32 tolerance; (3) swapping class labels flips every mean's sign; (4) the pair set is identical when the albedo layers are replaced by noise (matching never reads the outcome); (5) a hand case with one cell of 1 pair and one of 50 gives the equal-cell and pair-weighted means; (6) model exchange: q = 0 gives exactly 0; May regional mean reproduces -0.094.
Fable also noted: data/gmted2010/ holds only mn30_grd.zip and its aux.xml (prepare_land_elevation.R reads data/gmted2010/mn30_grd): check what is on disk.
