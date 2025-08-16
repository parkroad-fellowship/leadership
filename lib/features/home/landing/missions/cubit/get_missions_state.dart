part of 'get_missions_cubit.dart';

@freezed
class GetMissionsState with _$GetMissionsState {
  const factory GetMissionsState.initial() = _Initial;
  const factory GetMissionsState.loading() = _Loading;
  const factory GetMissionsState.loaded({
    required List<PRFMission> missions,
  }) = _Loaded;
  const factory GetMissionsState.error(String message) = _Error;
}
