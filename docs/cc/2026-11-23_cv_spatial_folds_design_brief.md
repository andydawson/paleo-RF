# Brief: one cross-validation method for spatial autocorrelation and unseen land cover (design only)

Given on 23 November 2026, the same brief to Fable and to Astra (Codex). Each designs independently,
without seeing the other's work, and then there is one reconciliation round. This is design only:
nothing is built and nothing is run until Chris approves.

**Benefit to the paper:** the albedo model that drives the hindcast vegetation forcing would be
chosen on a score that is honest about new places as well as new cover mixtures.

## Why this is being done

On 15 November Chris asked us to come back to the cross-validation folds. He said that spatial
autocorrelation must be dealt with, "ideally" by "a single CV method" that handles it "alongside the
generalisation to unseen land cover". Andria's written answer of 12 November asked for the same
thing: spatial blocks plus cover composition in the folds, and a comparison of models with and
without the location term. Chris's notes from their call ask whether the spatial location term is
needed and what it tells us; Andria thinks of it as a proxy for climate.

Protocol 2 (`docs/cc/2026-11-06_cv_protocol_v2.md`) holds out cells by how extreme their cover is
(directional tails of the modern cover triangle). Its score is taken only from withheld cells less
than 250 km from a training cell. The median distance is about 130 km, and many of those cells are
direct neighbours. Spatial structure enters only through the 5 x 5 degree block resampling for
standard errors, and through one spatially blocked holdout that was reported but not used to choose.
The score is therefore optimistic for new places. It also cannot separate skill borrowed from
neighbours (the location term) from skill of the cover response. The revised results review
(`docs/cc/2026-11-10_cv_protocol_v2_results_review_fable.md`, with Astra's check
`docs/cc/2026-11-10_cv_protocol_v2_results_review_check_codex_gpt6astra.md`) found the following:

- The choice is fragile. 61% of the chosen model's margin over model 8 comes from four blocks in
  western and interior Alaska.
- Inside the modern cover range, the chosen model and model 8 tie.
- The vegetation forcing differs between candidate models in every period.

## Read first

- The protocol, its decisions and its briefs: `docs/cc/2026-11-06_cv_protocol_v2.md`,
  `docs/cc/2026-11-06_cv_redesign_*`, `docs/cc/2026-11-06_cv_deep_band_*` and
  `docs/cc/2026-11-06_cv_domain_precedent_and_aic_*` (the precedent search already done).
- The code: `R/cross_validation.R`, `R/cv_separation.R`, `tools/cross_validate_albedo.R`,
  `tools/check_cv_separation.R`, `tools/compare_cv_hindcasts.R`, and the model registry and the
  calibration settings in `config.R`.
- The results review and its check (above), and the protocol 2 outputs in
  `../paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts/output/cross_validation_v2/` (coverage,
  feasibility, distances, scores by region).
- `CONTRIBUTING.md` and `AGENTS.md`.

## What to deliver

1. **Published precedent**, from this domain wherever possible: palaeoecological transfer functions,
   land-cover and albedo mapping from remote sensing, and species distribution models. Name the paper,
   the method and what it says about blocking in geographic space and in predictor (cover) space at
   the same time. Leads not yet checked: Telford and Birks 2009 (h-block cross-validation for
   transfer functions), Roberts et al. 2017 (blocking in geographic and in environmental space),
   Meyer and Pebesma 2021 and 2022 (matching the distances from test to training data to those of
   the prediction task, in space or in predictor space), and Valavi et al. 2019 (blockCV).
2. **One recommended method**, with at most one alternative. Say how the folds are built, what is
   scored, how the score is weighted to the hindcast target, and how it combines geographic distance
   with cover novelty. Say what it can show and what it cannot. In particular, can it tell whether
   the location term helps prediction for new places, and does it reduce the Alaska fragility?
3. **Reuse and deletion first.** Say which existing functions and outputs it reuses, which it
   replaces and what can be deleted. Give an estimated line count, +added / -removed = net, covering
   code, tests and documents.
4. **Cost**, in the number of model fits, against the measured fit counts and runtimes of
   protocol 2 in the records. Give no time estimates beyond those measured runtimes.
5. **Questions** that only Chris or Andria can decide, written so that each can be answered on its
   own.
6. **Not worth doing**, and the limits of the design.

Keep it simple and readable for Andria. Do not build for hypothetical future uses. Chris's general
rules on simplicity and architectural additions were included in the prompt each designer received.
