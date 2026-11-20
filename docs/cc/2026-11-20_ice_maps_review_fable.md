# Review of the ice-maps build (Fable, change-reviewer), 20 November 2026

Reviewed: commits `cb6ca54`, `3f55868` and `4e8532c` on branch `ice-maps`, in `/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps`, against the "Approved build" in `docs/cc/2026-11-20_ice_maps_design.md` (lines 84-105). Read-only; nothing was run. I had no shell, so the diff was rebuilt by comparing the head files with the pre-change copies in `/home/expert/Documents/contracting/Andria/paleo-RF-verify/c0b6eda` (see "Not checked").

**Verdict.** Mergeable once both verification reports say PASS and the printed counts of the NADI-1 check have been read. I found no blocker by reading. One record is missing (the changelog entry) and there are four nits, two of which remove a line.

## Deletions first

| File:line | What could go | Lines |
|---|---|---|
| `README.md:243-244` | "The setting also picks the ice that script 7 draws and flags on its maps." repeats lines 238-239, five lines above. | -1 |
| `scripts/7_plot_preds.R:402-403` | "A NADI-1 file has its own band for every slice, so there every age finds its outline." repeats the comment on line 61. | -1 |

Nothing in the code itself can go: the NADI-1 block (lines 53-64) is eight statements, and `ice_aes` replaces eleven repeated mappings with one name.

## Findings

| Severity | File:line | What is wrong | Consequence | Evidence | Check; lines |
|---|---|---|---|---|---|
| should-fix | `docs/cc/changelog_single_config_migration.md` (last entry at line 2008) | No entry for this change. The approved build lists one (design line 103). | Coauthors are not told that a NADI-1 run now gives different script 7 tables, maps and slide-18 recipe table. | No match for "ice-maps", "map ice" or "20 November"; the last heading is the case-study boxes of 19 November. | Add the entry with the two verification reports. About +6. |
| nit | `R/paths.R:58-60`; `tools/build_nadi1_fractions.R:12` | Both comments say only script 7a reads the NADI-1 files. Script 7 now reads them too (`scripts/7_plot_preds.R:53`). | A reader of the file catalogue is told the wrong readers; the README is right. | Lines cited. | Reword, 0 net lines. Both files are outside the approved file list (see Questions). |
| nit | `README.md:243-244` | Duplicate sentence (table above). | Bloat. | Lines 238-239 and 243-244. | -1. |
| nit | `scripts/7_plot_preds.R:402-403` | Repeats line 61 (table above). | Bloat. | Lines cited. | -1. |
| nit | `scripts/7_plot_preds.R:59` | The implementer reports that the `hole` column of the saved `ice_fort*` tables is wrong on the NADI-1 path. The script does not say so. | Nothing in the pipeline reads it, but anyone opening the table could trust it. | No use of `hole` in `scripts/`, `R/`, `tools/` or `tests/` (search). The mislabelling itself I could not confirm by reading. | A few words in the existing trailing comment, 0 lines. Chris's call whether it is worth it. |

## 1. Is each path right?

**Old raster (`"dalton_ice"`): unchanged.**
- Lines 40-48 are the old lines 37-46 inside the `if`, indented, with the same `polygon_age()` and `ice_match()`.
- `ice_aes = aes(x=long, y=lat, group=group)` (line 48) is the mapping every ice layer had before.
- The two loops, the coarse differences and the three `write_output()` calls are untouched.
- The legacy anchors would detect any slip in the tables. They do not see figures.

