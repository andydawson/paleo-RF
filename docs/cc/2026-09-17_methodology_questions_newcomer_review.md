# Newcomer's questions on the methodology

Written 2026-09-17 by an independent review pass over the draft manuscript,
the EGU talk and scripts 1, 2, 4, 5, 6, 7a and 8, for Chris to take to the
coauthors. The aim is fundamental "why this, did you consider that" questions
from a quantitative scientist new to paleoecology, albedo and radiative
forcing. Code-level defects are in `2026-09-16_known_issues_missing_data_and_code.md` and are not repeated.
Line numbers refer to `main`. Questions marked **[key]** are the ten to ask
first. Code citations were spot-checked (kernel variables, ice-readvance
averaging, taxon table, cell areas) before this was committed.

## 1. Pollen to land cover (REVEALS, classes, grid, slices)

1. **[key]** What calendar years does the "modern" (age 50) slice actually represent, and how well does it match the 2000-2009 albedo it is calibrated against? If the slice is 0-100 cal BP it is roughly 1850-1950 CE, i.e. before or during peak agricultural clearance in the east and before the 20th-century reforestation of New England; the pollen and the satellite would then be describing two different landscapes.
   *Draft §2.2 lists the youngest slice as "present-100 YBP"; script 7a uses ages 50, 200, 500 ... 11500.*

2. Why three cover classes? Open land lumps prairie, tundra, cropland, wetland and post-fire ground, which have very different albedo (especially spring bare soil versus snow-covered tundra). What is lost by not splitting OL into at least herbaceous/cropland vs tundra, and what would a fourth class (shrub, or bare/water) do to the calibration?
   *`data/taxon2LCT_translation_v2.0.csv`: Poaceae, Cyperaceae, Artemisia, Ambrosia and chenopods are all OL.*

3. Shrub taxa that dominate the tundra-taiga transition (Betula, Alnus, Salix) are mapped to "summergreen trees"; Ericaceae are dropped (NA). Does a cell of dwarf birch tundra therefore look to the model like a deciduous forest, and what does that do to albedo in the northern half of the domain, where the biggest Holocene changes are?
   *Same CSV; Larix is also ST.*

4. Do ET + ST + OL sum to one in every cell and slice? Taxa with LCT = NA are dropped after the per-cell renormalisation, so the fractions can sum to less than one; the calibration smooth is fitted on the 2-simplex and it matters whether paleo points sit on it.
   *`scripts/1_veg_lct_prep.R` L54 renormalises across all taxa, then L59 aggregates by LCT with NA rows dropped.*

5. REVEALS depends on modern pollen productivity estimates, fall speeds and the assumption that these are constant through time and across the continent. How sensitive is the cover reconstruction to the PPE set, and does any of that uncertainty reach the albedo step?
   *Talk slide 8 lists the REVEALS inputs; nothing downstream reads REVEALS uncertainty.*

6. **[key]** REVEALS posterior draws are collapsed to a single mean per cell, slice and class before anything else happens. So does land-cover uncertainty (age models, pollen counts, PPEs, interpolation) propagate into the albedo or forcing at all? If not, what do the credible ribbons on the forcing plots represent?
   *`scripts/1_veg_lct_prep.R` L220-222: `summarize(value = mean(value))` over the interpolated posterior; non-interp path uses `mediansim`.*

7. How is age uncertainty handled when assigning pollen samples to 500- or 1000-year bins? Are samples with age posteriors spanning a boundary split, assigned to one bin, or resampled? A sharp event such as the hemlock decline can be smeared or sharpened by this choice.
   *Draft §2.2 refers to Tunski et al. (in prep) for the age models.*

