# Brief for Astra (ultra effort): check Fable's design for exploring the cover contrasts

*Chris, 10 November 2026: "have fable design it and then Astra check it, asking me any questions needed."
Read-only.*

## Rules
- Change no file; do not commit. You are in the worktree of branch `cv-v2`.
- You may run R for small read-only checks (`THREADS=1 OPENBLAS_NUM_THREADS=1 tools/rscript.sh`), writing nothing
  into the repository or any run folder. Never open `data/modis_albedo/requests/`.
- Plain words, no private ids. Verdict first.
- **Simplicity is a requirement** (Chris): as simple, clear and parsimonious as possible, no overengineering. Say
  what to cut before saying what to add.
- **Precedent from this field is a requirement** (Chris): for each step, published precedent from albedo and land
  cover, vegetation albedo forcing or palaeo-vegetation calibration, with DOI and the passage read; say plainly
  where there is none. Raise it yourself.

## What to check
The design: `docs/cc/2026-11-10_cover_contrast_test_design_fable.md`. Background: the review
`docs/cc/2026-11-10_cv_protocol_v2_results_review_fable.md` (sections 2.4 and 2.5) and the code it would extend
(`R/cv_separation.R`, `tools/check_cv_separation.R`, `tests/test_cv_separation.R`).

Chris has decided: this is an exploration with no pass or fail ("Let's just explore the contrasts for now,
depending on the results we can decide if we include in the paper"); Fable builds and you review the code;
open-access copies of the benchmark papers may be downloaded (a separate agent is assembling the table of
published values now).

Answer, with evidence:

1. **Is the quantity right?** Three exchanges of 0.10 of cover at modern cells inside the modern range,
   area-weighted, with the standard error from the coefficient covariance; multiplied by ten for comparison with
   published class contrasts. Is that the simplest fair way to read a fitted cover response for all fifteen
   versions, straight-line and thin-plate alike? What does the scaling by ten get wrong, and is there a simpler or
   more honest presentation?
2. **Is the comparison fair?** Published class means and tower sites against one-degree cover fractions; tower
   and MODIS albedo kinds against the project's blue-sky albedo; snow-free and snowy tables built with the 75%
   rule; summergreen including larch and shrubs; open land mixing crops, grass, tundra and bare ground. What must
   be stated beside the table so that it does not mislead Chris or Andria?
3. **The all-days expectation.** The design brackets it between the snow-free and snowy published values. Is that
   sound, or should the all-days table be compared only in months with essentially no snow?
4. **Cells and regions.** The northeast box and the whole study area; a 30-cell floor; endpoints inside the modern
   range. Anything to change? Does the open-land exchange leave enough cells in the northeast?
5. **Scope.** Fifteen versions, twelve months, three albedo tables, up to 510 fits. Is all of it needed for an
   exploration, or would fewer versions answer the question? Give the smallest set that still shows whether
   location size and cover form change the answer.
6. **Standard errors and the two flags.** Are two and three standard errors a sensible plain reading given the
   number of comparisons and that the errors take the smoothing as known?
7. **Code.** Is "extend `fixed_exchange()` to any pair of classes, add two commands to
   `tools/check_cv_separation.R`" the smallest change? Would a stand-alone script be simpler to read for a
   scientist who knows R? Which tests are enough?
8. **Precedent table (section 7).** Confirm or correct each row; add what is missing.
9. **What the design missed**, most important first.

End with: the changes you recommend before Fable builds, in order; and any question for Chris, each written so
that he can answer it without reading anything else.
