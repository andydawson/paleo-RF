# Code review for Astra: the cross-validation's geographic sensitivity reports (commit b7a5772, branch cv-design)

Read-only; read-only shell commands (git show/diff/log, rg, cat, sed -n) allowed; run no R. Fable reviews the same change
independently; then one reconciliation. Plain words.

The change implements decision 15 and the protocol's new section "Geographic sensitivity" (docs/cc/2026-11-02_cv_protocol.md,
end; docs/cc/2026-11-02_cv_design_decisions.md item 15), from your design (docs/cc/2026-11-03_cv_geographic_sensitivity_design_codex_gpt6astra.md)
and Fable's review of it. Read the diff: `git show b7a5772` (and 28f0dad for its verification record, cv-holdouts-9, PASS;
its in-range support table is in /home/expert/Documents/contracting/Andria/paleo-RF-verify/b7a5772/.rundirs/cv-holdouts-9/output/cross_validation/inrange.csv).

Check: (1) the code does what the protocol text says, no more (reported only; the choice and its score unchanged;
nothing reads a score to change the design); (2) arithmetic: km per prediction (nearest_km against the month's training
rows), km_band boundaries, cv_paired_by_band (each band a cv_score with one group; difference and its standard error from
the paired resampled scores), the equal-month in-range score through cv_score (group = month, weight 1/months), the
months-complete count, converged-only and inside-range-only filtering, the in-range support table and its feasibility
rule; (3) seeds: reuse of SEEDS$resample inside withr_seed cannot change the tail score's draws; (4) failure cases: a
failed or unconverged model 8, a model missing a month, empty bands, the in-range holdout's NA directions (now 'inside' in
cv_by_region); (5) the tests (tests/test_cross_validation.R, last three cases) are right and sufficient; (6) simplicity
(project rule: simple, concise, no bloat) and readability for Andria.
Output: verdict; findings table (file:line, issue, consequence, evidence, proposed check); what is right; questions for Chris.
