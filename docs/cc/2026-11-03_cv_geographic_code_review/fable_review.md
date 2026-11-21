*Fable (science-reviewer role), first review of b7a5772, 3 November 2026; condensed to its findings.*

**Verdict.** Faithful to the protocol's "Geographic sensitivity" section; choice untouched; arithmetic correct on every
case worked (equal-month in-range score 0.055 against 0.0433 pooled; paired differences by band; nearest_km 78.62 km;
the in-range support table against feasibility.csv, e.g. January 1340 + 386 = 1726 rows; coefficient counts 52, 249,
551, 748). One should-fix; the rest nits and records.

**Findings.**
- should-fix: the in-range report took its models after the converged-and-inside filter, so a model with no converged
  fit vanished, and if that model was model 8 the score stage crashed.
- should-fix (decide): by_distance dropped a candidate with any failed fold, while the other tables drop failed fits only.
- nits: the band was one pasted string; `cell_months` counted cell-month-holdouts; in-range failures not listed; empty
  bands absent rather than zero; protocol lines 146-147 (cell dedup, converged-only) needed Chris's confirmation as his
  decision; an older holdouts.rds without the in-range table would fail obscurely; no changelog entry.
- verification missed: a second model missing a month, model 8 absent, a stand-in end-to-end run of the stages, a
  check that holdouts.rds's in-range table equals inrange.csv.
