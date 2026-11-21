# Integration review of all the migration code (Astra, 20 November 2026)

*What this is: the final integration review that issue #16 and AGENTS.md require before the full-run gate.
Who wrote it: Astra (Codex, gpt-6-astra, reasoning effort ultra), read-only, on a detached checkout of
`feature/single-config` at 9c8dea1, from the brief `2026-11-20_integration_review_astra_brief.md`. Filed unchanged
below; the decisions on its findings are recorded with the gate.*

**Verdict.** No new scientific arithmetic blocker found by static review; legacy equivalence still requires the executable gate, and the verification gaps below need attention.

**Benefit.** Andria can change the analysis through one configuration file, retain the original analysis as a reproducible alternative, and trace each forcing result to its inputs and settings.

Reviewed `1b9d5a9 → 9c8dea1`. This is a read-only review, not a test result. I found no unrecorded numerical departure in the legacy path. The coverage correction, endpoint differences, kernel choices, model-fitting methods and slice labels agree with the recorded decisions. That conclusion does not establish the correctness of the inherited methods.

**Hand check.**

Take two cells, two slices and one month. Glacier albedo is 0.68; areas are 2 and 1 in consistent units.

| Cell | Older state | Younger state | Younger-minus-older albedo |
|---|---|---|---:|
| A | Ice fraction 0.7; vegetation albedo 0.20 | Ice fraction 0.3; vegetation albedo 0.30 | −0.122 |
| B | Ice-free; albedo 0.25 | Ice-free; albedo 0.20 | −0.050 |

For A, the mixed albedos are:

- Older: `0.7 × 0.68 + 0.3 × 0.20 = 0.536`.
- Younger: `0.3 × 0.68 + 0.7 × 0.30 = 0.414`.
- Original partial-ice split: vegetation `0.3 × 0.10 = 0.030`; ice `0.4 × (0.30 − 0.68) = −0.152`; total `−0.122`.

Both split rules agree for this retreat. For an **advance**, using already-adjusted fractions 0.3 → 0.7 and vegetation albedo 0.20 → 0.30, the total is `0.566 − 0.344 = 0.222`. The original split gives `0.070 + 0.152`; the smaller-exposed-share split gives `0.030 + 0.192`. Both sum correctly. This checks the split helper directly; the retained readvance adjustment can change the fractions before that helper runs.

With HadGEM3/CAM5 kernel values of −2 W m⁻² per percentage-point albedo, the two retreat forcings are +24.4 and +10 W m⁻². A CACK value of +200 W m⁻² per unit albedo gives the same values after the sign reversal. Thus:

- Regional mean: `(2 × 24.4 + 1 × 10) / 3 = 19.6 W m⁻²`.
- With a toy Earth area of 100: global equivalent `58.8 / 100 = 0.588 W m⁻²`.
- Script 10’s two band contributions sum to `0.488 + 0.100 = 0.588`.

The code agrees: [partial-ice arithmetic](R/differences.R:142), [kernel conversion](scripts/8_radiative.R:99), [breakdown arithmetic](R/forcing_breakdown.R:40).

I also checked the missing-month denominator. If cell A has January/February forcing 3/6 and cell B has missing/9, the global equivalent is `(2 × 4.5 + 1 × 9) / 100 = 0.18`. Script 10 assigns contributions 0.03 and 0.15. It correctly divides each cell by its own number of available months.

Additional checks agreed with the implementation:

- Median cover `(0.2, 0.2, 0.5)` is closed to `(2/9, 2/9, 5/9)`.
- MODIS black-sky 0.1, white-sky 0.3 and diffuse fraction 0.25 give blue-sky albedo 0.15.
- Coverage with one successful prediction among two observed cells and one missing observation is 1/2.
- Month selection uses calendar names rather than positions in a selected subset.
- Seed derivation separates scripts, months and simulation purposes; the tested month independence is consequential.
- The new split preserves the total; endpoint differences telescope; script 10 reconciles with script 9.

**Findings — useful deletions first, then necessary corrections.**

Line costs are estimates, including focused tests and short changelog entries.

**1. Nit — remove demonstrably unused calculations and catalogue entries.**

| Location | Removal or simplification | Source line cost |
|---|---|---:|
| [Script 4:15](scripts/4_calibration_model.R:15), 25–26, 57–58, 77 | Unused `alb_prod`, `cal_data2`, `cal_data3`, and `AIC_list` | +0 / −6 |
| [Script 7a:126](scripts/7a_alb_diff_full.R:126), 142, 145–147, 154–156 | Unused per-slice mixture/threshold totals and their unused intermediates | +0 / −15 |
| [R/paths.R:54](R/paths.R:54) | Uncalled `boundaries` catalogue entry | +0 / −1 |
| [Script 9:269](scripts/9_forcing_barplot.R:269), 297 | Remove `forcing_panels`; calculate the range directly from the two plotted value vectors | +1 / −4 |

