# Lean Data Loading (PRF Leadership) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Cut the Leadership app's API traffic to what each screen actually needs: one request where it now makes dozens, nothing where the cache is already fresh, and smaller payloads per request.

**Architecture:** Fix the shared data layer first, then the screens. `ResourceCubit` gains a freshness gate (`FetchLedger`), bigger pages, and opt-in page crawling with an explicit `loadNextPage()`. The Dio layer stops retrying writes and shares identical in-flight GETs. Screens then stop eager-loading every tab, page history lists on scroll, request lean `include` sets, and drop reloads that Hive already makes unnecessary. A companion backend plan (`API/prf/docs/superpowers/plans/2026-10-14-accounting-event-sums.md`) removes the per-row SUM queries that make each request slow.

**Tech Stack:** Flutter ≥3.38.5, Dart ≥3.12.2, flutter_bloc/bloc, Dio, Hive CE, auto_route, freezed.

**Spec:** This document's **Evidence** section (read-only investigation, 2026-10-14).

## Evidence (why each task exists)

Paths are relative to `lib/`.

| # | Finding | Location |
|---|---|---|
| E1 | `loadAll` always refetches, then **crawls every remaining page** sequentially at 15 rows a page. There is no freshness check; 62 call sites. | `utils/crud/resource_cubit.dart:80, 156-167, 194-241` |
| E2 | Every screen calls `loadAll()` in `initState`, so revisiting a screen re-downloads the whole collection even though cubits are app-global and Hive holds the data. | e.g. `features/members/_handset.dart:39`, `features/schools/_handset.dart:38` |
| E3 | Requisition approvals creates 3 cubits and loads **all three tabs** on open, including the full closed history. | `features/requisition_approvals/_handset.dart:40-56` |
| E4 | Tab listeners have no `indexIsChanging` guard, so one tap loads twice. | `features/missions/_handset.dart:57`, `features/events/_handset.dart:56`, `features/requisition_approvals/_handset.dart:58` |
| E5 | Mission lists include `school.schoolContacts.contactType`, `weatherForecasts`, `accountingEvent`, and `missionType` twice. | `features/missions/cubit/mission_resource_cubit.dart:21-29`, `mission_detail_cubit.dart:18-26` |
| E6 | Expenses embed the parent accounting event **with all its refunds on every row**, only so the screen can read `entries.first.accountingEvent`. | `shared/expenses/cubit/allocation_entry_resource_cubit.dart:238-246`, `shared/expenses/_handset.dart:199-201` |
| E7 | Mission details eagerly loads 6 sub-lists plus class groups before any tab is opened. | `features/missions/mission_details/_handset.dart:89-146` |
| E8 | Reloads after a sheet closes, even on cancel, although `create`/`update`/`delete` already write to Hive. | `features/missions/_handset.dart:650`, `members/_handset.dart:314`, `schools/_handset.dart:345`, `shared/expenses/_handset.dart:1350,1370`, `shared/requisitions/_handset.dart:156`, `requisition_details/_handset.dart:1711` |
| E9 | `RetryInterceptor` retries **every method** (POST/PUT/DELETE included) 3× on timeouts and 5xx. | `utils/http/retry_interceptor.dart:52-58` |
| E10 | `POST auth/update-profile` with the FCM token on every cold start. | `bootstrap.dart:90-97` |
| E11 | School detail refetches contacts that came with the school list; member detail reloads the whole member list to show one member. | `features/schools/school_detail/_handset.dart:33`, `features/members/member_detail/_handset.dart:37-38` |
| E12 | Bugs: mission "Refresh" calls `loadOne` without `refresh: true` (never refreshes); `MemberResourceCubit.loadCachedList` ignores filters (the approver picker shows all members). | `features/missions/mission_details/_handset.dart:711`, `features/members/cubit/member_resource_cubit.dart` |

Estimated today: **~45–50 requests** for "cold start → missions → one mission → all tabs → past/schools tabs", **~26** to approve one requisition (about 5 needed).

## Global Constraints

- **No automated tests in this app.** Each task ends with a manual on-device check using the debug request counter from Task 0.
- Leadership is **handset-only**; do not add `_tablet.dart` variants.
- No server contract changes in this plan; server work lives in the API plan.
- Keep offline-first behaviour: the UI always renders Hive data first, then refreshes.
- New `ResourceCubit` parameters are optional and default to today's behaviour, except where a task explicitly changes a default and lists the affected call sites.
- `dart format lib` clean and `dart analyze --fatal-infos` clean after every task.
- `prf_design` is a path dependency (`../../prf_design_system`); do not edit it from this plan.
- Commit after every task on branch `perf/lean-data-loading`.

## Review Focus (manual checks; each one is repeated in its task)

