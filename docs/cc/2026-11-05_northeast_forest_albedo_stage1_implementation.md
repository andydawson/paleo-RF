# Northeast forest-albedo stage 1: pairs and coverage

Issue #27; implementation for Chris, 5 November 2026. This stage establishes whether the
paper's proposed local forest comparison has adequate geographic support before anyone
examines its albedo contrasts. The approved 3 November design and frozen settings govern
the implementation. Updated after Fable's review, Astra's reconciliation and Chris's
5 November decisions. This follow-up makes no commits, downloads or full coverage run.

## Implementation

`tools/check_northeast_forest_albedo.R` reads the shared native inputs, checks their grids,
builds candidates in small strips, applies the record-wide land rule, freezes three pair
tables, and writes structural and count-only retrieval coverage. Its functions live in
`R/northeast_forest_albedo.R`. No albedo sum or value enters the driver or its helpers.

The driver writes `fixed_pairs.rds`, full-precision `eligible_candidates.rds`, readable `pairs_{main,stricter,looser}.csv` and
`candidates_{main,stricter,looser}.csv`, structural/cell coverage, distance and elevation
summaries, DBF reuse, wetland strata, sequential screen losses at regional and cell level,
outside-cell candidate support and feasibility flags into `output/northeast_forest_albedo/`.
Retrieval outputs give monthly coverage by version, panel, latitude and wetland stratum. Retrieval
diagnostics and the cell-year output are deferred to stage 2; the eligibility masks
and regional retrieval coverage remain unchanged. Run metadata records
the settings, exact inputs, build tags, code hashes and fixed-pair identity. The normal
`run$dir` redirection and run manifests are used, so the verification tool can run it.

Screen order is first-year forest class (including a total for excluded nonforest/missing
labels), explicit removal of ENF centres outside the selected cells (`enf_scope`),
nine-year centre stability, centre QC, complete neighbourhood, neighbourhood
class persistence, MOD44W land, complete valid GMTED neighbourhood, relief, complete ENF
search, record-wide land, then availability of a partner within both distance and elevation
limits. Losses are sequential; their sums are not independent estimates of each cause.
`screen_losses_cell.csv` preserves the raw strip-level rows: sum repeated
bundle/class/cell/screen keys before reconciling. The initial `all` class screen includes
nonforest and missing labels; its survivors equal the combined ENF/DBF scope-screen
input. A missing cell key denotes search support outside the selected cells.

`R/modis_albedo_helpers.R` contains the moved grid constants, `tile_template`, `pixel_lonlat`
and `is_land`. Preparation sources them. Parsed comparison with the preceding code found
the constants and function bodies identical. The shared land default is literal `land`;
preparation explicitly passes its `LAND_RULE`, including its existing shoreline option.

New monthly files store one SHA-256 digest of the exact preparation-script bytes followed
by the shared-helper bytes in `paleoRF_script_sha256`. Both build reuse and the cell step
check that combined identity; no second tag is written. The cell step still accepts the
approved historical script hashes unchanged, since those scripts contained the helpers.
The pre-extraction hash
`cb2920f6357010ada20c311d31cc90fc7cee00cafbee9358dc2f1735e9684638` was added to that list;
the archive's existing `2ee39123d879995c219b65b1749726384d2351e9b990bf05d6d7ffa6b6ba1aa5`
was already accepted. Existing files therefore need no rebuild for cell use. Build-time
reuse keeps its earlier stricter script-identity policy. Synthetic cell totals still agree
for every accepted historical hash, and both land rules pass the existing fixtures.

## Choices left unspecified by the frozen settings

These implementation details do not change a frozen threshold:

1. Use the existing MODIS sphere, radius 6,371,007.181 m, for great-circle distances.
2. Use fixed IDs `<tile>_<seven-digit one-based row-major cell number>`; exact distance ties
   use ascending ID. Matching uses 0.1-degree search bins only to find possibilities; the
   final tests use exact great-circle distance and elevation difference.
3. Require the bounding longitude/latitude rectangle of each search circle, mapped to the
   sinusoidal grid, to fit inside the joined classification map with the partner's full
   neighbourhood. This conservative outer-boundary test can exclude a few extra centres.
   Internal tile joins are not boundaries. Both forest classes need full neighbourhoods;
   only ENF anchors need a complete partner search.
