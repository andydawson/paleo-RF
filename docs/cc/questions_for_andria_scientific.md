# Open questions for Andria: scientific and technical

Maintained by Chris with Claude Code; kept current as work proceeds (see
AGENTS.md). Simple and logistical questions are in
`questions_for_andria_general.md`. Each entry says what the code does now,
why it matters, what the options are, and what we need from you. Line
numbers refer to the code as received (branches `main` / `legacy`).
Updated 2026-09-18.

## A. Uncertainty

### A1. The 200 land-cover draws are averaged away before use
**What the code does.** `veg_posts_interp_ice.RDS` holds 200 posterior
draws (`iter`) of each cover fraction for every cell and time slice.
Script 1 (`1_veg_lct_prep.R`, lines 218-222) takes the mean over the 200
draws and passes a single cover value per cell and slice to everything
downstream. From that point on, no land-cover uncertainty exists in the
pipeline: the calibration is fitted to the mean modern field and the
Holocene hindcasts use the mean paleo field.
**Why it matters.** In the meeting you described the intended approach
as "take multiple samples from the posterior and summarise mean and
sd". Today that summary happens only for land cover, and only implicitly,
because the mean is used and the spread is discarded. The albedo and
forcing results therefore carry none of the uncertainty in the
reconstructions.
**Options.** (i) Keep using the mean, and say in the paper that
land-cover uncertainty is not propagated. (ii) Carry a subset of the
draws (for example 20 to 50 of the 200) through prediction: fit the
calibration once on the mean modern field, then run the hindcast once per
draw and pool the results, so the albedo intervals include land-cover
uncertainty. (iii) Both calibration and prediction per draw, which
multiplies the fitting time by the number of draws and is probably out of
reach.
**What we need from you.** Is (i) acceptable for this paper, or should we
implement (ii)? If (ii), how many draws, and should the calibration also
see the spread?

### A2. What the albedo "posterior samples" actually are
**What the code does.** Script 6 (`6_prediction_model.R`, line 49) calls
`simulate(model, nsim = 100)` on the fitted GAM. With the gratia package
attached, that function draws new *observations* from the fitted beta
distribution at each cell's fitted mean. The model's coefficients are
held fixed; the uncertainty of the fitted albedo-cover relationship is
never sampled. Every `alb_sd`, `alb_lo`, `alb_hi` and the sd and CV maps
in script 7 are therefore the residual scatter of the calibration data
(its beta dispersion), reproduced at each paleo cell, not the model's
uncertainty. The "fraction of data inside the 95% interval" statistic in
script 5 (lines 206-244) checks that the dispersion parameter was
estimated consistently, not that the model is calibrated.
**Why it matters.** The two kinds of uncertainty behave differently.
Observation noise is the same size everywhere and does not grow when the
model extrapolates; coefficient uncertainty grows where the paleo cover
combinations are far from the modern calibration data, which is exactly
where the early-Holocene results live.
**Options.** (i) Keep observation noise, and describe it as such in the
paper. (ii) Replace it with coefficient draws: sample coefficient vectors
from the fitted model's posterior (gratia's `fitted_samples`, or a
multivariate normal from `vcov(model)` applied to the prediction matrix),
which costs seconds per month. (iii) Add both.
**What we need from you.** Which of these did you intend? The manuscript
says "posterior samples", which readers will take to mean (ii).

### A3. 100 or 1,000 draws
The manuscript says 1,000 posterior samples per cell and month; the
scripts draw 100. Which is intended? (This interacts with A1 and A2.)

## B. The calibration model

