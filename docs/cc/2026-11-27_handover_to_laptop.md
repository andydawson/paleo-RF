# Handover: moving the work from the workstation to Chris's laptop (27 November 2026)

The workstation keeps freezing: it hard-froze again at 14:58 on 27 November and was power-cycled. Chris is moving the
work to his laptop. This note says where things stand, what comes next, how to set up a fresh machine, and what has
to be copied by hand because it is not in git. File contents are never given here, only paths.

## State at handover

- **Everything in git is pushed.** All eight local branches match GitHub: `chris-dev` (the trunk),
  `cv-spatial-folds`, `feature/single-config`, `i16b-calibration`, `annotated-interp`, `northeast-forest-check`,
  `legacy` and `main`. No job was running. No text file was damaged by the freeze: the only NUL bytes found are
  inside binary files (shapefiles, one .docx), which is normal for those files.
- **The trunk is `chris-dev`.** It holds the finished single-config migration (merged 21 November), the
  Holocene animation tool (24 November), and the records of the dropped northeast check and of the refit runs.
- **This branch also brings in 128 verification specs and reports** (early November cross-validation and refit
  runs). They were on the workstation's main checkout and had never been committed.

## Work in progress: the cross-validation folds (branch `cv-spatial-folds`)

The aim is one cross-validation method that handles spatial autocorrelation together with unseen land cover. Chris
asked for this on 15 November. Records are `docs/cc/2026-11-2[3-6]_cv_*` on that branch, in this order:
1. the brief;
2. Fable's and Astra's designs and their reconciliation;
3. Chris's choices of 24 November;
4. the adversarial reviews and their reconciliation;
5. Chris's decisions of 26 November (`docs/cc/2026-11-26_cv_spatial_folds_decisions.md`).

**Done.** `tools/check_cv_far_cells.R` (commit 79de462) scores protocol 2's saved predictions on cells 250 km or
more from training, with no fits. Fable and Astra reviewed it and reconciled their reviews:
- `docs/cc/2026-11-26_cv_far_cells_check_review_*`
- `docs/cc/2026-11-26_cv_far_cells_check_reconciliation_*`

Its first, unverified results:
- It chooses the same model as protocol 2 (`loc100_linear`).
- The lead is thin: the nearest simpler model is 1.33 standard errors behind on far cells, against 4.3 or more on
  nearby cells.
- The lead rests on few cells, mostly in Alaska.
- 93.9% of the past outside-range target lies at a place where the model was fitted.

**Next, waiting for Chris's answers.**
1. Approve the script changes both reviewers agree on, then the verification spec (about 45 lines). The changes:
   - delete the unapproved target guard;
   - delete about 13 more lines that Fable alone recommends.
2. Decide whether the separated score chooses the model:
   - the nearby score chooses and the separated score is reported beside it;
   - a choice is declared only if both agree;
   - the separated score chooses.
3. Decide whether the buffered fits (up to 2,160) are still wanted, and whether they report or choose.
4. Optional: a share of the margin by month (+1 line).

The far check needs protocol 2's run folder (see "Results folders" below).

## Other open items

- Before Chris meets Andria: talk through the location terms in the models (how `s(x, y, bs = "gp", k)` is built,
  what k does, why it can absorb the cover effect). The far-cell results bear on this.
- After Andria answers: the glacier albedo sensitivity cases (0.50 and 0.80). Issue #29 holds the ice decisions.
- Chris's own list:
  - email Andria with the Word document;
  - share the ice slides and the albedo-split explainer.
- For Andria, still to be entered in the questions file: which claim the choice of model should support
  (prediction at new places, or the right change of albedo when cover changes at a known place); and whether the
  location term stands for climate, chiefly snow.

## Setting up the laptop

1. Clone `andydawson/paleo-RF` and check out `chris-dev`. Large inputs come through Git LFS (README, "Large files").
   `.lfsconfig` skips `tests/anchors/**`, so fetch those explicitly if a run must be compared with the anchors.
