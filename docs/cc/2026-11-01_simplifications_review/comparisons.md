# Before and after comparisons of the simplifications, 1 November 2026

Figures and console output are not anchored, so the same runs were made at the base (ac90729, the drift-fix line
the simplifications started from) and at the branch tip (51888b4), each with `tools/verify_change.R`, and their
outputs compared file by file. PDFs were compared with their creation and modification dates removed; every other
file by MD5.

- **Script 1 with its diagnostics on** (`simplify-diag1-base` and `simplify-diag1-head`, original configuration):
  the same 29 files in `figures/diagnostics/`, all identical, and the two data tables identical (31 files). The
  console logs are identical apart from the run's timestamped manifest name.
- **Script 7** (`simplify-script7-base`, compared with script 7's outputs in `simplify-legacy-scripts78`): all 17
  files it wrote identical.
- Numbers checked against the anchors in the other runs: scripts 1-2 (`simplify-legacy-prep`), scripts 5-6 at seed 1
  with 17 test files (`simplify-legacy-seed1`), scripts 7, 7a and 8 (`simplify-legacy-scripts78`), scripts 9-10 with
  `test_paths.R` and `test_check_comments_only.R` (`simplify-legacy-forcing`). All PASS.
