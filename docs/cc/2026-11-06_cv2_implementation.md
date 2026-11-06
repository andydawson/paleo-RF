# CV protocol 2 implementation and change record — 6 November 2026

Implemented the approved [protocol](2026-11-06_cv_protocol_v2.md), sections 1–9, except the section-7 hindcast comparison tool deferred in the brief. The benefit is a reproducible second selection run with the stated northeast separation checks. No scientific tuning rules were added or changed.

All edits are in the `cv-v2` worktree. No commits, pushes, network calls, production CV/capacity/recovery fits or pipeline runs were made. The approved protocol, scripts 1–10, `config.R`, and all run-1 specs/records are unchanged. GitHub issue #24 was not updated under the no-network instruction.

## Pre-run fixes chosen by Chris

These fixes preserve interpretable diagnostics for Andria and reduce job management without changing model formulas, selection or contrast calculations. The historical exchange is stored and reported once per month and reused by capacity. Thin-plate concurvity now follows Chris's explicit NA/reason policy, with rank/count/EDF retained for every available capacity fit. The ET/ST eligibility comment explains the existing endpoint validation. Fixed interpretation prose is below; generated facts, figure labels, both record writers and `predicted_nearby_depth.csv` remain.

The following counts are relative to the committed files at the start of this fix session; the original implementation history follows separately. Only these files and the listed spec replacements changed. No commits, network calls, question-file edits, data copies, CV/capacity/recovery fits or other document edits were made.

| Changed file | Lines before → after |
|---|---:|
| [R/cv_separation.R](../../R/cv_separation.R) | 220 → 243 |
| [tools/check_cv_separation.R](../../tools/check_cv_separation.R) | 279 → 271 |
| [tools/cross_validate_albedo.R](../../tools/cross_validate_albedo.R) | 481 → 475 |
| [tests/test_cv_separation.R](../../tests/test_cv_separation.R) | 205 → 285 |
| [tests/test_model_registry.R](../../tests/test_model_registry.R) | 91 → 116 |
| [tests/test_cross_validation_stages.R](../../tests/test_cross_validation_stages.R) | 111 → 122 |
| [docs/cc/2026-11-06_cv2_run_order.md](2026-11-06_cv2_run_order.md) | 78 → 88 |
| [docs/cc/2026-11-06_cv2_implementation.md](2026-11-06_cv2_implementation.md) | 369 → 400 |
| Twelve removed `verification/2026-11-06_cv2-fit-inrange-<month>.R` specs (`jan`–`dec`) | 10 → 0 each |
| Four replacement specs: `jan-mar`, `apr-jun`, `jul-sep`, `oct-dec` (linked below) | 0 → 11 each |

Checks for this fix:

- All **66** implementation/test/spec R files parse (13 code/test files and 53 specs). `git diff --check` passes. Static checks confirm four in-range specs, one driver invocation with three months each, and all twelve months exactly once.
- **11 of 12 test scripts pass:** `test_model_registry`, `test_calibration_fit`, `test_cross_validation`, `test_cross_validation_stages`, `test_cv_separation`, `test_training_support`, `test_random`, `test_config`, `test_differences`, `test_forcing_periods`, `test_forcing_breakdown`. Every R invocation used `THREADS=1 OPENBLAS_NUM_THREADS=1 tools/rscript.sh`. Existing small unit fitting fixtures remain; the new checks use setup matrices or deterministic stand-ins.
- New tests cover all ten thin-plate NA/reason policies and retained fit/cover ranks and EDF, including saved CSVs and a nonconverged available fit; all five linear-cover logit invariants; the independent stage score **0.002323295918367347** and represented weight **2/3**; and actual hull checks for inside/inside, outside/inside, inside/outside and outside/outside (**FALSE, TRUE, TRUE, TRUE**). Generated selection status messages are also checked.
- `test_paths.R` stops at its missing baseline `output/calibration/calibration_model_stats.csv`. No fixture was supplied here. The [run order](2026-11-06_cv2_run_order.md) now launches the verifier from the baseline-populated main checkout, whose existing file matches frozen MD5 `3612e3d9301b601cfe74b4b76273cfd0`; `link_inputs()` will link it into the detached verification worktree. The full verifier remains for Chris's final commit, and its entire frozen-input check still applies.
- An independent code review found no actionable defects in the reporting helper, drivers or grouped specs; zero speculative findings were retained or dropped.

