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

## Working rules

- Branch off `chris-dev` for any topic that is more than a quick fix
  (`chris-dev/<topic>` or `<topic>`); merge back into `chris-dev` when done.
- Commit each atomic (single logical) change, frequently. Use a concise
  imperative subject line and a body that explains *what* changed and *why*.
  Do not squash granular history unless asked.
- Never modify `legacy` or `main`. Merging `chris-dev` into `main` (or opening
  a PR to upstream) requires explicit approval from the repo owner.
- Push `chris-dev` (and topic branches) to a remote for backup at the end of
  each working session at minimum. **Open question (see below): which remote.**
- The original scripts are documented in `CODE_MAP.md`; keep that file current
  when scripts are added, renamed or retired.

## Open questions (to be confirmed by Chris)

1. Remote for backup: push `chris-dev` and `legacy` to `origin`
   (`andydawson/paleo-RF`, where the current GitHub account has write access),
   or to a personal fork?
2. Should `legacy` and `chris-dev` be pushed now?
3. Merge policy into `main`: PR reviewed by Andria, or direct merge after
   sign-off?