2. Build the R environment as in README.md, section "Environment" (micromamba, env `paleo-rf`, conda-forge packages,
   then the few CRAN packages listed there).
3. Install the merge hook once per clone: `Rscript tools/check_merge_evidence.R install` (CONTRIBUTING.md).
4. `tools/rscript.sh` (core pinning) is optional and Linux-only; plain `Rscript` works on any OS.
5. The animation tool's GIF step needs Python 3 with Pillow (`tools/make_holocene_gif.py`).
6. `tools/verify_change.R` makes worktrees at `../paleo-RF-verify/<sha>` and links the frozen inputs from the main
   checkout. Those inputs must be present there first (next section).

## What must be copied by hand (not in git)

Copy from the workstation's main checkout,
`/home/expert/Documents/contracting/Andria/paleo-RF/`, keeping the same relative paths.

**Frozen pipeline inputs: 261 files, 7.4 GB.**
- `tests/frozen_inputs.md5` lists every frozen input. These 261 are git-ignored:
  - under `output/calibration/` (194 files) and `output/prediction/` (38);
  - `output/forcing/RF_holocene_all_cases.RDS`;
  - 28 files at the top of `data/`: the `calibration_*`, `lct_*`, `paleo_predict_*` and `ice_fort*` RDS files,
    `ALB_diffs_bluesky.RDS`, `alb_interp_preds_diffs_bluesky.RDS` and `CACKv1.0.zip`.
- After copying, run `md5sum -c tests/frozen_inputs.md5` from the repository root; every line must say OK.

**Data folders not in git**, needed by the tools named:

| Path | Size | Used for |
|---|---:|---|
| `data/nadi1/` | 125 MB | NADI-1 ice source files and provenance |
| `data/duveiller2018/` | 401 MB | Duveiller et al. comparison |
| `data/mcd12q1/` | 286 MB | MODIS land cover |
| `data/mod44w/` (with `2015/`) | 48 MB | MODIS water mask |
| `data/gmted2010/` | 696 MB | elevation |
| `data/era5/` | 12 GB | ERA5 snow and climate |
| `data/modis_albedo/` | 236 GB | the MODIS albedo rebuild source; only needed to rebuild the albedo table, so it can stay on the workstation or an external disk |

**Results folders of past runs**, under `/home/expert/Documents/contracting/Andria/paleo-RF-verify/`:
- 64 folders hold results. The ones current work reads are:
  - `1d31cfc/.rundirs/` (7.1 GB): protocol 2's holdouts, fits and the chosen model's pipeline, read by the far
    check;
  - `d5d5df5/.rundirs/run1-main` (part of 7.7 GB): the main run of 1 November, read by the animation tool.
- The others are records of finished runs. Their reports are in git, so copy them only if a result needs re-reading.

**Not in the repository, and not to be copied into it.** Chris must set these up himself; paths only:
- Earthdata login: `~/.netrc`. Copernicus CDS key: `~/.cdsapirc`.
- GitHub access: his SSH key, and the `gh` login.
- Codex (Astra): its login is in `~/.codex/`. Sign in again on the laptop rather than copying it. The bubblewrap and
  AppArmor fix applies only to Ubuntu.
- Claude Code settings and memory:
  - his global instructions, `~/.claude/CLAUDE.md`;
  - this project's memory folder under `~/.claude/projects/` (the folder named after the project path);
  - the project's `.claude/` folder (agents and skills; untracked, 144 KB; review copies of the roles are in
    `docs/cc/roles_draft/`).
- Zotero library and its local helpers, if literature work continues there.

## How the work is run (unchanged)

The rules are in `CONTRIBUTING.md` and `AGENTS.md`. In short:
- `chris-dev` is the trunk, with one topic branch per task.
- Every code change is verified with `tools/verify_change.R` before merging.
- Code merges need Chris's approval; documentation-only branches merge without asking.
- Never commit to `legacy` or `main`.
- Fable and Astra design and review; Opus agents implement.
