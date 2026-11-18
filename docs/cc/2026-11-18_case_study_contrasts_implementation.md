# Cover-contrast summaries at the case-study boxes: what was built

*18 November 2026, branch `case-study-contrasts` (off `feature/single-config` at `e9a9b1a`). Built to
Astra's design (`2026-11-18_case_study_contrasts_design_codex_gpt6astra.md`) as Chris approved it on
18 November. Not yet reviewed or verified.*

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

## Files touched

| File | What changed |
|---|---|
| `tools/explore_cover_contrasts.R` | The `case-studies` command (`evaluate_case_studies()`) and its four boxes (`CASE_STUDY_BOXES`, `case_study_members()`); `exchange_cases()` takes the regions as an optional argument whose default is the previous behaviour; `read_fit_status()` takes the albedo table (all days by default); `compare_duveiller()` takes an optional case folder; the header and usage message |
| `tests/test_explore_cover_contrasts.R` | Box edges with the real table; the default regions unchanged; the saved job of the hand-made run evaluated at the boxes while every fitting function is set to stop; the Duveiller comparison's default case folder, and the comparison on the boxes' cases |
| `tools/check_cover_contrasts.R` | Two checks for the verification, `case-studies` and `duveiller-case-studies`; two one-line helpers now shared with the existing `duveiller` check |
| `docs/cc/verification/2026-11-18_case-study-cover-contrasts.R` | The verification spec (its commit is filled in after review) |
| `README.md` | The rows of the two tools |

Nothing in `R/`, `scripts/` or `config.R` changed.

## Precedents

The method is the exploration's own; nothing new is introduced. The precedents listed in Astra's design:

- Lejeune, Q., Davin, E. L., Duveiller, G., Crezee, B., Meier, R., Cescatti, A. & Seneviratne, S. I.
  (2020). Biases in the albedo sensitivity to deforestation in CMIP5 models and their impacts on the
  associated historical radiative forcing. *Earth System Dynamics* 11, 1209-1232,
  doi:10.5194/esd-11-1209-2020. Sections 2.1.1 and 2.3.1: averaging over an area, and comparing month
  by month in each snow state; equation 11: scaling by the fraction converted.
- Duveiller, G., Forzieri, G., Robertson, E., Li, W., Georgievski, G., Lawrence, P., Wiltshire, A.,
  Ciais, P., Pongratz, J., Sitch, S., Arneth, A. & Cescatti, A. (2018). Biophysics and vegetation cover
  change: a process-based evaluation framework for confronting land surface models with satellite
  observations. *Earth System Science Data* 10, 1265-1279, doi:10.5194/essd-10-1265-2018. Section 2.3:
  comparing only where both cover the same places.
- Duveiller, G., Hooker, J. & Cescatti, A. (2018). A dataset mapping the potential biophysical effects
  of vegetation cover change. *Scientific Data* 5, 180014, doi:10.1038/sdata.2018.14. Table 1 and Data
  Records (p. 11): the class codes, and the sign of a transition read the other way round.
- Boisier, J. P., de Noblet-Ducoudré, N. & Ciais, P. (2013). Inferring past land use-induced changes in
  surface albedo from satellite observations: a useful tool to evaluate model simulations.
  *Biogeosciences* 10, 1501-1516, doi:10.5194/bg-10-1501-2013. Table 2: a spread across cells is not
  the uncertainty of a regional mean.

The exchange centred on each cell's own mix, the restriction to the continental range of cover
mixes, the four boxes and the six versions are project choices. Astra's design notes that the
reference check confirmed the publishers' records and the passages, but the registry requests failed,
so no complete registry and retraction check can be claimed.

## Left out by Chris's choice (18 November)

Astra's design had three checks at run time: comparing the inputs' checksums with the saved run's
records before evaluating; refusing to write into a folder that already holds outputs; and, in the
Duveiller step, checking that cases from another folder were built against the same fits. Chris
approved the design without them. The inputs are checked once, in the verification instead: in every
new record, the run's files must have the MD5 sums that the saved run's records give them
(`tools/check_cover_contrasts.R case-studies`, its first check). Running the command again into the
same folder overwrites, as the fit command does.

## How it is verified

- **Tests** (`tests/test_explore_cover_contrasts.R`, on its hand-made run): a cell on a box's west or
  south edge is in, one on its east or north edge is out, with the real table of boxes; without the new
  argument, `exchange_cases()` gives the study area and the six boxes of `R/regions.R` as before; the
  saved job of the hand-made run is evaluated at the boxes while the tool's fitting step, the ordinary
  fitter and the model registry's fitter are all set to stop if called, and the hemlock box gives back
  the saved northeast rows; the Duveiller comparison still reads the saved cases by default, and reads
  the boxes' cases when given their folder. This file, `tests/test_cv_separation.R` and
  `tests/test_config.R` pass (exit 0). Four deliberate faults (fitting in the new command, an east edge
  counted in, the default regions changed, the Duveiller comparison ignoring its case folder) each make
  the tests fail.
- **Trial on real data**, the steps of the verification spec in a scratch folder, one job at a time,
  one thread: every step exited 0, about four minutes in all, each under 1 GB of memory. The three
  case-studies jobs took 71, 62 and 42 seconds (all days, snow-free, snowy), 72 rows a month. The
  report has 2,592 rows and four pages; of the 216 fit entries, 212 converged and 4 were not fitted.
  The checks: in all 36 records the run files have the saved run's MD5 sums; the 648 rows of the
  hemlock box are identical to the saved northeast rows (largest difference 0); in July on the
  all-days table the Quebec-Labrador box has 186 calibration cells with an area, and the shares of
  that area represented (1.000, 0.771 and 0.737 for the three exchanges) are reproduced from cells
  selected independently; the 36 status tables are byte for byte the saved ones. The Duveiller
  comparison on the new cases took 41 seconds for 864 rows, and its 216 hemlock rows equal those of
  the comparison verified on 17 November. The existing Duveiller check still passes on that
  comparison. Nothing was written into the folders read. Two altered copies of the output (a hemlock
  contrast moved by 1e-9; a record's checksum changed) each make the new check fail.
- **Still to do before merging** (per `AGENTS.md`): one independent `change-reviewer` review (a tool,
  its tests and checks; no arithmetic or scientific option changed), then the spec
  `docs/cc/verification/2026-11-18_case-study-cover-contrasts.R` run with `tools/verify_change.R` at the
  reviewed commit, which fills its placeholder.