Updated maximum: **52 jobs / 952 new fits** before the optional winner pipeline; **53 jobs / 1,144 new fits** including it, before retries. The 952 fits are 540 directional + 28 capacity + 360 recovery + 24 in-range; the optional pipeline adds 192. Run tests → preparation/holdouts → 36 directional and 2 capacity jobs → selection → 6 recovery and 4 in-range jobs → summary. The optional winner pipeline may start after selection if the winner differs from model 8. Capacity reuses the two saved full-data model-8 fits; no-choice, infeasible or deduplicated cases reduce the counts. The six-process limit is unchanged.

## Original implementation files

| Code file | Lines before → after | Purpose |
|---|---:|---|
| [R/model_registry.R](../../R/model_registry.R) | 155 → 184 | Fifteen explicit CV configurations, fixed counts/order and capacity labels; existing formulas retained. |
| [R/config_schema.R](../../R/config_schema.R) | 222 → 223 | Accept the new grid while preserving saved mod8_small_cover pipeline configurations. |
| [R/calibration_fit.R](../../R/calibration_fit.R) | 0 → 43 | Common complete rows, ordinary REML fitting, one convergence retry and term summaries. |
| [R/cross_validation.R](../../R/cross_validation.R) | 267 → 361 | Shared nearby mask, feasibility, coverage/depth summaries, paired diagnostics and no-choice handling. |
| [R/cv_separation.R](../../R/cv_separation.R) | 0 → 220 | Frozen exchanges, full-covariance contrasts, reuse/AIC checks, truths and recovery pass rules. |
| [tools/cross_validate_albedo.R](../../tools/cross_validate_albedo.R) | 385 → 481 | Freeze protocol-2 rows and counts; fit and score them; distance, direction, deep-band and in-range reports. |
| [tools/check_cv_separation.R](../../tools/check_cv_separation.R) | 0 → 279 | Prepare inputs once; run capacity/recovery partitions; summarize AIC, contrasts, recovery and failures. |
| [tests/test_model_registry.R](../../tests/test_model_registry.R) | 57 → 91 | Check all fifteen setup counts/order and retained formulas/model-8 design matrices and penalties. |
| [tests/test_config.R](../../tests/test_config.R) | 233 → 235 | Accept every new candidate and the retained run-1 configuration. |
| [tests/test_calibration_fit.R](../../tests/test_calibration_fit.R) | 0 → 52 | Hand-made success, nonconvergence, error/retry and common-missingness cases. |
| [tests/test_cross_validation.R](../../tests/test_cross_validation.R) | 195 → 260 | Hand-worked cutoff, feasibility, target, paired denominator, maxima, deep-weight and selection cases. |
| [tests/test_cross_validation_stages.R](../../tests/test_cross_validation_stages.R) | 76 → 111 | Standalone frozen fixture with deterministic stand-ins: selection, diagnostic, incomplete and stale-record flows. |
| [tests/test_cv_separation.R](../../tests/test_cv_separation.R) | 0 → 205 | Hand-worked contrast, generator, AIC and pass boundaries; full mocked stages including whole-job failure. |

The 53 verification specs are listed individually below; all use `commit = 'TO_FILL'`. The [run order](2026-11-06_cv2_run_order.md) gives their dependencies. README now maps the CV and separation tools and their input/output files. Both living Andria question documents were reviewed and updated; the scientific file records the concurvity issue below. This document is the implementation/change record.

## Original implementation checks

