part of 'get_past_events_cubit.dart';

@freezed
abstract class GetPastEventsState with _$GetPastEventsState {
  const factory GetPastEventsState.initial() = _Initial;
  const factory GetPastEventsState.loading() = _Loading;
  const factory GetPastEventsState.loaded({
    required List<PRFEvent> events,
  }) = _Loaded;
  const factory GetPastEventsState.empty() = _Empty;
  const factory GetPastEventsState.error(String message) = _Error;
}
