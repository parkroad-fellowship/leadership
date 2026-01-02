part of 'edit_allocation_entry_cubit.dart';

@freezed
abstract class EditAllocationEntryState with _$EditAllocationEntryState {
  const factory EditAllocationEntryState.initial() = _Initial;
  const factory EditAllocationEntryState.loading() = _Loading;
  const factory EditAllocationEntryState.loaded() = _Loaded;
  const factory EditAllocationEntryState.error(String message) = _Error;
}
