#!/usr/bin/env bash
# Compare the pipeline's live outputs with an anchor's MD5SUMS.txt, byte for byte.
#
# Why: anchors are keyed by file name, but the pipeline writes to data/ and output/
# subdirectories. tests/anchors/live_paths.tsv maps each anchor file name to where the
# pipeline writes it, so one checker serves every anchor and every run directory.
#
# Usage: tools/check_anchors.sh <anchor-dir> [root]
#   root defaults to the repo root; pass a run directory (tools/rundir.sh) to check a
#   verification run. Only files that exist under root are compared; files absent there
#   are reported as "not produced", and in a run directory files that are links to the
#   repo's copies are reported as "linked input". Exit status 1 if any compared file differs.
set -euo pipefail
ROOT=$(git -C "$(dirname "$0")/.." rev-parse --show-toplevel)
ANCHOR=${1:?usage: tools/check_anchors.sh <anchor-dir> [root]}
RUNROOT=${2:-$ROOT}
MAP="$ROOT/tests/anchors/live_paths.tsv"
status=0
while read -r sum path; do
  name=$(basename "$path")
  live=$(awk -F'\t' -v n="$name" '$1==n {print $2}' "$MAP")
  [[ -z "$live" ]] && { printf '%-48s %s\n' "$name" "NO MAPPING in live_paths.tsv"; status=1; continue; }
  if [[ ! -e "$RUNROOT/$live" ]]; then printf '%-48s %s\n' "$name" "not produced"; continue; fi
  # In a run directory, inputs are links to the repo's files: reporting them as MATCH
  # would claim a reproduction that did not happen.
  if [[ "$RUNROOT" != "$ROOT" && -L "$RUNROOT/$live" ]]; then printf '%-48s %s\n' "$name" "linked input, not produced here"; continue; fi
  got=$(md5sum < "$RUNROOT/$live" | cut -d' ' -f1)
  if [[ "$got" == "$sum" ]]; then printf '%-48s %s\n' "$name" "MATCH"
  else printf '%-48s %s\n' "$name" "DIFFER (anchor ${sum:0:8}, got ${got:0:8})"; status=1; fi
done < "$ANCHOR/MD5SUMS.txt"
exit $status
