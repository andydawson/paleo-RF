**Add one `case-studies` command to `tools/explore_cover_contrasts.R`.** It should rebuild the existing exchanges for four exact boxes, evaluate the saved fits, and feed the existing report. Include Duveiller by letting its comparison read these new cases separately from the original fits.

This gives Chris the seasonal comparison needed to examine whether the better-predicting models have more plausible cover responses. It remains an exploration of modern fitted responses; establishing the historical hemlock forcing still requires evaluating the historical cover mixtures.

I checked that the original inputs are available and that their checksums match **all 36 saved monthly records**.

The boxes should come directly from the existing [candidates.csv](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/docs/cc/2026-11-10_case_study_candidates/candidates.csv):

| Summary box | Longitude | Latitude | Historical context |
|---|---|---|---|
| Northeast: hemlock decline | −80 ≤ longitude < −66 | 40 ≤ latitude < 48 | 6000 → 4500 BP |
| Quebec–Labrador: spruce rise | −80 ≤ longitude < −55 | 50 ≤ latitude < 60 | 6000 → 2500 BP |
| Prairie–forest border | −100 ≤ longitude < −88 | 40 ≤ latitude < 50 | Advance: 10500 → 8000; return: 4500 → 500 BP |
| Atlantic seaboard: clearance, secondary | −84 ≤ longitude < −74 | 32 ≤ latitude < 40 | 500 → 200 BP |

Select keys `hemlock_decline`, `quebec_spruce`, `prairie_advance`, and `clearance_seaboard`. Prairie advance and return share one box and one set of summaries. The west/south-inclusive, east/north-exclusive convention follows [the search helper](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/docs/cc/2026-11-10_case_study_candidates/case_study_helpers.R:33). Historical dates provide context; they are not inputs to this modern exchange calculation.

**Leave `R/regions.R` unchanged.** Its [classifier assigns one region per cell](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/R/regions.R:24), with later matches replacing earlier ones. Adding prairie and seaboard boxes would change existing Midwest and Southeast classifications, affecting cross-validation, pollen-coverage reports and ordinary contrast summaries.

Instead, add a small reader in the contrast tool that selects those four CSV rows and supplies independent membership masks. Keep the existing `Northeast (hemlock box)` label. Read the CSV directly; the search helper also contains old absolute run paths and need not be sourced. No new coordinate file or region registry is necessary.

The proposed interface is:

```text
Rscript tools/explore_cover_contrasts.R case-studies <run-dir> <saved-contrast-dir> <output-dir> [--fill-missing]
Rscript tools/explore_cover_contrasts.R report <output-dir>
Rscript tools/explore_cover_contrasts.R duveiller <saved-contrast-dir> <netcdf-file> <output-dir> [<case-dir>]
```

`case-studies` processes all twelve months for one source run. Invoke it three times into the same new output folder, then run `report`. This task needs no month selector or custom-box option.

Use these original runs under `/home/expert/Documents/contracting/Andria/paleo-RF-verify/`:

| Albedo table | Source run |
|---|---|
| All days | `1d31cfc/.rundirs/cv2-holdouts` |
| Snow-free | `8e3f3a4/.rundirs/run2-snowfree-2` |
| Snowy | `74b5482/.rundirs/run7-snowy` |

The fit source is the supplied `7c12534/.rundirs/cover-contrasts-full/`. Pass `--fill-missing`: these old configurations predate the new ice setting. This uses the existing compatibility mechanism.

The implementation can stay small:

1. **Read and identify the inputs.** Reuse `read_run()`. Compare its four named input checksums with each original monthly record before evaluation. Compare hashes by input name; the old relative paths were relative to the original verification checkout.
2. **Rebuild only the exchange cases.** Give [exchange_cases()](/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature/tools/explore_cover_contrasts.R:103) an optional membership argument whose default preserves its current behaviour. Supply the four case-study masks. Keep the continental training hull, eligibility rules, areas and support calculations.
3. **Read the existing fits.** Generalise `read_fit_status(saved_dir, table = 'all_days')` to select the table and validate table/month/version keys. Reuse `saved_fit()` and `version_rows()`. Read one fitted object at a time. There must be no fallback to fitting.
4. **Write the existing intermediate formats.** Save the new cases and contrasts; copy the original fit-status CSVs. Their fitting times remain the original fitting times. Record evaluation timings separately.
5. **Record provenance.** Include the selected keys and bounds, candidate-file checksum, original job records, source-input and fit checksums, and code/package versions. Use a separate destination and reject existing products for the table being written.

