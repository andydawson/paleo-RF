# Regression anchors

Frozen outputs that any refactor must still reproduce. The point of an
anchor is to prove that a change to the code did not change the science;
`tools/` and the staged plan
(`docs/cc/2026-09-18_staged_plan_development_to_package.md` (archived 2026-09-25; in git history)) call for a
check against these before and after each cleanup step.

## What exists, and what does not

| Flavour | Anchor | Where |
|---|---|---|
| non-interp, March | Andria's own outputs, as received | tag `v0-legacy`; extract with `bash tools/restore_original_outputs.sh` |
| non-interp, March | our re-run of 2026-09-16, which reproduces Andria's | `nointerp-mar-2026-09-16/` |
| non-interp, May | our run of 2026-09-17; no counterpart from Andria | `nointerp-may-2026-09-17/` |
| **interp, all months** | **none yet** | must be created by the first interp run |

There are no interp anchors because there are no interp outputs anywhere
in the repository or its history: the interp code path has been the live
one since February 2024 but was never run here, and Andria committed only
non-interp results. Creating the interp anchor is the first substantive
step of the plan, and until it exists there is nothing to regress the
interp flavour against.

## Why Andria's outputs are not copied into this directory

They are already immutable at the `v0-legacy` tag, which git cannot lose
or overwrite. Copying them here would double about 70 MB for no extra
safety. The risk they face is different: a run overwrites them *in the
working tree*, and a careless `git add -A` would then commit the
regenerated versions over them. The tag defends against that, and
`tools/restore_original_outputs.sh` brings them back.

## What is anchored, and what is not

Each directory holds the pipeline's *data frames*, not its fitted model
objects:

| File | Content | Reproducible exactly? |
|---|---|---|
| `calibration_modern_lct_bluesky.RDS` | 505 cells x 12 months of extracted albedo plus cover | yes, deterministic |
| `paleo_predict_gam_*.RDS` | point predictions per cell and slice | yes, deterministic given the fitted model |
| `paleo_predict_gam_summary_*.RDS` | mean, sd and quantiles over 100 draws | **no**: the draws are unseeded, so compare with a tolerance until a seed is added |
| `alb_preds_diffs_*.RDS` | albedo change between consecutive slices | inherits the summary's tolerance |

The fitted `bam` objects (9 to 12 MB each) are deliberately excluded. Two
reasons: they carry their `call` and enclosing environment, so
`all.equal` reports differences after any refactor even when the fit is
numerically identical; and what matters scientifically is the
predictions, which are anchored. Andria's `mod1`-`mod7` remain available
at the tag if a fit itself ever needs comparing.

## Provenance of the runs

Both runs used the scripts on `chris-dev` with the `# [run-nointerp]` and
`# [run-may]` changes, on the committed data, in the `paleo-rf`
micromamba environment: R 4.5.3, mgcv 1.9.4, terra 1.9.50, raster 3.6.32,
sp 2.2.3, dplyr 1.2.1, gratia 0.11.2, ggplot2 4.0.3.

- `nointerp-mar-2026-09-16`: March. Reproduces Andria's committed
  calibration table exactly and her predictions to a correlation of
  0.999 (mean absolute difference 0.007 in albedo), the residual being
  the unseeded draws.
- `nointerp-may-2026-09-17`: May, same code, `CAL_MONTH=may`. Model fit
  adjusted R² 0.899, model-versus-data correlation 0.958.

Note for whoever uses these: the May AIC table rises with model
complexity, which cannot happen for correctly fitted nested models. That
is an open question with Andria (B4 in
`docs/cc/questions_for_andria_scientific.md`), not a property to
reproduce.

- `interp-tail-2026-09-21`: the first complete run of the tail of the
  interp pipeline, scripts 7, 7a and 8, and the first time the pipeline
  has produced a radiative-forcing table at all. Made possible by the
  three inputs Chris supplied on 20 and 21 September (the Dalton ice
  raster, the monthly glacier albedo table and the CACK kernel), which
  were the last missing pieces. Six files with `MD5SUMS.txt`, 187 MB;
  `RF_holocene_all_cases.RDS` is in LFS.

  Provenance: `runs/2026-09-21_1412_7_plot_preds.md` (62 min) and
  `runs/2026-09-21_1504_8_radiative.md`. Both ran on commit 84e89f6 and
  735d212 respectively, with a clean working tree.

  Two bugs in the original code had to be fixed to get here, both
  latent because this half of the pipeline had never been run: script 7
  never defined `months`, so it silently picked up `base::months` and
  died in `factor()`; 7a called `ggplot()` without loading ggplot2 and
  died immediately after writing its output.

  What to check when re-running: the six md5s in `MD5SUMS.txt`. The
  loops in 7 and 7a are deterministic, so these should reproduce exactly
  unless the method changes. **This has been demonstrated, not assumed**:
  7a was run a second time on 2026-09-21 (51.7 min, manifest
  `runs/2026-09-21_1514_7a_alb_diff_full.md`) and reproduced
  `ALB_diffs_bluesky.RDS` byte for byte, md5 8039899288aaf84877b904c51e941448. This is the anchor that protects the Stage 4
  consolidation of the two per-cell difference loops.

  Note for whoever uses these: the three kernels do **not** agree. CACK
  gives 0.53 to 0.60 of the HadGEM3 forcing across the early-Holocene
  slice-pairs, because it is the only all-sky kernel of the three.
  Reproduce the numbers, but do not treat the kernel spread as settled;
  it is C3 and C4 in `docs/cc/questions_for_andria_scientific.md`.
