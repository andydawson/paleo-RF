*Fable (science-reviewer role), 5 November 2026: review of Astra's design
(`2026-11-05_cv_comparison_and_sign_design_codex_gpt6astra.md`). Read-only.*

**Verdict.** The definitions are right: the swap, the weights, deterministic predictions against simulated means,
the three-step interval, the ice part and signed contributions. Astra's CV point is confirmed by the saved reports.
But this is not the smallest design. The two CV-derived support labels and the tiered period rule guard a case that
is empty in this run. Two figure elements duplicate existing products. The rename deletes Chris's location-term
figure. And the design does not say how one tool reads two run folders.

**Hand checks.** Swap endpoints at modern open land 0.10 and 0.20 over evergreen 0.09-0.50 are all valid mixes.
6 to 4.5 ka May model 8: 0.075 - 0.150 = -0.075 (darker), which gives positive forcing (warming): the albedo table
(positive = brighter) and the forcing table (positive = warming) carry opposite signs for the same event. The
area-weighted three-step sum equals the endpoint change only on a common cell set, so that must be asserted. The ice
part differs between models but is zero in the northeast 6-4.5 ka. Support labels: `scores.csv` has represented = 1
for all models, so "outside and unrepresented" is empty and "outside but represented" equals "outside the hull".

**Findings.**
1. Should-fix: one support label (outside the month's own hull at either end of any pair in the period, the
   existing rule of `tools/plotting/plot_forcing_vs_training_support.R:57-69` per month), plus one sentence that
   the CV represented 100% of the outside target. Removes the direction and distance machinery; the tool reads
   nothing from the CV run.
2. Should-fix: say how one tool reads two run folders: two run-directory arguments, `readRDS()` on the fixed
   product paths of `R/paths.R`, paths and md5s logged (about ten lines).
3. Should-fix, Chris's decision: do not rename the northeast tool; that deletes the 28 October location-term
   figure. Instead, a new small `tools/compare_cv_hindcasts.R`, with `cells_with_evergreen()` moved to
   `R/training_support.R`. The old tool can admit `mod8_coarse_loc` with one changed condition (its no-location
   counterpart is `cover_elev` too).
4. Should-fix, interpretation: the chosen model is worse inside the range (RMSE 0.0512 against 0.0456, 2.3 standard
   errors). April and May are ties continent-wide (0.1109 against 0.1119; 0.1706 against 0.1720). Its pooled gain
   comes from June, March, July, August and December, and it is worse in February. So the CV does not separate the
   models on a spring sign.
5. Should-fix, literature: Hollinger rows use only the northerly evergreen subset; show both subsets or the range,
   and say why. Source numbers and pages not checked here.
6. Should-fix, records: the drop note paraphrased the hull choice as Chris's (fixed: it now quotes the option he
   chose).
7. Nit: drop the HadGEM3 vegetation-component difference map (it equals the total away from ice).
8. Nit: the forcing panel of the series figure repeats Table 2; keep the albedo series only.
9. Nit: state the opposite sign conventions in the table headers. Use one source for the evergreen range, the
   albedo range and the swap cells: the month's fitting rows in the region. The support strip can be caption numbers
   or a coloured curve.

**Verification additions.** Telescoping on the real forcing per cell-month. Every fitting row inside its own month's
hull. Identical cell sets asserted. Zero and reversed swaps. Deterministic against simulated means within a stated
tolerance. The northeast CV comparison rests on 4-6 blocks: say so.

**Astra's CV point: confirmed** (`by_region.csv`, northeast, model 8 against chosen: April 0.036/0.038 and
0.031/0.085; May 0.035/0.058 and 0.042/0.060; in-range April 0.020/0.045, May 0.026/0.039, 51 cells in 4 blocks).
The chosen model predicts the northeast too bright in spring at modern cover.

**For Chris.** One support label or three; a new tool beside the location-term figure, or the rename; each month's
own hull (in his words); area-weighted or unweighted regional means; which difference maps.
