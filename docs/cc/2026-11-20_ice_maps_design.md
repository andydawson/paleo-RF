# Script 7's maps from the forcing's ice: design for review (20 November 2026)

Chris chose this as the next task on 20 November 2026. Nothing is built; the design goes to Fable
(change-reviewer) for review, then to Chris for approval with the files and line counts.

## Why

With `analysis$ice$fraction_source` set to a NADI-1 reconstruction, script 7a's forcing uses NADI-1's
ice, but script 7 still uses the old 21 glacier outlines. So the albedo maps, script 7's coarse
differences and script 9's slide-18 recipe (which reads them) show ice the forcing does not use. If
NADI-1 becomes the default (Andria to decide, issue #29), the paper's maps must show the same ice as
the forcing.

## Today

- Script 7 (`scripts/7_plot_preds.R`) reads `glacier_shapes` (21 outlines, 1 to 21 ka) and gives each
  age the nearest outline (`ice_match()`; 11,500 BP is matched as 12 ka).
- It uses them twice:
  1. A point-in-polygon test flags prediction cells `'ICE'` (`alb_interp_preds$ice`). Flagged cells are
     blank on the albedo maps, take the glacier albedo in the coarse differences (`alb_mean_ice`), and
     are masked in script 9's slide-18 recipe (`scripts/9_forcing_barplot.R`, about line 378).
  2. The outlines are drawn over the maps and saved: `ice_fort`, `ice_fort_diff_young`,
     `ice_fort_diff_old`. In the difference outlines, 50 and 500 BP find no outline (a known quirk,
     pending Andria).
- Script 7a reads the fraction file `fraction_source` chooses (one band per slice, the 1 ka ice carried
  forward to 500, 200 and 50 BP). In its threshold variants a cell is ice when its fraction exceeds
  `analysis$ice$threshold` (0.5).
- The regression contract makes script 7's ice and coarse-difference tables byte-identical anchors
  under the legacy configuration: `ice_fort.RDS`, `ice_fort_diff_young.RDS`, `ice_fort_diff_old.RDS`,
  `alb_interp_preds_diffs_bluesky.RDS` (`tests/anchors/interp-tail-2026-09-21`).
- Out of scope: script 2 masks modern ice in the calibration with the 1 ka outline; changing that
  changes the calibration.

## Proposal

1. **Shared helper, moved out of script 7a.** Read the fraction file, check one band per slice, and give
   the fraction at given points for one slice (today 7a lines 46 to 80, inline). Script 7a calls it;
   its outputs must not change (MD5 check).
2. **Script 7 from the fraction file.** Flag a prediction cell `'ICE'` when its fraction exceeds
   `threshold`, the rule of 7a's threshold variants. Draw as outline the cells above the threshold,
   dissolved into polygons (`terra::as.polygons`), written in today's columns so the plotting code and
   the saved tables keep their shape.
3. **A setting for the map ice,** because the legacy configuration must keep the outlines to reproduce
   its anchors: `analysis$ice$map_source`, `"outlines"` (legacy configuration) or `"fraction"`. Whether
   `config.R` takes `"fraction"` now or only when NADI-1 becomes the default is Chris's choice.

## Alternatives

| | What | For | Against |
|---|---|---|---|
| A | The setting above | Every anchor kept | One new option (an architectural addition) |
| B | No setting; script 7 always uses the fraction file | Fewer lines | The legacy configuration no longer reproduces four anchored files or the slide-18 recipe |
| C | No setting; outlines when `fraction_source = "dalton_ice"`, fractions for NADI-1 | Anchors and today's default kept | Two drawing methods hidden behind one setting |
| D | Draw NADI-1's own margin polygons (from `data/nadi1/`) | Faithful margins | A new prepared input; still disagrees with the forcing's cells |

## Expected effect

- Legacy configuration: none (anchors).
- `config.R` with `"fraction"` and the old raster: maps, coarse differences and the slide-18 recipe
  change from the 21 outlines to the old raster above 0.5. With NADI-1: NADI-1's ice. 50 and 500 BP
  gain difference outlines.

## Files and lines (estimate, before review)

| File | Change | Lines |
|---|---|---|
| `R/ice_fractions.R` (new) | the shared helper | +35 |
| `scripts/7a_alb_diff_full.R` | calls the helper | +5 / -20 |
| `scripts/7_plot_preds.R` | flag and outlines from the fraction file under the setting | +40 / -5 |
| `config.R`, `configs/legacy_config.R` | the setting, with its comment | +8 |
| `R/config_schema.R` | validates the setting | +3 |
| `tests/test_ice_fractions.R` (new) | a toy raster: flags and outlines | +30 |
| `README.md`, changelog | after the build | +10 |

About +130 / -25, net +105.

## Verification (after the build)

- Legacy configuration: anchors byte-identical for scripts 7, 7a, 8 and 9.
- Script 7a refactor: its outputs and script 8's MD5-identical to a run before the change.
- `"fraction"` with `dalton_ice` and with `nadi1_optimal`: runs cleanly; per slice, the cells script 7
  flags `'ICE'` equal those above the threshold in script 7a.
