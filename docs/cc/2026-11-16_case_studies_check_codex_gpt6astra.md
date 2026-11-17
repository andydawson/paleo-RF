**Yes: all four leading changes are clearly visible in the land cover used by the pipeline. I would prioritise Quebec–Labrador and the prairie advance alongside the hemlock decline. Land clearance remains useful, but Chris is right to question its ranking: it is a check of the model’s response, not independent validation of historical albedo.**

I independently reproduced the report’s regional cover changes and pollen-cell counts. My uncertainty calculation also supports its main signals, while qualifying some smaller changes. None of these cases supplies observed past albedo against which the model can simply be scored.

| Candidate | Verdict | What it can show |
|---|---|---|
| Quebec–Labrador spruce rise | **Usable with caveats; strongest additional case** | Whether increasing evergreen cover produces a plausible seasonal response, mostly within modern cover mixtures. |
| Hemlock decline | **Usable with caveats** | The reverse evergreen–summergreen exchange, with relatively dense pollen coverage, but substantial extrapolation beyond modern mixtures. |
| Prairie advance and forest return | **Usable with caveats; advance stronger** | The response to opening vegetation, its seasonal size, and whether the return gives a consistent reversal. |
| Eastern land clearance | **Usable with caveats as a secondary diagnostic** | The response to more open land. The calibration endpoint and subsequent regrowth prevent a straightforward historical validation claim. |
| Northwest Canada spruce rise | **Usable with caveats as supporting evidence** | A larger evergreen–summergreen exchange elsewhere, with sparse pollen coverage and greater climate differences. |
| Northwest Canada/Alaska greening; Pacific Northwest forest closure | **Usable with caveats, lower priority** | Additional opening/closing contrasts, with weaker historical or climatic comparability. |

**What I checked**

I read the finished-run [past land-cover table](/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main/data/lct_paleo_reveals_interp.RDS), its [modern table](/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main/data/lct_modern_reveals_interp.RDS), the [upstream posterior draws](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/data/veg_posts_interp_ice.RDS), and the [available coarse pollen-based table](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/data/lct_paleo_reveals.RDS), using Python independently of the report’s scripts.

The report’s study area contains **2,655 cells with all 25 slices**. Its land-cover values match the example finished run exactly; the modern table equals the 50 BP slice. The upstream posterior means reproduce the saved cover fractions to numerical precision.

