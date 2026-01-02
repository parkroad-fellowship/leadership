part of 'delete_contact_type_cubit.dart';

@freezed
abstract class DeleteContactTypeState with _$DeleteContactTypeState {
  const factory DeleteContactTypeState.initial() = _Initial;
  const factory DeleteContactTypeState.loading() = _Loading;
  const factory DeleteContactTypeState.loaded() = _Loaded;
  const factory DeleteContactTypeState.error(String message) = _Error;
}
