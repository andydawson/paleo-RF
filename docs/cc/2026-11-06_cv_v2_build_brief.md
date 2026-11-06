# Brief for Astra (ultra effort): write the code for CV protocol 2

You are in a git worktree on branch `cv-v2`. **Create and edit files in this worktree only; do not commit (I do).**
No network. Never open `data/modis_albedo/requests/` anywhere; never write to any other checkout. You may run R to
check your work: `THREADS=1 OPENBLAS_NUM_THREADS=1 tools/rscript.sh ...` to parse files, run the unit tests, and
make small reads of inputs. Do **not** run the cross-validation fits themselves (they go through the verification
tool). Keep memory small; other jobs share the machine.

## What to build
Exactly what `docs/cc/2026-11-06_cv_protocol_v2.md` (fixed, approved by Chris) specifies, sections 1-9, **except**
the hindcast comparison tool of section 7 (built later, after the CV has run). That is:
- the fifteen configurations in `R/model_registry.R` (existing five ids kept, ten new two-axis ids written out, table
  order as the tie-break);
- the < 250 km selection score, feasibility on nearby cells, far cells and the deep band by direction reported
  beside, the direction column in the distance table, the two maximum-depth columns in `comparison.csv`;
- the real-data capacity comparison and the synthetic recovery test (seed rule as in the protocol), with their
  pass rules, in the smallest readable form (reuse the existing fitting function and contrast code; one small tool
  if a new one is needed);
- conditional AIC from the April-May full-data fits;
- the in-range diagnostic for the winner and model 8;
- tests for everything the protocol's verification section lists (hand-worked cases), and verification specs in
  `docs/cc/verification/` (`2026-11-06_cv2-*.R`, `commit = 'TO_FILL'`), split so the fits can run in parallel jobs
  as the first run did (see the 5 November `cv-run1` specs in
  `/home/expert/Documents/contracting/Andria/paleo-RF/docs/cc/verification/`, read-only), plus a short run order.

## Rules (Chris)
As simple, clear, readable and parsimonious as possible; no overengineering; readability before elegance; no
duplicated code (shared routines in `R/`); comments say why; plain words; never remove a `library()` call. Change
existing code only where the protocol needs it, and keep the first run reproducible (its specs and records must
still make sense). Read `AGENTS.md` and `CONTRIBUTING.md` first.

## Report (final message)
Files created or changed and why (lines before and after per code file); every choice the protocol did not make;
what you ran and the results (parse, tests); the run order and the number of jobs and fits; anything in the protocol
that did not work with the real code or data.
