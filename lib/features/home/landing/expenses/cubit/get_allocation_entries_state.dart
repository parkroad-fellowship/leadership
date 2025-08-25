part of 'get_allocation_entries_cubit.dart';

@freezed
abstract class GetAllocationEntriesState with _$GetAllocationEntriesState {
  const factory GetAllocationEntriesState.initial() = _Initial;
  const factory GetAllocationEntriesState.loading() = _Loading;
  const factory GetAllocationEntriesState.loaded({
    required List<PRFAllocationEntry> entries,
  }) = _Loaded;
  const factory GetAllocationEntriesState.empty() = _Empty;
  const factory GetAllocationEntriesState.error(String message) = _Error;
}
