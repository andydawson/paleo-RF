# Published albedo contrasts between cover types: what the table holds and how it was made

*10 November 2026. Assembled by a literature agent (Fable) from open-access copies, at Chris's approval ("Yes,
open-access copies"). The table is `2026-11-10_published_albedo_contrasts.csv`; the digitised lines of
Hollinger's Fig. 2 are in `2026-11-10_published_albedo_contrasts_hollinger_fig2_digitised.csv`. The PDFs are
not in the repository. This note is the agent's report, shortened; nothing here has been reviewed except where
Astra's checks of the same day are named.*

**What the table is.** 103 rows, one per published value: source, DOI, locator (table, figure, page), region,
months, snow state, the two classes, their albedos, the difference (computed from the two columns, never typed),
the kind of albedo, how it was read, and whether the agent read it in the source. 96 rows were read in the
source (74 from tables or text, 22 with a figure reading), 1 from an abstract, 6 are placeholders marked "not read".

**Added 15 November 2026, for `tools/explore_cover_contrasts.R`.** Five columns at the end of the table restate
what its text columns say in a form a script can use. No existing field was changed (every old line is the start
of the new one). They were derived by rule from `note`, `months`, `snow_state` and `albedo_kind`:

- `contrast`: 1 deciduous minus evergreen, 2 open minus evergreen, 3 open minus deciduous; empty where a row names
  several contrasts.
- `first_month`, `last_month`: the calendar months the value covers (`jan` ... `dec`; a range may wrap the year
  end; `jan` to `dec` for an annual value). Empty for Euskirchen's four snow periods, which are not calendar months
  and differ between its boreal and tundra sites, and for rows that were not read.
- `snow`: `snow_free`, `snowy`, or `all_days` for all conditions.
- `broadband`: `no` for Bright's single spectral bands; empty where the kind of albedo was not read; else `yes`.

**Added 16 November 2026, after Astra's review of the exploration (findings 1 and 5, and its answer on Jin).**
Two more columns at the end, and Jin's two values entered; no other field changed.

- `qualification`: what a reader must know to place a value in time or class, shown beside it on the tool's
  published page. Burakowski et al. (2015): a single day (9 March 2013), and for the two Table 7 rows an open
  class that is a crop, forest, grass and shrub mosaic. Burakowski et al. (2016): December to March is the paper's
  model comparison window; the averaging period of the MODIS statistics is not stated. Lutz and Howarth (2015):
  annual means at separate sites. Empty elsewhere.
- `beside_model`: `no` for the two mosaic rows of Burakowski et al. (2015), which are not a complete change from
  forest to open land and so are not drawn beside the model; they stay on the published page. `yes` elsewhere.
- Jin et al. (2002), Table 1 and paragraph 9: deciduous broadleaf minus evergreen needleleaf forest, November to
  January, 40 to 50 N, black-sky albedo at local noon: +0.017 without snow (0.122 - 0.105) and +0.081 with snow
  (0.294 - 0.213). Read in the paper by Astra (10 November, and again in its review of 15 November); the builders
  could not obtain the paper and have not seen it. The table's `read_from`, `checked` and `note` columns say so. 98
  rows now hold a number read in the source.

