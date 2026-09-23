# Following one grid cell through the pipeline

Written 2026-09-23 to accompany the annotated scripts on `annotated-interp`. Every
number below is read directly from the anchored outputs in `tests/anchors/`, so it can
be checked, and it will change only if the method changes.

## The cell

Cell **8165**, centred at **51.5°N, 80.5°W**: the James Bay lowlands on the
Ontario–Quebec border, elevation 1 m. It was chosen because it lived through the
whole story: under the Laurentide ice sheet until about 9,000 years ago, then
vegetated for the rest of the Holocene. One cell, one story, all nine scripts.

Its area is 7,697 km² (a 1-degree cell at this latitude; `area_km2` in the tables).

## Script 1: what grew there

`data/lct_paleo_reveals_interp.RDS`, rows for this cell, three of the 25 slices:

| slice (BP) | ET | OL | ST | reading |
|---|---|---|---|---|
| 11,500 | 0.167 | 0.443 | 0.390 | mostly open; the cell is under ice, but the land-cover product still carries values (see below) |
| 8,000 | 0.329 | 0.231 | 0.440 | just deglaciated: mixed forest, summergreen-heavy |
| 50 | 0.563 | 0.179 | 0.258 | today: evergreen-dominated boreal forest |

Each row is the mean of 200 posterior draws; the spread of those draws is gone from
this point on. Note the cell has land-cover values even for slices when it was under
ice. The interpolation fills every cell; the ice is dealt with later (7a), not here.

## Script 2: what the satellite saw

`data/calibration_modern_lct_interp_bluesky.RDS`, the one row for this cell:

| jan | feb | mar | apr | may | jun | jul | aug | sep | oct | nov | dec |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 0.474 | 0.556 | 0.557 | 0.418 | 0.106 | 0.078 | 0.082 | 0.083 | 0.082 | 0.083 | 0.162 | 0.314 |

Winter albedo near 0.5 (snow on and around the trees), summer near 0.08 (dark
forest). This is the single 0.25-degree pixel at the cell centre. The twelve numbers
are the twelve responses the calibration models are fitted to, one model per month,
with this cell as one of 2,827 (summer) or 2,166 (January) data points.

## Scripts 4 and 5: the model

Nothing to show per cell: the model is a property of all cells together. For July the
selected model (model 8) is

    logit(albedo) = smooth(lon, lat) + smooth(elev) + smooth(OL, ET, ST) + noise

fitted by beta regression. What matters for this cell is that the last term is what
will be evaluated at its past land cover.

## Script 6: what the model says it looked like

`output/prediction/paleo_interp_predict_gam_summary_bluesky.RDS`, this cell:

| slice (BP) | July albedo (mean of 100 draws) | January albedo |
|---|---|---|
| 11,500 | 0.095 | 0.609 |
| 10,000 | 0.076 | 0.454 |
| 8,000 | 0.076 | 0.464 |
| 4,000 | 0.091 | 0.444 |
| 50 | 0.086 | 0.448 |

The model is asked what albedo the cell WOULD have had if its surface were the land
cover in the table. In summer the answer barely moves (0.07 to 0.10: forest is dark
whichever kind it is). In winter the early-Holocene open land gives a higher albedo
(0.61 at 11,500 BP against 0.45 today), because snow on open ground reflects more than
snow among trees. These are vegetation albedos even for the slices when the cell was
ice; the ice has not entered yet.

The 100 draws give a spread: July 8,000 BP is 0.076 with a 95% interval of 0.046 to
0.108. That interval is the scatter the model expects between individual observations
and its mean; it does not include uncertainty in the model itself or in the land cover.

## Script 7a: bringing in the ice, and taking differences

`data/ALB_diffs_bluesky.RDS`, this cell, July, the pairs around deglaciation. `year`
is the younger slice of the pair.