1. **Sign out, then sign in as a different user**: lists load from the network and show that user's data, not an empty or stale "fresh" cache. (Task 1)
2. **Pull-to-refresh** always hits the network, even within the freshness window. (Tasks 1, 4)
3. **History lists** show the newest items first after pagination. (Task 6)
4. **Create or approve an item while its list is fresh**: the new item appears without a reload, via Hive. (Task 8)
5. **A save that times out** is not sent twice (no duplicate record). (Task 3)

---

## File Structure

| File | Responsibility |
|---|---|
| Create `lib/utils/http/request_stats_interceptor.dart` | Debug-only per-endpoint request counter for manual before/after checks. |
| Create `lib/utils/crud/fetch_ledger.dart` | Records when an (endpoint, query) pair was last fetched and answers "is it fresh?". App-wide singleton. |
| Modify `lib/utils/crud/resource_cubit.dart` | Freshness gate in `loadAll`, `invalidate()`, `staleAfter`, `crawlAllPages`, `loadNextPage()`, bigger default page. |
| Modify `lib/utils/http/retry_interceptor.dart` | Retry only idempotent methods. |
| Modify `lib/utils/http/network.dart` | Install the counter (debug), share identical in-flight GETs. |
| Modify `lib/services/local_storage/hive/hive_service.dart` | Clear the ledger when data or auth is wiped. |
| Create `lib/shared_widgets/load_more_on_scroll.dart` | Calls back near the end of a scrollable (infinite scroll). |
| Create `lib/shared/expenses/cubit/accounting_event_cubit.dart` | Fetches one accounting event (with refunds) once per expenses screen. |
| Screen files listed per task | Tab guards, lazy tabs, pagination, lean includes, reload removal. |

---

### Task 0: Request counter and baseline

**Files:**
- Create: `lib/utils/http/request_stats_interceptor.dart`
- Modify: `lib/utils/http/network.dart:96` (interceptor registration)
- Create: `docs/superpowers/plans/lean-data-loading-baseline.md`

**Interfaces:**
- Produces: `RequestStatsInterceptor.instance` with `Map<String, int> get counts`, `int get total`, `void reset()`, `String report()`.

- [ ] **Step 1: Add the counter**

```dart
// lib/utils/http/request_stats_interceptor.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Debug-only counter of API requests per "METHOD /path". Compare request
/// volume before and after a change: call `RequestStatsInterceptor.instance
/// .reset()`, perform a flow, then print `.report()` from the debug console.
class RequestStatsInterceptor extends Interceptor {
  RequestStatsInterceptor._();

  static final RequestStatsInterceptor instance = RequestStatsInterceptor._();

  final Map<String, int> _counts = {};

  Map<String, int> get counts => Map.unmodifiable(_counts);
  int get total => _counts.values.fold(0, (a, b) => a + b);

  void reset() => _counts.clear();

  String report() {
    final rows = _counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      'API requests: $total',
      for (final r in rows) '  ${r.value.toString().padLeft(4)}  ${r.key}',
    ].join('\n');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final key = '${options.method} ${Uri.parse(options.path).path}';
    _counts[key] = (_counts[key] ?? 0) + 1;
    debugPrint('[api #$total] $key ${options.uri.query}');
    handler.next(options);
  }
}
```

In `lib/utils/http/network.dart`, directly before `// Retry interceptor for transient failures` (`:96`):

```dart
    if (kDebugMode) {
      dio.interceptors.add(RequestStatsInterceptor.instance);
    }
```

Import `package:leadership/utils/http/request_stats_interceptor.dart`.

- [ ] **Step 2: Record the baseline (manual)**

Run `flutter run -t lib/main_development.dart`. Every request now prints as `[api #N] GET /missions include=…`. For each flow below, note the last `#N` (or call `reset()` / `report()` from the debug console) and write the counts into `docs/superpowers/plans/lean-data-loading-baseline.md` under a **Before** column:
1. Cold start → landing → Missions → open one mission → visit every tab → back.
2. Missions → Past tab → Schools tab.
3. Requisition approvals → open one → approve → back.
4. Members → open a member → back → open Members again.

- [ ] **Step 3: Analyze and commit**

```bash
dart format lib && dart analyze --fatal-infos
git add lib/utils/http docs/superpowers/plans/lean-data-loading-baseline.md
git commit -m "perf: add debug request counter and record baseline"
```

---

### Task 1: Freshness gate for list loads

**Files:**
- Create: `lib/utils/crud/fetch_ledger.dart`
- Modify: `lib/utils/crud/resource_cubit.dart:18-24` (constructor), `:77-81` (overridables), `:106-168` (`loadAll`), `:170-212` (`_refreshAllInBackground`)
- Modify: `lib/services/local_storage/hive/hive_service.dart:269` (`clearAllTables`), `:309` (`clearBox`)

