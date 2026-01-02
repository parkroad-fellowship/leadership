part of 'get_schools_cubit.dart';

@freezed
abstract class GetSchoolsState with _$GetSchoolsState {
  const factory GetSchoolsState.initial() = _Initial;
  const factory GetSchoolsState.loading() = _Loading;
  const factory GetSchoolsState.loaded({
    required List<PRFSchool> schools,
  }) = _Loaded;
  const factory GetSchoolsState.error(String message) = _Error;
}
