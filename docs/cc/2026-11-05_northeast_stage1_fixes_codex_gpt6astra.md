Implemented the agreed changes. Monthly build-tag checks, overwrite refusal, elevation-before-nearest, southern warning rules and strip reading are preserved.

| Code file | Lines before → after | Change |
|---|---:|---|
| [R/northeast_forest_albedo.R](/home/expert/Documents/contracting/Andria/paleo-RF-wt/northeast/R/northeast_forest_albedo.R) | 675 → 643 | Deferred retrieval diagnostics/cell-year output; retained coverage; derived bounds/width; added scope accounting and cell-loss export; aligned style. |
| [Coverage driver](/home/expert/Documents/contracting/Andria/paleo-RF-wt/northeast/tools/check_northeast_forest_albedo.R) | 107 → 100 | Catalogued elevation-cache provenance and shorter notes. |
| [Albedo preparation](/home/expert/Documents/contracting/Andria/paleo-RF-wt/northeast/tools/prepare_bluesky_albedo.R) | 1003 → 992 | Combined script-then-helper SHA-256; approved historical identities remain accepted. |
| [Albedo compatibility tests](/home/expert/Documents/contracting/Andria/paleo-RF-wt/northeast/tests/test_bluesky_albedo.R) | 553 → 563 | Digest byte order, sensitivity and historical compatibility. |
| [Candidate tests](/home/expert/Documents/contracting/Andria/paleo-RF-wt/northeast/tests/test_northeast_forest_albedo.R) | 121 → 197 | Boundary brackets, candidate fixture, tile/strip joins, pixel-ID round trips and loss reconciliation. |
| [Coverage tests](/home/expert/Documents/contracting/Andria/paleo-RF-wt/northeast/tests/test_northeast_forest_coverage.R) | 106 → 114 | Cell-loss retention, partner closure and retained retrieval coverage. |
| [Draft verification spec](/home/expert/Documents/contracting/Andria/paleo-RF-wt/northeast/docs/cc/verification/2026-11-05_northeast-coverage.R) | New: 394 | Covers the review’s final checklist; `commit = 'TO_FILL'`. |

Updated the [implementation note](/home/expert/Documents/contracting/Andria/paleo-RF-wt/northeast/docs/cc/2026-11-05_northeast_forest_albedo_stage1_implementation.md) to match.

All seven R files parse. **All four required tests pass** using `THREADS=1 OPENBLAS_NUM_THREADS=1 tools/rscript.sh`, including `test_modis_albedo_helpers.R`. Spec-format validation and `git diff --check` also pass.

The spec independently samples nearest partners/reciprocity and reconstructs January, July and December retrieval coverage across all nine years. It has **not** run coverage.

Changes remain uncommitted in `northeast-forest-check`, awaiting Chris’s commit and verification. No network, full coverage run, requests-directory access or question-file edits.