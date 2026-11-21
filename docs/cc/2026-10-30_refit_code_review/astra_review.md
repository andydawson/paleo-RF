**Verdict.** Proceed to controlled verification after the fixes below; not ready to merge. I found no demonstrated arithmetic error in the MODIS attachment itself.

**Benefit.** This lets Andria measure how documented, land-only MODIS calibration responses change the forcing estimates and the northeast hemlock result.

**Hand check.**

The reader agrees with its hand-written expectations. With predictor order **B, A**, and input rows shuffled:

| Selection | January: B, A | February: B, A |
|---|---|---|
| `full_75`, all-days | 0.40, NA | 0.35, 0.30 |
| `full_75`, snow-free | 0.25, NA | 0.22, 0.20 |
| `full_75`, snowy | 0.70, NA | 0.65, 0.60 |
| `full_nocut`, all-days | 0.42, NA | 0.36, 0.31 |

`R/preparation.R:132–134` selects by month and matches centres in predictor order. Missing January does not remove February. Script 2 replaces an exact zero with `0.0001`; NA remains missing. There is no second MODIS scale factor. The six predictor columns remain untouched, so fractions such as `ET=0.2, OL=0.5, ST=0.3` still sum to one.

For interval coverage, take two cells: observed albedo `0.4` inside `(0.3,0.5)`, and an unobserved cell. `in_credible = c(TRUE, NA)`. The old calculation gives `1/2`; the changed calculation gives `1/1`. That implements Chris’s decision for either source.

For the downstream sign check, use one month and two slices. Cell A changes from `0.4` to `0.3`; cell B stays at `0.2`. A kernel of `−0.5 W m⁻²` per `0.01` gives A `−0.1 × 100 × −0.5 = +5 W m⁻²`, B zero. CACK `+50` per unit albedo gives the same result through its explicit minus sign. With cell areas in ratio 1:3, the regional mean is `1.25`; the global equivalent is `5 × area(A) / earth_area`. These agree with the inspected formulas. The change introduces no new time baseline, area normalisation or ice-advance treatment.

**Findings.**

1. **Should-fix — the model-7 diagnostic does not establish that only the iteration limit changed.**  
   [tools/check_model7_convergence.R:33](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-refit-modis/tools/check_model7_convergence.R:33).

   It correctly uses `saved$method`, but obtains the formula and controls from the current registry and data from a separate RDS. It neither verifies the saved model frame against those data nor aligns rows before subtracting fitted vectors at line 40. Equal row counts do not establish equal observations. A reordered table can produce a false fitted-value change; a replaced response table can make an AIC change look like a convergence effect. Unequal vector lengths can also trigger R’s recycling.

   **Fix/check:** before fitting, verify the response, predictors, formula, family/link and fitting controls against the saved fit. Preserve its controls except `maxit`. Compare fitted values on explicitly identical rows. Extend the test with reordered rows, changed responses and changed missingness: each must either be reconciled explicitly or rejected. The existing unchanged-data control is useful but cannot catch these cases.

2. **Should-fix — the planned four-month runs can produce results labelled as annual.**  
   [R/forcing_breakdown.R:44](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-refit-modis/R/forcing_breakdown.R:44); `scripts/9_forcing_barplot.R:172`; `scripts/10_forcing_breakdown.R:107`.

   The existing aggregation averages the available selected months. With November–February selected, it divides by four where all four are available. Nevertheless, script 10 retains `contribution_to_annual` and prints “annual global-equivalent forcing”. Its reconciliation with script 9 still passes because both use the same four-month denominator.

   **Consequence:** a seasonal sensitivity can be mistaken for an annual change. Four winter values of 3 and eight other values of zero give a winter mean of 3, but an annual mean of 1.

   **Fix/check:** retain the approved four-month experiment, identify its outputs explicitly as November–February means, and compare against the same months of the main run. Test the numerical example above. This is an existing limitation exposed by a newly planned use, not a new error in the MODIS reader.