- All 74 new/changed R files parse: 13 implementation/test files and 61 specs. `git diff --check` passes.
- All 12 relevant test scripts pass: `test_model_registry`, `test_calibration_fit`, `test_cross_validation`, `test_cross_validation_stages`, `test_cv_separation`, `test_training_support`, `test_random`, `test_config`, `test_paths`, `test_differences`, `test_forcing_periods`, and `test_forcing_breakdown` (under `tests/`).
- Tests used `THREADS=1 OPENBLAS_NUM_THREADS=1 tools/rscript.sh`; file-writing tests used a TMPDIR inside this worktree. Registry tests perform model setup without CV fitting and retain the existing two small elevation-only fitter fixtures. The random test retains its small existing fitting fixture. CV and separation stage tests use stand-ins, including a whole recovery job in which all fits fail.
- `test_paths.R` initially could not find the untracked baseline `output/calibration/calibration_model_stats.csv` in this worktree. It passed after temporarily linking that small file from the completed `run1-main` source; the link was removed afterwards. No test code or baseline data was changed for this.
- All 61 specs parsed and 60 were read/validated for required fields, command paths and single-thread environments. The winner spec cannot be evaluated until `scores.csv` exists; its syntax parses. `tools/verify_change.R` was not launched because this task leaves the implementation uncommitted and forbids creating other worktrees.
- Separation preparation was exercised on actual source inputs in ignored `.rundirs/cv2-separation-smoke`, with output confined here and source inputs linked read-only. Model-8 April/May fits pass exact full-data row, formula, beta-logit, REML and convergence checks. Each real-data, fixed and historical exchange retains 83 northeast cells, with no exclusions. The historical recovery exchange directly reuses the capacity endpoints. Exact generator null contrasts are zero; both saved fits have the `edf2` correction used by `AIC()`.
- Independent Astra review checked the registry/fitter, separation code and final CV implementation. Corrections included directional concurvity labels, shared historical endpoints, exact AIC data checks, common fitting rows, failure labels and all-error recovery summaries. No cosmetic/speculative review changes were retained. Fable code review and the protocol’s combined reference-checker runs remain outstanding; they were not available in this offline session. No claim of completed merge verification is made.

## Choices not fixed by the protocol

1. Results live under `output/cross_validation_v2/`; separation records are its `separation/` subdirectory. Old records are preserved by their original paths and recorded commits. Old `mod8_small_cover` configurations remain valid outside the CV grid.
2. Jobs split by directional holdout/month, capacity month, recovery month/truth and three-month in-range group. These administrative partitions reuse the existing verifier and queue. Historical source paths are those in the run order; the runner supplies the final full commit SHA.
3. Truth identifiers in seed derivation are `darkens`, `null`, and `shorter`. All 120 response vectors and their seeds are frozen by preparation, before fitting; each configuration reads the same vector.
4. A contrast belongs to the inside subset only if both endpoints are inside the monthly hull; either endpoint outside places it in the outside subset. Subset reports renormalize their frozen cell-area weights, with retained area and shares relative to the complete exchange reported. The pass gate uses the complete valid set; subsets remain diagnostic.
5. Approximate 95% capacity intervals use ±1.96 SE. Monte Carlo standard errors use sample variation across replicates: SD/sqrt(20) for means and mean absolute contrasts, sqrt(p(1−p)/20) for sign proportions, and a delta-method SE for RMSE. Magnitude variation is the range of absolute capacity contrasts. None changes the pass thresholds.
6. Exclusion counts list nonexclusive reasons. A slice with no positive ice-free area contributes no target observations and does not transfer its preassigned equal share to another slice. Missing tested depth is NA, never zero.
7. Membership-change reports match a new direction to the nearest old angle, reporting the angle and cut changes. Diagnostic represented/missing target shares use the full frozen historical denominator; paired errors, signed errors and counts use the same finite rows. Selection shares are separately normalized across frozen nearby rows and are zero for far rows.
8. Existing low-open-land evergreen-share bins (0–0.2–0.4–0.6–1) are retained. Source input/table equality is exact; serialization alone may differ. The configuration snapshot is written only in preparation, avoiding concurrent writers.
9. An outright fitting error is recorded immediately; the single retry is for nonconvergence, as in the existing fitter. All attempt statuses and warnings are retained. Every CV/separation fitting call uses one thread and the same complete predictor/response rows.

## Real-code limitation and remaining work

The [independent rank review](2026-11-06_cv2_code_review_codex_gpt6astra.md) confirmed that the thin-plate cover basis is rank-deficient because OL + ET + ST = 1. On the saved April model-8 fit, fit rank/coefficient count was 744/748 and cover-block rank/count was 195/199. Chris chose NA for all six pairwise concurvity fields of all ten thin-plate configurations, with the reason “not computable: cover fractions sum to one, so the thin-plate cover basis is rank-deficient”. Each available capacity fit retains its fit rank, coefficient count, cover-block rank/count and location EDF before being discarded, including nonconverged fits. The five linear-cover configurations keep their previous concurvity calculation (not applicable when location is absent). The model, contrasts and uncertainty calculations are unchanged; this is a reporting decision supported by that review, not a new scientific method.

