**Verdict: ready after named changes.** All six approved changes are correctly implemented. I found no numerical regression. Wrap the clipped title, pin the spec to the final code commit, and use this branch’s verification launcher.

No files changed, no commits were made, and R was not started. The checkout is one documentation-only commit beyond the stated review revision; the code and spec are unchanged.

1. **Use the launcher that preserves each check’s evidence.**  
   The main checkout’s [tools/verify_change.R:251](/home/expert/Documents/contracting/Andria/paleo-RF/tools/verify_change.R:251) writes every check to `checks.log`, overwriting the preceding output. The report retains exit statuses, so this does **not** create a false PASS. But a successful run loses the five test logs and both comparison logs, including their numerical reconciliation messages and console tables. Only the final table-check log survives.

   This branch’s [tools/verify_change.R:246](/home/expert/Documents/contracting/Andria/paleo-RF-wt/compare-tool/tools/verify_change.R:246) already retains eight separate logs and names them in the report. Use that launcher **from the main checkout**, passing the comparison branch’s launcher and spec by absolute path. That preserves the usual frozen-input source, worktree location and report destination.

   **Check:** the report records eight successful checks, and `check_01.log` through `check_08.log` remain available. Neither launcher embeds their contents in the report; retain the logs with the verification products. No verifier edit is needed.

2. **Wrap the title so the baseline model’s name remains readable.**  
   At [tools/compare_cv_hindcasts.R:515](/home/expert/Documents/contracting/Andria/paleo-RF-wt/compare-tool/tools/compare_cv_hindcasts.R:515), the subtitle is wrapped but the title is not. I inspected the saved reversed forcing map: its final letter is cut off.

   **Change:** replace `title = title` with `title = paste(strwrap(title, width = 70), collapse = '\n')`. Using the subtitle’s width of 90 would do nothing: this title is only 74 characters long.

   **Check:** inspect the regenerated normal and reversed forcing PNGs. The subtitle, including its clipping notice, is already readable. File-existence checks cannot establish this.

3. **Fill the spec’s commit after the title correction.**  
   The [spec:101](/home/expert/Documents/contracting/Andria/paleo-RF-wt/compare-tool/docs/cc/verification/2026-11-10_cv-hindcast-comparison.R:101) still contains `TO_FILL`, which prevents verification from starting.

   **Change and check:** use the full commit containing the final code, including the title correction, and confirm that the report identifies it. If the title changes, the previously proposed review commit is no longer the right verification target.

The six approved changes check out:

| Approved change | Result |
|---|---|
| Explain directions and northeast reach | Correct direction names, explicit warning, and qualification that tested limits are pooled across months. |
| Enforce common availability | Simulated albedo must be finite; corresponding forcing columns must share availability. The two-cell missingness test is present. |
| Preserve separate swap endpoints | All four columns are correctly labelled and calculated; the test checks distinct endpoints and their reversal. |
| Check both historical endpoints and narrow claims | Both 6 and 4.5 ka predictions are checked against the saved fits. The script-9/script-10 description now matches the checks performed. |
| Replace the 0.005 gate | Removed. The largest absolute fitted–simulated gap and sign disagreements are reported without an acceptance threshold. |
| Disclose kernel coverage and wrap subtitle | Counts are correct, model-versus-kernel support is distinguished, and the subtitle is readable. |

The diff contains the approved implementation, associated tests, spec changes and documentation. The console tables, arithmetic preamble, albedo names and both retained additional outputs remain. I found no unrelated tidy-up.

Independent Python comparison confirms **all ten saved tables preserve every pre-existing field exactly**, including row order: **110,622 field values, zero differences**. The additions are the four endpoint-distance columns and direction descriptions; headers and figure presentation also changed as intended.

The new numerical statements also hold when reconstructed from the inputs:

- **Northeast reach:** rebuilding the monthly training hulls from saved calibration and cover data gives **0.1072336366**. All **3,948 outside cell-slice-month rows** leave in the less-open-land, more-summergreen direction. The cross-validation inputs give **0.0993953301** as its nearby tested maximum. Both maxima happen to hold in every month here.
- **Kernel coverage:** all three raw forcing files have identical availability across runs for all nine reported kernel/component columns. CACK has **2,646 January cells** and **2,439 December cells**; every other study-area kernel/month has **2,655**. The contributing cell sets persist across slice pairs. The northeast has **83 throughout**.
- **Fitted–simulated difference:** the largest absolute gap is **0.0011952078427183 albedo**, with **0 of 36** sign disagreements.
- **Arithmetic and reversal:** baseline differences are zero; every reversed difference changes sign exactly, including forcing outside contributions. Component-sum discrepancies are below **9 × 10⁻¹⁴ W/m²**.

The independently reconstructed endpoint distances are:

| Open land held at | High-evergreen endpoint | Low-evergreen endpoint |
|---|---:|---:|
| 50 BP | 0 | 0.122241461665 |
| 6 ka | 0.023300404543 | 0.146643271877 |

These hold in every month. All **240 saved endpoint values** across the normal and reversed comparisons agree within **4.2 × 10⁻¹⁶**.

The spec is sufficient for these changes once pinned. Its checks cover common denominators, the new columns and header statements, both historical endpoints through the tool’s own checks, and all forcing difference reversals. The supplied seven test runs succeeded; the spec’s five relevant test files are sufficient. The trial’s implementation matches the reviewed code despite its earlier recorded commit.

On simplicity, **no further cuts to the approved implementation are justified**. Keep the console tables and arithmetic preamble. The title needs one line, and the existing launcher already solves log retention. I discarded three hypothetical hardening concerns because they demonstrated no failure in the required comparison and would expand the patch.

**Final verdict: ready after named changes**, in this order:

1. Wrap the map title at 70 characters and inspect both forcing maps.
2. Pin the spec to the full final code commit.
3. Run the spec using this branch’s verification launcher from the main checkout, retaining all eight logs.