| pair (young→old) | ice frac young | ice frac old | veg change | ice change | combined (`veg_ice_thresh`) |
|---|---|---|---|---|---|
| 9,000 → 9,500 | 1 | 1 | NA | 0 | 0.000 |
| **8,500 → 9,000** | **0** | **1** | NA | **−0.602** | **−0.602** |
| 8,000 → 8,500 | 0 | 0 | −0.002 | NA | −0.002 |
| 7,000 → 7,500 | 0 | 0 | +0.037 | NA | +0.037 |

The Dalton raster says the cell was entirely ice at 9,000 BP and entirely ice-free
at 8,500 BP. So:

- Between 9,500 and 9,000 the cell is ice at both ends: no change, difference 0.
- Between 9,000 and 8,500 the cell goes from ice (albedo 0.68, the fixed July ice
  albedo) to forest (the model's 0.078). Young minus old is 0.078 − 0.68 = **−0.602**:
  the surface got much darker.
- After that, the differences are the small wobbles in vegetation albedo from one
  slice to the next, a few hundredths at most.

(The area-weighted `_parts` version gives exactly the same numbers for this cell,
because its ice fraction jumps from 1 to 0 in one step; the two families differ only
for cells that were partly ice.)

## Script 8: multiplying by the kernel

`output/forcing/RF_holocene_all_cases.RDS`, same rows. The July HadGEM3 kernel at
this cell is **−3.015 W/m² per 1%** of albedo (it is negative: more albedo, less
absorbed sunlight). CAM5 gives −3.186; CACK gives +143.9 W/m² per unit albedo.

| pair | albedo change | × 100 × kernel (HadGEM3) | CAM5 | CACK |
|---|---|---|---|---|
| 8,500 → 9,000 | −0.602 | **+181.5 W/m²** | +191.8 | +86.6 |
| 8,000 → 8,500 | −0.002 | +0.7 | +0.8 | +0.3 |
| 7,000 → 7,500 | +0.037 | −11.1 | −11.8 | −5.3 |

A darkening of 60 percentage points in July, at a kernel of 3 W/m² per point, is a
July forcing of 181 W/m² for this cell: a large positive (warming) number, as it
should be for an ice sheet turning into forest. CACK gives about half of HadGEM3
here, which is the pattern across the whole domain (question C4).

Averaged over the twelve months (winter kernels are small, because there is little
sunlight to reflect), the deglaciation pair gives an **annual mean of +93 W/m²** for
this cell. Every other pair is within ±6.

## Script 9: from one cell to a bar on the chart

The 8–10 ka period contains four pairs (8,000, 8,500, 9,000 and 9,500 as young ends).
For this cell, summing them month by month and then averaging the months gives
**94.5 W/m²**: essentially the deglaciation pair alone.

The bar on the chart is not this number. It is the area-weighted mean over all cells
in the study area (the "domain mean", 8.0 W/m² for HadGEM3 in this period), or the
same total flux spread over the whole planet (the "global equivalent", 0.30 W/m²).
This cell's share of that 0.30 is its forcing times its area divided by Earth's area:

    94.5 W/m² × 7.70 × 10⁹ m² / 5.10 × 10¹⁴ m² = 0.0014 W/m²

About half a percent of the bar comes from this one cell. The bar is the sum of a few
hundred such deglaciation cells plus the near-zero contribution of every cell that was
never ice.

## What this one cell shows about the method

1. The signal is the ice. In every pair where this cell stayed vegetated, the forcing
   is a few W/m² either way and cancels over time; the one pair where ice became forest
   is two orders of magnitude larger. The early-Holocene bars are, to first order, the
   area that deglaciated in each period times the ice-to-forest albedo drop.
2. The vegetation model still matters, twice: it sets the albedo the ice turns INTO
   (0.078 here; if the young slice were open land it would be higher and the forcing
   smaller), and it sets the winter values, where the difference between open ground and
   forest under snow is large.
3. Everything after script 1 treats the land cover as known. The 200 draws that would
   have said how sure we are about the 0.329 / 0.231 / 0.440 at 8,000 BP were averaged
   away in the first script.
4. The choice of ice albedo (0.68 fixed, or 0.63 seasonal for July) moves the
   deglaciation forcing directly: every 0.01 of ice albedo is 3 W/m² in July for this
   cell.
