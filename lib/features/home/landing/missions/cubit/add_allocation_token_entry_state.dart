part of 'add_allocation_token_entry_cubit.dart';

@freezed
class AddAllocationTokenEntryState with _$AddAllocationTokenEntryState {
  const factory AddAllocationTokenEntryState.initial() = _Initial;
  const factory AddAllocationTokenEntryState.loading() = _Loading;
  const factory AddAllocationTokenEntryState.loaded() = _Loaded;
  const factory AddAllocationTokenEntryState.error(String message) = _Error;
}
