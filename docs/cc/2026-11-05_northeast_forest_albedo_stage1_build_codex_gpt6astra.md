Implemented stage 1, ready for Fable’s review. No commits, network access, downloads or full coverage run. Real pair tables and coverage results remain for verification.

Files changed:

- [Driver](/home/expert/Documents/contracting/Andria/paleo-RF-wt/northeast/tools/check_northeast_forest_albedo.R): builds and freezes main/stricter/looser pairs, then writes structural and count-only retrieval coverage using project run manifests.
- [Forest helpers](/home/expert/Documents/contracting/Andria/paleo-RF-wt/northeast/R/northeast_forest_albedo.R): candidate screens, matching, coverage and diagnostics.
- [Shared MODIS helpers](/home/expert/Documents/contracting/Andria/paleo-RF-wt/northeast/R/modis_albedo_helpers.R) and [preparation script](/home/expert/Documents/contracting/Andria/paleo-RF-wt/northeast/tools/prepare_bluesky_albedo.R): helpers moved without changing their bodies. Historical script hashes remain accepted without helper tags; the pre-extraction hash was added. New files require both hashes. Existing archive use needs no rebuild; build-time reuse remains strict.
- Three new test files and the updated blue-sky tests cover selection, geometry, coverage and compatibility.
- [Implementation report](/home/expert/Documents/contracting/Andria/paleo-RF-wt/northeast/docs/cc/2026-11-05_northeast_forest_albedo_stage1_implementation.md), both living question files and a [branch/worktree inventory](/home/expert/Documents/contracting/Andria/paleo-RF-wt/northeast/docs/cc/2026-11-05_northeast_forest_albedo_worktree_inventory.md) record the handoff and corrected input status.

Choices beyond the frozen settings:

- Great-circle distances use the MODIS sphere. IDs use tile plus padded, one-based pixel number; geographic bins only accelerate searches.
- Complete searches use a conservative bounding rectangle with neighbourhood clearance. Internal tile joins remain connected.
- DBFs may lie outside the target cells; candidate counts use their own cells, pairs their ENF cells.
- Wetland flags are true if ever flagged, false only when completely known and unflagged; otherwise unknown.
- Reciprocal matching considers eligible target-region ENFs. Stricter diagnostics retain existing pairs and apply their own three-pair cell-year gate.
- Southern warnings count cells with any pair; three-pair southern counts are also reported.
- Numeric summaries use min, p05, median, mean, p95 and max with R’s default quantiles; elevation differences are absolute.
- Reads use 48-row strips with two-row halos. Land requires all 118 months; retrieval coverage requires all 108 study-period months.
- One `SHARED_DATA` setting locates inputs; output redirection follows `run$dir`.
- Changed frozen pairs require another run directory. Provenance records code/pair hashes and input names, sizes, times and build tags; it does not hash monthly albedo payloads.
- Screen losses are sequential. Failed feasibility remains a completed coverage result requiring Chris’s review.

Validation: all eight R files parse; all four test files pass. No failing tests remain. Small reads checked HDF strips, aligned water, native elevation, count bands and metadata. All 27 approved granule sizes match, and 354 monthly files exist. One empty-candidate failure was found and fixed.

The real limitation is southern coverage: v04 ends at **40°N**, so incomplete searches are excluded and counted. Retrieval bands are separable, so retrieval coverage is included without reading real albedo values.

The verification spec should pin Chris’s implementation commit, run the driver and four tests with one thread, and check all 83 cells, screen accounting, nearest-partner rules, thresholds, reuse, wetland handling, feasibility flags, manifests and unchanged pair identity after count reads. Recompute pairs from the saved full-precision candidates.

```sh
THREADS=1 OPENBLAS_NUM_THREADS=1 tools/rscript.sh tools/check_northeast_forest_albedo.R
```

`northeast-forest-check` awaits Fable’s review, Astra’s reconciliation, Chris’s commit and coverage verification.