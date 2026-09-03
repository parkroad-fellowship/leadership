#!/usr/bin/env bash
# Prints cross-feature import edges to review coupling between features.
# Run via `make arch-edges`.

set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "Cross-feature import edges (feature -> feature):"
grep -rn "import 'package:leadership/features/" "$ROOT/lib/features" 2>/dev/null \
  | awk -v root="$ROOT" -F: '
      {
        path = $1
        target = $0
        sub(/.*import .package:leadership\/features\//, "", target)
        sub(/\/.*/, "", target)
        rel = path
        sub(root "/lib/features/", "", rel)
        n = split(rel, parts, "/")
        src = parts[1]
        if (src != target) print "  " src " -> " target "  (" $2 ")"
      }' \
  | sort | uniq -c | sort -rn
