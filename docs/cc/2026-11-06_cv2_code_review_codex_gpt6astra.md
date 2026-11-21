Fable’s rank diagnosis is confirmed. I recommend changing the concurvity report before the capacity jobs, while keeping the existing model and contrast calculation. No files were changed and no commits were made.

On the specified saved April REML fit:

| Check | Result |
|---|---:|
| `fit$rank` versus `length(coef(fit))` | **744 / 748** |
| Whole model-matrix rank | **744 / 748 columns** |
| Cover smooth’s model-matrix rank | **195 / 199 columns** |
| Cover’s unpenalized polynomial part, after centering | **5 / 9 columns** |

Both QR and singular-value checks confirm the cover rank. Before centering, the ten polynomial columns have rank six, exactly as Fable proposed. The fractions sum to one within `2.22e-16`.

I reproduced worst-case concurvity **4.35565123486** for cover explained by location, versus **0.999508232804** in the reverse direction. This is numerical failure: that measure should be symmetric and lie between zero and one. [mgcv documentation](https://stat.ethz.ch/R-manual/R-devel/library/mgcv/html/concurvity.html)

The deficiency does **not by itself invalidate physical cover predictions or the Vp-based contrast standard errors**. The four redundant coefficient combinations cancel wherever OL + ET + ST = 1. They also cancel from the contrast’s uncertainty calculation. In the saved-fit checks:

- Perturbing those coefficient combinations changed sampled predictions by at most `1.8e-14`.
- Adding covariance in those directions changed a sampled contrast variance by about `1.7e-17`.
- Prediction standard errors calculated from the model matrix and `Vp` matched `predict.gam()` exactly.

The [contrast helper](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/R/cv_separation.R:77) multiplies by `Vp`; it does not need to invert that singular matrix. This is consistent with [mgcv’s documented prediction calculation](https://stat.ethz.ch/R-manual/R-devel/library/mgcv/html/predict.gam.html).

Individual redundant coefficients remain unidentified, and predictions away from the sum-to-one plane would depend on arbitrary constraints. Physical mixtures outside the training hull still lie on that plane: their extrapolation uncertainty is a separate concern. These checks establish the algebra for the saved fit and sampled exchanges, not coverage of every historical contrast.

My decisions on the seven findings are:

| Finding | Decision | Evidence and recommendation |
|---|---|---|
| **1. Thin-plate concurvity** | **Agree with a change** | The rank defect and broken `worst` measure are established. Claiming that *every* reported measure is numerically meaningless goes further than the evidence: `observed` and `estimate` use different calculations. Nevertheless, suppressing the thin-plate pairwise report is prudent. Use **NA with an explicit reason**, and retain fit rank and coefficient count. Eight thin-plate configurations have location; the other two already report “not applicable.” [Code](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/R/cv_separation.R:196) |
| **2. Duplicate `month_capacity`** | **Agree** | It duplicates `exchanges$historical`, including its support calculation. Use that historical exchange for capacity and record its endpoints/exclusions once. Update the affected fixtures. [Code](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/tools/check_cv_separation.R:71) |
| **3. Fixed interpretation prose** | **Agree with a change** | Move fixed paragraphs to the run report, but retain **generated facts**, including completion/failure and chosen/no-choice messages—not merely numeric lines. Keep necessary figure labels, including the conditional-interval description. [Selection output](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/tools/cross_validate_albedo.R:449), [interpretation output](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/tools/check_cv_separation.R:258) |
| **4. Twelve in-range specs** | **Agree** | Four jobs containing three months each preserve all twelve months and the same fits. The driver already loops over supplied months and saves separate monthly outputs. This is housekeeping, not a scientific correction. [Code](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/tools/cross_validate_albedo.R:299) |
| **5. ET/ST eligibility comment** | **Agree** | Validating both endpoints already enforces ET ≥ 0.05 and ST ≥ 0.05. Explain that once above `fixed_exchange()`; do not introduce another filter. [Code](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/R/cv_separation.R:48) |
| **6. Combine record writers** | **Disagree as pre-run work** | They share header material but have different destinations and provenance: individual input hashes and named seeds versus a frozen-input hash and session information. An extra-lines argument alone does not preserve those differences. No defect justifies this refactor before running. [CV writer](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/tools/cross_validate_albedo.R:80), [separation writer](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/tools/check_cv_separation.R:16) |
| **7. Remove predicted depth table** | **Disagree** | `nearby_depth.csv` describes available geometry before fitting. `predicted_nearby_depth.csv` uses rows with finite predictions from both each candidate and model 8. They differ when fits fail; removing the latter would lose evidence of what was actually tested. [Code](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/tools/cross_validate_albedo.R:441) |

I would therefore drop two proposed trims: finding 6 adds refactoring without fixing a demonstrated defect; finding 7 removes distinct evidence.

For the verification additions:

| Addition | Decision | Evidence and proposed check |
|---|---|---|
| **Rank check** | **Agree with a change** | Include the cover-block rank, not just whole-fit rank; the results above establish the cause. Also test the chosen reporting policy: missing thin-plate concurvity must retain location EDF and an explanation. Existing tests check matrix direction, not numerical validity. [Test](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/tests/test_cv_separation.R:116) |
| **Linear-cover invariant** | **Agree** | For the fixed exchange, every cell’s logit change must equal `0.1 * (beta_ET - beta_ST)`. Check the endpoint matrices for all five linear configurations using the existing setup fixture. Response-scale changes need not be constant. [Existing setup test](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/tests/test_model_registry.R:60) |
| **Hand number through scoring** | **Agree** | The current “manual” comparison reuses the scoring functions. I independently calculated and checked **0.002323295918367347** for `lin_cover_noloc`; the stage returned **0.00232329591836735**, with represented weight **2/3**. Add these expected values to the existing fixture. [Test](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/tests/test_cross_validation_stages.R:59) |
| **Either endpoint outside** | **Agree** | The implementation correctly uses OR, but the current subset test supplies the combined flag directly. Exercise actual hull checks for inside/inside, outside/inside, inside/outside and outside/outside; expect `FALSE, TRUE, TRUE, TRUE`. [Code](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/R/cv_separation.R:55) |
| **Holdout `identical()` check** | **Agree with a change** | Monitor it, but retain the strict comparison. No attribute-only failure has been demonstrated. If it fails, inspect the difference before exempting any specific harmless attribute. [Spec](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/docs/cc/verification/2026-11-06_cv2-holdouts.R:5) |

For Chris’s three questions, my recommendations are **(b), NA with a reason**, supplemented by rank/count columns; **four in-range jobs covering all twelve months**; and **fixed interpretation prose in the report**, retaining generated facts beside the outputs.

All 74 changed R files parsed. Eleven of the twelve specified test scripts passed. `test_paths.R` stopped because this checkout lacks `output/calibration/calibration_model_stats.csv`, the baseline fixture it copies; that limitation was already documented in the implementation notes. No models were refitted.

Before the run, I recommend:

1. Suppress thin-plate pairwise concurvity with a clear reason; save rank and coefficient count before discarding fits.
2. Add the reporting-policy, linear-invariant, independent-score and endpoint-support checks above.
3. Remove the duplicate historical exchange and add the ET/ST eligibility comment.
4. Move fixed prose into the run report while preserving generated status and essential labels.
5. Consolidate the in-range specs into four jobs and update the job counts.
6. Provide the missing baseline fixture and complete verification at the final code commit.