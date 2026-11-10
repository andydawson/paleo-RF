**Verdict: ready after the changes below.** I found no numerical error in the supplied trial. Independent reconstruction from the saved inputs confirms the albedo means, forcing components, northeast endpoint changes, support distances and geographic counts. The remaining issues concern enforcing common denominators, explaining the tested limits, and making the verification claims accurate.

No files changed or commits were made. R was not started; I read the supplied test log and checked the saved products independently with Python.

1. **The validation limits cannot be interpreted safely without their direction meanings.**  
   [R/hindcast_comparison.R:139](/home/expert/Documents/contracting/Andria/paleo-RF-wt/compare-tool/R/hindcast_comparison.R:139) exports unexplained direction codes, while [tools/compare_cv_hindcasts.R:404](/home/expert/Documents/contracting/Andria/paleo-RF-wt/compare-tool/tools/compare_cv_hindcasts.R:404) tells readers to compare those limits with the hindcast distances.

   This matters in the actual results: the northeast reaches **0.10723** outside the hull. Nearby testing in the **less-open-land direction** reaches only **0.09940**. Another direction reaches **0.12634**, from just **three cells in two blocks**. The larger number could wrongly reassure a reader about the northeast.

   **Change and check:** identify the directions in plain words using the existing frozen direction information, and state that the deep northeast departure lacks nearby testing in its direction. Point readers to the existing monthly limits; the pooled maximum must not imply testing in every month. Check that these distinctions are understandable from the comparison output alone. No new support classes or estimator is needed.

2. **Common contributing cells are not enforced when values are missing.**  
   [R/hindcast_comparison.R:26](/home/expert/Documents/contracting/Andria/paleo-RF-wt/compare-tool/R/hindcast_comparison.R:26) removes missing values separately within each run. The input checks at [tools/compare_cv_hindcasts.R:147](/home/expert/Documents/contracting/Andria/paleo-RF-wt/compare-tool/tools/compare_cv_hindcasts.R:147) establish matching keys and cover, but not matching availability.

   A hand-worked counterexample shows the consequence. Two equal-area cells contain baseline albedos **0.1, 0.3**, and comparison albedos **0.1, missing**. The tool can report means of **0.2 and 0.1**, implying a change of **−0.1**, although the change on their common cell is zero. The later grouped-row checks accept this.

   **Change and check:** stop on nonfinite simulated albedo on rows used, and require matching forcing availability across runs for corresponding columns. A two-cell test with mismatched missingness should stop. This needs a small check, not a new missing-data framework. **The current three runs are unaffected:** their simulated predictions are finite and their comparison denominators agree.

3. **The swap table loses the separate endpoint distances requested by the protocol.**  
   [R/hindcast_comparison.R:111](/home/expert/Documents/contracting/Andria/paleo-RF-wt/compare-tool/R/hindcast_comparison.R:111) collapses both swap endpoints into one maximum. Section 7 explicitly requests endpoint hull distances. The figure supplies separate endpoint outside shares only for the modern-open-land curves; it does not recover the missing distances for both table columns.

   **Change and check:** retain the existing either-end outside share, maximum and band, but also report the maximum distance at the low-evergreen and high-evergreen endpoints for each swap. These distances already exist in `exchange_support()`. Check a case with one endpoint inside and the other outside, including endpoint reversal.

4. **The verification claims exceed the checks, and one numerical threshold lacks a basis.**  
   At [tools/compare_cv_hindcasts.R:347](/home/expert/Documents/contracting/Andria/paleo-RF-wt/compare-tool/tools/compare_cv_hindcasts.R:347), the saved-fit comparison checks only **northeast 6 ka** predictions. It does not check the **4.5 ka endpoint** used in the actual-change column. The spec’s broader description at [line 16](/home/expert/Documents/contracting/Andria/paleo-RF-wt/compare-tool/docs/cc/verification/2026-11-10_cv-hindcast-comparison.R:16) therefore overstates coverage.

   Likewise, the check at [tool line 269](/home/expert/Documents/contracting/Andria/paleo-RF-wt/compare-tool/tools/compare_cv_hindcasts.R:269) correctly reproduces selected script-9 domain means and script-10 monthly means after combining latitude bands. It does **not** reproduce “every number” those scripts saved: individual latitude bands, global equivalents, areas and other variants are outside that check.

   Finally, [spec line 39](/home/expert/Documents/contracting/Andria/paleo-RF-wt/compare-tool/docs/cc/verification/2026-11-10_cv-hindcast-comparison.R:39) requires fitted and simulated changes to agree within **0.005 albedo**. That is an undocumented tolerance, not an algebraic invariant or published acceptance threshold.

   **Change and check:** check both northeast endpoints against the fits; describe the saved-script check precisely; report the fitted–simulated gap descriptively while verifying each column against its own saved product. Add common-denominator assertions and include forcing outside-part differences in the existing reversal check. The current largest fitted–simulated gap is **0.001195**, with no sign disagreements.