| Paper | Obtained | What it gave |
|---|---|---|
| Hollinger et al. (2010), doi:10.1111/j.1365-2486.2009.02028.x | Forest Service repository | Table 2, p. 701: snow-free tower means by season for deciduous, evergreen (northerly and southerly), grassland and crop. Fig. 2, p. 700: Bartlett and Howland, digitised |
| Burakowski et al. (2016), doi:10.1175/JCLI-D-15-0286.1 | Forest Service repository | Fig. 5, p. 5149: New England, December to March, MODIS by class, with and without snow (figure readings; the open class with snow, 0.55, from the text, p. 5148). The albedo data section is 2d(3), p. 5146 |
| Bright et al. (2015), doi:10.5194/bg-12-2195-2015 | Publisher, open access | Fig. 2, p. 2200: monthly open and evergreen forest albedo in Norway, visible and near-infrared separately (not broadband; flagged) |
| Boisier et al. (2013), doi:10.5194/bg-10-1501-2013 | Publisher, open access | Table 2, p. 1506: MODIS white-sky albedo for crops, grasses, evergreen and deciduous trees; winter with and without snow, and summer |
| Burakowski et al. (2015), doi:10.1016/j.rse.2014.11.023 | Forest Service repository | Tables 5 and 7, pp. 474-475: New Hampshire, 9 March 2013, snow-covered pasture against dormant deciduous canopy |
| Euskirchen et al. (2016), doi:10.1088/1748-9326/11/10/105003 | Publisher, open access | Table 1: tower albedo for boreal evergreen, young deciduous, post-burn and tundra in four snow periods (Alaska and north-west Canada) |
| Lutz and Howarth (2015), doi:10.1088/1748-9326/10/6/064013 | Publisher, open access | Table 1: annual albedo of cleared and mature stands, White Mountains, New Hampshire |
| Jin et al. (2002); Barnes and Roy (2010); Ghimire et al. (2014) | Not obtained: the publisher's pages need a browser | Placeholders, except Jin's two values from Table 1, entered on 16 November as Astra read them (+0.017 without snow, +0.081 with snow; see above) |
| Zhao and Jackson (2014) | Not obtained: closed access | Placeholder only |

**Hollinger's values are confirmed exactly:** deciduous 0.145, 0.152, 0.146 for April-May, June-August,
September-October; northerly evergreen 0.084, 0.079, 0.089; southerly pines 0.111, 0.105, 0.107. The low end of
each recorded range is against the southern pines and the high end against the northerly conifers; Howland is in
the northerly group.

**Main values read** (differences; deciduous minus evergreen / open minus evergreen / open minus deciduous):

| Season and snow state | Values | Source |
|---|---|---|
| April-May, snow-free | +0.061 or +0.034 / grass +0.125 or +0.098, crop +0.094 or +0.067 / grass +0.064, crop +0.033 | Hollinger, towers (northerly or southerly evergreen) |
| June-August, snow-free | +0.073 or +0.047 / grass +0.102 or +0.076, crop +0.110 or +0.084 / grass +0.029, crop +0.037 | Hollinger |
| June-August, snow-free | +0.049 / crops +0.074, grasses +0.072 / crops +0.025, grasses +0.023 | Boisier, MODIS |
| September-October, snow-free | +0.057 or +0.039 / grass +0.108 or +0.090, crop +0.104 or +0.086 / grass +0.051, crop +0.047 | Hollinger |
| December-March, snow-free | +0.04 / +0.07 / +0.03 | Burakowski 2016, New England (figure) |
| December-February, snow-free | +0.023 / crops +0.047, grasses +0.067 / crops +0.024, grasses +0.044 | Boisier |
| December-March, snow-covered | +0.03 / +0.28 / +0.25 | Burakowski 2016 (figure; open value from text) |
| December-February, snow-covered | +0.039 / crops +0.341, grasses +0.363 / crops +0.302, grasses +0.324 | Boisier |

**Gaps.** No value for a single calendar month for any contrast in North America; the melt and onset months by
snow state in the temperate zone; snow-covered tower values in the north-east; all-conditions monthly means by
class; shrubland or tundra against forest in eastern Canada.

**Things to know.** The with-snow deciduous-minus-evergreen difference is smaller in the two sources read
(+0.039, +0.03) than Jin's +0.081. For open land under snow, MODIS class means give +0.25 to +0.36 and the New
Hampshire towers about +0.5. Boisier's tree groups pool leaf forms. The Bright rows are single spectral bands.

**Not obtained, for Chris to supply if wanted** (free to read in a browser unless noted): Jin et al. (2002),
doi:10.1029/2001GL014132; Barnes and Roy (2010), doi:10.1029/2010JG001428; Ghimire et al. (2014),
doi:10.1002/2014GL061671; Zhao and Jackson (2014), doi:10.1890/12-1705.1 (closed; an author's copy is on the
Jackson lab page). Possibly useful and not read: Burakowski et al. (2018), doi:10.1016/j.agrformet.2017.11.030;
Gao et al. (2005), doi:10.1029/2004JD005190; Jackson et al. (2008), doi:10.1088/1748-9326/3/4/044006.