3. **Should-fix — the changed coverage statistic lacks a committed test and an explicit invalid-interval check.**  
   [scripts/5_calibration_eval.R:194](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-refit-modis/scripts/5_calibration_eval.R:194), lines 214 and 219.

   The denominator is correct for the stated requirement. However, `sum(in_credible, na.rm=TRUE)` also discards an undefined interval for an **observed** cell while retaining that cell in the denominator. That silently treats a failed interval calculation as a miss. No committed test exercises the changed expression.

   **Fix/check:** assert finite, ordered interval bounds for observed cells; test observed-inside, observed-outside, missing-observation and observed-with-missing-interval cases. A month without observations must stop or be explicitly undefined. Do not “fix” this by silently dropping observed cells from the denominator.

4. **Should-fix — the scientific records have not caught up with this change.**  
   [docs/cc/questions_for_andria_scientific.md:216](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-refit-modis/docs/cc/questions_for_andria_scientific.md:216).

   B2b still describes the denominator correction as something worth doing. B5 describes the raster calculation without distinguishing the new default. The implementer also explicitly left the newly raised snow questions unfiled.

   **Fix/check:** the main session should record decision 4 as implemented, distinguish historical and current behaviour, and file the unresolved scientific questions with their origin. I made no edits, as instructed.

The regression references are also a **merge gate**, deliberately deferred by the implementation brief. The correction necessarily changes the seeded statistics CSV and invalidates the historical unseeded coverage comparison. This is an expected consequence of the approved change, not evidence that the correction is wrong.

**What the proposed verification misses.**

- **Legacy preservation remains unproved by execution.** The raster diff retains the extraction, resampling and table calculations. Moving the grid read and adding `print()` do not reveal a numerical change on inspection. Script 1 and scripts 6–10 have no changed calculation in this range; the default fitting controls are preserved. Nevertheless, byte identity requires the prescribed staged runs. The intended exception is script 5’s coverage column.
- **Script-2 integration needs committed executable evidence.** Assert the exact 18 columns, predictor order, selected CSV values, NA preservation, zero floor and manifest counts. Verify the ice exclusion and unmatched sets together. Given the packet’s counts, `2860−48=2812`, with four unmatched predictors and `48+10=58` MODIS-only centres after masking. I did not independently remeasure these counts.
- **Snowy feasibility is unestablished.** The reader tests permit all-NA months and do not show that every snowy month supports the unchanged bases. Record complete fitting-row counts and check whether the unchanged models can be fitted before launching the complete ladder. Do not silently change basis sizes or fill responses.
- **The replacement version test checks only where versions should agree.** Add a known high-angle case where the screen must remove a retrieval and a quality case distinguishing full from magnitude inversions. Agreement away from the screen does not establish correct behaviour where it acts.
- **A successful diagnostic command is not a convergence gate.** The model-7 tool reports nonconvergence but returns normally. Verification must inspect the reported result, including the converged control month.
- **Reproducibility needs a MODIS repeat.** No changed production line adds a random draw or alters `derive_seed()`. Legacy simulations should therefore remain unchanged at the same seed and environment. Across different fitted models, the same seed does not establish paired draws. Keep 100 draws unless separately changed; bound draw noise once. Historical byte comparisons require the contract’s thread settings, independently of the approved settings for new runs.

The new reader and schema are appropriately small. I found no extra calibration-table columns, inappropriate scaling, cross-month deletion, or downstream consumer requiring the omitted MODIS coarse table.

**The implementer’s six decisions.**

