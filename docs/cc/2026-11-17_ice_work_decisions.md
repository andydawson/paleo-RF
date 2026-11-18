# The ice work for the meeting with Andria: Chris's decisions so far

*Recorded 17 November 2026. Designs: `2026-11-16_ice_comparison_design_codex_gpt6astra.md` (first, superseded) and
`2026-11-16_ice_redesign_simpler_codex_gpt6astra.md` (the one to build).*

- **16 November, the request:** compare the 2023 ice reconstruction (Dalton et al. 2023, NADI-1) with the old ice
  inputs (what differs, at which time points, any problem); find when ice readvances in the old and the new ice; check
  whether readvances break the partial-ice formula; recompute the forcing with the new ice. Format: a few slides.
- **16 November:** NADI-1 downloaded (`data/nadi1/` in the main checkout, untracked, `PROVENANCE.txt`). Young slices
  (50, 200, 500 BP): carry the 1 ka ice forward, as the old raster does; list the alternatives for Andria.
- **16 November, on the first design:** "Ask Astra to design a simpler approach. This sounds overcomplicated. Perhaps
  just a switch on the config. We will likely move to using the new one files as our default and will reproduce the
  regression results using them." Hence the second design: one setting chooses the ice-fraction file.
- **16 November, the split of the forcing into a vegetation part and an ice part when ice advances:** compute both
  rules so that Andria can choose (today's rule: vegetation change over the land ice-free at the older slice; the
  alternative: vegetation change only on land ice-free at both slices, everything else to the ice part). Explainer
  for Andria: the document "Ice-Edge Albedo Split".
- **16 November, the oldest slice:** label it 11.5 ka and its period 10 to 11.5 ka (instead of 12 ka and 10 to 12 ka),
  made with the ice work, the legacy configuration unchanged; the forcing numbers do not change.
- **16 November, glacier albedo:** keep 0.68 with 0.50 and 0.80 as sensitivity cases; keep sourcing seasonal and
  latitudinal values (the vegetation part of the forcing does not depend on the glacier albedo).
- **17 November:** run NADI-1 optimal, minimum and maximum side by side (with the old-ice replay and the legacy
  regression); defer a run with the readvance averaging switched off.
- **17 November, the builder's three points:** accept the equal-area method for the NADI-1 cell fractions (s2 turns
  the 8.5 ka minimum inside out). For saved configurations that lack the new setting: "We shouldn't have to bodge this
  every time we add a new config setting. Find an elegant fix - like fail with a warning, and then pass an argument (or
  a legacy flag) to override missing config errors. Astra to design and keep it simple." Astra's design
  (`2026-11-17_config_compatibility_codex_gpt6astra.md`): Chris asked for a Fable review of it before it is built.
- **18 November, the oldest map's ice outline:** after Astra's review, keep the 12 ka outline under the 11.5 ka label,
  so the relabel stays label-only, and fix the lost outline on the oldest difference map; later, as a separate change,
  make script 7 draw the ice from the same fraction file as the forcing (Chris asked why outlines are not interpolated
  to the exact dates: the forcing's fractions already are, at the slice ages; outline shapes cannot sensibly be
  interpolated).

