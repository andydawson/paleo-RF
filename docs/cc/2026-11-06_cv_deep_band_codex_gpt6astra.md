- **Recommend a nearby selection score with a separate deep-cover assessment.** Run 1 cannot support a reliable combined test of deep northeast cover at nearby locations.
- Benefit: the paper can distinguish measured predictive skill from the extrapolation its central interpretation still requires.
- The 36 deepest predictions within 250 km occupy two blocks—and **none belongs to the northeast-relevant departure direction, d2**.
- Extending to 500 km adds deep examples, but changes the geographic task.
- Equal-band weighting has palaeo-calibration precedent; it cannot supply missing observations.
- Keep both 0.05–0.10 and ≥0.10 visible: the northeast’s historical median, 0.085, lies in the former.

From run 1’s [saved prediction summaries](/home/expert/Documents/contracting/Andria/paleo-RF-verify/f07ff68/.rundirs/cv-run1/output/cross_validation/by_distance.csv), entries below are **cell-month-holdouts / geographic blocks**:

| Cover distance | <100 km | 100–<250 km | 250–<500 km | ≥500 km |
|---|---:|---:|---:|---:|
| 0–<0.02 | 2,184 / 69 | 2,024 / 58 | 500 / 18 | 27 / 3 |
| 0.02–<0.05 | 548 / 20 | 3,185 / 68 | 2,032 / 43 | 573 / 13 |
| 0.05–<0.10 | 24 / 2 | 1,438 / 33 | 3,153 / 43 | 1,227 / 24 |
| ≥0.10 | 0 / 0 | 36 / 2 | 540 / 17 | 1,330 / 15 |

These include directions with zero historical target weight. Blocks overlap between columns and cannot be added. Below 500 km, the deepest band contains **576 predictions, but only 444 have positive target weight; 132 belong to d2**. Its combined block count is between 17 and 19, before excluding zero-weight observations.

The d2 counts follow uniquely from reconstructing the saved row-weight totals using [groups.csv](/home/expert/Documents/contracting/Andria/paleo-RF-verify/f07ff68/.rundirs/cv-run1/output/cross_validation/groups.csv). Direction d2 is the [northeast’s historical departure direction](/home/expert/Documents/contracting/Andria/paleo-RF-wt/comparison/docs/cc/2026-11-03_cv_northeast_question_codex_gpt6astra.md:21), not necessarily the geographic location of those validation cells.

| Option | What run 1 supplies | Assessment |
|---|---|---|
| **Historical weights, <250 km** | Band counts: **4,208 / 3,733 / 1,462 / 36**. Full historical band shares are **58.36 / 26.17 / 11.97 / 3.50%**, before excluding unrepresented groups. | Closest existing comparison to the intended geography. Deep d2 remains untested; report its missing weight. |
| **Equal bands, <250 km** | Same observations; **25% per band**. The deepest quarter rests on two blocks, entirely d1. | Makes deep errors influential, but substitutes sparse evidence from another direction. Unsuitable as a convincing northeast selection test. |
| **Historical or equal bands, <500 km** | Counts: **4,708 / 5,765 / 4,615 / 576**. Adds 132 deep d2 predictions. | A possible **geographic-transfer compromise**, requiring Chris’s explicit acceptance. It does not reproduce known-place prediction. |
| **Distance matching within bands** | Existing deepest observations below 250 km occur only at 100–250 km: at most 36 predictions, no d2. | Matching cannot create missing nearby cases. Matching positive distances across bands also does not match the northeast hindcast’s zero distance. |
| **Smaller, scattered edge holdouts** | Existing predictions cannot score changed training sets. | Restoring training cells expands the hull, so withheld cover depths can only stay unchanged or shrink. Check actual fold hulls before fitting; remaining deep support is unknown. |
| **Nearby score plus separate deep assessment** | Uses the existing predictions and distance strata above. | **Recommended.** Preserves the distinction between nearby skill, distant deep-cover skill and unsupported combinations. |