**Interfaces:**
- Produces:
  - `FetchLedger.instance` with `bool isFresh(String key, Duration staleAfter)`, `void markFetched(String key)`, `void invalidatePrefix(String prefix)`, `void clear()`.
  - `ResourceCubit.staleAfter` (`Duration`, default 5 minutes).
  - `ResourceCubit.invalidate()`: forget freshness for this cubit's endpoint.
  - `loadAll(..., bool force = false)`.

- [ ] **Step 1: Add the ledger**

```dart
// lib/utils/crud/fetch_ledger.dart

/// Remembers when each list query was last fetched so repeat screen opens
/// can be served from Hive alone while the data is fresh.
///
/// Keys are `"<endpoint>|<query signature>"`, built by `ResourceCubit`.
/// Cleared on sign-out and on 401 (see `HiveService`).
class FetchLedger {
  FetchLedger._();

  static final FetchLedger instance = FetchLedger._();

  final Map<String, DateTime> _fetchedAt = {};

  bool isFresh(String key, Duration staleAfter) {
    final at = _fetchedAt[key];
    if (at == null) return false;
    return DateTime.now().difference(at) <= staleAfter;
  }

  void markFetched(String key) => _fetchedAt[key] = DateTime.now();

  void invalidatePrefix(String prefix) =>
      _fetchedAt.removeWhere((key, _) => key.startsWith(prefix));

  void clear() => _fetchedAt.clear();
}
```

- [ ] **Step 2: Gate `loadAll`**

In `resource_cubit.dart`, import `package:leadership/utils/crud/fetch_ledger.dart`. Under the overridables at `:77-81` add:

```dart
  /// How long a fetched list stays fresh. Within this window [loadAll]
  /// renders Hive only and makes no request. Lookup cubits override this
  /// with hours; pull-to-refresh calls [invalidate] first.
  Duration get staleAfter => const Duration(minutes: 5);

  /// Forget freshness for every query on this cubit's endpoint so the next
  /// [loadAll] hits the network. Call before pull-to-refresh reloads.
  void invalidate() =>
      FetchLedger.instance.invalidatePrefix('${_service.endpoint}|');

  String _queryKey({
    required Map<String, dynamic> filters,
    required List<String> includes,
    required int limit,
    required String? sortBy,
  }) {
    final f =
        filters.entries
            .where((e) => e.value != null)
            .map((e) => '${e.key}=${e.value}')
            .toList()
          ..sort();
    final i = [...includes]..sort();
    return '${_service.endpoint}|${f.join('&')}|${i.join(',')}|$limit|${sortBy ?? ''}';
  }
```

In `loadAll` (`:106-168`), add `bool force = false,` after `refreshInBackground`, and replace `if (!refreshInBackground) return;` (`:156`) with:

```dart
    if (!refreshInBackground) return;

    final key = _queryKey(
      filters: mergedFilters,
      includes: includes ?? defaultIncludes,
      limit: resolvedLimit,
      sortBy: sortBy ?? defaultSortBy,
    );
    if (!force && FetchLedger.instance.isFresh(key, staleAfter)) return;
```

Pass `key: key,` into `_refreshAllInBackground(...)`. In `_refreshAllInBackground`, add a `required String key,` parameter and, just before `} on Failure catch (e) {` (`:204`), add:

```dart
      if (_isLatestRequest(requestId)) FetchLedger.instance.markFetched(key);
```

This sits after the page crawl, so the key is only marked fresh once every page is persisted, and never on failure.

In `hive_service.dart`, at the top of `clearAllTables()` (`:269`) and `clearBox()` (`:309`), add `FetchLedger.instance.clear();` with the import.

- [ ] **Step 3: Manual check**

Run the app in debug:
- Open Members, go back, open Members again within 5 minutes. Expected: no new `[api …] GET /members` lines on the second open, and the list still shows.
- Wait 5+ minutes (or temporarily set `staleAfter` to 10 seconds), reopen. Expected: one fresh `GET /members` run.
- Turn on airplane mode, open a list you haven't opened yet, then turn it back off and reopen. Expected: it fetches (a failed load is not marked fresh).
- **Sign out, sign in as a different leader**, open Missions and Members. Expected: requests are made and that leader's data shows.

- [ ] **Step 4: Analyze and commit**

```bash
dart format lib && dart analyze --fatal-infos
git add lib/utils/crud lib/services/local_storage/hive/hive_service.dart
git commit -m "perf: serve fresh lists from Hive and skip refetch within staleAfter"
```

---

### Task 2: Bigger pages, opt-in page crawling, `loadNextPage()`

**Files:**
- Modify: `lib/utils/crud/resource_cubit.dart:80` (`defaultLimit`), `:194-203` (crawl), add `crawlAllPages`, `hasMorePages`, `loadNextPage()`

**Interfaces:**
- Consumes: Task 1.
- Produces: `bool get crawlAllPages` (default `true`, keeping the "complete list" behaviour for screens that search locally), `bool get hasMorePages`, `Future<void> loadNextPage()` (fetches the next page of the last `loadAll` query; does nothing when there are no more pages or a page is already loading). `defaultLimit` becomes `100`.