### B1. The land-cover smooth has one direction with no data in it
**What the code does.** Model 8, the selected model, includes a
three-dimensional smooth `s(OL, ET, ST, bs = "tp", k = 200)`
(`4_calibration_model.R` line 286, and the March version at line 755).
The three fractions always sum to one, so every calibration point lies
on a flat two-dimensional sheet inside the three-dimensional (OL, ET, ST)
space. The smooth has nothing to learn about the direction perpendicular
to that sheet, and `mgcv` reports the fit as rank-deficient: the fitted
March model has rank 444 of 448 coefficients.
**Why it matters.** On the sheet this is harmless. Off the sheet the
smooth is unconstrained, and some paleo rows are off it: script 1
renormalises across all taxa and then drops taxa whose cover class is NA
(`Ericaceae`, `Boraginaceae`, `Plantaginaceae`, `Urticaceae`, lines
54-59), so those rows sum to less than one and are predicted by
extrapolation in the empty direction.
**Options.** (i) Keep the 3-D smooth but renormalise paleo rows to sum to
one before prediction, and check how many rows were affected. (ii) Use a
two-dimensional smooth of two fractions, `s(ET, ST)`, or a compositional
(isometric log-ratio) transform, and refit the ladder.
**What we need from you.** Did you know about the rank deficiency, and do
you have a preference? (ii) changes the model and the results; (i) is a
small correction.

### B2. Calibration on the interpolated field rather than pollen cells
**What the code does.** The all-months calibration reads
`calibration_modern_lct_interp_bluesky.RDS`, the modern slice of the
interpolated product, so it is fitted to all ~2,900 land cells, of which
only ~500 contain pollen sites. The rest are outputs of the interpolation
model. The draft manuscript still says "estimates are made for grid cells
that contain one or more pollen records".
**Why it matters.** Fitting to interpolated cells raises the apparent
sample size and skill of the spatial term, and smooths the cover
heterogeneity the albedo model is meant to learn from; the model is
partly being fitted to another model's output.
**What we need from you.** Is this the intended design, or should the
calibration be fitted to pollen-bearing cells only and the interpolated
field used for prediction alone? Either way the manuscript text needs to
match.

### B2a. The two flavours fit the spatial smooth in different coordinate systems
**Found 2026-09-19** while running the interp pipeline for the first time.

**What the code does.** Scripts 4, 5 and 6 fit the spatial term as
`s(x, y, bs = "gp", k = 500)`, taking whatever columns are named `x` and
`y`. Those columns mean different things in the two flavours:

| Flavour | `x`, `y` are | Range |
|---|---|---|
| non-interp (`lct_paleo_reveals.RDS`) | Albers equal-area metres, with `long`/`lat` held separately | x -3,103,504 to 3,076,936 |
| interp (`lct_*_reveals_interp.RDS`) | **longitude and latitude in degrees**; no projected columns exist | x -171.5 to -53.5 |

In the interp half of `1_veg_lct_prep.R` the `x`, `y` of
`veg_posts_interp_ice.RDS` are passed straight to `get_elev_point(...,
prj = ll_proj)` (line 228) and never projected, so they stay in degrees.

**Why it matters.** A Gaussian-process smooth measures distance between
points, so the units and the geometry matter. In degrees, distance is
anisotropic and latitude-dependent: one degree of longitude is about
105 km at 25°N but only about 38 km at 70°N. The smooth therefore treats
the far north as horizontally compressed relative to the south, which is
exactly the distortion the Albers projection exists to remove, and the
study's largest Holocene changes are in the north. The fitted
length-scale and the effective degrees of freedom of the spatial term
are not comparable between the two flavours either, which may be part of
why our March non-interp results and the talk's interp results differ
over 4 to 6 ka.

**Options.** (i) Leave as is, and state in the methods that the interp
spatial term is fitted on unprojected coordinates. (ii) Project the
interp cell centres to the same Albers grid the non-interp flavour uses,
before calibration, so both flavours and all the published comparisons
share one coordinate system.

**What we need from you.** Was fitting the interp spatial smooth on
degrees intended, or an oversight when the interpolated product was
swapped in? This changes results, so we have not altered it; the first
interp run reproduces the code as written.

### B2b. Winter albedo is missing across the north: polar night
**Found 2026-09-19** in the first interp calibration table.

**What the data show.** The blue-sky albedo has no value for high-latitude
cells in winter, because there is no incoming sunlight to reflect. In the
interp calibration table (2,860 cells):

| Month | Cells with no albedo | Latitudes affected |
|---|---|---|
| December | 1,109 (39%) | every cell above 60°N, 9% of 50-60°N |
| January | 694 (24%) | above 62.5°N |
| November | 400 (14%) | above 66.5°N |
| February | 95 (3%) | far north only |
| March to October | 33 (1%) | above 76.5°N |

