# Cross-validation folds (protocol 3): Chris's decisions after the adversarial reviews, 26 November 2026

Context: the brief, designs, reconciliations, reviews and review reconciliations are in `docs/cc/2026-11-23_cv_spatial_folds_*`
and `docs/cc/2026-11-24_cv_spatial_folds_*`. Chris answered four questions on 26 November.

1. **A check with no fits first.** Approved: score protocol 2's saved predictions on withheld cells 250 km or more
   from training with the protocol's own grouping, weights and block resampling. Put that score beside the nearby
   score, and give the area-weighted share of the past target at a fitted cell's own place. It is built as a check
   script (`tools/check_cv_far_cells.R`) run by a verification spec, before any decision on the 2,160 buffered fits.
2. **Whether the separated score chooses the model.** Left open until the check is seen. His decision of 24 November,
   that the new score chooses, is therefore not yet final.
3. **Buffer distance, if the buffered fits go ahead.** 250 km, recorded as a judgement, not an estimate. The
   correlogram (approved 24 November) is kept only as a monthly description for Andria, beside the existing table of
   error by distance; it does not set the distance.
4. **Clusters.** Seeded k-means, with a recorded seed, on coordinates converted to kilometres. The result is frozen in
   `holdouts.rds`.

Agreed by both reviewers and not put to Chris as a question: the ten-block rule applies per direction and month,
across usable splits, with any missing geography reported; the training-row rule applies per split.
