import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/services/api/_base_api_service.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';
import 'package:leadership/utils/crud/paginated_response.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:logger/logger.dart';

/// A single cubit that handles list, create, update, and delete
/// for any resource backed by a [BaseAPIService<T>].
///
/// Subclasses only need to:
///   1. Pass the service via super constructor.
///   2. Optionally override [defaultIncludes], [defaultFilters], etc.
///   3. Add resource-specific convenience methods.
abstract class ResourceCubit<TRemote> extends Cubit<ResourceState<TRemote>> {
  ResourceCubit({
    required this._service,
    required this.dbService,
  }) : super(const ResourceState.initial());

  final BaseAPIService<TRemote> _service;
  final BaseHiveDbService<TRemote> dbService;
  final _logger = Logger();

  /// Stores the last filters used by [loadAll] to ensure
  /// subsequent fetches use the correct parent key after mutations.
  Map<String, dynamic>? _lastFilters;

  /// Exposes [_lastFilters] to subclasses that need to pass the last-used
  /// filter context (e.g. parent ULID) from within
  /// custom mutation methods.
  Map<String, dynamic>? get lastFilters => _lastFilters;

  /// Subscription to the Hive DB stream for reactive updates.
  /// When external sources (e.g., API calls, socket events) write to Hive,
  /// this triggers a re-fetch so the cubit state stays current organically.
  StreamSubscription<List<TRemote>>? _dbStreamSubscription;

  int _requestSequence = 0;
  int _activeRequestId = 0;
  int _currentPage = 1;
  bool _hasMore = false;

  /// Subscribe to the Hive DB service's stream.
  /// The stream automatically triggers a locally filtered fetch via [loadCachedList].
  void subscribeToDbUpdates() {
    _dbStreamSubscription?.cancel();
    _dbStreamSubscription = dbService.stream.listen((_) async {
      if (!isClosed) {
        try {
          final hiveItems = await loadCachedList(filters: _lastFilters);
          _emitIfOpen(
            ResourceState.listLoaded(
              items: hiveItems,
              page: _currentPage,
              hasMore: _hasMore,
            ),
          );
        } catch (e, s) {
          _logger.e(
            'Error syncing cached list from DB stream',
            error: e,
            stackTrace: s,
          );
        }
      }
    });
  }

  @override
  Future<void> close() {
    _dbStreamSubscription?.cancel();
    return super.close();
  }

  /// Override these in subclasses for resource-specific defaults.
  List<String> get defaultIncludes => [];
  Map<String, dynamic> get defaultFilters => {};
  int get defaultLimit => 15;
  String? get defaultSortBy => null;

  /// Extracts the current list from whatever state we are in.
  List<TRemote> get currentItems {
    return state.maybeWhen(
      itemLoading: (items, _) => items,
      listLoading: (items) => items,
      listLoaded: (items, _, _) => items,
      itemLoaded: (_, items) => items,
      mutating: (items, _) => items,
      error: (_, items) => items,
      itemError: (_, items, _) => items,
      orElse: () => [],
    );
  }

  /// Returns the initial cached list used by [loadAll] for the cache-first
  /// local seed. Defaults to [dbService.list()] (all items).
  ///
  /// Override in subclasses that have parent-filtered Hive data to return only
  /// the items relevant to the current parent context (e.g. by mission ULID).
  Future<List<TRemote>> loadCachedList({
    Map<String, dynamic>? filters,
  });

