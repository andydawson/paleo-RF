# Brief for Astra (ultra effort, read-only): redesign the cross-validation as model tuning, with a check that the
# models can separate latitude from evergreen cover

Read-only: change nothing. Read-only shell commands are allowed (git log/diff/show, rg, grep, cat, sed -n, ls, wc).
Never open `data/modis_albedo/requests/`. Web search allowed: ground every step in published practice, cite with
DOIs, and say plainly where a step is our own adaptation. Plain words, no private ids, no time estimates.

**Simplicity (Chris's rule):** the smallest design that does the job; as simple, clear, readable and parsimonious
as possible; no overengineering; Andria (a scientist who knows R) must be able to follow it. Reuse the existing CV
code (`R/cross_validation.R`, `tools/cross_validate_albedo.R`, `R/model_registry.R`); say for each step whether it
adds or removes code. Anything for a case that has not happened and cannot change a result goes under "not worth
doing".

## Chris's words (6 November 2026)
"Rather than just generalisation across CV folds, we also need to know if the new models we train can separate
latitude from evergreen cover. Also, I had assumed that with the cross-validation we were doing an ML style
hyperparameter tuning to try and produce a better model. Otherwise we have only added one candidate (the
coarse-grained) so it is no wonder we don't do much better! Can you put this to astra for re-design please and we
will then rerun all the CV."

Earlier (5 November), on support: "being outside might not be a problem in itself, it is how far outside that is the
problem ie too far and the model will struggle to extrapolate, just outside and it should be fine."

## What exists
- Protocol: `docs/cc/2026-11-02_cv_protocol.md` (with its amendments). Thirteen fixed candidates (`CV_MODELS` in
  `R/model_registry.R`: the ladder mod1-8, cover_elev, lin_cover, lin_cover_noloc, mod8_coarse_loc with location
  k = 30, mod8_small_cover). Each hyperparameter was tried at one alternative value only. Holdouts: modern cells at
  the edge of today's cover range, in the directions the past mixes move, with cover-distance bands and km bands;
  one-standard-error rule; an in-range holdout reported only.
- Results (`/home/expert/Documents/contracting/Andria/paleo-RF-verify/f07ff68/.rundirs/cv-run1/output/cross_validation/`):
  mod8_coarse_loc chosen (RMSE 0.0845 against 0.1002 for model 8); worse in range (0.0512 against 0.0456); April and
  May ties continent-wide; in the northeast in April and May model 8 predicts better, and the chosen model is too
  bright there. Fable's review of the comparison design summarises this:
  `docs/cc/2026-11-05_cv_comparison_and_sign_design_review_fable.md`.
- The northeast problem: there, evergreen share follows latitude (correlation 0.92; 0.04 over all fitting cells); at
  fixed latitude evergreen share makes almost no difference to May albedo; model 8 with and without the location term
  give opposite signs for 6 to 4.5 ka. The figure: `tools/plotting/plot_northeast_cover_and_location.R`.
  Astra's earlier note that the CV cannot settle the northeast sign:
  `git show cv-design:docs/cc/2026-11-03_cv_northeast_question_codex_gpt6astra.md`.
- The comparison design waiting on this (Chris's choices of 5 November: one support label, but graded by how far
  outside; a new comparison tool beside the northeast figure tool; area-weighted means; Fable's trimmed figures):
  `docs/cc/2026-11-05_cv_comparison_and_sign_design_codex_gpt6astra.md` and Fable's review above.
- Machine: 48 cores, shared with other runs; each GAM fit uses one thread. The first CV took 468 fits.

## What to design
1. **Tuning.** Turn model selection into proper hyperparameter tuning, as in ML practice for GAMs and spatial
   models: which hyperparameters matter here (for example the location term's basis size or penalty, the cover
   term's size, the elevation term, the smoothing method), what search (a small grid, chosen and why), which
   validation scheme scores it (the existing extrapolation holdouts, spatial blocks, nested CV if needed to report
   an honest error for the tuned model), and the selection rule. Keep the search small enough to run; say how many
   fits.
2. **Can a model separate latitude from evergreen cover?** A direct test, not just held-out error. For example a
   simulation (parameter-recovery) check: build synthetic albedo on the real cells and real covers, with a known
   cover effect (including a known evergreen-for-summergreen sign) and a known location effect, fit each candidate
   or tuned model, and see whether it recovers the cover effect in the northeast, where cover and latitude are
   confounded. Also consider holdouts or diagnostics that break the evergreen-latitude link. Say what result would
   mean a model can, or cannot, separate them, and how this enters the choice (a gate, or reported beside it).
   Ground it in the spatial-confounding literature.
3. **How far outside.** Fold in Chris's point: grade support by distance outside today's range (the CV's existing
   cover-distance bands, or better), and show how well the tuned model predicts at each distance, so the comparison
   can say which hindcast results lie within the distance the models were shown to handle.
4. **What to rerun.** The whole CV from the start, under a new protocol fixed before fitting (as the first one was).
   Which existing code, holdouts and records are reused; what changes; what the new protocol must state.
5. **Reviews, verification and records** in proportion (AGENTS.md).
6. **What Chris and Andria must decide.**

Output: a markdown design with a summary of at most ten lines; sections 1-6; "not worth doing"; references with DOIs.
