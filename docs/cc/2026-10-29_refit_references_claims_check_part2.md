# Refit references: full-text claim check, part 2 (Jia 2022, Wang 2018, Barnes and Roy 2010 and 2008, Ghimire 2014)

By the claim-checker role (Claude), 29 October 2026, from the published versions.

---

# Adversarial reading: five cited papers in the refit plan and review (29 October 2026)

Scope: references.md items 1 (Jia et al. 2022), 2 (Wang et al. 2018), 3 (Barnes and Roy 2010), 4 (Barnes and Roy 2008), 6 (Ghimire et al. 2014). Citing sentences were taken from the plan (`astra_refit/result.md` lines 20, 119, 120, 226), the review (`astra_refit/fable_review.md` line 35, item 12), the literature note (`wt-feature/docs/cc/2026-10-16_snow_free_estimate_literature_fable.md` lines 5, 14, 15, 17, 34, 35, 40, 44, 52) and the build tool header (`wt-feature/tools/prepare_bluesky_albedo.R` lines 19-23, 32-36, 47-48, 53-54). All five full texts were read in full from the pdftotext files beside the PDFs; two PDF pages were read as images where the text extraction lost an equation sign or a figure legend. The sources were read before the context documents.

File identity (step 1): all five files are the cited works. First-page title, authors, year and journal match the citation keys: Jia, Wang, Liang, Peng, Yu, JGR Atmospheres 127, e2021JD035987 (2022); Wang, Schaaf, Sun, Shuai, Roman, RSE 207, 50-64 (2018); Barnes and Roy, JGR 115, G04033 (2010); Barnes and Roy, GRL 35, L09706 (2008); Ghimire, Williams, Masek, Gao, Wang, Schaaf, He, GRL 41, 9087-9096 (2014). The copies are the published versions (Wiley and Elsevier typesetting).

---

## Headline answer: are Barnes and Roy 2010 and Ghimire et al. 2014 precedents for the snow-share mix?

Both papers are genuine precedents for the **form** of the mix: separate snow-covered and snow-free MODIS albedo, recombined linearly per month as albedo = f_snow x snow albedo + (1 - f_snow) x snow-free albedo, with a modern snow climatology held fixed across the period studied. **Neither uses the share of snow-flagged MCD43 retrievals as f_snow.** Both take f_snow from the separate MODIS snow-cover product (MOD10CM, the monthly 0.05 degree climate-modelling-grid snow cover): Barnes and Roy per ecoregion and calendar month (2004-2008 mean), Ghimire per 1 degree cell and month (2001-2011 mean, with CCSM4 snow cover as an alternative). Barnes and Roy 2010 report a snow-free-only case beside the snow-inclusive one (f_snow set to zero); Ghimire et al. 2014 do not. Neither fits a statistical model to albedo: Barnes and Roy use per-class, per-ecoregion, per-month **medians** of pixel retrievals; Ghimire use Gao et al. (2014) look-up maps built from monthly median composites. Details and quotes follow under items 3 and 6.

Wording the sources support, if the plan wants a one-sentence precedent: "Barnes and Roy (2010, eq. 3, section 4.5) and Ghimire et al. (2014, eq. 1) combine snow-covered and snow-free MODIS albedo linearly with a monthly snow-cover fraction taken from the MODIS snow-cover product (MOD10CM); Barnes and Roy also report the snow-free case (fraction set to zero). Taking the fraction from the share of snow-flagged MCD43 retrievals, per cell, is this project's own choice and has no precedent in either paper."

---

## Item 1. Jia, Wang, Liang, Peng, Yu (2022), JGR Atmospheres. Key: jia2022

### Claim 1a (plan, result.md line 20)
Sentence: "The 75° screen, separate actual and snow-free climatologies, and explicit reporting of winter gaps have direct precedent in Jia ... (2022) ... §§2.2-3.2. Their averaging and diffuse-fraction construction differ from this project's; the approved build's choices must be described accurately rather than attributed wholesale to that paper."

Verdict: **SUPPORTED**.

