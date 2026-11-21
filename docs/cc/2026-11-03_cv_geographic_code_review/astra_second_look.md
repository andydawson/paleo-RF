*Astra, second look at 84b8689 (the fixes), 3 November 2026.*

| Finding | Status | Second look |
|---|---|---|
| Missing feasible months produce partial scores | **Fixed** | Frozen expected months now force incomplete scores when any month is absent. |
| Failed candidates disappear; missing model 8 crashes comparisons | **Fixed** | Expected models remain as missing-value columns; incomplete scores and unavailable comparisons are retained. |
| Failed model 8 leaves stale `by_distance.csv` | **Fixed** | The table is now written unconditionally, with unavailable pairs marked missing. |
| Pairing, band labels and counts | **Fixed** | Each candidate uses only rows shared with model 8; failed fits drop individually. Separate band columns and `cell_month_holdouts` are correct. |
| Selection-weight shares | **Fixed** | [Arithmetic](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv/tools/cross_validate_albedo.R:344) correctly assigns `group target weight / rows in group`, then normalizes over represented weight and sums within bands. |
| Tests establish failure handling and paired uncertainty | **Not fixed fully** | Non-zero SE and stage tests are added. Still missing: varying baseline with constant paired differences, a globally absent month, and failed-baseline overwrite checks on saved tables. |
| All in-range fits fail | **New finding; pre-existing gap** | The [empty regional report](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv/R/cross_validation.R:151) calls `order(NULL, …)`, which [errors](https://raw.githubusercontent.com/wch/r-source/trunk/src/main/sort.c). Reporting aborts and an old regional CSV can survive. Add an empty-result guard and an all-failed rerun test. |
| Selection score and choice byte identity | **Not fixed: verification gap** | No numerical or RNG change found by inspection. The [stage test](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv/tests/test_cross_validation_stages.R:42) compares two runs of this commit, not parent versus fix; that identical-input comparison remains needed. |
| Protocol wording and holdout regeneration | **Fixed** | Pooling, empty bands, “can raise/widen,” decision 16 and regeneration at the fitting commit are documented; stale in-range support gets a clear fit-stage stop. |

**Verdict:** Main fixes are sound; the all-failed regional path and regression evidence still need attention. No R run.