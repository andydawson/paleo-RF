# Brief for Astra (ultra effort): the smallest build of script 7's map ice

*Chris McWilliams, 20 November 2026. Review only, read-only.*

## The task
Chris approved in principle the design's alternative C for branch `ice-maps` (worktree
`/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps`): **no new setting**; `analysis$ice$fraction_source`
also picks the ice script 7 uses.
- With `"dalton_ice"` (today's default and the legacy configuration), script 7 keeps the 21 glacier outlines exactly
  as now.
- With a NADI-1 source (`nadi1_optimal`, `nadi1_minimum`, `nadi1_maximum`), script 7's ICE flags, ice outlines and
  coarse differences come from that fraction file, a cell counting as ice when its fraction exceeds
  `analysis$ice$threshold`.

Fable's review estimated about +103 / -23 lines (net +80) for this. Chris: **"not clear to me why it needs 80 lines of
code! Ask for review please"**.

## What to deliver
1. The smallest correct implementation of exactly that behaviour: what changes, in which file and where, in words
   (no full code needed). Count the lines per file, code separately from tests and documents.
2. For each part of the earlier estimate, whether it is needed and why: the new file `R/ice_fractions.R` with a shared
   function, the refactor of script 7a onto it, the new test file, the README, changelog and questions-file lines, the
   comment lines. "No duplicated code" (AGENTS.md) is a project rule; judge proportionately what counts as
   duplication, and say what you would do with any line two scripts would share.
3. What must stay true:
   - under `"dalton_ice"`, every output of scripts 7 to 9 stays byte-identical (legacy anchors in `tests/anchors/`);
   - script 7a's outputs do not change;
   - the flagged cells and the drawn outline agree;
   - the flag stays `'ICE'` or NA, the values downstream code tests;
   - the 11,500 BP slice, and the young slices 50, 200 and 500 BP, are handled correctly.
4. The risks of your smaller route, a "Not worth doing" list, and the limits of your review.

## Read
- The design, `docs/cc/2026-11-20_ice_maps_design.md`, and Fable's review, `docs/cc/2026-11-20_ice_maps_design_review_fable.md`.
  Its estimate is the thing to challenge; don't take its conclusions on trust.
- The code:
  - `scripts/7_plot_preds.R` (all of it);
  - `scripts/7a_alb_diff_full.R` (lines 40 to 140);
  - `scripts/9_forcing_barplot.R` (lines 360 to 400);
  - `R/paths.R`, `config.R` (the ice and coarse lists), `configs/legacy_config.R`, `R/differences.R`;
  - `tools/build_nadi1_fractions.R` (bands, grid, CRS), `tools/compare_ice.R`;
  - `R/preparation.R`, `R/run_manifest.R`.
- The project rules: `AGENTS.md`, `CONTRIBUTING.md`.

## Rules
Change no file; do not commit. R may not start in your sandbox; Python is available. Plain words, summary first. The
repository is public.

Astra's prompt also carried the project's change-reviewer role and Chris's simplicity rules, which are kept
out of this public repository.