**What the code does with them.** The calibration models are fitted with
`na.action = na.omit`, so those rows are dropped silently: the December
model never sees a cell north of 60°N. The prediction step then applies
that model to all 2,860 cells for every time slice, so December albedo
across the whole north is produced by extrapolating both the spatial
smooth and the land-cover smooth into a region and a vegetation range
the model had no data for.

**Why it matters.** This is the month and the region where the paper's
mechanism is strongest: snow masking by vegetation, at high latitude, in
winter. It is also where the Laurentide ice sheet sat, so the
early-Holocene forcing draws on exactly these extrapolated cells. The
spatial term cancels when consecutive slices are differenced (B3), but
the land-cover smooth does not, and in December that smooth was fitted
only on southern vegetation.

**Options.** (i) Keep, and state that winter high-latitude albedo is
extrapolated. (ii) Restrict the reported forcing to months and cells
with calibration support, for example by masking any cell-month whose
latitude lies outside the fitted range. (iii) Weight the annual forcing
by available sunlight, which is near zero exactly where the data are
missing, so the extrapolation would matter much less.

**What we need from you.** Was the winter data gap known, and how do you
want it handled in the maps and in the annual means? Option (iii) may be
the most defensible physically, since a forcing computed where no
sunlight falls is close to meaningless.

### B3. The spatial term cancels through time and may have absorbed the cover effect
**What the code does.** Every prediction uses the same location and
elevation values for a cell in every time slice; only the cover fractions
change. On the link scale the location and elevation terms therefore
cancel in every slice-to-slice difference, and the entire Holocene albedo
signal comes from the shape of the cover smooth alone. That smooth was
fitted alongside a very flexible spatial surface (`s(x, y, bs = "gp",
k = 500)`) on the same modern data.
**Why it matters.** Cover and location are strongly correlated in the
modern data (forest in the east, prairie in the middle, tundra in the
north). A flexible spatial term can take credit for part of the true
cover effect, leaving the cover smooth biased towards zero and the
Holocene forcing understated. The "spatial effects experiment" in scripts
4 and 5 compares fits, not the size of the cover effect.
**What we need from you.** Was this examined, for example by comparing
the cover effect with and without the spatial term, or by spatially
blocked cross-validation? If not, would you like us to?

### B4. Model selection: model 8 is fixed by hand
**What the code does.** Script 4 prints an AIC table and analysis of
deviance for models 1 to 8 (lines 315-335), but script 5 (line 28) loads
model 8 as the selected model for every month unconditionally. On the
March point data AIC preferred model 2, which has no land cover at all.
In our May run the AIC values rose with model complexity, which cannot
happen for correctly fitted nested models and suggests the AIC of these
beta-regression fits is not trustworthy.
**Why it matters.** A model without cover cannot produce any Holocene
change, so cover must be in the model regardless of AIC, but the paper
says analysis of deviance chose the model.
**What we need from you.** Which criterion was actually used, did the
same model win in all twelve months, and how should the paper describe
the choice?

### B5. Calibration response: centre pixel or cell mean
**What the code does.** Script 2 computes both the native 0.25-degree
albedo at the 1-degree cell centre and the 1-degree cell mean
(`_coarse`), and the calibration uses the centre pixel (lines 190 and
195; script 4 line 17). The predictors are 1-degree cell means.
**Why it matters.** A centre pixel over a lake, a city or a clear-cut is
attributed to the whole cell's cover.
**What we need from you.** Was the centre pixel a deliberate choice?

### B6. Albedo values of exactly zero are set to 0.0001
*Checked 2026-09-19: no cell-month in the interp calibration table hits
this replacement, so it affects the non-interp flavour only.*
Script 2 (line 388) replaces zeros with 0.0001 before fitting. On the
logit scale that is about -9, a very influential value for a beta model.
Where do the zeros come from (water, fill values, failed retrievals), and
should those cells be dropped instead?

### B7. Twelve independent monthly models
You said in the meeting that a model with within-year structure would be
better but is out of scope. Should the paper state that "consistent
pattern across months" is an observation rather than a constraint of the
model?

