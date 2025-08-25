part of 'get_allocations_cubit.dart';

@freezed
abstract class GetAllocationsState with _$GetAllocationsState {
  const factory GetAllocationsState.initial() = _Initial;
  const factory GetAllocationsState.loading() = _Loading;
  const factory GetAllocationsState.loaded({
    required List<PRFAllocation> allocations,
  }) = _Loaded;
  const factory GetAllocationsState.empty() = _Empty;
  const factory GetAllocationsState.error(String message) = _Error;
}
