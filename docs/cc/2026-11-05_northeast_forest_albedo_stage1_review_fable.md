*Fable (science-reviewer role), 5 November 2026: independent review of commit cc65015 (stage 1 of the northeast
forest-albedo check, written by Astra). Read-only, no R run. Issue #27.*

**Verdict.** Ready for the coverage run on correctness; the named simplifications should be made first so that the verified commit is the one that stays. No blocker found.

**Benefit.** It gives the paper a frozen, outcome-blind table of nearby pure conifer and pure hardwood 500 m pixel pairs in the northeast, and a coverage report that tells Chris whether the forest-albedo check has enough support before any albedo value is read.

**Scope note.** No shell, so `git diff 1e37c26 cc65015` and `sha256sum` were not run. The worktree files were read directly, with the `feature` worktree's copies of `tools/prepare_bluesky_albedo.R` and `tests/test_bluesky_albedo.R` as the pre-change reference (they contain the un-moved helpers and the un-moved `is_land` tests; they may not be exactly commit 1e37c26).

## Hand check

**1. Nearest partner, caliper, tie, replacement, reciprocity** (fixture `tests/test_northeast_forest_albedo.R:51-65`, worked by hand). ENF e1 at (−70, 45) and e2 at (−70.001, 45), both 100 m. DBF a and b both at (−69.99, 45), 150 m; DBF "close" at (−69.999, 45), 151 m. Ground distances at 45°N: Δlon 0.01° → 6371007.181 × 1.74533e-4 × 0.70711 = 786.3 m (a, b); Δlon 0.001° → 78.6 m (close). Elevation differences 50, 50, 51 → "close" fails the inclusive 50 m caliper; a and b tie at 786.3 m → fixed-id order picks `h12v04_a`; both ENF take it (replacement). Reverse: a's nearest ENF is e1 (786.3 m) not e2 (864.9 m) → only e1 reciprocal. Code (`R/northeast_forest_albedo.R:338-344`, `:356-362`) agrees; the test asserts exactly this.

**2. The 40°N boundary** (`R/northeast_forest_albedo.R:47-59`). One pixel row is 1/240° = 0.0041667°. Main: circle 5000/6371007.181 rad = 0.044966°, margin 1.5 px = 0.00625° → ENF centres below 40.05122°N excluded = the bottom 12 pixel rows of the tile (row 12 centre 40.0479 out, row 13 centre 40.0521 in). Stricter (3 km, 2.5 px): cutoff 40.03740° → 9 rows. Looser (10 km, 1.5 px): 40.09618° → 23 rows. The east edge of h13v04, the west edge of h11v04 and the top of v04 at 50°N cannot bind inside the padded box, so only 40°N excludes anything, as Astra states. The existing test brackets this only at 40.01 (out) and 40.1 (in).

**3. MOD44W odd offset** (`R/northeast_forest_albedo.R:148-157`, fixture `tests/test_northeast_forest_albedo.R:110-116`). Template 3×3, 2 m pixels on [1,7]²; water 8×8, 1 m on [0,8]². Water cell (4,4) covers x 3–4, y 4–5, inside template pixel (2,2) → `mask[2,2]` FALSE, 8 of 9 pass. Code agrees. 36 = 9 × 4 subpixels for 3×3; 100 for 5×5; 4 for the centre alone.

**4. Count rules** (`:530-547`). Main: 7/10 passes, 7/11 fails, zeros and NA fail, 4 panel days fail. Stricter: 20/25 and 14/20 pass, 8/20 fails; a cell with two eligible pairs loses both at the ≥3 gate. Looser: 3/6 passes, 3/7 fails. Agrees with the frozen table.

**5. Pixel ids** (`:250-251`, `:229-231`, `:256`): consistent with terra's cell numbering within a tile. Not unit-tested.

No albedo arithmetic, sign convention, kernel or stochastic element exists at this stage.

## Frozen settings, line by line

Every row of the frozen table that applies to stage 1 is implemented with the stated value for main, stricter and looser. No rule silently changed and none missing.

Choices the settings do not make, beyond Astra's list, to add to the record:
- **Elevation caliper before nearest.** `northeast_nearest` (`:338-343`) filters DBFs to |Δelevation| ≤ limit, then takes the nearest. The alternative ("nearest DBF within 5 km, then drop the pair if Δelevation > 50 m") gives fewer pairs. Astra's reading is standard caliper matching and is judged sound, but it is a choice.
- **Record-wide land rule hard-coded as `'land'`** (`:300`, driver `:41-42`) rather than read from `LAND_RULE`. Correct today; fine.

## Findings (worst first)

