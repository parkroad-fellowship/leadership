part of 'get_events_cubit.dart';

@freezed
abstract class GetEventsState with _$GetEventsState {
  const factory GetEventsState.initial() = _Initial;
  const factory GetEventsState.loading() = _Loading;
  const factory GetEventsState.loaded({required List<PRFEvent> events}) =
      _Loaded;
  const factory GetEventsState.empty() = _Empty;
  const factory GetEventsState.error(String message) = _Error;
}
