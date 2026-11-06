*Fable (science-reviewer role), 6 November 2026: check of Astra's deep-band note
(`2026-11-06_cv_deep_band_codex_gpt6astra.md`). Read-only. Summary filed by the main session.*

**Verdict.** Astra's counts are right. The brief's 96%/88% are wrong: they came from Fable's own earlier message on
protocol 2, were not in the filed review, and cannot be reproduced. The right figures within 0.05 of the hull are
95.3% (within 250 km) and 84.5% (all distances). Protocol 2's own nearby shares are 86.3% within 0.05, and 1.5% deep
(all in one direction, two blocks). Keep the 250 km rule; do not widen to 500 km; report the deep band beside the
score by direction; point the "deep cover at the northeast's own cells" question at the synthetic recovery test.

**Checked.** From `groups.csv` weights and `by_distance.csv` shares (to 11-13 figures): the 36 nearby deep
cell-months are all in the less-evergreen direction (d1), none in the northeast's less-open-land direction (d2). At
250-500 km the deep band holds 276 d1, 132 d2 and 132 d3 cell-months; 132 d2 is about eleven cells per month, in at
most five blocks. Run 1's winner gained only at 250-500 km, and was worse than model 8 in the deep band at both
distances.

**Findings.**
1. Correct the brief's numbers (above).
2. Do not widen to 500 km. That band carries 21.8% of run 1's weight and is the only band where run 1's winner beat
   model 8, so widening partly reverses the 6 November decision, for about eleven deep northeast-direction cells
   per month.
3. Add each cell's own direction to the distance table (`tools/cross_validate_albedo.R:319, 353`; one line), so the
   paper can state: no modern cell within 250 km of training lies 0.10 or more outside the range in the northeast's
   direction; that direction is tested nearby up to the 0.05-0.10 band (where the northeast's 4.5 ka median, 0.085,
   lies), and beyond 0.10 only at 250-500 km on about eleven cells per month.
4. Nit: Astra's 132 are cell-months (about eleven cells); the geometry-only check of scattered holdouts is not worth
   running.
5. Nit: 1.5% of the nearby weight on two blocks is unlikely to decide the choice (about 5e-05 against standard
   errors of about 1.5e-03); accept and report.

**Options checked.** Scattered holdouts: restoring cells to training can only reduce depth (the distance to a convex
set does not grow as the set grows), and a mix seen next door is not an extrapolation. Buffered spatial CV: depth
collapses when the mix exists beyond the buffer. Past cells as a target: already the design. The synthetic recovery
test is the one place where a hindcast-sized exchange at the actual northeast cells is tested (under a stipulated
truth); one sentence ties it to the untested limit, no code.

**For Chris.** Accept 1.5% of the nearby weight on two blocks (default: accept and report). **For Andria.** Is
nearby modern skill up to 0.10 plus synthetic recovery under a stipulated truth enough for the paper's northeast
claim?
