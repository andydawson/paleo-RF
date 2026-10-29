# Identity check of the 12 references in the refit plan (29 October 2026)

Scope: whether each DOI resolves and whether the registry record matches the entry in
references.md (title, authors, year, venue, volume, pages), plus retraction and correction
notices. The claims were not checked.

Sources: Crossref /works/<DOI> for all 12 (all HTTP 200; raw JSON in crossref/). I also
searched Crossref with filter=updates:<DOI> for notices that point at each DOI (all 0
results; JSON in updates/). OpenAlex was used for 3 records (openalex/) and doi.org landing
pages for 3 (landing/; the AGU pages returned 403). RefChecker 3.1.6 (refchecker-webui
--no-llm --check-retractions) was run on checkers/input.bib, which holds the entries as
given: 12 verified, no errors, no warnings, OpenAlex retraction check clean for all 12.
RefChecker missed the Gao2014 title difference and the Moody2007 subtitle, so its pass is
not counted as independent confirmation. Its retraction check uses OpenAlex, which copies
Crossref, so it is the same source as the Crossref check. refaudit was not run because it
requires a contact email (--email or REFAUDIT_EMAIL) and none was given for this task.
combine_reference_checks.py needs refaudit's CSV, so it was not run either. The earlier
name-resolution failure did not recur: the network worked throughout.

## CSV

citekey,doi,status,field_differences,registry_title,registry_first_author,registry_year,registry_container,correction_doi,raw_response_path,checked_on
Jia2022,10.1029/2021JD035987,verified,"title: case only; container: entry 'JGR Atmospheres' is the registry short title; year: online 2022-04-12 and issue 2022-04-27 (both 2022); volume 127 issue 8 and article e2021JD035987 agree; 5 authors agree",Global Daily Actual and Snow-Free Blue-Sky Land Surface Albedo Climatology From 20-Year MODIS Products,Jia,2022,Journal of Geophysical Research: Atmospheres,,/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/refaudit_refit/crossref/Jia2022.json,2026-10-29
Wang2018,10.1016/j.rse.2018.02.001,verified,"none beyond the diacritic in the 5th author (registry 'Román'); volume 207 and pages 50-64 agree; 5 authors agree",Capturing rapid land surface dynamics with Collection V006 MODIS BRDF/NBAR/Albedo (MCD43) products,Wang,2018,Remote Sensing of Environment,,/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/refaudit_refit/crossref/Wang2018.json,2026-10-29
Barnes2010,10.1029/2010JG001428,verified,"container: entry 'JGR', registry 'Journal of Geophysical Research: Biogeosciences' (short 'J. Geophys. Res.'); pages: entry 'G04033' not present in Crossref or OpenAlex (Crossref article-number '2010JG001428'; issue G4); publisher page HTTP 403, so G04033 unconfirmed; year 2010 (online 2010-12-04); volume 115 agrees; 2 authors agree",Radiative forcing over the conterminous United States due to contemporary land cover land use change and sensitivity to snow and interannual albedo variability,Barnes,2010,Journal of Geophysical Research: Biogeosciences,,/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/refaudit_refit/crossref/Barnes2010.json,2026-10-29
Barnes2008,10.1029/2008GL033567,verified,"pages: entry 'L09706' not present in Crossref or OpenAlex (Crossref article-number '2008GL033567'; issue 9); publisher page HTTP 403, so L09706 unconfirmed; year 2008 (online 2008-05-09); volume 35 agrees; 2 authors agree",Radiative forcing over the conterminous United States due to contemporary land cover land use albedo change,Barnes,2008,Geophysical Research Letters,,/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/refaudit_refit/crossref/Barnes2008.json,2026-10-29
Bright2015,10.5194/bg-12-2195-2015,verified,"diacritics only (registry 'Antón-Fernández' and 'Strømman'); volume 12 and pages 2195-2205 agree; 5 authors agree; relation lists the Biogeosciences Discussions preprint 10.5194/bgd-11-17339-2014 (not a correction)",Radiative forcing bias of simulated surface albedo modifications linked to forest cover changes at northern latitudes,Bright,2015,Biogeosciences,,/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/refaudit_refit/crossref/Bright2015.json,2026-10-29
Ghimire2014,10.1002/2014GL061671,verified,"none; online 2014-12-26 and issue 2014-12-28; volume 41 and pages 9087-9096 agree; 7 authors agree","Global albedo change and radiative cooling from anthropogenic land cover change, 1700 to 2005 based on MODIS, land use harmonization, radiative kernels, and reanalysis",Ghimire,2014,Geophysical Research Letters,,/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/refaudit_refit/crossref/Ghimire2014.json,2026-10-29
Jiao2017,10.1007/s10584-017-1962-8,verified,"none; online 2017-04-21 and issue June 2017; volume 142 and pages 463-476 agree; 6 authors agree",Global climate forcing from albedo change caused by large-scale deforestation and reforestation: quantification and attribution of geographic variation,Jiao,2017,Climatic Change,,/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/refaudit_refit/crossref/Jiao2017.json,2026-10-29
Moody2005,10.1109/TGRS.2004.838359,verified,"5th author: registry has the single string 'Feng Gao' with no family/given split, entry 'Gao'; volume 43 and pages 144-158 agree; 5 authors agree",Spatially complete global spectral surface albedos: value-added datasets derived from Terra MODIS land products,Moody,2005,IEEE Transactions on Geoscience and Remote Sensing,,/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/refaudit_refit/crossref/Moody2005.json,2026-10-29
Moody2007,10.1016/j.rse.2007.03.026,verified,"title: subtitle only in registry (': Statistics computed from Terra MODIS land products'); en dash in '2000–2004'; volume 111 and pages 337-345 agree; 5 authors agree",Northern Hemisphere five-year average (2000–2004) spectral albedos of surfaces in the presence of snow: Statistics computed from Terra MODIS land products,Moody,2007,Remote Sensing of Environment,,/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/refaudit_refit/crossref/Moody2007.json,2026-10-29
Gao2014,10.1117/1.JRS.8.083532,mismatch,"title: entry '...derived from MODIS BRDF/albedo products', registry '...derived from moderate resolution imaging spectroradiometer BRDF/albedo products'; pages: entry '083532', Crossref '1-15' (OpenAlex the same, copied); the publisher URL locator is 083532; 8 authors, year 2014 (2014-11-05), container and volume 8 agree",Multiscale climatological albedo look-up maps derived from moderate resolution imaging spectroradiometer BRDF/albedo products,Gao,2014,Journal of Applied Remote Sensing,,/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/refaudit_refit/crossref/Gao2014.json,2026-10-29
Wood2011,10.1111/j.1467-9868.2010.00749.x,verified,"year: online 2010-09-14, issue 2011 (entry uses the issue year); container: registry now 'Journal of the Royal Statistical Society Series B: Statistical Methodology' (entry 'JRSS B'); title case only; volume 73 and pages 3-36 agree; 1 author",Fast Stable Restricted Maximum Likelihood and Marginal Likelihood Estimation of Semiparametric Generalized Linear Models,Wood,2011,Journal of the Royal Statistical Society Series B: Statistical Methodology,,/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/refaudit_refit/crossref/Wood2011.json,2026-10-29
King2006,10.1093/pan/mpj004,verified,"year: issued 2006; Crossref published-online 2017-01-04 (the Cambridge re-registration date); the article PDF says Advance Access 2 November 2005; title case only; volume 14 and pages 131-159 agree; 2 authors agree",The Dangers of Extreme Counterfactuals,King,2006,Political Analysis,,/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/refaudit_refit/crossref/King2006.json,2026-10-29