8. **[key]** The calibration set is the *interpolated* modern field, so most of the calibration "observations" are Bayesian-interpolation output in cells with no pollen site. Doesn't that make the calibration partly a model fitted to another model, inflate the apparent sample size and skill of the spatial term, and smooth away exactly the cover heterogeneity the albedo model is supposed to learn from? Why not calibrate on pollen-bearing cells only and predict on the interpolated field?
   *`scripts/4_calibration_model.R` L17 reads `calibration_modern_lct_interp_bluesky.RDS`; the draft §2.2 still says estimates exist "for grid cells that contain one or more pollen records".*

9. How many pollen records inform each slice, and how does the count fall off before 8 ka? For early-Holocene cells with no nearby record, the interpolated cover is essentially a prior; should those cells be masked or flagged in the forcing maps?

10. Why a 1-degree grid? A cell is ~100 km x 70-110 km, which contains whole mountain ranges in the west. Was a finer grid, or a grid in equal-area projection, considered, and how was the elevation of a cell chosen (currently the centre point, not the cell mean)?
    *`scripts/1_veg_lct_prep.R` L96, L230: `get_elev_point` at cell centroids.*

11. The time slices in the code are regular 500-year steps to 11.5 ka, but the manuscript describes irregular slices (100-350, 350-700, 700-1500, then 1000-year). Which is it, and are differences over a 150-year interval (50 to 200) reported on the same footing as differences over 500 years?
    *Draft §2.2 vs `scripts/7a_alb_diff_full.R` L9.*

## 2. Modern satellite calibration applied to the whole Holocene

12. **[key]** The model is a space-for-time substitution: a modern cross-sectional relationship between cover and albedo is assumed to hold at every time in the past. What is held fixed by construction (snow climatology, cloudiness and diffuse fraction, atmosphere, insolation, soils, water bodies, human land use, species-to-class mapping), and which of these are known to have changed over the Holocene enough to matter for albedo?

13. Snow is fixed at its 2000-2009 climatology in every slice. Since the vegetation-albedo effect at these latitudes is mostly the snow-masking effect, what does an "albedo forcing" mean when the snow regime that mediates it is not allowed to change, and how should the limitation be stated?
    *`2026-09-17_manuscript_and_talk_outline.md` flags this; it is not in the draft methods.*

14. In the modern data, high open-land fraction in mid-latitude cells is mostly cropland; in the mid-Holocene the same cells were prairie. Does the calibration therefore encode cropland albedo (bare soil in spring, stubble, irrigation) as the albedo of "open land", and how big is the difference between cropland and native grassland albedo in the months that matter?
    *Draft §2.1 argues land use has "negligible impact ... for non-urban areas".*

15. Do the Holocene cover combinations fall inside the modern calibration range? Early-Holocene spruce parkland, tundra-steppe and open Picea woodland may have no modern 1-degree analogue. What fraction of paleo cell-slices lie outside the convex hull of the modern (OL, ET, ST) points, and how does the thin-plate smooth behave when extrapolating there?
    *`scripts/4_calibration_model.R` L286: `s(OL, ET, ST, bs='tp', k=200)`.*

16. The response is a 0.25-degree MODIS pixel value sampled at the 1-degree cell centre, while the predictors are 1-degree cell means. Why not use the cell-mean albedo that the script also computes? A centre pixel over a lake, a city or a clear-cut is attributed to the whole cell's cover.
    *`scripts/2_calibration_lct_bluesky.R` L383 extracts the native raster at points; L378 computes the coarse `method="average"` version but the saved calibration file uses the native extraction.*

17. Where do the albedo values of exactly zero come from, and why are they set to 1e-4 rather than dropped? On the logit scale 1e-4 is about -9, a very influential observation for a beta model. Are these water pixels, fill values, or failed retrievals?
    *`scripts/2_calibration_lct_bluesky.R` L388: `bs_interp_df[bs_interp_df==0] = 1e-4`.*

18. How were snow-covered retrievals treated in the MODIS quality filtering? If snow pixels are excluded (or if the quality flag removes most winter data at high latitude), the winter "blue-sky albedo" is not the real surface albedo, and the winter forcing would be wrong in exactly the season where vegetation matters most.
    *Draft §2.1: filtered on the shortwave quality layer; no mention of the snow flag.*

