# Verification case-study-cover-contrasts: PASS

- verdict: **PASS**
- commit: 545479befafd203eaa5bdd0109d3ae1706a1e5b5
- spec: `/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/case_specs/2026-11-18_case-study-cover-contrasts.R`
- started 2026-11-18 22:24:57 UTC, finished 2026-11-18 22:30:42 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/545479b` at 545479befafd203eaa5bdd0109d3ae1706a1e5b5; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/case-study-cover-contrasts`; configuration `.rundirs/case-study-cover-contrasts/config_used.R` (from `config.R`); 0 files copied in
- runner `tools/rscript.sh` with THREADS=1 OPENBLAS_NUM_THREADS=1

## Scripts


## Anchors


## Checks

- `tests/test_cv_separation.R`: exit status 0 (log `check_01.log`)
- `tests/test_training_support.R`: exit status 0 (log `check_02.log`)
- `tests/test_explore_cover_contrasts.R`: exit status 0 (log `check_03.log`)
- `tests/test_config.R`: exit status 0 (log `check_04.log`)
- `tests/test_paths.R`: exit status 0 (log `check_05.log`)
- `tools/check_cover_contrasts.R inputs /home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts /home/expert/Documents/contracting/Andria/paleo-RF-verify/8e3f3a4/.rundirs/run2-snowfree-2 /home/expert/Documents/contracting/Andria/paleo-RF-verify/74b5482/.rundirs/run7-snowy --fill-missing`: exit status 0 (log `check_06.log`)
- `tools/explore_cover_contrasts.R case-studies /home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts /home/expert/Documents/contracting/Andria/paleo-RF-verify/7c12534/.rundirs/cover-contrasts-full .rundirs/case-study-cover-contrasts/summaries --fill-missing`: exit status 0 (log `check_07.log`)
- `tools/explore_cover_contrasts.R case-studies /home/expert/Documents/contracting/Andria/paleo-RF-verify/8e3f3a4/.rundirs/run2-snowfree-2 /home/expert/Documents/contracting/Andria/paleo-RF-verify/7c12534/.rundirs/cover-contrasts-full .rundirs/case-study-cover-contrasts/summaries --fill-missing`: exit status 0 (log `check_08.log`)
- `tools/explore_cover_contrasts.R case-studies /home/expert/Documents/contracting/Andria/paleo-RF-verify/74b5482/.rundirs/run7-snowy /home/expert/Documents/contracting/Andria/paleo-RF-verify/7c12534/.rundirs/cover-contrasts-full .rundirs/case-study-cover-contrasts/summaries --fill-missing`: exit status 0 (log `check_09.log`)
- `tools/explore_cover_contrasts.R report .rundirs/case-study-cover-contrasts/summaries`: exit status 0 (log `check_10.log`)
- `tools/check_cover_contrasts.R case-studies .rundirs/case-study-cover-contrasts/summaries /home/expert/Documents/contracting/Andria/paleo-RF-verify/7c12534/.rundirs/cover-contrasts-full /home/expert/Documents/contracting/Andria/paleo-RF-verify/1d31cfc/.rundirs/cv2-holdouts --fill-missing`: exit status 0 (log `check_11.log`)
- `tools/explore_cover_contrasts.R duveiller /home/expert/Documents/contracting/Andria/paleo-RF-verify/7c12534/.rundirs/cover-contrasts-full /home/expert/Documents/contracting/Andria/paleo-RF/data/duveiller2018/albedo_IGBPdet.nc .rundirs/case-study-cover-contrasts/duveiller .rundirs/case-study-cover-contrasts/summaries`: exit status 0 (log `check_12.log`)
- `tools/check_cover_contrasts.R duveiller-case-studies .rundirs/case-study-cover-contrasts/duveiller /home/expert/Documents/contracting/Andria/paleo-RF-verify/fa9e465/.rundirs/duveiller-comparison/comparison/cover_contrasts_duveiller.csv`: exit status 0 (log `check_13.log`)
- `tools/check_cover_contrasts.R duveiller /home/expert/Documents/contracting/Andria/paleo-RF-verify/fa9e465/.rundirs/duveiller-comparison/comparison /home/expert/Documents/contracting/Andria/paleo-RF-verify/7c12534/.rundirs/cover-contrasts-full /home/expert/Documents/contracting/Andria/paleo-RF/data/duveiller2018/albedo_IGBPdet.nc`: exit status 0 (log `check_14.log`)

## Failures

- none
