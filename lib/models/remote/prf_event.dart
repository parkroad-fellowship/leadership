import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_event_type.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/models/remote/prf_media.dart';
import 'package:leadership/models/remote/prf_weather_forecast.dart';

part 'prf_event.freezed.dart';
part 'prf_event.g.dart';

@freezed
abstract class PRFEvent with _$PRFEvent {
  factory PRFEvent(
    String ulid,
    String name,
    String description,
    @JsonKey(name: 'start_date') DateTime startDate,
    @JsonKey(name: 'start_time') String startTime,
    @JsonKey(name: 'end_date') DateTime endDate,
    @JsonKey(name: 'end_time') String endTime,
    int capacity, {
    String? venue,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'event_subscriptions_needed') int? subscriptionsNeeded,
    @JsonEnum() @JsonKey(name: 'event_type') PRFEventType? eventType,
    @JsonKey(name: 'accounting_event') PRFAccountingEvent? accountingEvent,
    @Default([]) List<PRFMedia> posters,
    @JsonKey(name: 'weather_forecasts')
    @Default([])
    List<PRFWeatherForecast> weatherForecasts,
  }) = _PRFEvent;

  factory PRFEvent.fromJson(Map<String, dynamic> json) =>
      _$PRFEventFromJson(json);
}

@freezed
abstract class PRFEventResponse with _$PRFEventResponse {
  factory PRFEventResponse({@Default([]) List<PRFEvent> data}) =
      _PRFEventResponse;
  factory PRFEventResponse.fromJson(Map<String, dynamic> json) =>
      _$PRFEventResponseFromJson(json);
}
