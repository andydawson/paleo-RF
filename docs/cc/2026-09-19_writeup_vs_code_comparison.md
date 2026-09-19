# Where the write-ups and the code disagree

A claim-by-claim comparison of the methodology as described in the draft
manuscript and the EGU talk against the methodology as implemented in
Andria's original code (tag `v0-legacy`, commit `c9d525e`). All
`script:line` citations refer to that commit, not to any later edit on
`chris-dev` or `run-interp`.

The paper's results come from the interp code path, so that path is
weighted throughout; where a claim matches one flavour and not the other
it is said so explicitly.

Verdicts: **match**, **mismatch** (code does something different),
**unverifiable** (step is outside the repository), **undescribed** (code
does something methodologically significant that neither write-up
mentions). Materiality: *results* (changes numbers), *interpretation*
(changes what the numbers mean), *presentational* (wording only).

Findings already recorded elsewhere carry a pointer rather than a
restatement; `QS` means `questions_for_andria_scientific.md`.

## Summary table

| # | Claim | Source | What the code does | Verdict | Materiality |
|---|---|---|---|---|---|
| 1 | "estimates are made for grid cells that contain one or more pollen records" | MS 2.2 | interp calibration and prediction run on all 2,860 grid cells, most with no pollen record | mismatch | interpretation (QS B2) |
| 2 | Time periods "present-100, 100-350, 350-700, 700-1500 YBP, and 1000 year intervals prior" | MS 2.2 | slices are 50, 200, 500, then every 500 yr to 11,500 (25 slices) | mismatch | results (QS C7) |
| 3 | "extending from present day to 12,000 YBP" | MS 2.2 | oldest slice is 11,500; `7_plot_preds.R:100` relabels it 12,000 for plotting, `7a` does not | mismatch | presentational (QS C7) |
| 4 | "we drew a set of 1,000 albedo posterior samples" | MS 2.4 | `nsim = 100` (`6:49`) | mismatch | results (QS A3) |
| 5 | "posterior samples" | MS 2.4 | `simulate()` draws beta **observation** noise at fixed coefficients; no coefficient uncertainty | mismatch | interpretation (QS A2) |
| 6 | "a Bayesian hierarchical model that accounts for spatial dependence" | Talk 13 notes | frequentist REML GAM with a GP basis (`4:202-290`) | mismatch | interpretation |
| 7 | "GAM models were fit using the BAM R package" | MS 2.3 | `bam` is a function in **mgcv**, not a package | mismatch | presentational |
| 8 | "We used analysis of deviance with the chi-squared test to compare among models" | MS 2.3 | `anova.gam(..., test="Chisq")` and `AIC()` are computed (`4:326-336`), but `5:28` hard-codes mod8 regardless; and the fits are REML, so cross-model likelihood comparison is not valid | mismatch | interpretation (QS B4) |
| 9 | "spatial location as a two dimensional Gaussian process predictor" | MS 2.3 | `s(x, y, bs="gp", k=500)`, but in the interp flavour `x`,`y` are **degrees**, not projected metres | mismatch | results (QS B2a) |
| 10 | "elevation as a smooth predictor" | MS 2.3 | `s(elev, k=50)` | match | — |
| 11 | "beta distribution with the logistic link" | MS 2.3 | `family=betar(link="logit")` | match | — |
| 12 | "difference in mean estimated albedo for consecutive pairs of time intervals" | MS 2.4 | `-diff(alb_veg)` on consecutive slices, younger minus older (`7a:495`); but `alb_veg` is the mean of 100 unseeded draws, not the point prediction | match in scheme, mismatch in quantity | results |
| 13 | "we use the clear-sky **surface** kernel" | MS 2.5 | loads the **TOA** kernel file, variable `albedo_sw_cs` (`8:58`); a separate surface kernel exists in the same Zenodo record and is not used | mismatch or ambiguous | results (QS C3) |
| 14 | Kernel comparison across HadGEM3, CAM5, CACK | Talk 14 | HadGEM3 TOA vs CAM5 `FSNSC` (surface flux) — not like for like | mismatch | results (QS C3) |
| 15 | "units of W/m^2" from multiplying albedo shift by kernel | MS 2.5 | `alb_diff*100*kernel` for HadGEM3 and CAM5, both per-1% kernels: correct. CACK uses `alb_diff*(-rk_cack)` with no ×100 and a sign flip (`8:291`) | match for two, unverifiable for CACK | results |
| 16 | **"area-weighted relative abundance ... sum by land cover class ... for unglaciated land grid cells ... scale by the maximum sum of forest relative abundance"** | MS 2.5 final para; Talk 11 | **no code anywhere implements this**; and `1_veg_lct_prep.R:218-222` discards the `cell_area` and `ice` columns the calculation needs | undescribed / missing code | results |
| 17 | "forest cover increased from around 55% to 91%" between 11.7 and 7.0 ka | Talk 11 notes | not reproducible: our recomputation gives 65% to 96% on unglaciated cells, 84% to 96% on all cells | mismatch | results |
| 18 | Continental forest "stable 4.5 to 1.5 ka, then declined from 1.5 ka" | Talk 11 notes | reproduced: 1.000 at 4.5 ka, 0.994 at 1.5 ka, 0.933 at 50 yr | match | — |
| 19 | **Radiative forcing figures** (MS F2 "Annual RF", F3 "Hemlock RF", Fig 2 RF maps, Fig 3 RF bar plot; Talk 15-18) | MS Figures; Talk | **no code produces any forcing figure**: `8_radiative.R` has zero live `ggsave` calls and `7a` has none either | undescribed / missing code | results |
| 20 | Regional case studies: eastern North America, hemlock region, western Canada | MS Results notes | no code defines these regions anywhere | undescribed / missing code | results |
| 21 | Blue-sky formula from MODIS black/white sky weighted by ERA5 diffuse fraction | MS 2.1 | no code; the repository begins from the finished GeoTIFF | unverifiable | — |
| 22 | "filtered using the shortwave quality layer" | MS 2.1 | no code; snow-flag handling unknown | unverifiable | — |
| 23 | REVEALS run and the Bayesian spatial interpolation | MS 2.2; Talk 8-9 | outside the repository by agreement | unverifiable | — |
| 24 | Forcing restricted to 27°N-74°N | not stated | `8:253-254` | undescribed | interpretation |
| 25 | Winter high-latitude albedo is absent (polar night) and silently dropped | not stated | `na.action=na.omit`; December has no data above 60°N | undescribed | results (QS B2b) |
| 26 | Snow is never modelled; modern snow climatology is held fixed | not stated | no snow term anywhere | undescribed | interpretation (QS, manuscript outline) |
| 27 | Ice readvances are averaged away | not stated | `7a:452-459` | undescribed | results (QS C2) |
| 28 | The cover smooth is rank deficient | not stated | `s(OL,ET,ST)` on fractions summing to 1 | undescribed | results (QS B1) |

