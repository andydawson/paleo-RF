# Brief for Astra (ultra effort): write the northeast forest-albedo check, first stage (pairs and coverage only)

*Chris, 5 November 2026: Astra writes the code; Fable then reviews it, then Astra reviews Fable's review and the code
again. Issue #27.*

## Where you are and what you may do
- You are in a git worktree of paleo-RF on the topic branch `northeast-forest-check` (off `feature/single-config`).
  **You may create and edit files in this worktree only.** Do not commit (I commit). Do not touch any other checkout;
  in particular never write to `/home/expert/Documents/contracting/Andria/paleo-RF` (the main checkout) and never
  open `data/modis_albedo/requests/` anywhere.
- No downloads, no network.
- You may run R to check your code: `tools/rscript.sh -e '...'` or `tools/rscript.sh tests/<file>.R` (the project's
  R environment). Parse every file you write, and run the unit tests you write. You may also run small reads of the
  input files to learn their structure (for example, open one MCD12Q1 file with terra and list its layers). Do **not**
  run the full coverage run: that goes through the project's verification tool afterwards.
- Keep memory use small and use one thread: `OPENBLAS_NUM_THREADS=1`; other jobs are running on this machine.

## What to build: stage 1 of the approved design
Read first, in this worktree:
- `docs/cc/2026-11-03_northeast_forest_albedo_design_v2_codex_gpt6astra.md` (the approved design: sections 2, 3
  "Candidates and fixed pairs", 5, 7 and 8);
- `docs/cc/2026-11-03_northeast_forest_albedo_settings.md` (the **frozen settings**: Astra's final table and Chris's
  decisions). Use the frozen values exactly; do not change or reinterpret a setting. Where the code needs a choice the
  settings do not make, choose the plainest option, mark it in a comment, and list it in your report.
- `AGENTS.md`, `CONTRIBUTING.md`, `tools/prepare_bluesky_albedo.R` (the existing MODIS grid and land functions),
  `tests/` (conventions), `config.R` and `R/` (how paths and inputs are found).

Stage 1 is **the forest pairs and their coverage, with no albedo value read** (design section 3; settings: "No
automatic relaxation"). It ends with the coverage report that goes back to Chris before any contrast is computed.
1. **Shared helpers.** Move (not copy) `tile_template`, `pixel_lonlat`, their grid constants and `is_land` from
   `tools/prepare_bluesky_albedo.R` into `R/modis_albedo_helpers.R`, with their tests, as design section 7 says;
   `tools/prepare_bluesky_albedo.R` sources them. Its behaviour must not change. Section 7 notes that the preparation
   script checks hashes of its own code; handle that so existing built files are still accepted without a rebuild,
   and say exactly how.
2. **Candidates and the fixed pair table**, from the 27 MCD12Q1 files in
   `/home/expert/Documents/contracting/Andria/paleo-RF/data/mcd12q1/` (read-only), MOD44W-2015 and GMTED2010 in that
   checkout's `data/` (find them; read-only), and the record-wide land rule from the albedo build's counts (find how
   `is_land` uses them). Apply every frozen rule for the main settings, and the stricter and looser bundles. Pair table
   frozen and written to `output/northeast_forest_albedo/`.
3. **The coverage report**, everything the settings and design section 2 list for the coverage-only run: eligible ENF
   and DBF pixels, matched pairs, unique DBF partners and reuse, pipeline cells represented and without pairs, pair
   distances and elevation differences, wetland strata (neither/one/both), losses at each screen, excluded boundary
   centres, by one-degree latitude band and the two halves, and the feasibility targets (≥300 distinct pairs; ≥30
   cells with ≥3 pairs; southern cells reported, fewer than 5 flagged for Chris), for main, stricter and looser.
   Retrieval counts belong to the coverage run only if they can be read without any albedo value; if they cannot be
   separated cleanly, leave them for stage 2 and say so.
4. **Tests** for the invariants that apply at this stage (design section 8: nearest partner, ties, replacement, no
   partner, tile edges, ground distance, elevation and relief thresholds, cell assignment, outcome blindness of the
   pair table) and for the moved helpers (coordinate, tile-boundary and cell-boundary cases).
5. Paths: the worktree has no raw data. Use the project's existing way of pointing at shared inputs if there is one;
   otherwise one clearly named setting at the top of the driver. Do not copy data into the worktree.

Not in stage 1: albedo sums, contrasts, snow panels, the model comparison, figures, README tables (stage 2 onward).

## Rules for the code (Chris)
- As simple, clear, readable and parsimonious as possible; no overengineering; readability before elegance. A
  scientist who knows R (Andria) must be able to read the driver top to bottom.
- One readable driver `tools/check_northeast_forest_albedo.R` with a short settings block; small functions with a
  stated purpose in `R/northeast_forest_albedo.R`; comments say why, not what. No duplicated code. Plain words in
  comments, no private ids.
- Never remove a `library()` call; `terra` and `sf` set up PROJ.

## Report (your final message)
- Files created or changed, and why, in a few lines each.
- Every choice you made that the frozen settings did not make.
- What you ran (parse, tests, small reads) and the results, including any test that fails.
- What the verification spec for the coverage run should check, and the command to run the driver.
- Anything in the design that turned out not to work with the real files.
