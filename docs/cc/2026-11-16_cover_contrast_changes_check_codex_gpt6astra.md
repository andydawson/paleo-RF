**Verdict: ready after three small spec/documentation changes. No further implementation change is needed.** The approved numerical, reference-display and model-saving changes pass review.

I reviewed the requested commit range. The checkout’s later commit adds only this brief. I changed no files, made no commits, and ran no R.

The remaining findings, in order:

1. **The verification spec still needs its exact commit.**  
   [Verification spec:25](/home/expert/Documents/contracting/Andria/paleo-RF-wt/contrasts/docs/cc/verification/2026-11-15_cover-contrasts.R:25) contains `TO_FILL`, so verification cannot start. This is the acknowledged finishing step, not a newly discovered implementation defect.

   **Change and check:** set it to `7c12534`, launch from the canonical `paleo-RF` checkout, and confirm the resulting report identifies that commit and completes every specified check.

2. **The concrete timing/full-run plan is absent from the supplied note.**  
   [Implementation note:239](/home/expert/Documents/contracting/Andria/paleo-RF-wt/contrasts/docs/cc/2026-11-15_cover_contrast_exploration_implementation.md:239) ends with the repeated-trial results; it contains neither launch commands nor the output destination. I therefore cannot endorse the proposed commands themselves. This matters because [the report command:387](/home/expert/Documents/contracting/Andria/paleo-RF-wt/contrasts/tools/explore_cover_contrasts.R:387) stacks whatever files it finds: successful reporting does not establish completion.

   **Change and check:** record the actual commands, destination, memory rule and completion checks described below. Also update the note’s statement that full-run approval remains open: Chris has already approved it after checking and verification.

3. **Two passages still overstate Lejeune’s filter.**  
   [Implementation note:181](/home/expert/Documents/contracting/Andria/paleo-RF-wt/contrasts/docs/cc/2026-11-15_cover_contrast_exploration_implementation.md:181) calls the count “the 10 % condition”; [line 208](/home/expert/Documents/contracting/Andria/paleo-RF-wt/contrasts/docs/cc/2026-11-15_cover_contrast_exploration_implementation.md:208) still says “Lejeune: each at least 10 % of the cell”. Readers can therefore recover the misleading attribution despite section 10’s correction.

   **Change and check:** replace those phrases with “a count adapting one element of Lejeune’s filter”. The tool’s wording is already correct. Check against §2.3.1, which also specifies the regression-error condition. [Lejeune et al. 2020](https://esd.copernicus.org/articles/11/1209/2020/).

**The approved scope was respected.** I found no new scientific option, co-occurrence filter, recombined estimate, external dataset, local regression or calendar placement of Euskirchen’s snow periods. No committed trial files were removed. The less-than-atomic commit needs no history repair.

Every published-table row gained exactly `qualification` and `beside_model`. **Only Jin’s two rows changed existing fields**: their locator, albedos, difference, reading/checking status and explanatory note. Every other original field is unchanged.

The audit of all 58 drawn source rows gives:

| Published CSV lines | Result |
|---|---|
| 2–29: Hollinger | Existing metadata preserved; blank qualifications appropriate to these approved changes. |
| 30–35: Burakowski 2016 | Comparison-window placement and unspecified MODIS averaging period explicitly qualified. |
| 36–37: Burakowski 2015 pasture | Both marked single-day, 9 March 2013; retained beside snowy models. |
| 38–39: Burakowski 2015 mosaic | Single-day and mosaic qualifications; both `beside_model = no`. |
| 40–54: Boisier | Existing metadata preserved; drawing rules correct. |
| 83–85: Lutz | Annual means at separate sites; drawn once each on the published page and absent from model guides. |
| 99–100: Jin | Values, sign, period, snow state, albedo definition and reading provenance correct. |

Jin’s Table 1 confirms **0.122 − 0.105 = +0.017** and **0.294 − 0.213 = +0.081**, for November–January, 40–50°N, black-sky shortwave albedo. [Jin et al. 2002](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2001GL014132).

Independent reconstruction gives **191 model guides: 51 all-days, 108 snow-free and 32 snowy**. Every saved guide matches its source metadata and multiplication by 0.10. Neither mosaic comparison remains beside a model. Lutz’s `beside_model = yes` is harmless: the existing snow-state/month rules exclude annual all-conditions values.

**The figure now shows the requested support correctly.** I inspected all four pages and the supplied Southwest enlargement. Each model panel shows monthly eligible cells, calibration-cell area percentage and the appropriate retrieval percentage. The captions contain the continental-fit, repeated-reference, differing-scale and regional snow qualifications. The published page distinguishes the single-day, mosaic, uncertain-period and annual values.

Support text is readable when enlarged, but too small for comfortable reading at page-fit size. These are dense diagnostic pages requiring zoom. I found no overlap or clipping that warrants another change before verification.

**The saved-fit check is real.** [The checker:138](/home/expert/Documents/contracting/Andria/paleo-RF-wt/contrasts/tools/check_cover_contrasts.R:138) reloads a model and its exchange cases, recomputes 21 contrasts and standard errors, and compares them with the separately written results CSV. It does not compare freshly calculated values against themselves.

That establishes preservation. It uses the same contrast routine, so independent arithmetic evidence comes from the hand-worked tests and earlier numerical checks. The three frozen trial results provide an additional regression check.

The saving code retains the full fitter return, including attempt records and failed attempts, and saves cases once per month. Deliberately unfitted versions correctly have no fitted object.

**The strengthened verification is sufficient for this change.** It includes ten test files, all-three-input checks, the frozen-exchange comparison, the snowy July–August fit and report, convergence/support/numerical assertions, and the reload check. The canonical launch location also supplies the frozen fixture needed by `test_paths.R`. I inspected the passing trial logs; exact-commit verification remains to be run.

My independent Python checks found:

- All **420 repeated trial rows** identical to the first trial.
- Correct numerical availability in every trial row.
- All **756 support cases** reproduced from the saved input tables using an independent convex-hull calculation.
- Exact agreement in every count; maximum differences below **\(7\times10^{-16}\)** in area and retrieval shares.

For the launch note, keep the plan short:

- Use a fresh, durable output folder, separate from trial and verification output. Keep the verified code fixed and retain the exact inputs, configurations, shared cell table, logs and records.
- Run **all-days July with all six versions first**, including both location-500 versions, using single-thread settings and `/usr/bin/time -v`. Retain this as the first full-run job, leaving 35 jobs.
- Choose concurrency from available CPU slots and the memory budget remaining after reserving capacity for other work. A reasonable operational starting allowance is **1.5 times the timing job’s peak memory per concurrent job**, using consistent units and monitoring the first batch. That allowance is a judgement, not a measured guarantee. The snowy trial cannot size the location-500 work.
- Retain each job’s exit status, elapsed time, peak memory and saved-file sizes.
- Check the exact unique combinations: **36 jobs, 216 fit-status records, 4,536 contrast rows, 36 case files and 212 saved attempted-fit results**. Expect precisely four deliberate skips. Distinguish failed fits from missing jobs, and check numerical availability against convergence and eligibility before issuing the final report.

The 158-line checker is proportionate. Keep both reload tests and the archived trial scripts. Cut the stale wording; add no scheduler or general verification framework. I dropped seven cosmetic or speculative review candidates because they did not fix observed defects.

**Final verdict: ready after these named changes:**

1. Set the verification commit to `7c12534`.
2. Record the concrete launch plan and existing approval.
3. Correct the two remaining Lejeune attributions.

Then run verification, followed by the already approved timing job and full run.