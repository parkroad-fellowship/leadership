part of 'create_school_cubit.dart';

@freezed
abstract class CreateSchoolState with _$CreateSchoolState {
  const factory CreateSchoolState.initial() = _Initial;
  const factory CreateSchoolState.loading() = _Loading;
  const factory CreateSchoolState.loaded({required PRFSchool school}) = _Loaded;
  const factory CreateSchoolState.error(String message) = _Error;
}