Quotes:
- p. 6, section 2.2.2: "Pixels with a large SZA (>75°) were also eliminated to maintain the input data quality (Liu et al., 2009). The snow-free albedo climatology was obtained by ignoring all snow pixels marked by MCD43A2."
- p. 3, section 2.1.1: "To generate actual and snow-free albedo climatology data, the corresponding snow mark from MCD43A2 C06 was used for the classification of snow or snow-free albedo pixels."
- p. 2, section 1: "(a) Global actual (all historical records including the snow albedo) and snow-free daily blue-sky albedo climatology datasets were generated and published".
- p. 9, section 3.2: "The snow-free map in winter left blanks over high latitudes owing to a lack of available valid snow-free albedo values for calculation." and "in winter the observations over high latitudes are limited, contributing to a possibly larger uncertainty"; observation counts per pixel are mapped (Figure 5, p. 10) and "attached to the published files" (p. 9).

Element by element:
- 75 degree screen: agrees. Applied per daily 500 m pixel before averaging across years. The zenith angle is the MCD43A2 layer (Table 1, p. 3: "MCD43A2: snow mark, SZA"). The paper does not say "noon"; that the MCD43A2 zenith is the local-solar-noon value is product documentation, not a statement in the paper.
- Separate actual and snow-free climatologies: agrees. "Actual" means all retrievals including snow days; there is no snow-only climatology and no snow-fraction weighting in Jia et al.
- Explicit winter gaps: agrees (section 3.2, Figure 5).
- Section numbers: the screen and the snow-free construction are in 2.2.2 (p. 6), the data in 2.1.1 (p. 3), the gaps in 3.2 (pp. 8-9). "2.2-3.2" is correct as a span; 2.1.1 could be added.
- "Averaging and diffuse-fraction construction differ": agrees. Jia average each day-of-year over 2001-2020 after discarding the maximum and minimum (p. 6); the diffuse ratio comes from a look-up table of zenith angle and MODIS MOD08 aerosol optical depth (p. 6, eq. 1), not from ERA5.
- Qualifier the plan does not mention: I found no statement in Jia et al. that retrievals were restricted by inversion quality (full versus magnitude); a search for "quality" and "inversion" returns only the sentence above and site quality control. The precedent is for the 75 degree rule, not for "75 degrees plus full inversions only".

### Claim 1b (build header, lines 35-36)
Sentence: "Low sun: noon solar zenith at most 75 degrees, as in the published climatology of Jia et al. 2022".
Verdict: **SUPPORTED** (quote as above, p. 6). "At most 75" is consistent with ">75° eliminated". "Noon" is not the paper's word (see 1a).

### Claim 1c (build header, lines 53-54)
Sentence: "Jia et al. 2022 likewise average each date over the years, but also drop the largest and smallest values".
Verdict: **SUPPORTED**. p. 6, section 2.2.2: "The daily climatology was calculated by averaging available albedo values of each DOY from 2001 to 2020, separately. After sorting the available samples, the maximum and minimum ones were neglected to constrain the impact of anomalous values".

### Claim 1d (review item 12, line 35)
"the project's own documents already support Jia et al. 2022 (75-degree cut, actual and snow-free climatologies)". Consistent with the source. **SUPPORTED**.

Available: full text, 19 pages. Not available: Jia's Zenodo data documentation.

---

## Item 2. Wang, Schaaf, Sun, Shuai, Roman (2018), Remote Sensing of Environment. Key: wang2018

### Claim 2a (plan, result.md line 119)
Sentence: "Wang ... (2018) ... distinguishes full from backup magnitude inversions and validates results across quality classes. This supports the quality comparison, without guaranteeing every low-quality observation. Daily products use overlapping 16-day windows, so day counts are not independent sample sizes."

Verdict: **SUPPORTED** (the final "so day counts are not independent sample sizes" is the plan's inference; the paper does not say it, but the premise is the paper's).

