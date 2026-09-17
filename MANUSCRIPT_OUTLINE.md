# Draft manuscript and EGU talk: high-level outline

Source files (in the untracked `writing/` folder, from Andria's shared Drive):
`Draft manuscript (spatially complete).docx` and `dawson_EGU.pptx`.
Written 2026-09-17 as a map for a later close reading.

## The draft manuscript

**Working title:** Mapping Holocene Albedo from Fossil Pollen Inferred Land
Cover Change. **Authors:** Ruby Morillo, Bethany Blakely, Andria Dawson, Jack
Williams. **Target:** Nature Climate Change (3000-word main text) or
Geophysical Research Letters.

**State of the draft.** Introduction and Methods are written prose. Results
is a skeleton of bracketed headings and bullet notes. Discussion is empty
apart from a paragraph of "the story as BB sees it". Abstract is a
placeholder. Figures are listed by intent with no captions finalised. The
model-comparison table (models 1 to 4 only) and a few equations did not
survive conversion to text. Roughly 4,000 words including references.

### Structure

- **Introduction**
  - Climate-vegetation feedbacks are hard to quantify; albedo is one of them.
  - Holocene vegetation change has been invoked to explain the Holocene
    Temperature Conundrum, but global simulations are unconstrained by data;
    European studies suggest large regional effects.
  - Albedo, radiative forcing, and what is known about anthropogenic
    (decadal to centennial) land-cover effects; millennial-scale effects
    have not been quantified.
  - Paleoecological networks as the observational constraint; prior work
    reconstructing leaf area index and woody cover from pollen (Williams et
    al. 2008, 2009).
  - Statement of what the paper does: land-cover reconstructions plus a
    modern blue-sky albedo product, a calibration model, Holocene albedo
    hindcasts, radiative forcing via a kernel, comparison with modern
    forcing agents.
- **Methods**
  - 2.1 Blue-sky albedo: built from MODIS MCD43A3 v061 black- and white-sky
    shortwave albedo (2000 to 2009, quality filtered), combined using the
    diffuse-radiation fraction from ERA5, then averaged over years to a
    monthly climatology.
  - 2.2 Land-cover estimates: 1-degree gridded ET / ST / OL fractions for
    Holocene time slices, from Neotoma pollen records with refitted
    Bayesian age-depth models and the REVEALS model; cited to Dawson et al.
    (in prep) and Tunski et al. (in prep). Only cells containing pollen
    records.
  - 2.3 Calibration: monthly beta-regression GAMs (logit link, REML) of
    albedo on land cover, a 2-D Gaussian-process spatial term and elevation;
    model ladder compared by analysis of deviance; a factorial
    "spatial-effects" experiment to check for bias from the spatial term.
  - 2.4 Prediction: posterior simulations of monthly albedo per time slice
    and grid cell; differences between consecutive slices.
  - 2.5 Radiative forcing: albedo differences multiplied by the HadGEM3
    pre-industrial clear-sky surface albedo kernel; area-weighted
    continental land-cover summaries on unglaciated cells.
- **Results** (notes only)
  - Ice-sheet retreat dominates forcing 12 to 8 ka.
  - Continental forest cover rises 12 to 6 ka (summergreen in the east,
    evergreen in the west), giving net warming; a 6 to 4 ka sign reversal
    tied to the hemlock decline; Euro-American deforestation after 500 yr BP
    gives strong cooling.
  - Three regional case studies: eastern North America, the hemlock region,
    western Canada.
  - Forcing not sensitive to kernel choice; peak Holocene vegetation
    forcings comparable to modern greenhouse-gas forcing.
- **Discussion** (empty; three bullet ideas).
- **Figures planned:** calibration map / model-vs-data; land-cover maps by
  slice; Holocene radiative-forcing maps; forcing bar plot vs modern agents;
  hemlock-region forcing. Supplement: land-cover anomaly maps "after
  interpolation", continental PFT trends, monthly modern albedo maps.

## The EGU talk (21 slides, with speaker notes)

A conference talk by Andria titled "Holocene Land Cover Change in North
America: Trends, Drivers, Feedbacks". It tells the same story as the
manuscript at a higher level, with more emphasis on the land-cover
reconstruction than the paper has.

- Motivation: the Holocene temperature conundrum and the vegetation
  explanation (slides 3 to 5).
- Workflow: fossil pollen, land cover, albedo, radiative forcing (7).
- REVEALS and its inputs (8); **Bayesian spatial interpolation after
  Pirzamanbein et al. 2018 to fill the grid** (9); vegetation maps with
  uncertainty (10 to 12), including the continental area-weighted forest
  fraction tracking Laurentide retreat, and the hemlock decline.
- Calibration model: monthly albedo = spatial location + elevation +
  fractional land cover, shown for May (13).
- Radiative kernels: HadGEM3 used, CESM-CAM5 and CACKv1.0 tested (14).
- Results: forcing maps for 12 to 10 ka (warming) and 500 to 50 yr BP
  (cooling); consistent pattern across months; continental time series of
  forcing with early-Holocene warming and late-Holocene cooling, comparable
  to modern methane forcing (15 to 18).
- Take-home: pre-industrial forests were not in steady state; composition
  and structure matter (19).

## Points to reconcile with the code later

- The manuscript describes cover only for cells with pollen records and the
  supplement mentions "after interpolation"; the talk shows the Bayesian
  interpolation explicitly. The interpolation step is what produces the
  missing `veg_posts_interp_ice.RDS`, and its source is Pirzamanbein et al.
  2018, which is not in `writing/articles/`.
- Manuscript says 1,000 posterior samples per cell and month; the scripts
  draw 100.
- The blue-sky albedo construction (MODIS plus ERA5) is described in the
  methods but no code for it is in the repo; the repo starts from the
  finished GeoTIFF.
- The talk calls the calibration a Bayesian hierarchical model; the code
  and manuscript use `mgcv::bam` GAMs (the manuscript's "BAM R package").
- The talk shows results for May and "across months"; the non-interp code
  in the repo is March only, so the talk and paper results come from the
  interp, all-months path.
