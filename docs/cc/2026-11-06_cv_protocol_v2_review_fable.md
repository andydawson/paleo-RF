*Fable (science-reviewer role), 6 November 2026: review of Astra's draft of CV protocol 2
(`2026-11-06_cv_protocol_v2_draft_codex_gpt6astra.md`). Read-only. Summary filed by the main session.*

**Verdict.** Ready after named changes. Chris's four decisions of 6 November, and those of 5 November, are
implemented exactly, and the science holds under hand check. Coefficient counts for all fifteen configurations:
loc0 52/99/249; loc12 63/110/260; loc30 81/128/278; loc100 151/198/348; loc500 551/598/748. Fit count
540 + 28 + 360 + 24 + 10 = 962. The delta-method standard error is correct. Under run 1's weights, 72% of the
selection weight lies within 250 km; within it, the beyond-0.10 cover band has 36 cell-month-holdouts in two blocks.

**Findings.**
1. Should-fix (Chris decides): how the winner's pipeline run is produced. Script 4 always fits the ladder and the
   spatial experiments, and script 5 reads the ladder, so saving only two fits needs new plumbing. Options:
   (a) as drafted, with new plumbing; (b) run scripts 4-10 unchanged for the winner: about 180 more cheap fits plus
   model 7's 12 slow ones, no new code (recommended); (c) a config switch to skip the ladder.
2. Should-fix: the null-truth threshold refers to the **exact generator contrast**, not a fitted one.
3. Should-fix: state the synthetic seed rule (`derive_seed(CV_SEED, 'cross_validation', 'recovery', month, truth,
   replicate)`), so the data are fixed before fitting and identical across configurations.
4. Nit: "< 250 km" rather than "<= 250 km", keeping the existing km bands (no cell pair is at exactly 250 km).
5. Nit: the five existing configurations keep their ids; the ten new ones get two-axis names; no aliases.
6. Nit: one open-land convention for the swap. The draft uses modern open land in section 7 (Chris's choice of 5
   November); the existing tool and section 6's historical-size exchange use 6 ka open land. Pick one and say so.
7. Nit, precedent: the Pirzamanbein section number disagrees between documents; point to the 4 November basis for
   the distance tables and the in-range holdout; retitle the Hu et al. row; Telford and Birks 2009 "described and
   criticised" extreme holdouts.
8. Nit: a one-sentence optimism statement (with fifteen candidates, about one bootstrap standard error; a
   rule-of-thumb judgement, not measured).

**Cuts (about a fifth of the document).** In-body precedent sentences that duplicate the table; a finiteness
eligibility clause that guards nothing; basis-adequacy diagnostics on 540 fits; the per-dataset setup-count rule;
the synthetic location-surface error; the distance-quantile paragraph (two columns in `comparison.csv` instead);
AIC per tuning fit (the 30 April-May full-data fits suffice); process paragraphs already in AGENTS.md.

**Verification additions.** Cells at 240 and 260 km (the second changes nothing); the fifteen setup counts as a
test; contrast-helper invariants; the null truth's exact contrast is 0; pass-rule boundaries (18/20 passes, 17/20
fails); represented target weight recomputed under the mask; AIC compared only within a holdout-month.

**On Astra's seven points:** approve all, with findings 2 and 3 in point 2, finding 1 deciding point 6, and the
finding 8 sentence for point 7.

**For Chris.** Finding 1 (a, b or c); accept that the deepest cover band is thin near training, reported beside;
the open-land convention. For Andria: is a common cover response across regions acceptable for reading the
northeast? (Not yet in the questions file.)
