part of 'update_school_cubit.dart';

@freezed
abstract class UpdateSchoolState with _$UpdateSchoolState {
  const factory UpdateSchoolState.initial() = _Initial;
  const factory UpdateSchoolState.loading() = _Loading;
  const factory UpdateSchoolState.loaded({required PRFSchool school}) = _Loaded;
  const factory UpdateSchoolState.error(String message) = _Error;
}