Truncating **run 1’s existing row weights** gives band shares of **71.89 / 23.39 / 4.66 / 0.068%** below 250 km, and **61.35 / 25.62 / 10.98 / 2.05%** below 500 km. These are **not** protocol 2’s weights after recomputing within-group means. The corresponding shallow shares are 95.28% nearby and 84.53% over all distances; I could not reproduce the brief’s 96%/88% from these saved tables.

For a numerical illustration, averaging the four **pooled band MSEs equally**, then taking the square root, gives:

| Model | <250 km RMSE | <500 km RMSE |
|---|---:|---:|
| Model 8 | 0.0776 | 0.0985 |
| Coarse location | 0.0819 | 0.0950 |
| Linear cover | 0.0793 | 0.0959 |

These diagnostic calculations include zero-target observations and unequal month/direction representation. They demonstrate sensitivity to the cutoff, **not a protocol-2 winner**. Exact target-aware rescoring and paired uncertainty require the row-level RDS predictions, which were not deserialized under the permitted shell commands.

**Recommendation and code effect.** Retain the nearby historical-weighted selection score, accompanied by errors for each cover band and departure direction across geographic distances. State explicitly: **“Deep northeast-direction performance near training is untested.”** Missing groups receive neither zero error nor another direction’s error.

Relative to draft v2, this needs reporting changes: add departure direction, positive-target prediction/block counts and missing historical weight to the distance tables. Reuse the existing scorer and block resampling; this amendment requires no additional fits.

**Chris must decide** whether that limited selection claim is sufficient. If deep northeast performance must influence selection, the current nearby folds cannot establish it. The next step should be a geometry-only check of scattered holdouts; adopting 500 km instead would be a deliberate change in the prediction task. Neither cutoff has a published domain justification.

Primary-source identities and the following supporting passages were checked:

- **Telford & Birks (2011), “Effect of uneven sampling along an environmental gradient on transfer-function performance.”** *Journal of Paleolimnology* 46, 99–106. Discussion, Fig. 6 and Table 1 combine ten segment RMSEPs by their root mean square. This supports equal segment MSE weighting; our unequal hull bands remain an adaptation. DOI: [10.1007/s10933-011-9523-z](https://doi.org/10.1007/s10933-011-9523-z).
- **Telford & Birks (2009), “Evaluation of transfer functions in spatially structured environments.”** *Quaternary Science Reviews* 28, 1309–1316. The environmental-extremes discussion, p. 1315, distinguishes extrapolation testing from spatial independence. DOI: [10.1016/j.quascirev.2008.12.020](https://doi.org/10.1016/j.quascirev.2008.12.020).
- **Milà et al. (2022), “Nearest neighbour distance matching Leave-One-Out Cross-Validation for map validation.”** *Methods in Ecology and Evolution* 13, 1304–1316. §§2.1 and 4 support matching deployment distances and explicitly qualify substantial covariate shifts. DOI: [10.1111/2041-210X.13851](https://doi.org/10.1111/2041-210X.13851).
- **Linnenbrink et al. (2024), “kNNDM CV: k-fold nearest-neighbour distance matching cross-validation for map accuracy estimation.”** *Geoscientific Model Development* 17, 5897–5912. §§2 and 4 describe fold-based matching and its support limitations. DOI: [10.5194/gmd-17-5897-2024](https://doi.org/10.5194/gmd-17-5897-2024).
- **Hu et al. (2018), “From Remotely-Sensed Data of Norwegian Boreal Forests to Fast and Flexible Models for Estimating Surface Albedo.”** *JAMES* 10, 2495–2513. §3.4 separates reciprocal geographic transfer from within-area performance. DOI: [10.1029/2018MS001403](https://doi.org/10.1029/2018MS001403).
- **Duveiller, Hooker & Cescatti (2018), “The mark of vegetation change on Earth’s surface energy balance.”** *Nature Communications* 9, 679. Methods use local cover contrasts under comparable climate and exclude inadequate co-occurrence. This supports geographic comparability, not our thresholds. DOI: [10.1038/s41467-017-02810-8](https://doi.org/10.1038/s41467-017-02810-8).

*Read-only: no files changed. Automated reference checkers were not run.*