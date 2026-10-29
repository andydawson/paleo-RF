# Refit on the rebuilt albedo: plan by Astra (GPT-6 Astra via Codex, ultra effort, 29 October 2026)

Planned from the brief in 2026-10-29_refit_plan_brief.md (whose snow plan was out of date). Reviewed
adversarially by Fable (2026-10-29_refit_plan_review_fable.md); Chris's decisions on both are in
2026-10-29_refit_plan_decisions.md. File links point to the worktree it read (feature/single-config at dd83724).

---

The refit will establish how the rebuilt land-only albedo changes the paper’s forcing estimates and whether it changes the interpretation of the northeast hemlock result.

I recommend six MODIS runs—both snow treatments under each of the three agreed retrieval choices—plus one raster control with otherwise identical settings. This is a plan only: no files were changed and no analysis runs were launched.

**Keep the new input choice explicit and preserve the legacy calculation.**

Add the following settings under `analysis$albedo`. The names describe choices Andria will make; paths remain in `R/paths.R`.

| Setting | Allowed values | `config.R` default | `configs/legacy_config.R` |
|---|---|---|---|
| `source` | `"modis_cells"`, `"legacy_raster"` | `"modis_cells"` | `"legacy_raster"` |
| `statistic` | `"all_days"`, `"snow_free"` | `"all_days"` | `"all_days"` |
| `version` | `"full_75"`, `"any_75"` | `"full_75"` | `"full_75"`; inactive |
| `winter_no_sun_cut` | `FALSE`, `TRUE` | `FALSE` | `FALSE` |

`winter_no_sun_cut = TRUE` selects `full_nocut` for November, December, January and February, retaining `full_75` elsewhere. Permit it only with `source = "modis_cells"` and `version = "full_75"`. The legacy source must reject snow-free or winter-override settings rather than silently ignoring them.

There is no need to expose `full_70`, a coverage threshold, shoreline inclusion, alternative averaging, or snow shifts. Those would extend this task beyond Chris’s decisions.

The 75° screen, separate actual and snow-free climatologies, and explicit reporting of winter gaps have direct precedent in Jia, A., Wang, D., Liang, S., Peng, J. and Yu, Y. (2022), *Global Daily Actual and Snow-Free Blue-Sky Land Surface Albedo Climatology From 20-Year MODIS Products*, **JGR: Atmospheres**, 127, e2021JD035987, §§2.2–3.2. Their averaging and diffuse-fraction construction differ from this project’s; the approved build’s choices must be described accurately rather than attributed wholesale to that paper. [DOI: 10.1029/2021JD035987](https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2021JD035987).

**Script 2 should attach the supplied monthly values by cell centre, without calculating another climatology.**

The existing raster extraction, ice exclusion, zero floor and coarse comparison are in [script 2](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-feature/scripts/2_calibration_lct_bluesky.R:39), particularly lines 41–54, 64–145 and 147–180.

The implementation should follow this sequence:

1. Read the modern predictor table from script 1. Retain its row order and its `x`, `y`, `elev`, `ET`, `OL`, `ST` columns. Coordinates are longitude and latitude in degrees; elevation remains in metres; cover remains fractions.
2. Read the completed official CSV and its provenance sidecar through `read_input()`.
3. Validate unique `(x, y, month)` keys, recognised months, required columns, numeric types and admissible values. Join on exact, validated grid centres; do not use row position, nearest-neighbour matching or coordinate rounding to conceal a mismatch.
4. Select one response column for each month according to the configuration.
5. Apply the existing `centre_in_1ka_polygon` calibration exclusion unchanged, using `cells_in_polygons()`. Record the excluded centres separately from missing albedo. Their removal from calibration must not remove them from the prediction domain.
6. Write the existing wide calibration-table format: the six predictor columns followed by `jan` through `dec`. Keep observation-support information in a separate table.

That last separation matters: script 3 melts every column other than its six identifiers into “monthly albedo” (`scripts/3_plot_cal_lct_albedo.R:48–50`). Adding counts or quality fields to the calibration table would therefore break its meaning.

