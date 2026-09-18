# Open questions for Andria: scientific and technical

Maintained by Chris with Claude Code; kept current as work proceeds (see
AGENTS.md). Simple and logistical questions are in
`questions_for_andria_general.md`. Each entry gives the question, a plain
explanation of why it matters, and where it comes from. Updated 2026-09-18.
Sources: `2026-09-17_methodology_questions_newcomer_review.md` (Q numbers)
and `2026-09-18_code_review_original_code.md` (R numbers).

## Uncertainty

### U1. Does land-cover uncertainty reach the albedo and forcing? (Q6)
The interpolated land-cover file carries 200 posterior draws per cell,
slice and cover type. In the meeting you described the intended approach
as drawing many samples from the posterior and summarising their mean and
standard deviation. Script 1 averages the 200 draws to a single value per
cell before anything else happens, so the land-cover uncertainty never
reaches the calibration, the hindcasts or the forcing. Is that the
intended use of the draws, or should each draw (or a subset) be carried
through the prediction step so that the albedo intervals include
land-cover uncertainty?

### U2. What do the albedo "posterior samples" represent? (R1)
Script 6 calls `simulate()` on the fitted GAM. With the gratia package
attached, that draws new observations from the beta distribution at the
fitted mean; the model's coefficients are never resampled. So the
reported albedo standard deviations, intervals and CV maps describe
residual scatter at the calibration data's dispersion, not the model's
own uncertainty about the fitted relationship. The "fraction of data
inside the credible interval" statistic in script 5 therefore checks the
dispersion parameter rather than coverage. Is this what was intended? If
model uncertainty is wanted, the standard route in mgcv is to draw
coefficient vectors from the fitted model's posterior (gratia's
`fitted_samples` / `posterior_samples`, or `rmvn` with `vcov`) and
propagate those.

### U3. 100 versus 1,000 draws
The manuscript says 1,000 posterior samples per cell and month; the
scripts draw 100. Which is intended? (Relevant to U1 and U2.)

## The calibration model

### M1. The land-cover smooth is rank-deficient (R5)
The three cover fractions ET + ST + OL always sum to one, so they lie on
a flat two-dimensional surface inside three-dimensional space. The model
fits a three-dimensional smooth `s(OL, ET, ST)`, which has no data in one
of its three directions; the fitted March model has rank 444 of 448
coefficients. This is harmless for interpolation on the surface, but any
paleo cell whose fractions do not sum to one (taxa with no cover class
are dropped after renormalisation, Q4) is extrapolated off the surface
where the smooth is unconstrained. Two options: enforce that the fractions
sum to one before prediction, or replace the 3-D smooth with a 2-D smooth
of two fractions (or a compositional transform). Which do you prefer?

### M2. Calibration on the interpolated field (Q8)
The all-months calibration is fitted to the interpolated modern field,
so most calibration "observations" are outputs of the interpolation
model in cells with no pollen site, and the manuscript still says only
pollen-bearing cells are used. Is calibrating on the interpolated field
the intended design? It raises the effective sample size and smooths the
cover heterogeneity the albedo model is meant to learn from.

### M3. Spatial confounding and what is held fixed (Q12, Q22, Q23)
Location and elevation are identical in every slice, so they cancel in
every slice-to-slice difference and the entire Holocene signal comes from
the cover smooth. The spatial term (k = 500) was fitted alongside it on
the same data and may have absorbed part of the true cover effect. Was
this examined, for example by comparing the cover effect with and without
the spatial term, or by spatially blocked cross-validation? Related: what
is held fixed at 2000-2009 by construction (snow, clouds, atmosphere,
soils, lakes, modern land use, taxon-to-class mapping), and which of
those changed enough over the Holocene to matter?

### M4. Model selection (Q26)
Script 5 hard-codes model 8 as the selected model; the manuscript says
analysis of deviance chose it. On the March point data, AIC preferred
model 2 (no land cover), and the May AIC table increased with model
complexity, which is not possible for correctly fitted nested models and
suggests the beta-regression AIC is unreliable here. Which criterion was
used, did the same model win in all twelve months, and should the paper
say the choice was made on grounds other than AIC?

### M5. Zeros replaced by 0.0001 (Q17)
Albedo values of exactly zero are set to 0.0001 before fitting. On the
logit scale that is about -9, a very influential value for a beta model.
Where do the zeros come from (water, fill values, failed retrievals) and
should they be dropped instead?

### M6. Twelve independent monthly models (Q28)
You said in the meeting that a model with within-year structure would be
better but is out of scope. Should the paper state that "consistent
pattern across months" is an observation rather than a constraint of the
model?

## Differencing, ice and forcing

### F1. Ice contribution: which variant does the paper report? (Q36)
Script 7a computes both a threshold (ice fraction > 0.5) and an
area-weighted representation, each with fixed and scaled glacier albedo,
and script 8 computes forcing for all combinations. Which one is
reported, and how different are the continental totals?

### F2. Ice readvances are averaged away (R8, R9, Q38)
Where the ice fraction increases from one slice to the next, script 7a
replaces it by the mean of its neighbours, so real readvances are erased,
and a `na.rm = TRUE` sum turns such pairs into a confident zero albedo
change that still receives a kernel. Is suppressing readvances deliberate?

### F3. Are the three kernels like for like? (R16, Q42, Q43)
HadGEM3 is a clear-sky top-of-atmosphere kernel; the CAM5 variable used
(`FSNSC`) is a clear-sky surface flux; the CACK band used is not
documented. They also enter with different unit and sign conventions
(HadGEM and CAM5 multiply the albedo change by 100, CACK does not and
flips sign), and the kernel grids are aligned by arithmetic with the
check plots commented out. Could you confirm the intended flux level,
units and sign for each, and whether "forcing not sensitive to kernel"
was checked after putting them on the same footing?

### F4. Clear-sky, pre-industrial kernels across the Holocene (Q41)
Clear-sky kernels are typically larger than all-sky, and early-Holocene
summer insolation at high latitude was well above pre-industrial. What is
the case for this kernel choice, and what would an all-sky kernel do to
the headline numbers?

### F5. The headline comparison (Q44)
The comparison with modern greenhouse-gas forcing sets a local, land-only,
clear-sky, per-interval forcing against a global-mean, all-sky,
cumulative one. What is the fair comparison: the Holocene forcing
expressed as a global mean, or the modern agents expressed locally?

### F6. Consecutive-slice differences and interval length (Q33, Q35)
Forcing is defined per consecutive pair of slices, which do not
accumulate and span different lengths (150 to 500 years). Should a fixed
reference slice be used, or forcing expressed per unit time?

## Land cover

### L1. Taxon-to-class mapping in the north (Q2, Q3)
Betula, Alnus and Salix are mapped to summergreen trees and Ericaceae are
dropped, so dwarf-birch tundra looks like deciduous forest to the model.
Open land lumps prairie, tundra and cropland. Was this examined, and does
it matter in the northern half of the domain where the largest changes
are?

### L2. Age uncertainty and binning (Q7)
How are samples whose age posteriors straddle a bin boundary assigned?
Sharp events such as the hemlock decline can be smeared or sharpened by
that choice.

## Validation

### V1. Independent check of the hindcasts (Q49, Q50)
Is there any out-of-sample test? The last 150 years of Euro-American
clearance, with land-survey or HYDE land cover and published deforestation
forcing estimates, looks like the natural one.
