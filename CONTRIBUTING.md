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
- The code map that used to live in `docs/cc/` was archived on 2026-09-25 (git history before that date); the README's script table is now the current map and is kept up to date when scripts are added, renamed or retired.
- Andria's code and data as received are tagged `v0-legacy`. That tag is
  the store of her original pipeline outputs; recover them with
  `bash tools/restore_original_outputs.sh`. Never commit regenerated run
  outputs over the committed versions in `data/`: a run overwrites them
  in the working tree, so check `git status` before staging, and prefer
  `git add <path>` to `git add -A`.
- Frozen outputs used to prove a refactor changed nothing live in
  `tests/anchors/`; see the README there for what is anchored and why.
- Everything Claude Code generates that is not a script, a result or a data
  file with its own home (code maps, issue lists, schematics, reports,
  generators) lives under `docs/cc/`, with dated, descriptive file names
  (`YYYY-MM-DD_what_and_why.ext`); living documents carry no date. The
  repo root holds only README, CONTRIBUTING, AGENTS, .gitignore,
  `scripts/`, `data/`, `docs/` and `tools/`.
- `scripts/` is the R analysis pipeline and nothing else. Helper code that
  is not part of the pipeline (data download, diagram generators) lives in
  `tools/`.
- Questions for Andria are collected continuously in
  `docs/cc/questions_for_andria_general.md` and
  `docs/cc/questions_for_andria_scientific.md`; add to them as questions
  arise, remove them when answered.

## Decisions on record

- **2026-09-17.** The point (non-interp) flavour is not developed further;
  the interp flavour is the analysis (agreed with Andria).
- **2026-09-24.** The point flavour is removed from `chris-dev`: every
  script now holds its interp code only, lines unchanged. Preserved at
  tags `v0-legacy` and `v1-both-flavours`, branch `legacy`, and
  `origin/run-nointerp` / `origin/run-may`; documented in
  `docs/cc/README_nointerp.md`; outputs in `tests/anchors/nointerp-*`.
- **2026-09-24.** Andria reviews the method on `chris-dev` and commits her
  comments and changes there directly. While that review is open, Chris and
  agent sessions do not edit `scripts/` on `chris-dev`; work goes on topic
  branches and is rebased onto her changes before merging.
- **2026-09-23.** Branch `annotated-interp` is a teaching copy of the same
  code with a comment on every line. It is read, not merged; its code is
  kept identical to `chris-dev`'s by the comment-stripped comparison
  described in its commit messages. Chris intends to prune it into package
  documentation later.
- **2026-09-24.** `.lfsconfig` excludes `tests/anchors/**` from LFS
  fetches so that a clone downloads only the data inputs (617 MB) and stays
  inside GitHub's 1 GB/month LFS bandwidth allowance on Andria's account.
  Fetch anchors with `git lfs pull --include="tests/anchors/**"`.
- **Manifest string.** `8_radiative.R` records `cack_band_meaning = 'year
  2003'`; the file's Year dimension says 2001 = 1 (known issue 37).
