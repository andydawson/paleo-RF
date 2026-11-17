**Public monthly shortwave output covering 12–8 ka does exist. I did not verify an openly downloadable product that already isolates the North American ice surface—including its snow cover—and supplies monthly albedo by latitude or zone.** The main obstacle is separating ice from other surfaces within coarse model cells, especially along the retreating margins.

**My recommendation is a small, targeted request to Kapsch’s group in a later authorised task**, asking for ice-only monthly albedo or matched shortwave fluxes. TraCE-21ka offers a practical public-data fallback: an exactly identified **126.94 MB** flux-only pilot, or about **1.86 GB** for the full interval, before glacier masks. Neither should yet replace the agreed **0.68**, with **0.50 and 0.80** sensitivity cases.

The benefit to the paper would be a sourced seasonal and spatial sensitivity, with its model assumptions distinguished from observations. No files were changed, data files downloaded, or people contacted.

The archive findings are below. Sizes come from repository metadata; they are not estimates from downloaded files. “Unverified” means that the available catalogue did not establish the required product, not that the output cannot exist.

| Candidate | Public output, licence and resolution | Suitability and remaining work |
|---|---|---|
| **Kapsch et al. (2021), original release** | The linked WDCC deposits contain ice-sheet forcing: **2.53 GiB** with GLAC-1D boundaries and **2.55 GiB** with ICE-6G. Both are **CC BY 4.0**, with registered-user access. They have persistent handles rather than separate dataset DOIs. | The paper advertises surface mass balance and ocean forcing, **not a monthly albedo archive**; additional output is available on request. Crucial correction: these experiments use **prescribed ice sheets**, with a separate surface energy-balance calculation, rather than an interactively evolving ice sheet. Atmosphere resolution is about **3.75°**. Paper: §§2.2–2.3, pp. **1135–1137**; availability p. **1152**, DOI [10.5194/tc-15-1131-2021](https://doi.org/10.5194/tc-15-1131-2021). [GLAC-1D deposit](https://www.wdc-climate.de/ui/entry?acronym=DKRZ_LTA_989_ds00006), [ICE-6G deposit](https://www.wdc-climate.de/ui/entry?acronym=DKRZ_LTA_989_ds00007). |
| **Later MPI prescribed-ice releases** | WDCC now lists **monthly `rsds` and `rsus`**—downward and upward surface shortwave—with full target-period coverage, approximately **3.75°** atmosphere, **CC BY 4.0**. For the inspected GLAC-1D member, the complete variable collections are **2.77 and 2.68 GiB** respectively. Dataset DOI [10.26050/WDCC/PMMXMCRTDGP111](https://www.wdc-climate.de/ui/entry?acronym=PMMXMCRTDGP111). | A genuine public route to **grid-cell albedo**. It is not established that these atmospheric fluxes reproduce the separate ice energy-balance model’s albedo. Glacier fractions are indexed, but I could not establish a complete, individually priced file set or ice-only radiation output. Reduction is straightforward after that distinction is resolved. [Variable catalogue](https://www.wdc-climate.de/ui/q?hierarchy_steps_ss=PMMXMCRTDGP111&page=0&query=%2A%3A%2A&rows=100). |
| **MPI interactive ice-sheet simulations, published 2025** | A newer, genuinely coupled MPI-ESM–mPISM–VILMA archive also covers the interval. For inspected member D2.3: monthly **`rsds` 2.76 GiB**, **`rsus` 2.69 GiB**, and **`sftgif` land-ice fraction 182.79 MiB**; together **5.63 GiB** for the complete collections. **CC BY 4.0**. Atmosphere approximately **3.75°**; northern ice model **10 km**, according to archive metadata. Dataset DOI [10.26050/WDCC/PMMXMC1TDIr1162](https://www.wdc-climate.de/ui/entry?acronym=PMMXMC1TDIr1162). | Stronger public candidate because a changing glacier fraction is explicitly listed. But a fraction does **not** separate ice radiation from mixed-cell radiation. The fine ice grid does not make atmospheric albedo a 10 km product. Individual filenames and target-period subset sizes remained unverified. [Variable catalogue](https://www.wdc-climate.de/ui/q?hierarchy_steps_ss=PMMXMC1TDIr1162&page=0&query=%2A%3A%2A&rows=100); associated paper DOI [10.5194/cp-21-719-2025](https://doi.org/10.5194/cp-21-719-2025). |
| **TraCE-21ka, CCSM3** | NCAR GDEX, DOI **10.5065/CXB5-TV56**, **CC BY 4.0**. Monthly atmospheric **`FSDS`** downward and **`FSNS`** net absorbed shortwave cover the full interval. T31 atmosphere: **48 × 96 cells**, approximately **3.75°**. Evolving prescribed ICE-5G boundaries. [Archive](https://gdex.ucar.edu/datasets/d651050/), [NCAR grid documentation](https://www.cesm.ucar.edu/working-groups/paleo/simulations/trace-21ka/t31-t85). | **Best verified filenames and manageable download.** Flux arithmetic is easy; obtaining the matching model-native glacier masks and identifying genuinely ice-only cells remains unresolved. NCAR explicitly identifies `ICEFRAC` as **sea ice**, so that field cannot supply the Laurentide mask. |
| **iTRACE / iCESM** | Main GDEX release: DOI **10.26024/B290-AN76**, **CC BY 4.0**, monthly atmosphere and land output; nominally **2°** atmosphere/land. The principal public deglacial segment is **20–11 ka**. [Archive](https://gdex.ucar.edu/datasets/d651022/), [experiment description](https://www.cesm.ucar.edu/working-groups/paleo/simulations/cesm1-itrace). | It does not by itself cover 11–8 ka. A linked Holocene release includes `FSDS`/`FSNS` in seasonal/annual decadal output: `iTRACE_transient_decadal.rar`, **2.4 GB**. It also offers `PMIP4_iTRACE_4CO2_mon_climatology.rar`, **1.1 GB**, whose relevant ages and variables I could not verify. Its licence was not exposed by the page reader. **Do not assume the monthly bundle supplies the missing sequence.** [Zenodo record, DOI 10.5281/zenodo.14523124](https://zenodo.org/records/14523124). |

The older MPI deposits are therefore not an obvious first download merely because Kapsch’s paper models albedo. The newer radiation archives are more promising, but they answer a different question unless their surface representation is checked.

The other suggested model families yielded these results:

| Candidate | What the public evidence establishes | Assessment |
|---|---|---|
| **PMIP4 deglaciation intercomparison, including FAMOUS and HadCM3** | Leeds DOI **10.5518/1398**, **CC BY 4.0**, supplies selected climate fields for **21–15 ka**, regridded to **1°**. `FAMOUS.zip` and `HadCM3_routed.zip` are each **3 GB**. Declared variables exclude albedo and shortwave fluxes. [Repository](https://archive.researchdata.leeds.ac.uk/1245/). | Wrong period and variables for this task. **Do not download these bundles.** PMIP participation alone does not establish a public monthly albedo archive. |
| **FAMOUS QUEST glacial-cycle runs** | CEDA lists **156 GB** across roughly **1,080 files**, spanning the last glacial cycle; registered-user access. Permitted use is **“Unstated”**, and no variable inventory is supplied. The atmosphere is **5° latitude × 7.5° longitude**: Smith & Gregory, model description, PDF p. **6**, DOI [10.1007/s00382-011-1283-y](https://doi.org/10.1007/s00382-011-1283-y). [CEDA catalogue](https://catalogue.ceda.ac.uk/uuid/a43dcfaccfae4824ab9ab2b572703e72/). | Monthly albedo, ice separation, filenames and individual sizes remain unverified. Older FAMOUS should not be assumed to have the later FAMOUS-ice surface capabilities. |
| **Other HadCM3 deglacial runs** | PMIP directs users towards participating institutes and Bristol BRIDGE. The relevant Bristol pages were inaccessible during this check. [PMIP guidance](https://pmip4.lsce.ipsl.fr/doku.php/wg:ptof:models). | No verified monthly 12–8 ka albedo/flux manifest, licence or sizes. A small author-supplied subset would be preferable to a broad archive request. |
| **LOVECLIM DG_ns** | Historically public through APDRC; the linked documentation now returned 404. The published availability statement is Lowry et al., p. **211**, DOI [10.5194/cp-15-189-2019](https://doi.org/10.5194/cp-15-189-2019). | Present availability, monthly radiation variables, ice-only separation, licence and file sizes could not be established. |
| **LOVECLIM 784K** | A live ICCP catalogue lists **`alb` surface albedo (%)** and **`ssr` surface solar radiation**, but as **100-year averages**; atmosphere collection **4.2 GB**. No dataset DOI is assigned. [Variable catalogue](https://climatedata.ibs.re.kr/data/loveclim-784k/loveclim-784k-atm). | These averages cannot provide a seasonal cycle. ICCP’s licence wording explicitly imposes noncommercial use, despite inconsistent Creative Commons naming. |
| **CESM1.2 three-million-year transient run** | ICCP DOI **10.22741/iccp.20230001** has separate January–December catalogues, sampled at **1,000-year intervals**. [Repository](https://climatedata.ibs.re.kr/data/3ma-transient-climate-simulation). | A worthwhile lead, but the variable-level service was inaccessible. Albedo/shortwave fields, ice masks, grid, filenames and sizes were not verified. Not yet a concrete download recommendation. |
| **Gandy’s FAMOUS-ice output** | Mendeley DOI **10.17632/8kswwpnjyz.1**, **CC BY 4.0**, contains one selected LGM simulation. [Repository](https://data.mendeley.com/datasets/8kswwpnjyz/1). | Useful model evidence, but a fixed LGM experiment does not supply 12–8 ka. Filenames and sizes were not exposed by the rendered catalogue. |

**The mixed-cell problem is substantive, not merely missing documentation.** Koepnick, Fu and Tziperman’s accessible preprint explicitly says that its iTRACE output cannot separate ice and ice-free land fluxes in mixed margin cells; it therefore also examines fully ice-covered cells. See **p. 6, §2.4**, DOI [10.5194/egusphere-2024-1998](https://egusphere.copernicus.org/preprints/2024/egusphere-2024-1998/egusphere-2024-1998.pdf). Their final paper appeared in September 2026, DOI [10.1029/2025PA005366](https://agupubs.onlinelibrary.wiley.com/doi/abs/10.1029/2025PA005366), but I could not inspect its full text, so I am identifying this evidence as coming from the preprint.

Keeping only fully ice-covered cells is possible in principle, once the correct masks are obtained. **It preferentially removes the margins whose summer albedo matters here.** Applying the resulting interior cycle to disappearing ice would be a project assumption, not a recovered ablation-zone climatology.

I found no published table that avoids this model-output work:

| Published evidence | What it supplies |
|---|---|
| **Willeit & Ganopolski (2018), “The importance of snow albedo for ice sheet evolution over the last glacial cycle”** | **Fig. 6, p. 701:** a full seasonal curve at **one southern Laurentide-margin location at 15 ka**. **Fig. 5, p. 700:** a summer spatial map. Neither supplies target-period latitude-band means. Output is available from the authors on request, p. **705**. DOI [10.5194/cp-14-697-2018](https://doi.org/10.5194/cp-14-697-2018). |
| **Carlson et al. (2009), “Surface-melt driven Laurentide Ice Sheet retreat during the early Holocene”** | Relevant **9 ka** modelling, but snow/ice albedos are model parameters, not a twelve-month zone table: **p. 1, §2**. DOI [10.1029/2009GL040948](https://doi.org/10.1029/2009GL040948). |
| **Gandy et al. (2023)** | LGM diagnostics; **Fig. 5, p. 10**, explicitly uses **30-year July averages**. DOI [10.1029/2023JF007250](https://doi.org/10.1029/2023JF007250). |
| **Bradley et al. (2024)** | Spatial and ablation/accumulation contrasts for **21 ka summer**, not all months: **§4.2, pp. 221–223; Fig. 8**. DOI [10.5194/cp-20-211-2024](https://doi.org/10.5194/cp-20-211-2024). |
| **Wang & Zender (2010)** | The Greenland monthly series already identified: **Table 2, p. 9**. Latitude-band analysis appears in **Fig. 3, p. 7**, but there is no transferable North American deglacial monthly-by-band table. DOI [10.1029/2009JF001436](https://doi.org/10.1029/2009JF001436). |

Willeit and Ganopolski are consequently a sensible second contact route if Kapsch’s group cannot supply suitable output.

For a later public-data pilot, the following two TraCE files are exactly identified:

| Filename | Catalogue size |
|---|---:|
| `trace.16.12000-11701BP.cam2.h0.FSDS.1000101-1030012.nc` | 63.47 MB |
| `trace.16.12000-11701BP.cam2.h0.FSNS.1000101-1030012.nc` | 63.47 MB |

Total: **126.94 MB**, covering **12.000–11.701 ka**. This is a flux diagnostic, excluding the glacier mask. [NCAR file catalogue](https://gdex.ucar.edu/datasets/d651050/filelist/112/?fl=glade&page=1).

For completeness, the full-interval filenames follow `trace.SEG.cam2.h0.V.DATES.nc`, with **two files per row**, `V=FSDS` and `V=FSNS`:

| `SEG` | `DATES` | MB per file |
|---|---|---:|
| `16.12000-11701BP` | `1000101-1030012` | 63.47 |
| `17.11700-11301BP` | `1030101-1070012` | 84.62 |
| `18.11300-10801BP` | `1070101-1120012` | 105.78 |
| `19.10800-10201BP` | `1120101-1180012` | 126.93 |
| `20.10200-09701BP` | `1180101-1230012` | 105.78 |
| `21.09700-09201BP` | `1230101-1280012` | 105.78 |
| `22.09200-08701BP` | `1280101-1330012` | 105.78 |
| `23.08700-08501BP` | `1330101-1350012` | 42.32 |
| `24.08500-08001BP` | `1350101-1400012` | 105.78 |
| `25.08000-07601BP` | `1400101-1440012` | 84.62 |

The rounded catalogue sizes sum to **1,861.72 MB**, excluding masks. The last segment is needed to include **8.000 ka**. [Catalogue evidence](https://gdex.ucar.edu/datasets/d651050/filelist/112/?fl=glade&page=1).

The simplest useful request to Kapsch’s group would be:

> Monthly broadband albedo of the ice-covered surface, including overlying snow, over North America for 12–8 ka; preferably accompanied by matched upward and downward shortwave fluxes, ice fractions/areas, coordinates, calendar and age definitions. Please identify whether these are ice-surface or whole-cell quantities, how monthly albedo was averaged, and whether the subset and derived tables may be redistributed publicly.

A small gridded subset would preserve the option to inspect margins before reducing it. If only the separate energy-balance calculation is appropriate, ask whether its monthly albedo was retained. That availability cannot be inferred from the archived mass balance. Filenames, sizes and reuse terms would have to accompany the response; I cannot honestly price that download now.

For the pipeline, I recommend an initial table with **one row per month, native model latitude band and existing project time slice**, rather than introducing ablation/accumulation zones immediately. Zone-specific values would additionally require a defensible, changing zone map. Native latitude bands, averaging windows and transfer to the project’s ice reconstruction are **project choices**, not a published Laurentide prescription.

The reduction has published precedents:

- Compute effective albedo from matched surface fluxes: `rsus/rsds`, or `1 − FSNS/FSDS`. Averaging fluxes before forming a climatological ratio is explicitly described by **Loeb et al. (2019), “Decomposing Shortwave Top-of-Atmosphere and Surface Radiative Flux Variations in Terms of Surface and Atmospheric Contributions,” p. 5005**, DOI [10.1175/JCLI-D-18-0826.1](https://doi.org/10.1175/JCLI-D-18-0826.1).
- For regional aggregation, **He, Liang and Song (2014), “Analysis of global land surface albedo climatology and spatial-temporal variation during 1981–2010 from multiple satellite products,” p. 10285, §2.3, Eqs. 1–2**, uses area and incoming-radiation weighting. DOI [10.1002/2014JD021667](https://doi.org/10.1002/2014JD021667).

For **already separated ice fluxes**, that gives:

\[
\alpha_{\mathrm{band,month}}
=
\frac{\sum \Delta t\,A_{\mathrm{ice}}\,SW_{\uparrow}}
     {\sum \Delta t\,A_{\mathrm{ice}}\,SW_{\downarrow}} .
\]

Use the matched ice area at each time before averaging. This preserves the source model’s reflected/incident energy ratio; transferring it to the project’s geometry and radiative kernels remains an assumption. It cannot extract ice albedo from mixed-cell fluxes. Polar-night zero/zero entries must remain flagged as undefined, so the deliverable is **twelve month records**, not necessarily twelve recoverable numerical values.

Implementation would be modest once suitable data exist: one preparation routine and a lookup using latitude, month and slice. However, this is **not just a replacement CSV**. The current lookup is month-only in [script 7a](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/scripts/7a_alb_diff_full.R:106), and the partial-ice difference arithmetic in [R/differences.R](/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice/R/differences.R:72) assumes unchanged ice albedo between slices. Slice-varying values require accounting for albedo change on ice that remains covered. That would need scientific review and the repository’s normal verification before use.

Two choices remain for Chris, for a later task; this read-only brief authorises neither action:

1. **Should the next step be an enquiry to Kapsch’s group for a small, publicly reusable monthly ice-only subset covering North America at 12–8 ka?** I recommend this before downloading the large archives.
2. **If you prefer to continue without author contact, should a later task download the two named TraCE files, totalling 126.94 MB, solely for a flux diagnostic?** The matching glacier masks and margin problem would still need resolution before using the results as ice-sheet albedo.