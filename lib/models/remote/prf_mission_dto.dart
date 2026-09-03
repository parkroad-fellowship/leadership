import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leadership/enums/prf_mission_status.dart';

part 'prf_mission_dto.freezed.dart';
part 'prf_mission_dto.g.dart';

String _formatDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

@freezed
abstract class PRFMissionDTO with _$PRFMissionDTO {
  factory PRFMissionDTO({
    @JsonKey(name: 'school_term_ulid') required String schoolTermUlid,
    @JsonKey(name: 'mission_type_ulid') required String missionTypeUlid,
    @JsonKey(name: 'school_ulid') required String schoolUlid,
    @JsonKey(name: 'start_date', toJson: _formatDate)
    required DateTime startDate,
    @JsonKey(name: 'end_date', toJson: _formatDate) required DateTime endDate,
    @JsonKey(name: 'start_time') required String startTime,
    @JsonKey(name: 'end_time') required String endTime,
    String? theme,
    int? capacity,
    @JsonEnum() PRFMissionStatus? status,
    @JsonKey(name: 'mission_prep_notes') String? missionPrepNotes,
    @JsonKey(name: 'dressing_recommendations') String? dressingRecommendations,
    @JsonKey(name: 'activity_recommendations') String? activityRecommendations,
    @JsonKey(name: 'whats_app_link') String? whatsAppLink,
    @JsonKey(name: 'weather_recommendations')
    List<String>? weatherRecommendations,
    @JsonKey(name: 'offline_members') List<String>? offlineMembers,
    @JsonKey(name: 'executive_summary') String? executiveSummary,
  }) = _PRFMissionDTO;

  factory PRFMissionDTO.fromJson(Map<String, dynamic> json) =>
      _$PRFMissionDTOFromJson(json);
}