4. Derive the target rectangle from the selected cells' outer edges and add the largest
   search-radius buffer; derive each tile's column count from the mosaic and tile count.
   Read all DBF candidates inside those bounds;
   allow partners outside the 83 cells. Candidate coverage uses each candidate's own cell;
   outside-cell DBFs are reported separately. Pair coverage always uses the ENF cell.
5. A member is wetland TRUE if flagged in any year; FALSE only if all required flags are
   known and unflagged; otherwise NA. Pairs with an uncertain member are a separate
   `unknown` stratum. The stricter unflagged diagnostic requires both 3 x 3 neighbourhoods
   to be known and unflagged throughout all nine years.
6. Reciprocal matching compares the chosen DBF with eligible ENF anchors in the target
   cells, using the same distance, elevation and ID rules. Both stricter diagnostics are
   subsets of the frozen stricter pairs; they never rematch the forward pairs.
7. Interpret "southern cells" for the fewer-than-five warning as cells with at least one
   pair; also report southern cells with at least three pairs. Other feasibility targets
   remain exactly 300 distinct pairs and 30 cells with at least three pairs.
8. Use min, 5th percentile, median, mean, 95th percentile and max for descriptive numeric
   summaries; R's default type-7 quantiles. Elevation differences are absolute, as for
   matching; each member's elevation remains in the candidate table. These are not
   uncertainty intervals.
9. Within each stricter diagnostic subset apply its own three-pair cell-year gate; wetland
   display rows then subdivide that eligible sample without another gate or rematch.
10. Read 48 forest rows at a time with a two-row halo. Read only candidate/pair positions
    from selected monthly count bands. Keep all 118 months for the record-wide land rule,
    and exactly 108 months for 2001–2009 retrieval coverage; missing files stop the run.
11. Use a clearly named `SHARED_DATA` setting because `R/paths.R` has no shared-input-root
    setting. Native files stay read-only in the existing checkout; products follow
    `run$dir`. Read the pipeline cell domain through
    `read_input(run, path_file(paths, 'elevation_cache'))`, recording its catalogued path
    and MD5. Terra temporary files go under the local output directory.
12. A rerun accepts an identical RDS pair table; a changed table requires a separate run
    directory. Store pair-table and code MD5s, exact input names/sizes/mtimes and monthly
    build tags without hashing the enormous monthly albedo payloads. Check MCD12Q1 names
    and byte counts against the approved local acquisition manifest (no published checksums).
13. Report failures and stop at coverage for every bundle, including an all-empty result;
    a failed feasibility target is a scientific review flag, not a software error or an
    instruction to choose another bundle automatically.

## Input findings and limits

All 27 MCD12Q1.061 files are present and expose `LC_Type1`, `QC`, `LC_Prop3` directly through
terra. The acquisition manifest records approval on 4 November and published byte counts.
The 250 m MOD44W-2015 mosaic aligns two-to-one with the forest grid, including its odd row
and column offsets; code zero explicitly means land. The native GMTED ArcInfo grid retains
its roughly -0.000138889-degree origin offset. Its zero elevations remain valid here;
the land-mean preparation script's different zero-as-sea convention is not borrowed.

The available three v04 forest tiles end at 40°N. The complete-search requirement really
does exclude centres near that edge, by different amounts for each bundle. The loss
tables expose these exclusions; there is no southern truncation or inferred classification.
No additional source is needed to implement the approved boundary rule.

Count bands can be selected independently in the monthly files. Thus retrieval coverage
is included in stage 1 rather than deferred. The land rule uses March 2000–December 2009,
matching the albedo preparation, while forest persistence and retrieval coverage use
2001–2009. The 83 pipeline cells come from the catalogued `data/elev_interp_cells.RDS`.

## Scientific precedents carried forward

This implements the already approved judgements; no new scientific estimator is proposed.
The design records the supporting passages and their limits:

- Zhao, K. & Jackson, R. B. (2014). Biophysical forcings of land-use changes from potential
  forestry activities in North America. *Ecological Monographs* 84, 329–353.
  DOI: 10.1890/12-1705.1, methods pp. 333–335: local forest comparison, terrain controls and
  one-degree aggregation, not this exact matching recipe or thresholds.
- Stuart, E. A. (2010). Matching methods for causal inference: A review and a look forward.
  *Statistical Science* 25, 1–21. DOI: 10.1214/09-STS313, sections 1 and 3.1.3: matching
  with replacement and assessing support/balance before outcomes.
- Friedl, M. & Sulla-Menashe, D. (2022). *MODIS/Terra+Aqua Land Cover Type Yearly L3 Global
  500m SIN Grid V061*. NASA LP DAAC. DOI: 10.5067/MODIS/MCD12Q1.061; the design cites its
  guide for labels, QC and the wetland flag.
