# Review: Holocene animation tool (`git diff chris-dev...animations`), Fable, 23 November 2026

Change-reviewer role, read only, before any merge into chris-dev. Chris's rules on simplicity and
architecture were given. Tool: `tools/animate_holocene.R` (223 lines), cited as `:line`.

**Verdict.** It can merge once the two blockers are fixed. Both are below: the tool runs only on this
machine and only while one verification folder still exists, and there is no PASS report for it, so
the merge check would refuse it. The blend arithmetic, the timing and the labelling are right.

## Useful deletions first (about 45 of 223 lines)

| # | Lines | What could go | Why it is safe | Net |
|---|---|---|---|---|
| D1 | `:39`, `:41`, `:184-194` | The two palette-comparison stills and their unused palettes | Chris has chosen the palettes. This also removes the wrongly titled still. | -13 |
| D2 | `:33`, `:142-154`, part of `:130` | `ice_source_changes.csv`, which compares the old raster with NADI-1 cell by cell | It answered a one-off round-3 question, and the answer is filed in the design note. It is the only reason the tool reads the old raster. | -14 |
| D3 | `:195-198`, `:12`, `:223`, `:24` | Per-frame full-ice counts, the runtime timer and `terraOptions(tempdir = out)` | Round-2 debugging output and a sandbox workaround | -7 |
| D4 | `:20` | `main = '/home/expert/...'` | The three files read through it are at the same relative paths in any checkout. | -1 |
| D5 | `:87-94`, `:160-161` | `bin_bounds()` / `bin_label()` | They repeat `pollen_bin()` from `tools/compare_ice.R:168`. | -10 |

## Findings (worst first)

- **Blocker, `:20-21`, `:124`, `:156`.** Absolute paths into the home folder, and a verification
  worktree's run folder (`paleo-RF-verify/d5d5df5/.rundirs/run1-main`) used as the input. The tool runs
  nowhere else and will stop working once that folder is cleaned up. Fix: take the run folder as an
  argument, as `tools/compare_ice.R:61-67` does (+2/-2). The caption's run name (`:124`) and
  `length.out = 49` (`:156`) should then come from the data.
- **Blocker.** There is no verification spec or PASS report, so `tools/check_merge_evidence.R` refuses
  the merge.
- **Should fix, `:190-191`.** The still titled "Neutral brightness" uses the cool blue-grey scale, and
  `albedo_neutral` is never used. The GIF is not affected. D1 removes the problem.
- **Should fix, `:201-222`.** The GIF is written by Python embedded in an R string:
  - it needs `python3` with Pillow, which the header does not say;
  - the exit status is ignored, so a GIF from an earlier run can sit beside new frames looking current;
  - it breaks the rule that the pipeline runs from R alone.
- **Should fix, `:2`.** The run line (`CORES=32-47 THREADS=2 tools/rscript.sh ...`) works on Linux only.
- **Should fix, `:87-94`.** The time-bin rule is duplicated, with `tools/compare_ice.R`. Delete it (D5).
- **Should fix, `README.md:128-149`.** There is no row for the tool in the tools tables (+1).
- **Nit, `:7`, `:96-97`.** The comments credit script 7a with the surface mixture. The partial-ice
  arithmetic is in fact `partial_ice_differences()` in `R/differences.R:142-149`.
- **Nit, `:35`, `:126`.** The caption hard-codes 0.68 while the map reads the value from
  `data/albedo_glacier_monthly.csv`.
- **Nit, `:208-216`.** The GIF reduces the frames to one 256-colour palette without saying so.

## Right

- No pipeline file changes, so default outputs and anchors are untouched.
- Each blend frame averages ice fraction, the three cover fractions and vegetation albedo cell by cell,
  then recomputes the surface albedo. The rows align.
- Timing is 2 ms per nominal year plus a 2.1 s hold, 25.0 s in all. The measured render took 252.48 s.
- Blend frames are labelled as blends, and the caption calls them illustrative.
- The surface mixture, differenced between two slices, equals the pipeline's partial-ice total.
- Helpers are reused, not copied. All outputs land under the ignored folder.

## Questions for Chris (as Fable put them)

1. **GIF writer.**
   - (a) Keep the Python and add a status check, the folder as an argument, and the requirement in the header.
   - (b) An R package such as `magick`, which is a new dependency.
   - (c) R stops at the frames, and the Python moves to its own file.
2. **Output folder.** Keep the new top-level `animations/` folder and list it in CONTRIBUTING, or write
   under `figures/`, which is already ignored.
3. **`ice_source_changes.csv`.** Regenerate it on every render, or drop it (D2).
4. **Blend label.** Keep "8,250 BP | blend", or name the two slices.

## Not worth doing

A test for the frame table or `surface_albedo()`; moving the mixture into `R/differences.R`; routing
reads through the config helpers; merging the two map functions.

## Not checked

- Windows behaviour of the Python call.
- A thin white line near 95 W in frame 14, whose cause is unknown.
- Full ice (ivory) is close to the sea colour around Hudson Bay.