The path entry and script 9 intermediate remain from the earlier whole-code review. These removals reduce misleading intermediate state without changing the scientific calculation. Preserve script 7a’s `vegetation_rows`, `alb_ice_thresh` and `alb_icesc_thresh`: the legacy method uses them.

**Verification:** parse and run the existing relevant checks through `verify_change.R`; anchored tables should remain byte-identical. Script 9’s axis limits should be identical. The gate cannot identify dead code, but can detect an accidental behavioral change during deletion.

**Total cost:** approximately **+4 / −26**, including the changelog.

**2. Should-fix — an unsuccessful Git comparison can pass the comments-only checker.**

[tools/check_comments_only.R:26](tools/check_comments_only.R:26) ignores the exit-status attribute from `system2("git", ...)`.

For an unknown base, `git diff` supplies no filenames. The checker consequently examines no files, returns `TRUE` at line 47 and exits zero at line 53. That is false verification evidence.

**Fix:** propagate the failed Git comparison using the existing error path. Add an invalid-base case to the existing throwaway-repository test, checking failure rather than merely printed diagnostics.

**Gate coverage:** neither planned scientific run nor the current comments-only tests catches this condition.

**Cost:** approximately **+9 / −0**, including the focused test and changelog. No new verification mechanism is needed.

**3. Should-fix — stochastic comparisons do not enforce equality of numeric cell identifiers.**

[tools/compare_tables.R:53](tools/compare_tables.R:53) treats every double column as a measurement. [The tolerance table](tests/anchors/tolerances.tsv:23) constrains only the `alb_*` columns of script 6’s summary.

Changing only a double-valued longitude can therefore leave `ok = TRUE`; longitude is reported as `UNCHECKED`. The regression contract requires identical identifiers. The summary’s deterministic columns are `year`, `x`, `y`, `elev`, `ET`, `OL` and `ST`.

The reporting is now honest—the earlier misleading verdict was fixed. The remaining problem is coverage of the contract.

**Simplest fix:** use the existing tolerance mechanism: add `max_abs = 0` rows for those deterministic columns, plus a fixture that changes only a numeric coordinate. Preserve Chris’s chosen report-only behavior when no tolerances are supplied. The tolerance-file amendment needs Chris’s recorded decision.

**Gate coverage:** the proposed seed-1 byte comparison would catch coordinate drift in that output. A tolerance-only comparison against the historical unseeded summary would not. The present tests intentionally confirm that unconstrained numeric columns can pass.

**Cost:** approximately **+15 / −0**, including seven tolerance rows, the focused test and changelog.

**4. Should-fix for handover — README promises batch provenance behavior in RStudio.**

[README.md:361](README.md:361) says manifests start immediately and errors mark runs failed.

[R/run_manifest.R:67](R/run_manifest.R:67) deliberately defers an interactive manifest until an output is written or the run finishes. Its error handler is installed only for batch sessions. The tests explicitly establish this behavior.

An RStudio user can therefore encounter an error with no manifest, or with a manifest still marked `started`.

**Fix:** qualify the existing paragraph: immediate creation and automatic failure recording apply to batch execution; describe the interactive behavior alongside it. No code change is needed.

**Gate coverage:** batch runs cannot expose this documentation error.

**Cost:** approximately **+7 / −1**, including the changelog.

The remaining README configuration ownership and run-order descriptions agree with the code, including script 7’s coarse differences feeding script 9 and script 10’s reconciliation.

**What the proposed verification misses.**

1. **All fitted-model equivalence.** Refitting 192 models, matching rounded AIC and matching selected-model predictions does not compare every ladder and spatial fitted function. The spatial experiments are particularly weakly covered by those anchors. The contract’s fitted-model standard is predictions within `1e−6`; [check_calibration_month.R:30](tools/check_calibration_month.R:30) is a selected-model check, not a general comparison of all saved fits.

   I recommend comparing the freshly saved legacy fits with their corresponding frozen fits on the calibration rows, using the existing tolerance. Reuse the completed fits; do not refit them again. Estimated addition to the existing gate specification and record: **+35 / −0**.

2. **Native kernel coordinate correctness.** The sign, scaling, selected variables, month/year branches and downstream row placement are internally consistent. Neither anchored reproduction nor agreement between kernels proves that the native arrays were geographically indexed correctly—especially CACK’s transpose/flip and shifted coordinates.

   C3(d) remains explicitly open. I recommend a small independent native-coordinate check at asymmetric locations and nonconsecutive months, covering the current climatology and legacy annual CACK branches. Expected values must come from native coordinates, not the same raster transformation under test. Estimated specification/check and record cost: **+35 / −0**.

3. **Scientific adequacy or convergence.** A completed script is not proof that every model converged. Script 4 prints convergence information for the ladder and prediction fits, but not the spatial fits. The known model-7 convergence question remains relevant. Inspect the saved fits’ actual convergence signals; matching an unconverged historical fit establishes reproduction only.

4. **Every alternative configuration.** Both planned full runs select Dalton ice. They do not regenerate NADI-1 products, the rebuilt MODIS product, real cross-validation jobs, recovery experiments or exploratory case studies. Their focused tests and separate verification records remain necessary evidence. The exploration tests include meaningful asymmetric-grid, transition-sign, shared-support and failed-fit cases; they are not substitutes for checking delivered real-data outputs.