## C. Differencing, ice and forcing

### C0. Three different definitions of where the ice was
**Found 2026-09-19** while looking for the two missing ice inputs.

The pipeline carries three unreconciled representations of ice extent,
and the one script 7a depends on is the one we do not have:

| Source | Form | Coverage | Used by | In the repo? |
|---|---|---|---|---|
| `ice` column of `veg_posts_interp_ice.RDS` | binary `ICE` flag per cell and slice (7.2% of rows) | all 25 slices | the interpolation that made the file; **dropped by `1_veg_lct_prep.R`, which does not carry the column through** | yes |
| `map-data/ice/glacier_shapefiles_21-1k.RDS` | 21 sets of polygons, lon/lat, attributes `SYMBx` and `Area_Km2` | 21 ka to 1 ka in 1,000-year steps | `7_plot_preds.R`, for map overlays and ICE / no-ICE status | yes |
| `Dalton_QSR_2020_Ice/dalton_interpolated_LC6k.tif` | continuous ice fraction per cell and slice | the time slices | `7a_alb_diff_full.R`, for the vegetation/ice split and hence all the forcing | **no** |

**Questions.** Are these three meant to agree? Which is authoritative?
And should script 1 be carrying the `ice` flag through to the
predictions, rather than the pipeline picking the ice up again later
from a different source?

### C0a. `albedo_glacier_monthly.csv` cannot be sourced; what should the values be?
The code needs twelve rows with the columns `month`, `ice_albedo_fixed`
and `ice_albedo_sc` (`7a:264-268`), plus `ice_albedo` for
`7_plot_preds.R` (`7:258-262`). This is not a published dataset, it is a
set of chosen values, so there is nothing for us to download.

Its influence is large: it sets the albedo of every ice-covered cell, so
it drives the deglaciation forcing that dominates 12 to 8 ka.

**What we need from you.** The file if you have it, or the values and
where they came from. Failing that, may we derive them from the
blue-sky albedo product over present-day ice and document the choice?
That would at least be internally consistent, same product and same
months as the calibration. We would also need to know what distinguishes
`ice_albedo_fixed` from `ice_albedo_sc` ("scaled" by what?).

### C0b. The Dalton raster: can we reconstruct it?
`dalton_interpolated_LC6k.tif` is not Dalton et al. 2020's published
data; it is their ice margins interpolated to the LandCover6k time
slices and rasterised to a per-cell fraction, a derived product specific
to this project. The originals are behind the journal paywall with no
open repository we could find, and the interpolation method is not
recorded anywhere in the repository.

**What we need from you.** The file, or the script that made it. If
neither survives, the fallback is to rasterise the ice polygons we do
have onto the 1-degree grid to get a fraction per cell and slice. That
would unblock script 7a, but those polygons look like a different
chronology (probably Dyke, which Dalton updates), so the results would
not reproduce the paper. Would you accept that substitution, and should
the paper then cite the chronology actually used?

### C1. Which ice representation the paper reports
**What the code does.** Script 7a computes two representations of ice in
each cell and slice: a threshold (cell is ice if the Dalton ice fraction
exceeds 0.5) and an area-weighted mix of vegetation and ice albedo. Each
is computed with a fixed glacier albedo and with a scaled one, and script
8 computes forcing for every combination.
**What we need from you.** Which combination do the talk and paper
report, and how different are the continental totals between them?

### C2. Ice readvances are averaged away
**What the code does.** Script 7a (lines 452-459) looks for cells where
the ice fraction increases from an older to a younger slice, and replaces
that value by the mean of its neighbours in time. Real readvances are
erased; the adjustment is applied once, not repeated, and it fails with an
error if the increase occurs in the first pair. A later sum with
`na.rm = TRUE` (lines 526-530) turns such pairs into a confident zero
albedo change that still receives a kernel.
**Why it matters.** The early-Holocene forcing is dominated by ice, so
the rule for handling the ice chronology sets the largest numbers.
**What we need from you.** Is suppressing readvances deliberate? If so we
will clamp the chronology to monotone retreat cleanly; if not we will
keep real readvances.

