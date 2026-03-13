import 'package:leadership/models/remote/mission/prf_mission_session.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class MissionSessionService extends BaseAPIService<PRFMissionSession> {
  @override
  String get endpoint => '/mission-sessions';

  @override
  PRFMissionSession createFromJson(Map<String, dynamic> json) {
    return PRFMissionSession.fromJson(json);
  }

  @override
  List<PRFMissionSession> createListFromResponse(
    Map<String, dynamic> response,
  ) {
    final rawData = response['data'];
    if (rawData is! List) return <PRFMissionSession>[];

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(PRFMissionSession.fromJson)
        .toList(growable: false);
  }
}
