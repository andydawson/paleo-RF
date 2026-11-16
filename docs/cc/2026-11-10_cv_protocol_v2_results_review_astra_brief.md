# Brief for Astra (ultra effort): check Fable's review of the cross-validation protocol 2 results

*Chris, 10 November 2026: "Yes, Astra checks it." Read-only.*

## Rules
- Change no file; do not commit. You are in the worktree of branch `cv-v2`.
- You may run R for small read-only checks: `THREADS=1 OPENBLAS_NUM_THREADS=1 tools/rscript.sh <script or -e>`.
  Write nothing into the repository or any run folder. No new model fits beyond a few small ones you need to
  confirm a number; say exactly which you made.
- Never open `data/modis_albedo/requests/`.
- Plain words, no private ids. Verdict first. Findings carry file and line, consequence, evidence and a proposed
  check. Where a method or benchmark is proposed, give published precedent **from this application field**
  (albedo from land cover, vegetation albedo forcing, palaeo-vegetation calibration), with DOI and the passage
  read, and say plainly where there is none.

## What to check
The review: `docs/cc/2026-11-10_cv_protocol_v2_results_review_fable.md`. Its scripts and outputs:
`docs/cc/2026-11-10_cv_protocol_v2_results_review_checks/`. The protocol: `docs/cc/2026-11-06_cv_protocol_v2.md`.
Saved outputs: `/home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2/`.
Pipeline runs: `.../1d31cfc/.rundirs/cv2-winner` (chosen model), `.../f05628d/.rundirs/cv-mod8` (model 8),
`.../e82f399/.rundirs/cv-chosen` (coarse location). Snow-free and snowy runs: `.../8e3f3a4/.rundirs/run2-snowfree-2`,
`.../74b5482/.rundirs/run7-snowy`.

For each numbered claim say **confirmed, confirmed with a change, or not confirmed**, with your own evidence. Do
not reuse Fable's scripts to confirm Fable's numbers: re-derive the key ones your own way.

1. **Section 2.1, Alaska.** Four blocks give 61% of the chosen model's margin over model 8; without them the
   flexible-location version with straight-line cover ties the chosen model (0.04 SE). Is the block-share
   calculation right? Is leaving those blocks out a fair sensitivity check, and is "the location term extrapolating
   at the corner of the map" the right reading? What does the protocol's own rule return without them?
2. **Section 2.3.** The score covers 12.8% of the hindcast; inside the range the two models tie; the three
   pipelines' forcing differs since 6 ka and agrees before. Are the three runs like for like (settings, inputs,
   seeds)? Is the forcing table read correctly?
3. **Section 2.4, twelve months against published contrasts.** Re-derive at least April, July and December for
   the three pipeline fits. Is the comparison with Hollinger et al. (2010) and Jin et al. (2002) fair: class means
   and tower sites against one-degree cover fractions; a continental straight-line slope read at the northeast's
   mean albedo; summergreen including larch and shrubs? Are the quoted published values right (check the sources if
   you can reach them; otherwise say they were not re-checked)?
4. **Section 2.5, snow (exploratory).** Fable fitted the chosen model's formula and its flexible-location rival to
   the existing snow-free and snowy tables (58 fits, not saved). Re-derive two or three of them. What could make
   the snow-free result misleading (different cells per month, the 75% rule, what "snow-free" albedo means in the
   build, summer months where the two tables should agree)? Does the evidence support "snow explains the chosen
   model's wrong winter sign, not model 8's"?
5. **Section 2.6.** Is the reading of the made-up-truth test fair?
6. **Sections 3 to 5.** The corrections, the meaning for the paper and the six recommendations: agree, agree with
   a change, or disagree. In particular: is a declared test against published contrasts, by month and snow state,
   a sound way to judge the fitted cover response, and what is its precedent in this field? What would you add or
   drop to keep it simple?
7. **What the review missed**, most important first.

End with: the claims Chris can rely on now; the claims that need more work first; and any question for Chris or
Andria, each written so it can be answered without reading anything else.
