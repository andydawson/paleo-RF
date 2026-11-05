# Brief for Astra (ultra effort): make the agreed stage-1 changes

*Chris chose, 5 November 2026, after Fable's review and Astra's review of it. Issue #27.*

Same rules as your build brief (`docs/cc/2026-11-05_northeast_forest_albedo_build_brief.md`): edit files in this
worktree only, do not commit, no network, never open `data/modis_albedo/requests/`, no full coverage run; parse every
changed file and run the four test files with `THREADS=1 OPENBLAS_NUM_THREADS=1 tools/rscript.sh`. Do not edit the
question files for Andria or write other documents beyond what is asked here.

## Chris's decisions
- Make the agreed changes, and **keep** the monthly build-tag check and the pair-table overwrite refusal.
- Elevation limit decides eligibility before nearest (as coded).
- Southern warning counts cells with any pair (as coded), with the three-pair count beside it.
- Keep reading in strips.

## The changes (from your review, `docs/cc/2026-11-05_northeast_stage1_review_codex_gpt6astra.md`)
1. Defer the retrieval diagnostics and the cell-year output to stage 2; keep retrieval coverage.
2. One combined code digest (script bytes then helper bytes) in the existing `paleoRF_script_sha256` tag, replacing
   the second tag; the approved historical digests stay accepted; update the compatibility tests.
3. Derive the candidate search bounds from the selected cells and the tile width from the inputs.
4. Record the outside-domain ENF removal as an explicit screen, so the losses reconcile.
5. Write the cell-level screen losses that already exist in memory.
6. Read and record the catalogued elevation cache (`path_file(paths, 'elevation_cache')`).
7. Shorten the coverage notes to the coverage-only statement, the pair identity and the instruction to return the
   coverage to Chris.
8. Rename `c`; use the file's `=` and single-quote style in the code you touch.
9. Tests: sharp boundary brackets for main, stricter and looser; pixel-id round trip including tile and strip joins;
   a small candidate-building fixture; loss reconciliation.

Also update `docs/cc/2026-11-05_northeast_forest_albedo_stage1_implementation.md` where these changes make it wrong.

## Report
Files changed and why; lines before and after for each code file; test results; and a draft verification spec
(`docs/cc/verification/` format, see existing `2026-11-05_*.R` specs) whose checks cover your review's final list,
written to `docs/cc/verification/2026-11-05_northeast-coverage.R` with `commit = 'TO_FILL'`.
