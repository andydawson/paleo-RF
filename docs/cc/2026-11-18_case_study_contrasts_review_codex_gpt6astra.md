# Review of the case-study contrast summaries (branch case-study-contrasts, 8331fb5 to cb36279)

*What this is: the independent review of the change, in the project's change-reviewer role (plumbing class), against the scope Chris approved on 18 November 2026 (Astra's design without its three run-time guards). Who wrote it: Astra (Codex, gpt-6-astra, ultra effort, read-only), 18 November 2026. Filed unedited below the line; the decisions taken on its points are recorded in the commits that follow it.*

---

**Verdict.** Mergeable after the blockers: I found no production defect or changed default, but exact-commit verification remains outstanding and the promised new-box numerical check is incomplete.

**Findings.**

Useful deletions first. The [implementation note](/home/expert/Documents/contracting/Andria/paleo-RF-wt/case-boxes/docs/cc/2026-11-18_case_study_contrasts_implementation.md) can shrink from 132 to 68 lines while retaining its commands, box definitions and interpretation:

| Lines | Simplification | Saving |
|---|---|---:|
| 55–66 | Delete “Files touched”; the README and diff provide this inventory. | 12 |
| 71–93 | Replace the repeated references and audit history with a link on line 69 to the design’s precedents. Retain the required references in the merge changelog. | 23 |
| 94–103 | Replace approval history with three lines identifying the omitted runtime checks and verification’s input comparison. | 7 |
| 104–132 | Replace the test/trial narrative with seven lines giving the principal results, pending exact-commit verification and its link. | 22 |
| **Total** | | **64** |

The checker can lose one further explanatory line when its unused arguments are removed. I found no justified large deletion from its executable checks.

| Severity | File:line | What is wrong | Consequence | Evidence | Check that would prove the fix |
|---|---|---|---|---|---|
| **Blocker** | [Verification spec:30](/home/expert/Documents/contracting/Andria/paleo-RF-wt/case-boxes/docs/cc/verification/2026-11-18_case-study-cover-contrasts.R:30) | The commit remains a placeholder; the required verification report is absent. Replace the placeholder before execution; this replacement is line-neutral. | The scratch trial does not satisfy the merge requirement. | Spec line 30; `CONTRIBUTING.md:44–47`; implementation note 129–132. | Run `tools/verify_change.R` with the final reviewed commit and retain its PASS report. |
| **Should-fix** | [Checker:317](/home/expert/Documents/contracting/Andria/paleo-RF-wt/case-boxes/tools/check_cover_contrasts.R:317) | The independent Quebec check stops at cell count and area denominator. It takes eligible area from saved cases and never independently computes a new-box contrast. The Duveiller check likewise reproduces only hemlock. A focused numerical test **adds lines**. | Incorrect predictions for a new box could pass these checks. This is a coverage gap, not evidence of incorrect production arithmetic. | Checker 317–329 and 355–370; the new fixture’s other boxes are empty (`tests/test_explore_cover_contrasts.R:349–365`). Design 85–86 requested independent endpoint predictions and matched means. | Give one new box nonempty, unequal-area fixture cells; independently calculate its endpoint mean and Duveiller matched mean using the existing fixture helpers. Incorrect new-box predictions or weights must fail. |
| **Should-fix** | [Implementation note:55](/home/expert/Documents/contracting/Andria/paleo-RF-wt/case-boxes/docs/cc/2026-11-18_case_study_contrasts_implementation.md:55) | The note repeats the file inventory, references, approval history and detailed test narrative. The deletions above **remove 64 lines**. | Andria’s explanation is harder to find among implementation records. | Lines 55–132 duplicate the README, design and verification material. | Check that the shortened note retains usage, interpretation, principal evidence and pending verification. |
| **Nit** | [Checker:284](/home/expert/Documents/contracting/Andria/paleo-RF-wt/case-boxes/tools/check_cover_contrasts.R:284) | `case-studies` accepts three run folders but reads only `run_dirs[1]`. **Yes: take only the all-days folder.** Signature, dispatch, usage and spec substitutions are line-neutral; shortening line 28 and deleting line 29 saves **one line**. | The interface implies that this check uses two folders it ignores. | Lines 284, 317, 380 and 385; spec line 41. | Run the revised single-folder invocation through the verification spec. The separate `inputs` check should continue taking all three runs. |

Known simplification saving: **65 lines**. The focused numerical test requires additional lines; its exact size cannot be established without a patch.

**Right.**

- **Existing defaults are preserved.** `fit` retains the same region membership, eligibility, hull, weights and ordering; `report` is unchanged; ordinary `duveiller` still reads cases and fits from the saved directory. No existing filenames, columns or seed paths change.
- **Production scope is respected.** The four boxes come from the candidate CSV as independent masks. There is no refitting fallback, month selector, custom-box option or any of the three rejected runtime guards. `R/`, `scripts/`, configuration and schema are unchanged.
- **Most checks are proportionate.** Hemlock reproduction checks exact support/status and absolute `1e-12` numerical agreement. The 36-record checksum comparison implements the approved verification check. Copied fit statuses, complete keys, deliberately unfitted entries and four report pages are checked.
- **The no-fitting test is sound.** It replaces the three fitting entry points and restores them after success. The existing hand-worked tests exercise arithmetic, and the new boundary fixture checks all four boxes.
- **Plumbing follows the existing standalone tool.** It uses its input records, rather than pipeline `read_input()`/`write_output()` manifests. The specifically approved design preserves that arrangement; pipeline catalogue and stale-input checks are untouched. Legacy configuration retains its previous settings.
- **All six commit messages match their changes:** `4968e66`, `5a57909`, `c311543`, `d5c5a5e`, `f12c58c`, `cb36279`. The implementation note is an expressly requested document, not an unapproved document type. The changelog entry remains pending at merge.
- The scientific questions still retain the uncertainty about forest analogues for shrubs. No new scientific decision is implied.

**Questions for Chris.**

The design requested explicit box keys/bounds, original-job records and evaluation timings in provenance. Current records contain candidate/input/fit hashes and the saved-directory path; evaluation duration goes to stdout, captured by verification. Is that sufficient, or should the originally specified record details be restored? Either choice needs no new runtime guard.

**Not worth doing.**

I dropped three possible additions: another runtime input guard, a cleanup framework for the no-fitting test, and a generic comparison helper solely to shorten the checker. They address no demonstrated defect here. Replacing the comparison loops with whole-frame `all.equal()` would also alter their exact-metadata and absolute-tolerance semantics.

**Not checked.**

No R, tests or verification were executed. I did not independently confirm the reported trial, inspect generated figures, re-audit the literature or fetch GitHub issue history. The prohibited directory was not opened.

Read **30 repository files**, some in part, plus the supplied diff and Git objects; **32 top-level tool calls across the review team**.