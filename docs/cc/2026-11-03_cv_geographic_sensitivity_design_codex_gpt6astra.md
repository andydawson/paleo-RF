*Astra (gpt-6-astra, ultra effort, web search), 3 November 2026, for Chris: separating each candidate's geographic penalty from its cover-extrapolation skill. Brief: `2026-11-03_cv_geographic_sensitivity_design_brief.md`. Issue #24. Links relative to the repository root.*

**Summary**

- **Measure and report the geographic sensitivity; retain the current selection rule.**
- Benefit: the paper can show whether a candidate’s advantage depends on predicting across geographic gaps.
- Fit all 13 candidates on the existing in-range holdout: **156 fits, 132 more than the budgeted 24**, before retries.
- Report genuinely in-range errors, paired comparisons with model 8, and errors by distance from training.
- Neither this comparison nor distance matching identifies a pure geographic penalty.
- The existing control reaches only 353 km; 46% of the northeastern d2 validation cells lie farther away.
- Do not subtract or divide by each candidate’s control error, or introduce a second selection criterion.
- Freeze this amendment after Fable’s review and Chris’s decision, before any fit or score.

## 1. Is it worth doing?

**Yes, as a diagnostic. A numerical correction to the selection score is not justified.**

The current test asks each model to predict unfamiliar cover **and**, where that cover is geographically concentrated, unfamiliar locations. The hindcast often changes cover at locations already represented in calibration. Environmental and geographic withholding can therefore test different capabilities. Roberts et al. explicitly discuss their combined effects; NNDM and kNNDM establish why validation geography should reflect the intended prediction task. [Roberts et al., 2017](https://doi.org/10.1111/ecog.02881); [Milà et al., 2022](https://doi.org/10.1111/2041-210X.13851).

**Which candidates could be affected?** Models 3–8, `lin_cover` and `mod8_small_cover` must predict their location smooth across the hole. `mod8_coarse_loc` may behave differently because its location term has less flexibility. `cover_elev` and `lin_cover_noloc` avoid that particular prediction problem.

That does **not** establish the ranking. A location term could still help across the gap. Models without coordinates also suffer when withholding removes relevant environments or regional relationships. Distance-dependent performance occurs in nonspatial models too. [Brenning, 2023](https://doi.org/10.1080/13658816.2022.2131789).

### How much could it matter?

The verified inputs establish substantial exposure, but **cannot establish an albedo-error penalty before fitting**.

The following calculations use run 1’s saved holdouts and actual monthly training rows. Tail rows are restricted to groups with positive selection weight.

| May validation set | Scored cells | Nearest training distance: 10th / median / 90th percentile |
|---|---:|---:|
| Existing control, genuinely inside its training hull | 545 | 66 / 111 / 236 km |
| d1 | 562 | 82 / 270 / 672 km |
| d2 | 563 | 65 / 174 / 423 km |
| d3 | 332 | 82 / 194 / 458 km |
| Northeast within d2 | 82 | 167 / 340 / 524 km |

Three consequences matter:

- The control’s maximum distance is **352.8 km**. Beyond it lie **38/82 northeastern d2 cells**, and **16.1% of the complete target-weighted validation score** across months and holdouts. Reweighting existing control predictions cannot supply these missing distances.
- Northeastern validation rows carry **8.9% of the primary score’s effective weight**. The previously reported 5% concerns four historical slices, a different denominator. A uniform change of \( \delta \) in those validation rows’ squared errors changes the overall MSE by approximately \(0.089\delta\). Geographic effects elsewhere add to this.
- The control itself withholds 61 northeastern cells. Only 51 remain inside its training cover hull, occupying **four blocks**. Its regional result will have limited replication.

These are geometry and weighting calculations, not model results. They reproduced all 36 saved modern distance summaries and feasibility counts; the calibration checksum matched the verification record.

The zero-distance comparison also needs its existing qualification: it applies to the northeast here, but missing winter calibration observations create substantial hindcast distances elsewhere.

### Do the existing safeguards solve this?

They limit uncertainty from the available comparison, **not the mismatch in prediction task**:

- **Pairing** removes some variation from comparing models on different cases. It cannot cancel a geographic effect that differs between candidates.
- **Block bootstrap** measures variation across the observed validation blocks, conditional on the fitted models and these holdouts. It does not reconstruct predictions at occupied training locations.
- **The one-SE rule** avoids choosing extra complexity for small, uncertain gains. Its preference for fewer coefficients can favour a no-location model; it is not protection against geographic confounding.

The paired uncertainty and simplicity principles have published support; this project’s exact block-resampled rule remains its declared adaptation. [Yates et al., 2023, model-selection section](https://doi.org/10.1002/ecm.1557).

There is also a basic information limit. Each cell supplies one modern albedo per month. Keeping that observation in training to preserve local information, then scoring its prediction, would cease to be held-out validation. The present data cannot directly observe “new cover at this same place” while retaining an independent local calibration response.

## 2. Options, simplest first

Fit counts below exclude retries and retain the existing **468 maximum tail fits**. Additional counts compare with the protocol’s budgeted 24 control fits.

| Option | Diagnostic fits; additional fits | Effect on choice | Basis and main risk |
|---|---:|---|---|
| **A. Report existing tail errors by geographic distance** | Existing 24; **+0** | None | A descriptive adaptation of Brenning’s distance diagnostics. Cover difficulty also changes with distance, so it reveals association rather than a geographic penalty. |
| **B. Extend the existing control to all candidates, with distance reporting** | **156; +132** | None | Structured validation and all-candidate reporting follow Roberts and Yates. Shows performance on ordinary cover under spatial withholding, but uses different cases and distances from the tails. **Recommended.** |
| **C. Use the control in selection** | **156; +132** | Adds a second objective or changes the score | A dual one-SE requirement borrows the simplicity principle, but the combined rule is **our unvalidated adaptation**. Subtracting control error has a more fundamental problem, below. |
| **D. Match control distances to tail distances** | Reweight B: **+0 beyond B**. One new control split per tail: **468; +444** | None if diagnostic; otherwise changes selection | NNDM/kNNDM support distance-distribution matching. Matching to *tail holdouts* instead of the hindcast is **our adaptation**. Missing support, changed training size and regional differences remain. |
| **E. Compare the same validation cells with and without global tail exclusion** | Up to **624; +600** | None if diagnostic | A project experiment informed by Roberts’ comparison of spatial and environmental withholding. Better pairing of test cases, but exclusion still changes geography and training composition. Too much additional fitting for the proposed benefit. |

If model 8 itself wins, the current code deduplicates the control to 12 fits. Option B then adds **144**, rather than 132.

### C: why not adjust each candidate by its own control score?

Consider these **illustrative MSEs**, not results:

| Candidate | Tail MSE | Control MSE | Tail minus control |
|---|---:|---:|---:|
| A | 0.0009 | 0.0001 | 0.0008 |
| B | 0.0016 | 0.0010 | **0.0006** |

Subtraction selects B even though it predicts worse on both tests. Dividing by the control error has the same problem: poor control performance can improve the adjusted ranking.

There is no established additive decomposition here. Even if a response-scale error could be written as geographic error plus cover error, its square contains their cross-product. Different locations, cover mixtures and fitted smooths further prevent the control MSE from being the geographic component of the tail MSE.

A **dual one-SE gate** is more defensible as a policy: retain candidates comparable to the best on both tests, then choose the simplest. But it changes Chris’s decision 6, does not isolate geography, and may leave no candidate. Its necessary prespecified outcome would be **no automatic choice**, rather than an improvised fallback. I do not recommend it for this amendment.

### D: what distance matching would accomplish

Matching can reduce **one measured difference** between the two tests. It cannot make their only remaining difference cover extrapolation.

NNDM and kNNDM explicitly acknowledge limitations involving predictor distributions, actual locations, distance directions and nonstationarity. Matching marginal distances also leaves training size, surrounding-neighbour geometry, elevation and regional relationships unmatched. [Milà et al., 2022, §4](https://doi.org/10.1111/2041-210X.13851); [Linnenbrink et al., 2024, §4](https://doi.org/10.5194/gmd-17-5897-2024).

For this dataset:

- Reweighting the existing control must exclude unsupported distances and disclose their weight. It cannot recover the full target.
- Creating controls with larger geographic holes could extend support, but removes more training data and may also remove cover extremes.
- A conventional \(k\)-fold implementation requires **\(156k\) fits per configuration**—780 for five folds. That expense does not establish a clean decomposition.
- Matching the tail’s positive distances would reproduce the tail test’s geography. It would not reproduce the northeast hindcast’s zero distances.

I would therefore report distance distributions and errors first, without matching weights or fitting an error-versus-distance adjustment.

### E: the strongest paired alternative

Let \(V\) be the existing withheld blocks and \(H_d\) a cover tail. Compare:

1. training outside \(V\);
2. training outside \(V \cup H_d\);

on the **same cells in \(V \cap H_d\)**, retaining only cases inside the first fit’s cover hull.

This measures the effect of removing the remaining tail examples. However, that removal also changes geographic distances, sample size and fitted smoothness. Existing tail fits train outside \(H_d\), so they generally cannot supply the second fit.

It is a coherent additional experiment, not a pure cover-error measurement. No better simple decomposition emerged from the literature reviewed.

## 3. Recommendation and implementation

**Adopt B: all-candidate blocked in-range reporting, supplemented by descriptive distance tables. Keep the tail selection rule.**

The result should be called **blocked in-range accuracy**, not “the geographic penalty”. A reversal of rankings between tests would demonstrate sensitivity to the validation task; it would not identify which component caused it.

### Exact protocol addition

> **Geographic sensitivity, fixed before fitting.** Fit all thirteen candidates on the existing seeded one-fifth block holdout. Report accuracy only on cells inside that month’s remaining training cover hull, with excluded cells and failed fits counted. Report monthly RMSE, signed error and paired MSE differences from model 8; combine monthly MSEs with equal month weights. Report errors separately in geographic-distance bands [0,100), [100,250), [250,500), and [500,∞) km, with cell/block counts and actual distance ranges. Before fitting, report training counts, cover support and the tail-score weight beyond the control’s distance range. These are descriptive checks of geographic sensitivity, not an additive geographic penalty. They do not alter eligibility, the selection score or the choice. Unsupported comparisons remain untested. Neither diagnostics nor the hemlock sign trigger reselection.

Equal-month control aggregation and the four distance bands are **our reporting judgements**, not published optimal settings. Binning existing predictions is a lighter adaptation of Brenning’s buffered prediction-error profiles; no error curve is extrapolated. [Brenning, 2023, methods; accessible author preprint](https://arxiv.org/pdf/2111.08478).

For the report:

- Keep the existing target-weighted tail score beside the control score, clearly identifying their different populations and weights.
- Use the same predetermined evaluation rows for every candidate. A failed diagnostic month makes that candidate’s aggregate incomplete; successful months may still be shown individually.
- Reuse the existing block bootstrap for aggregate paired differences against model 8, keeping months together. Small regional or distance-bin tables remain descriptive, with counts.
- Preserve the monthly cover-direction and cover-distance labels beside geographic distance. Geographic bands must not be interpreted as controlling cover difficulty.

### Minimal code

Line numbers refer to the inspected checkout, `057b9f2`.

| File and location | Change |
|---|---|
| [tools/cross_validate_albedo.R:144](tools/cross_validate_albedo.R:144) | Extend pre-fit reporting for the **existing** control membership: monthly training count, inside/outside-hull counts, blocks and distance coverage. Apply the existing training-row feasibility floor. |
| [tools/cross_validate_albedo.R:220](tools/cross_validate_albedo.R:220) | Use `CV_MODELS` for the control; remove its dependency on `scores.csv`. |
| [tools/cross_validate_albedo.R:233](tools/cross_validate_albedo.R:233) | Save nearest-training kilometres once per validation row, reusing `nearest_km()` at line 76. |
| [R/cross_validation.R:150](R/cross_validation.R:150) | Add one small `cv_geography_report()` helper for grouped counts, distances and descriptive errors. Reuse `cv_score()` for equal-month control scores and paired block uncertainty. |
| [tools/cross_validate_albedo.R:302](tools/cross_validate_albedo.R:302) | Replace the console-only control summary with saved all-candidate and distance reports; label incomplete comparisons explicitly. |
| [tests/test_cross_validation.R](tests/test_cross_validation.R) | Add the hand-worked checks below. |

No new formulas, matching package or configuration framework are needed. `cv_choose()` remains unchanged.

### Hand-worked checks and verification

1. **Distance:** identical coordinates give zero; one degree along the equator gives approximately 111.195 km; the nearest of two training points is selected.
2. **Cover support:** triangle interior and boundary points qualify as in-range; a point beyond an edge does not. A no-cut holdout must not automatically be labelled in-range.
3. **Monthly weighting:** January squared errors \(0.04,0\), February \(0.09\), give equal-month MSE **0.055**, rather than pooled-cell MSE 0.04333.
4. **Pairing:** identical model predictions give zero paired difference and zero SE. Block resampling keeps all months and candidate errors together.
5. **Distance boundaries:** 100, 250 and 500 km enter the upper intervals. Empty intervals have zero cases and missing error, never zero error.
6. **Failure and isolation:** a failed control fit produces an incomplete diagnostic. Adding, removing or changing control predictions leaves tail scores, bootstrap draws and selection unchanged.
7. **Common data:** all thirteen candidates receive identical training and validation rows, with month-specific missingness preserved.

After approval, verify through a dated `tools/verify_change.R` spec at the implementation commit, in its separate worktree. Use the verified run-1 inputs; run parsing, existing tests, these new cases and the holdouts stage. Compare existing memberships, directions, targets and feasibility against `cv-holdouts-7`, and reproduce the new geometry counts above. A stubbed fitting call can check candidate coverage and row identity without fitting models.

Fable and Astra should review the same implementation and requirements independently, followed by one reconciliation. Record the references and adaptations in the protocol and changelog before fitting.

### What Chris must decide

1. **Approve the additional all-candidate control fits:** 132 beyond the current budget, before retries.
2. **Accept the limited conclusion:** retain the tail winner as the best-supported choice under this combined transfer test; do not claim geography has been removed from its score.
3. **Approve the exact reporting amendment**, including equal-month control aggregation, distance bands and no reselection.

If a score that isolates same-place cover extrapolation is essential, this amendment cannot supply it. That would require additional independent information or stronger modelling assumptions, followed by a separate design.

### References and evidence checked

- **Roberts, D. R., et al. (2017).** Cross-validation strategies for data with temporal, spatial, hierarchical, or phylogenetic structure. *Ecography*, **40**, 913–929. DOI: [10.1111/ecog.02881](https://doi.org/10.1111/ecog.02881). Supporting passages: “Disentangling blocking and extrapolation” and Box 4.
- **Milà, C., Mateu, J., Pebesma, E., & Meyer, H. (2022).** Nearest neighbour distance matching Leave-One-Out Cross-Validation for map validation. *Methods in Ecology and Evolution*, **13**, 1304–1316. DOI: [10.1111/2041-210X.13851](https://doi.org/10.1111/2041-210X.13851). Supporting passage: §4, including matching limitations.
- **Linnenbrink, J., Milà, C., Ludwig, M., & Meyer, H. (2024).** kNNDM CV: k-fold nearest-neighbour distance matching cross-validation for map accuracy estimation. *Geoscientific Model Development*, **17**, 5897–5912. DOI: [10.5194/gmd-17-5897-2024](https://doi.org/10.5194/gmd-17-5897-2024). Supporting passages: §§2 and 4.
- **Brenning, A. (2023; online 2022).** Spatial machine-learning model diagnostics: a model-agnostic distance-based approach. *International Journal of Geographical Information Science*, **37**, 584–606. DOI: [10.1080/13658816.2022.2131789](https://doi.org/10.1080/13658816.2022.2131789). Publisher identity checked; detailed methods read in the author preprint, §§2.1–2.2 and 3.3.
- **Yates, L. A., Aandahl, Z., Richards, S. A., & Brook, B. W. (2023).** Cross validation for model selection: A review with examples from ecology. *Ecological Monographs*, **93**, e1557. DOI: [10.1002/ecm.1557](https://doi.org/10.1002/ecm.1557). Supporting passage: calibrated selection rules, equations 7–8 and all-candidate reporting.

*Read-only design: no files changed and no models fitted. Publication identities and supporting passages were checked manually. The installed RefChecker could not reach Crossref from the shell, so the combined automated reference audit remains unpassed and should be completed before implementation. Decisions remain here rather than being written into the living question files.*