1. **Should-fix (scope and simplicity). Stage-2 retrieval diagnostics and a 350,000-row cell-year table are built in stage 1.** `R/northeast_forest_albedo.R:549-569`, `:632-641`, `:672-674`. `retrieval_diagnostics.csv` has about 8,424 rows × 75 columns and `retrieval_cell_year.csv` about 350,000 rows, in a go/no-go coverage run. The settings put only "retrieval counts" in the coverage-only run; the snow-share and balance diagnostics are stage 2. Fix removes about 35 lines and two outputs, leaving `retrieval_coverage.csv`.
2. **Should-fix. The second hash tag protects today's archive but leaves a gap; a single combined hash does the same in fewer lines.** `tools/prepare_bluesky_albedo.R:168`, `:175-176`, `:543-544`, `:598-600`, `:644`, `:650-651`, `:739`, `:837-843`, `:973`, plus about 20 test lines. Some record of the helper code is needed (after the move, `pixel_lonlat` and `is_land` are no longer covered by the script's hash). Existing archive behaviour is unchanged (files carry `2ee39123…`, in the accepted list; the helper check applies only to files with the current script hash). Gap: files made by an accepted older script version are never helper-checked. Cannot give a wrong result today. A combined hash over script bytes then helper bytes in the existing `paleoRF_script_sha256` tag closes the gap by construction and removes about 25–30 lines.
3. **Nit (record).** The moved `is_land` default changed from `LAND_RULE` to `'land'` (`R/modis_albedo_helpers.R:29`); Astra passes `rule = LAND_RULE` explicitly at `tools/prepare_bluesky_albedo.R:811`, so behaviour is unchanged, but the accepted-hash comment (`:199-200`, "function bodies unchanged") and the report omit the signature change. One comment line.
4. **Nit (no duplication).** The footprint is written twice (driver `:32`; `R/northeast_forest_albedo.R:224`, `:233-234`) and `2400L` is hard-coded (`:250-251`). This also makes `northeast_candidates` untestable on a small fixture. Derive the box from `cells` and the width from the template.
5. **Nit (accounting).** Outside-domain ENF are dropped without a loss row (`:247`), so losses do not telescope for "outside_pipeline_support" rows; class-screen rows carry `forest_class = 'all'`. One line or a header comment.
6. **Nit (readability).** (a) `:380-675` switch to `<-` and double quotes. (b) `c <- eligible[...]` at `:427`, `:459` shadows `c()`. (c) `northeast_monthly_metadata` (`:305-322`) re-checks build tags the cell step already enforces; 20 lines, cuttable. (d) `northeast_freeze_pairs` (`:366-372`) overwrite refusal; 6 lines, cuttable. (e) Driver `:94-104` eleven lines of prose duplicating the implementation document. (f) Driver `:28` `parallel = FALSE` is probably not a terra option. (g) Driver `:26-28` terra temp directory inside the output directory. (h) Driver `:31` reads `elev_interp_cells.RDS` from the shared checkout rather than the catalogued copy (`path_file(paths, 'elevation_cache')`).

**Not worth doing.** Floating-point near-ties; bin-edge rounding near 0.1° edges; reading the whole mosaic at once (about 3 GB, about 20 fewer lines) unless Chris prefers the simpler code.

## What the proposed verification misses
1. Boundary rows: every ENF lost at `search_boundary` has cell_y = 40.5 and latitude below 40.05122 (main), 40.03740 (stricter), 40.09618 (looser).
2. Telescoping of losses per bundle, class and cell.
3. Pixel-id round trip: tile and pixel → row and column → `xyFromCell(tile_template(tile))` → `pixel_lonlat` reproduces stored lon/lat to 1e-9.
4. Per-cell closure: `matched_enf` + `n_lost` at the partner screen = `n_before`.
5. Stratum consistency: `unflagged3` TRUE implies `wetland_stratum == 'neither'`; `reciprocal` recomputed.
6. Existing archive accepted without rebuild: one real monthly file carries `2ee39123…` and no helper tag and is accepted; `sha256sum` of `git show 1e37c26:tools/prepare_bluesky_albedo.R` equals `cb2920f6…`.
7. `northeast_check_grids` may stop on CRS (`+a/+b` against `+R`) at `:117`; if so, `crs = FALSE` plus a string check.
8. Sharper unit test: 40.0510 (out) and 40.0516 (in) for main.

## Questions for Chris or Andria
1. Elevation caliper as eligibility (as coded) or nearest-then-drop?
2. Stage-1 retrieval output: keep the diagnostics and the cell-year table, or defer to stage 2?
3. Helper identity: two tags, or one combined hash?
4. "Southern cells" for the <5 flag: any pair (as coded) or ≥3 pairs?
5. Strips (small memory) or the whole mosaic (about 3 GB, about 20 fewer lines)?

## Not checked
The value of the `cb2920f6…` hash; the HDF subdataset names; MOD44W and GMTED headers; whether `terraOptions` accepts `parallel`; Astra's claim that the tests pass; anything in `scripts/` (unchanged).
