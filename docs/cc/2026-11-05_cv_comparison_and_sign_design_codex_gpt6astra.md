# Design: CV hindcast comparison, northeast signs and literature

## Summary

- Use one comparison tool, built from the existing northeast diagnostic.
- Compare the completed `mod8_coarse_loc` and `mod8` runs without refitting.
- Produce three tables, a series figure, difference maps and the April–May figure.
- Use each month’s own training hull.
- Distinguish being outside that hull from being outside the conditions represented in CV.
- Evaluate the forest swap at each cell’s **modern open-land fraction**.
- Keep deterministic model-sign diagnostics separate from the pipeline’s simulated means.
- Use published forest comparisons as context, with reference and passage checks before publication.
- This is a read-only design: no files, runs or repository records were changed.

## 1. The section 7 comparison

**Benefit to the paper:** show how much the selected model changes the reconstruction, and how much evidence supports the cover conditions behind those changes.

### Inputs and scope

The pipeline specifications identify these intended run folders:

- Chosen: `paleo-RF-verify/e82f399/.rundirs/cv-chosen`
- Comparator: `paleo-RF-verify/f05628d/.rundirs/cv-mod8`

Neither completed pipeline folder was available when inspected. The specifications use the same seed, `1549466984`; the relevant pipeline code at their two commits is identical. Before comparison, check their completed configurations, input records and verification reports. The intended scientific difference is the model.

Read these existing products, with paths relative to each run:

| Existing product | Purpose |
|---|---|
| `output/calibration/calibration_prediction_fit_<month>_bluesky.RDS` | Monthly full-data REML fits; training rows and observed albedo |
| `output/calibration/calibration_mod_interp_selected_<month>_bluesky.RDS` | Confirm the selected fit passed to script 6 agrees with the prediction fit |
| `output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS` | Albedo used by the pipeline: `alb_mean` is the mean of simulated responses |
| `output/prediction/paleo_interp_predict_gam_bluesky.RDS` | Deterministic fitted means and actual cover mixtures |
| `data/ALB_diffs_bluesky.RDS` | Existing pair differences, cell areas and ice fractions |
| `output/forcing/RF_holocene_all_cases.RDS` | Forcing by cell, month, consecutive slice pair, kernel and component |
| `output/forcing/forcing_by_period.csv` | Published-style period totals |
| `output/forcing/forcing_by_period_variant_sensitivity.csv` | Existing vegetation, ice and total comparisons |
| `output/forcing/forcing_by_month_latitude.csv` | Existing monthly breakdown |

The distinction between deterministic predictions and simulated means matters: [script 6](/home/expert/Documents/contracting/Andria/paleo-RF-wt/comparison/scripts/6_prediction_model.R:45) saves both, while script 7a reads the latter. Compare pipeline results using their actual saved inputs; use deterministic predictions for the sign diagnostic.

Also read the existing CV reports under:

`paleo-RF-verify/f07ff68/.rundirs/cv-run1/output/cross_validation/`

Use `scores.csv`, monthly and regional reports, in-range reports, `groups.csv` and the saved holdouts. Do not rescore or choose another model.

### Small output set

**Three tables:**

1. **Albedo comparison:** study domain and northeast; every month and configured slice; each model’s regional mean and chosen minus model 8; support shares.
2. **Forcing comparison:** existing periods, plus the northeast 6–4.5 ka interval; monthly and annual results; each model and their difference; support shares and signed contributions.
3. **Northeast sign table:** the 24 rows defined in section 2.

**Three figure files:**

- **Series:** annual regional albedo through all slices and forcing over the existing periods, with both models. Monthly values remain in the tables.
- **Difference maps:** chosen minus model 8. Albedo at 50 BP, 6 ka, 4.5 ka and the oldest actual slice; forcing over the existing periods. Use a common colour scale within each quantity. Existing run figures supply the individual-model maps.
- **April–May northeast figure:** section 2.

Show the configured headline total forcing and the HadGEM3 vegetation component. Retain the other kernels in the comparison table; another map collection adds little. State that the oldest actual slice is **11.5 ka**, including where an inherited period label says “10–12 ka”.

Match rows by cell coordinates or cell ID, month and age—not row position. Use the same cells and denominators for both models; report missing coverage.

For forcing, reuse the existing complete-pair and month-averaging rules. Sum consecutive changes; do not average them. The northeast interval uses pairs whose younger ages are **5500, 5000 and 4500 BP**.

