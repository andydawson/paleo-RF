# Protocol 2 run order

The specifications are ready for Chris to freeze against the implementation commit. No CV,
capacity, recovery or pipeline fit was run while writing them. Replace `TO_FILL` in every
`docs/cc/verification/2026-11-06_cv2-*.R` with that same full commit SHA before launching.
Keep the approved protocol and these input records with that commit.

Run each specification through the existing queue and `tools/verify_change.R`, from the
same checkout throughout, for example:

```sh
THREADS=1 OPENBLAS_NUM_THREADS=1 tools/rscript.sh tools/verify_change.R docs/cc/verification/2026-11-06_cv2-tests.R
```

The verifier creates its own detached worktree. The common scientific run is
`.rundirs/cv2-holdouts` there; the job-specific folders hold verification logs. Use at most
six concurrent single-thread fitting processes across all CV and separation jobs. Each
job fits its configurations sequentially. Run preparation first to create the worktree
before any parallel launches; do not run two jobs with the same specification name.

| Order | Specification suffix after `2026-11-06_` | Jobs | Maximum new fits |
|---|---|---:|---:|
| 1 | `cv2-tests.R` | 1 | 0 research fits |
| 2 | `cv2-holdouts.R` | 1 | 0 |
| 3 | `cv2-fit-d1-<month>.R`, `cv2-fit-d2-<month>.R`, `cv2-fit-d3-<month>.R` | 36 | 540 |
| 3 | `cv2-capacity-apr.R`, `cv2-capacity-may.R` | 2 | 28 |
| 4 | `cv2-score.R` | 1 | 0 |
| 5 | `cv2-recovery-<apr\|may>-<darkens\|null\|shorter>.R` | 6 | 360 |
| 5 | `cv2-fit-inrange-<month>.R` | 12 | 24 |
| 6 | `cv2-summary.R` | 1 | 0 |
| 7 | `cv2-winner.R`, only when the winner differs from model 8 | 1 | 192 |
| **Total** | | **61** | **1,144** |

Orders 3's capacity jobs may run alongside the directional jobs, within the six-process
limit. Order 4 waits for every directional job, but does not depend on capacity results.
Order 5 requires a unique selected configuration. Its recovery and in-range jobs may run
alongside remaining capacity jobs. Order 6 waits for all three diagnostics. The winner's
pipeline can start any time after selection; diagnostics never change the winner.

The totals assume three feasible directions and all months. Each directional job fits
fifteen configurations; an infeasible fold is skipped according to the frozen mask.
Capacity reuses two model-8 fits. Each recovery job fits twenty datasets with at most three
distinct configurations; the datasets are generated once by preparation and shared across
configurations. In-range jobs fit at most two configurations. Retries are additional and
are recorded. Before the winner pipeline there are **60 jobs and at most 952 new fits**.
If model 8 wins, deduplication further reduces recovery and in-range fits and its pipeline
is reused. The unit suite has small fitting fixtures, counted separately from research fits.

Preparation reruns unchanged scripts 1 and 2 and requires exact equality of the calibration
and reconstructed-cover tables with the main refit. It copies that run's existing area/ice
table. The source is
`/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main`;
April and May's `output/calibration/calibration_prediction_fit_<month>_bluesky.RDS` are
the reused REML prediction fits. The separation preparation checks their settings, formulas
and response rows, and freezes their checksums and generator constants. It uses no ML ladder
fit. The previous CV memberships and cuts are read from
`/home/expert/Documents/contracting/Andria/paleo-RF-verify/f07ff68/.rundirs/cv-run1`.

Review the new feasibility, membership-change, coverage and exclusion reports before
launching fits. All version-2 CV tables live under `output/cross_validation_v2`; run 1's
tables remain in its original folder. The specified `cv2-score.R` is the first selection
pass. `cv2-summary.R` reruns that same deterministic scoring after the in-range jobs and
then summarizes capacity and recovery, including failed or incomplete results.

The winner specification reads the choice from the same commit's verification worktree,
sets only the existing `calibration$model_id` and recorded simulation seed, and runs
scripts 1–10 in order, including 7a. Script 4 repeats its complete ladder, spatial tests
and twelve prediction fits: 192 fits, including the two repeated April–May fits. No fit
is injected. If model 8 wins, skip this specification and reuse `run1-main`.

The section-7 hindcast comparison tool, its period-sum and common-denominator checks,
and the comparison figures are deferred by the implementation brief until these runs
finish. Neither the existing pipeline nor its original verification records is changed.

Implementation choices left to the runner are the final code commit and the queue's job
slots. The job split (one directional holdout/month; one capacity month; one recovery
month/truth; one in-range month) is administrative and changes no scientific settings.
The historical absolute source paths above reproduce this machine's first-run layout.