Quotes:
- p. 51, section 1: "A backup algorithm (or magnitude inversion), using available observations with an a priori BRDF database, is applied if a high quality full inversion BRDF cannot be retrieved ... it is always flagged as a poor quality retrieval."
- p. 59, Table 5 ("The accuracy of Collection V006 MCD43 albedo products") has rows All quality, Full inversion, Magnitude inversion, Snow-free, Snow, by land type; p. 60, section 3.2: "The RMSEs and biases for the high quality full inversions over all the land types are < 0.0204 and within ± 0.0102 respectively and are < 0.0412 and within ± 0.0130 respectively for the poorer quality magnitude inversions."
- p. 50, abstract: "The Collection V006 product still utilizes the 16-days of directional reflectances surrounding the day of interest (9th day) to retrieve the model of the surface anisotropy but assigns the highest temporal weight to the day of interest"; p. 57, section 3.1: "the DOY 009 BRDF is retrieved by using data from DOY 001 to 016".

Element by element:
- Full versus magnitude: agrees (also section 2.1.3, p. 53).
- Validation across quality classes: agrees; 21 tower sites (Table 1), blue-sky albedo, both inversions used (p. 55: "Both full and magnitude inversions are used for this evaluation."). Qualifiers dropped: p. 53, "users of the MCD43 V006 product are advised to use these magnitude (backup) results with caution, as they are considered lower quality results"; p. 62, "The ground sites for albedo validation in this study are mainly distributed over Mid-Latitude regions".
- Overlapping 16-day windows: "overlapping" is not the paper's word, but daily retrievals from 16-day windows entail it. The paper adds that if no clear-sky observation exists on the day of interest the retrieval is made from the surrounding days with lowered quality (pp. 52-53, p. 57).
- Observation the build may want: p. 54, section 2.1.4: "The retrieval quality is also lowered if the day of interest has no valid observation or the solar zenith angle is larger than 70°." The build header cites NASA's validation page for its 70 degree comparison; Wang et al. state the 70 degree rule inside the product's own quality flag. Section 2.1.5 (p. 54): observations with zenith "< 80°" enter retrievals.

### Claim 2b (build header, lines 19-23)
Sentence: "daily collection 6: Wang et al. 2018 ... Each daily value comes from the observations of a 16-day window centred on that day."
Verdict: **PARTIAL**. The window is days 1-16 for day of interest 9 (p. 50 "9th day"; p. 57 quote above), i.e. eight days before and seven after. Suggested: "a 16-day window around that day (the ninth day of sixteen)".

### Claim 2c (build header, lines 32-34)
Sentence: "any processed retrieval (0-7) is kept for comparison (Wang et al. 2018 validate all qualities)".
Verdict: **SUPPORTED** (Table 5 "All quality" row; p. 55). The "(0-7)" coding is the build's own; Wang describe the shortwave mandatory QA as "0" if all bands are full inversions and "1" otherwise (p. 54).

### Claim 2d (build header, lines 47-48)
Sentence: "Snow: the MCD43A2 snow flag of each day (Wang et al. 2018)".
Verdict: **SUPPORTED** for the day-of-interest snow status. p. 53, section 2.1.2: "the snow or snow-free retrieval is determined by the snow status of the day of interest ... only snow-covered observations from the surrounding period are used for the BRDF/albedo retrieval of that target day". That the status is stored as a flag in MCD43A2 is product documentation (the paper names MCD43A2 as the quality product, p. 53-54).

### Claim 2e (literature note, line 34)
"v006 uses all Terra and Aqua clear observations, improving high-latitude inversions".
Verdict: **SUPPORTED**. p. 50, abstract: "All valid clear sky observations from Terra and Aqua are now used for each retrieval, which improves the inversion quality. This is especially true at high latitudes".

### Claim 2f (literature note, line 52, the "from memory" item)
"That the inversion then uses only observations matching that status, so a flagged retrieval is a pure snow or pure snow-free retrieval: from memory, to be checked".
Verdict: **PARTIAL**, now checked. Confirmed for snow days (p. 53 quote in 2d). The converse for snow-free days (that snow observations are excluded) is not stated explicitly in Wang et al.; it is implied by the Collection 5 description on p. 53 ("if the majority was snow-covered then only snow observations were used") but not written for V006 snow-free days. Suggested wording: "a snow-flagged retrieval uses only snow-covered observations (Wang et al. 2018, section 2.1.2); the paper does not state the converse for snow-free days."

Available: full text, pp. 50-64. Table 1 (site list) is garbled by the text extraction but not needed.