## Mismatches that matter most

### A. The headline forcing figures have no code

The manuscript lists F2 "Annual RF", F3 "Hemlock RF", "Figure 2: Holocene
RF prediction maps" and "Figure 3: RF bar plot Holocene and modern". The
talk shows forcing maps for 12-10 ka and 500-50 yr (slides 15, 16),
continental trends by month (17) and the comparison against IPCC modern
forcing agents (18) — the slide Andria singled out as the one that makes
audiences react.

`8_radiative.R` computes about thirty `rf_*` columns and saves the data
frame at `8:346`. It contains **no live `ggsave` call**; the only two are
commented-out projection checks at `8:180` and `8:214`. `7a_alb_diff_full.R`
has none either. Counting live `ggsave` calls across the whole repository:
script 2 has 20, script 3 has 16, script 5 has 18, script 6-spatial-eval
has 3, script 7 has 25, and scripts 7a and 8 have zero.

So every figure that presents the project's actual result was made by
code that is not in the repository. This is more consequential than any
single numerical discrepancy: the analysis can be re-run to the forcing
table, but nothing in the repository turns that table into the paper's
claims.

### B. The continental summary described in 2.5 is not implemented

The manuscript's final methods paragraph describes a specific
calculation: sum relative abundance by land cover class and for forest
(ETaS + STaS) over **unglaciated** land grid cells, area-weighted, then
scale by the maximum forest sum. This is the basis of the talk's slide 11
and of the Results bullet "Forest cover increased throughout the
Holocene, from x% to y%".

