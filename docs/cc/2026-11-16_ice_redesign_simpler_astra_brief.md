# Brief for Astra (ultra effort): a simpler design for the ice work, built on a configuration switch

*Chris McWilliams, 16 November 2026. Design only, read-only.*

## What changed
Your first design (`docs/cc/2026-11-16_ice_comparison_design_codex_gpt6astra.md`, on this branch) proposed a
stand-alone tool plus two refactors of shared code (a readvance argument in `R/differences.R`, and the kernel
multiplication moved out of script 8). Chris's answer: **"Ask Astra to design a simpler approach. This sounds
overcomplicated. Perhaps just a switch on the config. We will likely move to using the new one files as our
default and will reproduce the regression results using them."**

So the ice reconstruction becomes a **configuration setting** of the pipeline, NADI-1 is expected to become the
default, and the pipeline's own forcing stage computes the forcing for each setting. No separate forcing tool.

## What still stands from the first design and Chris's decisions
- Chris's goals for the meeting with Andria: what differs between the old ice and NADI-1, at which time points,
  and whether that causes problems; when readvances happen in the old and the new ice; whether readvances break the
  partial-ice formula; how much the forcing changes with the new ice. Format: a few slides (your five-slide
  outline is fine as a starting point).
- NADI-1 is downloaded (`/home/expert/Documents/contracting/Andria/paleo-RF/data/nadi1/`, untracked, with
  `PROVENANCE.txt`); its ages match the slice names from 1,000 to 11,500 BP; the three youngest slices carry the
  1 ka ice forward, as the old raster does; the alternatives (no ice; a present-day inventory) are listed for
  Andria with no new data.
- Your findings stand: the partial-ice total is exact for every kind of change, readvances included; the one-pass
  averaging creates readvances as well as removing some (186 to 228 on the forcing cells, 75 new); the saved
  headline run (`paleo-RF-verify/d5d5df5/.rundirs/run1-main`) has vegetation albedo wherever needed.
- Still open, not for this design to decide: what the separately reported vegetation part should mean when ice
  advances (Chris asked for explanatory diagrams before deciding; keep today's split for now), and the old raster's
  time convention and source (questions for Andria).

## Rules
As before: change no file; R may not start in your sandbox (Python is available); plain words, no private ids,
summary first; simplicity is a requirement (as simple, clear, readable and parsimonious as possible; no
overengineering; no duplicated code); published precedent for every method choice with DOI and passage, or say it
is a project choice; the repository is public; never open `data/modis_albedo/requests/`. Read `CONTRIBUTING.md`,
`AGENTS.md`, `config.R`, `R/config_schema.R`, `R/paths.R`, `scripts/7a_alb_diff_full.R`, `R/differences.R`,
`tools/verify_change.R` and the verification folder's README, and the regression contract
`docs/cc/2026-10-08_single_config_regression_contract.md`, to see how settings, inputs, legacy configurations,
anchors and verification already work.

## What the design must give
1. **The setting.** The smallest change that lets the configuration choose the ice fraction: for example a
   setting naming the ice-fraction file or source (old Dalton raster, or NADI-1 optimal, minimum, maximum), read by
   script 7a in place of the fixed path, with the legacy configuration keeping the old raster. Say whether the
   readvance averaging should also become a setting (keep or average), or whether the meeting's questions can be
   answered without it; if it should, the smallest form.
2. **Building the NADI-1 fractions once.** A stand-alone data-building script (the project keeps one-off data
   building in stand-alone scripts) that turns the NADI-1 polygons into a file of the same form as the old raster
   (or whatever form script 7a most simply reads), with the area-conserving fraction per cell, the young slices
   carried forward, and a provenance note; tracked or not, by size.
3. **The runs.** How the forcing stage (script 7a onwards) is rerun from the saved headline predictions for each
   ice setting, through `tools/verify_change.R` with its seeding from saved products, and what each run costs
   (script 7a took about 67 to 76 minutes before). Which settings to run for the meeting (at least NADI-1 optimal;
   whether minimum and maximum, and readvances kept, earn their runs).
4. **The comparison and the readvance inventory.** The fewest tables and figures for the slides, made from the
   two fraction files and the runs' saved forcing tables, by the smallest script; no copy of pipeline arithmetic.
5. **The default switch and the regression results.** What making NADI-1 the default would involve later: the
   legacy configuration still reproducing the old anchors, new anchors from the NADI-1 run, and the verification
   that proves both. Keep this short; it is a later step.
6. **An implementation plan for an Opus agent**, in order, with the files touched (as few as possible), the
   checks, and the measured runtimes to record.
7. **Questions for Chris**, only where the choice is his, each answerable without reading anything else.

Summary first, in plain words, no more than half a page; then the details.