---

## Item 3. Barnes and Roy (2010), JGR 115, G04033. Key: barnes2010

### What the paper does (the specifics asked for)
- Split: MODIS Collection 5 BRDF/Albedo 16-day 500 m product (produced every 8 days), broadband 0.3-5.0 micron **white-sky** albedo, 18 February 2000 to 31 March 2009, full inversions only. p. 2, paragraph 7: "per-pixel product quality assessment information that describe the processing method and whether a snow or snow-free albedo was retrieved are used. Only good quality (full BRDF inversion), nonfill, snow, and snow-free albedo values are used." The paper does not name "MCD43A2"; it is the Collection 5 product's own snow/snow-free retrieval indicator. p. 3, paragraph 10: 60,423 snow and 1,307,902 snow-free values, extracted at class centroids of Landsat subsets eroded by 240 m.
- Statistic: median per land-cover class, ecoregion and month over 9 years (eq. 1, p. 3). p. 3, paragraph 11: "The median rather than the mean value was taken as it is less sensitive to infrequent but anomalously low or high MODIS albedo values associated with residual shadow or cloud contamination". Fallback (eq. 2, pp. 3-4) where fewer than 3 valid values exist: the median over the 58 ecoregions of the ecoregion medians.
- Snow fraction: a separate product. p. 2, paragraph 8: "Snow cover data are provided by the MODIS Collection 5 monthly average snow cover 0.05° climate modeling grid product (MOD10CM) ... are used to compute ecoregion monthly snow climatology, i.e., the mean fractional snow cover (0-1) for each calendar month" (January 2004 to December 2008). Per ecoregion and calendar month, not per cell; applied to both 1973 and 2000.
- Combination: eq. (3), p. 4 (checked on the page image; the minus sign is lost in the text extraction): alpha_i,ecoregion,month = (1 - f_snow,month,ecoregion) x median snow-free albedo + f_snow,month,ecoregion x median snow albedo, "following the approach of Roesch et al. [2002]"; "f_snow, month, ecoregion is the monthly snow fraction [0-1] derived from the MODIS snow product". Then eq. (4): ecoregion albedo = sum over classes of class proportion x class albedo.
- Resolution: ecoregion-month (58 Omernik level III ecoregions, 14,458 to 346,883 km2; p. 2); forcing from 2.5 degree ERA-40 surface solar radiation per ecoregion (eq. 9, p. 4), surface forcing, not TOA.
- Snow-free-only case: yes. p. 9, paragraph 35, section 4.5: "The surface radiative forcing modeling snow-free conditions was computed by setting the monthly snow fraction (fsnow, month, ecoregion) in equation (3) to zero." p. 10, paragraph 38: "We estimated a net CONUS surface radiative forcing of 0.029 Wm-2 due to LCLU albedo change from 1973 to 2000 when snow is modeled (section 4.4) and 0.031 Wm-2 when snow is not modeled." Figure 8 (p. 11) is the scatter of the two; Sierra Nevada -0.367 versus -0.160 W m-2 (p. 10, paragraph 37).
- Share of snow-flagged retrievals as f_snow: **no**. Separate product (MOD10CM).
- Winter months (literature note line 35, "not verified"): no solar-zenith screen and no month exclusion is described. Gaps are filled by the eq. (2) fallback. p. 3, paragraph 12: "there were insufficient MODIS snow and snow-free albedos to estimate (1). This typically occurred in ecoregions with small areal LCLU class proportions (<0.005), in persistently cloudy months, and for the snow albedo in snow-free ecoregions and summer months." Interannual variability was computed for snow-free data only and for 45 of 58 ecoregions (p. 4, paragraph 16: "Only snow-free MODIS albedo data were considered as many ecoregions had insufficient snow albedo LCLU class values in each month to compute MAD statistics.").