- [ ] **Step 1: Implement**

Change `int get defaultLimit => 15;` to:

```dart
  int get defaultLimit => 100;

  /// When true (default) [loadAll] keeps fetching until the last page so
  /// local search sees the whole collection. History lists that grow without
  /// bound override this with `false` and call [loadNextPage] on scroll.
  bool get crawlAllPages => true;

  bool get hasMorePages => _hasMore;

  List<String>? _lastIncludes;
  int _lastLimit = 0;
  String? _lastSortBy;
  bool _pageInFlight = false;
```

In `loadAll`, after `_lastFilters = mergedFilters;`:

```dart
    _lastIncludes = includes;
    _lastLimit = resolvedLimit;
    _lastSortBy = sortBy;
```

In `_refreshAllInBackground`, change `if (_hasMore) {` (`:194`) to `if (_hasMore && crawlAllPages) {`.

After `loadMore`, add:

```dart
  /// Fetch the next page of the last [loadAll] query (infinite scroll).
  Future<void> loadNextPage() async {
    if (!_hasMore || _pageInFlight) return;
    _pageInFlight = true;
    final requestId = _activeRequestId;
    final limit = _lastLimit == 0 ? defaultLimit : _lastLimit;
    try {
      final result = await _service.list(
        filters: _lastFilters,
        includes: _lastIncludes ?? defaultIncludes,
        limit: limit,
        page: _currentPage + 1,
        sortBy: _lastSortBy ?? defaultSortBy,
      );
      if (!_isLatestRequest(requestId)) return;
      _currentPage = result.pagination.currentPage ?? _currentPage + 1;
      _hasMore = _resolveHasMore(result, limit);
      await dbService.persistEntities(result.data);
    } on Failure catch (e) {
      _emitIfOpen(ResourceState.error(message: e.message, items: currentItems));
    } finally {
      _pageInFlight = false;
    }
  }
```

Leave explicit `limit: 200` / `500` call sites as they are (`rg -n "limit: " lib --type dart`).

- [ ] **Step 2: Manual check**

With the request log in debug, pull-to-refresh on Members and on Schools. Expected: `limit=100` in the query, and 1 request (or 2–3 for long collections) instead of one per 15 rows. Search on both screens still finds people and schools that were at the end of the list.

- [ ] **Step 3: Analyze and commit**

```bash
dart format lib && dart analyze --fatal-infos
git add lib/utils/crud
git commit -m "perf: 100-row pages, opt-in page crawl and loadNextPage"
```

---

### Task 3: Network hygiene: no retried writes, one request per identical GET

**Files:**
- Modify: `lib/utils/http/retry_interceptor.dart:26, 52-58`
- Modify: `lib/utils/http/network.dart` (`get` at `:260-282`)

- [ ] **Step 1: Retry only reads**

In `retry_interceptor.dart`, replace `_shouldRetry`:

```dart
  static const _idempotent = {'GET', 'HEAD', 'OPTIONS'};

  /// Only idempotent reads are retried: replaying a POST after a timeout can
  /// create the record twice.
  bool _shouldRetry(DioException err) {
    if (!_idempotent.contains(err.requestOptions.method.toUpperCase())) {
      return false;
    }
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null &&
            const [500, 502, 503, 504].contains(err.response!.statusCode));
  }
```

- [ ] **Step 2: Share identical in-flight GETs**

In `network.dart`, inside `NetworkUtil` add:

```dart
  /// Identical GETs that are already in flight share one request (e.g. two
  /// widgets loading the same lookup at the same moment).
  final Map<String, Future<Map<String, dynamic>>> _inFlightGets = {};
```

Rename the existing `get(...)` method to `_get(...)` (body unchanged), and add a new public `get` with the same signature:

```dart
  Future<Map<String, dynamic>> get(
    String url, {
    String apiVersion = 'v1',
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) {
    final query =
        (queryParameters?.entries.map((e) => '${e.key}=${e.value}').toList() ??
              <String>[])
          ..sort();
    final key = '$apiVersion|$url|${query.join('&')}';
    final existing = _inFlightGets[key];
    if (existing != null) return existing;
    final future = _get(
      url,
      apiVersion: apiVersion,
      queryParameters: queryParameters,
      headers: headers,
    ).whenComplete(() => _inFlightGets.remove(key));
    _inFlightGets[key] = future;
    return future;
  }
```

- [ ] **Step 3: Manual check**

- In debug, open the member form (it loads 5 lookups) twice quickly. Expected: no duplicate concurrent lines for the same lookup URL.
- With the network throttled (Android emulator: Settings → Network → "Poor"; iOS: Network Link Conditioner), add an expense and let it time out. Expected: the log shows **one** `POST /allocation-entries`, and refreshing the list shows no duplicate expense.

