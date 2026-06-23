import 'package:freezed_annotation/freezed_annotation.dart';

part 'resource_state.freezed.dart';

@Freezed(genericArgumentFactories: true)
abstract class ResourceState<T> with _$ResourceState<T> {
  const factory ResourceState.initial() = ResourceInitial<T>;

  const factory ResourceState.listLoading() = ResourceListLoading<T>;

  const factory ResourceState.itemLoading({
    @Default([]) List<T> items,
    T? item,
  }) = ResourceItemLoading<T>;

  const factory ResourceState.listLoaded({
    required List<T> items,
    @Default(1) int page,
    @Default(false) bool hasMore,
  }) = ResourceListLoaded<T>;

  const factory ResourceState.itemLoaded({
    required T item,
    @Default([]) List<T> items,
  }) = ResourceItemLoaded<T>;

  const factory ResourceState.mutating({
    required List<T> items,
    required ResourceOperation operation,
  }) = ResourceMutating<T>;

  const factory ResourceState.mutated({
    required List<T> items,
    required ResourceOperation operation,
    T? item,
  }) = ResourceMutated<T>;

  const factory ResourceState.error({
    required String message,
    @Default([]) List<T> items,
  }) = ResourceError<T>;

  const factory ResourceState.itemError({
    required String message,
    @Default([]) List<T> items,
    T? item,
  }) = ResourceItemError<T>;
}

enum ResourceOperation { create, update, delete }
