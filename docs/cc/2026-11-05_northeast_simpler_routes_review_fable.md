*Fable (science-reviewer role), 5 November 2026: review of Astra's assessment of simpler routes
(`2026-11-05_northeast_simpler_routes_codex_gpt6astra.md`). Read-only. Issue #27.*

**Verdict.** Agree with dropping the pair check and with Astra's additivity argument. The monthly fixed-location
figure is sound only if its "supported" line is built at today's open-land fractions and each month's own hull (the
present tool does neither), and it should be the northeast part of the comparison that CV protocol section 7 already
requires, not a second tool. The literature numbers could not be checked here. The paper wording is accurate but
incomplete and premature.

**Hand check (additivity).** Both models are `eta = b0 + s(x,y) + s(elev) + s(OL,ET,ST)`, logit link
(`R/model_registry.R:33-34, 61-62, 111`). A swap changes eta by the same amount at every cell: with +0.3, a cell at
eta -2.0 goes 0.1192 -> 0.1545 (+0.035) and one at -1.5 goes 0.1824 -> 0.2315 (+0.049). The sign is the same
everywhere; only the exchange itself (open-land level, starting evergreen share) can change it, because the cover
smooth is curved. The 5 November log agrees (model 8 0.150 -> 0.075; cover_elev 0.142 -> 0.184; +0.169 across the
band). Not drawn out before: 0.075 is below the darkest modern May cell in the region (about 0.092), and 0.184 above
the brightest (about 0.150). Both models put 4.5 ka May albedo outside the region's modern range, in opposite
directions.

**Findings.**
1. Should-fix, figure. `tools/plotting/plot_northeast_cover_and_location.R:87-90, 129-134, 143-150, 158-165, 190`:
   the "today's evergreen range" band and the +0.169 are evaluated at each cell's 6 ka open land (mean 0.06), not
   today's (median 0.15). 71-100% of the band's cells are outside the hull. Add a line at today's open land for the
   supported reading, mark hull membership on the line, and drop or recompute the net contrast there.
2. Should-fix, figure. `R/training_support.R:59-61, 67-69`: the hull is May's for every month; a monthly figure
   needs each month's own hull (Chris's choice).
3. Should-fix, scope. It overlaps CV protocol section 7 (`docs/cc/2026-11-02_cv_protocol.md:75-83, 91, 222-224`):
   build the monthly swap inside that comparison. For Andria, use a 12-month by 2-model table: the 6 to 4.5 ka change;
   the swap at today's open land inside today's evergreen range; the share of cells outside the month's hull; and
   predicted 4.5 ka albedo against the region's modern minimum and maximum. Keep the figure for April and May.
4. Should-fix, records. The drop is not yet Chris's decision. When he makes it, record it in his words. Rewrite
   section 7 of the scientific questions file as "stopped at coverage, 0 pairs", keeping for Andria items 1
   (stands), 4 (towers), 5 (snow state) and 6 (her raster's retrievals).
5. Nit, literature: not checkable here (no paper tools in this session). The numbers match the 3 November design,
   which is consistency, not verification. Run refaudit/RefChecker before any number enters the paper.
6. Nit, wording: it omits the leading explanation (evergreen share follows latitude, r = 0.92; the May sign flips
   without the location term). "The inferred warming" presumes the winner still warms, which section 7 has not
   shown yet.

**Drop the check?** Yes. The coverage gate did its job; any rescue changes the study after seeing coverage; the
sign for question A is in the literature; it is outside what Andria approved. The only outcome-blind alternative is
single-pixel candidates instead of 3x3 blocks (10,110 stable evergreen pixels before the block rule, 125 after), still
outside what Andria approved.

**Checks for the extension.** The swap difference on the link scale is identical at two cells; the sign is the same
at every cell; a zero swap gives zero; the caption says the points are the actual mixes; the modern-range bound for
each month and model.

**For Chris.** Drop and close #27 at coverage? A table or a figure, and inside the section 7 comparison? Each
month's hull, or May's for all?

**Not checked.** The four papers' numbers and pages; the winner's monthly fits; the LC_Type5 threshold; hull shares
for months other than May.
