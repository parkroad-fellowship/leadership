# Architecture Migration Plan

Aligns Leadership project with the PRF SuperApp standard architecture.

## Phase 1: DTOs — Eliminate Ad-Hoc Maps

Create `@freezed` DTOs for 9 domains currently using raw `Map<String, dynamic>`:

| Domain | Model | New DTO | Fields |
|---|---|---|---|
| Profession | `PRFProfession` | `PRFProfessionDTO` | `name`, `isActive` |
| Church | `PRFChurch` | `PRFChurchDTO` | `name`, `isActive` |
| Department | `PRFDepartment` | `PRFDepartmentDTO` | `name`, `isActive` |
| Gift | `PRFGift` | `PRFGiftDTO` | `name`, `isActive` |
| MaritalStatus | `PRFMaritalStatus` | `PRFMaritalStatusDTO` | `name`, `isActive` |
| MissionType | `PRFMissionType` | `PRFMissionTypeDTO` | `name`, `isActive` |
| ContactType | `PRFContactType` | `PRFContactTypeDTO` | `name` |
| SchoolTerm | `PRFSchoolTerm` | `PRFSchoolTermDTO` | `name`, `year`, `isActive` |
| MissionGroundSuggestion | `PRFMissionGroundSuggestion` | `PRFMissionGroundSuggestionDTO` | `name`, `contactPerson`, `contactNumber`, `notes` |

Also fix:
- Convert `PRFMissionDTO` from hand-written class to `@freezed`
- Fix `MissionService.listMissionQuestions()` / `createMissionQuestion()` to return `PRFMissionQuestion` instead of raw maps
- Update cubits to use DTOs instead of inline maps

## Phase 2: DI Refactor

Replace `Singletons` with `DIContainer` + per-feature modules.

**Infrastructure** (`lib/di/modules/`):
- `CoreModule` — router, HiveService, base services
- `FirebaseModule` — FirebaseService, FirebaseMessagingService
- `MediaModule` — MediaService

**Feature modules** (`lib/features/<feature>/di/`):
- `AuthModule` — AuthService + auth cubits
- `AccountModule` — account cubits
- `MissionsModule` — MissionService + mission cubits
- `SchoolsModule` — SchoolService + school cubits
- `EventsModule` — EventService + event cubits
- `MembersModule` — MemberService + member cubit
- `ChurchesModule` — ChurchService + church cubit
- `DepartmentsModule` — DepartmentService + department cubit
- `GiftsModule` — GiftService + gift cubit
- `ProfessionsModule` — ProfessionService + profession cubit
- `MaritalStatusesModule` — MaritalStatusService + marital status cubit
- `ExpensesModule` — expense/requisition shared cubits

## Phase 3: Feature Extraction

Promote `home/landing/*` to top-level features:

```
features/
  auth/              ← already correct
  home/              ← account + landing shell only
  missions/          ← extracted from home/landing/missions/
  schools/           ← extracted from home/landing/schools/
  events/            ← extracted from home/landing/desk_activities/
  members/           ← extracted from home/landing/members/
  churches/          ← extracted from home/landing/churches/
  departments/       ← extracted from home/landing/departments/
  gifts/             ← extracted from home/landing/gifts/
  professions/       ← extracted from home/landing/professions/
  marital_statuses/  ← extracted from home/landing/marital_statuses/
  school_terms/      ← extracted from home/landing/school_terms/ (if exists)
  mission_types/     ← extracted from home/landing/mission_types/ (if exists)
```

## Phase 4: Cubit Relocation

| Cubit | From | To |
|---|---|---|
| `ThemeCubit` | `features/home/cubit/` | `lib/shared/theme/cubit/` |
| `SelectMediaCubit` | `features/home/cubit/` | `lib/shared/media_upload/cubit/` |
| `UploadMediaCubit` | `features/home/cubit/` | `lib/shared/media_upload/cubit/` |
| `ExpenseCategoriesResourceCubit` | `features/home/cubit/` | `lib/shared/expenses/cubit/` |
| `shared_views/expenses/*` | `shared_views/expenses/` | `shared/expenses/` |
| `shared_views/requisitions/*` | `shared_views/requisitions/` | `shared/requisitions/` |

## Phase 5: Barrel File Removal

Delete `_index.dart` files and replace all imports with direct file references:
- `lib/services/_index.dart`
- `lib/utils/_index.dart`
- `lib/shared_widgets/_index.dart`

## Phase 6: Shared Code Reorganization ✅

- Renamed `lib/shared_views/` → `lib/shared/` (expenses + requisitions preserved).
- Relocated cubits: `theme_cubit` → `lib/shared/theme/cubit/`, `select_media_cubit`/`upload_media_cubit` → `lib/shared/media_upload/cubit/`, `expense_categories_resource_cubit` → `lib/shared/expenses/cubit/`.
- Removed the last barrel (`lib/utils/_index.dart`) and `lib/utils/singletons.dart` — direct imports everywhere.
- Enums are self-contained in `lib/enums/` (only `dart:`, `flutter`, `freezed_annotation`, `prf_design`, intra-enums imports allowed). `PRFHeaderActionButtonVariant` moved there.

## Phase 7: Analytics & Error Reporting ✅

- `lib/services/analytics/analytics_service.dart` — `AnalyticsService` + Firebase impl (+ NoOp for debug).
- `lib/services/errors/unified_error_reporting_service.dart` — Crashlytics wrapper wired in `bootstrap.dart` (release mode only).
- Registered in `FirebaseModule`. No PostHog anywhere.
- Services (incl. analytics/error reporting) are always injected into cubits via constructors — `getIt` is never referenced inside cubits (enforced by `arch-check`).

## Phase 8: Architecture Guardrails ✅

- `scripts/architecture_guardrails.sh` (`make arch-check`) — enforces: no barrels, no `shared_views`/flattened `home/landing` paths, no map literals in services, cubits in `cubit/` dirs, no direct FirebaseAnalytics/Crashlytics outside services/DI, self-contained enums, domain enums only in `lib/enums/`.
- `scripts/feature_import_edges.sh` (`make arch-edges`) — cross-feature import report.

## Phase 9: CI ✅

- Existing workflows kept (no IPA builds, AAB-only deploys).
- `pr-check.yaml` now also runs `make arch-check` and a codegen-drift check.

## Verification

After each phase:
```sh
make gen          # codegen
make fmt          # format + fix
flutter analyze lib  # static analysis
```
