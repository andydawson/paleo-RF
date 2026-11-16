Implemented in `cv-v2`, **uncommitted**. The [full implementation report](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/docs/cc/2026-11-06_cv2_implementation.md) records every file, implementation choice, check and branch/worktree status.

| Code file | Lines before → after | Change |
|---|---:|---|
| `R/model_registry.R` | 155 → 184 | Fifteen configurations and fixed tie-break order |
| `R/config_schema.R` | 222 → 223 | New IDs; retained old configuration compatibility |
| `R/calibration_fit.R` | 0 → 43 | Shared fitting, retry and term summaries |
| `R/cross_validation.R` | 267 → 361 | Nearby scoring, feasibility, coverage and depth |
| `R/cv_separation.R` | 0 → 220 | Contrasts, AIC, generator and recovery rules |
| `tools/cross_validate_albedo.R` | 385 → 481 | Frozen rows and protocol-2 reports |
| `tools/check_cv_separation.R` | 0 → 279 | Capacity and recovery stages |
| `tests/test_model_registry.R` | 57 → 91 | Counts and unchanged formulas |
| `tests/test_config.R` | 233 → 235 | Configuration compatibility |
| `tests/test_calibration_fit.R` | 0 → 52 | Common rows and retry cases |
| `tests/test_cross_validation.R` | 195 → 260 | Hand-worked scoring/reporting cases |
| `tests/test_cross_validation_stages.R` | 76 → 111 | Mocked CV integration |
| `tests/test_cv_separation.R` | 0 → 205 | Hand calculations and mocked separation integration |

Added **61 verification specs**, all with `commit = 'TO_FILL'`, plus the [run order](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/docs/cc/2026-11-06_cv2_run_order.md). README and both living question files are updated.

Implementation choices include separate `cross_validation_v2` outputs; month/holdout/truth job partitions; seed identifiers `darkens/null/shorter`; either endpoint outside defining the outside subset; subset weight normalization; ±1.96 SE intervals and replicate-based Monte Carlo errors; nonexclusive exclusion counts; nearest-angle matching to old directions; and retained evergreen reporting bins. The report explains these and the numerical conventions fully.

**Checks:** all 74 R files parse; all 12 targeted test scripts pass; `git diff --check` passes. Real-input separation preparation passed without fitting, retaining 83 northeast cells. No CV, capacity, recovery or pipeline fits were run.

**Run order:** tests → preparation → directional/capacity jobs → selection → recovery/in-range jobs → summary → winner pipeline. Maximum **61 jobs, 1,144 new fits before retries**, with six concurrent single-thread CV/separation jobs.

One real-library limitation remains: mgcv returns worst-case concurvity **4.355651**, above its theoretical range, for the saved model-8 fits. Raw values are preserved and the issue is recorded for Andria. Fable review, reference-checker runs and committed verification remain pending.