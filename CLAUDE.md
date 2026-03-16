# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter mobile app ("PRF Leadership") for Park Road Fellowship church leadership. Part of a larger "SuperApp" mono-repo. Built with the Very Good CLI scaffold. Targets iOS, Android, Web, and macOS.

## Build & Run Commands

```bash
# Install dependencies
flutter pub get

# Run code generation (freezed, json_serializable, auto_route, build_version)
make gen                # or: dart run build_runner build --delete-conflicting-outputs

# Run by flavor
flutter run --flavor development --target lib/main_development.dart
flutter run --flavor staging --target lib/main_staging.dart
flutter run --flavor production --target lib/main_production.dart

# Format & fix
make fmt                # dart fix --apply && dart format lib test

# Generate localization strings
make l10n               # flutter gen-l10n

# Run tests
very_good test --coverage --test-randomize-ordering-seed random

# iOS pods
make pods               # cd ios && pod install --repo-update --verbose

# Full clean rebuild
make clean              # flutter clean && flutter pub get && make pods

# Production builds
make aab                # Android App Bundle
make ipa                # iOS
make web                # Web
```

## Architecture

### Flavor-based Configuration
Each flavor (development/staging/production) has its own `main_<flavor>.dart` entry point that instantiates `PRFLeadershipConfig` with environment-specific values (API URLs, socket config, Azure connection strings). There is also a `main_local.dart` for local development.

### State Management: BLoC/Cubit with Freezed
- State management uses **flutter_bloc** with Cubits (not full Blocs)
- Every cubit has a paired freezed state file: `*_cubit.dart` + `*_state.dart` + `*_cubit.freezed.dart`
- All cubits are registered globally in `lib/utils/singletons.dart` via `Singletons.registerCubits()` and provided at the root `MultiBlocProvider`
- Cubit dependencies are injected via constructor from `GetIt` singletons

### Dependency Injection
- Uses **get_it** (`getIt` global instance in `lib/utils/singletons.dart`)
- Services registered as singletons in `Singletons.setup()`
- Cubits registered as BlocProviders in `Singletons.registerCubits()`
- Hive databases initialized in `Singletons.setupDatabases()`

### Routing
- **auto_route** with `PRFLeadershipRouter` in `lib/utils/router/router.dart`
- Route file is code-generated: `router.gr.dart` — run `make gen` after adding `@RoutePage()` pages
- Auth-guarded routes use `AuthGuard`
- `DecisionPage` (`/`) is the entry point that redirects to sign-in or landing based on stored auth state

### API Layer
- HTTP client: **Dio** singleton (`lib/utils/http/network.dart`) with auth token injection, request signing, and retry interceptor
- `BaseAPIService<T>` generic base class (`lib/services/api/_base_api_service.dart`) provides CRUD operations; subclasses define `endpoint`, `createFromJson`, and `createListFromResponse`
- API uses versioned paths (`/api/v1/...`) with query-parameter-based filtering (`filter[key]=value`) and includes (`include=relation1,relation2`)

### Data Models
- Remote models use **freezed** + **json_serializable** — every model has `.dart`, `.freezed.dart`, and `.g.dart` files in `lib/models/remote/`
- Local Hive models in `lib/models/local/`
- `build.yaml` sets `explicit_to_json: true` for json_serializable

### Local Storage
- **Hive CE** (Community Edition) for local persistence
- `HiveService` with sub-services: `auth_hive_service`, `data_hive_service`, `settings_hive_service`

### Adaptive UI Pattern
Widgets use `flutter_adaptive_ui`'s `AdaptiveBuilder` with `_handset.dart` and `_tablet.dart` variants. The parent widget (e.g., `primary.dart`) delegates to the correct layout. Feature pages follow the same pattern.

### Design System
Uses `prf_design` package (local path dependency at `../../prf_design_system`). Theme defined in `lib/utils/theme/`.

### Shared Code
- `lib/shared_widgets/` — reusable UI components (buttons, inputs, navbar, progress indicators)
- `lib/shared_views/` — reusable feature views (expenses, requisitions) with their own cubits

### Services
- Firebase: auth, crashlytics, analytics, messaging, remote config
- Real-time: Pusher Channels via `dart_pusher_channels` (`lib/services/socket_service.dart`)
- Media: Azure Blob Storage uploads (`lib/utils/azure_blob_storage.dart`)
- Notifications: `awesome_notifications`

## Lint Rules

Uses `very_good_analysis` (v10). Key overrides in `analysis_options.yaml`:
- `public_member_api_docs: false`
- Excludes generated files (`*.g.dart`, `*.freezed.dart`)

## Code Generation

After modifying any of these, run `make gen`:
- Freezed models (`@freezed`)
- JSON serializable models (`@JsonSerializable`)
- Auto Route pages (`@RoutePage()`)
- Build version (`lib/versioning/build_version.dart`)

## Localization

Single locale (English). ARB files in `lib/l10n/arb/`. Generated output in `lib/l10n/gen/`. Access via `context.l10n` (extension from `lib/l10n/l10n.dart`).