**NADI-1: right by reading.**
- **Flags.** `SYMB = 'ICE'` (line 58) is the only attribute the flag loop picks (line 150). A cell outside the polygons gets NA from `over()`. So the flag is `'ICE'` or NA, as script 9 needs (`scripts/9_forcing_barplot.R:378` masks any non-NA value).
- **Threshold.** Strict `>` (line 56), the same as script 7a (`R/differences.R:58-59`). Script 7 uses the stored fraction; 7a's default method classifies the readvance-averaged one (`R/differences.R:52-56`). The comment on lines 50-52 says this accurately.
- **NA cells.** `ifel(NA > threshold, 1, NA)` is NA, and `as.polygons()` leaves NA cells out, so a cell with no fraction is never ice. Script 7a drops such cells (`scripts/7a_alb_diff_full.R:89`); script 7 keeps them unflagged.
- **11,500 BP and the young slices.** `ice_years` comes from the band names (line 54, the same expression as `7a_alb_diff_full.R:49`). `polygon_age()` is the identity, so each of the 25 slices takes its own band. Lines 404 and 406 then find an outline for 50 and 500 BP.
- **Outlines and holes.** All eleven ice layers use `ice_aes`: lines 223, 240, 260, 279, 298, 312, 330, 452, 453, 473 and 474. The only `group = group` left belongs to the land boundaries. Every faceted layer has one slice per panel, so `group = id` cannot merge two slices.
- **Manifest.** The NADI-1 file is read through `read_input()` with its catalogue id (line 53). The glacier outlines are read only on the old path (line 40), so a NADI-1 run's manifest lists what it used.
- **Settings.** No new key. `configs/legacy_config.R` is untouched and still names the old raster (line 104).

## 2. Would the verification catch a wrong result?

**Legacy spec** (`/home/expert/Documents/contracting/Andria/paleo-RF/docs/cc/verification/2026-11-20_ice-maps-legacy.R`)
- It covers all ten anchored files, script 9's recipe table included. Any change to the old path's tables fails it.
- It does not run `config.R`'s own default. There the only difference is the `age == 11500` case of `polygon_age()`, a line that did not change.
- Its script 7 log shows the `proj4string<-` warning on the old path too, so that warning is not new with NADI-1.