  /// Fetch the full list of resources from the API.
  /// Persists into Hive, triggering an organic UI update via [_dbStreamSubscription].
  Future<void> loadAll({
    Map<String, dynamic>? filters,
    List<String>? includes,
    int? limit,
    int? page,
    String? sortBy,
    bool refreshInBackground = true,
  }) async {
    _emitIfOpen(ResourceState.listLoading());

    final mergedFilters = {...defaultFilters, ...?filters};
    _lastFilters = mergedFilters;
    final startPage = page ?? 1;
    final resolvedLimit = limit ?? defaultLimit;
    final requestId = _nextRequestId();

    // Ensure we are subscribed to organically push DB changes to the UI
    if (_dbStreamSubscription == null) {
      subscribeToDbUpdates();
    }

    // Strict offline-first: always seed UI with cache immediately.
    try {
      final cached = await loadCachedList(filters: mergedFilters);
      _currentPage = startPage;
      _hasMore = cached.length == resolvedLimit;
      _emitIfOpen(
        ResourceState.listLoaded(
          items: cached,
          page: _currentPage,
          hasMore: _hasMore,
        ),
      );
    } catch (e, s) {
      _logger.e(
        'Error loading cached list before background refresh',
        error: e,
        stackTrace: s,
      );
      _currentPage = startPage;
      _hasMore = false;
      _emitIfOpen(
        ResourceState.listLoaded(
          items: currentItems,
          page: _currentPage,
          hasMore: _hasMore,
        ),
      );
    }

    if (!refreshInBackground) return;

    unawaited(
      _refreshAllInBackground(
        requestId: requestId,
        mergedFilters: mergedFilters,
        includes: includes,
        resolvedLimit: resolvedLimit,
        startPage: startPage,
        sortBy: sortBy,
      ),
    );
  }

  Future<void> _refreshAllInBackground({
    required int requestId,
    required Map<String, dynamic> mergedFilters,
    required List<String>? includes,
    required int resolvedLimit,
    required int startPage,
    required String? sortBy,
  }) async {
    try {
      final result = await _service.list(
        filters: mergedFilters,
        includes: includes ?? defaultIncludes,
        limit: resolvedLimit,
        page: startPage,
        sortBy: sortBy ?? defaultSortBy,
      );

      if (!_isLatestRequest(requestId)) return;

      _currentPage = result.pagination.currentPage ?? startPage;
      _hasMore = _resolveHasMore(result, resolvedLimit);

      await dbService.persistEntities(result.data);

      if (_hasMore) {
        await _loadRemainingPagesInBackground(
          requestId: requestId,
          startFromPage: _currentPage + 1,
          mergedFilters: mergedFilters,
          includes: includes,
          resolvedLimit: resolvedLimit,
          sortBy: sortBy,
        );
      }
    } on Failure catch (e) {
      _emitIfOpen(ResourceState.error(message: e.message, items: currentItems));
    } catch (e, s) {
      _logger.e('Error loading resources', error: e, stackTrace: s);
      _emitIfOpen(
        ResourceState.error(message: e.toString(), items: currentItems),
      );
    }
  }

  Future<void> _loadRemainingPagesInBackground({
    required int requestId,
    required int startFromPage,
    required Map<String, dynamic> mergedFilters,
    required List<String>? includes,
    required int resolvedLimit,
    required String? sortBy,
  }) async {
    var nextPage = startFromPage;

    while (_hasMore && _isLatestRequest(requestId)) {
      final result = await _service.list(
        filters: mergedFilters,
        includes: includes ?? defaultIncludes,
        limit: resolvedLimit,
        page: nextPage,
        sortBy: sortBy ?? defaultSortBy,
      );

      if (!_isLatestRequest(requestId)) return;

      _currentPage = result.pagination.currentPage ?? nextPage;
      _hasMore = _resolveHasMore(result, resolvedLimit);

      await dbService.persistEntities(result.data);
      nextPage += 1;
    }
  }

  /// Append the next page of results to the current list.
  Future<void> loadMore({
    required int page,
    Map<String, dynamic>? filters,
    List<String>? includes,
    int? limit,
    String? sortBy,
    bool loadUntilDone = false,
  }) async {
    final mergedFilters = {...defaultFilters, ...?filters};
    _lastFilters = mergedFilters;
    final resolvedLimit = limit ?? defaultLimit;
    final requestId = _nextRequestId();

    if (_dbStreamSubscription == null) {
      subscribeToDbUpdates();
    }

    try {
      final result = await _service.list(
        filters: mergedFilters,
        includes: includes ?? defaultIncludes,
        limit: resolvedLimit,
        page: page,
        sortBy: sortBy ?? defaultSortBy,
      );

      if (!_isLatestRequest(requestId)) return;

      _currentPage = result.pagination.currentPage ?? page;
      _hasMore = _resolveHasMore(result, resolvedLimit);

      await dbService.persistEntities(result.data);

      if (loadUntilDone && _hasMore) {
        await _loadRemainingPagesInBackground(
          requestId: requestId,
          startFromPage: _currentPage + 1,
          mergedFilters: mergedFilters,
          includes: includes,
          resolvedLimit: resolvedLimit,
          sortBy: sortBy,
        );
      }
    } on Failure catch (e) {
      _emitIfOpen(ResourceState.error(message: e.message, items: currentItems));
    } catch (e, s) {
      _logger.e('Error loading more resources', error: e, stackTrace: s);
      _emitIfOpen(
        ResourceState.error(message: e.toString(), items: currentItems),
      );
    }
  }

