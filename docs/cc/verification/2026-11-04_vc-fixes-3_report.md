# Verification vc-fixes-3: PASS

- verdict: **PASS**
- commit: ff31fcb5a468e60467c97ba4d77c8831c5d3e625
- spec: `docs/cc/verification/2026-11-04_vc-fixes-3.R`
- started 2026-11-04 17:21:32 UTC, finished 2026-11-04 17:22:23 UTC
- worktree `/home/expert/Documents/contracting/Andria/paleo-RF-verify/ff31fcb` at ff31fcb5a468e60467c97ba4d77c8831c5d3e625; 0 frozen inputs linked from the main checkout
- run folder `.rundirs/vc-fixes-3`; configuration `.rundirs/vc-fixes-3/config_used.R` (from `config.R`); 0 files copied in
- runner `tools/rscript.sh` with THREADS=1

## Scripts

- scripts/1_veg_lct_prep.R: exit status 0, 0.4 min, run record `20261104T172144.976Z_3980835.md`, 2 outputs

## Anchors


## Checks

- `tests/test_check_merge_evidence.R`: exit status 0
- `tests/test_config.R`: exit status 0
- `tests/test_paths.R`: exit status 0
- `-e for (n in c('env-drivers-script2', 'env-drivers-script8', 'i15c-script1-before', 'i15c-script2-before', 'i15c-script3-before', 'i15c-script5-before', 'i15c-scripts7-before', 'i15c-script8-before', 'i15c-script9-before', 'i16b-legacy-seed1', 'i16b-merged-legacy-seed1')) { f = sprintf('docs/cc/verification/2026-10-15_%s.R', n); s = eval(parse(f)); r = readLines(sub('[.]R$', '_report.md', f)); stopifnot(identical(paste('- commit:', s$commit), grep('^- commit: ', r, value = TRUE)[1])) }; cat('pinned specs match their reports\n')`: exit status 0
- `-e for (f in list.files('docs/cc/verification', '[.]R$', full.names = TRUE)) { l = grep("commit *= *'", readLines(f), value = TRUE)[1]; v = if (is.na(l)) NA else strsplit(regmatches(l, regexpr("commit *= *'[^']*'", l)), "'")[[1]][2]; r = sub('[.]R$', '_report.md', f); if (is.na(v) || !file.exists(r)) next; tested = sub('^- commit: ', '', grep('^- commit: ', readLines(r), value = TRUE)[1]); if (!startsWith(tested, v)) stop(f, ' names ', v, ' but its report tested ', tested) }; cat('every spec with a report names the commit it tested\n')`: exit status 0

## Failures

- none