The supplied CSV has 44 columns:

| Columns | Meaning |
|---|---|
| `x`, `y`, `month`, `land_pixels` | Cell centre, calendar month, retained land-pixel count |
| `V` | All-days albedo for version `V` |
| `V_snowfree`, `V_snowy`, `V_unknown` | Conditional albedos |
| `V_share_snowfree`, `V_share_snowy`, `V_share_unknown` | Corresponding shares |
| `V_years`, `V_coverage`, `V_days` | All-days observation support for that version |

Here `V` is one of the four versions already supplied. Albedos, shares and coverage are already fractions on 0–1: **do not apply MODIS scaling again**. Coverage is the mean fraction of land pixels with a qualifying observation in a year with data. Days are qualifying pixel-days per land pixel, averaged over those years.

There is an important qualification for the snow-free write-up. The supplied all-days mean weights years equally; the supplied snow-free mean uses the same underlying annual weights, so years contribute in proportion to their snow-free share. It is not an equally weighted mean of annual snow-free means. Likewise, `_years`, `_coverage` and `_days` describe all-days support, not snow-free-specific support. Import these values unchanged and label them honestly. These definitions are implemented in [`climatology()` and `cell_table()`](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-feature/tools/prepare_bluesky_albedo.R:515), lines 515–535 and 879–919.

**The difference between 2,866 and 2,860 cells is not six surplus cells.** Inspection found:

- 2,856 centres common to the MODIS and existing modern tables.
- Ten MODIS-only centres at latitude 17.5°, longitudes −100.5° through −91.5°.
- Four modern centres absent from MODIS: `(−132.5, 69.5)`, `(−114.5, 61.5)`, `(−112.5, 62.5)` and `(−112.5, 63.5)`.

Use a left join from the modern predictors. Report both unmatched lists; retain the four modern rows with missing responses. The builder can omit an entire centre when it has no retained land pixels (`prepare_bluesky_albedo.R:838–848`).

A cell missing January must remain available for May. An absent cell-month or an explicitly missing response stays `NA`; neither becomes zero, a neighbouring value, or an all-days substitute in the snow-free run. Fit each month on its available observations, as the existing `na.action = na.omit` already does. Stop if a selected month has no usable response or cannot support the unchanged model.

Retain the inherited exact-zero replacement, `0 → 1e-4`, and record its count. Do not turn missing values into that floor. For the new reader, reject negative, infinite, above-one or exactly-one responses with named offending cells rather than inventing another endpoint adjustment. The examined main all-days values contain no zeros and range from 0.076513 to 0.806541.

For MODIS runs, replace the raster-native/coarse illustrations with clearly labelled one-degree maps of the selected response and missingness/support. Do not write a duplicate “coarse” calibration table or native-versus-coarse scatterplot: neither describes this input. Keep those existing outputs available unchanged in legacy raster runs.

**Keep the code changes small and identifiable.**

| File | Planned change |
|---|---|
| `config.R`, `configs/legacy_config.R` | Add the four settings and plain-language comments. |
| `R/config_schema.R` | Validate values and combinations in `CONFIG_SCHEMA` and `config_combination_errors()`; current relevant sections are lines 120–188. |
| New `R/albedo.R` | Small functions `validate_albedo_cells()`, `select_cell_albedo()` and `join_cell_albedo()` for validation, column selection and order-preserving attachment. |
| `R/paths.R` | Add the CSV, provenance sidecar and support-table paths beside the existing raster/calibration entries, currently lines 44–65. Add paths for the diagnostic outputs below. |
| `scripts/2_calibration_lct_bluesky.R` | Explicit source branch, shared final table writing and zero-floor handling, support audit and source-appropriate figures. |
| `scripts/4_calibration_model.R` | Record monthly fitting counts and convergence evidence; verify that models compared within a month use the same observations. Preserve formulas and fitting methods. |
| `scripts/5_calibration_eval.R` | For MODIS runs, evaluate only rows with an observed monthly response and valid predictors. Preserve the legacy evaluation path exactly. |
| `R/model_registry.R` | Allow explicit diagnostic fitting controls while retaining existing defaults; details below. |
| New `tools/check_model7_convergence.R` | Separate, recorded 2,000-step diagnostic using the shared fitting function. |
| `R/training_support.R` and the two support plotting tools | Add one shared monthly-support routine using each saved fit’s actual training rows. |
| `tools/plotting/plot_northeast_cover_and_location.R` | Save its existing numerical diagnostics beside its figure for comparison between runs. |
| New `tools/compare_albedo_refits.R` | Join recorded run summaries and report differences; reuse existing aggregation helpers rather than copy forcing arithmetic. |
| Tests, verification specs and documentation | Reader/configuration tests, diagnostic checks, run specs, changelog, README and question-file updates after approval. |

