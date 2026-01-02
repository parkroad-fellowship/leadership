part of 'delete_contact_cubit.dart';

@freezed
abstract class DeleteContactState with _$DeleteContactState {
  const factory DeleteContactState.initial() = _Initial;
  const factory DeleteContactState.loading() = _Loading;
  const factory DeleteContactState.loaded() = _Loaded;
  const factory DeleteContactState.error(String message) = _Error;
}
