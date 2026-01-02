part of 'create_contact_cubit.dart';

@freezed
abstract class CreateContactState with _$CreateContactState {
  const factory CreateContactState.initial() = _Initial;
  const factory CreateContactState.loading() = _Loading;
  const factory CreateContactState.loaded({required PRFContact contact}) =
      _Loaded;
  const factory CreateContactState.error(String message) = _Error;
}