- [ ] **Step 4: Analyze and commit**

```bash
dart format lib && dart analyze --fatal-infos
git add lib/utils/http
git commit -m "perf: retry only idempotent requests and share identical GETs"
```

---

### Task 4: Long freshness for lookups; pull-to-refresh always refetches

**Files:**
- Modify (one override each): `features/churches/cubit/church_resource_cubit.dart`, `features/departments/cubit/department_resource_cubit.dart`, `features/gifts/cubit/gift_resource_cubit.dart`, `features/marital_statuses/cubit/marital_status_resource_cubit.dart`, `features/professions/cubit/profession_resource_cubit.dart`, `features/missions/cubit/mission_type_resource_cubit.dart`, `features/missions/cubit/school_term_resource_cubit.dart`, `features/missions/cubit/class_group_resource_cubit.dart`, `features/schools/cubit/contact_type_cubit.dart`, `shared/expenses/cubit/expense_categories_resource_cubit.dart`
- Modify (23 `onRefresh:` sites, find with `rg -n "onRefresh:" lib`): `features/requisition_approvals/_handset.dart`, `features/missions/_handset.dart`, `features/missions/mission_details/widgets/record_sections.dart`, `features/missions/mission_details/_handset.dart`, `features/missions/school_past_missions/_handset.dart`, `features/events/_handset.dart`, `shared/requisitions/_handset.dart`, `shared/requisitions/requisition_details/_handset.dart`

- [ ] **Step 1: Lookups stay fresh for 12 hours**

In each of the 10 lookup cubits:

```dart
  /// Reference data changes rarely; pull-to-refresh still forces a reload.
  @override
  Duration get staleAfter => const Duration(hours: 12);
```

- [ ] **Step 2: Pull-to-refresh invalidates first**

At each `onRefresh:` site, call `invalidate()` on the cubit(s) being reloaded before the existing call. Examples:

```dart
// features/missions/_handset.dart (upcoming tab)
onRefresh: () {
  final cubit = context.read<MissionResourceCubit>()..invalidate();
  return cubit.loadUpcomingMissions();
},
```

```dart
// features/requisition_approvals/_handset.dart
onRefresh: () {
  cubit.invalidate();
  return reload(cubit);
},
```

For `features/missions/mission_details/_handset.dart` (`onRefresh: _loadMissionSubdomainData`), call `invalidate()` on each sub-cubit at the top of `_loadMissionSubdomainData` before its loads.

- [ ] **Step 3: Manual check**

- Open the member form, close it, open it again. Expected: the second open makes 0 lookup requests.
- On every screen with pull-to-refresh, pull down right after the list loaded. Expected: a request is logged every time.

- [ ] **Step 4: Analyze and commit**

```bash
dart format lib && dart analyze --fatal-infos
git add lib
git commit -m "perf: 12h freshness for lookups; pull-to-refresh invalidates first"
```

---

### Task 5: Load only the visible tab, once per tap

**Files:**
- Modify: `features/missions/_handset.dart:50-67`
- Modify: `features/events/_handset.dart:40-62`
- Modify: `features/requisition_approvals/_handset.dart:40-67`
- Modify: `features/missions/mission_details/_handset.dart:89-146`

- [ ] **Step 1: Guard listeners and load lazily**

`features/missions/_handset.dart`, replace the listener body:

```dart
    _tabController.addListener(() {
      // TabController notifies twice per animated change; act once.
      if (_tabController.indexIsChanging) return;
      _loadTab(_tabController.index);
    });
```

```dart
  void _loadTab(int index) {
    switch (index) {
      case 0:
        context.read<MissionResourceCubit>().loadUpcomingMissions();
      case 1:
        context.read<MissionResourceCubit>().loadPastMissions();
      default:
        context.read<PastMissionResourceCubit>().loadAll(
          filters: _schoolsFilters(),
        );
    }
  }
```

Add the same `if (_tabController.indexIsChanging) return;` guard to the listeners in `features/events/_handset.dart:56` and `features/requisition_approvals/_handset.dart:58`. In `requisition_approvals/_handset.dart:40-56` and `events/_handset.dart:40-53`, keep creating the cubits but call only the **first** tab's load in `initState`; the listener loads the others on first selection.

- [ ] **Step 2: Mission details: load each sub-list when its tab is first shown**

In `features/missions/mission_details/_handset.dart`, replace the six eager `loadForMission` calls in `initState` (`:111-131`) with:

```dart
  final Set<int> _loadedTabs = {};

  void _ensureTabLoaded(int index) {
    if (!_loadedTabs.add(index)) return;
    final ulid = widget.missionUlid;
    switch (index) {
      case _peopleTab:
        context.read<MissionSubscriptionResourceCubit>().loadForMission(missionUlid: ulid);
        context.read<MissionOfflineMemberResourceCubit>().loadForMission(missionUlid: ulid);
      case _sessionsTab:
        context.read<MissionSessionResourceCubit>().loadForMission(missionUlid: ulid);
      case _feedbackTab:
        context.read<MissionQuestionResourceCubit>().loadForMission(missionUlid: ulid);
        context.read<DebriefNoteResourceCubit>().loadForMission(missionUlid: ulid);
        context.read<SoulResourceCubit>().loadForMission(missionUlid: ulid);
    }
  }
```

