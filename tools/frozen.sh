#!/usr/bin/env bash
# Protect and verify the frozen inputs the single-config migration verifies against.
#
# Why: issues I02 to I13b re-run scripts 5 to 9 from the calibration fits, predictions and
# intermediates on disk instead of refitting (27 h). Those files must not change while the
# migration is in progress. `lock` makes every file under data/ and output/ read-only, so
# a script that tries to overwrite one fails with "Permission denied" instead of silently
# replacing it; `verify` checks them against the recorded inventory.
#
# Usage: tools/frozen.sh lock | unlock | verify | record
#   record  writes tests/frozen_inputs.md5 (md5 of every file under data/ and output/)
set -euo pipefail
ROOT=$(git -C "$(dirname "$0")/.." rev-parse --show-toplevel)
cd "$ROOT"
INV=tests/frozen_inputs.md5
case "${1:-}" in
  lock)   find data output -type f -exec chmod a-w {} +; echo "frozen: data/ and output/ files read-only" ;;
  unlock) find data output -type f -exec chmod u+w {} +; echo "frozen: data/ and output/ files writable" ;;
  record) find data output -type f -print0 | sort -z | xargs -0 md5sum > "$INV"; echo "frozen: $(wc -l < "$INV") files recorded in $INV" ;;
  verify) md5sum --quiet -c "$INV" && echo "frozen: all $(wc -l < "$INV") files match $INV" ;;
  *) echo "usage: tools/frozen.sh lock|unlock|verify|record" >&2; exit 2 ;;
esac
