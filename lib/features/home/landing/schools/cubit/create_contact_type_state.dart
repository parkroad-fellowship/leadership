part of 'create_contact_type_cubit.dart';

@freezed
abstract class CreateContactTypeState with _$CreateContactTypeState {
  const factory CreateContactTypeState.initial() = _Initial;
  const factory CreateContactTypeState.loading() = _Loading;
  const factory CreateContactTypeState.loaded({
    required PRFContactType contactType,
  }) = _Loaded;
  const factory CreateContactTypeState.error(String message) = _Error;
}
