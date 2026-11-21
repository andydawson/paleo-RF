# References of the refit plan: audit summary (29 October 2026)

Chris asked (29 October) for the references cited by Astra's refit plan and Fable's review to be
audited before building. Details: `2026-10-29_refit_references_identity_check.md` and the two
`..._claims_check_part1.md`, `..._part2.md`.

**Identity.** All 12 DOIs resolve to the cited papers; no retractions or corrections. Gao et al. 2014's
registered title spells out "moderate resolution imaging spectroradiometer" (cite as J. Appl. Remote
Sens. 8, 083532).

**Full texts read:** Jia 2022, Wang 2018, Barnes and Roy 2010 and 2008, Ghimire 2014, Bright 2015,
Moody 2005, King and Zeng 2006 (published versions); Wood 2011 (accepted manuscript). **Abstracts
only:** Jiao 2017 and Moody 2007 (no open copy; Chris chose not to fetch them through the library) and
Gao 2014 (the publisher's site blocked automated access).

**The snow-share mix (the 19 October snow plan).** Barnes and Roy 2010 (eq. 3; snow-free case with the
fraction set to zero in section 4.5) and Ghimire et al. 2014 (eq. 1) combine snow-covered and snow-free
MODIS albedo linearly per month with a snow-cover fraction: genuine precedent for the form. Both take
the fraction from NASA's separate monthly snow-cover product (MOD10CM, 0.05 degree; per ecoregion over
2004-2008 in Barnes and Roy, per 1-degree cell over 2001-2011 in Ghimire), not from the share of
snow-flagged albedo retrievals. Neither fits a statistical model to albedo (medians per land-cover
class and month); Ghimire reports no snow-free-only case. **Chris decided (29 October):** the mixing
step will take today's snow share from MOD10CM averaged per cell over 2000-2009, with the share of
snow-flagged retrievals compared beside it.

**Supported as cited:** Jia 2022 (75-degree screen, all-days and snow-free climatologies, winter gaps
reported, sections 2.2-3.2); Wang 2018 (full and backup inversions, validation across quality classes);
King and Zeng 2006 (convex hull, section 2.3); Bright 2015 (noon direct-beam albedo, section 2.1);
Ghimire 2014 (monthly kernels, seasonal reporting, section 2.3 and Figure 2); Barnes and Roy 2008
(snow-free only).

**Corrections (applied in the documents named):**
- Barnes and Roy 2010 use **median**, not mean, monthly class albedo (literature note).
- Bright 2015: there is no section 2.2.1. The December exclusion is in the Figure 2 caption (p. 2200);
  the MODIS data are section 2.1. "MODIS may underestimate cold dry snow albedo" is Bright's summary of
  Jin et al. 2002, Stroeve et al. 2005 and Wang and Zender 2010, so cite those (literature note, Fable's
  review item 12).
- Wood 2011 develops mgcv's REML method; concurvity appears in one sentence (section 3.3), so "discusses
  numerical difficulties associated with concurvity" overstates it (Astra's plan).
- Moody 2005: single-year (2001, 2002) 16-day snow-free maps from the older MOD43B3 product's snow flag,
  not a climatology and not the MCD43A2 flag; the snow-covered statistics are Moody 2007 (literature note).
- Barnes and Roy 2008 against 2010 is not a clean snow comparison (the 2010 study also covers 26% more
  area); the clean one is inside the 2010 paper, section 4.5 (literature note).
- Ghimire 2014 attributes the albedo change mainly to snow exposure from its seasonal pattern, without a
  formal decomposition (literature note).
- Wang 2018: the daily value's 16-day window has the day of interest 9th of 16, not centred (build
  script header); a snow-flagged retrieval uses only snow-covered observations, but the paper does not
  state the converse for snow-free days (literature note).
