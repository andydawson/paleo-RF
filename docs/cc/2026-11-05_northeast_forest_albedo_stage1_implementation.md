# Northeast forest-albedo stage 1: pairs and coverage

Issue #27; implementation for Chris, 5 November 2026. This stage establishes whether the
paper's proposed local forest comparison has adequate geographic support before anyone
examines its albedo contrasts. The approved 3 November design and frozen settings govern
the implementation. Nothing is committed, downloaded or run over the full footprint here.
Fable's review and Astra's subsequent reconciliation remain to follow.

## Implementation

`tools/check_northeast_forest_albedo.R` reads the shared native inputs, checks their grids,
builds candidates in small strips, applies the record-wide land rule, freezes three pair
tables, and writes structural and count-only retrieval coverage. Its functions live in
`R/northeast_forest_albedo.R`. No albedo sum or value enters the driver or its helpers.

The driver writes `fixed_pairs.rds`, full-precision `eligible_candidates.rds`, readable `pairs_{main,stricter,looser}.csv` and
`candidates_{main,stricter,looser}.csv`, structural/cell coverage, distance and elevation
summaries, DBF reuse, wetland strata, sequential screen losses, outside-cell candidate
support and feasibility flags into `output/northeast_forest_albedo/`. Retrieval outputs
give monthly coverage by version, panel, latitude and wetland stratum; year-specific
before/after count diagnostics; and all cell-years, including zeros. Run metadata records
the settings, exact inputs, build tags, code hashes and fixed-pair identity. The normal
`run$dir` redirection and run manifests are used, so the verification tool can run it.

Screen order is first-year forest class (including a total for excluded nonforest/missing
labels), nine-year centre stability, centre QC, complete neighbourhood, neighbourhood
class persistence, MOD44W land, complete valid GMTED neighbourhood, relief, complete ENF
search, record-wide land, then availability of a partner within both distance and elevation
limits. Losses are sequential; their sums are not independent estimates of each cause.

`R/modis_albedo_helpers.R` contains the moved grid constants, `tile_template`, `pixel_lonlat`
and `is_land`. Preparation sources them. Parsed comparison with the preceding code found
the constants and function bodies identical. The shared land default is literal `land`;
preparation explicitly passes its `LAND_RULE`, including its existing shoreline option.

New monthly files record `paleoRF_modis_helpers_sha256` as well as their script hash;
build reuse and the cell step check both for new files. The cell step still accepts the
existing historical script hashes without a helper tag, since those scripts contained the
helpers. The pre-extraction hash
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
4. Read all DBF candidates in the target rectangle plus the largest search-radius buffer;
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
    `run$dir`. Terra temporary files go under the local output directory.
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
2001–2009. The 83 pipeline cells come from `elev_interp_cells.RDS`.

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

Use `tools/verify_change.R` with a spec containing the full implementation commit, the
normal `config.R`, script `tools/check_northeast_forest_albedo.R`, no seeds or anchors for
this new coverage product, and environment `THREADS=1`, `OPENBLAS_NUM_THREADS=1`. Its run
directory must be new. Include the four unit checks:

- `tests/test_modis_albedo_helpers.R`
- `tests/test_bluesky_albedo.R`
- `tests/test_northeast_forest_albedo.R`
- `tests/test_northeast_forest_coverage.R`

The post-run checks should verify: the 27 filenames and sizes, all 354 tile-month inputs,
unchanged native grids, 83 cells including zeros, complete per-band/per-half coverage,
sequential nonnegative screen losses including explicit boundary/partner exclusions,
unique ENF IDs and correct DBF reuse, each chosen partner's eligibility and nearest/tie
rule, inclusive radius/elevation/relief limits, exact recomputation of feasibility flags,
unknown wetland handling, stricter diagnostics as subsets, correct count thresholds and
cell-year gates, and pair identity unchanged after count reading. Recompute pairs from
`eligible_candidates.rds` and compare exactly (the CSVs are for reading, not exact floating-point
round trips). An empty or thin result must still be a
valid completed run and must flag Chris. Software PASS does not mean feasibility PASS.

Verify the extraction with the unchanged historical cell-total fixtures and both land
rules; no scientific albedo regeneration is justified for this extraction. Retain the
tool's normal completed-manifest, output-hash and unchanged-input checks. The code stores
monthly input sizes/mtimes and build identities; compare these before and after if the
archive is being read by other concurrent jobs.

Direct driver command (for that later verification, not run in this session):

```sh
THREADS=1 OPENBLAS_NUM_THREADS=1 tools/rscript.sh tools/check_northeast_forest_albedo.R
```

The wrapper resets BLAS/OMP/MKL threads from `THREADS`, so setting only
`OPENBLAS_NUM_THREADS` would not enforce one thread. No full coverage result exists yet.

## Checks in this session

All eight new or changed R files parsed. All four unit-test files listed above passed.
Tests cover native coordinates and cell/tile boundaries, historical build hashes and
both land rules, nearest eligible partners/ties/reuse/no partner, spherical distances,
inclusive elevation/relief/count thresholds, nine-year class neighbourhoods across tile
joins, odd MOD44W subpixel offsets, native DEM boundaries and incomplete relief, wetland
unknowns, immutable pair tables, count-only reads when synthetic albedo sums are changed,
cell-year gates and missing years. Zero-candidate structural and retrieval reports were
also checked; no retrieval reader was called. The separate implementation check found and
fixed one actual defect: assigning a scalar land flag to an empty candidate table. No
speculative findings were retained or dropped, and no test remains failing.

Small real-input reads checked one five-row strip of three 2001 HDFs, aligned water,
native elevation/relief, selected land/retrieval count pixels, and one monthly metadata
record. The 27 approved filename/byte-count entries match and all 354 monthly paths exist.
No albedo-value band was read. The full coverage driver, verification tool, downloads and
network were not run; no commits or pushes were made. Work remains on
`northeast-forest-check`, awaiting Fable's review, Astra's reconciliation, Chris's commit
and coverage verification. README tables remain for stage 2 as instructed.
