#!/usr/bin/env bash
# Architecture guardrails for the Leadership app.
# Fails (exit 1) if any rule is violated. Run via `make arch-check`.

set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0

err() {
  printf '%b\n' "❌ $1" >&2
  fail=1
}

echo "Running architecture guardrails..."

# 1. No barrel imports (_index.dart)
hits=$(grep -rln "_index\.dart" "$ROOT/lib" "$ROOT/test" 2>/dev/null)
[ -n "$hits" ] && err "Barrel imports found (_index.dart):\n$hits"

# 2. No references to the old shared_views directory
hits=$(grep -rln "shared_views" "$ROOT/lib" "$ROOT/test" 2>/dev/null)
[ -n "$hits" ] && err "References to removed lib/shared_views/:\n$hits"

# 3. No old flattened feature paths under home/landing (the landing shell
#    itself still lives at lib/features/home/landing — only its root files,
#    models/ and widgets/ are allowed there).
hits=$(grep -rn "features/home/landing/" "$ROOT/lib" 2>/dev/null \
  | grep -v "landing/landing.dart" \
  | grep -v "landing/_handset.dart" \
  | grep -v "landing/_tablet.dart" \
  | grep -v "landing/models/" \
  | grep -v "landing/widgets/")
[ -n "$hits" ] && err "References to flattened home/landing feature paths:
$hits"

# 4. No raw Map<String, dynamic> in services (DTOs everywhere)
hits=$(grep -rn "Map<String, dynamic>{" "$ROOT/lib/services" 2>/dev/null)
[ -n "$hits" ] && err "Raw maps in services layer (use DTOs):\n$hits"

# 5. Cubits live in their owning feature's cubit/ directory (or lib/shared)
hits=$(find "$ROOT/lib/features" -name '*_cubit.dart' -not -path '*/cubit/*' 2>/dev/null)
[ -n "$hits" ] && err "Cubits outside a cubit/ directory:\n$hits"

# 5b. Cubits use constructor injection — no service-locator access inside cubits
hits=$(grep -rln "getIt" "$ROOT/lib/features" "$ROOT/lib/shared" 2>/dev/null \
  | grep "_cubit\.dart$" | grep -v "freezed")
[ -n "$hits" ] && err "getIt used inside cubits (use constructor injection):\n$hits"

# 5c. List state is only ever emitted by the base CRUD cubits — feature cubits
#     must persist to Hive and let the DB stream emit listLoaded.
hits=$(grep -rn "ResourceState[^ ]*\.listLoaded(" "$ROOT/lib/features" "$ROOT/lib/shared" 2>/dev/null \
  | grep -v "freezed")
[ -n "$hits" ] && err "Manual listLoaded emissions outside base CRUD cubits (persist to Hive and let the DB stream emit):\n$hits"

# 6. Firebase analytics/crashlytics used directly outside the service layer
hits=$(grep -rln "FirebaseAnalytics\|FirebaseCrashlytics" "$ROOT/lib" \
  | grep -v "lib/services/analytics/" \
  | grep -v "lib/services/errors/" \
  | grep -v "lib/services/firebase_service.dart" \
  | grep -v "lib/di/modules/")
[ -n "$hits" ] && err "Direct FirebaseAnalytics/Crashlytics usage outside services:\n$hits"

# 7. Enums are self-contained: only dart:, flutter, freezed_annotation,
#    prf_design and intra-enums imports allowed.
bad_imports=$(grep -rh "^import" "$ROOT/lib/enums" 2>/dev/null \
  | grep -v "dart:" \
  | grep -v "package:flutter/" \
  | grep -v "package:freezed_annotation/" \
  | grep -v "package:prf_design/" \
  | grep -v "package:leadership/enums/")
[ -n "$bad_imports" ] && err "lib/enums is not self-contained. Offending imports:\n$bad_imports"

# 8. Domain (PRF*) enums are declared only in lib/enums
hits=$(grep -rln "^enum PRF" "$ROOT/lib" 2>/dev/null | grep -v "$ROOT/lib/enums/")
[ -n "$hits" ] && err "Domain enums declared outside lib/enums:\n$hits"

if [ "$fail" -eq 0 ]; then
  echo "✅ All architecture guardrails passed."
fi
exit "$fail"