The code and input checks otherwise accommodated the approved protocol. Production nearby/deep coverage, the winning model, full capacity results and recovery outcomes await the verification jobs. Period-sum and endpoint regressions for the unchanged pipeline passed; section-7 two-run common-cell, support-period and hindcast endpoint tests remain with the explicitly deferred comparison tool.

Run order: tests → preparation/holdouts → 36 directional jobs plus 2 capacity jobs → selection → 6 recovery jobs plus 4 three-month in-range jobs → summary → winner pipeline when needed. Maximum: **53 jobs and 1,144 new fits**, before retries; **52 jobs and 952 fits** before the winner pipeline. Capacity reuses two full-data model-8 fits. A model-8 winner, duplicate recovery configurations and infeasible folds reduce the count. AIC adds no fits. At most six CV/separation fit processes run concurrently.

## Interpretation of the run outputs

The selection score is measured on development data: choosing among fifteen configurations is optimistic. Optimism may be about one bootstrap standard error in albedo units (`selection_rmse_se` in `scores.csv`); this is a judgement, not measured bias, an upper bound or a correction. Distances and errors beyond observed support are untested; the deep band does not establish accuracy at all deeper distances. Missing direction-month depth combinations are NA, not depth zero. Distance-table represented/missing shares use the full frozen historical target denominator. Pooled diagnostic errors and partial model-8 comparisons never select the model.

Capacity and recovery reports do not change selection. AIC differences compare only full-data fits within one month. Recovery pass rules use the complete frozen cell set; inside/outside subsets are diagnostics, and outside means either endpoint is outside. Capacity and recovery share the same monthly `historical` exchange; its endpoints and exclusions are recorded once per month.

Intervals use `Vp` and are conditional on smoothing parameters; errors across configurations are not independent. Twenty replicates give worst-case Monte Carlo SE 0.112 for a sign proportion. Reported MCSEs use independent replicate variation. Recovery failure, incompleteness or untestability prevents a northeast vegetation-sign claim. Agreement within this grid does not establish correct separation or historical signs.

Fixed interpretation prose now lives here instead of generated text files. `selection_notes.txt` keeps generated depth/weight counts, completion/failure and chosen/no-choice messages, and the bootstrap-SE field label. The capacity figure keeps its conditional-interval caption. Both record writers and `predicted_nearby_depth.csv` are retained; the latter reports finite candidate/model-8 prediction pairs and can differ from the pre-fit geometry.

## Published basis

The approved protocol is the fixed plan and retains the complete precedent table, full references and checked-passage record. This implementation introduces no new scientific method. Principal precedents for the new separation/AIC reporting are:

- Duveiller, G., Hooker, J., & Cescatti, A. (2018). The mark of vegetation change on Earth’s surface energy balance. *Nature Communications*, 9, 679. DOI: 10.1038/s41467-017-02810-8. The protocol’s Methods/equations 11–13 passage supports replacement contrasts with covariance; the particular historical exchange and GAM capacity grid are approved adaptations.
- Wood, S. N., Pya, N., & Säfken, B. (2016). Smoothing parameter and model selection for general smooth models. *Journal of the American Statistical Association*, 111, 1548–1575. DOI: 10.1080/01621459.2016.1180986. The protocol’s §5 passage supports conditional GAM AIC and smoothing-parameter uncertainty correction.
- Morris, T. P., White, I. R., & Crowther, M. J. (2019). Using simulation studies to evaluate statistical methods. *Statistics in Medicine*, 38, 2074–2102. DOI: 10.1002/sim.8086. The protocol’s §§3/5 passages support stated truths, performance measures and Monte Carlo uncertainty; numerical truths and pass thresholds remain Chris’s approved judgements.
- Yates, L. A., Aandahl, Z., Richards, S. A., & Brook, B. W. (2023). Cross validation for model selection: A review with examples from ecology. *Ecological Monographs*, 93, e1557. DOI: 10.1002/ecm.1557. The protocol’s equations 7–8 passage supports the adapted simpler-within-uncertainty selection rule.

No references were newly fetched or checked online; the protocol’s remaining reference-checker requirement is explicit above.

## Individual verification specs

