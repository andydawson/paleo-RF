**The clearest result is that the inferred cover response remains sensitive to the model.** The chosen model gives summer evergreen-to-summergreen brightening of roughly the published size, but little summer brightening when summergreen becomes open land. Model 8 often reverses that balance. Winter and spring differences are larger, and increasing the location term does not produce a simple, consistent change. I would include this as a supplementary exploration, with a short main-text statement about model sensitivity—not as validation.

All numbers below are **absolute albedo changes for a 10-percentage-point exchange of cover**; positive means brighter. They describe changes around modern mixed cells, holding location, elevation and the third cover class fixed. In the first two tables, each pair is **chosen model (`loc100_linear`) / model 8 (`mod8`)**. Sources are the [full contrast table](/home/expert/Documents/contracting/Andria/paleo-RF-verify/7c12534/.rundirs/cover-contrasts-full/cover_contrasts.csv) and [published comparison guide](/home/expert/Documents/contracting/Andria/paleo-RF-verify/7c12534/.rundirs/cover-contrasts-full/published_guide.csv).

**Evergreen to summergreen.** The chosen model’s snow-free summer response broadly matches the published contrasts multiplied by 0.10: approximately **+0.0047 to +0.0073**. Model 8 instead predicts darkening across most eastern and northern regions. The Southwest is a substantial exception. Spring and autumn remain sensitive: in the northeast, model 8’s all-days response is negative from March through October; the chosen model is positive in March and May–October, with April close to zero.

Winter does not extend the summer agreement. In snowy January, the northeast’s chosen response is almost zero, while model 8 gives +0.0496—much larger than the published snowy guides of approximately +0.0030 to +0.0081. Published winter leaf-habit contrasts are themselves not universally positive, so disagreement is a finding to explain, not proof that a version is physically wrong.

**Evergreen to open land.** This has the strongest agreement in direction. Every version gives positive snow-free *study-area means* in every month. All six also give positive snowy December–March responses in the northeast and Upper Midwest. Their sizes nevertheless differ substantially.

The chosen model’s snow-free summer values are generally near or below the published summer guides of **+0.0072 to +0.0110**. Its northeast snowy January–March values, about +0.024 to +0.027, approach the published winter scale of +0.028 to +0.036; December is much smaller. Continental agreement hides regional reversals: snow-free model 8 predicts summer darkening in the Southern Plains and Southeast.

**Summergreen to open land.** This is the chosen model’s weakest summer comparison. Its response is close to zero or slightly negative, against published summer guides of approximately **+0.0023 to +0.0037**. Model 8 usually gives larger positive snow-free responses in eastern and northern regions, often several times the guide, but negative responses in the Southwest.

The chosen model’s snowy northeast January–March response, about +0.024 to +0.027, is close to the published winter scale of +0.025 to +0.032. Its **all-days March response is negative**, however, in every reported region. The coarse-location curved-cover version also gives negative snowy winter responses in the northeast. There is no agreement across all versions and seasons.

The northeast shows these seasonal differences particularly clearly:

| Northeast: table and month | Evergreen → summergreen | Evergreen → open | Summergreen → open |
|---|---:|---:|---:|
| All days, January | −0.0219 / +0.0250 | +0.0160 / +0.0927 | +0.0365 / +0.0639 |
| All days, March | +0.0169 / −0.0289 | +0.0057 / +0.0448 | −0.0102 / +0.0665 |
| All days, July | +0.0070 / −0.0020 | +0.0063 / +0.0058 | −0.0008 / +0.0080 |
| All days, October | +0.0057 / −0.0197 | +0.0087 / +0.0076 | +0.0028 / +0.0218 |
| Snowy, January | +0.0001 / +0.0496 | +0.0244 / +0.0854 | +0.0239 / +0.0352 |

There is **no directly comparable monthly all-days winter guide**. The published numbers above concern specified snow states and seasons; they are ranges among heterogeneous published means, not acceptance bands or uncertainty intervals.

**The regional differences matter for the case studies.** Snow-free July provides a compact comparison:

| Region | Evergreen → summergreen | Evergreen → open | Summergreen → open |
|---|---:|---:|---:|
| Whole study area | +0.0069 / −0.0034 | +0.0063 / +0.0021 | −0.0008 / +0.0065 |
| Northeast | +0.0075 / −0.0099 | +0.0068 / +0.0015 | −0.0008 / +0.0129 |
| Upper Midwest / Great Lakes | +0.0072 / −0.0116 | +0.0067 / ≈0 | −0.0009 / +0.0150 |
| Southern Plains | +0.0085 / −0.0103 | +0.0075 / −0.0069 | −0.0009 / +0.0086 |
| Southeast | +0.0072 / −0.0231 | +0.0065 / −0.0074 | −0.0008 / +0.0156 |
| Southwest | +0.0089 / +0.0184 | +0.0079 / +0.0067 | −0.0010 / −0.0140 |
| Alaska / Yukon | +0.0066 / −0.0106 | +0.0059 / +0.0009 | −0.0008 / +0.0122 |

For the **hemlock decline**, this establishes disagreement about the modern fitted response, not the albedo change caused by the historical event. The historical cover mixtures remain a separate extrapolation problem.

