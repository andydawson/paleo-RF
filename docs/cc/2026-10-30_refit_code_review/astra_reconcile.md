Read-only reconciliation; no tests or pipeline runs.

For Fable’s findings:

1. **Agree on the defect; partly on the fix.** Model-frame/formula checks are necessary, but also preserve the saved family/link and controls except `maxit`; the tool currently substitutes registry controls.
2. **Partly.** Check every month before expensive fitting. Use complete model rows and actual basis requirements; a hard-coded “about 750” response-count threshold does not establish feasibility.
3. **Partly.** Document retrieval support, but `_coverage` and `_days` describe all qualifying retrievals, not snow-conditional support. Reporting these requires no new filtering or weighting.
4. **Partly.** Both anchor comparisons are affected. Rescaling is mathematically defensible as an approximation; rounding below 0.02 does not establish that the corrected statistic’s stochastic variation fits that tolerance.
5. **Agree.** Update questions/changelog and correct the attributions: implementation choices should not be presented as explicit decisions by Chris.
6. **Disagree.** `cor()` is the final expression of the top-level `if` at script 2:258; the block retains its visibility, so autoprint is preserved. See R’s [brace](https://stat.ethz.ch/R-manual/R-devel/library/base/html/Paren.html) and [if](https://stat.ethz.ch/R-manual/R-devel/library/base/html/Control.html) return rules.
7. **Agree, nit.** The reader depends on `MONTHS`; source its calendar dependency explicitly. Current callers already supply it.
8. **Agree, cosmetic.** Explain the 58 unmatched centres as 48 ice exclusions plus 10 southern centres in the record.
9. **Agree, nits.** The literal-length assertion adds little; wrap the comment. `pipeline_paths()` creates directories, so “writes nothing” is inaccurate.
10. **Agree as integration housekeeping.** I confirmed both main-checkout copies are untracked and byte-identical to this branch; reconcile them before integration.

For its verification list, in order:

1. **Agree:** three preparation anchors plus the frozen coarse-table checksum.
2. **Partly:** expect 25 MATCH/one DIFFER and unchanged other statistics. Comparing two rounded coverage columns requires **±0.005 × (r + 1)**, not ±0.005 × r, where `r = N/N_observed`.
3. **Agree:** verify the written MODIS table independently, including the stated counts; also check its 18 columns, predictor order and flooring.
4. **Partly:** fitted rows equal observed-response counts only when predictors are complete; otherwise check complete model-frame rows.
5. **Agree:** after fixing finding 1, check the converged control and explicitly inspect convergence; successful command completion is insufficient.
6. **Agree:** confirm the checksum from the actual October 18 manifest. This supplements Chris’s approved full raster refit.
7. **Agree:** repeat MODIS scripts 5–6 with identical inputs, seed and thread environment; this establishes reproducibility, not paired draws across scenarios.

My findings **1, 3 and 4 stand**. Fable adds useful support-reporting and housekeeping checks. I close the reference-audit question after reading the merged summary, and narrow finding **2** as follows.

**(a) Unseeded anchor:** preserve the historical CSV and **retire only its coverage-column comparison**, through a recorded contract change before candidate results. Keep the other unseeded checks; cover the corrected statistic with the regenerated seed-1 reference and direct denominator tests. Fable’s rescaling is useful supporting arithmetic, but cannot recover the original numerator exactly or validate the new stochastic tolerance.

**(b) Four-month reporting:** **monthly reporting is sufficient for this refit; no aggregation-code change is required.** Compare November–February `global_equiv_month` values against the same months of the main run, explicitly labelled. Do not report the four-month aggregate or `contribution_to_annual` as annual. I withdraw finding 2 as a prerequisite code fix; correcting labels remains necessary if those aggregate products are distributed or quoted.