Scripts 1, 3 and 6–10 need no scientific calculation changes.

Script 5 requires particular care: its current interval-coverage denominator includes missing observations (`scripts/5_calibration_eval.R:206–215`). This is already documented in `questions_for_andria_scientific.md:216–222`. For MODIS runs, use one shared monthly-row selector from `R/albedo.R` throughout evaluation and report the denominator. Preserve the legacy branch—including its historical statistic—to satisfy the anchor requirement.

For provenance, the existing `read_input()`, `run_record()` and manifest machinery suffice; no generic manifest redesign is needed. Script 2 should record:

- CSV and sidecar paths and hashes; completed build identity and script versions.
- Product/version, observation period beginning 5 March 2000, noon interpretation, land rule and averaging definition.
- Selected statistic and **effective version for every month**.
- Predictor, matched, unmatched and ice-excluded counts and coordinates.
- Monthly available/missing responses, zero-floor counts and support summaries.
- Confirmation that no coverage filter or coverage weighting was applied.

The sidecar is written at `prepare_bluesky_albedo.R:955–968`. The run’s plain-language record should repeat the source and scenario, so a reader need not decode its configuration.

**Run both snow treatments under each agreed sensitivity.**

All six configurations retain all twelve analysis months.

| Run | `statistic` | `version` | `winter_no_sun_cut` |
|---|---|---|---|
| Main | `all_days` | `full_75` | `FALSE` |
| Snow-free | `snow_free` | `full_75` | `FALSE` |
| Broader retrieval quality | `all_days` | `any_75` | `FALSE` |
| Broader retrieval quality, snow-free | `snow_free` | `any_75` | `FALSE` |
| Winter without sun-angle cut | `all_days` | `full_75` | `TRUE` |
| Winter without sun-angle cut, snow-free | `snow_free` | `full_75` | `TRUE` |

The additional raster control uses `legacy_raster` with **current scientific settings**, including land-mean elevation and the current ice mask. It is distinct from `legacy_config.R`, whose purpose is historical reproduction.

Each scenario runs scripts **1, 2, 3, 4, 5, 6, 7, 7a, 8, 9 and 10**, followed by the four diagnostic plotting tools. Script 1 is numerically unaffected by albedo, but rerunning it gives an upstream manifest with matching analysis settings.

For the winter sensitivity, rerunning the unchanged eight months is the simplest implementation: it avoids stitching together products with different configurations. A four-month run through script 9 would average those four months and must not be presented as an annual result.

The scientific interpretations should remain bounded:

- **Retrieval quality:** Wang, Z., Schaaf, C. B., Sun, Q., Shuai, Y. and Román, M. O. (2018), *Capturing rapid land surface dynamics with Collection V006 MODIS BRDF/NBAR/Albedo (MCD43) products*, **Remote Sensing of Environment**, 207, 50–64, distinguishes full from backup magnitude inversions and validates results across quality classes. This supports the quality comparison, without guaranteeing every low-quality observation. Daily products use overlapping 16-day windows, so day counts are not independent sample sizes. [DOI: 10.1016/j.rse.2018.02.001](https://doi.org/10.1016/j.rse.2018.02.001).
- **Snow:** Barnes, C. A. and Roy, D. P. (2010), *Radiative forcing over the conterminous United States due to contemporary land cover land use change and sensitivity to snow and interannual albedo variability*, **JGR**, 115, G04033, §4.5, compares snow-inclusive and snow-free forcing. Their method uses an explicit snow mixture, not two GAM refits. Our result must therefore be called **sensitivity to the calibration’s snow treatment**, not an isolated historical snow contribution. [DOI: 10.1029/2010JG001428](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2010JG001428).
- **Winter:** Bright, R. M., Myhre, G., Astrup, R., Antón-Fernández, C. and Strømman, A. H. (2015), *Radiative forcing bias of simulated surface albedo modifications linked to forest cover changes at northern latitudes*, **Biogeosciences**, 12, 2195–2205, documents insufficient December retrievals and degraded correction at high solar angles. It supports examining the problem, not abandoning the screen as a correction. `full_nocut` remains Chris’s agreed stress test. [DOI: 10.5194/bg-12-2195-2015](https://bg.copernicus.org/articles/12/2195/2015/).

The provisional support counts make these qualifications material. Applying the existing 48-cell ice exclusion gives 2,812 predictor centres:

| Month | Main all-days observations | Main snow-free observations |
|---|---:|---:|
| January | 1,726 | 1,227 |
| February | 2,397 | 1,617 |
| March | 2,806 | 1,764 |
| April | 2,808 | 2,039 |
| May | 2,808 | 2,529 |
| June–September | 2,808 each | 2,808 each |
| October | 2,662 | 2,599 |
| November | 1,866 | 1,776 |
| December | 1,416 | 1,272 |

These must be recalculated from final run inputs. Snow-free sampling changes substantially in spring as well as winter. Removing the sun-angle cut increases December all-days support to 1,642 on these centres; it does not eliminate the gap.

**Check model 7 separately, without changing the prediction model or legacy iteration limit.**

The current controls and convergence helper are in [R/model_registry.R](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-feature/R/model_registry.R:55), lines 55–104. `CONTRIBUTING.md:132–135` deliberately keeps iteration limits out of configuration.

Add an optional `control = CALIBRATION_CONTROL` argument to `fit_calibration_model()`, preserving existing defaults and calls. The diagnostic tool supplies `maxit = 2000` and one thread, explicitly including `bam`’s separate thread argument.

For the main all-days and snow-free runs, check model 7 for all twelve months at 2,000 steps. For the other sensitivity runs, apply the higher limit wherever the ordinary fit fails or reaches its limit. Compare against the corresponding 500-step fit on **identical monthly data**, using the same ML method:

- Fitting-loop iterations and limit.
- Named warnings and smoothing-parameter convergence.
- Gradient and Hessian diagnostics where available.
- Changes in fitted predictions and AIC.
- Actual fitting-row identity.

Save these fits separately from the production ladder and selected model. An unconverged fit cannot be an AIC winner. Model 8 remains the REML prediction model; its convergence must also pass before its forcing is interpreted.

Wood, S. N. (2011), *Fast stable restricted maximum likelihood and marginal likelihood estimation of semiparametric generalized linear models*, **JRSS B**, 73, 3–36, establishes the REML estimation framework and discusses numerical difficulties associated with concurvity. The exact 2,000-step limit is Chris’s numerical diagnostic, not a published scientific threshold. `maxit` limits fitting iterations; it is not a guarantee of convergence. [DOI: 10.1111/j.1467-9868.2010.00749.x](https://doi.org/10.1111/j.1467-9868.2010.00749.x).

**Verify through the existing tool, with separate specifications for historical reproduction and new results.**

Every specification must run at a fixed commit through `tools/verify_change.R`, produce its PASS/FAIL report, and cover the code actually merged. The applicable rules are in [the verification README](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-feature/docs/cc/verification/README.md:3).

| Specification | Required evidence |
|---|---|
| Reader and configuration | Shuffled input order gives identical joins; duplicate keys and malformed values fail; unmatched centres and missing months remain missing; every scenario selects the intended columns; no accidental scaling, weighting or cross-month deletion. |
| Integration of script 2 | Exact selected CSV values appear at the correct centres; predictor columns/order unchanged; ice exclusion unchanged; zero floor applied only to exact zero; support table and manifests agree. |
| Legacy preparation | Newly generated script-1 and script-2 tables match their existing anchors, including the coarse table. |
| Legacy fitting | Existing one-month model-8 regression check exercises the shared fitting wrapper: prediction difference at most `1e-6`, equal anchored integer AIC. |
| Legacy evaluation/prediction | Scripts 5–6 from frozen fits, seed 1, eight BLAS threads: seeded anchors and deterministic predictions unchanged. |
| Legacy differences/forcing | Scripts 7, 7a and 8 from the original frozen prediction summary: tail anchors unchanged. |
| Legacy summaries | Scripts 9–10 from original frozen forcing/coarse differences: four script-9 summary anchors unchanged. |
| Each new scenario | Full pipeline and diagnostics complete; fitting counts and convergence recorded; required products present; manifests consistent; all inputs unchanged. |
| Cross-run comparison | Configuration differences match the declared scenarios; winter override changes only November–February calibration inputs; unchanged months reproduce with the fixed seed; monthly contributions reconcile to annual summaries. |

A fresh seeded full run cannot be expected to reproduce every historical tail anchor: those anchors used an older unseeded prediction summary. Preserve the established staged checks and their tolerances; do not replace anchors or loosen the contract after seeing results. The [regression contract](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-feature/docs/cc/2026-10-08_single_config_regression_contract.md:36) makes this distinction.

Add meaningful tests for missing-observation evaluation denominators, monthly rather than May-only support, diagnostic-only fitting controls, and provenance. Extend the existing configuration, paths and model-registry tests; retain the build tests.

Before launching, show Chris one input-and-settings audit containing:

- The completed official CSV **and** `albedo_modis_cells_provenance.txt`, their hashes, dimensions, ranges and comparison with the supplied provisional table.
- Every other input actually read: pollen posteriors; both elevation sources where applicable; grid; boundaries; glacier polygons, ice fractions and glacier albedos; three kernel files and selected variables; pollen-coverage data; IPCC comparison tables; and the legacy raster for controls.
- Each input’s resolved path, hash, readable format and relevant dimensions/units. Identify LFS pointers or missing external files before starting.
- The complete resolved configuration for every run, with an explicit difference table.
- Confirmation of land-cover mean, GMTED2010 land mean, model 8/REML, ML ladder, existing calibration ice exclusion, 100 evaluation and prediction draws, all twelve months, current ages and coarse-age alias, domain limits, endpoint ice arithmetic, partial-ice headline, whole-cell coastal weights, three current all-sky TOA kernel choices, Earth-area denominator and latitude bands.
- Code commit, environment/package versions, seeds, threads, core allocation, output directories and expected products.

Wait for the official writer to finish before hashing or freezing its output. Add the completed CSV and sidecar to the frozen-input inventory without changing existing entries; the verification tool’s input linker otherwise will not bring them into its worktree (`tools/verify_change.R:90–101`).

Production scenarios should use fresh directories and `allow_stale = FALSE`. The tool automatically permits stale inputs when `seed` or `copy` is used (`tools/verify_change.R:104–112`); reserve that mechanism for explicitly checked historical fixtures and comparison-only re-summaries.

**Run conservatively and make comparisons reproducible.**

Use a fixed seed of **1549466984** in all new comparison specifications, leaving the general default seed choice unchanged.

This seed matches the 18 October prediction run. Its evaluation run used **1384237515**, and the 19 October icecaps-kept run used that latter seed while describing it as the prediction seed. Consequently, the old runs were not fully paired. This affects forcing because scripts 7 and 7a read simulation-mean predictions, not the separately saved deterministic predictions (`scripts/6_prediction_model.R:45–82`; `scripts/7a_alb_diff_full.R:36`).

Recommended order:

1. Reader checks, legacy gates and completed-input audit.
2. Matched raster control, then main MODIS all-days run.
3. Main snow-free run and model-7 diagnostics.
4. The two `any_75` runs.
5. The two winter-no-cut runs.
6. Comparison report and reconciled reviews.

Begin with one production job to measure peak memory. Thereafter allow at most two independent jobs, each on a separate assigned core, with one BLAS thread. Count a model-7 diagnostic within that limit. Use an aggregate R-memory target of **40 GB**, providing headroom below 60 GB; this is an operational recommendation, not a measured requirement.

Set `THREADS = "1"` in the specifications. `tools/rscript.sh:17–19` derives OpenBLAS/OpenMP/MKL settings from `THREADS`, so setting only `OPENBLAS_NUM_THREADS` is insufficient. Legacy byte-comparison checks retain eight threads on eight reserved cores, as required by the anchors.

Use immutable verification worktrees and separate scenario directories. Do not split production months between competing writers or edit code while a run reads it.

**Report changes in forcing, sampling and interpretation together.**

Every production run produces its calibration/support tables, saved models and diagnostics, predictions, albedo differences, per-cell forcing, period summaries, monthly/latitude breakdown and figures.

The comparison report should include:

- Old versus rebuilt albedo on common observed cell-months, with maps and separate missingness counts.
- Forcing by the existing seven periods and all twelve months, for HadGEM3, CAM5 and CACK, in both domain-mean and global-equivalent W m⁻².
- Partial-ice headline totals and vegetation/ice components; retain the existing threshold sensitivity.
- Signed differences from the matched raster control and historical runs, with valid-area changes identified.
- For winter, both monthly forcing and its contribution to the annual result—not just the change in available calibration cells.
- For snow, the all-days/snow-free contrast under each retrieval choice, accompanied by differences in fitting populations.

Use the later partial-ice headline run as the principal historical comparison. The original 18 October headline used threshold ice; the later run re-summarised its same per-cell forcing using partial ice (`docs/cc/verification/2026-10-19_headline-partial-ice-2.R:4–14`). Re-summarise the icecaps-kept run under the same reporting definition, retaining its different mask and seed as explicit qualifications.

Monthly kernel multiplication and seasonal reporting follow Ghimire, B., Williams, C. A., Masek, J., Gao, F., Wang, Z., Schaaf, C. and He, T. (2014), *Global albedo change and radiative cooling from anthropogenic land cover change, 1700 to 2005 based on MODIS, land use harmonization, radiative kernels, and reanalysis*, **GRL**, 41, 9087–9096, §2.3 and Figure 2. Preserve this pipeline’s existing signs, units, month weighting and denominators; the reference does not justify changing them here. [DOI: 10.1002/2014GL061671](https://doi.org/10.1002/2014GL061671).

Redraw all four diagnostic tools. For the northeast, retain the same 80–66° W, 40–48° N box and May comparison: evergreen–latitude correlation, observed albedo relationships, conditional evergreen slope, with/without-location predictions, and the 6–4.5 ka change. Report whether the sign changes and whether the underlying support improves. A changed albedo response cannot by itself separate strongly correlated predictors.

The support tools already use actual fitted rows, but currently use **May’s** training hull (`plot_training_support.R:42`; `plot_forcing_vs_training_support.R:48–59`). Keep the May illustration clearly labelled, and add monthly support using each monthly fit. Join forcing support by cell, month and both period endpoints.

Convex-hull identification of extrapolation follows King, G. and Zeng, L. (2006), *The Dangers of Extreme Counterfactuals*, **Political Analysis**, 14, 131–159, §2.3. Here it describes **cover-space support only**. Also report latitude/elevation ranges and model concurvity; being inside the cover triangle does not establish support for every predictor combination. [DOI: 10.1093/pan/mpj004](https://doi.org/10.1093/pan/mpj004).

**Require independent scientific reviews before integration.**

Give Fable, as Claude science-reviewer, and Astra the same package before either sees the other’s findings:

- Approved requirements and fixed decisions.
- Exact code commit/diff and configuration matrix.
- Final input hashes, build provenance and reader contract.
- Full references and supporting passages.
- Tests, legacy PASS reports and representative new-run evidence.
- Monthly support, convergence and proposed forcing comparisons.

Each finding must name file/line, consequence, evidence and a proposed check. Conduct one reconciliation pass; unresolved scientific interpretation goes to Chris or Andria. Neither a successful pipeline exit nor agreement between reviewers establishes the scientific validity of an extrapolated result.

Work on a topic branch under the existing migration-branch protocol, commit atomic changes with reasons, and merge only with matching PASS evidence. Do not touch `main` or `legacy`.

The literature passages and bibliographic identities above were checked through publisher or author-hosted sources. The installed paired reference checkers could not complete their Crossref lookup because of network-resolution failure. **A successful paired reference audit remains a prerequisite before implementation; this plan does not claim that gate has passed.**

**Chris’s remaining approvals are bounded.**

| Decision | Recommendation and reason |
|---|---|
| Cross sensitivities with both snow treatments? | Yes: six MODIS runs. Otherwise the apparent snow sensitivity could depend on the retrieval-quality or winter-screen choice without being tested. |
| Add the matched raster control? | Yes. It separates the input replacement from historical seed, reporting and execution differences. |
| Correct evaluation/support handling for the new source? | Yes, with legacy behaviour preserved. Missing observations must not count as failed interval coverage, and May support must not stand for winter support. |
| Model-7 diagnostic scope and failure handling? | Twelve months for both main snow treatments; all failed sensitivity fits thereafter. Keep model 8 selected and report unresolved model-7 convergence. |
| Adopt the proposed fixed seed, full-year execution and resource limits? | Yes, to make comparisons interpretable and keep execution within the shared-machine constraints. |
| What if sample changes dominate the snow comparison? | Report that limitation first. Any additional matched-cell refit is a further, explicitly justified analysis for approval—not an automatic extension. |

The following questions belong to **Andria**, supported by the new results:

- What independent evidence should determine the expected sign of the hemlock-collapse albedo response?
- Does the paper’s vegetation-forcing claim mean cover change under today’s snow/climate, or include changing historical snow?
- What exactly do the pollen fractions and “modern” slice represent?
- How should the paper qualify forcing predicted outside modern training support?
- If the northeast effect remains unstable, what additional model or independent comparison is scientifically warranted?

Record those questions and their origins during approved implementation. Reconcile the stale shoreline wording and older snow-mixture notes then; the current instructions already settle those choices.

The principal risks have specific checks:

| Risk | How it is caught |
|---|---|
| Reading an unfinished or different build | Completed sidecar, fixed hashes, frozen inputs and before/after checks |
| Wrong cells, months or units | Key-based join tests, both unmatched lists, column-selection checks and range checks |
| Hidden coverage filtering or land-area weighting | Direct CSV-to-calibration equality; unchanged whole-cell forcing weights |
| Misleading snow attribution | Monthly fitting-population report and explicitly limited interpretation |
| Winter extrapolation mistaken for observations | Missingness maps, monthly support and retained no-cut gaps |
| Invalid model-7 AIC ranking | Actual convergence diagnostics and separate diagnostic fits |
| Historical changes mistaken for an albedo effect | Matched raster control, common reporting definition and disclosed seeds |
| Legacy behaviour lost | Staged unchanged-anchor gates |
| Stale products or resource contention | Fresh run directories, immutable worktrees, explicit threads and measured memory |
| Northeast sign change overinterpreted | Same regional diagnostics, support assessment and Andria’s scientific review |