- Danielson, J. J. & Gesch, D. B. (2011). *Global multi-resolution terrain elevation data
  2010 (GMTED2010).* USGS Open-File Report 2011–1073. DOI: 10.3133/ofr20111073. The existing
  elevation documentation records its native grid convention and mean-elevation source.

No network or new reference-checker run was performed in this implementation session.
The approved design's outstanding automated reference-check record remains outstanding.

## Verification after review and Chris's commit

The draft spec is `docs/cc/verification/2026-11-05_northeast-coverage.R`, with
`commit = 'TO_FILL'`. After Chris commits the reviewed code, fill in the full revision
and run it through `tools/verify_change.R` in its separate worktree and a fresh run
directory, with `THREADS=1` and `OPENBLAS_NUM_THREADS=1`. The spec parses the changed R
files and runs the four tests:

- `tests/test_modis_albedo_helpers.R`
- `tests/test_bluesky_albedo.R`
- `tests/test_northeast_forest_albedo.R`
- `tests/test_northeast_forest_coverage.R`

Its checks cover the approved input catalogue and native geometry, the 83-cell domain,
pixel-ID round trips, boundary and strip/tile fixtures, independent sampled nearest
partners against all eligible DBFs, thresholds, wetland subsets and reciprocity. Cell
losses reconcile from the initial class screen through scope exclusion and partner
availability; regional coverage and feasibility flags are recomputed, including zero-pair
cells. Count eligibility is independently reconstructed for January, July and December
in all nine years, including the stricter cell-year gate and represented-year accounting;
this is a sample of months, not an independent check of every retrieval output row.

The historical-build fixtures check unchanged cell totals and both land rules, sensitivity
of the combined digest to either code file, historical acceptance without a helper tag,
and rejection of unapproved identities. No archive rebuild is needed. The spec also
checks completed manifests, output hashes, unchanged recorded inputs and pair identity
after count reading. Return coverage and feasibility to Chris before stage 2: a software
PASS does not establish scientific feasibility, and an empty or thin result must remain
a valid completed run with the review flag set.

Direct driver command (for that later verification, not run in this session):

```sh
THREADS=1 OPENBLAS_NUM_THREADS=1 tools/rscript.sh tools/check_northeast_forest_albedo.R
```

The wrapper resets BLAS/OMP/MKL threads from `THREADS`, so setting only
`OPENBLAS_NUM_THREADS` would not enforce one thread. No full coverage result exists yet.

## Checks in the original build and the agreed-change follow-up

The original build parsed eight new or changed R files and passed all four tests. Its
small real-input reads checked one five-row strip of three 2001 HDFs, aligned water,
native elevation/relief, selected land/retrieval count pixels and one monthly metadata
record. The 27 approved filename/byte-count entries matched and all 354 monthly paths
existed. The original independent check found and fixed one defect: assigning a scalar
land flag to an empty candidate table.

The follow-up adds sharp southern-boundary brackets for all three bundles, a small
candidate-building fixture across tile and strip joins, pixel-ID coordinate round trips,
loss reconciliation and combined-digest compatibility checks. The cell-loss export is
checked against the original rows, including repeated strip keys. The retrieval fixture
checks that coverage is the sole retrieval output and retains its existing count and
year-accounting assertions. All seven changed/new R files parse, all four tests pass
with `THREADS=1 OPENBLAS_NUM_THREADS=1 tools/rscript.sh`, and the draft spec passes
`read_spec()` without executing its coverage checks. The strip/whole fixture permits
`1e-12` numerical tolerance (observed latitude roundoff was `1.11e-16` degrees); pixel
IDs must still match exactly and coordinate round trips must be within `1e-9` degrees.

Independent review found no confirmed defect in the code changes. Two non-defects were
dropped: processing outside-domain ENFs before recording their exclusion, and repeated
strip rows in the cell-loss output. Both remain bounded and reconcilable. Spec review
found and fixed a CSV integer/double mismatch that would have caused a false failure.
Read-only metadata checks confirmed native GMTED bounds and input sizes; no coverage
functions were run.

No full coverage run, verification run, download, network access, commit or push was made
in either implementation session. No albedo-value band from the archive was read, and the
requests directory was never opened. The changes remain in `northeast-forest-check` for
Chris's review, commit and coverage verification. README tables remain for stage 2.
