# Snow mixing: the decision (Chris, 4 November 2026)

After Astra's design (`2026-11-04_snow_mixing_design_codex_gpt6astra.md`) and Fable's review of it (below, condensed),
Chris keeps his 29 October plan (`2026-10-29_refit_plan_decisions.md`, items 1 and 8): **mix the predictions** of the
snow-free calibration (run 2) and the snowy calibration (run 7) by MOD10CM's monthly snow-cover fraction, draw by draw
(both runs use seed 1549466984), then run scripts 7-10 on the mixed predictions; July and August use the snow-free
prediction alone (run 7 does not fit them). No refit. Astra's alternative, mixing the observations and refitting as a
ninth run, is not taken.

To settle before any result: a minimum support for a panel (thin snowy or snow-free panels rest on a few pixel-days in
places, January snow-free in the northeast among them), proposed to Chris before use; the MOD10CM download (118 monthly
files, March 2000 to December 2009, Earthdata), listed for Chris's approval; and that MOD10CM and the albedo's own snow
flag both detect snow from MODIS reflectance and both under-detect it beneath dense canopy (for the hemlock decline this
inflates the size of the winter brightening, it does not reverse it).

## Fable's review of the design (4 November, condensed)

Verdict: proceed with changes. Blockers for the design's observation mixing: the missing-panel rule ("both panels or
nothing") would drop January's 501 snowiest cells and could stop July and August at the fitting gate; per-panel support
is not recorded, and a one-pixel-day panel can carry 6-20 % of a cell's response (hand check, cell -72.5, 44.5,
January). The recorded plan (mixing predictions of runs 2 and 7) needs no new fitting and is the closer analogue of
Barnes and Roy 2010 and Ghimire et al. 2014; the design's claim that existing fits cannot be used holds only for its own
method. Also: plain means of MOD10CM's valid land sub-cells rather than new land weights; a zero-download screening from
the existing table (any_75 against full_75 snow shares) is possible; MOD10CM and the MCD43A2 snow flag share MODIS
snow detection, so "independent" is overstated. Hand check of the mix on cell -71.5, 44.5, January, agrees with the
design's identity.