| New code file | Lines before → after | Job |
|---|---:|---|
| [2026-11-06_cv2-capacity-apr.R](verification/2026-11-06_cv2-capacity-apr.R) | 0 → 10 | capacity-apr |
| [2026-11-06_cv2-capacity-may.R](verification/2026-11-06_cv2-capacity-may.R) | 0 → 10 | capacity-may |
| [2026-11-06_cv2-fit-d1-apr.R](verification/2026-11-06_cv2-fit-d1-apr.R) | 0 → 10 | fit-d1-apr |
| [2026-11-06_cv2-fit-d1-aug.R](verification/2026-11-06_cv2-fit-d1-aug.R) | 0 → 10 | fit-d1-aug |
| [2026-11-06_cv2-fit-d1-dec.R](verification/2026-11-06_cv2-fit-d1-dec.R) | 0 → 10 | fit-d1-dec |
| [2026-11-06_cv2-fit-d1-feb.R](verification/2026-11-06_cv2-fit-d1-feb.R) | 0 → 10 | fit-d1-feb |
| [2026-11-06_cv2-fit-d1-jan.R](verification/2026-11-06_cv2-fit-d1-jan.R) | 0 → 10 | fit-d1-jan |
| [2026-11-06_cv2-fit-d1-jul.R](verification/2026-11-06_cv2-fit-d1-jul.R) | 0 → 10 | fit-d1-jul |
| [2026-11-06_cv2-fit-d1-jun.R](verification/2026-11-06_cv2-fit-d1-jun.R) | 0 → 10 | fit-d1-jun |
| [2026-11-06_cv2-fit-d1-mar.R](verification/2026-11-06_cv2-fit-d1-mar.R) | 0 → 10 | fit-d1-mar |
| [2026-11-06_cv2-fit-d1-may.R](verification/2026-11-06_cv2-fit-d1-may.R) | 0 → 10 | fit-d1-may |
| [2026-11-06_cv2-fit-d1-nov.R](verification/2026-11-06_cv2-fit-d1-nov.R) | 0 → 10 | fit-d1-nov |
| [2026-11-06_cv2-fit-d1-oct.R](verification/2026-11-06_cv2-fit-d1-oct.R) | 0 → 10 | fit-d1-oct |
| [2026-11-06_cv2-fit-d1-sep.R](verification/2026-11-06_cv2-fit-d1-sep.R) | 0 → 10 | fit-d1-sep |
| [2026-11-06_cv2-fit-d2-apr.R](verification/2026-11-06_cv2-fit-d2-apr.R) | 0 → 10 | fit-d2-apr |
| [2026-11-06_cv2-fit-d2-aug.R](verification/2026-11-06_cv2-fit-d2-aug.R) | 0 → 10 | fit-d2-aug |
| [2026-11-06_cv2-fit-d2-dec.R](verification/2026-11-06_cv2-fit-d2-dec.R) | 0 → 10 | fit-d2-dec |
| [2026-11-06_cv2-fit-d2-feb.R](verification/2026-11-06_cv2-fit-d2-feb.R) | 0 → 10 | fit-d2-feb |
| [2026-11-06_cv2-fit-d2-jan.R](verification/2026-11-06_cv2-fit-d2-jan.R) | 0 → 10 | fit-d2-jan |
| [2026-11-06_cv2-fit-d2-jul.R](verification/2026-11-06_cv2-fit-d2-jul.R) | 0 → 10 | fit-d2-jul |
| [2026-11-06_cv2-fit-d2-jun.R](verification/2026-11-06_cv2-fit-d2-jun.R) | 0 → 10 | fit-d2-jun |
| [2026-11-06_cv2-fit-d2-mar.R](verification/2026-11-06_cv2-fit-d2-mar.R) | 0 → 10 | fit-d2-mar |
| [2026-11-06_cv2-fit-d2-may.R](verification/2026-11-06_cv2-fit-d2-may.R) | 0 → 10 | fit-d2-may |
| [2026-11-06_cv2-fit-d2-nov.R](verification/2026-11-06_cv2-fit-d2-nov.R) | 0 → 10 | fit-d2-nov |
| [2026-11-06_cv2-fit-d2-oct.R](verification/2026-11-06_cv2-fit-d2-oct.R) | 0 → 10 | fit-d2-oct |
| [2026-11-06_cv2-fit-d2-sep.R](verification/2026-11-06_cv2-fit-d2-sep.R) | 0 → 10 | fit-d2-sep |
| [2026-11-06_cv2-fit-d3-apr.R](verification/2026-11-06_cv2-fit-d3-apr.R) | 0 → 10 | fit-d3-apr |
| [2026-11-06_cv2-fit-d3-aug.R](verification/2026-11-06_cv2-fit-d3-aug.R) | 0 → 10 | fit-d3-aug |
| [2026-11-06_cv2-fit-d3-dec.R](verification/2026-11-06_cv2-fit-d3-dec.R) | 0 → 10 | fit-d3-dec |
| [2026-11-06_cv2-fit-d3-feb.R](verification/2026-11-06_cv2-fit-d3-feb.R) | 0 → 10 | fit-d3-feb |
| [2026-11-06_cv2-fit-d3-jan.R](verification/2026-11-06_cv2-fit-d3-jan.R) | 0 → 10 | fit-d3-jan |
| [2026-11-06_cv2-fit-d3-jul.R](verification/2026-11-06_cv2-fit-d3-jul.R) | 0 → 10 | fit-d3-jul |
| [2026-11-06_cv2-fit-d3-jun.R](verification/2026-11-06_cv2-fit-d3-jun.R) | 0 → 10 | fit-d3-jun |
| [2026-11-06_cv2-fit-d3-mar.R](verification/2026-11-06_cv2-fit-d3-mar.R) | 0 → 10 | fit-d3-mar |
| [2026-11-06_cv2-fit-d3-may.R](verification/2026-11-06_cv2-fit-d3-may.R) | 0 → 10 | fit-d3-may |
| [2026-11-06_cv2-fit-d3-nov.R](verification/2026-11-06_cv2-fit-d3-nov.R) | 0 → 10 | fit-d3-nov |
| [2026-11-06_cv2-fit-d3-oct.R](verification/2026-11-06_cv2-fit-d3-oct.R) | 0 → 10 | fit-d3-oct |
| [2026-11-06_cv2-fit-d3-sep.R](verification/2026-11-06_cv2-fit-d3-sep.R) | 0 → 10 | fit-d3-sep |
| [2026-11-06_cv2-fit-inrange-jan-mar.R](verification/2026-11-06_cv2-fit-inrange-jan-mar.R) | 0 → 11 | fit-inrange-jan-mar |
| [2026-11-06_cv2-fit-inrange-apr-jun.R](verification/2026-11-06_cv2-fit-inrange-apr-jun.R) | 0 → 11 | fit-inrange-apr-jun |
| [2026-11-06_cv2-fit-inrange-jul-sep.R](verification/2026-11-06_cv2-fit-inrange-jul-sep.R) | 0 → 11 | fit-inrange-jul-sep |
| [2026-11-06_cv2-fit-inrange-oct-dec.R](verification/2026-11-06_cv2-fit-inrange-oct-dec.R) | 0 → 11 | fit-inrange-oct-dec |
| [2026-11-06_cv2-holdouts.R](verification/2026-11-06_cv2-holdouts.R) | 0 → 20 | holdouts |
| [2026-11-06_cv2-recovery-apr-darkens.R](verification/2026-11-06_cv2-recovery-apr-darkens.R) | 0 → 10 | recovery-apr-darkens |
| [2026-11-06_cv2-recovery-apr-null.R](verification/2026-11-06_cv2-recovery-apr-null.R) | 0 → 10 | recovery-apr-null |
| [2026-11-06_cv2-recovery-apr-shorter.R](verification/2026-11-06_cv2-recovery-apr-shorter.R) | 0 → 10 | recovery-apr-shorter |
| [2026-11-06_cv2-recovery-may-darkens.R](verification/2026-11-06_cv2-recovery-may-darkens.R) | 0 → 10 | recovery-may-darkens |
| [2026-11-06_cv2-recovery-may-null.R](verification/2026-11-06_cv2-recovery-may-null.R) | 0 → 10 | recovery-may-null |
| [2026-11-06_cv2-recovery-may-shorter.R](verification/2026-11-06_cv2-recovery-may-shorter.R) | 0 → 10 | recovery-may-shorter |
| [2026-11-06_cv2-score.R](verification/2026-11-06_cv2-score.R) | 0 → 10 | score |
| [2026-11-06_cv2-summary.R](verification/2026-11-06_cv2-summary.R) | 0 → 11 | summary |
| [2026-11-06_cv2-tests.R](verification/2026-11-06_cv2-tests.R) | 0 → 21 | tests |
| [2026-11-06_cv2-winner.R](verification/2026-11-06_cv2-winner.R) | 0 → 24 | winner |

