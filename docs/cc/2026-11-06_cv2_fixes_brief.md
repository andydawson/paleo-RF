# Brief for Astra (ultra effort): make the fixes Chris chose before the CV protocol 2 run

Edit files in this worktree only; do not commit (I do). No network. Never open `data/modis_albedo/requests/`. Run R
only to parse and run the tests (`THREADS=1 OPENBLAS_NUM_THREADS=1 tools/rscript.sh`); no CV, capacity or recovery
fits. Do not edit the question files or write other documents beyond what is asked.

## Chris's decisions (6 November 2026)
- **Concurvity:** for the ten thin-plate configurations, report concurvity as NA with the reason ("not computable:
  cover fractions sum to one, so the thin-plate cover basis is rank-deficient"); record each fit's rank and
  coefficient count (and the cover block's rank) before the fit is discarded; the five linear-cover configurations
  keep their concurvity.
- **Fixes:** your recommended list in `docs/cc/2026-11-06_cv2_code_review_codex_gpt6astra.md`: (1) remove the
  duplicate historical exchange (`month_capacity`); (2) move fixed interpretation prose into the run report (a short
  section in `docs/cc/2026-11-06_cv2_implementation.md` or the run order), keeping generated facts and essential
  labels; (3) merge the twelve in-range specs into four (three months each) and update the job and fit counts;
  (4) one comment for the ET/ST >= 0.05 rule above `fixed_exchange()`; (5) the four tests: reporting policy (NA with
  reason, rank kept), the linear-cover logit invariant, the independent hand score through the scoring stage
  (0.002323295918367347, represented 2/3), the either-endpoint-outside cases. Keep the two record writers and
  `predicted_nearby_depth.csv`.
- If `tests/test_paths.R` needs `output/calibration/calibration_model_stats.csv`, say how the verification
  worktree will have it (do not copy data into this worktree).

## Report
Files changed and lines before and after; test results; the updated job and fit counts and run order.
