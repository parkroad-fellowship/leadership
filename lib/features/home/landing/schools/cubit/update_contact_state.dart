part of 'update_contact_cubit.dart';

@freezed
abstract class UpdateContactState with _$UpdateContactState {
  const factory UpdateContactState.initial() = _Initial;
  const factory UpdateContactState.loading() = _Loading;
  const factory UpdateContactState.loaded({required PRFContact contact}) =
      _Loaded;
  const factory UpdateContactState.error(String message) = _Error;
}
