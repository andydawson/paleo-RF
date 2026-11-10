**Verdict: keep the protocol’s chosen model as its predictive selection, but revise Fable’s review before relying on its scientific conclusions.** The Alaska influence result, the principal scores and the nine requested monthly contrasts reproduce. The claims that snow explains the chosen model’s winter behaviour, that published contrasts establish its correctness, and that forcing is stable throughout the period before 6 ka go too far.

I changed no files and made no commits or new model fits. R could not start because the read-only environment prevented creation of its temporary directory. I independently read and calculated from the saved objects in memory using Python, without running Fable’s scripts. Consequently, the requested new snow-state refits remain unchecked. I also did not independently recalculate all contrast standard errors.

**1. Alaska — confirmed with a change.**

The calculation behind [review line 68](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/docs/cc/2026-11-10_cv_protocol_v2_results_review_fable.md:68) is correct, with an important qualification about what the percentage measures.

- There are **9,070 scored rows in 94 blocks**.
- The four blocks contain **50 cells and 546 rows**.
- They contribute **61.0016% of the weighted mean-squared-error advantage** over model 8. The ten largest contributors give **88.7177%**.
- Model 8 performs better in **47 of the 94 blocks**.

The 61% is an additive share of the **squared-error difference**, not the RMSE margin. Removing those blocks and recalculating group means reduces the squared-error difference by about 59%, because the remaining observations receive different weights.

My independent calculation after removing them gives:

| Model | RMSE | Excess squared error, in paired standard errors |
|---|---:|---:|
| Chosen | 0.048174 | — |
| Same location size, 50-basis cover | 0.049193 | 0.82 |
| Flexible-location, straight-line rival | 0.048261 | **0.038** |
| Flexible location, 50-basis cover | 0.048604 | 0.21 |
| Model 8 | 0.055730 | 2.92 |

These standard errors came from 2,000 independently implemented block resamples. **The protocol still chooses the chosen model:** four candidates fall within one paired standard error, and it has the fewest coefficients.

There are three corrections to the interpretation:

- **The January example is mislabeled.** [The checking script, line 9](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/docs/cc/2026-11-10_cv_protocol_v2_results_review_checks/alaska_check.R:9) selects the first model, which has no location term, then [line 30](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/docs/cc/2026-11-10_cv_protocol_v2_results_review_checks/alaska_check.R:30) labels its predictions “winner.” The actual January means are **0.372 observed, 0.352 chosen, 0.838 model 8**. The reported 0.29 belongs to the no-location model. This does not affect the block-share calculation.
- **Removing the blocks is fair as a post-hoc influence check.** It is not a replacement validation score or proof of equivalence: the blocks were selected because of their contribution to the observed advantage. No application-field precedent for this particular four-block deletion was established here.
- **A boundary effect is plausible, not demonstrated as the whole explanation.** Independently checking the actual training-coordinate hulls places **327 of the 546 rows outside geographic support and 219 inside**. All four January observations are outside. But both cover and geographical support change, so total predictions alone cannot assign the failure specifically to the location term.

**Proposed check:** correct the model label, retain the original selection, and describe the deletion as an influence sensitivity. Inspect fitted term contributions only if a mechanistic explanation of the Alaska failure is needed.

**2. Target coverage, in-range performance and forcing — confirmed with a change.**

I independently reconstructed the monthly cover hulls and combined historical cover, cell areas and ice fractions.

- Outside-hull target weight is **12.8158%**, confirming the headline number.
- Represented groups account for **12.5524% of the complete historical weight**, or **97.9445% of that outside-hull target**.
- Using the actual monthly hulls and ice weighting, slice shares range from **3.73% to 19.43%**. Fable’s 4–17% was explicitly an approximation.
- Northeast shares from 0.5–8.5 ka are **80.945–100%**.
- Independently calculated in-range RMSEs are **0.0455395 chosen versus 0.0455734 model 8**.

Thus the numerical tie is confirmed. But [review line 98](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/docs/cc/2026-11-10_cv_protocol_v2_results_review_fable.md:98) should describe **a share of the historical weighting target**, not a percentage of forcing validated. The in-range diagnostic still predicts withheld modern cells; it does not observe historical cover changes at fixed places.

**The three pipeline runs are sufficiently matched.** I checked matching checksums across 15 shared input products, matching scientific settings apart from model choice, matching simulation seeds and draw counts, and matching relevant software and downstream scripts. The older runs’ stale-input overrides are confined to script 5; the subsequent stages record checked inputs.

**The forcing table is transcribed correctly. Its interpretation is not.**

- At nominal **10–12 ka**, the totals are **2.874 chosen, 4.125 model 8 and 3.651 W/m² coarse**. The chosen value is about **30% below model 8**. “Stable before 6 ka” is therefore not confirmed. The oldest actual endpoint is 11.5 ka, despite the period label.
- The displayed forcing **includes ice**. Even the close totals at 6–10 ka conceal disagreement in the vegetation component:

| Vegetation component, HadGEM3, W/m² | Chosen | Model 8 | Coarse |
|---|---:|---:|---:|
| 6–8 ka | +0.075 | −0.068 | +0.268 |
| 8–10 ka | −0.046 | −0.221 | +0.303 |
| 10–11.5 ka | −0.030 | +1.138 | +0.906 |

These are already saved outputs; their component definitions are documented in [script 9, line 43](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/scripts/9_forcing_barplot.R:43). Agreement in ice-dominated totals cannot establish a stable vegetation response.

**Proposed check:** display the existing vegetation and ice components beside the total, and restrict the stability statement to the quantity and periods actually supported.

**3. Twelve-month contrasts and published values — confirmed with a change.**

All nine requested **point contrasts** reproduce independently:

| Historical-size forest exchange; positive means brighter | Chosen | Coarse | Model 8 |
|---|---:|---:|---:|
| April | −0.002036 | +0.052003 | −0.041151 |
| July | +0.012695 | +0.016069 | −0.006802 |
| December | −0.038651 | +0.009267 | +0.049474 |

These use 83 cells, actual area weights, evergreen declining from **0.39935 to 0.21974**, and open land held at 6 ka. For the nonlinear models I reconstructed the cover response from the saved basis and coefficients; an independent check against existing historical point predictions agreed within **4.5 × 10⁻¹³**. All exchanges have at least one endpoint outside the modern cover hull.

**The quoted published values are correct.** Primary passages were re-read:

