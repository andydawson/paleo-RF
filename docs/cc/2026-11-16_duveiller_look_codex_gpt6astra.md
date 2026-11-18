**This is a useful next comparison, with approximate class matching.** I recommend starting with evergreen needleleaf forest → deciduous broadleaf forest beside our ET → ST exchange, using **all-days albedo and the original, unextended estimates**. One file contains that comparison and analogues for our other two exchanges: **`albedo_IGBPdet.nc`, listed by Figshare as 400.46 MB**. Its regional coverage remains unknown until the data are inspected.

The benefit is a geographically matched seasonal reference for the fitted cover response. It would remain a comparison between two MODIS-based estimates with different definitions and methods, rather than an independent validation.

**The files and versions are distinguishable.** The original collection contains the following NetCDF files. Sizes below are the services’ rounded displays; exact byte counts were unavailable.

| Detailed file | Broad file | Contains changes in | Displayed sizes: detailed / broad |
|---|---|---|---|
| `albedo_IGBPdet.nc` | `albedo_IGBPgen.nc` | Albedo | **400.46 MB / 53.4 MB** |
| `SWreflected_IGBPdet.nc` | `SWreflected_IGBPgen.nc` | Reflected shortwave radiation | 400M / 53M |
| `LWemitted_IGBPdet.nc` | `LWemitted_IGBPgen.nc` | All-sky emitted longwave radiation | 400M / 53M |
| `LWsfc_IGBPdet.nc` | `LWsfc_IGBPgen.nc` | Clear-sky emitted longwave radiation | 400M / 53M |
| `LE_IGBPdet.nc` | `LE_IGBPgen.nc` | Latent heat flux | 400M / 53M |
| `HG_IGBPdet.nc` | `HG_IGBPgen.nc` | Sensible and ground heat combined | 400M / 53M |
| `LSTday_IGBPdet.nc` | `LSTday_IGBPgen.nc` | Daytime surface temperature | 400M / 53M |
| `LSTnight_IGBPdet.nc` | `LSTnight_IGBPgen.nc` | Nighttime surface temperature | 400M / 53M |