19. Why 2000-2009 specifically, and not the full MODIS record or a period chosen for good snow-year coverage? Is a single decade's mean albedo representative of a climatology, given interannual snow variability?

20. Water bodies: cells around the Great Lakes, Hudson Bay, and the Canadian Shield lake district have large open-water fractions with low albedo (or ice in winter). Are water fractions masked, held fixed, or silently absorbed into the spatial term?

## 3. The statistical calibration model

21. Why a beta regression GAM rather than, say, a Gaussian model on the logit scale or a Bayesian spatial model? The beta likelihood describes a single proportion; the response here is a 10-year mean of monthly means, whose variance structure is not that of a beta variate.

22. **[key]** The prediction through time changes only the cover inputs; the spatial and elevation terms are identical in every slice. On the link scale they cancel in every consecutive difference, so the entire Holocene signal comes from the shape of the `s(OL, ET, ST)` smooth alone. Given a `k=500` Gaussian-process spatial term fitted to the same data, how much of the true cover effect has been absorbed by space (spatial confounding), and is the cover smooth therefore biased toward zero?
    *`scripts/4_calibration_model.R` L286; the "spatial effects experiment" (L340-425) compares fits, not the size of the cover effect.*

23. What does it mean physically to keep a modern spatial term fixed for 12,000 years? It encodes modern snow, cloud, soil, land-use and lake patterns at each location; at 11 ka a cell 200 km south of the ice margin had none of those modern properties.

24. Elevation: the effect is fitted on cell-centre elevation and held fixed. Is it there as a snow proxy? If so it duplicates the spatial term and again bakes in modern snow.

25. Basis sizes: 500 (space) + 50 (elevation) + 200 (cover) basis functions for how many calibration cells? What are the effective degrees of freedom, and were the `gam.check` k-index diagnostics acceptable in every month?

26. Model selection: the manuscript says analysis of deviance chose the model; the code writes an AIC table and then hard-codes model 8 regardless. Which criterion was actually used, does the same model win in all 12 months, and what happens in months where the cover term is not supported (the March non-interp AIC preferred a model without cover)?
    *`scripts/5_calibration_eval.R` L28-33 load mod8 and save it as "selected" unconditionally.*

27. The cover smooth is a 3-D thin-plate smooth of three variables that sum to one, i.e. a 2-D manifold in 3-D. Why not a 2-D smooth of two of the fractions (or a compositional transform)? Does the redundant dimension cause identifiability or extrapolation problems?

28. Twelve independent monthly models: nothing constrains the seasonal cycle to be smooth or the cover effect to be coherent across months. Is the "consistent pattern across months" a result or an assumption, and would a single model with a month term be more defensible?
    *Talk slide 17.*

29. **[key]** What uncertainty do the 100 (manuscript: 1,000) "posterior samples" represent? `simulate()` on a GAM draws new *observations* from the fitted beta distribution at the fitted mean; unless the coefficients are also resampled, this is pixel-level sampling noise with no model-parameter uncertainty. And since the differencing uses only `alb_mean`, does any of it reach the forcing?
    *`scripts/6_prediction_model.R` L49-51 (`simulate(..., nsim=100)`, with gratia loaded); `scripts/7a_alb_diff_full.R` L270 uses `alb_mean` only.*

30. `alb_mean` in the paleo summary is the mean of 100 random draws, not the model's point prediction, so each cell carries Monte Carlo noise of order sd/10 that is then differenced between slices. Why not difference the point predictions?
    *`scripts/6_prediction_model.R` L65-73.*

31. The calibration evaluation reports correlation and interval coverage on the training data. Was any out-of-sample check done (spatially blocked cross-validation, or leave-region-out), since the spatial term can reproduce the training data almost by construction?
    *`scripts/5_calibration_eval.R` L228-244.*

