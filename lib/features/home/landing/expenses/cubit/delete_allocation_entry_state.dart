part of 'delete_allocation_entry_cubit.dart';

@freezed
abstract class DeleteAllocationEntryState with _$DeleteAllocationEntryState {
  const factory DeleteAllocationEntryState.initial() = _Initial;
  const factory DeleteAllocationEntryState.loading() = _Loading;
  const factory DeleteAllocationEntryState.loaded() = _Loaded;
  const factory DeleteAllocationEntryState.error(String message) = _Error;
}
