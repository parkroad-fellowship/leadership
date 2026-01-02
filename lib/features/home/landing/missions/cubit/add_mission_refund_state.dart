part of 'add_mission_refund_cubit.dart';

@freezed
class AddMissionRefundState with _$AddMissionRefundState {
  const factory AddMissionRefundState.initial() = _Initial;
  const factory AddMissionRefundState.loading() = _Loading;
  const factory AddMissionRefundState.loaded({
    required PRFRefund refund,
  }) = _Loaded;
  const factory AddMissionRefundState.error(String message) = _Error;
}
