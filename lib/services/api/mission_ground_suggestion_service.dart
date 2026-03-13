import 'package:leadership/models/remote/mission/prf_mission_ground_suggestion.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class MissionGroundSuggestionService
    extends BaseAPIService<PRFMissionGroundSuggestion> {
  @override
  String get endpoint => '/mission-ground-suggestions';

  @override
  PRFMissionGroundSuggestion createFromJson(Map<String, dynamic> json) {
    return PRFMissionGroundSuggestion.fromJson(json);
  }

  @override
  List<PRFMissionGroundSuggestion> createListFromResponse(
    Map<String, dynamic> response,
  ) {
    final rawData = response['data'];
    if (rawData is! List) return <PRFMissionGroundSuggestion>[];

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(PRFMissionGroundSuggestion.fromJson)
        .toList(growable: false);
  }
}