5. **The forcing header should explicitly distinguish common support across models from support across kernels.**  
   [tools/compare_cv_hindcasts.R:419](/home/expert/Documents/contracting/Andria/paleo-RF-wt/compare-tool/tools/compare_cv_hindcasts.R:419) explains averaging over available months, but does not identify the practical kernel difference.

   In January and December, CACK uses **2,646 and 2,439 study-area cells**, respectively; the other kernels use **2,655**. Comparisons between calibration models use matching support. Comparisons between kernels do not always do so.

   **Change and check:** disclose this in the header, preserving the inherited pipeline calculation. Check the stated counts against the displayed monthly rows. A common intersection across kernels would change the method and should not be introduced silently.

The independent numerical checks were substantial:

| Check | Result |
|---|---:|
| All 1,950 albedo means reconstructed from simulated predictions and ice fractions | Largest difference **9.44 × 10⁻¹⁵** |
| All 5,616 forcing component values reconstructed from script-8 products | Largest difference **1.36 × 10⁻¹³ W/m²** |
| Vegetation + ice − total, all 1,872 forcing rows | Largest difference **8.53 × 10⁻¹⁴ W/m²** |
| Outside vegetation + outside ice − outside total | Largest difference **4.45 × 10⁻¹⁴ W/m²** |
| Northeast three-step sums versus endpoints, 996 cell-months per run | Largest difference **1.39 × 10⁻¹⁷** |
| Northeast support shares and distances reconstructed independently | Agreement within **3.34 × 10⁻¹⁶** |
| All 24 geographic-support rows | Counts and latitude limits exact |
| Baseline differences and all reversed difference columns | Exactly zero residual |
| Kernel arrays across the three runs | Exactly identical |

The weighting and signs are correct. Albedo means use area multiplied by ice-free fraction; saved forcing receives **no second ice weighting**. Annual forcing correctly averages each cell over its available months before area weighting. Outside contributions use the whole mean’s denominator. Period flags include every endpoint, including intermediate slices.

The northeast has **83 cells**, both swaps retain all 83, and the hemlock interval contains no ice there. The annual HadGEM3 northeast totals are **+3.477, −0.833 and −2.596 W/m²** for model 8, the chosen model and the coarse-location model. These are regional means over months. Positive albedo change means brighter; positive forcing means warming.

The two helper moves preserve existing behaviour. `slice_area_ice()` contains the previous extraction unchanged; its additional sorting is harmless. `cells_with_evergreen()` replaces a captured variable with an explicit argument, and both existing northeast callers pass that same variable. I found no need to redesign either helper. The supplied log confirms four test files succeeded; the formal spec additionally runs the cross-validation-stage tests. The trial’s implementation code is identical to the reviewed implementation despite its earlier recorded commit.

Most of section 7 is fulfilled: three runs with baseline first, twelve-month northeast tables, both modern-range swaps, all kernels and three components, monthly geographic support, and exactly the four requested figure types. The simulated and fitted quantities are distinguished in the headers. The 11.5 ka endpoint is disclosed, and no scientific acceptance verdict against published contrasts appears.

Fable’s additional choices should remain explicit:

- The study domain is the **forcing-table footprint**.
- Albedo tables describe the mean over **ice-free land**; albedo maps show the vegetation contribution per **whole cell**, multiplying differences by ice-free fraction. These are related but different quantities.
- The hemlock interval is also reported for the whole study area.
- The historical-size forest exchange and its uncertainty are added for all twelve months.
- Maps use the first configured kernel and clip colours at the 98th percentile.

These are reporting choices, not numerical defects. The saved forcing-map subtitle does cut off its clipping notice; wrap it at [tool line 464](/home/expert/Documents/contracting/Andria/paleo-RF-wt/compare-tool/tools/compare_cv_hindcasts.R:464) and inspect the resulting PNG.