| Decision | Assessment |
|---|---|
| **1. `2.5e-6` rounding tolerance** | Accept. With rounding error at most `ε=5e-7`, the weighted conditional-albedo errors contribute at most `ε`, three share errors at most `3ε`, and the all-days value another `ε`: `5ε=2.5e-6`. State the assumptions that shares sum to one and albedos lie in `[0,1]`, and check those properties. This is a representation bound, not a stochastic tolerance. |
| **2. Replace equal-days ⇒ equal-albedo** | Accept the replacement, with the additional discriminating test above. The original implication is false even without rounding: one version may retain one year with ten days at 0.2, another two years each with ten days, at 0.2 and 0.8. Both report ten days per retained year; their albedos are 0.2 and 0.5. |
| **3. Put row count in `fit_convergence()`** | Accept. It reports the saved model-frame size and avoids duplicate formatting. Counts alone do not establish row identity. |
| **4. A second raster-only `if` after the shared write** | Accept. It keeps the coarse products source-specific without duplicating the shared preparation. |
| **5. Move the grid read** | Accept. It removes an unused MODIS input. No numerical dependency on its previous position was found. |
| **6. Explicitly print three raster plots** | Accept. This preserves plotting when those expressions move into a block. Verify the resulting figures during the legacy run. |

The builder change is safe on inspection. The base script’s SHA-256 is exactly the newly accepted `2ee39123…aa5`. The diff contains the window-comment correction and the explicit acceptance-list entry; no reduction arithmetic changes. The final script is therefore **not wholly comments-only**, but the acceptance change is narrow and retains the separate settings check.

**The implementer’s five open questions.**

1. **Test reformulations:** accept them for the reasons above, with explicit share invariants and a case where screening acts.
2. **Unseeded anchor:** do not widen `0.02` to accommodate a different estimand. Regenerate the seeded CSV and its `MD5SUMS.txt` entry in the separately authorised commit. Preserve the historical unseeded file; Chris should choose between a separately documented corrected reference and retiring only its obsolete coverage-column comparison. Retain the other stochastic checks. Rounded historical percentages cannot reconstruct the corrected reference exactly.
3. **Default baseline locations:** the concern is real, but manifests normally stop script 2 against an old script-1 product first. Use separate run directories for every planned experiment and leave frozen baseline products intact.
4. **New schema key:** correct. Old manifests differ; old saved configurations also fail schema validation if `analysis$albedo` is absent. `allow_stale` cannot repair an invalid configuration. Current-config verification specs can use the existing seed/copy override. Fresh scenario runs should have matching upstream manifests.
5. **Unfiled questions:** the main session should file them now. This review neither answers them nor turns them into decisions.

**Questions for Chris or Andria.**

- **Chris:** which narrowly scoped treatment of the obsolete unseeded coverage comparison should be recorded? Meanwhile, the changed code calculates observed-cell coverage and both existing reference checks remain incompatible with that column.
- **Chris:** where are the completed reference identity and supporting-passage audits required by decision 7? The packet records them as started; I found no completion record among the supplied documents.
- **Chris:** if a snowy month cannot support the unchanged model, should that experiment stop pending a separate method decision, or should a smaller model be proposed and reviewed? Meanwhile, the code attempts the existing bases.
- **Andria:** how should winter “snow-free” retrievals beneath conifer canopy be interpreted, and should low conditional support eventually lead to exclusion, weighting or qualification only? Meanwhile, the code uses the supplied conditional means without a coverage filter or weights. Mixing remains a separate change.

**Not checked.**

No pipeline or verification run was performed. The attempted `tests/test_preparation_albedo.R` invocation failed before execution with `Fatal error: cannot create 'R_TempDir'`. Consequently, the implementer’s test-pass claims, real-table extrema and counts, fitted convergence, rendered maps and byte identity are not independently confirmed here. I did not read Fable’s review conclusions, audit the cited literature, inspect the large CSV directly, or revalidate kernel-file metadata and the unchanged C2 behaviour.

The reviewed checkout was clean at `1a041d1`. The supplied decisions document contains numbered items 1–7, not 1–9; I reviewed those and the implementation brief.

Files read: project rules, decisions/plan/brief/build report, regression contract and question files; changed code/tests/configuration/provenance plus relevant preparation, manifest, prediction, differencing, kernel and aggregation code and anchor records. Tool calls: `functions.exec` with read-only `exec_command` inspection and one failed test invocation; no edits or pipeline runs.