No code performs it. `st_area` appears at `7a:218-220` but only to attach
an area column to the difference table, and script 8 never uses that
column. More tellingly, the two inputs the calculation needs are thrown
away at the first step: `1_veg_lct_prep.R:218-222` averages the posterior
draws and keeps only `ages, x, y, elev, ET, OL, ST`, dropping both
`cell_area` and the `ice` flag that `veg_posts_interp_ice.RDS` provides.
Downstream, nothing knows cell areas or which cells were glaciated.

Reconstructing it approximately (cos-latitude weighting for area, and the
ice mask recovered by point-in-polygon against the shapefiles, which is
exactly equivalent to the dropped flag) gives:

| Age | Scaled forest sum, unglaciated cells | All cells |
|---|---|---|
| 11,500 | 0.65 | 0.84 |
| 11,000 | 0.66 | 0.84 |
| 10,000 | 0.77 | 0.94 |
| 7,000 | 0.96 | 0.96 |
| 4,500 | 1.00 | 0.99 |
| 1,500 | 0.99 | 0.99 |
| 50 | 0.93 | 0.92 |

The shape the talk describes reproduces well: a strong early-Holocene
rise, a mid-Holocene plateau from about 4.5 to 1.5 ka, and a late decline
to the present. The stated endpoints do not: the talk's "around 55% to
91%" against our 65% to 96%. The gap could come from the exact slice
(11.7 ka is not one of ours), from true spherical cell areas against the
cos-latitude proxy, from a different normalisation year, or from an
earlier version of the land-cover product. Without the code it cannot be
settled.