### C3. The three kernels are not like for like
**Verified on 2026-09-19** by downloading the HadGEM3 and CAM5 kernels
and opening them (README.md records provenance, licences and sizes).

**What the code does and what the files contain.**

| Script reads | Variable long name | Flux level | Sky | Units |
|---|---|---|---|---|
| `8:58` HadGEM3 `albedo_sw_cs` | "SW Surface albedo clear-sky kernel" | **top of atmosphere** | clear-sky | W/m² per 1% |
| `8:163` CAM5 `FSNSC` | "Clearsky net solar flux at **surface**" | **surface** | clear-sky | W/m² per 1% |
| `8:197` CACK band 3 | not yet checked (file not obtained) | top of atmosphere | ? | ? |

**Good news on units.** Both files are per 1% albedo change: HadGEM3
states `units = W/m2/%`, and Pendergrass et al. (2018, §2.1) define their
albedo kernel as "the change in radiative flux for a 1 % change in
surface albedo". So the `alb_diff * 100 * kernel` convention at
`8:256-301` is right for both, and the talk's "W/m²/%" is correct.

**The problem.** The two kernels answer different questions: HadGEM3
gives the change in flux at the top of the atmosphere, CAM5 the change at
the surface. They are not comparable, so "radiative forcing was not
sensitive to kernel" is comparing unlike quantities. The like-for-like
CAM5 variable is `FSNTC`, "Clearsky net solar flux at top of model",
which is in the same file, so the fix is a one-word change.

**Also available at no cost.** Each file contains its all-sky twin
(HadGEM3 `albedo_sw`, CAM5 `FSNT`/`FSNS`), so the clear-sky versus
all-sky test in C4 needs no new download.

**What we need from you.** (a) Was top of atmosphere the intended flux
level throughout? If so, may we switch CAM5 to `FSNTC` and re-run the
comparison? (b) Which CACK band is band 3, and is it top of atmosphere,
all-sky or clear-sky? (c) The kernel grids are aligned to the data by
arithmetic on longitude and latitude (`8:230-250`) with the check plots
commented out; was that verified?

### C4. Clear-sky, pre-industrial kernels across the Holocene
The HadGEM kernel is clear-sky and pre-industrial. Clear-sky albedo
kernels are typically 1.5 to 2 times larger than all-sky because clouds
mask the surface, and early-Holocene summer insolation at high latitudes
was tens of W/m² above pre-industrial. What is the case for this choice,
and would an all-sky kernel change the headline numbers?

### C5. The comparison with modern forcing agents
The talk compares the Holocene forcing with IPCC forcing from modern
agents. The Holocene number is local to North American land, clear-sky,
and per interval; the IPCC numbers are global means, all-sky, and
cumulative since 1750. North American land is a few percent of Earth's
surface. What is the fair comparison: the Holocene forcing expressed as a
global mean, or the modern agents expressed regionally?

### C6. Consecutive-slice differences and interval length
Forcing is defined per consecutive pair of slices. The pairs span
different lengths (150, 300, 500 years) and do not accumulate to a change
relative to a baseline. Should a fixed reference slice be used, or forcing
be expressed per unit time?

### C7. The 11.5 ka slice is labelled 12 ka
Script 7 relabels age 11,500 as 12,000 for plotting (line 100); script 7a
does not. Is 12 ka the intended label, and is it the same slice? (The
broader time-slice question is in the general file.)

## D. Land cover

### D1. Taxon-to-class mapping in the north
`taxon2LCT_translation_v2.0.csv` maps Betula, Alnus and Salix to
summergreen trees and drops Ericaceae, so dwarf-birch tundra looks like
deciduous forest to the model, and open land lumps prairie, tundra and
cropland with very different albedo. Was this examined? It matters most
in the north, where the largest Holocene changes are.

### D2. Age uncertainty and binning
How are samples whose age posteriors straddle a bin boundary assigned to
time slices? Sharp events such as the hemlock decline can be smeared or
sharpened by that choice.

## E. Validation

### E1. Independent check of the hindcasts
Is there any out-of-sample test of the hindcast albedo? The last 150
years of Euro-American clearance, with land-survey or HYDE land cover and
published deforestation forcing estimates, looks like the natural one.
