# Follow-up: should the model be chosen on predicted CHANGE rather than predicted albedo? (2 November 2026)

You are Astra. Read, in this order: `docs/cc/2026-11-02_cv_design_brief.md`, your design
`docs/cc/2026-11-02_cv_design_codex_gpt6astra.md`, Fable's review `docs/cc/2026-11-02_cv_design_review_fable.md`
and your reconciliation `docs/cc/2026-11-02_cv_design_reconciliation_codex_gpt6astra.md`.

Same working rules: read-only commands only (git, rg, grep, cat, sed -n, ls, wc); no R, no pipeline scripts,
nothing that writes files. Web search allowed and expected. Cite every source (authors, year, venue, DOI) and
say plainly what is your own proposal. Never invent a reference. Plain words. Code as simple as possible.
Chris's decisions stand: the hemlock-decline sign is an outcome, never a selection criterion; in-range skill
is reported, not mixed into the selection score; the points agreed in your reconciliation are accepted
(no buffers, cover-free models as baselines only, the two added candidates, no reserved blocks, fixed
simplicity order, at least 10 blocks for the one-standard-error rule, testable months declared first).

Chris now decides only the score that chooses the model. The open disagreement: you recommend absolute
albedo error on withheld cover-tail cells, with paired nearby-cell contrasts as a supporting check; Fable
recommends the paired contrast as the primary score. Chris asked whether the paired idea has published
precedent. A quick search found that the principle of validating predicted change rather than predicted state
is established in species distribution modelling:
- Rapacciuolo et al. (2012), PLoS One, "Climatic associations of British species distributions show good
  transferability in time but low predictive accuracy for range change" (DOI 10.1371/journal.pone.0040212);
- Rapacciuolo et al. (2014), Methods in Ecology and Evolution, "Temporal validation plots" (DOI 10.1111/2041-210X.12181);
- Piirainen et al. (2023), Diversity and Distributions, "Species distributions models may predict accurately
  future distributions but poorly how distributions change" (DOI 10.1111/ddi.13687).
Verify these and look for others, including in land-cover/albedo, remote sensing, ecology and statistics
(for example space-for-time substitution and its validation; evaluating predicted differences or treatment
effects; local "window" or paired-pixel approaches to cover effects on albedo).

Answer:
1. What the literature establishes about judging a model on predicted change versus predicted state, and
   what does or does not carry over to this case (the forcing is driven by differences in predicted albedo
   between time slices at the same cell).
2. Whether there is precedent for using spatial pairs of modern cells as a stand-in for change over time in
   a validation or selection score, and its known problems.
3. A third option: real observed change in the MODIS era. Check in the repository what the modern cover
   for calibration is (source, years; scripts 1 and 2, the data provenance documents) and whether a
   cover-change dataset over roughly 2001 onwards exists in or could feasibly be added to the project for
   this region, so that cells whose cover really changed (harvest, fire, regrowth) give an observed albedo
   change to score against. Say whether it is feasible, its pitfalls (the cover classes versus the pollen
   cover fractions, snow and year-to-year variation, too few cells or too small changes), and published
   precedent for it.
4. Your recommendation for the selection score (state, change by spatial pairs, observed change, or a
   stated combination), the simplest version that does the job, and what each option would cost in code and
   fits beyond the reconciled design. Keep it to about two pages.
