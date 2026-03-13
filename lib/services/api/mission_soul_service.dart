import 'package:leadership/models/remote/prf_mission_soul.dart';
import 'package:leadership/services/api/_base_api_service.dart';

class MissionSoulService extends BaseAPIService<PRFMissionSoul> {
  @override
  String get endpoint => '/mission-souls';

  @override
  PRFMissionSoul createFromJson(Map<String, dynamic> json) {
    return PRFMissionSoul.fromJson(json);
  }

  @override
  List<PRFMissionSoul> createListFromResponse(Map<String, dynamic> response) {
    final rawData = response['data'];
    if (rawData is! List) return <PRFMissionSoul>[];

    return rawData
        .whereType<Map<String, dynamic>>()
        .map(PRFMissionSoul.fromJson)
        .toList(growable: false);
  }
}
