# Independent review of the cross-validation code (2 November 2026)

Repository: the current directory, branch `cv-design`. The change under review is
`git diff c171a06 b0cf6b1` (files: R/model_registry.R, R/cross_validation.R,
tools/cross_validate_albedo.R, tests/test_cross_validation.R).

Requirements: the protocol Chris approved and froze, `docs/cc/2026-11-02_cv_protocol.md`, with his
decisions in `docs/cc/2026-11-02_cv_design_decisions.md`. Background: the brief, Astra's design, Fable's
review and the reconciliation (`docs/cc/2026-11-02_cv_design_*.md`).

A development run of the first stage (holdouts; no model fitted) on the main refit's data, made by the
implementer, is in `../cvtest/output/cross_validation/` (directions.csv, feasibility.csv, comparison.csv,
target.csv, directions.pdf): three directions (shares 52%, 40%, 8% of the outside target weight), all 36
month-holdout combinations feasible at the 80th-percentile cut; withheld cells lie further outside their
training range (median about 0.04) than the past mixes (about 0.01-0.02) and 170-340 km from the nearest
training cell, while past mixes are at 0 km.

Review questions:
1. Does the code implement the protocol exactly? List every departure (sections 2-6), with file:line.
2. Correctness of the arithmetic: target weights (area x ice-free fraction; slices and months equal; the
   reconstruction of each slice's ice fraction from script 7a's pairs), departure angles and their
   grouping, the cut, the group key (month, direction, distance band), the score and its block resampling,
   the standard error of the paired difference, the choice rule and its tie-breaks, convergence and retry.
3. Leakage: can any withheld cell's albedo reach a fit; can the scores or the hemlock sign influence any
   choice made before scoring?
4. The fit stage: is anything that the score stage needs missing from the saved predictions; will the
   inrange holdout behave as the protocol says; behaviour when a fit fails outright (an error, not
   non-convergence).
5. Tests: what the protocol requires that the tests do not check (compare the verification list in Fable's
   review and the protocol, section 8).
6. Simplicity and readability for Andria (Chris's rule: as simple and concise as possible, no bloat):
   anything to cut or simplify.
7. What the development-run numbers say about whether the folds imitate the hindcast (the protocol says
   results are tests of transfer across cover and space, not unbiased estimates of hindcast error).

Findings ranked blocking / should-fix / nit, each with file:line, consequence, evidence and a proposed check.
Read-only.
