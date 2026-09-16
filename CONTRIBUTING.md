# Contributing / version-control protocol

Recorded 2026-09-16. This file is the source of truth for how work in this
repository is branched, committed, merged and backed up. Agent sessions read
`AGENTS.md`, which points here.

## Branches

| Branch      | Role                                                                 |
|-------------|----------------------------------------------------------------------|
| `main`      | Upstream line from `andydawson/paleo-RF`. Not committed to directly. |
| `legacy`    | Frozen snapshot of the code as received (commit `c9d525e`, 2026-09-13). **Never commit to or rebase this branch.** |
| `chris-dev` | Development trunk for Chris McWilliams' work. All new work goes here. |

## Working rules (confirmed by Chris, 2026-09-16)

- Trunk: `chris-dev`. Topic branches off `chris-dev`, one per logical task
  (e.g. `fix-missing-dirs`, `replace-rgeos`); merge into `chris-dev` when the
  task is finished.
- Commit each atomic (single logical) change, frequently. Concise imperative
  subject line plus a body explaining *what* changed and *why*. Do not squash
  granular history unless asked.
- Never commit to `legacy` or `main`. Work reaches `main` only via a pull
  request on GitHub reviewed and approved by Andria; agent sessions never
  merge to `main` themselves.
- Remote: `origin` (`andydawson/paleo-RF`). Push `chris-dev`, `legacy` and
  any open topic branches at natural checkpoints and before ending each
  session, without asking each time.
- Keep `CODE_MAP.md` current when scripts are added, renamed or retired.
