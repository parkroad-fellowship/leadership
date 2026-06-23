import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/services/api/_base_api_service.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:logger/logger.dart';

abstract class ResourceCubit<TRemote> extends Cubit<ResourceState<TRemote>> {
  ResourceCubit({
    required this._service,
    required this.dbService,
  }) : super(const ResourceState.initial());

  final BaseAPIService<TRemote> _service;
  final BaseHiveDbService<TRemote> dbService;
  final _logger = Logger();

  Map<String, dynamic>? _lastFilters;
  Map<String, dynamic>? get lastFilters => _lastFilters;

  StreamSubscription<List<TRemote>>? _dbStreamSubscription;

  int _requestSequence = 0;
  int _activeRequestId = 0;
  int _currentPage = 1;
  bool _hasMore = false;

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

  List<String> get defaultIncludes => [];
  Map<String, dynamic> get defaultFilters => {};
  int get defaultLimit => 15;
  String? get defaultSortBy => null;

  List<TRemote> get currentItems {
    return state.maybeWhen(
      itemLoading: (items, _) => items,
      listLoading: () => [],
      listLoaded: (items, _, _) => items,
      itemLoaded: (_, items) => items,
      mutating: (items, _) => items,
      mutated: (items, _, _) => items,
      error: (_, items) => items,
      itemError: (_, items, _) => items,
      orElse: () => [],
    );
  }

  TRemote? get currentItem {
    return state.maybeWhen(
      itemLoading: (_, item) => item,
      itemLoaded: (item, _) => item,
      itemError: (_, _, item) => item,
      listLoaded: (items, _, _) => items.isNotEmpty ? items.first : null,
      mutated: (items, _, item) =>
          item ?? (items.isNotEmpty ? items.first : null),
      orElse: () => null,
    );
  }

  Future<List<TRemote>> loadCachedList({
    Map<String, dynamic>? filters,
  });

