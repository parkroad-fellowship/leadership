part of 'get_past_missions_cubit.dart';

@freezed
class GetPastMissionsState with _$GetPastMissionsState {
  const factory GetPastMissionsState.initial() = _Initial;
  const factory GetPastMissionsState.loading() = _Loading;
  const factory GetPastMissionsState.loaded({
    required List<PRFMission> missions,
  }) = _Loaded;
  const factory GetPastMissionsState.error(String message) = _Error;
}