Define `_peopleTab`, `_sessionsTab`, `_feedbackTab` as `static const int` matching this file's `TabBar` order (read the `tabs:` list), and use the exact `loadForMission` argument names already used at `:111-131`. Call `_ensureTabLoaded(_tabController.index)` once in `initState` and from the tab listener (guarded by `indexIsChanging`). Also move the class-group load (`:146`) to the tab that shows class groups.

- [ ] **Step 3: Manual check**

- Missions: reset the log, tap Past, Schools, then Upcoming. Expected: one `GET` per tab on first visit, none on the return to Upcoming, and never two identical lines per tap.
- Requisition approvals: opening it logs one `GET /requisitions`; the Closed tab loads only when tapped.
- Mission details: opening a mission logs no sub-list requests until each tab is opened, and every tab still shows its data.

- [ ] **Step 4: Analyze and commit**

```bash
dart format lib && dart analyze --fatal-infos
git add lib
git commit -m "perf: load tabs lazily and once per tap"
```

---

### Task 6: Page history lists on scroll, newest first

**Files:**
- Create: `lib/shared_widgets/load_more_on_scroll.dart`
- Modify: `features/missions/cubit/mission_resource_cubit.dart:55-58`
- Modify: `features/events/cubit/event_resource_cubit.dart:68-80`
- Modify: `shared/requisitions/cubit/requisition_resource_cubit.dart` (closed-requisitions loader used by approvals)
- Modify: the Past tab in `features/missions/_handset.dart`, past events tab in `features/events/_handset.dart`, Closed tab in `features/requisition_approvals/_handset.dart`

**Interfaces:**
- Consumes: `crawlAllPages`, `loadNextPage()`, `hasMorePages` (Task 2).

- [ ] **Step 1: Infinite-scroll helper**

```dart
// lib/shared_widgets/load_more_on_scroll.dart
import 'package:flutter/widgets.dart';

/// Calls [onEndReached] when the wrapped scrollable is within [threshold]
/// pixels of its end. `ResourceCubit.loadNextPage` ignores repeat calls.
class LoadMoreOnScroll extends StatelessWidget {
  const LoadMoreOnScroll({
    required this.child,
    required this.onEndReached,
    this.threshold = 600,
    super.key,
  });

  final Widget child;
  final VoidCallback onEndReached;
  final double threshold;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.extentAfter < threshold) onEndReached();
        return false;
      },
      child: child,
    );
  }
}
```

- [ ] **Step 2: History loaders page newest-first**

In `MissionResourceCubit`, `EventResourceCubit` and `RequisitionResourceCubit`, add:

```dart
  bool _historyMode = false;

  @override
  bool get crawlAllPages => !_historyMode;
```

Set `_historyMode = true` in the history loader and `_historyMode = false` at the top of every other `load*` method in that cubit.

`mission_resource_cubit.dart`:

```dart
  Future<void> loadPastMissions() {
    _historyMode = true;
    _lastListFilters = {'past': true};
    // Newest first so page 1 is the most recent history.
    return loadAll(filters: _lastListFilters, sortBy: '-start_date', limit: 30);
  }
```

In `loadPastEvents`, set `_historyMode = true`, change `sortBy: 'start_date'` to `'-start_date'` and add `limit: 30`. In the closed-requisitions loader, set `_historyMode = true`, use `sortBy: '-requisition_date'` and `limit: 30`.

- [ ] **Step 3: Wire the tabs**

Wrap each history tab's scrollable:

```dart
LoadMoreOnScroll(
  onEndReached: () => context.read<MissionResourceCubit>().loadNextPage(),
  child: /* existing list */,
)
```

Show a `PRFCircularProgressIndicator` as the last item while `cubit.hasMorePages` is true. If a screen groups or sorts history locally in ascending order, keep that display order; only the fetch order changes.

- [ ] **Step 4: Manual check**

- Missions → Past: one `GET /missions … limit=30&sort=-start_date`. The most recent past missions show at the top. Scrolling to the end logs one more request and appends older missions, and so on until the end with no spinner.
- Same for past events and closed requisitions.

- [ ] **Step 5: Analyze and commit**

```bash
dart format lib && dart analyze --fatal-infos
git add lib
git commit -m "perf: page past missions, past events and closed requisitions on scroll"
```

---

### Task 7: Ask for less in each response