- **Hollinger et al. (2010), “Albedo estimates for land surface models and support for a new paradigm based on foliage nitrogen concentration,” DOI 10.1111/j.1365-2486.2009.02028.x.** Table 2, p.701, gives broadleaf-minus-evergreen differences of **0.034–0.061 in spring, 0.047–0.073 in summer and 0.039–0.057 in autumn**. These bounds come from two geographical evergreen groups; they are not monthly confidence limits. Methods p.698 and discussion pp.701–702 describe tower measurements and seasonal variation. The paper also reports winter exceptions and separate larch behaviour. [Primary text](https://research.fs.usda.gov/treesearch/download/34733.pdf)
- **Jin et al. (2002), “How does snow impact the albedo of vegetated land surfaces as analyzed with MODIS data?”, DOI 10.1029/2001GL014132.** Section 3, Table 1, confirms **0.122 − 0.105 = 0.017 snow-free** and **0.294 − 0.213 = 0.081 snowy**, at 40–50°N during November–January. These are **black-sky albedos at local solar noon**, rather than this project’s blue-sky values. [Primary text](https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2001GL014132)

The comparison is useful for identifying substantial discrepancies, but [review lines 153 onward](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/docs/cc/2026-11-10_cv_protocol_v2_results_review_fable.md:153) should not turn it into a universal physical sign rule. Tower stands and satellite class means differ from one-degree fractional-cover regressions. Summergreen includes larch and shrubs; evergreen also includes shrubs. Those mappings remain an explicit [question for Andria](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/docs/cc/questions_for_andria_scientific_from_2026-10-20.md:300).

There is also a quantity mismatch. [The snow-check script, line 23](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/docs/cc/2026-11-10_cv_protocol_v2_results_review_checks/winner_by_snow_state.R:23) calculates

\[
\bar a(1-\bar a)(\beta_{\rm summergreen}-\beta_{\rm evergreen}).
\]

That is a **local slope evaluated at the observed northeast mean albedo**, not a full-swap prediction. It remains a continental coefficient. Multiplying it by 0.18 gives an approximation, not the exact historical exchange. Similarly, scaling model 8’s nonlinear historical contrast to “per full swap” does not calculate a full replacement.

**Proposed check:** use exact endpoint differences on common cells for all models and states. Keep published values alongside them as explicitly qualified seasonal analogues.

**4. “Snow explains the chosen model’s wrong winter sign, not model 8’s” — not confirmed as an explanation.**

The descriptive pattern warrants investigation. It does not yet isolate snow as its cause.

I could not reproduce the unsaved chosen/rival fits because R could not start. I did independently reproduce three contrasts from **model 8’s saved snow-free fits**, for 0.10 more evergreen replacing summergreen:

| Month | Albedo change | Cells |
|---|---:|---:|
| April | +0.013391 | 83 |
| July | +0.010803 | 83 |
| December | −0.002038 | 79 |

Thus its spring/summer brightening response persists on the snow-free product. That is narrower than proving why either model behaves as it does.

The following confounding changes matter for [section 2.5](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/docs/cc/2026-11-10_cv_protocol_v2_results_review_fable.md:180):

- **Different fitting populations.** January changes from 1,726 all-days cells to 1,227 snow-free cells; northeast cells fall from 83 to 68. April changes from 2,808 to 2,039 continental cells.
- **The “75” rule is 75 degrees, not 75% coverage.** It is the solar-zenith cutoff and removes northern winter observations. There is no 75% minimum snow-free share. See [the build, line 36](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/tools/prepare_bluesky_albedo.R:36).
- **Some snow-free means have very little support.** Independently matching the source table shows that **21 of January’s 68 northeast snow-free values use less than 1% of usable retrievals**. The fit does not weight them by that support.
- **Snow-free describes classified retrievals.** It does not guarantee bare ground beneath a canopy. The build partitions qualifying pixel-days by their snow flag, with unequal pixel representation possible. Jin’s discussion of canopy masking supports this qualification.
- **Summer supplies a useful control.** Northeast all-days and snow-free albedos are exactly identical in June–September. Across the continent they still differ in **448 July cells and 351 August cells**. Different northeast slopes can therefore arise through the common continental response changing elsewhere.
- **Eleven positive point estimates are not eleven established positive effects.** Counting signs also does not demonstrate that the two location sizes are statistically separated.

**Proposed check:** first reproduce a few snow fits, then compare identical fitting rows and exact exchanges. This common-row comparison is a diagnostic control proposed here, not an established validation method for these pollen-derived calibrations. Resolve retrieval support before inventing a cutoff or expanding the experiment.

**5. Made-up-truth test — confirmed with a change.**

Independent regrouping of the saved replicate results confirms:

- Chosen and model 8 each pass **12 of 12** required checks.
- Their non-null cases recover the sign in **20 of 20** replicates.
- Maximum absolute bias is **0.001717**, against its applicable limit of **0.008686**.

But [review line 225](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/docs/cc/2026-11-10_cv_protocol_v2_results_review_fable.md:225) understates the test. The third truth adds shorter-scale sinusoidal spatial variation; not every location surface is an unpenalized latitude plane. The omitted no-location control passes only **5 of 12** checks and invents appreciable effects under the null.

“Scatter” also needs correction: empirical standard deviations are approximately **0.000151–0.001460**; the larger **0.002230** figure is RMSE about the truth, including bias. Comparing that directly with real-data standard errors mixes measures.

**Consequence:** recovery is useful evidence under the stipulated truths, beyond merely exercising the contrast code. Independent noise, correctly specified linear cover effects and limited truths still prevent it from establishing separation in the real data.

**Proposed check:** describe all three truths, retain the failed control, and distinguish bias, RMSE and standard deviation.

**6. Sections 3–5 — agree with changes overall.**

For the six corrections in section 3:

| Correction | Assessment |
|---|---|
| Qualify “wins outright” | **Agree with a change:** distinguish the declared selection from evidence of a reliable performance advantage. |
| Coarse location brightens only with some cover forms | **Agree.** |
| Replace “no CV can settle it” | **Agree with a change:** say alternatives score worse under this protocol, rather than being scientifically ruled out. |
| April–May does not describe the whole year | **Agree.** |
| Qualify “best predictor” by the test’s target | **Agree with a change:** use the target-weight interpretation above. |
| Published contrasts decide between location sizes | **Disagree as stated:** they raise concerns and motivate checks; they do not establish the correct size. |

For section 4’s five implications: the first needs the **6–10 ka total-only** qualification; the second is sound if the range is called **model sensitivity, not a confidence interval**; the northeast sign remains unresolved for the paper; a common continental response remains an assumption requiring justification; and separating snow states is a supported route to investigate, not an established solution.

The six recommendations:

| Recommendation | Assessment |
|---|---|
| 1. Independent review | **Agree; this review supplies it, with the refitting limitation stated.** |
| 2. Declare a published-contrast test | **Agree with a change:** make it a diagnostic with matched quantities and uncertainty, not a universal sign gate. |
| 3. Incorporate snow results before model choice | **Agree with a change:** first resolve sample and retrieval-support differences. |
| 4. Build the agreed hindcast comparison | **Agree:** include exact monthly contrasts and vegetation/ice components. |
| 5. Add block contributions | **Agree:** distinguish squared-error influence from the post-hoc deletion result. |
| 6. Publish pre-6 ka forcing unchanged | **Disagree as written:** neither the oldest total nor vegetation forcing supports that blanket statement. |

There is direct application-field precedent for the diagnostic:

- **Burakowski et al. (2016), “Evaluating the Climate Effects of Reforestation in New England Using a Weather Research and Forecasting (WRF) Model Multiphysics Ensemble,” DOI 10.1175/JCLI-D-15-0286.1.** Section 2c(3) and Figure 5 compare modeled albedo with MODIS **by vegetation class and separately by snow state**. Figure 5 uses December–March averages and uncertainty; the discussion addresses heterogeneous pixels. This supports the comparison and its qualifications, not twelve monthly acceptance limits. [Passage and figure](https://harvardforest1.fas.harvard.edu/publications/pdfs/Burakowski_JClimate_2016.pdf)
- **Duveiller, Hooker and Cescatti (2018), “The mark of vegetation change on Earth’s surface energy balance,” DOI 10.1038/s41467-017-02810-8.** Methods, “Retrieving the local biophysical signal,” equations 11–13, calculate vegetation-replacement effects from endpoint predictions and retain their covariance. This supports exact contrasts; its local fractional-cover regression does not validate this continental model. [Primary article](https://www.nature.com/articles/s41467-017-02810-8)
- **Barnes and Roy (2010), DOI 10.1029/2010JG001428**, §3.1 equation 3, and **Ghimire et al. (2014), DOI 10.1002/2014GL061671**, §§2.2–2.3, support combining monthly snow-state albedos with snow fractions. They do not establish that splitting these calibration tables fixes the response. Ghimire’s fixed-modern-snow assumption concerns 1700–2005, not the whole Holocene. [Barnes and Roy](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2010JG001428), [Ghimire et al.](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1002/2014GL061671)

**No field precedent was established for a universal monthly sign gate selecting among these fifteen pollen-calibration models.** Declaring a rule now also does not make these already inspected data an untouched validation set.

To keep it simple, start with saved fits, exact common-cell contrasts, retrieval-support counts and a few reproduced snow fits. Drop the automatic expansion to all fifteen configurations until those checks justify it.

**7. What the review missed, most important first.**

1. **Ice-dominated totals conceal disagreement in vegetation forcing.** Report the existing components before drawing paper-level stability conclusions.
2. **The hindcast does geographically extrapolate in winter.** Contrary to [review line 81](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/docs/cc/2026-11-10_cv_protocol_v2_results_review_fable.md:81), saved predictions include **1,114 January cells north of the northernmost fitting cell**, and **1,441 in December**. The pipeline predicts the full historical table at [script 6, line 34](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/scripts/6_prediction_model.R:34). Report this support gap and assess its forcing relevance with the kernels; extrapolation alone does not establish a large forcing error.
3. **Deep departures in the northeast’s cover direction remain untested nearby.** The missing target groups are precisely that direction’s deep band. The only 36 nearby deep observations belong to another direction. This limitation is explicit in [protocol line 123](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/docs/cc/2026-11-06_cv_protocol_v2.md:123) and should accompany the result.
4. **The original choice was not decided by the simplicity tie-break.** At [review line 96](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/docs/cc/2026-11-10_cv_protocol_v2_results_review_fable.md:96), the next candidate is **1.242 paired standard errors** behind, outside the one-SE set. Only the chosen model qualifies originally; simplicity decides the comparison after Alaska is removed.
5. **“REML is not smoothing it” is too categorical.** [Review line 51](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/docs/cc/2026-11-10_cv_protocol_v2_results_review_fable.md:51) overlooks model 8’s approximately **409–416 location degrees of freedom versus 499 available**. Both penalization and basis capacity matter.

The misleading stability and physical-correctness statements have also reached the [living scientific questions document, line 332](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/docs/cc/questions_for_andria_scientific_from_2026-10-20.md:332). They need the same qualifications when editing is authorized. I left it unchanged.

**Claims Chris can rely on now:** the declared protocol selects the chosen model; the Alaska squared-error influence and near tie after deletion reproduce; the three pipelines are matched; the nine requested point contrasts and published numerical contrasts reproduce; and the synthetic experiment passes for the two principal models under its stipulated truths.

**Claims needing more work first:** the unsaved chosen/rival snow fits; a causal explanation of their sign changes; selection by published contrasts; a northeast historical sign; and any claim of stable vegetation forcing before 6 ka. The contrast standard errors were not all independently recalculated here.

**Questions for Chris or Andria:**

- **Chris:** Should published seasonal forest contrasts be a diagnostic requiring explanation of discrepancies, or a hard model-selection rule? The cited studies support comparison but provide no acceptance limits for this calibration.
- **Andria:** For the northeast hemlock decline, may broadleaf-deciduous versus needleleaf-evergreen observations represent the reconstructed groups—which include shrubs and larch—for sign, magnitude, or neither?
- **Andria:** Is one continental cover response acceptable for interpreting the northeast, given that its summer estimate changes when only albedo elsewhere changes?
- **Chris and Andria:** Should the vegetation-forcing estimate hold modern snow conditions fixed, or represent historical snow changes? That choice determines what the proposed snow-state mixture would estimate.
- **Chris:** Should the paper present vegetation and ice components separately, with model sensitivity for every period where those components disagree, including before 6 ka?