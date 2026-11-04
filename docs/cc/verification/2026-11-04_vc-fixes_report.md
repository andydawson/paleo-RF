# Verification vc-fixes: PASS

- verdict: **PASS**
- commit: c7d6b6c5eb18fcee20326c8f5d140fd22b8e7c48
- spec: `docs/cc/verification/2026-11-04_vc-fixes.R`
- started 2026-11-04 16:39:38 UTC, finished 2026-11-04 16:40:32 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/c7d6b6c` at c7d6b6c5eb18fcee20326c8f5d140fd22b8e7c48; 261 frozen inputs linked from the main checkout
- run folder `.rundirs/vc-fixes`; configuration `.rundirs/vc-fixes/config_used.R` (from `config.R`); 0 files copied in
- runner `tools/rscript.sh` with THREADS=1

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261104T163954.433Z_3960427.md`, 2 outputs

## Anchors


## Checks

- `tests/test_check_merge_evidence.R`: exit status 0
- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `-e for (n in c('env-drivers-script2', 'env-drivers-script8', 'i15c-script1-before', 'i15c-script2-before', 'i15c-script3-before', 'i15c-script5-before', 'i15c-scripts7-before', 'i15c-script8-before', 'i15c-script9-before', 'i16b-legacy-seed1', 'i16b-merged-legacy-seed1')) { f = sprintf('docs/cc/verification/2026-10-15_%s.R', n); s = eval(parse(f)); r = readLines(sub('[.]R$', '_report.md', f)); stopifnot(identical(paste('- commit:', s$commit), grep('^- commit: ', r, value = TRUE)[1])) }; cat('pinned specs match their reports\n')`: exit status 0

## Failures

- none
