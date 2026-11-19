# Second review of the case-study contrast summaries (branch case-study-contrasts, 8331fb5 to d61da30)

*What this is: the independent review in the project's change-reviewer role, asked for by Chris on 19 November once Fable was available again; it formed its view before reading Astra's review of 18 November, then compared the two. Who wrote it: Fable (the change-reviewer role, read-only), 19 November 2026. Its report, lightly condensed in the "Right" and "Not worth doing" sections (lists run together, nothing changed in substance); findings and tables as written.*

---

**Verdict.** Mergeable as is: no changed default, nothing beyond the approved scope and no defect found. Five optional nits. Commit message bodies other than d61da30's could not be read (no git access).

Line cost of the change, against base 8331fb5: code and tests +257/-23 (tool +86/-18, checker +115/-3, test +56/-2); README +2/-2; new documents 79 (note) and 46 (spec) lines.

**Useful deletions first.** Nothing substantial can go; about 5 lines in total.

| Lines | Simplification | Saving |
|---|---|---:|
| `tools/explore_cover_contrasts.R:702-706` | The comment above `evaluate_case_studies` repeats the usage text at lines 17-23 almost sentence for sentence. Two lines would do (what it is given, one fit in memory at a time). | 3 |
| `tools/check_cover_contrasts.R:335-336` | The byte-for-byte comparison of the 36 copied status tables repeats, for a plain `file.copy`, what the unit test asserts at `tests/test_explore_cover_contrasts.R:367`. Low value either way. | 2 |

**Findings.** All nits; no blocker, no should-fix.

| Severity | File:line | What is wrong | Consequence | Evidence | Check that would prove it |
|---|---|---|---|---|---|
| Nit (adds 1 comment line; no mechanism) | `tools/explore_cover_contrasts.R:17-23` | The usage text does not say that `<run-dir>` must be the run the saved fits were made from, nor that the tool does not check this. | A later user who passes another all-days run gets plausible numbers: old fits evaluated at another run's cells and range of cover mixes. Only the verification's checker would show it. | Lines 17-23 and 679-680; `evaluate_case_studies` (707-730) compares nothing, as approved. | Reading only. |
| Nit (line-neutral) | `tools/check_cover_contrasts.R:306-309` and `364-367` | The same four lines appear twice with only the suffix changed; the hemlock label is also typed again at 288 and 358. | None for any result; a pasted duplicate under AGENTS.md's rule. | The two blocks as read. | Rerun the two checks; both must print the same lines as `check_11.log` and `check_13.log`. |
| Nit (records; no lines now) | `docs/cc/2026-11-18_case_study_contrasts_implementation.md:63-67` | "Left out by Chris's choice" lists only the three run-time checks; two later decisions (no hand recomputation of a new box's contrast and Duveiller mean; no extra record details) are not in the note. | A reader comparing design and build finds two unexplained gaps. | Note 63-67; design 48, 85-86. | At merge, check the changelog entry names both decisions in words. |

**Right.** The defaults of `fit`, `report` and `duveiller` are unchanged (`exchange_cases()` without `members` uses the same regions; `read_fit_status(saved_dir)` the same names; `compare_duveiller()` without `cases_dir` the saved folder; `report()` untouched). Nothing goes beyond the approved scope: no checksum comparison in the tool, no refusal of an occupied folder, no source check in the Duveiller step, no month selector, custom box or fitting fallback; `R/`, `scripts/`, `config.R` and `R/regions.R` untouched. The four keys select the right rows of the candidates table; the twelve corner points of the test, worked by hand, fall in the right boxes; the hemlock box equals the north-east box of `R/regions.R`. The checks are right and proportionate: the record MD5 comparison cannot pass vacuously; the hemlock reproduction (648 rows, largest difference 0) exercises reading the saved fits, rebuilding the cases and predicting on all three tables; Quebec-Labrador's count and denominator are independent (its eligible area is the tool's, as the checker says); the Duveiller comparison's 216 hemlock rows equal the 17 November comparison; the no-fitting overrides sit where the fitters are looked up. The committed spec equals the one the report ran. The records list every file read with its MD5 sum. The README and the note's counts match the logs. The question on forest analogues for shrub-rich cover is already in the scientific questions file. The commit subjects match their files; d61da30's body matches its content.

**Not worth doing.** Removing the restore of the fitters in the test; a shared helper for the two "read each saved fit" loops (line-neutral, different shapes); rewording the Duveiller record in the case-folder mode (adds a conditional); guards with no case here (a missing key, a table-column check, spaces in paths, `file.copy`'s value); an extra assertion on Quebec's eligible cells; trimming the spec; carrying the "secondary" ranking into the note.

**Questions for Chris.** None that need his choice.

**Not checked.** No R, tests or verification run (relied on the logs at 545479b); commit bodies other than d61da30's; that d61da30 changes no code beyond line counts; the figures' look; the GitHub issue and the literature; the merge changelog (not written yet).

**Against Astra's review** (read after the above was formed). Agree: defaults preserved, scope respected, the no-fitting test sound, no large deletion in the checks, the tool's own records the right plumbing. Her blocker (placeholder commit) is resolved: PASS at 545479b. Her nit on the three run folders is fixed in 545479b; her 64-line cut of the note is done. Her should-fix (no hand-computed number for a new box): her facts are right, but Chris decided against the extra check and his reasoning is supported by what the checks show; the residual gap is that no new box has a number worked by hand anywhere. Her question on record details was decided by Chris; the note does not say so. Differ mildly: she put a checker comparison helper under "not worth doing"; I list the pasted block as a nit because of the no-duplication rule, line-neutral, not pressed. New here: the unstated precondition on `<run-dir>`, and the two small deletions.

Files read: 23 (some in part), plus 4 searched; 39 tool calls.
