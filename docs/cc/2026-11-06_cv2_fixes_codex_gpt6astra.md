Implemented Chris’s selected fixes, left uncommitted. Both record writers and `predicted_nearby_depth.csv` remain.

| File | Lines before → after |
|---|---:|
| `R/cv_separation.R` | 220 → 243 |
| `tools/check_cv_separation.R` | 279 → 271 |
| `tools/cross_validate_albedo.R` | 481 → 475 |
| `tests/test_cv_separation.R` | 205 → 285 |
| `tests/test_model_registry.R` | 91 → 116 |
| `tests/test_cross_validation_stages.R` | 111 → 122 |
| [Implementation report](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/docs/cc/2026-11-06_cv2_implementation.md) | 369 → 400 |
| [Run order](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/docs/cc/2026-11-06_cv2_run_order.md) | 78 → 88 |
| Twelve monthly in-range specs | 10 → 0 each |
| Four replacements: Jan–Mar, Apr–Jun, Jul–Sep, Oct–Dec | 0 → 11 each |

All **66 R files parse**; `git diff --check` passes. **11/12 test scripts pass**, including all four requested additions. `test_paths.R` stops at the missing baseline CSV. The run order documents launching verification from the main checkout so existing `link_inputs()` supplies its verified baseline file to the detached worktree. Nothing was copied here.

Updated maximums, before retries:

- **52 jobs / 952 new fits** before the optional winner pipeline.
- **53 jobs / 1,144 new fits** including it.

Order: tests → preparation → 36 directional and 2 capacity jobs → selection → 6 recovery and 4 in-range jobs → summary. The optional winner pipeline can start after selection.

No network access, research fits, question-file edits or commits. `cv-v2` awaits your commit and frozen-commit verification; the existing branch/worktree inventory remains in the report.