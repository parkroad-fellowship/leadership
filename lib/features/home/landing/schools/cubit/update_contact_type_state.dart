part of 'update_contact_type_cubit.dart';

@freezed
abstract class UpdateContactTypeState with _$UpdateContactTypeState {
  const factory UpdateContactTypeState.initial() = _Initial;
  const factory UpdateContactTypeState.loading() = _Loading;
  const factory UpdateContactTypeState.loaded({
    required PRFContactType contactType,
  }) = _Loaded;
  const factory UpdateContactTypeState.error(String message) = _Error;
}