32. Why calibrate over 10-80N (including Mexico and Central America, where the temperate taxon list barely applies) and then report forcing only for 27-74N?
    *`scripts/1_veg_lct_prep.R` L25-26; `scripts/8_radiative.R` L253-254.*

## 4. Differencing and ice-sheet handling

33. Why consecutive-slice differences rather than differences from a fixed reference (e.g. the modern or pre-industrial slice)? A radiative forcing is conventionally defined relative to a baseline; per-interval differences do not accumulate and cannot be compared directly to a 1750-to-2019 forcing.

34. **[key]** Is any slice-to-slice change tested against its uncertainty? With 25 slices and smooth interpolated cover, sign reversals between adjacent slices (e.g. 6-4 ka and 4-2 ka) could be noise. The talk asks "when does the signal emerge from the noise?" for vegetation but no equivalent is shown for forcing.
    *Talk slide 10; draft results bullets on the 6-4 ka reversal.*

35. Intervals of different length (150, 300, 500 years) are differenced as if equivalent. Should forcing be expressed per unit time, or at least should the short late-Holocene intervals be flagged when compared with 500-year ones?

36. Two ice representations are computed (0.5 threshold and area-weighted "parts") and both fixed and "scaled" glacier albedo; which combination does the paper report, and how different are the continental totals between them?
    *`scripts/7a_alb_diff_full.R` L288-302 and L495-530; `scripts/8_radiative.R` computes all 30 combinations.*

37. Where does the prescribed monthly glacier albedo come from, and is a single value appropriate for the whole Laurentide margin (debris-covered, ablation-zone ice in summer versus snow-covered interior)? Its value directly sets the dominant 12-8 ka forcing.
    *`data/albedo_glacier_monthly.csv`, source unknown per KNOWN_ISSUES §2.1.*

38. Ice-sheet extent has no uncertainty, and the code averages away any interval where ice fraction increases forward in time (readvances). Is suppressing ice growth deliberate, and how sensitive is the early-Holocene forcing to the Dalton chronology?
    *`scripts/7a_alb_diff_full.R` L452-459 (`ice_frac_adj`).*

39. Newly deglaciated land is assigned the younger slice's vegetation albedo immediately. In cells without pollen sites the interpolated cover comes from forested neighbours, so a proglacial-lake or bare-ground stage becomes forest at once. Does this overstate the deglaciation warming?
    *`scripts/7a_alb_diff_full.R` L497.*

40. The ice-masked interpolation means an ice-covered cell has no cover in the old slice; the vegetation part of the difference is then NA and the "thresh" sum uses `na.rm=TRUE`. Are NA-plus-ice cells being counted as pure ice-to-vegetation transitions, and does the continental average treat NA as zero?
    *`scripts/7a_alb_diff_full.R` L526-530.*

## 5. Radiative forcing

41. **[key]** The kernels are pre-industrial (1850 orbit, CO2, clouds) and the HadGEM one is clear-sky. Early-Holocene summer insolation at 65N was tens of W/m2 higher, and clear-sky kernels are typically 1.5-2x larger than all-sky because clouds mask the surface. What is the case for using this kernel across the Holocene, and what would an all-sky kernel do to the headline numbers?
    *Draft §2.5 justifies clear-sky as "forcing potential".*

42. Which flux level does each kernel report? The HadGEM file is a TOA kernel; the CAM5 variable used (`FSNSC`) is net *surface* clear-sky solar flux, not the TOA field; and the CACK band index is unexplained. If they mix TOA and surface, "forcing not sensitive to kernel" may be a coincidence.
    *`scripts/8_radiative.R` L58 (`albedo_sw_cs`, level 1), L163-165 (`FSNSC`), L197-200 (`band=3`).*

43. Units and sign: HadGEM and CAM5 are multiplied by `alb_diff*100` (per-percent kernels), CACK by `alb_diff` with a sign flip. Has each kernel's documented unit and sign convention been checked, and are the three results on the same scale? The talk says the kernel is "W/m2/%" and the albedo shift is in %, but the differences are in fractions.
    *`scripts/8_radiative.R` L256-301; talk slide 14 notes.*