## Rows that are not plain "verified"

- **Gao2014: mismatch, title.** The DOI, all 8 authors, the year, the journal and volume 8
  agree. The registered title spells out "moderate resolution imaging spectroradiometer"
  where the entry has "MODIS". Crossref gives the pages as 1-15; the entry's 083532 is the
  article number, and that is the locator in the SPIE URL. Action: use the registered title
  string (as in refs.bib). Cite the article as 8, 083532.

No retracted-or-corrected rows: no update-to, updated-by or correction relation in any
record, no Crossref notice pointing at any of the 12 DOIs, and no title starting with
Retraction, Correction or Erratum. No manual-no-DOI rows: all 12 entries have DOIs.

## Notes the authors may want to act on (not mismatches)

- **Barnes2010 and Barnes2008:** the citation numbers G04033 and L09706 are not in Crossref
  or OpenAlex, and the AGU pages refused the request (HTTP 403). They are consistent with
  the registered issues (G4 and 9) but not confirmed. Check against the article PDFs.
- **Moody2007:** the full registered title has the subtitle "Statistics computed from Terra
  MODIS land products".
- **Wood2011:** pdf/wood2011.pdf is the University of Bath accepted manuscript (10 pages),
  not the version of record (pp. 3-36). Section and page numbers quoted from it may not
  match the journal version.
- **pdf/ folder (seen while another process was writing to it):** barnes2008.pdf,
  barnes2010.pdf, ghimire2014.pdf and jia2022.pdf were 5833-byte HTML pages, not PDFs. The
  claims reviewer should not treat them as sources.

## Addendum (29 October, after this report)

- refaudit ran once Chris confirmed his contact address for these services: 12 checked, all OK;
  combine_reference_checks.py: 11 PASS, Gao2014 NEEDS_LOOK (the registered title spells out
  "moderate resolution imaging spectroradiometer"; cite it as J. Appl. Remote Sens. 8, 083532).
- The published PDFs (first pages) confirm Barnes and Roy 2010, 115, G04033 and 2008, 35, L09706.