**Files:**
- Modify: `features/missions/cubit/mission_resource_cubit.dart:21-29`
- Modify: `features/missions/cubit/mission_detail_cubit.dart:18-26`
- Modify: `features/missions/mission_details/_handset.dart` (`loadOne` in `initState`)
- Modify: `shared/requisitions/cubit/requisition_resource_cubit.dart` (`loadForAccountingEvent`)
- Modify: `shared/expenses/cubit/allocation_entry_resource_cubit.dart:236-247`
- Create: `shared/expenses/cubit/accounting_event_cubit.dart`
- Modify: `shared/expenses/expenses.dart`, `shared/expenses/_handset.dart:193-210`

**Interfaces:**
- Produces: `AccountingEventCubit(AccountingEventService)` with `Future<void> load(String ulid, {bool force = false})`; state `({PRFAccountingEvent? event, bool loading, String? error})`.

- [ ] **Step 1: Lean mission lists; full payload only on details**

`mission_resource_cubit.dart`:

```dart
  @override
  List<String> get defaultIncludes => ['school', 'missionType', 'schoolTerm'];
```

`mission_detail_cubit.dart` (also removes the duplicate `missionType`):

```dart
  @override
  List<String> get defaultIncludes => [
    'school',
    'missionType',
    'school.schoolContacts.contactType',
    'accountingEvent',
    'schoolTerm',
    'weatherForecasts',
  ];
```

In mission details `initState`, call `loadOne(id: …, matchById: …, refresh: true)` once so the screen fetches its full payload (one request). Before committing, check nothing outside details reads the dropped includes from list items: `rg -n "weatherForecasts|accountingEvent|schoolContacts" lib/features/missions --glob '!**/mission_details/**'`. For each hit, either move it into details or keep that include, and note the decision in the commit message.

- [ ] **Step 2: Requisitions under a known accounting event don't embed it**

In `RequisitionResourceCubit.loadForAccountingEvent`, pass `includes: ['member', 'appointedApprover', 'approvedBy', 'paymentInstruction']`.

- [ ] **Step 3: Fetch the accounting event once for expenses**

```dart
// lib/shared/expenses/cubit/accounting_event_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/services/api/accounting_event_service.dart';

typedef AccountingEventState = ({
  PRFAccountingEvent? event,
  bool loading,
  String? error,
});

/// Loads one accounting event (with its refunds) for the expenses screen,
/// so expense rows no longer embed the parent event on every row.
class AccountingEventCubit extends Cubit<AccountingEventState> {
  AccountingEventCubit(this._service)
    : super((event: null, loading: false, error: null));

  final AccountingEventService _service;
  String? _loadedUlid;

  Future<void> load(String ulid, {bool force = false}) async {
    if (!force && _loadedUlid == ulid && state.event != null) return;
    emit((event: state.event, loading: true, error: null));
    try {
      final event = await _service.get(
        ulid: ulid,
        includes: ['refunds', 'latestRefund'],
      );
      _loadedUlid = ulid;
      if (!isClosed) emit((event: event, loading: false, error: null));
    } on Failure catch (e) {
      if (!isClosed) {
        emit((event: state.event, loading: false, error: e.message));
      }
    }
  }
}
```

Check the model import with `rg -l "class PRFAccountingEvent" lib/models` and adjust if it differs.

- In `allocation_entry_resource_cubit.dart:238-246`, change the includes to `['expenseCategory', 'member', 'receipts']`.
- In `shared/expenses/expenses.dart`, wrap the variant in `BlocProvider(create: (_) => AccountingEventCubit(getIt<AccountingEventService>())..load(accountingEventUlid), child: …)`.
- In `shared/expenses/_handset.dart:199-201`, replace `entries.first.accountingEvent` with `context.watch<AccountingEventCubit>().state.event`, and render the header only when it is non-null (removing the `accountingEvent!` force-unwrap).
- After add-token, add-refund and expense saves, call `context.read<AccountingEventCubit>().load(ulid, force: true)` so the totals the server computes are updated.

- [ ] **Step 4: Manual check**

- Missions list: the logged `GET /missions` URL has `include=school,missionType,schoolTerm`. The list still shows school, type and term.
- Opening a mission logs one `GET /missions/{ulid}` with the full includes. Contacts, weather and the finance section show.
- Finance → Expenses logs one `GET /accounting-events/{ulid}?include=refunds,latestRefund` and one `GET /allocation-entries` without `accountingEvent` in the include. The header totals and refunds list show. Adding a token updates the totals.

- [ ] **Step 5: Analyze and commit**

```bash
dart format lib && dart analyze --fatal-infos
git add lib
git commit -m "perf: lean list includes; fetch accounting event once for expenses"
```

---

### Task 8: Drop redundant reloads; startup and small fixes

