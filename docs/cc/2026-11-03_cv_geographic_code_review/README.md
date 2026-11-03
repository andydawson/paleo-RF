# Code review of the cross-validation's geographic reports (3 November 2026, issue #24)

The change: commit b7a5772 (decision 15; protocol section "Geographic sensitivity"). Reviewed independently by Astra
(`astra_review.md`) and Fable (`fable_review.md`), each given the same code and requirements; both found the arithmetic,
distances, seeds and equal-month weighting right and the choice untouched, and the same gap: failed or missing fits were
not reported reliably (a model never converging could vanish from the in-range table, or crash it if it was model 8).
Fable added: drop failed fits per row in the by-distance table (Chris chose this), label the band columns, regenerate
`holdouts.rds` at the fitting commit, and run the stages end to end with a stand-in for the fits. Chris approved all
fixes and asked for each band's share of the selection score's weight.

Fixes: 84b8689, then the second looks (`astra_second_look.md`, `fable_second_look.md`): all first-round findings fixed;
Astra found an empty-table crash (every in-range fit failed) and asked for more tests and an old-against-new check of
the selection; Fable asked for a test pinning the weight-share formula, the choice compared with the old code, the
records filed and a verification at the head commit. All done in the following commit.