**NADI-1 spec** (`/home/expert/Documents/contracting/Andria/paleo-RF/docs/cc/verification/2026-11-20_ice-maps-nadi1.R`)
- **Flags against the raster by band name** is independent of the polygon route. It catches a wrong band, a wrong rule, NA cells flagged, and `over()` flagging an enclosed ice-free cell.
- **Ring parity of the saved outline against the flags** catches a missing or extra hole ring, provided an enclosed ice-free cell is a prediction cell.
- **It can pass on nothing.** `bad == 0` holds if no row matches an age. The per-age line prints the counts: check that "cells" and "flagged ICE" are above zero at the older ages.
- **Difference outlines** are tested for presence only (seven periods each), not for which slice they hold. That code is unchanged and subsets `ice_fort`, which the parity check covers.
- **Not covered:** the drawing itself, and the minimum and maximum reconstructions.
- **By eye:** an enclosed ice-free cell at 8 ka shows its tile (Astra's review names 67.5 W, 63.5 N); the two youngest difference panels now have outlines.
- `tests/test_paths.R` is safe in the spec: the file it needs is in the frozen inventory (`tests/frozen_inputs.md5:228`), which `tools/verify_change.R:96-106` links into the verification worktree. Earlier reports show it exiting 0 there.

## 3. Comments, README and questions entry

- Script comments (lines 37-38, 50-52, 61-63, 119-121, 399-403) are accurate and say why.
- `config.R:104-107` and `129-130` are accurate.
- `README.md:118`, `196` and `236-239` are accurate.
- The questions entry (`docs/cc/questions_for_andria_general.md:197-203`) now points at the right lines (404-406) and limits the quirk to the 21 outlines. It stays open.
- Nothing turns a doubt into a decision. The default stays `"dalton_ice"`, and whether NADI-1 becomes the default stays with Andria.
- The last commit's message matches its diff.

## 4. Scope and line cost

Nothing goes beyond the approved build: no new setting, guard, file, helper or test; scripts 7a, 8 and 9, `R/`, `tests/` and the legacy configuration are untouched.

| File | Added / removed (as git counts, approximate) | Net | Approved estimate |
|---|---|---|---|
| `scripts/7_plot_preds.R` | +46 / -25 | +21 (14 code, 8 comment, 1 blank line removed) | +21 / -2 |
| `config.R` | +5 / -3, comments only | +2 | +2 / -1 |
| `README.md` | about +8 / -5 | +3 | +5 / -4 |
| `docs/cc/questions_for_andria_general.md` | +3 / -2 | +1 | +2 / -1 |
| **Total** | | **+27** | |
| Changelog (outstanding) | about +6 | | +6 |
| The two verification specs | 16 and 57 lines, plus their reports | | |

The script's larger added and removed counts come from indenting the old-path block and eleven one-for-one substitutions. The two deletions above would bring the net to +25.

## Right

- All eleven ice layers use `ice_aes`; the old path's mapping is unchanged.
- The flag is `'ICE'` or NA on both paths.
- Strict `>`, as in script 7a.
- Every slice has its own band (`tools/build_nadi1_fractions.R:74-77, 213`), and 500, 200 and 50 BP equal 1,000 BP (line 220).
- The NADI-1 files are on the old raster's one-degree grid in longitude and latitude (`tools/build_nadi1_fractions.R:106-116, 214`).
- Every read is on the manifest; the stale-input check is unchanged; no schema change was needed.
- Nothing reads the `hole` column.

## Questions for Chris

1. **The two stale comments in `R/paths.R:58-60` and `tools/build_nadi1_fractions.R:12`.** Reword them in this branch (0 net lines, comment only), or leave them because the approved build lists `R/` as not touched? Meanwhile they say only script 7a reads the NADI-1 files.

## Not worth doing

- **NADI-1 with the legacy relabelling of the oldest slice** (not built, Chris's choice). By reading, the flags and the map outline still take the 11,500 BP band, because `ice_match()` picks the nearest. Only the oldest period's older difference outline would be missing, without a message. No configuration in the repository combines the two.
- **A slice with no cell above the threshold.** The script would stop at line 59 or in the first loop; it would not give a wrong result.
- **Silencing the `proj4string<-` warning.** It already appears on the old path.
- **A shared helper for the two lines script 7 now has in common with script 7a** (the read and the band-name parse).
- **Unit tests of the inline block.** The check on real data is stronger.
- **Fixing the per-age pages' `year == year` bug, or the neighbouring stale line references in the questions file** (`:303` and `:355` are 297 and 332 on this branch). Both pre-date this change.
- **Adding a content check of the difference outlines to the spec.**

## Not checked

- **The exact diff and commit bodies.** I compared with `/home/expert/Documents/contracting/Andria/paleo-RF-verify/c0b6eda`, whose script 7 matches the described base. Its README differs from the true base by three unrelated lines, so the README counts are approximate. I read the commit subjects (reflog) and only the last commit's body.
- **Anything that needs R.**
  - That `as(..., 'Spatial')` returns one object per band with usable rings.
  - That `fortify()` gives the nine columns.
  - That `over()` decides by ring parity. I believe it does from sp's source, which is not in the repository; the flag check proves it either way.
  - The drawing of holes.
  - The ggplot2 version (the log's deprecation warning only shows 3.4.4 or later).
- **The rasters.** Their CRS string, band names and enclosed cells are taken from the build tool's checks and Astra's review.
- **The verification results.** When I looked, the legacy run had written `ice_fort.RDS` and was drawing figures; the NADI-1 run had not started.
- **The minimum and maximum reconstructions.**

Key files:
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps/scripts/7_plot_preds.R`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps/config.R`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps/README.md`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps/docs/cc/questions_for_andria_general.md`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps/docs/cc/changelog_single_config_migration.md`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps/R/paths.R`
- `/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice-maps/tools/build_nadi1_fractions.R`

Files read: 25 (11 in part), 8 more searched only. Tool calls: 58.