The ice component is not necessarily identical between models: [its existing formula](/home/expert/Documents/contracting/Andria/paleo-RF-wt/comparison/R/differences.R:75) includes vegetation albedo.

### What “tested versus untested” means

Use three explicit labels for each cell, slice and month:

1. **Inside the monthly training hull.**
2. **Outside the hull, but in a CV group with withheld predictions.**
3. **Outside the hull, without that CV representation.**

Build the hull from that month’s full-data fitting rows. Reuse `training_hull()` and `training_support()`; a boundary point counts as inside. The current [input reader](/home/expert/Documents/contracting/Andria/paleo-RF-wt/comparison/R/training_support.R:59) is May-only, so the comparison should read the monthly fits directly.

For outside points, reuse the saved CV directions and the existing `departure_angle()`, `nearest_direction()` and `distance_band()` functions. “Represented” means the same **month, departure direction and distance band** has valid withheld predictions for the compared models. It does not mean the exact historical mixture or location was tested.

This distinction already changes the interpretation: `scores.csv` reports `represented = 1` for the positive-weight outside target. Therefore, extensive extrapolation can coexist with **zero unrepresented target weight**. That does not cover cells excluded for missing area or ice, or establish local accuracy.

Inside-hull rows keep that literal label. The completed in-range holdouts provide separate evidence; they do not validate every inside-hull cell.

For a change between slices, inspect both endpoints. For a period, inspect **every endpoint used in its component steps**. Assign the cell-month period result to:

- unrepresented if any endpoint is unrepresented;
- otherwise represented extrapolation if any endpoint is outside;
- otherwise inside throughout.

Report two things:

- **Area shares.** For slice-level vegetation summaries, use area × ice-free fraction, as in the approved CV target. For forcing summaries, use the same whole-cell area and valid-month weights as the reported forcing.
- **Signed contributions**, using the whole result’s denominator. These must add back to the displayed total.

Do not divide contributions by net forcing: warming and cooling can cancel. Do not multiply saved vegetation forcing by ice-free fraction again; that fraction is already included.

