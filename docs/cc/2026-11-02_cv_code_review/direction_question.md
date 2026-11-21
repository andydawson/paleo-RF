# Question for Astra: which direction should a withheld cell's error count under? And is it leakage? (3 November 2026)

You are Astra. Repository: the current directory, branch `cv-design`. Read the protocol
`docs/cc/2026-11-02_cv_protocol.md`, the decisions `docs/cc/2026-11-02_cv_design_decisions.md`, the code
`R/cross_validation.R` and `tools/cross_validate_albedo.R`, and the two code reviews and the reconciliation in
`docs/cc/2026-11-02_cv_code_review/` (your review is astra_review.md, finding 3; Fable's reconciliation, point 3
and question 1). Read-only commands only (git, rg, grep, cat, sed -n, ls, wc); no R; nothing that writes.
Web search allowed; cite sources (authors, year, venue, DOI) and say what is your own proposal. Plain words.

The question Chris must decide. The score weights each withheld cell's squared error by the target weight of its
group (month, direction, distance band). Past cover mixes are grouped by the direction in which each actually lies
outside the month's training range (nearest point of the hull's edge). A withheld cell can be grouped either
(a) under the direction of the holdout that withheld it (as coded), or (b) under the direction in which it actually
lies outside its own fold's training range, computed the same way as for the past mixes (your recommendation and
Fable's). At the edges of a holdout the two differ.

Chris asks: option (b) suppose, "but this will cause information leakage from the hindcast prediction data into the
training. In ML that is bad practice. Is it OK here?" The main session answered: the past has no albedo, so only past
cover (predictors, unlabelled) shapes the folds and weights; no past or withheld albedo reaches any fit; this is the
covariate-shift practice of importance-weighted cross-validation (Sugiyama, Krauledat and Müller 2007, JMLR 8:985-1005)
and of prediction-location-based folds (Mila et al. 2022; Linnenbrink et al. 2024); the caveat is that the score
measures skill for this hindcast, not general skill. Chris asked for your view at ultra effort.

Answer, in about one page:
1. Is either option leakage in the machine-learning sense? Be precise about what information flows where: past cover,
   withheld cells' cover, withheld cells' albedo, training albedo, the hindcast predictions. Check the code for any
   path by which past or withheld albedo, or predictions, could influence a fit, the folds, the weights or the choice.
   Verify the main session's citations and say whether they support its answer.
2. Any subtler risk: e.g. selection optimism from tailoring the folds to the target, the weights depending on the
   training range, or option (b) moving cells between groups in a way that favours some models.
3. Your recommendation between (a) and (b), and the one-line reason, plus anything to report alongside (for example
   the number of cells whose direction changes).
