part of 'get_mission_cubit.dart';

@freezed
class GetMissionState with _$GetMissionState {
  const factory GetMissionState.initial() = _Initial;
  const factory GetMissionState.loading() = _Loading;
  const factory GetMissionState.loaded({
    required PRFMission mission,
  }) = _Loaded;
  const factory GetMissionState.error(String error) = _Error;
}
