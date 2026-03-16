import 'package:freezed_annotation/freezed_annotation.dart';

part 'resource_state.freezed.dart';

/// Generic state for any CRUD resource.
@Freezed(genericArgumentFactories: true)
abstract class ResourceState<T> with _$ResourceState<T> {
  /// Initial state before any operation.
  const factory ResourceState.initial() = ResourceInitial<T>;

  /// Loading a list of resources.
  const factory ResourceState.listLoading() = ResourceListLoading<T>;

  /// Successfully loaded a list.
  const factory ResourceState.listLoaded({
    required List<T> items,
    @Default(1) int page,
    @Default(false) bool hasMore,
  }) = ResourceListLoaded<T>;

  /// A mutation (create/update/delete) is in progress.
  /// Preserves the current list so the UI doesn't blank.
  const factory ResourceState.mutating({
    required List<T> items,
    required ResourceOperation operation,
  }) = ResourceMutating<T>;

  /// A mutation succeeded. Contains the updated list and affected item.
  const factory ResourceState.mutated({
    required List<T> items,
    required ResourceOperation operation,
    T? item,
  }) = ResourceMutated<T>;

  /// Any operation failed. Preserves the last good list for UI recovery.
  const factory ResourceState.error({
    required String message,
    @Default([]) List<T> items,
  }) = ResourceError<T>;
}

/// Which mutation is in progress or just completed.
enum ResourceOperation { create, update, delete }