For the **prairie border**, the summergreen-to-open disagreement has substantial support: 94 eligible cells in the Upper Midwest and all 117 Southern Plains calibration cells. It is not simply a handful-of-cells result. But the Upper Midwest box only overlaps the previously defined prairie-border case-study box; it is not the exact same region.

**Quebec–Labrador has no separate result in this run.** Neither the continental average nor Alaska/Yukon supplies that missing regional answer.

A particularly useful finding is that **June–September all-days and snow-free results use identical saved evaluation cases**, including cells, exchanges and weights. Their differing responses therefore arise from fitting the continental models to different albedo values, not from changing the local cells being averaged. Separately fitted all-days responses need not lie between the snowy and snow-free responses.

**Both location size and cover form change the answer.** Here are northeast evergreen-to-summergreen contrasts. Each pair in this table is **linear cover / curved cover**:

| Location-term size | January, all days | July, snow-free |
|---|---:|---:|
| 30 | +0.0247 / +0.1103 | +0.0098 / +0.0138 |
| 100 | −0.0219 / −0.0202 | +0.0075 / +0.0015 |
| 500 | +0.0005 / +0.0250 | +0.0037 / −0.0099 |

Increasing location size reduces the summer contrast here, but winter changes direction non-monotonically. At size 500, changing the cover form reverses the summer sign. No simple statement that “more location removes more cover effect” describes the full results.

The linear-cover versions also impose the same exchange sign across regions within a month and albedo table. Their regional magnitudes vary, but the chosen model’s consistent regional signs are partly built into its form—not independent regional confirmations.

**Several results should not be described as regional responses.** Counts below follow the exchange order used in the tables; area percentages refer to modern calibration-cell area, not the entire geographic box.

- **Northeast:** all-days results represent 58/41/22 cells, or about 70%/50%/27% of calibration-cell area. Snowy May has only **3/1/1 cells**, with a typical snowy retrieval share of **0.0001%**. October has 2/0/0 cells; June–September has none.
- **Upper Midwest:** snowy May has 4/2/2 cells and October 1/1/4, again with tiny snowy retrieval shares. Conversely, February’s snow-free forest exchanges have dozens of cells but only about **0.1–0.2%** typical snow-free retrieval support.
- **Southern Plains and Southeast:** snowy results often rest on rare retrievals and very few cells. Southern Plains snowy March has 5/5/9 cells; Southeast March and November have 1/2/2. Extreme curves there should not become regional conclusions.
- **Southwest:** snowy late-spring and summer estimates have little retrieval support; June has only 5/6/5 cells.
- **Alaska/Yukon:** all-days January represents only about 6–9% of calibration-cell area, and December has no result. Snow-free February–March and snowy July–August draw on very small shares of accepted retrievals.

“Retrieval share” is the typical share of accepted retrievals in the relevant snow state, not a count of observations or a percentage of calendar days. Familiar continental cover mixtures also do not establish nearby examples of the exchange.

Small signs need restraint. Northeast snow-free July evergreen-to-summergreen is **+0.0075 ±0.0023** for the chosen model and **−0.0099 ±0.0087** for model 8, using the supplied twice-standard-error intervals. But model 8’s all-days July −0.0020 ±0.0107 and the chosen model’s summergreen-to-open −0.0008 ±0.0020 are much less decisive. These intervals omit several sources of uncertainty, including model choice and spatial dependence.

**For the paper, I recommend a compact supplement containing all six versions, the seasonal comparisons and support information.** A main-text sentence could say:

> Predicted responses to vegetation exchange varied with model structure and calibration snow state; agreement with published summer forest contrasts did not extend consistently across exchanges and seasons.

There is good precedent for that presentation. Lejeune et al. (2020), *Biases in the albedo sensitivity to deforestation in CMIP5 models and their impacts on the associated historical radiative forcing*, **Earth System Dynamics 11**, 1209–1232, compares January/July model-derived transitions with satellite estimates in Section 4.2 and Figures 10–11 ([DOI: 10.5194/esd-11-1209-2020](https://esd.copernicus.org/articles/11/1209/2020/)). Burakowski et al. (2016), *Evaluating the Climate Effects of Reforestation in New England Using a WRF Model Multiphysics Ensemble*, **Journal of Climate 29**, 5141–5156, compares model versions with MODIS by cover class and snow state in Figure 5 ([DOI: 10.1175/JCLI-D-15-0286.1](https://harvardforest1.fas.harvard.edu/publications/pdfs/Burakowski_JClimate_2016.pdf)).

Those support showing the comparison, not this exact centred exchange as an established method. Multiplying published contrasts by 0.10 is an ideal linear-mixing guide. Differences in cover classes, geography, albedo definitions and shared MODIS ancestry prevent treating agreement as validation. Sparse snowy estimates belong in the complete record, without regional or historical-event claims.

Two choices remain for Chris:

1. **Include this exploration in the supplement, with the short main-text qualification above, while retaining the existing model-selection decision?**
2. **Before interpreting Quebec–Labrador and the prairie-border events, commission the same summaries for their exact case-study boxes?** The present run lacks Quebec–Labrador and uses only an overlapping Upper Midwest box.

I read all 4,536 result rows, the fit records, logs and four figure pages. All 212 attempted fits converged; the four omissions were by design. No files were changed or downloaded.