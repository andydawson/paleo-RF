# Cover-contrast summaries at the case-study boxes: what was built

*18 November 2026, branch `case-study-contrasts` (off `feature/single-config` at `e9a9b1a`). Built to
Astra's design (`2026-11-18_case_study_contrasts_design_codex_gpt6astra.md`) as Chris approved it on
18 November, and reviewed by Astra the same day (`2026-11-18_case_study_contrasts_review_codex_gpt6astra.md`).*

## What it does and why

The cover-contrast exploration shows, month by month, the change in albedo that each of six fitted
versions of the albedo model predicts when 10 points of a cell's cover pass from one class to another.
Until now it did so for the study area and the six boxes of `R/regions.R`. Chris wanted the same
summaries at the exact case-study boxes, beside the published values and the comparison with Duveiller
et al. (2018), to see how the versions respond where the case studies are.

A new command, `case-studies`, gives them for four boxes of the case-study search
(`docs/cc/2026-11-10_case_study_candidates/candidates.csv`):

| Box, as labelled in the tables and figures | Key in the search | Longitude | Latitude |
|---|---|---|---|
| Northeast (hemlock box) | `hemlock_decline` | 80 to 66 W | 40 to 48 N |
| Quebec-Labrador (spruce rise) | `quebec_spruce` | 80 to 55 W | 50 to 60 N |
| Prairie-forest border | `prairie_advance` | 100 to 88 W | 40 to 50 N |
| Atlantic seaboard (clearance) | `clearance_seaboard` | 84 to 74 W | 32 to 40 N |

A box includes its west and south edges and excludes its east and north edges, as in `R/regions.R`.
The prairie's advance and its later return share one box.

The versions are fitted to the whole continent, so a box is only a summary taken after the fit. The
command therefore fits nothing: it reuses the 216 saved entries of the full run of 16 November (212
fits, and four deliberately not fitted: `lin_cover` and `mod8` on the snowy table in July and August,
which keep their rows without numbers). For each month it rebuilds the exchanges at the four boxes from
the run, evaluates each saved fit there, one at a time, and writes the same files as the fit command,
so the existing `report` command stacks and draws them. The saved fit status tables are copied
unchanged, so they keep the original fitting times. The `duveiller` command can now read these cases
from their own folder; the fits still come from the saved run.

```
Rscript tools/explore_cover_contrasts.R case-studies <run> <saved-contrast-dir> <output-dir> --fill-missing   # once per albedo table
Rscript tools/explore_cover_contrasts.R report <output-dir>
Rscript tools/explore_cover_contrasts.R duveiller <saved-contrast-dir> <albedo_IGBPdet.nc> <comparison-dir> <output-dir>
```

The hemlock box is the northeast box of `R/regions.R` and keeps its label, so its rows can be set
beside those of the full run: they are the same numbers. `R/regions.R` itself is unchanged. It gives
each cell one region, so a prairie box added there would take cells from the Upper Midwest box that
the cross-validation, the pollen coverage figure and the ordinary summaries use. The case-study boxes
are separate masks inside the contrast tool.

This remains an exploration of the modern fitted response, with no pass or fail. It does not give the
historical forcing of the hemlock decline, which needs the historical cover mixtures. Quebec's spruce
rise runs from summergreen to evergreen, the opposite of the plotted "evergreen to summergreen", so
that panel reads with its sign reversed. The published values are repeated in every box's panels,
wherever they were measured, and forest analogues fit Quebec's shrub-rich summergreen class least well.

## Precedents

The method is the exploration's own; nothing new is introduced. Its precedents, with the passages used,
are listed in Astra's design: Lejeune et al. (2020), Duveiller, Forzieri et al. (2018), Duveiller, Hooker
and Cescatti (2018) and Boisier et al. (2013). The exchange centred on each cell's own mix, the
restriction to the continental range of cover mixes, the four boxes and the six versions are project
choices.

## Left out by Chris's choice (18 November)

Astra's design also had three checks at run time (the inputs' checksums, refusing a folder that already
holds outputs, and the source of the Duveiller step's cases). Chris approved it without them: the inputs
are checked once, in the verification, where every new record's run files must have the saved run's MD5 sums.

## How it is verified

- Tests (`tests/test_explore_cover_contrasts.R`): the box edges, the default regions unchanged, the
  saved fits evaluated with every fitting function set to stop, and the Duveiller comparison's case folder.
- The spec `docs/cc/verification/2026-11-18_case-study-cover-contrasts.R` runs the three jobs, the
  report and the Duveiller comparison at the reviewed commit, then checks: the run files' MD5 sums in
  all 36 records; the 648 hemlock rows against the saved northeast rows; the Quebec-Labrador cells and
  area shares, selected again independently; 2,592 rows with complete keys, the four entries not fitted
  without numbers, four report pages; the Duveiller comparison's 864 rows, its hemlock rows against the
  comparison verified on 17 November. Its report, filed beside it: PASS at 545479b (18 November), every
  check exiting 0; the 648 hemlock rows identical to the saved ones.
