part of 'delete_school_cubit.dart';

@freezed
abstract class DeleteSchoolState with _$DeleteSchoolState {
  const factory DeleteSchoolState.initial() = _Initial;
  const factory DeleteSchoolState.loading() = _Loading;
  const factory DeleteSchoolState.loaded() = _Loaded;
  const factory DeleteSchoolState.error(String message) = _Error;
}