### Claim 3a (references.md item 3)
Sentence: "derives mean monthly snow and snow-free MODIS albedo per land-cover class and combines them with snow data (how weighted: snow-cover fraction from MOD10?); compares snow-inclusive and snow-free forcing (section 4.5)."
Verdict: **PARTIAL**. Everything is supported except "mean": the paper uses the **median** (p. 1, paragraph 3: "Median monthly snow and snow-free albedo climatology values are derived from 9 years of Moderate Resolution Imaging Spectroradiometer (MODIS) albedo product data for 10 LCLU classes in 58 ecoregions."; p. 3, paragraph 11, quoted above). "Mean monthly" occurs in the paper only for incoming solar radiation. The open question is answered: weighted by the MOD10CM monthly mean snow fraction per ecoregion (eq. 3). Section 4.5 is "Snow Sensitivity Analysis of Surface Radiative Forcing Due to LCLU Albedo Change From 1973 to 2000" (pp. 9-10). Suggested wording: "derives median monthly snow and snow-free MODIS white-sky albedo per land-cover class, ecoregion and month, combines them linearly with the MOD10CM monthly snow fraction per ecoregion (eq. 3), and compares snow-inclusive with snow-free (fraction set to zero) forcing (section 4.5)."

### Claim 3b (plan, result.md line 120)
Sentence: "Barnes and Roy (2010) ... §4.5, compares snow-inclusive and snow-free forcing. Their method uses an explicit snow mixture, not two GAM refits."
Verdict: **SUPPORTED** (quotes above). One precision: the mixture equation is eq. (3) in section 3.1 (p. 4); section 4.5 applies it with the fraction set to zero. The sentence that follows in the plan ("Our result must therefore be called sensitivity to the calibration's snow treatment") is the plan's own reasoning, not a claim about the paper.

### Claim 3c (literature note, line 15)
Quotations attributed to the abstract: "satellite-derived land cover land use, snow and albedo data" (abstract, p. 1: agrees); "Snow exacerbated both negative and positive forcing for LCLU transitions between snow-hiding and snow-revealing LCLU classes" (abstract, p. 1: agrees verbatim); "highly sensitive to snow-free inter-annual albedo variability" with 1.6-4.3 per cent (abstract, p. 1: agrees); "mean monthly broadband MODIS snow and snow-free albedo values were derived" (**not in the published paper**; the published text says "Median monthly ..." as quoted in 3a; the phrase may come from the SDSU repository abstract the note cites, which I did not see). The "from memory" item ("I believe by MODIS MOD10 snow-cover fraction, with a snow-free-only case for comparison") is **confirmed**.
Verdict for the line: **PARTIAL** (one misquote; correct "mean" to "median").

### Claim 3d (literature note, lines 5 and 44)
Line 5: separating MCD43 retrievals into snow-free and snow-covered with the snow flag and building per-land-cover statistics "is the normal practice (... Barnes and Roy 2010 ...)". **SUPPORTED** in substance (p. 2, paragraph 7); the flag is the Collection 5 product's own retrieval indicator, and the statistics are medians per class, ecoregion and month.
Line 44: "The established simple alternative, which all three forcing papers above use: ... combine as albedo = f_snow x albedo_snow + (1 - f_snow) x albedo_snow_free, with f_snow the modern monthly snow-cover fraction per cell (MODIS MOD10 snow cover, or the share of snow-flagged retrievals in the all-days stream)." For Barnes and Roy 2010: the mix form is exactly eq. (3) and f_snow is MOD10CM, **SUPPORTED**; "per cell" is per ecoregion in this paper; "or the share of snow-flagged retrievals" has **no precedent** in this paper (nor in Ghimire; Jiao 2017 not checked). Verdict for the line: **PARTIAL**. Suggested: "... with f_snow the modern monthly MOD10 snow-cover fraction (per ecoregion in Barnes and Roy 2010, per 1 degree cell in Ghimire et al. 2014); using the share of snow-flagged retrievals instead would be our own variant."

### Claim 3e (literature note, line 40)
"Barnes and Roy 2010 show that snow-free interannual variability alone changes the forcing materially (abstract)".
Verdict: **SUPPORTED**. Abstract (p. 1) as quoted in 3c; p. 11, paragraph 41: "we estimate a snow-free net surface radiative forcing of 0.043 Wm-2 due to LCLU albedo change from 1973 to 2000 equation (11) with an error of 0.084 Wm-2". (The paper gives 0.043 in paragraph 41 and 0.044 in paragraph 46; an internal inconsistency to avoid quoting without a page.)

