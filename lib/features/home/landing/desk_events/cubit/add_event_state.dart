part of 'add_event_cubit.dart';

@freezed
class AddEventState with _$AddEventState {
  const factory AddEventState.initial() = _Initial;
  const factory AddEventState.loading() = _Loading;
  const factory AddEventState.loaded() = _Loaded;
  const factory AddEventState.error(String message) = _Error;
}
