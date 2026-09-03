import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:leadership/models/remote/failure.dart';
import 'package:leadership/services/api/_base_api_service.dart';
import 'package:leadership/services/local_storage/hive/db/_base_hive_db_service.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:logger/logger.dart';

class SingleResourceCubit<TRemote> extends Cubit<ResourceState<TRemote>> {
  SingleResourceCubit({
    required this._service,
    required this._dbService,
  }) : super(const ResourceState.initial());

  final BaseAPIService<TRemote> _service;
  final BaseHiveDbService<TRemote> _dbService;
  final _logger = Logger();

  StreamSubscription<TRemote?>? _dbItemSubscription;
  String? _subscribedItemId;

  void subscribeToDbUpdates(String id) {
    _dbItemSubscription?.cancel();
    _subscribedItemId = id;

    _dbItemSubscription = _dbService.watchItem(id).listen((item) {
      if (isClosed) return;

      if (item == null) {
        _emitIfOpen(const ResourceState.initial());
        return;
      }

      _emitIfOpen(
        ResourceState.itemLoaded(
          item: _dbService.localToRemote(item),
        ),
      );
    });
  }

  @override
  Future<void> close() {
    _dbItemSubscription?.cancel();
    return super.close();
  }

  List<String> get defaultIncludes => [];

  TRemote? get currentItem {
    return state.maybeWhen(
      itemLoading: (_, item) => item,
      itemLoaded: (item, _) => item,
      itemError: (_, _, item) => item,
      orElse: () => null,
    );
  }

  Future<TRemote?> loadCachedItem(String id) async {
    try {
      final item = await _dbService.get(id);
      return item != null ? _dbService.localToRemote(item) : null;
    } catch (e, s) {
      _logger.e('Error loading cached item', error: e, stackTrace: s);
      return null;
    }
  }

  Future<TRemote?> loadOne({
    required String id,
    required bool Function(TRemote item) matchById,
    List<String>? includes,
    bool refresh = false,
  }) async {
    final existing = currentItem;

    if (_dbItemSubscription == null || _subscribedItemId != id) {
      subscribeToDbUpdates(id);
    }

    if (existing != null && matchById(existing) && !refresh) {
      _emitIfOpen(ResourceState.itemLoaded(item: existing));
      return existing;
    }

    if (!refresh) {
      final cached = await loadCachedItem(id);
      if (cached != null) {
        _emitIfOpen(ResourceState.itemLoaded(item: cached));
        return cached;
      }
    }

    _emitIfOpen(ResourceState.itemLoading(item: existing));

    try {
      final item = await _service.get(
        ulid: id,
        includes: includes ?? defaultIncludes,
      );
      await _dbService.persistEntity(item);

      final persisted = await loadCachedItem(id);
      final finalItem = persisted ?? item;
      _emitIfOpen(ResourceState.itemLoaded(item: finalItem));
      return finalItem;
    } on Failure catch (e) {
      final cached = await loadCachedItem(id);
      if (cached != null) {
        _emitIfOpen(ResourceState.itemLoaded(item: cached));
        return cached;
      }

      _emitIfOpen(
        ResourceState.itemError(
          message: e.message,
          item: existing,
        ),
      );
    } catch (e, s) {
      final cached = await loadCachedItem(id);
      if (cached != null) {
        _emitIfOpen(ResourceState.itemLoaded(item: cached));
        return cached;
      }

      _logger.e('Error loading single resource', error: e, stackTrace: s);
      _emitIfOpen(
        ResourceState.itemError(
          message: e.toString(),
          item: existing,
        ),
      );
    }

    return existing;
  }

  Future<void> create({
    required Map<String, dynamic> data,
    List<String>? includes,
  }) async {
    final existing = currentItem;
    _emitIfOpen(ResourceState.itemLoading(item: existing));
    try {
      final item = await _service.create(
        data: data,
        includes: includes ?? defaultIncludes,
      );
      await _dbService.persistEntity(item);
      _emitIfOpen(ResourceState.itemLoaded(item: item));
    } on Failure catch (e) {
      _emitIfOpen(ResourceState.itemError(message: e.message, item: existing));
    } catch (e, s) {
      _logger.e('Error creating single resource', error: e, stackTrace: s);
      _emitIfOpen(
        ResourceState.itemError(message: e.toString(), item: existing),
      );
    }
  }

  Future<void> update({
    required String id,
    required Map<String, dynamic> data,
    List<String>? includes,
  }) async {
    final existing = currentItem;
    _emitIfOpen(ResourceState.itemLoading(item: existing));
    try {
      final item = await _service.update(
        id: id,
        data: data,
        includes: includes ?? defaultIncludes,
      );
      await _dbService.persistEntity(item);
      _emitIfOpen(ResourceState.itemLoaded(item: item));
    } on Failure catch (e) {
      _emitIfOpen(ResourceState.itemError(message: e.message, item: existing));
    } catch (e, s) {
      _logger.e('Error updating single resource', error: e, stackTrace: s);
      _emitIfOpen(
        ResourceState.itemError(message: e.toString(), item: existing),
      );
    }
  }

  Future<void> delete({required String ulid}) async {
    final existing = currentItem;
    _emitIfOpen(ResourceState.itemLoading(item: existing));
    try {
      await _service.delete(ulid: ulid);
      await _dbService.deleteByKey(ulid);
      _emitIfOpen(const ResourceState.initial());
    } on Failure catch (e) {
      _emitIfOpen(ResourceState.itemError(message: e.message, item: existing));
    } catch (e, s) {
      _logger.e('Error deleting single resource', error: e, stackTrace: s);
      _emitIfOpen(
        ResourceState.itemError(message: e.toString(), item: existing),
      );
    }
  }

  void reset() => _emitIfOpen(const ResourceState.initial());

  void _emitIfOpen(ResourceState<TRemote> nextState) {
    if (isClosed) return;
    emit(nextState);
  }
}