On simplicity, **a rewrite is not justified**. The 539-line tool contains 387 code-containing lines; the 149-line helper file contains 78. Concrete cuts are:

- **12 lines:** remove the optional console tables at tool lines 527–538; they repeat the CSVs.
- **24 further lines, optionally:** remove the arithmetic preamble at lines 46–69, whose information is repeated in output headers and helper documentation.
- Removing the historical exchange saves only about **three executable lines**. It already shares the existing contrast helper.

There is genuine duplication between `period_cell_months()`, `R/forcing_breakdown.R` and script 9. A shared period-sum routine could remove approximately **five repeated arithmetic lines net**. However, changing those pipeline callers conflicts with this task’s instruction to leave the pipeline unchanged. Record that as a separate, verified refactor rather than expanding this review.

I discarded three proposed defensive findings—duplicate-key hardening, empty-swap handling and support beyond five runs—because none demonstrated a problem in the required comparison and their fixes would add unused machinery.

The literature supports the broad comparisons, with narrower support than the exact project settings:

| Method | Checked precedent and supporting passage |
|---|---|
| Vegetation-replacement contrasts and covariance-aware uncertainty | **Duveiller, G., Hooker, J. & Cescatti, A. (2018), “A dataset mapping the potential biophysical effects of vegetation cover change,” Scientific Data 5, 180014.** Methods, “Retrieving the local biophysical signal,” equations 11–13: destination prediction minus origin prediction, with covariance retained because both predictions share a regression. DOI: [10.1038/sdata.2018.14](https://pmc.ncbi.nlm.nih.gov/articles/PMC5819485/). |
| Comparing levels alongside contrasts and forcing | **Bright, R. M., et al. (2015), “Radiative forcing bias of simulated surface albedo modifications linked to forest cover changes at northern latitudes,” Biogeosciences 12, 2195–2205.** Section 3, page 2200 explains how biases in two cover-state albedos can cancel in their difference and forcing. DOI: [10.5194/bg-12-2195-2015](https://bg.copernicus.org/articles/12/2195/2015/bg-12-2195-2015.pdf). |
| Northeast scientific context | **Dawson, A., et al. (2025), “Holocene land cover change in North America: continental trends, regional drivers, and implications for vegetation–atmosphere feedbacks,” Climate of the Past 21, 2031–2060.** Section 4.2.3 discusses hemlock decline, evergreen losses and possible seasonal albedo consequences; it does not establish observed historical albedo or a required sign. DOI: [10.5194/cp-21-2031-2025](https://cp.copernicus.org/articles/21/2031/2025/). |
| Reporting error along environmental gradients | **Telford, R. J. & Birks, H. J. B. (2011), “Effect of uneven sampling along an environmental gradient on transfer-function performance,” Journal of Paleolimnology 46, 99–106.** Discussion and Figure 6 show why pooled errors can conceal poor performance in sparsely sampled gradient segments. This is adjacent palaeoenvironmental precedent. DOI: [10.1007/s10933-011-9523-z](https://link.springer.com/article/10.1007/s10933-011-9523-z). |

The exact modern evergreen endpoints, fixed open-land slices, GAM contrast calculation, hull geometry and bands, period union flag, regional denominators, geographic counts and figure settings remain **project choices or adaptations**. These publications do not establish their exact settings as reliability thresholds. Primary identities and passages were checked directly; dedicated reference-checker tools were unavailable.

“Modern range” must continue to mean the marginal evergreen range: the modern-open-land swap extrapolates on **89.79%** of northeast area, and the 6 ka-open-land swap on **100%**. Neither is an in-range validation.

**Final verdict: ready after named changes.** Before formal verification, I recommend these small decisions, in order:

1. Explain the validation directions and the northeast’s untested deep departure.
2. Enforce common value availability, with the two-cell missingness test.
3. Preserve the separate swap-endpoint distances.
4. Check both historical prediction endpoints and narrow the verification claims.
5. Replace the unexplained 0.005 gate with descriptive reporting.
6. State the kernel coverage difference and wrap the clipped figure subtitle.
7. Fill the verification commit and run the existing spec, strengthened as above, in its own worktree.

Two questions for Chris:

- **Keep the extra whole-study-area 6–4.5 ka results and twelve-month historical-size forest exchange?** I recommend yes; they reuse existing calculations.
- **Keep albedo tables as means over ice-free land, while maps show the vegetation contribution per whole cell?** I recommend yes, with those quantities named explicitly.