### Claim 3f (review item 12)
"Barnes and Roy 2010 'section 4.5, explicit snow mixture' ... unverified". Now verified as in 3b.

Available: full text, 14 pages, plus page 4 as an image for eq. (3).

---

## Item 4. Barnes and Roy (2008), GRL 35, L09706. Key: barnes2008

### Claim 4a (references.md item 4; literature note lines 5 and 14)
Sentence: "forcing from MODIS snow-free albedo only" / "Explicitly 'MODIS snow-free broadband albedo values'; no snow."
Verdict: **SUPPORTED**.
Quotes: p. 1, abstract: "Moderate Resolution Imaging Spectroradiometer (MODIS) snow-free broadband albedo values are derived from Landsat LCLU classification maps located using a stratified random sampling methodology"; p. 1, paragraph 4: "Three years of 500 m (0.3-5.0 mm) snow-free broadband white sky albedo data (February 18th 2000 to February 18th 2003) are used to capture inter-annual albedo variability."; p. 2, paragraph 6: "a_i is the mean monthly snow-free broadband white sky MODIS albedo derived from the three years of MODIS data"; p. 5, paragraph 14: "This work did not consider snow, which may have a significant land cover dependent albedo effect [Jin et al., 2002] ... however, only about one eighth of the CONUS ecoregions considered in this study have significant annual snow cover."
Qualifiers: 36 ecoregions, 43 per cent of CONUS, 3 years of Collection 5 data, class **means** (2008) rather than medians (2010); net 0.012 W m-2 (p. 4, paragraph 12).

### Claim 4b (literature note, line 5)
"The nearest precedent is the Barnes and Roy pair: 2008 computed forcing from snow-free albedo only, 2010 added snow and snow-free albedo with snow data and reported that snow 'exacerbated' the forcing."
Verdict: **PARTIAL** (framing). Both halves are true of the respective papers, but the 2008-versus-2010 contrast is not a clean snow-free-versus-snow comparison: the 2010 paper attributes its higher CONUS forcing to two causes, p. 9, paragraph 33: "This CONUS net surface radiative forcing is greater than our earlier reported result of 0.012 Wm-2 [Barnes and Roy, 2008], which we attribute to considering 26% more area of the CONUS in this study and because we modeled snow effects". The clean comparison (same 58 ecoregions, 0.029 versus 0.031 W m-2) is inside the 2010 paper, section 4.5. Suggested: cite 2010 section 4.5 alone for "snow-free case beside snow-inclusive case" and 2008 only as the earlier snow-free-only study.

Available: full text, 6 pages.

---

## Item 6. Ghimire et al. (2014), GRL 41, 9087-9096. Key: ghimire2014