The hull diagnostic follows King and Zeng, §2.3, pp. 138–140. It describes support in the selected covariates, not a guarantee of nearby observations or causal identification. The three reporting labels and conservative period assignment are **project reporting judgements**, requiring Chris’s agreement. [DOI: 10.1093/pan/mpj004](https://doi.org/10.1093/pan/mpj004)

### Code location and code effect

**Rename and extend** `tools/plotting/plot_northeast_cover_and_location.R` as `tools/compare_cv_hindcasts.R`.

- **Adds:** reading two run folders and the CV records; matching tables; monthly loops; the comparison tables and figures.
- **Removes:** the fixed `mod8` versus `cover_elev` assumption, May-only calculations in this tool, historical-open-land substitution in the modern curve, and interpolated endpoint contrasts.
- **Reuses unchanged:** model registry, region definition, hull geometry, CV grouping functions and map helpers.
- **Moves rather than duplicates:** the existing per-cell period-summing block needed by both comparison and forcing-support plotting into one small function in `R/forcing_periods.R`.

The old diagnostic remains available in its recorded run and git history. No new pipeline stage or general comparison framework is needed.

## 2. Northeast sign table and April–May figure

**Benefit to the paper:** distinguish the actual reconstructed change from the model’s isolated evergreen–summergreen response.

### Common definitions

Use `region_of()` unchanged: **−80 ≤ longitude < −66; 40 ≤ latitude < 48**.

Use the same northeast cells at 6000, 5500, 5000, 4500 and 50 BP. The 50 BP reconstruction supplies “today’s” cover; it is not a modern stand survey.

Read each model’s **full-data monthly prediction fit**, not its ML ladder fit or a CV fold fit. Confirm the two models used the same monthly calibration rows and response values. Their hulls and observed modern ranges can then be computed once per month.

I recommend fixed cell-area weights for regional model means, so the table agrees with the regional comparison. This deliberately replaces the old diagnostic’s unweighted means. The requested **share of cells** remains a count fraction.

Let \(A_i\) be cell area and \(a_{kmit}\) the deterministic predicted vegetation albedo for model \(k\), month \(m\), cell \(i\), age \(t\).

### Exact table columns

One row per month and model: **24 rows**.

| Column | Definition |
|---|---|
| **6–4.5 ka albedo change** | \(\sum_i A_i(a_{kmi,4500}-a_{kmi,6000})/\sum_i A_i\). Positive means brighter at 4.5 ka. Evaluate the three consecutive differences as a check. |
| **Modern evergreen→summergreen swap** | The fixed-open-land contrast defined below. Positive means the summergreen-rich endpoint is brighter. |
| **Historical cells outside monthly hull** | Count percentages at 6 ka, at 4.5 ka, and outside at **any of the four slices** used by the three-step interval. |
| **Swap cells outside monthly hull** | Percentage whose synthetic mixture is outside at either swap endpoint. |
| **4.5 ka predicted albedo against modern range** | Regional predicted mean; observed monthly northeast minimum and maximum; `below`, `within` or `above`. |

The modern range comes from **observed response values in the monthly fitting data**, not fitted values. It is a descriptive warning, not a confidence interval or a physical bound.

The forcing table from section 1 supplies the corresponding twelve monthly northeast forcing sums. Keep those pipeline results distinct from this deterministic sign table.

### The modern swap

From the common northeast 50 BP rows, obtain:

- each cell’s own modern open-land fraction, \(OL_{i,50}\);
- the regional minimum and maximum modern evergreen fractions, \(e_L,e_H\).

At each cell, keep location, elevation and modern open land fixed. Set:

\[
(OL,ET,ST)=(OL_{i,50},e,1-OL_{i,50}-e).
\]

Define the evergreen→summergreen contrast as:

\[
S_{km}=
\frac{\sum_i A_i\{\hat a_{km}(i,e_L)-\hat a_{km}(i,e_H)\}}
     {\sum_i A_i}.
\]

Predict at the **exact endpoints**. Do not obtain the contrast by interpolating plotted points.

Using today’s open land and evergreen range does **not** guarantee joint support. Test both synthetic endpoints against that month’s hull. Call this the *modern-open-land contrast*; call it fully supported only when the hull checks justify that description. Do not silently narrow the exchange or change the cells to manufacture support.

### April–May figure

Use two panels, one per month, with two model colours.

Each panel shows:

- the predicted regional curve across the modern evergreen range, keeping each cell’s modern open land;
- a small aligned support strip showing the percentage outside the monthly hull along that curve;
- the observed modern albedo minimum–maximum as a horizontal band;
- points for 6 and 4.5 ka, using predictions at the **actual historical mixtures**.

The historical points sit at mean historical evergreen cover and mean predicted albedo. They need not lie on the modern-open-land curve.

The caption must say:

> Points use the actual historical cover mixtures. Lines exchange evergreen and summergreen while holding each cell’s modern open land, location and elevation fixed. The support strip identifies extrapolated synthetic mixtures.

Use model names, not “with/without location”: both requested models contain location terms. The existing latitude scatter can remain background evidence rather than being regenerated in every panel.

### Hand-worked checks

Both models have the form:

\[
\eta=b_0+s(x,y)+s(elevation)+g(OL,ET,ST),
\qquad a=\operatorname{logit}^{-1}(\eta).
\]

For an **identical cover exchange** copied to different locations:

- the link-scale difference is identical;
- its response-scale sign is identical;
- its response-scale magnitude can differ.

For example, a link increase of 0.3 changes albedo:

- from \(0.1192\) to \(0.1545\) when the starting link is −2;
- from \(0.1824\) to \(0.2315\) when it is −1.5.

This sign-invariance check must use identical cover endpoints. Cells retaining different modern open-land fractions undergo different exchanges and can legitimately have different signs.

Also check:

- `(OL,ET,ST) = (0.15,0.40,0.45)` becomes `(0.15,0.20,0.65)` under a 0.20 evergreen→summergreen swap.
- Zero exchange gives zero; reversing the exchange reverses the difference.
- All mixtures remain nonnegative and sum to one.
- For albedos `0.20, 0.18, 0.17, 0.15`, the three changes sum to `−0.05`, equal to the endpoint difference.
- A constructed modern range `[0.10,0.20]` classifies predictions `0.08`, `0.15`, `0.22` correctly.
- Plotted historical points reproduce predictions at actual mixtures.

**Code effect:** adds one model/month calculation reused by table and figure; removes the old historical-open-land contrast and its misleading modern-range interpretation.

## 3. Literature comparison

**Benefit to the paper:** provide an observed seasonal expectation without reopening the dropped satellite-pair study.

Suggested paper paragraph, after the reference checks:

> Published observations generally show deciduous broadleaf forest to be brighter than evergreen needleleaf forest during the snow-free growing season and under winter snow. The winter contrast can increase when snow is exposed beneath leafless canopies. The ordering is not universal: Hollinger et al. report winter exceptions involving southern pine and leafless hardwood sites. These comparisons provide context for our modelled evergreen–summergreen response; they do not directly measure the reconstructed northeast replacement or establish past snow conditions. [Jin et al., 2002](https://doi.org/10.1029/2001GL014132); [Hollinger et al., 2010](https://doi.org/10.1111/j.1365-2486.2009.02028.x); [Zhao and Jackson, 2014](https://doi.org/10.1890/12-1705.1).

One small supporting table is sufficient. Values are albedo fractions; differences below are simple subtraction of the published means.

| Observational comparison | Deciduous | Evergreen | Deciduous minus evergreen | Exact passage |
|---|---:|---:|---:|---|
| Winter 2000–01, 40–50°N, snow-free | 0.122 | 0.105 | +0.017 | Jin, Table 1, p. 12-3 |
| Same winter and latitude band, snow-covered | 0.294 | 0.213 | +0.081 | Jin, Table 1, p. 12-3 |
| Snow-free April–May | 0.145 | 0.084 | +0.061 | Hollinger, Table 2, p. 701 |
| Snow-free June–August | 0.152 | 0.079 | +0.073 | Hollinger, Table 2, p. 701 |
| Snow-free September–October | 0.146 | 0.089 | +0.057 | Hollinger, Table 2, p. 701 |
| Annual, adjacent North American forest pairs | 0.166 | 0.138 | +0.028 | Zhao and Jackson, p. 338 |

The caption must distinguish the measurements:

- **Jin:** shortwave black-sky albedo at local noon; averaging 31 October 2000–1 February 2001. Table and supporting passage read. [Publisher text](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2001GL014132).
- **Hollinger:** tower broadband albedo; deciduous sites compared here with the **northerly evergreen subset**. Table and winter-exception passage read. These are not matched northeast pairs. [Primary PDF](https://research.fs.usda.gov/treesearch/download/34733.pdf).
- **Zhao and Jackson:** MODIS white-sky albedo; annual means over adjacent forest pairs, without separating snow states. Passage read. [Author PDF](https://jacksonlab.stanford.edu/sites/g/files/sbiybj20871/files/media/file/em2014.pdf).

**Burakowski:** methods and Figure 5 caption, p. 5149, were read. They provide a New England December–March comparison separated by snow state. Exact forest bar heights were **not verified**, so include no numerical contrast from that graph. The reported `0.17–0.18` on p. 5148 is a model bias for snowy deciduous forest, not a deciduous–evergreen difference. [Primary PDF](https://harvardforest1.fas.harvard.edu/publications/pdfs/Burakowski_JClimate_2016.pdf).

Before any number enters the paper:

1. Run **RefChecker and refaudit** on the retained references; reconcile identity discrepancies and check corrections/retractions.
2. Independently verify the passages, forest classes, snow definitions, latitude/season, illumination convention, numbers and subtraction.
3. Specifically verify Hollinger’s northern subset and winter exception, and distinguish Zhao’s annual paired result from its January zonal means.
4. Keep satellite forest classes distinct from the reconstruction’s summergreen/evergreen categories, which include shrubs and do not map perfectly onto broadleaf/needleleaf classes.

The automated checkers establish reference identity; they do not establish numerical claim support. They were not run in this read-only session.

**Code effect:** none; one paragraph and, if useful, this table.

## 4. Reviews and verification

Give **Fable and Astra the same code and requirements independently**, beginning with the paper benefit and Chris’s simplicity rule. Reconcile once. A change-reviewer should cover run reading and path handling. Record findings with file/line, consequence, evidence and proposed check; report how many were discarded because they would add complexity without fixing a real defect.

Run verification through `tools/verify_change.R`, from a separate worktree at the exact implementation commit, after the two input runs finish. Use a spec such as `docs/cc/verification/<date>_cv-hindcast-comparison.R`.

The necessary checks are:

- the hand calculations in section 2;
- comparing a run with itself produces zero differences;
- changing a monthly hull affects that month’s support, not another month’s;
- a missing CV group changes representation without changing hull membership;
- support classes partition the stated denominator;
- signed contributions add back to the displayed totals;
- whole-domain forcing reproduces scripts 9 and 10;
- northeast forcing sums exactly the three specified steps;
- table and figure values agree;
- deterministic and simulated-mean results are labelled correctly, with any material sign discrepancy investigated.

Check the April–May figures visually, particularly support markings, observed ranges and historical-point captions.

Use existing CV evidence in the interpretation. The pooled RMSE is about **0.08448 for the chosen model versus 0.10017 for model 8**, but the saved northeast April–May regional diagnostics favour model 8 in both represented departure directions and in the in-range report. Those regional results have limited block replication and do not alter the frozen choice. They do prevent claiming that an overall CV improvement automatically establishes better local spring behaviour.

Holding location fixed during prediction does not undo confounding during fitting. Paciorek supplies the relevant caution about spatial scales and separation of covariate effects. [DOI: 10.1214/10-STS326](https://doi.org/10.1214/10-STS326)

For implementation, put the agreed design and references in the issue before coding; carry the supporting precedent and explicit reporting judgements into the changelog and methods. Update the two living question files then.

**Code effect:** adds targeted scientific checks and one verification spec; reuses completed fits and pipeline outputs.

## 5. What Chris and Andria must decide

**Chris:**

- **Monthly hulls:** recommend each month’s own. The dropped-check note records this choice, while the current brief treats it as pending; settle that record once.
- **Regional contrast:** approve fixed cell-area weights, each cell’s own 50 BP open land, and the common regional evergreen endpoints.
- **Support reporting:** approve the three labels and the conservative all-endpoints rule. Recommend the full-region swap with its support percentage; do not add a supported-only subset unless that answers a further question.
- **Interpretation:** retain the frozen model choice and present the existing local CV errors beside any northeast sign change.

**Andria:**

- Does the vegetation effect represent change under modern climate and snow, as these monthly all-days fits imply?
- Is the comparison between pollen cover categories and published broadleaf/needleleaf forest classes acceptable as qualitative context?
- Is the modern 50 BP reconstruction an adequate reference for the proposed swap?
- How central is a claim about the true northeast replacement effect? This design assesses model behaviour and plausibility; it does not independently establish that historical effect.

The approved 6–4.5 ka interval remains the comparison interval. An ecological interpretation of its timing should not become a search for a more favourable window.

## Not worth doing

- Reviving issue #27 through relaxed pairing rules or another land-cover product.
- New tower-data processing or snow-specific refits for this comparison.
- Additional candidates, folds, geographic partitions or a changed selection score.
- Moving an identical cover swap to many regions as independent evidence: additivity already determines its sign invariance.
- Automatically choosing new swap endpoints to obtain support.
- Treating the observed modern range as a clipping rule.
- Percentages of net forcing, or a new absolute-magnitude statistic to avoid cancellation.
- Confidence intervals made by pairing simulation draws across the two models merely because their seeds match.
- A general run-comparison framework, new configuration system or duplicate northeast tool.
- Repeating full pipeline runs solely to generate these reporting products.

## References

- **Jin, Y., et al. (2002).** How does snow impact the albedo of vegetated land surfaces as analyzed with MODIS data? *Geophysical Research Letters*, **29**(10), 1374, 12-1–12-4. DOI: [10.1029/2001GL014132](https://doi.org/10.1029/2001GL014132).
- **Hollinger, D. Y., et al. (2010).** Albedo estimates for land surface models and support for a new paradigm based on foliage nitrogen concentration. *Global Change Biology*, **16**, 696–710. DOI: [10.1111/j.1365-2486.2009.02028.x](https://doi.org/10.1111/j.1365-2486.2009.02028.x).
- **Zhao, K., & Jackson, R. B. (2014).** Biophysical forcings of land-use changes from potential forestry activities in North America. *Ecological Monographs*, **84**, 329–353. DOI: [10.1890/12-1705.1](https://doi.org/10.1890/12-1705.1).
- **Burakowski, E. A., Ollinger, S. V., Bonan, G. B., Wake, C. P., & Dibb, J. E. (2016).** Evaluating the Climate Effects of Reforestation in New England Using a Weather Research and Forecasting (WRF) Model Multiphysics Ensemble. *Journal of Climate*, **29**, 5141–5156. DOI: [10.1175/JCLI-D-15-0286.1](https://doi.org/10.1175/JCLI-D-15-0286.1).
- **King, G., & Zeng, L. (2006).** The Dangers of Extreme Counterfactuals. *Political Analysis*, **14**, 131–159. DOI: [10.1093/pan/mpj004](https://doi.org/10.1093/pan/mpj004). Supports the hull diagnostic and its limits.
- **Paciorek, C. J. (2010).** The importance of scale for spatial-confounding bias and precision of spatial regression estimators. *Statistical Science*, **25**, 107–125. DOI: [10.1214/10-STS326](https://doi.org/10.1214/10-STS326). Supports caution about interpreting spatially adjusted cover effects.