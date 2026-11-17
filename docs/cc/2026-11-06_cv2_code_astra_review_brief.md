# Brief for Astra (ultra effort): review Fable's review of your CV protocol 2 code

Change no file; do not commit. You may run R only to parse, run the tests, and make small reads of saved fits
(`THREADS=1 OPENBLAS_NUM_THREADS=1 tools/rscript.sh`). Never open `data/modis_albedo/requests/`. Plain words.

Fable reviewed commit 10c1886 (your implementation): `docs/cc/2026-11-06_cv2_code_review_fable.md`. For each
finding and each verification addition: agree, agree with a change, or disagree, with evidence. Settle finding 1 by
running the check Fable proposes on the saved April model-8 REML fit
(`/home/expert/Documents/contracting/Andria/paleo-RF-verify/be277d7/.rundirs/run1-main-fit-apr-jun/output/calibration/calibration_prediction_fit_apr_bluesky.RDS`):
`fit$rank` against `length(coef(fit))`, and the rank of the cover smooth's model-matrix columns; say whether the
rank deficiency matters for anything beyond concurvity (predictions, Vp-based standard errors of the contrasts).
Recommend for each of Fable's three questions to Chris. End with the list of changes you recommend before the run.