### What the paper does (the specifics asked for)
- Split: look-up maps from Gao et al. (2014). p. 9089, section 2.2: "the monthly composite (median albedo) MODIS broadband albedo product [Schaaf et al., 2002] from 2001 to 2011 at 30 arc sec (~1 km) spatial resolution" intersected with MODIS land cover; "This intersection was performed for four unique pairwise combinations of sky conditions (white sky and black sky, described below) and snow cover (snow free and snow covered)". **Which flag separates snow from snow-free is not stated in this paper**; "Further details on the LUMs are available at Gao et al. [2014]." (p. 9089). For the flag, the citation should move to Gao et al. 2014 (not checked here).
- Snow fraction: a separate product. p. 9089, section 2.3: "The snow-covered and snow-free fractions were derived from the 0.05° spatial resolution monthly level 3 MODIS terra snow cover climate modeling grid global product [Hall et al., 2002] averaged from 2001 to 2011, resampled to 1° spatial resolution." Held fixed over 1700-2005, p. 9090: "this study was forced to adopt an assumption of stationarity in the snow-covered climatology for the full historical period of study". Alternative for uncertainty, p. 9090: "substituting the Community Climate System Model version 4 snow cover product [Lawrence et al., 2012] for the MODIS product".
- Combination: eq. (1), p. 9089: alpha_m,y = sum over land-cover class l, snow state s and sky state r of f_l,y x f_s,m x f_r,m x alpha_l,s,r,m, "where ... fs was the fraction for snow-covered (s = 0) and snow-free (s = 1) conditions at month (m), and fr was the fraction for white-sky (r = 0) and black-sky (r = 1) radiation conditions". The snow mix and the diffuse/direct mix sit in the same sum.
- Resolution: 1 degree, monthly, 1700-2005 (p. 9089).
- Kernels: eq. (2), p. 9090: F_m,y = delta alpha_m,y,ws x K_ws + delta alpha_m,y,bs x K_bs, TOA, Shell et al. (2008) CAM3 kernels with Soden et al. (2008) as alternative; "We did not use the blue-sky albedo computed from equation (1) to determine radiative forcing in equation (2). Instead, we used the white-sky and black-sky albedos because the kernels were specific for white-sky and black-sky conditions" (p. 9090).
- Seasonal reporting: Figure 2 (p. 9092; checked on the page image) plots radiative forcing 1700-2005 for winter, spring, summer, autumn and annual, with an albedo inset. Text, p. 9092: "vary by season with winter and spring seasons having similarly large magnitudes of radiative forcing change of -0.17 W m-2 (cooling) from 1700 to 2005 followed by summer (-0.13 W m-2) and autumn (-0.12 W m-2) (Figure 2)"; albedo increases winter 0.00188, spring 0.00093, autumn 0.00081, summer 0.00060 (p. 9090). Figure 3 gives DJF, JJA and annual maps.
- Snow-free-only case: **no**. Only the snow-inclusive result is reported; uncertainty comes from swapping data products. The attribution to snow is qualitative: abstract, p. 9087: "mainly driven by snow exposure due to land cover transitions from natural vegetation to agriculture"; p. 9092: the largest increase is in winter "because the conversion of high stature vegetation (e.g., forests) to low stature vegetation (e.g., crops) results in snow exposure".
- Share of snow-flagged retrievals as f_snow: **no**. Separate product (MOD10 monthly CMG).

### Claim 6a (references.md item 6)
Sentence: "monthly snow-covered and snow-free albedo per land-cover type combined with a snow-cover fraction; monthly albedo change times radiative kernels, seasonal reporting (section 2.3, Figure 2)."
Verdict: **SUPPORTED**. Eq. (1) and eq. (2) are both in section 2.3 (pp. 9089-9090); the look-up maps are described in 2.2; Figure 2 is seasonal. Qualifiers dropped: the kernels are TOA and are applied separately to white-sky and black-sky albedo change, not to blue-sky albedo; the snow fraction is a 2001-2011 climatology assumed stationary; no snow-free-only case.

### Claim 6b (plan, result.md line 226)
Sentence: "Monthly kernel multiplication and seasonal reporting follow Ghimire ... §2.3 and Figure 2."
Verdict: **SUPPORTED** (as 6a). The plan's own rider that the reference "does not justify changing" the pipeline's signs, units, weighting and denominators is consistent with the source: Ghimire report TOA forcing from white- and black-sky kernels, a different convention from a surface or blue-sky one.

### Claim 6c (literature note, line 17, the "from memory" item)
"That the two are blended by a MODIS snow-cover fraction and that the paper attributes most of the change to the snow-covered term: from memory, to be checked."
Verdict: **PARTIAL**, now checked. Blending by a MODIS snow-cover fraction: confirmed (eq. 1; MOD10 CMG climatology). "Attributes most of the change to the snow-covered term": the paper says the increase is "mainly driven by snow exposure" and is largest in winter, but it performs no term-by-term decomposition and no snow-free run; the decomposition the note has in mind is Jiao et al. 2017 (not checked here). Suggested: "Ghimire et al. attribute the albedo increase mainly to snow exposure on the strength of its seasonal pattern (largest in winter), without a formal decomposition." Also note: the abstract gives the forcing as "-0.15 ± 0.1 W m-2" but the Results and Discussion give a standard deviation of 0.01 W m-2 and a range -0.13 to -0.16 (pp. 9092); if the uncertainty is ever quoted, use the text value and say so.

### Claim 6d (literature note, line 44)
As in 3d: the mix form with a MOD10 fraction is **SUPPORTED** for Ghimire (per 1 degree cell and month); the retrieval-share option is **NOT ESTABLISHED** in this paper.