For comparability, I retained the report’s boxes and its area weights multiplied by the smaller endpoint ice-free fraction. Those exact choices are **project choices**. Fixed-domain, area-weighted cover comparisons have precedent in Dawson et al. (2025), §2.4, p. 2035, *Holocene land cover change in North America: continental trends, regional drivers, and implications for vegetation–atmosphere feedbacks*, *Climate of the Past* 21, 2031–2060, DOI **10.5194/cp-21-2031-2025**. [Paper](https://cp.copernicus.org/articles/21/2031/2025/cp-21-2031-2025.pdf#page=5)

For uncertainty, I averaged each **whole posterior map** over the region before comparing ages, preserving spatial dependence. I combined every older regional draw with every younger draw, avoiding arbitrary matching of draw numbers. Posterior differences have palaeovegetation precedent in Dawson et al. (2019), *Quantifying trends and uncertainty in prehistoric forest composition in the upper Midwestern United States*, *Ecology* 100:e02856, p. 7, DOI **10.1002/ecy.2856**. The all-pairs implementation is a project adaptation to the separate-slice reconstruction. [Paper](https://onlinelibrary.wiley.com/doi/pdfdirect/10.1002/ecy.2856)

**These are conditional interpolation intervals, not total reconstruction uncertainty.** They exclude pollen-to-cover standard errors and dating uncertainty; temporal dependence was not implemented in this reconstruction. Dawson et al. (2025), §4.3, p. 2048, explicitly describes these limitations. [DOI 10.5194/cp-21-2031-2025](https://cp.copernicus.org/articles/21/2031/2025/cp-21-2031-2025.pdf#page=18)

**The leading candidates in our data**

Changes below are younger minus older, in **percentage points of cover**. Brackets contain my marginal 95% interpolation intervals. Evergreen and summergreen both include trees and shrubs.

| Candidate and slices | Cells | Open land change | Evergreen change | Summergreen change |
|---|---:|---:|---:|---:|
| Eastern clearance, 500 → 50 BP | 215 | **+11.8 [5.6, 17.4]** | −3.5 [−7.1, −0.4] | −8.3 [−14.3, −1.9] |
| Quebec–Labrador, 6 → 2.5 ka | 186 | −0.5 [−5.5, 4.8] | **+18.0 [11.0, 25.4]** | **−17.5 [−25.3, −9.9]** |
| Hemlock decline, 6 → 4.5 ka | 83 | −0.7 [−2.8, 1.3] | **−18.0 [−22.9, −12.9]** | **+18.7 [13.2, 23.9]** |
| Prairie advance, 10.5 → 8 ka | 117 | **+19.6 [12.6, 26.2]** | **−13.7 [−18.9, −8.5]** | −5.9 [−12.6, 0.9] |
| Prairie retreat, 4.5 → 0.5 ka | 117 | **−9.7 [−16.1, −3.0]** | +3.6 [0.4, 6.7] | +6.1 [−0.4, 12.4] |

The main changes are established much more clearly than every component of the exchange. For example, the prairie advances through increasing open land and decreasing evergreen cover; its smaller summergreen decline is uncertain. The later reduction in open land is also supported, but the division of returning woody cover is less certain.

The changes persist across slices and are spatially widespread:

- **Eastern clearance:** open land rises **21.5% → 29.3% → 33.3%** at 500, 200 and 50 BP; **210/215 cells** increase.
- **Quebec–Labrador:** evergreen rises **36.2% → 42.2% → 46.2% → 47.1% → 50.0% → 50.2% → 52.7% → 54.3%**, through every slice from 6 to 2.5 ka. **179/186 cells** increase.
- **Hemlock region:** evergreen falls **39.9% → 36.7% → 29.2% → 22.0%**, from 6 through 4.5 ka. **All 83 cells** decrease. By 2 ka it recovers to **33.1%**, supporting a useful return comparison.
- **Prairie advance:** open land rises **35.5% → 38.9% → 42.6% → 47.0% → 51.3% → 55.1%**, from 10.5 through 8 ka. **101/117 cells** increase.
- **Prairie retreat:** open land falls from **57.8% to 48.1%**, with intervening reversals; **102/117 cells** decrease. This is a weaker, less orderly change.

Excluding every cell with ice at either endpoint preserves the principal results: Quebec evergreen **+17.4** rather than +18.0 points; prairie open land **+20.6** rather than +19.6; northwest Canada evergreen **+23.4** rather than +23.5. These signals are not consequences of retaining partly glaciated cells.

**Pollen coverage needs more careful wording than the headline table suggests.**

The available table contains distinct cell–age estimates, but no individual site counts or sample dates. Some counted ages differ substantially from the candidate endpoints.

| Candidate | Cells with pollen-based estimates | Ages actually counted |
|---|---:|---|
| Eastern clearance | 96 → 86 of 215 | 500 → 50 BP |
| Quebec–Labrador | 38 → 36 of 186 | **6 → 2 ka**, not 6 → 2.5 |
| Hemlock | 59 → 61 of 83 | **6 → 4 ka**, not 6 → 4.5 |
| Prairie advance | 44 → 45 of 117 | **10 → 8 ka**, not 10.5 → 8 |
| Prairie retreat | 48 → 52 of 117 | **4 → 0.5 ka**, not 4.5 → 0.5 |

These are approximate guides to observational coverage. The files do not establish that the older coarse table contains exactly the observations underpinning the newer interpolated product.

**Chris’s calibration objection is correct, with an important qualification.**

[Script 1 selects age 50 as modern](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/scripts/1_veg_lct_prep.R:63), and [the calibration attaches the satellite albedo](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2/scripts/2_calibration_lct_bluesky.R:173). Consequently, the younger endpoint is a fitted state. Agreement there cannot independently validate the model.

However, fitting modern albedo does **not** force the predicted historical change to have the right sign or size. The contrast can still expose an implausible cover response. Its appropriate claim is therefore: *does the fitted model respond plausibly to this reconstructed opening?*

The time mismatch is more serious than the slice label suggests. Dawson et al. (2025), p. 2035, §2.2, gives the youngest bins as **1250–1600, 1600–1850 and 1850–2024 CE**. Within-bin pollen counts are pooled. Thus 50 BP is neither a specific historical year nor necessarily an evenly weighted average of those years, and cannot automatically represent 2000–2009. [DOI 10.5194/cp-21-2031-2025](https://cp.copernicus.org/articles/21/2031/2025/cp-21-2031-2025.pdf#page=5)

Reforestation matters directly. Steyaert and Knox’s historical reconstruction reports peak-growing-season albedo around **0.14–0.15** in the central deciduous region in 1650, approximately **+0.02** in disturbed/regenerating forests by 1850, typically **0.16–0.19** over much of the eastern US in 1920, and **0.12–0.15** over much of the region after regrowth by 1992. These are spatial descriptions, not a matched mean for our rectangle: §3.2.1, accessible manuscript pp. 46–47. Their albedos themselves use modern optical parameters, including MODIS (§2.4.5, pp. 25–26). They are reconstructed historical albedos, not historical measurements. **Steyaert & Knox (2008), DOI 10.1029/2006JD008277.** [NASA manuscript](https://ntrs.nasa.gov/api/citations/20080031165/downloads/20080031165.pdf)

The cleaner clearance comparison is the **Atlantic seaboard, 500 → 200 BP**: open land increases **13.7 points [2.8, 24.3]**, evergreen changes −1.8 and summergreen −11.8, across 58 cells. It avoids the fitted endpoint, but remains a plausibility check. The calibration’s historical/modern mismatch still affects it—and every other hindcast. Its reported younger pollen count also comes from **50 BP**, because no 200 BP row exists in the coarse table.

**What the literature supports about albedo**

For a transparent scale comparison, I multiplied our cover changes by published class albedos and summed them. This follows the fractional-cover mixing in **Boisier, de Noblet-Ducoudré & Ciais (2013), *Inferring past land use-induced changes in surface albedo from satellite observations*, p. 1504, Eq. 1, DOI 10.5194/bg-10-1501-2013**. Mapping our broad classes onto forest and grassland analogues is a **project assumption**. [Paper](https://bg.copernicus.org/articles/10/1501/2013/bg-10-1501-2013.pdf)

The checked inputs were:

- **Snow-free:** Hollinger et al. (2010), *Albedo estimates for land surface models and support for a new paradigm based on foliage nitrogen concentration*, Table 2, p. 701. Grassland/evergreen/deciduous values are **0.209/0.084/0.145** in April–May, **0.181/0.079/0.152** in June–August, and **0.197/0.089/0.146** in September–October. DOI **10.1111/j.1365-2486.2009.02028.x**. [Paper](https://escholarship.org/content/qt45n4h12r/qt45n4h12r.pdf#page=7)
- **Snow-covered:** Boisier et al., Table 2, p. 1506, gives **0.568/0.205/0.244** for grasses/evergreen trees/deciduous trees. These are MODIS white-sky values; the pipeline predicts blue-sky albedo. [DOI 10.5194/bg-10-1501-2013](https://bg.copernicus.org/articles/10/1501/2013/bg-10-1501-2013.pdf)

The following are **my illustrative calculations**, not published estimates of these events, uncertainty bounds or acceptance thresholds. Open land is represented by grassland, including in the clearance case. The snow column assumes the specified snow-covered state; it is **not an actual regional winter mean**.

| Candidate | Snow-free spring | Snow-free summer | Snow-free autumn | Fully snow-covered analogue |
|---|---:|---:|---:|---:|
| Eastern clearance | +0.010 | +0.006 | +0.008 | +0.040 |
| Quebec–Labrador spruce | −0.011 | −0.013 | −0.011 | −0.009 |
| Hemlock decline | +0.011 | +0.013 | +0.010 | +0.005 |
| Prairie advance | +0.021 | +0.016 | +0.018 | +0.069 |
| Prairie retreat | −0.008 | −0.005 | −0.007 | −0.033 |

An albedo change of 0.01 means one percentage point more incoming sunlight reflected.

The broad signs have support: forest opening brightens; replacing deciduous forest with evergreen generally darkens. The exact magnitudes require restraint. In particular, **Quebec’s shrub-to-spruce interpretation lacks a matched quantitative analogue in every season**. Boisier groups shrubs with grasses, whereas this calculation assigns summergreen vegetation deciduous-tree albedo. Snow duration, vegetation height and canopy closure also matter.

The data establish broad class exchanges; the species names require palaeoecological interpretation. The prairie timing is particularly well supported: Williams, Shuman and Bartlein (2009), §3.2, p. 199, reports expansion during **11–7 calendar ka**, fastest during **10–8 ka**, and retreat during **6–2 ka**. Our advance window captures that major phase; the chosen retreat window extends later. DOI **10.1016/j.gloplacha.2008.10.012**. [Paper](https://citeseerx.ist.psu.edu/document?doi=85e6754821e21b7e11dca0f9b9a36a377d3596d7&repid=rep1&type=pdf)

**Why the main cases are useful despite these limits**

Quebec tests the opposite exchange to hemlock with much less cover extrapolation. I reproduced the report’s finding that approximately **19–21%** of its endpoint area lies outside modern May cover mixtures, compared with **98–100%** for hemlock. Prairie advance is **0–5%** outside.

I also independently recalculated seasonal changes from the saved albedo predictions:

- In summer, the original model gives **+0.0084 for Quebec**, **−0.0211 for hemlock**, and **−0.0031 for prairie advance**—opposite to the corresponding forest/grass analogue signs.
- The provisional linear-cover model gives **−0.0100, +0.0115 and +0.0094**, respectively.
- That model nevertheless gives winter changes of **+0.0305 for Quebec** and **−0.0286 for hemlock**, again opposing the adopted forest contrasts.

These are useful diagnostic disagreements. They do not disappear simply because the cover change is uncertain, and an annual average conceals them. They also do not establish which model reconstructs actual past seasonal albedo correctly.

**The additional candidates**

I checked the remaining regional cover changes as well. For the next-ranked cases:

| Candidate; slices | Cells; approximate pollen coverage | Change in open / evergreen / summergreen cover, points | Principal 95% interval |
|---|---|---:|---:|
| Northwest Canada spruce; 10 → 8 ka | 307; 29 → 30 cells at those ages | −4.0 / **+23.5** / −19.6 | Evergreen **+15.2 to +31.7** |
| Northwest Canada greening; 11.5 → 10 ka | 307; 21 → 29 at 12 → 10 ka | **−25.0** / +12.1 / +12.9 | Open **−34.9 to −15.1** |
| Alaska greening; 11.5 → 9 ka | 223; 33 → 43 at 12 → 8 ka | **−18.6** / +4.1 / +14.6 | Open **−27.9 to −9.2** |
| Pacific Northwest closure; 8 → 5.5 ka | 58; 23 → 25 at 8 → 6 ka | −13.7 / **+15.9** / −2.2 | Evergreen **+5.2 to +25.8** |

Using the same illustrative forest/grass parameters, their summer changes are respectively about **−0.018, −0.016, −0.008 and −0.016**; the snow-covered analogues are **−0.022, −0.086, −0.062 and −0.051**. All suggest darkening, with particularly uncertain magnitudes for tundra/shrub transitions.

Northwest Canada spruce is the most useful supporting case. The greening cases have large cover signals but greater climate and vegetation-structure differences. Winter calibration support is also poor: only **41/307 northwest Canadian cells**, and **none of the 223 Alaska cells**, have January albedo in the checked calibration table. Pacific Northwest closure has better local support, but its series includes an initial opening before the sustained closure.

The lower-ranked cases do not improve the main shortlist:

| Candidate; slices | Recomputed change: open / evergreen / summergreen, points | Verdict |
|---|---:|---|
| Central Canadian treeline retreat; 5 → 0.5 ka | +18.4 / −9.1 / −9.3 | **Usable with substantial caveats:** opening is visible, but only 8–9 of 189 cells have coarse pollen estimates; no January calibration cells. |
| Great Lakes spruce decline; 11.5 → 9 ka | −0.3 / −15.4 / +15.7 | **Usable with caveats as supporting evidence:** clear exchange, but difficult event timing and early-Holocene climate comparison. |
| Alaska spruce expansion; 9 → 4 ka | +1.5 / +12.5 / −13.9 | **Usable with caveats:** clear evergreen increase, but a long interval and weak winter support. |
| Quebec–Labrador opening; 2.5 ka → 50 BP | +7.7 / −6.6 / −1.1 | **Usable with caveats, low priority:** smaller opening and the same calibration-endpoint problem. |
| Southern Plains woodland gain | −11.5 / +4.6 / +6.9 | **Not suitable as a strong test:** all three change intervals include zero; sparse pollen coverage. |
| Southwest opening | +23.6 / −17.5 / −6.1 | **Not suitable as a strong test:** very broad uncertainty, sparse coverage and an unstable regional series. |

The shortlist was assembled after inspecting model results. These cases can reveal implausible responses and explain the paper’s results, but should not be presented as an untouched validation set.

Everything remained read-only; no files or question documents were changed.

**Questions for Chris**

1. Shall Quebec–Labrador and the prairie advance/return join hemlock as the main three diagnostic cases, with land clearance retained only as a secondary check?
2. Should quantitative clearance comparisons wait until Andria establishes whether the pooled **1850–2024 pollen slice adequately represents 2000–2009 vegetation**?
3. Should the expected effect mean **vegetation change under fixed modern snow conditions**? Estimating actual past seasonal albedo would additionally require evidence about past snow.
4. Will Andria accept forest analogues only as a qualitative check where summergreen cover includes shrubs, or does she have suitable shrub/woodland evidence for a quantitative Quebec–Labrador comparison?