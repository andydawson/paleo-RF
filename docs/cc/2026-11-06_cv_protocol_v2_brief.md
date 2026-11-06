# Brief for Astra (ultra effort, read-only): write the second cross-validation protocol

Read-only: change nothing; read-only shell commands allowed (git log/diff/show, rg, grep, cat, sed -n, ls, wc). Never
open `data/modis_albedo/requests/`. Web search allowed. Plain words, no private ids, no time estimates.

**Simplicity (Chris's rule):** as simple, clear, readable and parsimonious as possible; no overengineering; Andria
must be able to follow it. Reuse the existing code. **Precedent (Chris's rule):** every step names its precedent
from this application domain (albedo from land cover, vegetation albedo forcing, paleo-vegetation and transfer-
function calibration), with DOI and the passage read, as in your note
`docs/cc/2026-11-06_cv_domain_precedent_and_aic_codex_gpt6astra.md`; where the precedent is only from a
neighbouring field or none, say so and label the step our judgement.

## Inputs
- First protocol: `docs/cc/2026-11-02_cv_protocol.md` (keep its structure; this is its successor, fixed before any
  fit, and the first run stays on record as the previous experiment).
- Your redesign `docs/cc/2026-11-06_cv_redesign_codex_gpt6astra.md`; Fable's review
  `docs/cc/2026-11-06_cv_redesign_review_fable.md`; your precedent and AIC note above.

## Chris's decisions (6 November 2026)
1. **Scoring:** the tuning score uses only withheld cells within 250 km of a training cell; the far cells are
   reported beside, never used for the choice. This replaces the 3 November rule.
2. **No nesting:** one level of tuning; the score is labelled a selection score, with one sentence quantifying its
   optimism.
3. **Both separation tests:** Fable's real-data test (all configurations on the full data for April and May; the
   northeast historical-size evergreen-for-summergreen contrast with its standard error, and concurvity between the
   location and cover terms; does it move with location capacity?) and your synthetic-recovery test, with Fable's
   changes (drop the +0.5 truth; pass rules fixed before fitting; recovery reported beside the choice, and a
   configuration that fails cannot carry the northeast sign claim).
4. **AIC:** REML within each fit; cross-validation chooses; conditional AIC reported for every configuration; no AIC
   filter.
Earlier (5 November): support graded by distance outside today's range; in the hindcast comparison, one outside-hull
flag with its distance and band; area-weighted means; a new comparison tool beside the northeast figure tool;
Fable's trimmed figures.

## Still to propose (Chris approves with the protocol)
- Fable's additional location size of about 12 (the optimum appeared to lie between none and 30).
- The recovery pass rules (Fable's example: sign right in at least 18 of 20 replicates and |bias| at most half the
  true contrast; null invented contrast at most a quarter of the b = -0.5 contrast).
- Fable's nits 7-11 (true-model note; registry ids naming both axes, written out; tie-break order; pooled distance
  report with the maximum tested distance recorded; reuse run 1's model 8 fits and pipeline).

## Output
The protocol as a markdown document ready to file as `docs/cc/2026-11-06_cv_protocol_v2.md`: what is chosen and how;
the configurations; holdouts and the 250 km rule; scoring and selection; the two separation tests with pass rules;
distance reporting; AIC; what is reported only; code changes (as small as possible, each adds or removes); fit
count; reviews and verification; what the result can and cannot show; precedent table; references with DOIs. Then,
separately, a list of the points needing Chris's approval.