## Branches and registered worktrees at handoff

No branches were switched, committed, merged, pushed or removed. `cv-v2` in this worktree awaits Chris’s review/commit, the frozen-commit verification jobs and merge decisions. Other branches/worktrees below predate this task; their owner’s pending action was not investigated. Detached verification worktrees are retained run records; cleanup/reuse awaits their owner’s decision. The listing records registrations, not whether a process is currently using each checkout.

Unmerged local branches relative to `chris-dev`:

```text
  albedo-build
  anchor-guard
  annotated-interp
  astra-reports-2026-11-04
  centre-elevation-tool
+ cleanups-2026-11-03
  convergence-report
  cv-and-period-guards
+ cv-design
+ cv-hindcast-comparison
  cv-run1-records
* cv-v2
  diagnostic-plots
  docs-nits-2026-11-03
  drift-fixes
+ feature/single-config
  file-reviews-2026-10-18
  fix-variant-components
  forcing-breakdown
  headline-partial-ice
  housekeeping-2026-10-17
  i01-regression-contract
  i02-month-indexing
  i03-config
  i04a-settings
  i04b-settings
  i05-manifests
  i06-wiring
  i07-paths
  i11-pair-differences
  i15-figure-notes
  i15a-comments
  i15b-helpers
  i15c-script1
  i15c-script2
  i15c-script2-albedo-names
  i15c-script3
  i15c-script5
  i15c-script6
  i15c-script8
  i15c-script9
  i15c-scripts7
  i16a-tail
+ i16b-calibration
  i16c-elevation
  i17-path-readability
  ladder-aic
  merge-check-trunks
+ northeast-benchmark
+ northeast-forest-check
  northeast-location-plot
  northeast-settings
  northeast-title
+ old-scripts-archive
  references-audit
  refit-modis
  refit-plan
+ refit-runs
+ repo-organisation
  review-simplicity-rule
  roles-sync
  simplicity-review-2026-11-01
  simplify-2026-11-01
  simplify-anchor-check
  simplify-docs
  simplify-redundant-io
  snow-mixing-decision
  vc-review-2026-11-03
  verification-records-2026-10
  verify-tool
  writing-tools
```