44. **[key]** The comparison with modern greenhouse-gas or methane forcing pits a local, clear-sky, per-interval, land-only number against a global-mean, all-sky, cumulative (1750-2019) one. North American land is a few percent of Earth's surface; what is the Holocene vegetation forcing expressed as a global mean, and is that the number that should be compared?
    *Draft results: "about as strong as modern greenhouse gas forcings"; talk slide 18.*

45. Are continental means area-weighted? Cell area is computed in 7a but not used in 8; a 1-degree cell at 70N is a third the size of one at 30N.
    *`scripts/7a_alb_diff_full.R` L218-222; `scripts/8_radiative.R`.*

46. Is the annual forcing the mean of the twelve monthly forcings, and are cells with missing months (winter no-data at high latitude) handled consistently?

47. Why restrict to 27-74N in the forcing step and not earlier? Is it kernel coverage, data density, or something else?

48. Radiative forcing is not temperature. Converting local surface-albedo forcing to a temperature response needs a climate sensitivity and an efficacy, and land-albedo forcing has low global efficacy. Should the paper compute forcing at all, or the more physically comparable "radiative forcing equivalent" of prior deforestation studies?

## 6. Validation

49. **[key]** How would anyone know the hindcast albedo is right? Is there any independent test: e.g. predicting the 1850-to-present albedo change from land-survey (PLSS/witness-tree) or HYDE land-cover reconstructions and comparing with published estimates of Euro-American deforestation forcing; or predicting albedo in a held-out region or in a different decade of MODIS?
    *Draft results already cite historical surveys for the last 500 years; that is the obvious validation target.*

50. Could the method be tested on the one interval where the answer is known from other means, the last century, by comparing predicted albedo change against, for example, the difference between MODIS and early AVHRR products, or against a land-use-driven albedo change from a land-surface model?

51. The model's skill (r about 0.95) is dominated by the latitudinal snow gradient captured by the spatial term. What is the skill of the cover term alone, i.e. the partial R2 or the correlation of the cover-only prediction with the residual after space and elevation?

52. Does the sign of the modelled cover effect agree with the flux-tower and remote-sensing literature (evergreen darker than deciduous in winter/spring, forest darker than open land with snow) in every month? A table of the marginal effect of each class by month would answer this.

## 7. Scope and framing

53. The Holocene Temperature Conundrum is about global or hemispheric temperature. What is the argument that North American vegetation albedo, expressed as a local forcing, bears on it, especially when the dominant early-Holocene term is ice retreat that the Conundrum models already include?

54. The paper frames vegetation change as a "forcing", but most of it (succession after deglaciation, prairie expansion, treeline shifts) is a response to climate. Is this a one-way forcing estimate or a partial feedback, and does the paper claim the vegetation change caused the temperature change or merely amplified it?

55. Non-radiative effects of the same vegetation shifts (evapotranspiration, roughness, cloud feedbacks) are often of the same magnitude as, and opposite sign to, the albedo effect in mid-latitudes. Should the paper state that albedo is one term of the biogeophysical budget, not the net effect?

56. The take-home "pre-industrial forests were not in steady state" rests on the 6-4 ka sign reversal and the hemlock decline. Given questions 6, 29 and 34, is that conclusion robust to the uncertainty that is currently not propagated?
    *Talk slide 19.*

57. The talk calls the calibration a Bayesian hierarchical model; the code is a frequentist REML GAM with a GP basis. Which is the intended description, and does the difference matter for how uncertainty is interpreted?
    *Talk slide 13 notes; draft §2.3.*

58. What is the intended use of the product: an observational constraint for ESMs (as the Introduction says), or a stand-alone estimate? If the former, which quantity (albedo maps, cover maps, or forcing) is the deliverable, and at what resolution and uncertainty would a modeller need it?