### Claim 6e (review item 12)
"Ghimire et al. 2014 'section 2.3, Figure 2' ... unverified". Now verified as in 6a.

Available: full text, 10 pages, plus page 9092 as an image for the Figure 2 legend. Not available: the supporting information (Tables Sa1-Sa3, Sb1), Gao et al. 2014, Jiao et al. 2017, the NASA CCE 2013 abstract.

---

## Summary table

| Claim | Citing document | Verdict |
|---|---|---|
| 1a Jia 2022: 75° screen, actual and snow-free climatologies, winter gaps, sections 2.2-3.2 | plan line 20 | SUPPORTED |
| 1b Jia 2022: noon zenith at most 75° | build header 35-36 | SUPPORTED |
| 1c Jia 2022: average each date over years, drop max and min | build header 53-54 | SUPPORTED |
| 1d Jia 2022: 75° cut, actual and snow-free | review item 12 | SUPPORTED |
| 2a Wang 2018: full vs magnitude, validation across qualities, 16-day windows | plan line 119 | SUPPORTED |
| 2b Wang 2018: 16-day window "centred" on the day | build header 19-23 | PARTIAL (9th of 16 days) |
| 2c Wang 2018: validate all qualities | build header 32-34 | SUPPORTED |
| 2d Wang 2018: MCD43A2 snow flag of each day | build header 47-48 | SUPPORTED |
| 2e Wang 2018: all Terra and Aqua clear observations, high latitudes | literature note 34 | SUPPORTED |
| 2f Wang 2018: flagged retrieval uses only matching observations | literature note 52 | PARTIAL (stated for snow days only) |
| 3a Barnes and Roy 2010: "mean" monthly snow and snow-free albedo, MOD10 weighting, section 4.5 | references.md item 3 | PARTIAL (median, not mean; rest supported) |
| 3b Barnes and Roy 2010: section 4.5 comparison, explicit snow mixture | plan line 120 | SUPPORTED |
| 3c Barnes and Roy 2010: abstract quotations and MOD10 weighting | literature note 15 | PARTIAL (one misquote; weighting confirmed) |
| 3d Barnes and Roy 2010: snow flag split; mix form; retrieval share as f_snow | literature note 5, 44 | PARTIAL (retrieval share has no precedent) |
| 3e Barnes and Roy 2010: snow-free interannual variability changes forcing | literature note 40 | SUPPORTED |
| 3f Barnes and Roy 2010: section 4.5 and mixture now verified | review item 12 | SUPPORTED |
| 4a Barnes and Roy 2008: snow-free albedo only | references.md item 4; literature note 14 | SUPPORTED |
| 4b Barnes and Roy 2008 vs 2010 as the snow-free/snow pair | literature note 5 | PARTIAL (confounded by area; use 2010 section 4.5) |
| 6a Ghimire 2014: snow mix with snow-cover fraction, kernels, seasonal, section 2.3, Figure 2 | references.md item 6 | SUPPORTED |
| 6b Ghimire 2014: kernel multiplication and seasonal reporting | plan line 226 | SUPPORTED |
| 6c Ghimire 2014: blended by MODIS snow fraction; attributes most change to snow term | literature note 17 | PARTIAL (blend confirmed; attribution qualitative, no decomposition) |
| 6d Ghimire 2014: mix form; retrieval share as f_snow | literature note 44 | PARTIAL (retrieval share has no precedent) |
| 6e Ghimire 2014: section 2.3 and Figure 2 now verified | review item 12 | SUPPORTED |

No claim is CONTRADICTED or UNVERIFIABLE. The one correction of fact for `literature/evidence.csv`: Barnes and Roy 2010 use the median, not the mean, monthly class albedo.

Pages read: Barnes and Roy 2010 all 14 pages (plus p. 4 as image); Ghimire et al. 2014 all 10 pages, 9087-9096 (plus p. 9092 as image); Barnes and Roy 2008 all 6 pages; Jia et al. 2022 all 19 pages; Wang et al. 2018 all 15 pages, 50-64. Tool calls: 22 before this report.