The old saved cases alone are insufficient: they contain eligible endpoints and aggregate support, not all cells needed to recover a new box’s calibration count, area denominator and retrieval-share medians.

For Duveiller, add `cases_dir = saved_dir` to `compare_duveiller()`. Fits and status tables continue to come from `saved_dir`; cases come from `cases_dir`. In the separate-case mode, check that their recorded fit source matches. Reuse the existing matching, weighting, prediction and plotting functions.

Keep the approved Duveiller choices: original estimates, transitions **23 reversed, 38 and 28**, finite-estimate coverage, identical cells and renormalised area weights for both means, and no summary of published uncertainties. The earlier full comparison took about two minutes; measure this run rather than promise the same duration.

Expected outputs are:

| Product | Contents |
|---|---|
| `cases_<table>_<month>.rds`, `contrasts_<table>_<month>.csv`, `fits_<table>_<month>.csv`, records | 36 monthly jobs; no copied or newly fitted model binaries |
| `cover_contrasts.csv` | **2,592 rows:** 3 tables × 12 months × 6 versions × 4 boxes × 3 exchanges |
| `fits.csv` | Original 216 fit-status rows |
| `published_guide.csv`, `cover_contrasts.pdf` | Existing guide and four-page report: three model pages plus published values |
| `cover_contrasts_duveiller.csv`, `.pdf`, `record_duveiller.txt` | **864 rows** and one comparison page |

The archive contains **212 converged fits and four deliberately unfitted entries**: `lin_cover` and `mod8`, snowy July and August. Retain their 48 case-study rows with missing estimates. Empty eligible sets create additional legitimate missing estimates.

Preserve the current mean, conditional SE, spatial spread, cell counts, represented calibration-area share, 10%-class count and retrieval shares. The figure already shows monthly support. Keep all three exchanges in every box; Quebec’s spruce rise runs opposite to the plotted evergreen-to-summergreen direction. Explain that in the interpretation rather than introducing event-specific reversal calculations.

The published guide remains a qualified comparison repeated across regions, scaled by 0.10. Forest analogues are especially approximate for Quebec’s shrub-rich summergreen class. No pooled agreement score, acceptance band or automatic model-selection change is needed.

The method is inherited, with these precedents:

- **Lejeune, Q., Davin, E. L., Duveiller, G., Crezee, B., Meier, R., Cescatti, A. & Seneviratne, S. I. (2020).** *Biases in the albedo sensitivity to deforestation in CMIP5 models and their impacts on the associated historical radiative forcing.* **Earth System Dynamics 11**, 1209–1232. Sections 2.1.1 and 2.3.1 support area aggregation and monthly comparisons by snow state; equation 11 supports converted-fraction scaling. [DOI: 10.5194/esd-11-1209-2020](https://esd.copernicus.org/articles/11/1209/2020/)
- **Duveiller, G., Forzieri, G., Robertson, E., Li, W., Georgievski, G., Lawrence, P., Wiltshire, A., Ciais, P., Pongratz, J., Sitch, S., Arneth, A. & Cescatti, A. (2018).** *Biophysics and vegetation cover change: a process-based evaluation framework for confronting land surface models with satellite observations.* **Earth System Science Data 10**, 1265–1279. Section 2.3 supports restricting comparisons to common geographic coverage. [DOI: 10.5194/essd-10-1265-2018](https://essd.copernicus.org/articles/10/1265/2018/)
- **Duveiller, G., Hooker, J. & Cescatti, A. (2018).** *A dataset mapping the potential biophysical effects of vegetation cover change.* **Scientific Data 5**, 180014. Table 1 and Data Records, p. 11, establish the class codes and reversed-transition sign. [DOI: 10.1038/sdata.2018.14](https://www.nature.com/articles/sdata201814.pdf)
- **Boisier, J. P., de Noblet-Ducoudré, N. & Ciais, P. (2013).** *Inferring past land use-induced changes in surface albedo from satellite observations: a useful tool to evaluate model simulations.* **Biogeosciences 10**, 1501–1516. Table 2 distinguishes spatial standard deviations from uncertainty in a regional mean. [DOI: 10.5194/bg-10-1501-2013](https://bg.copernicus.org/articles/10/1501/2013/bg-10-1501-2013.pdf)

The exact centred exchange, hull restriction, four boxes and six-version selection remain existing **project choices**. The reference-checker review confirmed publisher identities and supporting passages; registry requests failed, so a completed registry/retraction audit cannot be claimed.

Verification should establish implementation correctness:

- Extend the existing fixture to check box boundaries, independent membership, unchanged default regions and prediction-only reuse. Make fitting entry points stop during the reuse test. Check missing fits, mismatched inputs and destination collisions.
- Reproduce **every northeast row across all 36 table-months**: support unchanged, and contrast/SE/spread within `1e-12`, with matching missingness.
- Independently select cells for a new box and check its support denominator and area-weighted endpoint predictions. Retain the existing covariance tests.
- Check complete output keys, the four missing-fit statuses, support shared across versions, and four report pages. Extend the Duveiller checker to read the separate cases, retain original-mode checks, and independently recompute matched means and weights.

A draft spec for `docs/cc/verification/2026-11-18_case-study-cover-contrasts.R` is below. The checker gains `case-studies <output-dir> <saved-dir> <three-run-dirs>` and the same optional case-directory argument as Duveiller. Replace the commit placeholder before execution.

```r
base = '/home/expert/Documents/contracting/Andria/paleo-RF-verify'
saved = file.path(base, '7c12534/.rundirs/cover-contrasts-full')
runs = file.path(base, c(
  '1d31cfc/.rundirs/cv2-holdouts',
  '8e3f3a4/.rundirs/run2-snowfree-2',
  '74b5482/.rundirs/run7-snowy'
))
out = '.rundirs/case-study-cover-contrasts/summaries'
comparison = '.rundirs/case-study-cover-contrasts/duveiller'
netcdf = '/home/expert/Documents/contracting/Andria/paleo-RF/data/duveiller2018/albedo_IGBPdet.nc'
tool = 'tools/explore_cover_contrasts.R'
check = 'tools/check_cover_contrasts.R'

jobs = lapply(runs, function(run)
  c(tool, 'case-studies', run, saved, out, '--fill-missing'))

list(
  name = 'case-study-cover-contrasts',
  commit = '<full reviewed implementation commit>',
  config = 'config.R',
  scripts = character(),
  checks = c(
    list(
      'tests/test_cv_separation.R',
      'tests/test_training_support.R',
      'tests/test_explore_cover_contrasts.R',
      'tests/test_config.R',
      'tests/test_paths.R',
      c(check, 'inputs', runs, '--fill-missing')
    ),
    jobs,
    list(
      c(tool, 'report', out),
      c(check, 'case-studies', out, saved, runs, '--fill-missing'),
      c(tool, 'duveiller', saved, netcdf, comparison, out),
      c(check, 'duveiller', comparison, saved, netcdf, out)
    )
  ),
  rscript = 'tools/rscript.sh',
  env = c(THREADS = '1', OPENBLAS_NUM_THREADS = '1')
)
```

Run this through `tools/verify_change.R` from its own worktree. Its PASS/FAIL concerns software correctness only.

For Opus: open or update the GitHub issue before implementation; use one topic branch under the recorded migration protocol, including the inspected ice-merged code at `e9a9b1a`. Implement the command and small shared-function changes, extend the tests/checker, and update the README script table and dated implementation/changelog notes with the precedents above. Obtain an independent `change-reviewer` review of the plumbing; changes to arithmetic or scientific rules require the stipulated Fable/Astra reviews. Verify the exact commit, then integrate and push under `CONTRIBUTING.md`.

**No new decision from Chris is needed.** The existing question about forest analogues for shrubs remains relevant to interpretation and does not block these summaries.

No files changed, no R jobs started, and no commits, pushes, branches or worktrees were created. The prohibited directory was not opened.