**Verdict.** Hold for three small corrections and executable verification. I found no change to the anchored forcing arithmetic by inspection.

**Benefit.** These fixes help Andria interpret diagnostic figures correctly and distinguish reproduced outputs from copied inputs without changing the reported forcing calculations.

**Hand check.**

Take May, two cells, and configured slices 8,000 and 10,000 BP:

| Cell | Area | Older albedo | Younger albedo | Younger − older | Forcing |
|---|---:|---:|---:|---:|---:|
| A | 2 | 0.30 | 0.20 | −0.10 | +10 |
| B | 1 | 0.20 | 0.25 | +0.05 | −5 |

Using a HadGEM3/CAM5 kernel of −1 W m⁻² per 0.01 albedo gives `difference × 100 × −1`; CACK at +100 W m⁻² per unit albedo gives the same answers through `difference × −100`. Darkening warms.

With illustrative Earth area 100, script 9 gives domain mean `(2×10 − 5)/3 = 5` and global equivalent `(2×10 − 5)/100 = 0.15`. Script 10’s single-month contribution is also 0.15. If B’s forcing is missing, the domain denominator becomes 2 and the global equivalent becomes 0.20; missing forcing is not included in the domain mean. These expressions are unchanged.

The new age lookup assigns `8000 → 10000`, correctly replacing the previous erroneous `8000 → 11500` for this input. For the complete default sequence, the old reconstructed sequence and configured sequence coincide, retaining period pair counts **2, 3, 4, 4, 4, 4, 3**. Unrecognised younger ages stop. Either missing support endpoint now stops before the logical OR, including `TRUE | NA`.

For pollen counts of **2, 0, 0** across three represented slices, the new median is **0**, versus the old median of **2**. A grid region absent from the pollen table receives zeros throughout. The code agrees.

Kernel selection, scaling, ice calculations and random-seed derivation are unchanged. The kernel labels agree with the registry, including the legacy CAM5 surface designation. This does not establish that the legacy kernels are scientifically comparable.

**Findings.**

1. **Should-fix — protected directories are not resolved before comparison.**  
   [R/config_schema.R:85](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-drift/R/config_schema.R:85)

   The candidate path is resolved, but the forbidden paths are constructed lexically. If `/repo/output` links to `/storage/baseline`, `run$dir = "output/alt"` resolves to `/storage/baseline/alt` and no longer matches `/repo/output`. A previously rejected relative path can therefore pass when the protected directory itself is linked.

   **Consequence:** the isolation check does not enforce its stated protection for linked baseline directories. I found no such directory link in this checkout; this is a concrete conditional counterexample, not an observed overwrite.

   **Fix/check:** resolve the protected directories too. Test a temporary repository whose `output` directory is a link, rejecting both relative and resolved spellings while accepting an unrelated directory.

2. **Should-fix — the northeast figure calls an endpoint contrast the sign of the effect.**  
   [plot_northeast_cover_and_location.R:158](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-drift/tools/plotting/plot_northeast_cover_and_location.R:158), with the interpretation at lines 196 and 215.

   The calculation correctly measures **net albedo change between today’s minimum and maximum evergreen shares**. It does not determine the direction throughout that range. The supplied smoke figure demonstrates this: the green curve rises over approximately ET 0.30–0.45 inside the shaded range, although its endpoint contrast is −0.102.

   **Consequence:** readers can interpret the title and caption as a statement about the local evergreen effect or the hemlock transition, which this statistic does not establish.

   **Fix/check:** retain the calculation but describe it as a net endpoint contrast, giving the two ET endpoints. Describe disagreement between the fitted contrasts without promoting it to a general identification result. Test a curved example: at ET `(0.1, 0.3, 0.5)`, curves `(0.2, 0.5, 0.3)` and `(0.2, 0.3, 0.4)` both have positive net changes, but opposite directions over the final segment. No derivative machinery is needed.

3. **Should-fix — “within tolerance” remains possible without any tolerance comparison.**  
   [tools/compare_tables.R:85](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-drift/tools/compare_tables.R:85)

   For identical identifier-only tables, `numbers_checked` is false and `unchecked` is empty. The condition requires both an unchecked column and no checked numbers, so execution falls through to **“RESULT: within tolerance.”**

   **Consequence:** requested finding 2 is incompletely fixed; the verdict still claims a tolerance comparison that did not occur.

   **Fix/check:** base that branch on `numbers_checked`, with suitable wording for identifier-only agreement. Add an identifier-only case alongside the existing report-only and partial-tolerance tests. Preserve the intended exit-status behavior.

4. **Nit — the variant-sensitivity figure still omits the selected months.**  
   [scripts/9_forcing_barplot.R:349](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-drift/scripts/9_forcing_barplot.R:349)

   The new month wording reaches the headline, domain and kernel figures through `headline_line`, but this figure uses `sens_subtitle` alone.

   **Consequence:** a selected-month sensitivity figure can be detached from its configuration without revealing which months it represents.

   **Fix/check:** append the month wording here for subsets; check the full-year and winter-subset captions. Table bytes need not change.