5. **Inherited figure errors.** These remain recorded in general questions §8:

   - [Script 7:297](scripts/7_plot_preds.R:297): `year == year` retains every age on every per-age tile page.
   - [Script 7:332](scripts/7_plot_preds.R:332): the CV map uses SD legend labels.
   - [Script 2:265](scripts/2_calibration_lct_bluesky.R:265): native/coarse scatter labels are swapped.
   - [Script 7:403](scripts/7_plot_preds.R:403): Dalton difference-map outlines are missing for the youngest requested ages.

   These are existing defects, not new migration regressions. Numerical anchors do not inspect the first three figures; the historical ice-table anchors preserve the fourth behavior. A passing gate must not be presented as approval of these figures.

6. **Failure scenarios and provenance ancestry.** A clean full run does not test invalid references, RStudio stepping or stale-input overrides. Existing fixture tests cover many failures meaningfully. `allow_stale` records immediate mismatches; it does not propagate an upstream override through every descendant. `fill_missing` is off in the pipeline and completes historical settings in memory where explicitly allowed.

7. **Required-product completeness without explicit assertions.** The verifier checks recorded outputs; it cannot infer an omitted, unrecorded product. Use `require_all = TRUE` for the intended anchor sets, as the verifier already does. The command-line anchor checker’s partial-run default is insufficient for a whole-pipeline claim.

The seed-1 check establishes reproducible response draws for that configuration and environment. It does not establish complete predictive uncertainty. Historical tolerances constrain measured differences; they cannot establish scientific correctness.

The retained ice adjustment is also not a monotone-retreat algorithm: it replaces selected values once and can leave advances. Endpoint and split tests correctly exercise advances, missing fractions and telescoping. Requiring monotone retreat would contradict the behavior currently recorded, rather than verify it.

**Questions for Chris or Andria.**

- **Chris — scope of the gate claim:** include the saved-fit comparison and native-coordinate spot check above, or limit the report to anchored reproduction, successful execution and the existing method tests? I recommend including both. These are focused checks within the existing verification workflow; they add no pipeline option or new approval stage.

- **Chris — fixed glacier-albedo sensitivity delivery:** the 16 November decision says, “keep 0.68 for now, with 0.50 and 0.80 as sensitivity cases shown prominently.” Will those cases be delivered separately, or must they accompany this handover? The present configuration uses 0.68; its seasonal-column variants do not implement fixed 0.50 and 0.80 cases. Neither proposed run supplies them.

- **Existing questions remain existing questions:** the readvance treatment, interpretation of the two ice splits, seasonal glacier albedo and the retained figure slips still need their recorded decisions. Meanwhile, the code smooths readvances, emits both partial-ice splits under `endpoint`, and keeps the listed legacy figures. I found no reason to manufacture a new scientific decision from these open points.

No question registers were edited, as instructed.

**Not checked.**

No R execution, parsing, refitting, test execution, checksum recomputation, real-data numerical recomputation or figure inspection was performed. I did not independently revalidate publications or external datasets. Builders and exploratory tools received the requested lighter trace, including what their outputs hand downstream.

The Part 4 risks were traced through configuration consumers, calendars, masks, joins, RNG calls, manifests and verification. Historical merge correctness, hydrated LFS contents and bit reproducibility of all fits remain matters for executable evidence.

This review changed nothing and made no push. Local branches unmerged into `chris-dev` are `feature/single-config`, `i16b-calibration`, `northeast-forest-check`, `refit-runs` and `annotated-interp`. The first two await migration integration; `annotated-interp` is the retained reference copy. The remaining branches’ disposition was not established here. Occupied worktrees are the main checkout, `feature`, `gate-review`, `northeast`, `questions`, `runs`, and 151 retained verification worktrees. Their presence does not establish that a process is running; no cleanup was attempted.

**Not worth doing.**

Seven candidate recommendations were dropped: expanding dirty-tool tracking, requiring completed producer runs for every usable output, propagating stale flags transitively, introducing setting-level dependency manifests, adding an output registry, deleting the duplicate calibration fit, and restoring exploratory cross-run fingerprint guards. They reopen explicit decisions or add mechanisms without establishing a defect in the agreed workflow.

The earlier fixes for empty verification specifications, seeded-output accounting, interactive graphics, period-boundary crossing and frozen-holdout binding are present. They should not be reported again as outstanding.

**Estimated recommended line cost: fixes +35 / −27; two focused gate additions +70 / −0; total +105 / −27, net +78.** This includes tests and brief records, and authorizes no implementation.

Files read: project rules and listed review/decision records; both configurations; pipeline scripts and shared helpers; verification tools and tests; relevant builders, CV and exploration tools. Tools: 107 shell calls across the review and delegated tracing; no R, pipeline or web calls. One initial Git-status query triggered an LFS temporary-write attempt, which the sandbox denied.