#!/usr/bin/env bash
# Extract Andria's committed pipeline outputs from the v0-legacy tag.
# They are all non-interp (March). Running the pipeline overwrites these
# files in data/; the tag cannot be overwritten, so this is the recovery
# route. Run from the repository root:
#   bash tools/restore_original_outputs.sh [destination]   (default: ./original_outputs)
set -euo pipefail

TAG=v0-legacy
DEST="${1:-original_outputs}"
FILES=(
  calibration_modern_lct_bluesky.RDS
  calibration_mod1_bluesky.RDS calibration_mod2_bluesky.RDS calibration_mod3_bluesky.RDS
  calibration_mod4_bluesky.RDS calibration_mod5_bluesky.RDS calibration_mod6_bluesky.RDS
  calibration_mod7_bluesky.RDS
  paleo_predict_gam_bluesky.RDS paleo_predict_gam_summary_bluesky.RDS
  preds_alb_diffs_sub_bluesky.RDS
)

git rev-parse -q --verify "refs/tags/$TAG" >/dev/null || { echo "tag $TAG not found"; exit 1; }
mkdir -p "$DEST"
for f in "${FILES[@]}"; do
  git show "$TAG:data/$f" > "$DEST/$f"
  printf '  %-42s %s\n' "$f" "$(du -h "$DEST/$f" | cut -f1)"
done
echo "Andria's original outputs restored to $DEST/ (from tag $TAG)"
echo "To inspect one without extracting:  git show $TAG:data/<file> | ..."
