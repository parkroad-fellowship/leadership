import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_mission_status.dart';
import 'package:leadership/models/remote/prf_accounting_event.dart';
import 'package:leadership/models/remote/prf_mission_expense.dart';
import 'package:leadership/models/remote/prf_mission_type.dart';
import 'package:leadership/models/remote/prf_school.dart';

part 'prf_mission.freezed.dart';
part 'prf_mission.g.dart';

@freezed
abstract class PRFMission with _$PRFMission {
  factory PRFMission(
    String ulid,
    @JsonKey(name: 'start_date') DateTime startDate,
    @JsonKey(name: 'start_time') String startTime,
    @JsonKey(name: 'end_date') DateTime endDate,
    @JsonKey(name: 'end_time') String endTime,
    int capacity,
    PRFMissionStatus status,
    @JsonKey(name: 'mission_subscriptions_needed')
    int missionSubscriptionsNeeded,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt, {
    @JsonKey(name: 'mission_prep_notes') String? missionPrepNotes,
    @Default('Open Topic') String? theme,
    @JsonKey(name: 'whats_app_link') String? whatsAppLink,
    PRFSchool? school,
    @JsonKey(name: 'mission_type') PRFMissionType? missionType,
    @JsonKey(name: 'mission_expense') PRFMissionExpense? missionExpense,
    @JsonKey(name: 'accounting_event') PRFAccountingEvent? accountingEvent,
  }) = _PRFMission;

  factory PRFMission.fromJson(Map<String, dynamic> json) =>
      _$PRFMissionFromJson(json);
}

@freezed
abstract class PRFMissionsResponse with _$PRFMissionsResponse {
  factory PRFMissionsResponse(List<PRFMission> data) = _PRFMissionsResponse;

  factory PRFMissionsResponse.fromJson(Map<String, dynamic> json) =>
      _$PRFMissionsResponseFromJson(json);
}