The albedo sizes come from the [detailed Figshare record](https://doi.org/10.6084/m9.figshare.5217709) and [broad Figshare record](https://doi.org/10.6084/m9.figshare.5217712); the remaining filenames and sizes come from the [JRC v1 directory](https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/ECOCLIM/Biophysical-effects-vgt-change/v1.0/). There is no separate mask file in that listing.

- **Original release:** Figshare collection v1, posted **15 February 2018**; both albedo records specify **CC0**. [Collection record](https://doi.org/10.6084/m9.figshare.c.3829333.v1).
- **JRC v2.0:** retains the original variables and adds climate-based random-forest extensions with an `_ext` suffix. Those extensions also smooth existing values. Internal compression reduces file sizes. This is described on **p. 1** of Duveiller, Hooker and Cescatti’s 2021 addendum, *Scientific Data* 8, 12, [DOI:10.1038/s41597-020-00787-6](https://www.nature.com/articles/s41597-020-00787-6.pdf).
- **JRC licence:** the catalogue specifies the **European Commission reuse notice**, requiring source acknowledgement. Its issue date is **31 October 2020**. [JRC catalogue](https://data.jrc.ec.europa.eu/dataset/f97e4216-e81c-4dfb-b42d-d0c19070d029).

I could not retrieve the v2 directory listing or verify its compressed sizes. Consequently, the concrete download proposal is **the original detailed albedo file alone, 400.46 MB as displayed**. The broad file combines forest types and cannot supply ET → ST.

**The quantity needs several qualifications.** Paper page numbers below are printed PDF pages.

| Property | Finding and evidence |
|---|---|
| Albedo definition | Broadband shortwave, **½ × (black-sky + white-sky)**. The authors write “we took the mean of both values”; diffuse radiation was unavailable. Descriptor, **pp. 3–4**. |
| Time sampling | A **16-day** retrieval window nearest the month’s **15th**, followed by calendar-month medians over **2008–2012**. Descriptor, **pp. 2–4**. |
| Land cover | Represents **2010**. Descriptor, **pp. 3–4**. |
| Output | Global **1° × 1°**, monthly. Descriptor, **p. 11**. |
| Snow | No snow-state dimension. Snow contributes to the seasonal signal; detailed snow-flag screening is unspecified. Descriptor, **pp. 4, 11**. |

These findings are from Duveiller, Hooker and Cescatti (2018), *A dataset mapping the potential biophysical effects of vegetation cover change*, *Scientific Data* 5, 180014, [DOI:10.1038/sdata.2018.14](https://www.nature.com/articles/sdata201814.pdf).

A transition is **predicted pure destination minus predicted pure source**: positive albedo change means brightening. It describes complete local conversion, subsequently aggregated; it is not a simulation of wholesale conversion across an entire coarse cell. The underlying regressions use **5 × 5 windows of 0.05° pixels**. Evidence: method paper, **p. 9, equations 3–11**, Duveiller, Hooker and Cescatti (2018), *The mark of vegetation change on Earth’s surface energy balance*, *Nature Communications* 9, 679, [DOI:10.1038/s41467-017-02810-8](https://www.nature.com/articles/s41467-017-02810-8.pdf).

**Support and uncertainty are included.** The documented naming pattern gives `Delta_albedo`, `SD_Delta_albedo` and `N_albedo`, indexed by latitude, longitude, month and transition. `N` counts contributing fine pixels; `SD` describes estimation uncertainty. Descriptor, **pp. 10–11**, [DOI:10.1038/sdata.2018.14](https://www.nature.com/articles/sdata201814.pdf). I have not inspected a NetCDF header.

The original estimates require complete windows, sufficient distinct cover mixtures and a co-occurrence index of at least **0.5**; three terrain checks use **50/100/100 m** limits. Coarse estimates require at least **20** usable fine pixels. Outliers are also removed, without a stated cutoff. Uncertainty accounts for shared regression predictions and overlapping windows, but omits input-data uncertainty. Evidence: method paper, **pp. 9–10, equations 12–19 and masking/aggregation paragraphs**, [DOI:10.1038/s41467-017-02810-8](https://www.nature.com/articles/s41467-017-02810-8.pdf).

Thus missing values reflect substantive sampling restrictions. They should remain missing in a first comparison.

**The proposed class mapping is deliberately approximate.** The published classes and codes below come from **Table 1, p. 5** of the [descriptor, DOI:10.1038/sdata.2018.14](https://www.nature.com/articles/sdata201814.pdf). The mapping column is my project judgement.

| Detailed class | Proposed relation to our classes |
|---|---|
| 1 — Evergreen broadleaf forest, EBF | ET analogue, but not the clearest match to our predominantly coniferous evergreen taxa |
| 2 — Deciduous broadleaf forest, DBF | Main ST forest analogue |
| 3 — Evergreen needleleaf forest, ENF | Main ET forest analogue |
| 4 — Deciduous needleleaf forest, DNF | ST analogue for larch; keep separate |
| 5 — Mixed forest, MF | Cannot assign wholly to ET or ST |
| 6 — Savannas, SAV | Mixture of woody and open cover |
| 7 — Shrublands, SHR | Cannot assign without leaf habit; our woody classes include shrubs |
| 8 — Grasslands, GRA | Simplest named OL analogue |
| 9 — Cropland, CRO | Separate managed-open analogue; do not automatically combine with grassland |
| 10 — Wetlands, WET | Hydrology and vegetation both differ; no single assignment |

The broad scheme contains forest, shrubland, crops/grasses and savanna. These are **the dataset’s own codes**, not standard MODIS class numbers.

Our [taxon translation](/home/expert/Documents/contracting/Andria/paleo-RF-wt/contrasts/data/taxon2LCT_translation_v2.0.csv:2) places larch in ST and herbaceous taxa in OL. It does not establish a reconstructed bare-ground fraction. I would therefore describe OL as an open/herbaceous class here, avoiding the design note’s broader bare-ground wording.

**The smallest comparison can reuse the existing calculation.**

1. **Start with ET → ST**, represented by ENF → DBF. The same file also supports these optional extensions:

   | Our exchange | Named external analogue | Read from the detailed file |
   |---|---|---|
   | ET → ST | ENF → DBF | Negate transition **23**, which stores DBF → ENF |
   | ET → OL | ENF → grassland | Transition **38** |
   | ST → OL | DBF → grassland | Transition **28** |

   Direction encoding and reversal are documented on **p. 11** of the [descriptor, DOI:10.1038/sdata.2018.14](https://www.nature.com/articles/sdata201814.pdf). Reverse the difference only; retain positive uncertainty and unchanged counts.

2. **Keep our actual ten-percentage-point exchange.** Multiply the published complete-transition difference by **0.10**, as already done for published guides. Scale its cell uncertainty likewise. Fraction-times-transition scaling has direct precedent in **equation 11, p. 1215**, of Lejeune et al. (2020), *Biases in the albedo sensitivity to deforestation in CMIP5 models and their impacts on the associated historical radiative forcing*, *Earth System Dynamics* 11, 1209–1232, [DOI:10.5194/esd-11-1209-2020](https://esd.copernicus.org/articles/11/1209/2020/esd-11-1209-2020.pdf). Choosing exactly 0.10 is our existing project choice.

3. **Use all-days results, keeping each calendar month separate.** Our [README](/home/expert/Documents/contracting/Andria/paleo-RF-wt/contrasts/README.md:19) describes a **2000–2009 blue-sky climatology**. That differs from Duveiller’s illumination approximation, period and within-month sampling. Treat agreement in magnitude and seasonal shape as informative context.

4. **Average both estimates over the same cells.** For each month and existing region, intersect valid original Duveiller coverage with our eligible exchange cells. Recalculate all six model means on that intersection using the existing cell-area weights. The [saved fits and cases](/home/expert/Documents/contracting/Andria/paleo-RF-wt/contrasts/docs/cc/2026-11-15_cover_contrast_exploration_implementation.md:237) should permit this without refitting. Check grid alignment first.

   Matching model coverage to available satellite estimates has precedent in **§2.3, p. 1269**, of Duveiller et al. (2018), *Biophysics and vegetation cover change: a process-based evaluation framework for confronting land surface models with satellite observations*, *Earth System Science Data* 10, 1265–1279, [DOI:10.5194/essd-10-1265-2018](https://essd.copernicus.org/articles/10/1265/2018/essd-10-1265-2018.pdf). Area weighting has precedent in **§2.1.1, p. 1211**, of [Lejeune et al.](https://doi.org/10.5194/esd-11-1209-2020). Our exact intersection, regional boxes and analogue selection remain project choices.

5. **Show coverage alongside the means:** common cell count, represented calibration-cell area and published sample counts. Keep cell uncertainties available. Do not substitute sample counts for area weights or construct a regional confidence interval by assuming adjacent cells are independent.

I would leave out snow-free/snowy comparisons, gap filling, pooled “OL” estimates, new regional uncertainty calculations and scientific pass/fail labels. Existing regional CSV means cannot simply be overlaid if their spatial coverage differs. Modern agreement would also not establish validity under past climates or ice-sheet conditions.

No files were changed, no R process was started, and no data was obtained or saved. The prohibited directory was not opened. One attempted Figshare link was mistakenly a download endpoint; it failed without returning data. The working tree remains clean on `cover-contrasts`.

For Chris:

1. **Do you approve downloading only the original `albedo_IGBPdet.nc` from Figshare, listed as 400.46 MB?** I recommend yes; the smaller JRC alternative needs a verified size first.
2. **Should the first comparison cover only ET → ST using evergreen-needleleaf → deciduous-broadleaf forest, or all three exchanges using grassland as the named open-land analogue?** I recommend starting with ET → ST, all-days only, across the existing regions and months wherever common coverage exists.