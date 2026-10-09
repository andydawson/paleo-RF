#!/usr/bin/env bash
# Build an isolated run directory for a verification run.
#
# Why: the scripts write to fixed paths, so re-running one in the repo replaces the files
# later checks compare against. The scripts use relative paths, so running them from a
# directory whose data/ and output/ are trees of links to the repo's files makes them read
# the real inputs and write every output locally. Files matching an exclude pattern (the
# outputs of the scripts you will run there) are not linked, so the run writes fresh ones.
# As a backstop, run `tools/frozen.sh lock` first: writing through a link to a locked file
# fails loudly instead of overwriting it.
#
# Usage: tools/rundir.sh <name> [exclude-glob ...]
#   Globs are relative to the repo root, e.g. 'data/lct_*_reveals_interp.RDS' 'output/prediction/*'.
#   Creates .rundirs/<name>/ (gitignored). scripts/, R/ and tests/ are links to the repo.
#   Prints the directory path. Fails if it already exists.
set -euo pipefail
ROOT=$(git -C "$(dirname "$0")/.." rev-parse --show-toplevel)
NAME=${1:?usage: tools/rundir.sh <name> [exclude-glob ...]}; shift
DIR="$ROOT/.rundirs/$NAME"
[[ -e "$DIR" ]] && { echo "rundir: $DIR already exists" >&2; exit 1; }
mkdir -p "$DIR/figures" "$DIR/runs"
for d in scripts R tests; do ln -s "$ROOT/$d" "$DIR/$d"; done
linked=0; skipped=0
while IFS= read -r -d '' f; do
  rel=${f#"$ROOT/"}
  skip=0
  for g in "$@"; do
    # shellcheck disable=SC2053
    [[ "$rel" == $g ]] && { skip=1; break; }
  done
  mkdir -p "$DIR/$(dirname "$rel")"
  if (( skip )); then skipped=$((skipped+1)); else ln -s "$f" "$DIR/$rel"; linked=$((linked+1)); fi
done < <(find "$ROOT/data" "$ROOT/output" -type f -print0)
echo "rundir: $linked files linked, $skipped excluded" >&2
echo "$DIR"