  Future<void> loadAll({
    Map<String, dynamic>? filters,
    List<String>? includes,
    int? limit,
    int? page,
    String? orderBy,
    String? orderDirection,
    bool refreshInBackground = true,
  }) async {
    _emitIfOpen(ResourceState.listLoading());

    final mergedFilters = {...defaultFilters, ...?filters};
    _lastFilters = mergedFilters;
    final startPage = page ?? 1;
    final resolvedLimit = limit ?? defaultLimit;
    final requestId = _nextRequestId();

    if (_dbStreamSubscription == null) {
      subscribeToDbUpdates();
    }

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
        orderBy: orderBy,
      ),
    );
  }

  Future<void> _refreshAllInBackground({
    required int requestId,
    required Map<String, dynamic> mergedFilters,
    required List<String>? includes,
    required int resolvedLimit,
    required int startPage,
    required String? orderBy,
  }) async {
    try {
      final result = await _service.list(
        filters: mergedFilters,
        includes: includes ?? defaultIncludes,
        limit: resolvedLimit,
        page: startPage,
        sortBy: orderBy ?? defaultSortBy,
      );

      if (!_isLatestRequest(requestId)) return;

      _currentPage = result.pagination.currentPage ?? 1;
      _hasMore = result.pagination.hasNext;

      await dbService.persistEntities(result.data);

      if (_hasMore) {
        await _loadRemainingPagesInBackground(
          requestId: requestId,
          startFromPage: _currentPage + 1,
          mergedFilters: mergedFilters,
          includes: includes,
          resolvedLimit: resolvedLimit,
          orderBy: orderBy,
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
    required String? orderBy,
  }) async {
    var nextPage = startFromPage;

    while (_hasMore && _isLatestRequest(requestId)) {
      final result = await _service.list(
        filters: mergedFilters,
        includes: includes ?? defaultIncludes,
        limit: resolvedLimit,
        page: nextPage,
        sortBy: orderBy ?? defaultSortBy,
      );

      if (!_isLatestRequest(requestId)) return;

      _currentPage = result.pagination.currentPage ?? 1;
      _hasMore = result.pagination.hasNext;

      await dbService.persistEntities(result.data);
      nextPage += 1;
    }
  }

  Future<void> loadMore({
    required int page,
    Map<String, dynamic>? filters,
    List<String>? includes,
    int? limit,
    String? orderBy,
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
        sortBy: orderBy ?? defaultSortBy,
      );

      if (!_isLatestRequest(requestId)) return;

      _currentPage = result.pagination.currentPage ?? 1;
      _hasMore = result.pagination.hasNext;

      await dbService.persistEntities(result.data);

      if (loadUntilDone && _hasMore) {
        await _loadRemainingPagesInBackground(
          requestId: requestId,
          startFromPage: _currentPage + 1,
          mergedFilters: mergedFilters,
          includes: includes,
          resolvedLimit: resolvedLimit,
          orderBy: orderBy,
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

  Future<void> loadOne({
    required String id,
    List<String>? includes,
  }) async {
    final existing = currentItem;
    _emitIfOpen(ResourceState.itemLoading(item: existing));

    try {
      final cached = await dbService.get(id);
      if (cached != null) {
        _emitIfOpen(ResourceState.itemLoaded(item: cached));
      }

      final item = await _service.get(
        ulid: id,
        includes: includes ?? defaultIncludes,
      );
      await dbService.persistEntity(item);

      final persisted = await dbService.get(id);
      _emitIfOpen(
        ResourceState.itemLoaded(item: persisted ?? item),
      );
    } on Failure catch (e) {
      final cached = await dbService.get(id);
      if (cached != null) {
        _emitIfOpen(ResourceState.itemLoaded(item: cached));
        return;
      }
      _emitIfOpen(
        ResourceState.itemError(message: e.message, item: existing),
      );
    } catch (e, s) {
      final cached = await dbService.get(id);
      if (cached != null) {
        _emitIfOpen(ResourceState.itemLoaded(item: cached));
        return;
      }
      _logger.e('Error loading single resource', error: e, stackTrace: s);
      _emitIfOpen(
        ResourceState.itemError(
          message: e.toString(),
          item: existing,
        ),
      );
    }
  }

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
      final updated = [item, ...currentItems];
      _emitIfOpen(
        ResourceState.mutated(
          items: updated,
          operation: ResourceOperation.create,
          item: item,
        ),
      );
    } on Failure catch (e) {
      _emitIfOpen(ResourceState.error(message: e.message, items: currentItems));
    } catch (e, s) {
      _logger.e('Error creating resource', error: e, stackTrace: s);
      _emitIfOpen(
        ResourceState.error(message: e.toString(), items: currentItems),
      );
    }
  }

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
      final updated = currentItems.map((existing) {
        return matchById(existing) ? item : existing;
      }).toList();
      _emitIfOpen(
        ResourceState.mutated(
          items: updated,
          operation: ResourceOperation.update,
          item: item,
        ),
      );
    } on Failure catch (e) {
      _emitIfOpen(ResourceState.error(message: e.message, items: currentItems));
    } catch (e, s) {
      _logger.e('Error updating resource', error: e, stackTrace: s);
      _emitIfOpen(
        ResourceState.error(message: e.toString(), items: currentItems),
      );
    }
  }

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
      final updated = currentItems.where((item) => !matchById(item)).toList();
      _emitIfOpen(
        ResourceState.mutated(
          items: updated,
          operation: ResourceOperation.delete,
        ),
      );
    } on Failure catch (e) {
      _emitIfOpen(ResourceState.error(message: e.message, items: currentItems));
    } catch (e, s) {
      _logger.e('Error deleting resource', error: e, stackTrace: s);
      _emitIfOpen(
        ResourceState.error(message: e.toString(), items: currentItems),
      );
    }
  }

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
}
