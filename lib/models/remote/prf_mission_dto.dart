import 'package:leadership/enums/prf_mission_status.dart';

class PRFMissionDTO {
  PRFMissionDTO({
    required this.schoolTermUlid,
    required this.missionTypeUlid,
    required this.schoolUlid,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    this.theme,
    this.capacity,
    this.status,
    this.missionPrepNotes,
    this.dressingRecommendations,
    this.activityRecommendations,
    this.whatsAppLink,
    this.weatherRecommendations,
    this.offlineMembers,
    this.executiveSummary,
  });

  final String schoolTermUlid;
  final String missionTypeUlid;
  final String schoolUlid;
  final DateTime startDate;
  final DateTime endDate;
  final String startTime;
  final String endTime;
  final String? theme;
  final int? capacity;
  final PRFMissionStatus? status;
  final String? missionPrepNotes;
  final String? dressingRecommendations;
  final String? activityRecommendations;
  final String? whatsAppLink;
  final List<String>? weatherRecommendations;
  final List<String>? offlineMembers;
  final String? executiveSummary;

  Map<String, dynamic> toJson() {
    return {
      'school_term_ulid': schoolTermUlid,
      'mission_type_ulid': missionTypeUlid,
      'school_ulid': schoolUlid,
      'start_date': _formatDate(startDate),
      'end_date': _formatDate(endDate),
      'start_time': startTime,
      'end_time': endTime,
      if (theme != null) 'theme': theme,
      if (capacity != null) 'capacity': capacity,
      if (status != null) 'status': status!.apiKey,
      if (missionPrepNotes != null) 'mission_prep_notes': missionPrepNotes,
      if (dressingRecommendations != null)
        'dressing_recommendations': dressingRecommendations,
      if (activityRecommendations != null)
        'activity_recommendations': activityRecommendations,
      if (whatsAppLink != null) 'whats_app_link': whatsAppLink,
      if (weatherRecommendations != null)
        'weather_recommendations': weatherRecommendations,
      if (offlineMembers != null) 'offline_members': offlineMembers,
      if (executiveSummary != null) 'executive_summary': executiveSummary,
    };
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