  /// Create a new resource.
  ///
  /// Persists the API response to Hive, leaving [_dbStreamSubscription] to
  /// stream the authoritative list state back to the UI.
  Future<void> create({
    required Map<String, dynamic> data,
    List<String>? includes,
  }) async {
    _emitIfOpen(
      ResourceState.mutating(
        items: currentItems,
        operation: ResourceOperation.create,
      ),
    );
    try {
      final item = await _service.create(
        data: data,
        includes: includes ?? defaultIncludes,
      );
      await dbService.persistEntity(item);
    } on Failure catch (e) {
      _emitIfOpen(ResourceState.error(message: e.message, items: currentItems));
    } catch (e, s) {
      _logger.e('Error creating resource', error: e, stackTrace: s);
      _emitIfOpen(
        ResourceState.error(message: e.toString(), items: currentItems),
      );
    }
  }

  /// Update an existing resource.
  ///
  /// Persists the API response to Hive, leaving [_dbStreamSubscription] to
  /// stream the authoritative list state back to the UI.
  Future<void> update({
    required String id,
    required Map<String, dynamic> data,
    required bool Function(TRemote item) matchById,
    List<String>? includes,
  }) async {
    _emitIfOpen(
      ResourceState.mutating(
        items: currentItems,
        operation: ResourceOperation.update,
      ),
    );
    try {
      final item = await _service.update(
        id: id,
        data: data,
        includes: includes ?? defaultIncludes,
      );
      await dbService.persistEntity(item);
    } on Failure catch (e) {
      _emitIfOpen(ResourceState.error(message: e.message, items: currentItems));
    } catch (e, s) {
      _logger.e('Error updating resource', error: e, stackTrace: s);
      _emitIfOpen(
        ResourceState.error(message: e.toString(), items: currentItems),
      );
    }
  }

  /// Delete a resource.
  ///
  /// Removes the record from Hive, leaving [_dbStreamSubscription] to
  /// stream the authoritative list state back to the UI.
  Future<void> delete({
    required String ulid,
    required bool Function(TRemote item) matchById,
  }) async {
    _emitIfOpen(
      ResourceState.mutating(
        items: currentItems,
        operation: ResourceOperation.delete,
      ),
    );
    try {
      await _service.delete(ulid: ulid);
      await dbService.deleteByKey(ulid);
    } on Failure catch (e) {
      _emitIfOpen(ResourceState.error(message: e.message, items: currentItems));
    } catch (e, s) {
      _logger.e('Error deleting resource', error: e, stackTrace: s);
      _emitIfOpen(
        ResourceState.error(message: e.toString(), items: currentItems),
      );
    }
  }

  /// Reset to initial state.
  void reset() => _emitIfOpen(const ResourceState.initial());

  void _emitIfOpen(ResourceState<TRemote> nextState) {
    if (isClosed) return;
    emit(nextState);
  }

  int _nextRequestId() {
    _requestSequence += 1;
    return _activeRequestId = _requestSequence;
  }

  bool _isLatestRequest(int requestId) => requestId == _activeRequestId;

  bool _resolveHasMore(PaginatedResponse<TRemote> result, int resolvedLimit) {
    if (result.pagination.hasNext) return true;
    if (result.pagination.currentPage != null) return false;
    return result.data.length == resolvedLimit;
  }
}