Note also what the metric is. Because it is a *sum* over available cells
and not a mean fraction, it rises largely because deglaciation exposes
land. The mean forest fraction per cell barely moves across the Holocene:
0.54 at 11.5 ka, 0.62 at 7 ka, 0.56 today. The talk's own speaker note
concedes this ("closely tracks the increase in available land surface
area"), but the Results bullet "forest cover increased from x% to y%"
invites a reader to hear it as vegetation change.

### C. "Estimates are made for grid cells that contain one or more pollen records"

Manuscript 2.2, describing the land-cover input. In the interp path the
calibration is fitted, and predictions are made, on all 2,860 grid cells,
the large majority of which contain no pollen record and whose land cover
is the output of the Bayesian interpolation. The sentence describes the
non-interp product that the project moved away from. See QS B2.

### D. "Clear-sky surface kernel" versus the file actually read

Manuscript 2.5 says "we use the clear-sky surface kernel". `8:58` reads
`HadGEM3-GA7.1_TOA_kernel_L19.nc`, variable `albedo_sw_cs`, whose long
name is "SW Surface albedo clear-sky kernel" — that is, a
**top-of-atmosphere flux** response to a **surface albedo** perturbation.
The same Zenodo record contains `HadGEM3-GA7.1_srf_kernel_L19.nc`, a
genuine surface-flux kernel, which is not used.

The manuscript phrase is therefore either loose wording for "surface
albedo kernel" or a description of a different file from the one used. It
must be disambiguated, because the CAM5 variable the code pairs it with,
`FSNSC`, genuinely is a surface flux, so the two kernels are not
comparable. See QS C3.

### E. Sign convention is inconsistent within script 8

The forcing columns use `+rk_hadgem` and `+rk_cam5` (`8:256-266`,
`8:269-...`), while the diagnostic plots at the end of the same script use
`-rk_hadgem*100` and `-rk_cam5*100` (`8:331`, `8:337`) and `+rk_cack`
where the forcing uses `-rk_cack` (`8:291`). Both conventions cannot be
right. Neither write-up states a sign convention. This is not currently
in QS; it belongs with C3.

### F. Model description omits the ladder's purpose and outcome

Manuscript 2.3 describes "a suite of models that consider different
specifications of land cover predictors" and a factorial spatial
experiment, both of which exist (`4:202-295` and `4:353-428`). What it
does not say is which model was used, and the code does not select one:
`5:28` loads mod8 unconditionally for every month. See QS B4.

## Undescribed behaviour

Methodologically significant things the code does that neither write-up
mentions. Those already documented carry a pointer.

- Forcing is restricted to 27°N-74°N (`8:253-254`). Not stated anywhere,
  and it silently excludes the highest-latitude cells, which are where
  the ice signal is largest.
- Winter albedo is missing across the north and dropped silently; QS B2b.
- Snow is never modelled; the 2000-2009 snow climatology is held fixed
  for every slice; recorded in the manuscript outline.
- Ice readvances are averaged out of the chronology (`7a:452-459`); QS C2.
- The land-cover smooth is rank deficient because the fractions sum to
  one; QS B1.
- The interp spatial smooth is fitted on unprojected degrees; QS B2a.
- `1_veg_lct_prep.R` discards `cell_area` and the `ice` flag, which is
  what forces the later scripts to obtain ice from a separate file; QS C0.
- Script 4 fits the eight-model ladder for every month and then refits
  mod8 for every month again (`4:443-527`), roughly doubling the cost for
  no additional result.

## Unverifiable claims

Steps described in the write-ups for which the repository holds no code,
so the description can be neither confirmed nor contradicted:

- The entire blue-sky albedo construction of manuscript 2.1: the MODIS
  MCD43A3 quality filtering, the ERA5 diffuse fraction, the weighting
  formula and the averaging across years. The repository begins from the
  finished GeoTIFF.
- The REVEALS run and the Bayesian spatial interpolation of manuscript
  2.2 and talk slides 8-9. Out of scope by agreement with Andria.
- The CACK kernel's flux level, sky condition, units and band, since the
  file has not been obtained.
- The regional case studies in the Results notes. No code defines
  eastern North America, the hemlock region or western Canada.

## Concrete edits the manuscript needs

Phrased as replacements, assuming the interp path is what the paper
reports and that the science decisions in QS are resolved in favour of
describing current behaviour rather than changing it.

1. **2.2**, delete "where estimates are made for grid cells that contain
   one or more pollen records" and replace with a sentence saying
   estimates are spatially complete across the grid, produced by Bayesian
   interpolation of the site-level REVEALS reconstructions, with
   ice-covered cells masked.
2. **2.2**, replace the list of time periods with the set actually used:
   50, 200, 500 yr BP and then every 500 yr to 11,500 yr BP, 25 slices.
   Either drop "to 12,000 YBP" or explain the relabelling.
3. **2.3**, "the BAM R package" becomes "the `bam` function of the mgcv R
   package".
4. **2.3**, state which model was selected and on what grounds. If the
   ladder is not refitted by maximum likelihood, the sentence claiming
   analysis of deviance chose the model must go, and model 8 should be
   presented as an a priori choice.
5. **2.3**, state the coordinate system the spatial smooth is fitted in.
6. **2.4**, "1,000" becomes "100", or the code is changed.
7. **2.4**, replace "posterior samples" with an accurate description of
   what `simulate()` returns, or change the code to draw model
   coefficients.
8. **2.4**, state that the differenced quantity is the mean of the
   simulated draws rather than the point prediction, or difference the
   point predictions.
9. **2.5**, disambiguate "clear-sky surface kernel": name the file, the
   flux level and the variable.
10. **2.5**, state the sign and unit convention for each kernel, and
    confirm the three are compared at the same flux level.
11. **2.5**, state the 27°N-74°N restriction.
12. **2.5**, either implement the area-weighted continental summary as
    described or rewrite the paragraph to match what was actually
    computed; and give the endpoints that the implemented calculation
    produces.
13. **Methods, new sentence**, state that snow is not modelled and that
    the calibration carries the 2000-2009 snow climatology into every
    time slice.
14. **Methods, new sentence**, state that high-latitude winter albedo is
    absent from the calibration and that those cell-months are
    extrapolated.
15. **Results**, the forest-cover sentence should make clear that the
    metric is a scaled sum over available land, so its rise is driven
    substantially by deglaciation exposing land rather than by change in
    vegetation density.
