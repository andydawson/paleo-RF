**The 25-bin structure is correct, but Andria’s table has two calendar errors. The slice names are approximate ages, not exact centres. The modern calibration pairs a broad historical reconstruction with one satellite decade; its bias has no established direction. Matching ice by name is a project approximation that should be stated explicitly.**

The paper is Dawson et al. (2025), *Holocene land cover change in North America: continental trends, regional drivers, and implications for vegetation–atmosphere feedbacks*, **Climate of the Past 21, 2031–2060**, DOI [10.5194/cp-21-2031-2025](https://doi.org/10.5194/cp-21-2031-2025).

Its definitions appear in **§2.2, pp. 2034–2035**, with the complete interval specification on **p. 2035**. They give this corrected table:

| Period, ka BP | Calendar years | Bin width |
|---|---|---|
| 11.7 to 0.7 | **About 9750 BCE to 1250 CE** | 500 years |
| 0.7 to 0.35 | 1250–1600 CE | 350 years |
| 0.35 to 0.1 | 1600–1850 CE | 250 years |
| 0.1 to −0.074 | **1850–2024 CE** | 174 years |

The bin edges and widths are published values; the oldest BCE conversion is calculated using the paper’s 1950 CE reference. [Dawson et al., p. 2035](https://cp.copernicus.org/articles/21/2031/2025/cp-21-2031-2025.pdf#page=5).

Thus:

- **10,250 BCE is about 500 years too early** for 11.7 ka BP.
- **2024 is explicitly printed in the paper.** A 2020 endpoint would instead be −0.070 ka BP and give 170 years.
- The youngest interval extends **back to 1850**, which is its older boundary.

There are **22** successive 500-year bins between 11.7 and 0.7 ka, followed by the three shorter bins: **25 altogether**.

The protocol supports this structure, including approximate names. **Trondman et al. (2015), p. 680, “Time windows”**, labels the recent windows approximately 50, 200 and 500 BP. **Githumbi et al. (2022), p. 1586, §2.2**, explicitly describes the full 25-window division adopted by PAGES LandCover6k. Its youngest endpoint is qualified by “present is the year of coring”; sufficient pollen counts motivate the broad windows. Therefore **2024 is Dawson’s stated endpoint, not a universal LandCover6k endpoint or evidence that every record reaches 2024**. References: Trondman et al., *Global Change Biology* 21, 676–697, DOI [10.1111/gcb.12737](https://doi.org/10.1111/gcb.12737); Githumbi et al., *Earth System Science Data* 14, 1581–1619, DOI [10.5194/essd-14-1581-2022](https://doi.org/10.5194/essd-14-1581-2022).

The correspondence between the pipeline’s names and those intervals is:

| Slice name, BP | Interval, BP: older → younger | Arithmetic midpoint, BP |
|---|---:|---:|
| 50 | 100 → −74 | 13 |
| 200 | 350 → 100 | 225 |
| 500 | 700 → 350 | 525 |
| Each name from 1,000 through 11,500, every 500 years | Name + 200 → name − 300 | Name − 50 |

These midpoint values are calculations from the published edges, not estimated sample ages. For example, **1000 means 1200–700 BP**, centred geometrically on **950 BP**; **11500 means 11700–11200 BP**, centred on **11450 BP**. The youngest interval’s geometric centre is **1937 CE**, but that does not establish when its pollen evidence is concentrated.

For the modern calibration, the necessary assumption is that the youngest reconstruction adequately represents the land-cover differences between places that produced **2000–2009 albedo**. [Script 1 selects the slice named 50](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/scripts/1_veg_lct_prep.R:63), and the [README identifies the satellite period](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/README.md:186).

Three points matter to the methods.

**First, this is not a uniform average of calendar years.** Dawson describes assigning samples by their mean calibrated ages, summing pollen counts by taxon within each record and interval, then averaging site reconstructions within grid cells. [Dawson et al., §2.2, p. 2035, DOI 10.5194/cp-21-2031-2025](https://doi.org/10.5194/cp-21-2031-2025).

Consequently, sample dates and counted pollen determine temporal representation within a record. The published description does not establish which decades dominate the youngest reconstruction. Nor does it establish that a record with more samples automatically gets greater weight between sites. **Overlap with the satellite decade does not, by itself, make the mismatch small.**

**Second, the interval includes substantial land-cover change.** Thompson, Carpenter, Cogbill and Foster’s *Four Centuries of Change in Northeastern United States Forests* documents a forest-cover minimum in the **mid-nineteenth century**, followed by agricultural abandonment and approximately a century of reforestation. Recovered forests also differed in composition. This is regional evidence, not a uniform history for North America. [Thompson et al. (2013), *PLOS ONE* 8, e72540, p. 1, DOI 10.1371/journal.pone.0072540](https://doi.org/10.1371/journal.pone.0072540).

**Third, pollen and satellite cover can differ even when their dates agree.** Serge et al. explain that young pine woodland can register as forest remotely before producing much pollen; birch and alder can produce pollen before reaching the satellite product’s **5 m** tree-height threshold. This is evidence for effects of stand development and differing vegetation definitions, rather than one universal “pollen lag” that can be corrected by shifting dates. [Serge et al. (2023), *Land* 12, 986, §4.1, p. 18, DOI 10.3390/land12050986](https://doi.org/10.3390/land12050986).

Published practice provides two particularly relevant precedents:

- **Pollen–satellite comparison:** Serge et al. used an additional modern window of core tops dated **1995–2005 CE**, compared with satellite tree cover for **2000**. This is vegetation validation, not albedo calibration, but directly supports matching the periods. [§2.3, p. 12, DOI 10.3390/land12050986](https://doi.org/10.3390/land12050986).
- **Vegetation–albedo relationships:** Duveiller, Hooker and Cescatti combined monthly MODIS climatologies for **2008–2012** with vegetation-cover fractions for **2010**. Their paper, *A dataset mapping the potential biophysical effects of vegetation cover change*, therefore supplies a contemporary, overlapping-period precedent. [*Scientific Data* 5, 180014 (2018), pp. 2–4, DOI 10.1038/sdata.2018.14](https://doi.org/10.1038/sdata.2018.14).

These precedents **do not validate this project’s broad historical pairing**. Retaining it is a project choice.

The likely mechanism can be described, but its net direction cannot. Forest removal commonly raises albedo, especially where it exposes snow. [Duveiller et al., p. 2, DOI 10.1038/sdata.2018.14](https://doi.org/10.1038/sdata.2018.14). **My inference:** where pollen mainly represents earlier clearance and MODIS observes later regrowth, the calibration pairs relatively open reconstructed cover with darker contemporary conditions. Other histories can give the opposite discrepancy. Spatial terms, nonlinear cover effects and compositional changes prevent a reliable prediction of the overall calibration or forcing bias. Calling it automatically an underestimate, overestimate, or attenuation towards zero would be unjustified.

For the paper, a sufficient statement would be:

> We calibrated the youngest pollen-based land-cover reconstruction against MODIS albedo for 2000–2009. This assumes that the reconstructed fractions adequately represent satellite-period spatial contrasts. Temporal pooling across land-use change, and differences associated with vegetation development and pollen production, may affect this relationship; their effect was not quantified.

For ice, **matching names associates a snapshot with an interval**. Dalton et al.’s NADI-1 paper specifies reconstructions from **25 to 1 ka at 0.5 kyr intervals** on **p. 4**. On **p. 15, §4**, it explicitly calls the margins “snapshots” and cautions against interpreting them as stepwise retreat. Reference: Dalton et al. (2023), *Deglaciation of the North American Ice Sheet Complex in calendar years based on a new comprehensive database of chronological data: NADI-1*, *Quaternary Science Reviews* 321, 108345, DOI [10.1016/j.quascirev.2023.108345](https://doi.org/10.1016/j.quascirev.2023.108345).

The consequences are straightforward:

- The regular name-matched ice snapshot is **50 years older than the pollen interval’s geometric centre**. That calculation does not establish the discrepancy from its actual sampled age or imply a known error direction.
- Keeping the native names is a simple convention, provided the methods explicitly distinguish ice snapshots from interval-based vegetation. Neither cited protocol prescribes this pairing.
- Carrying **1 ka ice forward to 500, 200 and 50 BP** is already the agreed comparison convention. It assumes constancy beyond NADI’s youngest reconstruction; those are not independently reconstructed younger ice states. [Recorded decision](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/docs/cc/2026-11-16_ice_redesign_simpler_astra_brief.md:20).
- Consecutive-slice differences compare reconstructed interval states. They should not be described as measured changes between exact dates or as annual rates.

The **11,500 → 12,000 alias needs particular attention**. [Script 7 changes the age before selecting the nearest ice polygon](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/scripts/7_plot_preds.R:91). It therefore changes the ice outline as well as the printed label. **12 ka lies outside the oldest pollen interval.** The consistent nominal label is 11.5 ka, with 11.2–11.7 ka stated as its interval; the corresponding coarse difference is 10–11.5 ka.

The inspected checkout contains the NADI design while the existing scripts still use older ice inputs. The assessment above concerns the stated NADI matching rule, not verification of a completed implementation.

No files were changed and no data files were downloaded.

Questions for Chris:

1. **For the final paper, should the existing historical-bin calibration be retained with the limitation stated above, or should acceptance depend on a comparison with vegetation representing the satellite period?**
2. **Should Andria be asked for an existing summary of sample ages and pollen-count totals within the 1850–2024 bin, to establish which decades actually contribute?**
3. **For the oldest figures, do you prefer the nominal label “11.5 ka” with interval bounds in the caption, or the explicit label “11.2–11.7 ka”?**