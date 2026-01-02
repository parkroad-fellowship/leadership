part of 'add_allocation_entry_cubit.dart';

@freezed
abstract class AddAllocationEntryState with _$AddAllocationEntryState {
  const factory AddAllocationEntryState.initial() = _Initial;
  const factory AddAllocationEntryState.loading() = _Loading;
  const factory AddAllocationEntryState.loaded() = _Loaded;
  const factory AddAllocationEntryState.error(String message) = _Error;
}