**Files:**
- Modify (remove reload-after-close): `features/missions/_handset.dart:647-659`, `features/members/_handset.dart:314`, `features/members/member_detail/_handset.dart:570`, `features/schools/_handset.dart:345`, `features/schools/school_detail/_handset.dart:61`, `features/schools/school_contacts/_handset.dart:226-227`, `shared/expenses/_handset.dart:1350,1370`, `shared/requisitions/_handset.dart:156`, `shared/requisitions/requisition_details/_handset.dart:1711`
- Modify: `bootstrap.dart:90-97`, `lib/services/local_storage/hive/kv/auth_hive_service.dart:21,55`
- Modify: `features/schools/school_detail/_handset.dart:33`, `features/members/member_detail/_handset.dart:37-38`, `features/missions/mission_details/_handset.dart:711`, `features/members/cubit/member_resource_cubit.dart`

- [ ] **Step 1: Remove reloads that Hive already covers**

At each listed site, delete the `.then((_) => …loadAll…)` / `.then((_) => reload…)` reload. `ResourceCubit.create/update/delete` already persist the server response to Hive, and the list's DB-stream subscription re-emits. For the expenses token/refund sheets (`shared/expenses/_handset.dart:1350,1370`), replace the reload with `context.read<AccountingEventCubit>().load(ulid, force: true)` (Task 7), and only when the sheet reports a save: `final saved = await showPRFBottomSheet<bool>(…); if (saved ?? false) …`, with the sheet calling `Navigator.pop(context, true)` on success.

- [ ] **Step 2: Send the FCM token only when it changed**

In `AuthHiveService` (`lib/services/local_storage/hive/kv/auth_hive_service.dart`), beside `retrieveToken()`:

```dart
  // FCM token last sent to the API, so cold starts skip unchanged tokens.
  void storeFcmTokenSent(String token) => put('fcmTokenSent', token);

  String? retrieveFcmTokenSent() => get<String>('fcmTokenSent');
```

Add `'fcmTokenSent'` to the `deleteAll([...])` list in `clearAuthData()` so a new sign-in re-sends it. In `bootstrap.dart:90-97`, wrap the existing `updateProfile` call:

```dart
      final lastSent = getIt<HiveService>().auth.retrieveFcmTokenSent();
      if (fcmToken != null && fcmToken != lastSent) {
        // existing updateProfile(...) call, unchanged
        getIt<HiveService>().auth.storeFcmTokenSent(fcmToken);
      }
```

- [ ] **Step 3: Small fixes**

- `school_detail/_handset.dart:33`: stop calling `ContactCubit.loadForSchool(...)` on open. Render `school.schoolContacts` from the school already in hand, and keep `loadForSchool` only behind pull-to-refresh.
- `member_detail/_handset.dart:37-38`: remove `MemberResourceCubit.loadAll()`. The member comes from the list or Hive.
- `mission_details/_handset.dart:711`: make the "Refresh mission" action call `loadOne(…, refresh: true)`.
- `MemberResourceCubit.loadCachedList`: honour the executive-committee filter. Find the field with `rg -n "executive" lib/models/remote/prf_member.dart`; if it exists:

```dart
  @override
  Future<List<PRFMember>> loadCachedList({Map<String, dynamic>? filters}) async {
    final all = await dbService.list();
    if (filters?['is_executive_committee_member'] != true) return all;
    return all.where((m) => m.isExecutiveCommitteeMember).toList();
  }
```

  (Use the real field name.) If `PRFMember` has no such field, leave `loadCachedList` unchanged and note in the commit that the picker relies on the server filter.

- [ ] **Step 4: Manual check and final measurement**

- Add a member and a school while their lists are fresh. Expected: they appear immediately with no `GET` after the `POST`.
- Cancel the create-mission sheet. Expected: no requests logged.
- Restart the app twice. Expected: `update-profile` is logged on the first start only.
- Open a school. Expected: its contacts show with no `GET /school-contacts`.
- The mission "Refresh" action logs a `GET /missions/{ulid}`.
- The request-review approver picker lists only executive-committee members.
- Repeat the four baseline flows from Task 0 and fill in an **After** column in `docs/superpowers/plans/lean-data-loading-baseline.md`. Targets: flow 1 ≤ 12 requests on the first visit and ≤ 3 on a repeat within 5 minutes; flow 3 ≤ 6.

- [ ] **Step 5: Analyze and commit**

```bash
dart format lib && dart analyze --fatal-infos
git add lib docs
git commit -m "perf: drop redundant reloads, send FCM token only on change, small fixes"
```

---

## Expected outcome

| Flow | Today (est.) | After |
|---|---|---|
| Cold start → missions → one mission → all tabs → back | ~18–25 | ~8–10 first visit; ~2 repeat (cache fresh) |
| + Past + Schools tabs | ~45–50 | ~12 |
| Approve one requisition | ~26 | ~5–6 |
| Re-open any list within 5 min | full collection | 0 |
| Open a form with lookups | 1–5 full lists | 0 after first use in 12 h |

Server time per request drops further once the API plan stops the ~12 SUM queries per serialised accounting event.