Registered worktrees:

```text
/home/expert/Documents/contracting/Andria/paleo-RF                  451ea5c [i16b-calibration]
/home/expert/Documents/contracting/Andria/paleo-RF-verify/014e8a3   014e8a3 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/019ec98   019ec98 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/03f0cab   03f0cab (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/057b9f2   057b9f2 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/073079d   073079d (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/0b8c031   0b8c031 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/0df176d   0df176d (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/0e73cb5   0e73cb5 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/11356e0   11356e0 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/1158f29   1158f29 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/117bfdb   117bfdb (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/11ec216   11ec216 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/1716516   1716516 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/1ade8d3   1ade8d3 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/1ce2ca1   1ce2ca1 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/1ea8de4   1ea8de4 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/200b414   200b414 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/2138f8f   2138f8f (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/21409f4   21409f4 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/22330cd   22330cd (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/25cde3a   25cde3a (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/2664599   2664599 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/28011db   28011db (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/280a9a0   280a9a0 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/294e201   294e201 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/29d964c   29d964c (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/2bd4ab5   2bd4ab5 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/2ca4171   2ca4171 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/2eda936   2eda936 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/2f5f066   2f5f066 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/300c2a6   300c2a6 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/31ac4d7   31ac4d7 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/334afa3   334afa3 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/33aec25   33aec25 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/3ba159a   3ba159a (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/3d6a05a   3d6a05a (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/40cd5ce   40cd5ce (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/41c1701   41c1701 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/44b4b84   44b4b84 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/44d0605   44d0605 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/44d6a06   44d6a06 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/4672560   4672560 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/4946d09   4946d09 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/4ba4d2a   4ba4d2a (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/4bb95e1   4bb95e1 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/4d2c1b1   4d2c1b1 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/4f4245e   4f4245e (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/4f7e8db   4f7e8db (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/5164b91   5164b91 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/51888b4   51888b4 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/527ea1c   527ea1c (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/52a6237   52a6237 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/54decc7   54decc7 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/5895f97   5895f97 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/58bd502   58bd502 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/5bf769e   5bf769e (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/5ddcb94   5ddcb94 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/5deabac   5deabac (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/61b5447   61b5447 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/66fedb3   66fedb3 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/6841c48   6841c48 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/70a30aa   70a30aa (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/74b5482   74b5482 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/74c4cf7   74c4cf7 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/75945ee   75945ee (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/7850d46   7850d46 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/795792f   795792f (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/79f1491   79f1491 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/7c2bec3   7c2bec3 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/7e6f30c   7e6f30c (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/83415db   83415db (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/837f2d3   837f2d3 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/84b8689   84b8689 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/88356cf   88356cf (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/89f7d17   89f7d17 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/8b85be9   8b85be9 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/8b8e432   8b8e432 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/8db4a5e   8db4a5e (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/8e3f3a4   8e3f3a4 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/8e715d2   8e715d2 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/95fedfa   95fedfa (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/9a08244   9a08244 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/9ca2ed8   9ca2ed8 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/9d38612   9d38612 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/9ea33e1   9ea33e1 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/9ec468c   9ec468c (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/a3cfe68   a3cfe68 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/a83d9d5   a83d9d5 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/a9dcdc2   a9dcdc2 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/ab454c4   ab454c4 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/ac05239   ac05239 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/ac90729   ac90729 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/b0c706c   b0c706c (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/b0cf6b1   b0cf6b1 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/b215344   b215344 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/b43e7e3   b43e7e3 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/b689642   b689642 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/b7a5772   b7a5772 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/b835c95   b835c95 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/ba5e69a   ba5e69a (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/baa4ae2   baa4ae2 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/bd174cf   bd174cf (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/be277d7   be277d7 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/c0098cb   c0098cb (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/c2ccdb1   c2ccdb1 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/c3ef429   c3ef429 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/c7d6b6c   c7d6b6c (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/c86e4b5   c86e4b5 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/cca9ece   cca9ece (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/ccb6da6   ccb6da6 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/ce2577e   ce2577e (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5   d5d5df5 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/d766260   d766260 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/d784aea   d784aea (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/d8b6ab1   d8b6ab1 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/dbff5bd   dbff5bd (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/dd6e0fc   dd6e0fc (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/df59853   df59853 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/e00a8d0   e00a8d0 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/e04de82   e04de82 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/e15faed   e15faed (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/e71b6ee   e71b6ee (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/e82f399   e82f399 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/e89ffbe   e89ffbe (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/eaec467   eaec467 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/eee1a3f   eee1a3f (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/eee9a2c   eee9a2c (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/f05628d   f05628d (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/f07ff68   f07ff68 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/f0be70e   f0be70e (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/f0c2536   f0c2536 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/f0ff501   f0ff501 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/f2bacb5   f2bacb5 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/f44881b   f44881b (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/f6ca119   f6ca119 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/f756cd3   f756cd3 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/f93628e   f93628e (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/f9f9e46   f9f9e46 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/fce14d1   fce14d1 (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-verify/ff31fcb   ff31fcb (detached HEAD)
/home/expert/Documents/contracting/Andria/paleo-RF-wt/archive       f052a0a [old-scripts-archive]
/home/expert/Documents/contracting/Andria/paleo-RF-wt/benchmark     07d7053 [northeast-benchmark]
/home/expert/Documents/contracting/Andria/paleo-RF-wt/cleanups      220d758 [cleanups-2026-11-03]
/home/expert/Documents/contracting/Andria/paleo-RF-wt/comparison    9993cf4 [cv-hindcast-comparison]
/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv            4dd2407 [cv-design]
/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2           8ca23ab [cv-v2]
/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature       c86e4b5 [feature/single-config]
/home/expert/Documents/contracting/Andria/paleo-RF-wt/northeast     a1083ed [northeast-forest-check]
/home/expert/Documents/contracting/Andria/paleo-RF-wt/organisation  5ae5b1c [repo-organisation]
/home/expert/Documents/contracting/Andria/paleo-RF-wt/questions     837c940 [chris-dev]
/home/expert/Documents/contracting/Andria/paleo-RF-wt/runs          f05628d [refit-runs]
```