5. **Nit — new comments reintroduce review history into executable files.**  
   [scripts/9_forcing_barplot.R:308](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-drift/scripts/9_forcing_barplot.R:308) and [R/training_support.R:54](/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/wt-drift/R/training_support.R:54)

   The former spends five lines recounting the replaced claims; the latter repeats the extraction history and review identifiers around a small helper. Keep the current contract and May limitation; move the history to the commit/report. The functions themselves are appropriately small.

Requested findings **3, 4, 5, 7, 10, 15, 20, 21 and 23** are implemented as requested by inspection. Findings **1, 2 and 6** need the corrections above; **8** has the minor omission above. The shared training-support preparation preserves the selected rows and hull inputs. I found no expansion into the explicitly deferred work. The commit bodies explain why the changes were made.

The implementer’s decisions are mostly sound:

- **Copy-marker trailing space:** keep this fix. Exact matching in `check_anchors()` explains both the previous false MATCH and the corrected SEEDED result. The inspected seed-1 specs copy prediction fits, which are not seed-1 anchor members; the diagnostic specs do not require anchor matches. I found no inspected spec whose verdict changes solely because it copies an anchored file without regenerating it. A future such spec should fail `--all`. Writing the marker directly also avoids requiring a helper absent from older target commits.
- **Empty specifications:** rejecting only when scripts, checks and anchors are all empty matches the request. Checks-only verification remains useful.
- **May guard:** putting it in the shared helper, including the northeast tool, is appropriate.
- **Required age argument:** appropriate. Leaving historical check scripts unchanged preserves their records, but newly dated checks targeting this code must supply the argument.
- **Northeast contrast:** acceptable as a descriptive net contrast, subject to finding 2’s wording.
- **Kernel title:** removing the unsupported factor-of-two claim without inventing another statistic is appropriate.
- **Documentation and fingerprints:** preserving the original spatial-evaluation script and deferring finding 12 respects scope. I independently confirmed that the added SHA is the base builder’s SHA; the diff contains the header edit and acceptance-list addition.

**What the proposed verification misses.**

The reported 20 passing test files are not sufficient evidence for the new scientific paths:

- `test_forcing_periods.R:20` largely repeats the implementation’s lookup expression. Its shorter-sequence assertion can also pass vacuously if all 8,000 BP rows disappear. Assert retained row counts, explicit period assignments, incomplete-cell removal and the presence of the terminal pair.
- `test_training_support.R` checks only rejection without May. Add equivalence checks for the helper’s returned rows/hull and a missing-younger/missing-older support case.
- The pollen check used data with no absent region–slice combinations. Add the **2, 0, 0** case and an entirely absent region.
- The northeast smoke run reproduces the old directions; it does not exercise reversed, equal or nonmonotone contrasts.
- Add a `verify_change` copy test proving that an unchanged copied anchor is SEEDED and fails `--all`, then that successful regeneration clears the marker and allows a real MATCH.
- Test reported-kernel subsets as well as current and legacy sky settings.

Before merge, use `tools/verify_change.R` at the exact final code commit:

1. **Legacy scripts 9/10:** adapt `2026-10-16_forcing-breakdown-3.R`; require all four script-9 anchor files to MATCH. Also compare script 10’s CSV against the base commit, since that CSV is not anchored.
2. **Default scripts 9/10:** run base and head against identical current inputs and compare every produced table byte for byte. The legacy anchor alone cannot establish default preservation.
3. **Script 1:** verify legacy tables against their anchors, following `2026-10-15_i16c-elevation-legacy-4.R`; compare default base/head tables too. Exercise diagnostic mode for the removed printed claims.
4. **Shared plumbing and stochastic preservation:** adapt `2026-10-31_refit-legacy-seed1-3.R`, retaining the complete seed-1 anchor and prescribed eight-thread environment.
5. **Tools and diagnostics:** use the tests-only specification pattern plus updated versions of `2026-10-27_diagnostic-plots-2.R` and `2026-10-28_northeast-location-plot-3.R`, including the targeted cases above and a MODIS-input diagnostic run.

No changed code consumes random draws or changes draw counts/seeds. Seed-1 identity tests reproducibility under matched inputs and environment; historical tolerances test agreement within measured stochastic variation. Neither establishes correctness of the diagnostic changes.

**Questions for Chris or Andria.**

- Should the northeast statement describe the **net contrast across today’s evergreen range**, the **actual 6–4.5 ka change**, or **local response directions**? The code currently calculates the first for its title and plots the actual past predictions separately. Meanwhile, label the existing contrast precisely.
- Monthly training support remains open: **May-only reference** or **separate support by month**. This change retains May-only support and stops when May is absent; it does not settle that scientific choice.

**Not checked.**

I ran no R, tests or pipeline scripts and did not independently reproduce output hashes or MODIS diagnostic results. I inspected the supplied smoke logs and figure, not the fitted objects numerically. Kernel-file metadata, literature precedents and the unchanged ice-readvance method were not independently revalidated. I read no Fable findings.

Files read: packet, all changed-file diffs, relevant scripts/helpers/configurations, regression contract, question records, anchor inventories, verification specs, smoke logs and northeast PNG; tool calls: 18 `functions.exec` calls comprising 40 read-only shell calls and one image read; no edits or R execution.