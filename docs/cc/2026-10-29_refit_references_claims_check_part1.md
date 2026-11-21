# Refit references: full-text claim check, part 1 (Bright 2015, Moody 2005, Wood 2011, King and Zeng 2006)

By the claim-checker role (Claude), 29 October 2026, from full texts in the session scratch folder.
Wood 2011 was read as the Bath accepted manuscript (its page numbers differ from the journal's).

---

# Claim-support check, refit plan references 5, 8, 11, 12 (adversarial reader, 29 October 2026)

NOTE TO CALLER: I could not write `/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/refaudit_refit/claims_report_part1.md` because no file-writing tool was available to me in this run (I had Read, Grep, Glob and this handback only). The report below is complete and formatted to be saved verbatim to that path.

## Identity of the files (step 1)

- `pdf/bright2015.pdf`: Biogeosciences 12, 2195-2205, 2015; Bright, Myhre, Astrup, Antón-Fernández, Strømman; doi 10.5194/bg-12-2195-2015. Published version. Matches item 5.
- `pdf/moody2005.pdf`: IEEE TGRS 43(1), 144-158, January 2005; Moody, King, Platnick, Schaaf, Gao; doi 10.1109/TGRS.2004.838359. Published version. Matches item 8. (`moody2005_ntrs_popular_summary.pdf` not used.)
- `pdf/wood2011.pdf`: University of Bath repository "peer reviewed version" (manuscript dated 6 May 2010) of Wood, JRSS B 73(1), 3-36, 2011; doi 10.1111/j.1467-9868.2010.00749.x. Accepted manuscript, 29 manuscript pages behind a cover sheet; page numbers below are the manuscript's, not the journal's pp. 3-36. The journal typesetting was not available, so passages were checked against the manuscript only.
- `pdf/king2006.pdf`: Political Analysis 14, 131-159, 2006; King and Zeng; doi 10.1093/pan/mpj004. Published version. Matches item 12.

---

## Claim 5 (Bright et al. 2015), as stated in references.md item 5 and in the plan (`astra_refit/result.md` line 121)

Sentence (references.md): "documents insufficient December MODIS retrievals at high latitude and degraded retrievals at high solar zenith angles; MODIS may underestimate cold dry snow albedo (sections 2.2.1 and 4)."
Sentence (plan, line 121): "Bright ... (2015) ... documents insufficient December retrievals and degraded correction at high solar angles."
Citekey: Bright et al. 2015, Biogeosciences 12, 2195-2205.

Verdict: PARTIAL.

Quotes:
- Figure 2 caption, p. 2200: "High solar zenith angles precluded the number of sufficient MODIS retrievals in December; thus December mean biases were excluded from the November–May mean". Repeated in the Figure 3 caption, p. 2201: "November–May mean (excluding December)".
- Section 4, p. 2201: "January and most of February experience solar zenith angles > 70° for our case study regions; at these angles the atmospheric correction algorithm degrades and the uncertainty in the MODIS retrievals is increased (Lucht et al., 2000; Schaaf et al., 2002; Stroeve et al., 2005)".
- Section 4, p. 2201: "there is some evidence that MODIS may underestimate the albedo of cold dry snow (Jin et al., 2002; Stroeve et al., 2005; Wang and Zender, 2010), particularly in VIS bands (Wang and Zender, 2010)".

Element by element:
- Section locator: the published paper has sections 2.1 MODIS albedo, 2.2 Forest structure and meteorology, 2.3 Albedo parameterizations in climate models, 2.4 Regression modeling, 2.5 Radiative forcing, 3 Results, 4 Discussion, 5 Conclusions. There is no section 2.2.1. The MODIS data description is section 2.1 (p. 2196). The December statement appears only in the Figure 2 and Figure 3 captions (pp. 2200-2201), nowhere in the methods text (the word "December" occurs in the paper only in the received date and these two captions). The review's "sections 2.2.1 and 4" (`fable_review.md` line 35) carries the same wrong locator.
- "insufficient December MODIS retrievals": the paper's own data handling; agrees. The consequence in the paper is that December is dropped from a model-evaluation statistic (the November-May mean bias), not from a data product.
- "at high latitude": the paper says this for "our case study regions", three sites in boreal Norway (Figure 1 insets, p. 2197, about 60.5-62 N; Table 1 lists Flisa, Rena, Drevsjø). It does not generalise to high latitudes as such. The manuscript's "at high latitude" is a fair description of the sites but is the manuscript's generalisation.
- "degraded retrievals at high solar zenith angles" / plan's "degraded correction at high solar angles": the paper's own observation is that its sites have solar zenith angles above 70 degrees in January and most of February; the statement that the atmospheric correction degrades and retrieval uncertainty rises at such angles is attributed to Lucht et al. 2000, Schaaf et al. 2002 and Stroeve et al. 2005 (secondary). The plan's wording "degraded correction" matches the paper's "the atmospheric correction algorithm degrades" more exactly than "degraded retrievals".
- "MODIS may underestimate cold dry snow albedo": NOT the paper's own result. The paper reports it as "some evidence" from Jin et al. 2002 (Geophys. Res. Lett. 29, 12-11 to 12-14), Stroeve et al. 2005 (Remote Sens. Environ. 94, 46-60) and Wang and Zender 2010 (Remote Sens. Environ. 114, 563-575), with the hedge "may", and uses it only as a possible partial explanation of why models overestimated albedo in January and February. If the manuscript wants this statement, the citation should move to those works (Jin et al. 2002 for the "up to 10 % negative bias in the MODIS pure dry snow albedo", p. 2201), or be phrased "as summarised by Bright et al. (2015)".
- Kind of evidence: the December and solar-zenith observations are the paper's own data handling and site conditions; the mechanism and the snow-albedo bias are cited from other work. The paper is an albedo-parameterisation evaluation at three Norwegian sites using v006 MCD43A daily black-sky albedo (section 2.1, p. 2196), not a MODIS retrieval study.

Suggested wording: "Bright et al. (2015) excluded December from their November-May evaluation because high solar zenith angles left too few MODIS retrievals at their boreal Norway sites (about 61 N; Fig. 2 caption), and note that January and most of February there have solar zenith angles above 70 degrees, at which the atmospheric correction degrades and retrieval uncertainty rises (section 4, citing Lucht et al. 2000, Schaaf et al. 2002, Stroeve et al. 2005). The possible underestimate of cold dry snow albedo by MODIS is from Jin et al. (2002), Stroeve et al. (2005) and Wang and Zender (2010), as summarised by Bright et al. (2015)."

Available: full published text, all 11 pages read. Not available: the Supplement (Sect. S1-S6 referenced in the text) and the Biogeosciences Discussions version, which may be where a "2.2.1" numbering came from.

## Claim 5-noon (Bright et al. 2015), questions file section 3 (`wt-chrisdev/docs/cc/questions_for_andria_scientific_from_2026-10-20.md` lines 209-210)

Sentence: "Bright et al. 2015 (Biogeosciences) use the MODIS direct-light albedo at local solar noon".
Citekey: Bright et al. 2015.

Verdict: SUPPORTED.

Quotes:
- Section 2.1, p. 2196: "taking the direct beam ("black-sky") αs at local solar noon for visible (VIS; 0.3–0.7 µm) and near-infrared (NIR; 0.7–5.0 µm) spectral bands for the time periods spanning January through May (2007) and November through May (2008–2009)".
- Section 2.3, p. 2198: "Direct beam (black-sky) albedos are calculated at local solar noon to be compatible with the MODIS retrievals."

Element by element: direct-beam (black-sky) albedo, yes; local solar noon, yes; the product is v006 MCD43A 1-day daily, 500 m (p. 2196). Qualifier the surrounding paragraph should carry: Bright uses black-sky spectral albedo (VIS and NIR separately), not the blue-sky broadband albedo the questions file names as the project's calibration albedo; the paper treats the models' blue-sky albedos as comparable only because "The direct beam component, however, typically dominates the total albedo under clear-sky conditions" (section 2.3, p. 2198). So the paper is a precedent for a noon-defined direct-beam albedo, not for a blue-sky noon albedo as such. The sentence as written is exactly what the paper says.

Available: full text. Duveiller et al. 2018 and the Copernicus product, cited in the same sentence, were not in the packet and were not checked.

## Claim 5-lit22 (Bright et al. 2015), literature note (`wt-feature/docs/cc/2026-10-16_snow_free_estimate_literature_fable.md` line 22)

Sentence: "Section 2.2.1: v006 MCD43A daily black-sky albedo, November-May only, i.e. the snow season handled as its own stream."
Citekey: Bright et al. 2015.

Verdict: PARTIAL.

Quote: section 2.1, p. 2196 (as above): "... January through May (2007) and November through May (2008–2009)". Abstract, p. 2195: "daily meteorology for three snow cover seasons and for three case regions in boreal Norway".

Element by element: product and albedo type agree (v006 MCD43A, daily, black-sky). Section number is 2.1, not 2.2.1. Period: the first season was January-May 2007, so "November-May only" is not exact. "The snow season handled as its own stream" is the note's gloss: the whole study is confined to the snow-cover seasons; the paper does not split a larger record into a snow-season stream.

Suggested wording: "Section 2.1: v006 MCD43A daily black-sky albedo at local solar noon, analysed for the snow-cover seasons only (January-May 2007; November-May 2008 and 2009)."

## Claim 5-lit33 (Bright et al. 2015), literature note line 33

Sentence: "(Section 2.2.1, verified): 'High solar zenith angles precluded the number of sufficient MODIS retrievals in December; thus December mean biases were excluded'; Section 4 notes degraded atmospheric correction at solar zenith angles above 70 degrees in January and most of February."
Citekey: Bright et al. 2015.

Verdict: SUPPORTED, with the locator corrected: the quotation is verbatim from the Figure 2 caption (p. 2200), not from a section 2.2.1 (which does not exist); the solar-zenith statement is in section 4 (p. 2201) and rests on Lucht et al. 2000, Schaaf et al. 2002 and Stroeve et al. 2005. The note's closing inference "Excluding a month is an accepted answer" is the note's own; what the paper excluded was December from an evaluation statistic, not from a product.

## Claim 5-lit40 (Bright et al. 2015), literature note line 40

Sentence: "Bright et al. 2015 (Biogeosciences, Section 4) caution that MODIS may underestimate cold dry snow albedo and that retrievals degrade at high solar zenith angles, so the snowy stream is the less certain one."
Citekey: Bright et al. 2015.

Verdict: PARTIAL. Both statements are in section 4, p. 2201 (quotes above), but both are reported from other work (Jin 2002; Stroeve 2005; Wang and Zender 2010; Lucht 2000; Schaaf 2002), with the paper's own hedges "some evidence", "may" and "for our case study regions". The conclusion "the snowy stream is the less certain one" is the note's inference. Suggested wording: "Bright et al. (2015, section 4) relay evidence from Jin et al. (2002), Stroeve et al. (2005) and Wang and Zender (2010) that MODIS may underestimate cold dry snow albedo, and that retrieval uncertainty rises above 70 degrees solar zenith (Lucht et al. 2000; Schaaf et al. 2002; Stroeve et al. 2005)."

---

## Claim 8 (Moody et al. 2005)

Sentence (references.md item 8): "snow-free albedo climatology by land-cover class using the MODIS snow flag."
Where made: not in the plan or the review by name; in the literature note (`wt-feature/.../2026-10-16_snow_free_estimate_literature_fable.md`): line 5 "Separating MODIS MCD43 retrievals into snow-free and snow-covered with the MCD43A2 snow flag, and building per-land-cover albedo statistics for each, is the normal practice (Moody 2005, 2007; ...)"; line 11 "Snow-free climatology by IGBP class; abstract states snow-free data cover only about half the land surface annually"; line 31 "'ecosystem-dependent temporal interpolation technique to fill missing or seasonally snow-covered data', phenological curves per IGBP class from MOD12Q1 ... winter snow-free albedo at high latitudes in these products is an interpolated, class-based value, not an observation."
Citekey: Moody et al. 2005, IEEE TGRS 43, 144-158.

Verdict: PARTIAL.

Quotes:
- Abstract, p. 144: "An ecosystem-dependent temporal interpolation technique is described that has been developed to fill missing or seasonally snow-covered data in the official MOD43B3 albedo product."
- Section III.A, p. 147: "The data are also conditioned by applying the MOD43B3 general and band-specific QA to remove pixels of lower quality." ... "Pixels flagged as seasonally snow-covered or over ephemeral waters were also replaced with fill-values, as the current study intends to provide seasonal snow-free land albedo products."
- Section III.B, p. 147: "the statistics, by IGBP ecosystem class, are computed from the conditioned pixel-level data inside each region."
- Section IV, p. 155: "Simple statistics, consisting of the mean, standard deviation, and number of data points have been computed for each ecosystem class or as a whole, over each grid cell."
- Section IV, p. 156: "Current production of spatially complete albedo maps and statistics consists of 2001 and 2002 datasets."
- Section III.D.1, p. 149: "As one goal of the current study is to provide seasonal snow-free albedo maps, the full decay state must be approximated in order to properly represent the full phenological curve."

Element by element:
- "snow-free": agrees (abstract; p. 147; p. 154 "spatially complete snow-free global land surface albedo dataset").
- "climatology": not what the paper describes. The products are 16-day-period maps for single years (23 periods per year, Table IV p. 155; 2001 and 2002 datasets, p. 156). The word "climatology" does not occur in the paper except inside a cited title. A multi-year average product is a later paper (Moody et al. 2008, JAMC, not in this packet).
- "by land-cover class": supported for the method (phenological curves by MOD12Q1 IGBP class, sections II and III) and for a secondary product (per-grid-cell statistics by ecosystem class at 0.5 to 10 degree resolution, p. 155); the primary product is pixel-level (1-minute grid).
- "using the MODIS snow flag": supported in substance; the flag is the seasonal-snow flag in the MOD43B3 QA (Terra-only, Collection 4, 16-day, 1 km). The literature note's line 5 names the MCD43A2 snow flag, which this paper does not and could not use; the attribution to Moody 2005 should say MOD43B3 QA.
- Literature-note line 5 "snow-free and snow-covered ... statistics for each": the 2005 paper supplies only the snow-free side; snow-flagged pixels are replaced with fill values and interpolated, not tabulated. Snow-covered statistics are the 2007 companion (not in my packet; not checked).
- Literature-note line 31: agrees with section III.D.1 (pp. 149-150): at high latitudes the dormant state is "obscured by cloud and covered by snow" and the winter end point is set to "the ecosystem-dependent percentage of the maximum albedo during the full maturation stage" (p. 150), i.e. an interpolated class-based value.
- Kind of evidence: the paper's own product description; the snow-flag source is the MOD43B3 user guide and Schaaf et al. 2002 (its ref. [38]).

Suggested wording: "Moody et al. (2005) produce spatially complete snow-free MOD43B3 albedo maps for 2001 and 2002 (16-day periods) by replacing pixels flagged as seasonally snow-covered in the MOD43B3 QA with fill values and filling them by an ecosystem-dependent (IGBP class) temporal interpolation; they also provide per-grid-cell statistics by ecosystem class. A multi-year snow-free climatology and the snow-covered statistics are later papers (Moody et al. 2008; Moody et al. 2007)."

Available: full published text, all 15 pages read. Moody et al. 2007 and 2008 were not in the packet.

---

## Claim 11 (Wood 2011)

Sentence (plan, `astra_refit/result.md` line 155): "Wood, S. N. (2011) ... establishes the REML estimation framework and discusses numerical difficulties associated with concurvity." (references.md: "establishes the REML estimation framework used by mgcv; discusses numerical difficulties associated with concurvity.")
Citekey: Wood 2011, JRSS B 73, 3-36 (read as the Bath accepted manuscript).

Verdict: PARTIAL (first element SUPPORTED; second overstated).

Quotes (manuscript page numbers):
- Abstract, manuscript p. 1: "This article develops the first such method for REML or ML estimation of smoothing parameters. A Laplace approximation is used to obtain an approximate REML or ML for any GLM, which is suitable for efficient direct optimization." and "The method will cope with numerical rank deficiency in the fitted model".
- Section 6 Discussion, manuscript p. 20: "since the method is freely available in R package mgcv (from version 1.5) this is not an obstacle to its use."
- Section 3.3, manuscript p. 8 (the only occurrence of "concurvity" in the paper): "Given that penalized GLMs are frequently complex models in which concurvity effects can easily lead to quite high condition numbers, this approach is not sensible."
- Section 3, manuscript p. 6: "the major difficulty in minimizing (4) or (5) is that if some λj is large enough, then the 'numerical footprint' of the corresponding penalty term ... can extend well beyond the penalty's range space".
- Appendix A, manuscript p. 21: data generated "with a relatively benign co-linearity problem and a mild mean variance relationship problem" made BayesX fail to converge, while "Fitting the same model to these data sets using the methods proposed in this paper gave no problems".

Element by element:
- "establishes the REML estimation framework used by mgcv": agrees; the paper develops the Laplace-approximate REML/ML criterion with nested Newton/PIRLS optimisation and states it is implemented in mgcv from version 1.5.
- "discusses numerical difficulties associated with concurvity": overstated. Concurvity appears in one sentence, as the reason for solving the penalised least-squares step by orthogonal decomposition rather than forming X'WX (section 3.3). The paper's actual discussion of numerical difficulty (section 3, 3.1, manuscript pp. 5-7) concerns ill-conditioning induced by large smoothing parameters and structural rank deficiency, not concurvity. Appendix A uses correlated covariates as a test case on which previous REML schemes fail and the proposed method converges; the paper does not present concurvity as a source of difficulty for its own method.
- Relevance to the plan's context (a non-converging fit under maxit): the paper claims convergence reliability for its method ("eliminates the convergence failures of previous REML/ML based approaches", abstract); it gives no iteration-count threshold, consistent with the plan's statement that the 2,000-step limit is Chris's diagnostic.
- Version: accepted manuscript read; the journal pagination and any copy-editing changes were not available.

Suggested wording: "Wood (2011) develops the REML/ML smoothing-parameter estimation implemented in mgcv and notes that concurvity in complex penalized GLMs can produce high condition numbers, which its stable least-squares step is designed to withstand (section 3.3)."

Available: Bath accepted manuscript, PDF pages 1-2, 7, 9, 21-22 read as images, remainder via the text extraction and searches. Not available: the journal typeset version.

---

## Claim 12 (King and Zeng 2006)

Sentence (plan, `astra_refit/result.md` line 232): "Convex-hull identification of extrapolation follows King, G. and Zeng, L. (2006) ... §2.3. Here it describes cover-space support only. Also report latitude/elevation ranges and model concurvity; being inside the cover triangle does not establish support for every predictor combination." (references.md: "the convex hull of the observed covariates identifies extrapolation (section 2.3).")
Citekey: King and Zeng 2006, Political Analysis 14, 131-159.

Verdict: SUPPORTED.

Quotes:
- Section 2.3 "Interpolation versus Extrapolation", p. 138: "Perhaps the most intuitive definition of extrapolation is one based on the concept of the convex hull: questions that involve interpolation are values of the vector x that fall in the convex hull of X, and those involving extrapolation are outside of the hull."
- Section 2.3.1, p. 138: "A counterfactual question x that appears outside the polygon requires extrapolation. Anything inside involves interpolation."
- p. 140: "using extrapolation to detect counterfactuals too far from the data is conditional on a specific choice for X".

Element by element: section number correct (2.3 spans pp. 138-140; 2.3.1 Convex Hull p. 138, 2.3.2 computational geometry p. 140). The plan's caveat that the hull describes support only in the chosen covariate space matches the paper's own qualifier (p. 140). Qualifiers the paper adds that the plan might carry: the hull is a conservative approximation to the support (footnote 9, p. 139: "closely but qualitatively related; there is no universal quantitative relationship"); points inside the hull can still be far from the data when the data hug the boundary, so "the distance measure is a useful complement of the convex hull criterion" (p. 140, the Gower distance of section 2.2). Kind of evidence: the paper's own definition and proof-backed argument; software "WhatIf" for the membership check (Appendix A).

Available: full published text; pp. 131 and 138-140 read as images, section 2.3 also in the text extraction.

---

## Summary

| Claim id | Source of the sentence | Verdict |
|---|---|---|
| 5 | references.md item 5; plan line 121; review line 35 | PARTIAL (December: yes, Fig. 2 caption p. 2200, not "2.2.1"; solar zenith: yes for the sites, mechanism cited; cold dry snow: secondary citation of Jin 2002, Stroeve 2005, Wang and Zender 2010) |
| 5-noon | questions file, noon albedo paragraph | SUPPORTED (sections 2.1 p. 2196, 2.3 p. 2198; black-sky spectral, not blue-sky) |
| 5-lit22 | literature note line 22 | PARTIAL (section 2.1; January-May 2007 plus November-May 2008-2009; "stream" is a gloss) |
| 5-lit33 | literature note line 33 | SUPPORTED (locator: Fig. 2 caption p. 2200 and section 4 p. 2201) |
| 5-lit40 | literature note line 40 | PARTIAL (both statements cited from other work, hedged) |
| 8 | references.md item 8; literature note lines 5, 11, 31 | PARTIAL ("climatology" not supported: single-year 16-day maps; snow flag is MOD43B3 QA, not MCD43A2; snow-free side only) |
| 11 | plan line 155 | PARTIAL (REML framework in mgcv: yes; concurvity: one passing sentence, section 3.3 ms p. 8) |
| 12 | plan line 232 | SUPPORTED (section 2.3, pp. 138-140) |

Pages read: Bright 2015 all 11 pages; Moody 2005 all 15 pages; Wood 2011 manuscript PDF pages 1, 2, 7, 9, 21, 22 as images plus the text extraction for manuscript pp. 5-8 and 20-21; King and Zeng 2006 pages 131 and 138-140 as images plus the text extraction of section 2.3; 45 tool calls including this handback.